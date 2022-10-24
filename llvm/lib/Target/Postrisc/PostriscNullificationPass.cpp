//===-- PostriscNullificationPass.cpp - Transform to Predicated Code ------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
//
//===----------------------------------------------------------------------===//

#include "Postrisc.h"
#include "PostriscMachineFunctionInfo.h"
#include "PostriscSubtarget.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/CodeGen/MachineBasicBlock.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineInstrBundle.h"
#include "llvm/CodeGen/MachineOperand.h"
using namespace llvm;

#define DEBUG_TYPE "postrisc-nullification"
#define PASS_NAME "Postrisc Nullification"

static cl::opt<bool>
EnableNullify("enable-nullification",
              cl::init(false),
              cl::desc("Enable nullification instructions"),
              cl::NotHidden);

static cl::opt<bool>
EnableMoveMerging("enable-move-merging",
              cl::init(false),
              cl::desc("Enable mov2 merging"),
              cl::NotHidden);

static cl::opt<int>
MaxNullificationBlockSize("max-nullification-blocksize",
               cl::init(10),
               cl::desc("Maximum nullification block size"),
               cl::NotHidden);

STATISTIC(NumNullifications, "Number of nullification instructions inserted");

STATISTIC(NumMov2Merges, "Number of mov2 merges");

static unsigned
getNullificationOpc(unsigned Opc, bool& swap_args, bool& swap_blocks) {
  switch (Opc) {
// X - short/long branch converts to short nullification
#define X(COND)                                      \
  case POSTRISC::insn_b##COND:                       \
    swap_args = false;                               \
    swap_blocks = false;                             \
    return POSTRISC::insn_nul##COND;                 \
  case POSTRISC::insn_b##COND##_ext:                 \
    swap_args = false;                               \
    swap_blocks = false;                             \
    return POSTRISC::insn_nul##COND;

  X(deq) X(dne) X(dlt) X(dle) X(dltu) X(dleu)
  X(weq) X(wne) X(wlt) X(wle) X(wltu) X(wleu)
  X(bs) X(bc) X(bsi) X(bci)
  X(fssoeq) X(fssone) X(fssolt) X(fssole) X(fsso)
  X(fssueq) X(fssune) X(fssult) X(fssule) X(fssuo)
  X(fsdoeq) X(fsdone) X(fsdolt) X(fsdole) X(fsdo)
  X(fsdueq) X(fsdune) X(fsdult) X(fsdule) X(fsduo)
  X(fsqoeq) X(fsqone) X(fsqolt) X(fsqole) X(fsqo)
  X(fsqueq) X(fsqune) X(fsqult) X(fsqule) X(fsquo)

// XX - short/long branch converts to corresponding short/long nullification
#define XX(COND)                                     \
  case POSTRISC::insn_b##COND:                       \
    swap_args = false;                               \
    swap_blocks = false;                             \
    return POSTRISC::insn_nul##COND;                 \
  case POSTRISC::insn_b##COND##_ext:                 \
    swap_args = false;                               \
    swap_blocks = false;                             \
    return POSTRISC::insn_nul##COND##_ext;

  XX(mall) XX(mnotall) XX(mnone) XX(many)
  XX(deqi) XX(dnei) XX(dlti) XX(dltui)
  XX(weqi) XX(wnei) XX(wlti) XX(wltui)

// short/long branch converts to corresponding short/long nullification, plus block inversion
#define XXSWAP(BCOND, NCOND)                         \
  case POSTRISC::insn_b##BCOND:                      \
    swap_args = false;                               \
    swap_blocks = true;                              \
    return POSTRISC::insn_nul##NCOND;                \
  case POSTRISC::insn_b##BCOND##_ext:                \
    swap_args = false;                               \
    swap_blocks = true;                              \
    return POSTRISC::insn_nul##NCOND##_ext;

  XXSWAP(dgei, dlti) XXSWAP(dgeui, dltui)
  XXSWAP(wgei, wlti) XXSWAP(wgeui, wltui)

  default:
    LLVM_DEBUG(dbgs() << "Opc=" << Opc << "\n");
    llvm_unreachable("The branch instruction without nullification analog!");
    return -1;
  }
}

