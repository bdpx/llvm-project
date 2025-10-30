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
#include "PostriscTargetMachine.h"
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

static cl::opt<int>
MaxNullificationBlockSize("max-nullification-blocksize",
               cl::init(8),
               cl::desc("Maximum nullification block size"),
               cl::NotHidden);

static inline int maxArchNullificationBlockSize(void) {
  const int MaxArchNullificationBlockSize = 15;
  return std::min<int>(MaxArchNullificationBlockSize, MaxNullificationBlockSize);
}

STATISTIC(NumPREDs,        "Number of single predicated blocks inserted");


static unsigned getNullificationOpc(unsigned Opc, bool& swap_args, bool& swap_blocks) {
  switch (Opc) {
  // X - short/long reg-reg branches convert to short-only nullifications
#define AS_IS_NO_EXT(BCOND, NCOND)                                                              \
  case POSTRISC::BCOND:        swap_args = false; swap_blocks = false; return POSTRISC::NCOND;  \
  case POSTRISC::BCOND##_EXT:  swap_args = false; swap_blocks = false; return POSTRISC::NCOND;

  AS_IS_NO_EXT(B_EQ_D,    NUL_EQ_D)
  AS_IS_NO_EXT(B_EQ_W,    NUL_EQ_W)
  AS_IS_NO_EXT(B_NE_D,    NUL_NE_D)
  AS_IS_NO_EXT(B_NE_W,    NUL_NE_W)
  AS_IS_NO_EXT(BS_LT_D,   NULS_LT_D)
  AS_IS_NO_EXT(BS_LE_D,   NULS_LE_D)
  AS_IS_NO_EXT(BU_LT_D,   NULU_LT_D)
  AS_IS_NO_EXT(BU_LE_D,   NULU_LE_D)
  AS_IS_NO_EXT(BS_LT_W,   NULS_LT_W)
  AS_IS_NO_EXT(BS_LE_W,   NULS_LE_W)
  AS_IS_NO_EXT(BU_LT_W,   NULU_LT_W)
  AS_IS_NO_EXT(BU_LE_W,   NULU_LE_W)
  AS_IS_NO_EXT(BBS,       NULBS)
  AS_IS_NO_EXT(BBC,       NULBC)
  AS_IS_NO_EXT(BBSI,      NULBSI)
  AS_IS_NO_EXT(BBCI,      NULBCI)
  AS_IS_NO_EXT(BFO_EQ_SS, NULFO_EQ_SS)
  AS_IS_NO_EXT(BFO_NE_SS, NULFO_NE_SS)
  AS_IS_NO_EXT(BFO_LT_SS, NULFO_LT_SS)
  AS_IS_NO_EXT(BFO_LE_SS, NULFO_LE_SS)
  AS_IS_NO_EXT(BFO_SS,    NULFO_SS)
  AS_IS_NO_EXT(BFU_EQ_SS, NULFU_EQ_SS)
  AS_IS_NO_EXT(BFU_NE_SS, NULFU_NE_SS)
  AS_IS_NO_EXT(BFU_LT_SS, NULFU_LT_SS)
  AS_IS_NO_EXT(BFU_LE_SS, NULFU_LE_SS)
  AS_IS_NO_EXT(BFU_SS,    NULFU_SS)
  AS_IS_NO_EXT(BFO_EQ_SD, NULFO_EQ_SD)
  AS_IS_NO_EXT(BFO_NE_SD, NULFO_NE_SD)
  AS_IS_NO_EXT(BFO_LT_SD, NULFO_LT_SD)
  AS_IS_NO_EXT(BFO_LE_SD, NULFO_LE_SD)
  AS_IS_NO_EXT(BFO_SD,    NULFO_SD)
  AS_IS_NO_EXT(BFU_EQ_SD, NULFU_EQ_SD)
  AS_IS_NO_EXT(BFU_NE_SD, NULFU_NE_SD)
  AS_IS_NO_EXT(BFU_LT_SD, NULFU_LT_SD)
  AS_IS_NO_EXT(BFU_LE_SD, NULFU_LE_SD)
  AS_IS_NO_EXT(BFU_SD,    NULFU_SD)
  AS_IS_NO_EXT(BFO_EQ_SQ, NULFO_EQ_SQ)
  AS_IS_NO_EXT(BFO_NE_SQ, NULFO_NE_SQ)
  AS_IS_NO_EXT(BFO_LT_SQ, NULFO_LT_SQ)
  AS_IS_NO_EXT(BFO_LE_SQ, NULFO_LE_SQ)
  AS_IS_NO_EXT(BFO_SQ,    NULFO_SQ)
  AS_IS_NO_EXT(BFU_EQ_SQ, NULFU_EQ_SQ)
  AS_IS_NO_EXT(BFU_NE_SQ, NULFU_NE_SQ)
  AS_IS_NO_EXT(BFU_LT_SQ, NULFU_LT_SQ)
  AS_IS_NO_EXT(BFU_LE_SQ, NULFU_LE_SQ)
  AS_IS_NO_EXT(BFU_SQ,    NULFU_SQ)

// XX - short/long branch reg-imm branches convert to corresponding short/long nullifications
#define AS_IS_EXT(BCOND, NCOND)                                                                     \
  case POSTRISC::BCOND:        swap_args = false; swap_blocks = false; return POSTRISC::NCOND;      \
  case POSTRISC::BCOND##_EXT:  swap_args = false; swap_blocks = false; return POSTRISC::NCOND##_EXT;

  AS_IS_EXT(BM_ALL,     NULM_ALL)
  AS_IS_EXT(BM_NOTALL,  NULM_NOTALL)
  AS_IS_EXT(BM_NONE,    NULM_NONE)
  AS_IS_EXT(BM_ANY,     NULM_ANY)
  AS_IS_EXT(BI_EQ_D,    NULI_EQ_D)
  AS_IS_EXT(BI_NE_D,    NULI_NE_D)
  AS_IS_EXT(BSI_LT_D,   NULSI_LT_D)
  AS_IS_EXT(BUI_LT_D,   NULUI_LT_D)
  AS_IS_EXT(BI_EQ_W,    NULI_EQ_W)
  AS_IS_EXT(BI_NE_W,    NULI_NE_W)
  AS_IS_EXT(BSI_LT_W,   NULSI_LT_W)
  AS_IS_EXT(BUI_LT_W,   NULUI_LT_W)

// short/long branch reg-imm branches convert to corresponding short/long nullification, plus block inversion
#define INVERT_COND_AND_SWAP_BLOCKS(BCOND, NCOND)                                                   \
  case POSTRISC::BCOND:        swap_args = false; swap_blocks = true; return POSTRISC::NCOND;       \
  case POSTRISC::BCOND##_EXT:  swap_args = false; swap_blocks = true; return POSTRISC::NCOND##_EXT;

  INVERT_COND_AND_SWAP_BLOCKS(BSI_GE_D, NULSI_LT_D)
  INVERT_COND_AND_SWAP_BLOCKS(BUI_GE_D, NULUI_LT_D)
  INVERT_COND_AND_SWAP_BLOCKS(BSI_GE_W, NULSI_LT_W)
  INVERT_COND_AND_SWAP_BLOCKS(BUI_GE_W, NULUI_LT_W)

  default:
    LLVM_DEBUG(dbgs() << "The branch instruction without nullification analog! Opc=" << Opc << "\n");
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
    bool InsertPredInstructions(MachineBasicBlock *MBB);
    bool onePass(MachineFunction &MF);
    bool ExamineBranch(MachineBasicBlock *Head,
                MachineBasicBlock *&TBB, MachineBasicBlock *&FBB,
                SmallVector<MachineOperand, 4> &Cond);
    int checkBlock(MachineBasicBlock *MBB);
    bool Convert(MachineBasicBlock *Head,
                 MachineBasicBlock *Succ0, MachineBasicBlock *Succ1,
                 MachineBasicBlock *Tail);
  };
  char PostriscNullification::ID = 0;
} // end anonymous namespace