namespace llvm {
  void initializePostriscNullificationPass(PassRegistry &);
} // namespace llvm

namespace {
  class PostriscNullification : public MachineFunctionPass {
  public:
    static char ID;
    const PostriscInstrInfo *TII;

    PostriscNullification() : MachineFunctionPass(ID) {}

    bool runOnMachineFunction(MachineFunction &MF) override;

    StringRef getPassName() const override {
      return PASS_NAME;
    }
  private:
    bool TryMergeBlocks(MachineFunction &MF, MachineBasicBlock& MBB);
    bool MergeMoves(MachineFunction &MF);
    bool MergeMoves(MachineBasicBlock& MBB);
    bool onePass(MachineFunction &MF);
    bool AnalyzeBranch(MachineBasicBlock *Head, MachineBasicBlock *&TBB,
         MachineBasicBlock *&FBB, SmallVector<MachineOperand, 4> &Cond);
    int checkBlock(const MachineBasicBlock& MBB);
    bool Convert(MachineFunction &MF, MachineBasicBlock *Head, MachineBasicBlock *Succ0,
         MachineBasicBlock *Succ1, MachineBasicBlock *Tail);
  };
  char PostriscNullification::ID = 0;
} // end anonymous namespace

INITIALIZE_PASS(PostriscNullification, DEBUG_TYPE, PASS_NAME, false, false)

bool PostriscNullification::MergeMoves(MachineBasicBlock& MBB) {
  LLVM_DEBUG(dbgs() << "MergeMoves:\n");
  //MBB.dump();
  MachineInstr *Prev = nullptr;
  for (auto & MI : MBB) {
    LLVM_DEBUG(dbgs() << "MRG: " << MI.getOpcode() << " " << MI << "\n");
    if (Prev && Prev->isCopy() && MI.isCopy()) {
      assert(Prev->getOperand(0).isReg() && "1st mov 1st operand should be register");
      assert(Prev->getOperand(1).isReg() && "1st mov 2nd operand should be register");
      assert(MI.getOperand(0).isReg() && "2nd mov 1st operand should be register");
      assert(MI.getOperand(1).isReg() && "2nd mov 2nd operand should be register");

      Register dst1 = Prev->getOperand(0).getReg();
      Register src1 = Prev->getOperand(1).getReg();
      Register dst2 = MI.getOperand(0).getReg();
      Register src2 = MI.getOperand(1).getReg();

      bool const do_merge = (src2 != dst1)
                         && (src1 != src2);
      if (do_merge) {
        DebugLoc DL;
        LLVM_DEBUG(dbgs() << "insert mov2: mov=" << *Prev << " mov=" << MI << "\n");
        MachineInstrBuilder MIB = BuildMI(MBB, MI, DL, TII->get(POSTRISC::MOV2));
        MIB.addReg(dst1);
        MIB.addReg(dst2);
        MIB.addReg(src1);
        MIB.addReg(src2);
        assert(MIB->getOperand(0).isReg() && "mov2 1st operand should be register");
        assert(MIB->getOperand(1).isReg() && "mov2 2nd operand should be register");
        MIB->getOperand(0).setIsDef();
        MIB->getOperand(1).setIsDef();
        Prev->eraseFromParent();
        MI.eraseFromParent();
        ++NumMov2Merges;
        return true;
      }
    }
    Prev = &MI;
  }

  return false;
}

bool PostriscNullification::MergeMoves(MachineFunction &MF) {
  LLVM_DEBUG(dbgs() << "MergeMoves: MF=" << MF.getName() << "\n");
  bool Changed = false;
  // If merged, start again.
  for (auto &MBB : MF) {
    while (MergeMoves(MBB)) {
      Changed = true;
    }
  }
  return Changed;
}

// Returns true if branch can be changed to a nullification
bool PostriscNullification::AnalyzeBranch(MachineBasicBlock *Head, MachineBasicBlock *&TBB,
  MachineBasicBlock *&FBB, SmallVector<MachineOperand, 4> &Cond) {

  Cond.clear();
  TBB = nullptr;
  FBB = nullptr;
  // Analyze the branching code at the end of MBB, returning true if it cannot be understood
  if (TII->analyzeBranch(*Head, TBB, FBB, Cond, false)) {
    LLVM_DEBUG(dbgs() << "Branch not analyzable.\n");
    return false;
  }
  if (!TBB) { // This is weird, probably some sort of degenerate CFG.
    LLVM_DEBUG(dbgs() << "AnalyzeBranch didn't find conditional branch.\n");
    return false;
  }
  // Make sure the analyzed branch is conditional; one of the successors
  // could be a landing pad. (Empty landing pads can be generated on Windows.)
  if (Cond.empty()) {
    LLVM_DEBUG(dbgs() << "AnalyzeBranch found an unconditional branch.\n");
    return false;
  }
  if (FBB) {
    if (FBB == Head->getFallThrough()) {
       LLVM_DEBUG(dbgs() << "\tcond/uncond branch pair, uncond branch to fallthru\n");
       // MachineBasicBlock::iterator I = Head->getLastNonDebugInstr();
       // I->eraseFromParent();        // Remove the branch.
    }
  }
  LLVM_DEBUG(dbgs() << "\tbranch analyzed\n");
  return true;
}

// Count how many valid instructions can be predicated.
// If theres a call that is not at the end, return 0.
// Any branch should be at the end.
int PostriscNullification::checkBlock(const MachineBasicBlock& MBB) {
  int NumInstrs = 0;
  for (const auto & MI : MBB) {
    unsigned const Opc = MI.getOpcode();
    // currently we can't properly count possible NOPs before long instruction
    if (TII->isLong(Opc)) {
      return -1;
    }
    switch (Opc) {
    case TargetOpcode::CFI_INSTRUCTION:
    case TargetOpcode::MEMBARRIER:
    case TargetOpcode::EH_LABEL:
      return -1;  // continue;
    default:
      break;
    }
    if (MI.isTerminator()) {
       if (&MI == MBB.getFirstTerminator()) {
         return NumInstrs;
       }
    }
    // calls are not nullificable
    //if (MI.isCall() || MI.isBranch() || MI.isTerminator())
    //  return -1;
    ++NumInstrs;
    if (NumInstrs > std::min<int>(15, MaxNullificationBlockSize))
      return -1;
  }
  return NumInstrs;
}