INITIALIZE_PASS(PostriscNullification, DEBUG_TYPE, PASS_NAME, false, false)

static void dumpFunc(MachineFunction &MF, const char *what) {
  LLVM_DEBUG(
  dbgs() << "\n" << what << "\n";
    for (auto &MBB : MF) {
      dbgs() << MBB;
  });
}

static void dumpMBB(MachineBasicBlock *MBB, const char *what) {
  LLVM_DEBUG(
    dbgs() << "\n" << what << ": " << MBB->getParent()->getName() << "\n";
    MBB->dump();
    dbgs() << "\n";
  );
}

// Returns true if branch can be changed to a predicate
bool PostriscNullification::ExamineBranch(MachineBasicBlock *Head,
                MachineBasicBlock *&TBB, MachineBasicBlock *&FBB,
                SmallVector<MachineOperand, 4> &Cond) {

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
      LLVM_DEBUG(dbgs() << "cond/uncond branch pair, uncond branch to fallthru\n");
      MachineBasicBlock::iterator I = Head->getLastNonDebugInstr();
      I->eraseFromParent(); // Remove the branch.
    }
  } else {
    FBB = Head->getFallThrough();
  }
  // LLVM_DEBUG(dbgs() << "Branch analyzed\n");
  return true;
}

// Count how many valid instructions can be predicated.
// If theres a call that is not at the end, return 0.
// Any branch should be at the end.
int PostriscNullification::checkBlock(MachineBasicBlock *MBB) {
  int NumInstrs = 0;

  for (const MachineInstr &MI : instrs(*MBB)) {
    unsigned const Opc = MI.getOpcode();
    // currently we can't properly count possible NOPs before long instruction
    if (TII->isLong(Opc)) {
      return -1;
    }
    switch (Opc) {
    case TargetOpcode::CFI_INSTRUCTION:
    case TargetOpcode::MEMBARRIER:
    case TargetOpcode::EH_LABEL:
    case TargetOpcode::IMPLICIT_DEF:
    // FIXME - why are CFI_INSTRUCTIONs in the code?
    // answer: because of tail merged RETs
      return -1;  // continue;
    default:
      break;
    }
    if (MI.isTerminator()) {
       //if (&MI == MBB->getFirstTerminator()) {
         return NumInstrs;
       //}
    }
    // calls are not nullificable
    //if (MI.isCall() || MI.isBranch() || MI.isTerminator())
    //  return -1;
    ++NumInstrs;
    if (NumInstrs > maxArchNullificationBlockSize())
      return -1;
  }
  return NumInstrs;
}