bool PostriscNullification::Convert(MachineFunction &MF,
        MachineBasicBlock *Head, MachineBasicBlock *Succ0,
        MachineBasicBlock *Succ1, MachineBasicBlock *Tail) {

  LLVM_DEBUG(dbgs() << "PostriscNullification::Convert\n");
  MachineBasicBlock *TBB = nullptr, *FBB = nullptr;
  SmallVector<MachineOperand, 4> Cond;

  if (!AnalyzeBranch(Head, TBB, FBB, Cond))
    return false;
  // AnalyzeBranch doesn't set FBB on a fall-through branch.
  FBB = (TBB == Succ0) ? Succ1 : Succ0;

  LLVM_DEBUG(dbgs() << "\tTBB=" << printMBBReference(*TBB) << '\n'
                    << "\tFBB=" << printMBBReference(*FBB) << '\n');

  // See how many instructions we can shadow
  int const ninstrsT = (TBB == Tail) ? 0 : checkBlock(*TBB);
  int const ninstrsF = (FBB == Tail) ? 0 : checkBlock(*FBB);
  LLVM_DEBUG(dbgs() << "\tninstr=" << ninstrsT << ',' << ninstrsF << '\n');

  if (ninstrsT < 0 || ninstrsF < 0 ||    // unpredicatable instructions
     (ninstrsT == 0 && ninstrsF == 0) ||
     ninstrsT + ninstrsF > 2 * std::min<int>(15, MaxNullificationBlockSize))
    return false;

  MachineBasicBlock::iterator IP = Head->getFirstTerminator();
  DebugLoc dl = IP->getDebugLoc();

  unsigned const brop = Cond[0].getImm();
  bool swap_args = false;
  bool swap_blocks = false;
  int const nulOp = getNullificationOpc(brop, swap_args, swap_blocks);
  if (nulOp < 0)
    return false;

  assert(Cond[0].isImm());
  unsigned const Opc = Cond[0].getImm();
  LLVM_DEBUG(dbgs() << "Opc=" << Opc << "\n");

  if (swap_args) {
    // opc ra, rb, bb <=> opcOpp rb, ra, bb
    assert(Cond[1].isReg() && "invalid cond MachineOperand r1");
    assert(Cond[2].isReg() && "invalid cond MachineOperand r2");
    LLVM_DEBUG(dbgs() << "reverseBranchCondition SWAP regs: "
                      << Cond[1] << " " << Cond[2] << "\n");
    std::swap(Cond[1], Cond[2]);
  }

  LLVM_DEBUG(dbgs() << "\nHead: " << MF.getName() << "\n"; Head->dump());

  // Create the nullification instruction
  MachineInstrBuilder MIB = BuildMI(*Head, IP, dl, TII->get(nulOp));
  for (unsigned i = 1; i < Cond.size(); ++i) {
    assert((Cond[i].isImm() || Cond[i].isReg())
           && "Cannot copy operand for conditional nullification!");
    MIB.add(Cond[i]);
    LLVM_DEBUG(dbgs() << "after MIB.Add\n");
  }

  if (swap_blocks) {
    MIB.addImm(ninstrsT);
    MIB.addImm(ninstrsF);
  } else {
    MIB.addImm(ninstrsF);
    MIB.addImm(ninstrsT);
  }

  // FIXME: temp stop
  // return false;

  // Move all instructions into Head, except for the terminators.
  if (swap_blocks) {
    if (TBB != Tail) {
      LLVM_DEBUG(dbgs() << "\nTBB (merged 1st): " << MF.getName() << ":\n"; TBB->dump());
      Head->splice(IP, TBB, TBB->begin(), TBB->getFirstTerminator());
    }
    if (FBB != Tail) {
      LLVM_DEBUG(dbgs() << "\nFBB (merged 2nd): " << MF.getName() << "\n"; FBB->dump());
      Head->splice(IP, FBB, FBB->begin(), FBB->getFirstTerminator());
    }
  } else {
    if (FBB != Tail) {
      LLVM_DEBUG(dbgs() << "\nFBB (merged 1st): " << MF.getName() << "\n"; FBB->dump());
      Head->splice(IP, FBB, FBB->begin(), FBB->getFirstTerminator());
    }
    if (TBB != Tail) {
      LLVM_DEBUG(dbgs() << "\nTBB (merged 2nd): " << MF.getName() << "\n"; TBB->dump());
      Head->splice(IP, TBB, TBB->begin(), TBB->getFirstTerminator());
    }
  }

  // Are there extra Tail predecessors?
  bool ExtraPreds = Tail->pred_size() != 2;

  // Fix up the CFG, temporarily leave Head without any successors.
  Head->removeSuccessor(TBB);
  Head->removeSuccessor(FBB, true);
  if (TBB != Tail)
    TBB->removeSuccessor(Tail, true);
  if (FBB != Tail)
    FBB->removeSuccessor(Tail, true);

  // Fix up Head's terminators.
  // It should become a single branch or a fallthrough.
  DebugLoc HeadDL = Head->getFirstTerminator()->getDebugLoc();
  LLVM_DEBUG(dbgs() << "\tremove branch from Head\n");
  TII->removeBranch(*Head);
  if (Head->getFirstTerminator() != nullptr) {
    LLVM_DEBUG(dbgs() << "\tperhaps 2 branches were in head?\n");
  }

  // Erase the now empty conditional blocks.
  // It is likely that Head can fall through to Tail, and we can join the two blocks.
  if (TBB != Tail) {
    TBB->eraseFromParent();
  }
  if (FBB != Tail) {
    FBB->eraseFromParent();
  }

  LLVM_DEBUG(dbgs() << "\nHead (merged): " << MF.getName() << "\n"; Head->dump());

  assert(Head->succ_empty() && "Additional head successors?");
  if (!ExtraPreds && Head->isLayoutSuccessor(Tail)) {
    // Splice Tail onto the end of Head.
    LLVM_DEBUG(dbgs() << "\tjoining tail " << printMBBReference(*Tail)
                      << " into head " << printMBBReference(*Head) << '\n');
    Head->splice(Head->end(), Tail, Tail->begin(), Tail->end());
    Head->transferSuccessors(Tail);
    Tail->eraseFromParent();

    LLVM_DEBUG(dbgs() << "\nHead (tailed): " << MF.getName() << "\n"; Head->dump());
  } else {
    // We need a branch to Tail, let code placement work it out later.
    LLVM_DEBUG(dbgs() << "\tconverting to unconditional branch.\n");
    SmallVector<MachineOperand, 0> EmptyCond;
    TII->insertBranch(*Head, Tail, nullptr, EmptyCond, HeadDL);
    Head->addSuccessor(Tail);

    LLVM_DEBUG(dbgs() << "\nHead (final): " << MF.getName() << "\n"; Head->dump());
  }

  return true;
}

bool PostriscNullification::TryMergeBlocks(MachineFunction &MF, MachineBasicBlock& Head) {
  LLVM_DEBUG(dbgs() << "Nullification::TryMergeBlocks\n");
  LLVM_DEBUG(dbgs() << "\tHead: " << printMBBReference(Head) << '\n');
  // 2 successors for triangle or diamond
  if (Head.succ_size() != 2)
    return false;

  MachineBasicBlock *Succ0 = Head.succ_begin()[0];
  MachineBasicBlock *Succ1 = Head.succ_begin()[1];
  // Canonicalize so Succ0 has Head as its single predecessor.
  if (Succ0->pred_size() != 1) {
    LLVM_DEBUG(dbgs() << "\tswapped arms\n");
    std::swap(Succ0, Succ1);
  }
  LLVM_DEBUG(dbgs() << "\tSucc0: " << printMBBReference(*Succ0)
                    << " #P=" << Succ0->pred_size()
                    << " #S=" << Succ0->succ_size() << '\n'
                    << "\tSucc1: " << printMBBReference(*Succ1)
                    << " #P=" << Succ1->pred_size()
                    << " #S=" << Succ1->succ_size() << '\n');

  if (Succ0->pred_size() != 1)
    return false;

  if (Succ0->succ_size() != 1) // Can't be simple triangle or diamond
    return false;

  MachineBasicBlock *Tail = Succ0->succ_begin()[0];
  LLVM_DEBUG(dbgs() << "\tTail:  " << printMBBReference(*Tail) << '\n');
  if (Tail == Succ1) {
    LLVM_DEBUG(dbgs() << "\tTriangle\n");
  } else {
    // Check for a diamond. We won't deal with any critical edges.
    if (Succ1->pred_size() == 1 &&
        Succ1->succ_size() == 1 &&
        Succ1->succ_begin()[0] == Tail) {
      LLVM_DEBUG(dbgs() << "\tDiamond\n");
    } else {
      return false;
    }
  }

  // We have a simple triangle or diamond
  bool const Modified = Convert(MF, &Head, Succ0, Succ1, Tail);
  if (Modified) NumNullifications += 1;

  return Modified;
}

bool PostriscNullification::onePass(MachineFunction &MF) {
  // If merged, start again.
  for (auto &MBB : MF) {
    if (TryMergeBlocks(MF, MBB))
      return true;
  }
  return false;
}

bool PostriscNullification::runOnMachineFunction(MachineFunction &MF) {
  TII = MF.getSubtarget<PostriscSubtarget>().getInstrInfo();
  LLVM_DEBUG(dbgs() << "PostriscNullification::runOnMachineFunction\n");
  LLVM_DEBUG(dbgs() << "*** Original basic blocks ***\n"; for (auto &MBB : MF) dbgs() << MBB;);
  bool Modified = false;

  if (EnableMoveMerging)
    Modified |= MergeMoves(MF);

  if (EnableNullify) {
    while (onePass(MF)) {
      Modified = true;
      LLVM_DEBUG(dbgs() << "*** Modified basic blocks ***\n"; for (auto &MBB : MF) dbgs() << MBB;);
    }
  }
  if (Modified)
    MF.getRegInfo().invalidateLiveness();
  return Modified;
}

/// createPostriscNullificationPass - Returns an instance of the PostriscNullification
FunctionPass *llvm::createPostriscNullificationPass() {
  return new PostriscNullification();
}