bool PostriscNullification::Convert(MachineBasicBlock *Head,
                        MachineBasicBlock *Succ0, MachineBasicBlock *Succ1,
                        MachineBasicBlock *Tail) {
  MachineBasicBlock *TBB, *FBB;
  SmallVector<MachineOperand, 4> Cond;
  // LLVM_DEBUG(dbgs() << "PostriscNullification::Convert\n");
  if (!ExamineBranch(Head, TBB, FBB, Cond))
    return false;
  // AnalyzeBranch doesn't set FBB on a fall-through branch.
  FBB = TBB == Succ0 ? Succ1 : Succ0;

  // See how many instructions we can shadow
  int ninstrsT, ninstrsF;
  if (TBB == Tail)
    ninstrsT = 0;
  else
    ninstrsT = checkBlock(TBB);
  if (FBB == Tail)
    ninstrsF = 0;
  else
    ninstrsF = checkBlock(FBB);

  LLVM_DEBUG(dbgs() << "Tail" << printMBBReference(*Tail)
                    << " TBB(" << ninstrsT << ") " << printMBBReference(*TBB)
                    << " FBB(" << ninstrsF << ") " << printMBBReference(*FBB) << '\n');

  if (ninstrsT < 0 || ninstrsF < 0 ||   // unpredicatable instructions
     (ninstrsT == 0 && ninstrsF == 0) ||
      ninstrsT > maxArchNullificationBlockSize() || ninstrsF > maxArchNullificationBlockSize()) {
    LLVM_DEBUG(dbgs() << "Cannot convert: T=" << ninstrsT << " F=" << ninstrsF << "\n");
    return false;
  }

  MachineBasicBlock::iterator IP = Head->getFirstTerminator();
  DebugLoc dl = IP->getDebugLoc();

  assert(Cond[0].isImm());
  const int brop = Cond[0].getImm();
  // LLVM_DEBUG(dbgs() << "Opc=" << brop << "\n");
  bool swap_args = false;
  bool swap_blocks = false;
  const int nulOp = getNullificationOpc(brop, swap_args, swap_blocks);
  if (nulOp < 0)
    return false;

    LLVM_DEBUG(
      // dbgs() << "\n\nPostriscNullification::runOnMachineFunction=" << Head->getParent()->getName() << "\n";
      // dumpFunc(*Head->getParent(), "*** Original basic blocks ***");
    );

  if (swap_args) {
    // opc ra, rb, bb <=> opcOpp rb, ra, bb
    assert(Cond[1].isReg() && "invalid cond MachineOperand r1");
    assert(Cond[2].isReg() && "invalid cond MachineOperand r2");
    LLVM_DEBUG(dbgs() << "reverseBranchCondition SWAP regs: " << Cond[1] << " " << Cond[2] << "\n");
    std::swap(Cond[1], Cond[2]);
  }

  LLVM_DEBUG(dumpMBB(Head, "Head"));

  // Create the predicate instruction
  MachineInstrBuilder MIB = BuildMI(*Head, IP, dl, TII->get(nulOp));
  for (unsigned i = 1; i < Cond.size(); ++i) {
    assert((Cond[i].isImm() || Cond[i].isReg()) && "Cannot copy operand for conditional nullification!");
    MIB.add(Cond[i]);
    // LLVM_DEBUG(dbgs() << "after MIB.Add\n");
  }

  if (swap_blocks) {
    MIB.addImm(ninstrsT);
    MIB.addImm(ninstrsF);
  } else {
    MIB.addImm(ninstrsF);
    MIB.addImm(ninstrsT);
  }

  // Move all instructions into Head, except for the terminators.
  if (swap_blocks) {
    if (TBB != Tail) {
      LLVM_DEBUG(dumpMBB(TBB, "TBB (merged 1st)"));
      Head->splice(IP, TBB, TBB->begin(), TBB->getFirstTerminator());
    }
    if (FBB != Tail) {
      LLVM_DEBUG(dumpMBB(FBB, "FBB (merged 2nd)"));
      Head->splice(IP, FBB, FBB->begin(), FBB->getFirstTerminator());
    }
  } else {
    if (FBB != Tail) {
      LLVM_DEBUG(dumpMBB(FBB, "FBB (merged 1st)"));
      Head->splice(IP, FBB, FBB->begin(), FBB->getFirstTerminator());
    }
    if (TBB != Tail) {
      LLVM_DEBUG(dumpMBB(TBB, "TBB (merged 2nd)"));
      Head->splice(IP, TBB, TBB->begin(), TBB->getFirstTerminator());
    }
  }

  // LLVM_DEBUG(dumpMBB(Head, "Head (merged)"));

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
  // LLVM_DEBUG(dumpMBB(Head, "remove branch from Head"));
  TII->removeBranch(*Head);
  // LLVM_DEBUG(dumpMBB(Head, "Head (removed branch)"));

  if (Head->getFirstTerminator() != nullptr && Head->getFirstTerminator() != Head->end()) {
    LLVM_DEBUG(dumpMBB(Head, "Head: perhaps 2 branches were in head?"));
  }

  // Erase the now empty conditional blocks. It is likely that Head can fall
  // through to Tail, and we can join the two blocks.
  if (TBB != Tail) {
    TBB->eraseFromParent();
  }
  if (FBB != Tail) {
    FBB->eraseFromParent();
  }

  LLVM_DEBUG(dumpMBB(Tail, "Tail"));

  assert(Head->succ_empty() && "Additional head successors?");
  if (!ExtraPreds && Head->isLayoutSuccessor(Tail)) {
    // Splice Tail onto the end of Head.
    LLVM_DEBUG(dbgs() << "joining tail " << printMBBReference(*Tail)
                      << " into head " << printMBBReference(*Head) << '\n');
    Head->splice(Head->end(), Tail, Tail->begin(), Tail->end());
    Head->transferSuccessors(Tail);
    Tail->eraseFromParent();

    LLVM_DEBUG(dumpMBB(Head, "Head (tail merged)"));
  } else {
    // We need a branch to Tail, let code placement work it out later.
    // LLVM_DEBUG(dbgs() << "converting to unconditional branch\n");
    SmallVector<MachineOperand, 0> EmptyCond;
    TII->insertBranch(*Head, Tail, nullptr, EmptyCond, HeadDL);
    Head->addSuccessor(Tail);
    LLVM_DEBUG(dumpMBB(Head, "Head (branch to tail inserted)"));
  }
//  MakeBundle(Head, MIB, ninstrsT+ninstrsF);
  return true;
}

bool PostriscNullification::InsertPredInstructions(MachineBasicBlock *Head) {
  LLVM_DEBUG(dbgs() << "PostriscNullification::InsertPredInstructions "
                    << printMBBReference(*Head) << '\n');
  bool Modified = false;
  // 2 successors for triangle or diamond
  if (Head->succ_size() != 2)
    return false;
  MachineBasicBlock *Tail = nullptr;
  MachineBasicBlock *Succ0 = Head->succ_begin()[0];
  MachineBasicBlock *Succ1 = Head->succ_begin()[1];

  // Canonicalize so Succ0 has Head as its single predecessor.
  if (Succ0->pred_size() != 1) {
    //LLVM_DEBUG(dbgs() << "swapped arms\n");
    std::swap(Succ0, Succ1);
  }
  //LLVM_DEBUG(dbgs() << "Succ0: " << printMBBReference(*Succ0) <<
  //   " #P=" << Succ0->pred_size() << " #S=" << Succ0->succ_size() << '\n');
  //LLVM_DEBUG(dbgs() << "Succ1: " << printMBBReference(*Succ1) <<
  //   " #P=" << Succ1->pred_size() << " #S=" << Succ1->succ_size() << '\n');
  if (Succ0->pred_size() != 1)
    return false;

  if (Succ0->succ_size() == 1) { // Could be simple triangle or diamond
    Tail = Succ0->succ_begin()[0];
    //LLVM_DEBUG(dbgs() << "Tail:  " << printMBBReference(*Tail) << '\n');
    if (Tail == Succ1) {
      LLVM_DEBUG(dbgs() << "Triangle\n");
    } else {
      // Check for a diamond. We won't deal with any critical edges.
      if (Succ1->pred_size() == 1 && Succ1->succ_size() == 1 &&
          Succ1->succ_begin()[0] == Tail) {
          LLVM_DEBUG(dbgs() << "Diamond\n");
      } else {
        return false;
      }
    }
    // We have a simple triangle or diamond
    Modified = Convert(Head, Succ0, Succ1, Tail);
    if (Modified) NumPREDs += 1;
  }
  return Modified;
}


bool PostriscNullification::onePass(MachineFunction &MF) {
  // If we did any inserts, blocks may have been deleted so
  // we must start at the beginning again.
  for (auto &MBB : MF) {
    if (InsertPredInstructions(&MBB))
      return true;
  }
  return false;
}

bool PostriscNullification::runOnMachineFunction(MachineFunction &MF) {
  if (!EnableNullify) {
     return false;
  }
  TII = MF.getSubtarget<PostriscSubtarget>().getInstrInfo();

  bool Modified = false;
  while (onePass(MF)) {
    Modified = true;
    // LLVM_DEBUG(dumpFunc(MF, "*** Modified basic blocks ***"));
  }
  if (Modified) {
    // LLVM_DEBUG(dumpFunc(MF, "*** Final modified basic blocks ***"));
    MF.getRegInfo().invalidateLiveness();
  }
  return Modified;
}

/// createPostriscNullification - Returns an instance of the PostriscNullification
/// insertion pass.
FunctionPass *llvm::createPostriscNullificationPass() { return new PostriscNullification(); }
