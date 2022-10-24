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

  AS_IS_NO_EXT(BR_EQ_I32,   NUL_EQ_I32)
  AS_IS_NO_EXT(BR_EQ_I64,   NUL_EQ_I64)
  AS_IS_NO_EXT(BR_EQ_I128,  NUL_EQ_I128)
  AS_IS_NO_EXT(BR_NE_I32,   NUL_NE_I32)
  AS_IS_NO_EXT(BR_NE_I64,   NUL_NE_I64)
  AS_IS_NO_EXT(BR_NE_I128,  NUL_NE_I128)
  AS_IS_NO_EXT(BR_LT_I32,   NUL_LT_I32)
  AS_IS_NO_EXT(BR_LT_I64,   NUL_LT_I64)
  AS_IS_NO_EXT(BR_LT_I128,  NUL_LT_I128)
  AS_IS_NO_EXT(BR_GE_I32,   NUL_GE_I32)
  AS_IS_NO_EXT(BR_GE_I64,   NUL_GE_I64)
  AS_IS_NO_EXT(BR_GE_I128,  NUL_GE_I128)
  AS_IS_NO_EXT(BR_LT_U32,   NUL_LT_U32)
  AS_IS_NO_EXT(BR_LT_U64,   NUL_LT_U64)
  AS_IS_NO_EXT(BR_LT_U128,  NUL_LT_U128)
  AS_IS_NO_EXT(BR_GE_U32,   NUL_GE_U32)
  AS_IS_NO_EXT(BR_GE_U64,   NUL_GE_U64)
  AS_IS_NO_EXT(BR_GE_U128,  NUL_GE_U128)
  AS_IS_NO_EXT(BR_BS,       NUL_BS)
  AS_IS_NO_EXT(BR_BC,       NUL_BC)
  AS_IS_NO_EXT(BR_BS_IMM,   NUL_BS_IMM)
  AS_IS_NO_EXT(BR_BC_IMM,   NUL_BC_IMM)
  AS_IS_NO_EXT(BR_OEQ_F32,  NUL_OEQ_F32)
  AS_IS_NO_EXT(BR_ONE_F32,  NUL_ONE_F32)
  AS_IS_NO_EXT(BR_OLT_F32,  NUL_OLT_F32)
  AS_IS_NO_EXT(BR_OGE_F32,  NUL_OGE_F32)
  AS_IS_NO_EXT(BR_O_F32,    NUL_O_F32)
  AS_IS_NO_EXT(BR_UEQ_F32,  NUL_UEQ_F32)
  AS_IS_NO_EXT(BR_UNE_F32,  NUL_UNE_F32)
  AS_IS_NO_EXT(BR_ULT_F32,  NUL_ULT_F32)
  AS_IS_NO_EXT(BR_UGE_F32,  NUL_UGE_F32)
  AS_IS_NO_EXT(BR_U_F32,    NUL_U_F32)
  AS_IS_NO_EXT(BR_OEQ_F64,  NUL_OEQ_F64)
  AS_IS_NO_EXT(BR_ONE_F64,  NUL_ONE_F64)
  AS_IS_NO_EXT(BR_OLT_F64,  NUL_OLT_F64)
  AS_IS_NO_EXT(BR_OGE_F64,  NUL_OGE_F64)
  AS_IS_NO_EXT(BR_O_F64,    NUL_O_F64)
  AS_IS_NO_EXT(BR_UEQ_F64,  NUL_UEQ_F64)
  AS_IS_NO_EXT(BR_UNE_F64,  NUL_UNE_F64)
  AS_IS_NO_EXT(BR_ULT_F64,  NUL_ULT_F64)
  AS_IS_NO_EXT(BR_UGE_F64,  NUL_UGE_F64)
  AS_IS_NO_EXT(BR_U_F64,    NUL_U_F64)
  AS_IS_NO_EXT(BR_OEQ_F128, NUL_OEQ_F128)
  AS_IS_NO_EXT(BR_ONE_F128, NUL_ONE_F128)
  AS_IS_NO_EXT(BR_OLT_F128, NUL_OLT_F128)
  AS_IS_NO_EXT(BR_OGE_F128, NUL_OGE_F128)
  AS_IS_NO_EXT(BR_O_F128,   NUL_O_F128)
  AS_IS_NO_EXT(BR_UEQ_F128, NUL_UEQ_F128)
  AS_IS_NO_EXT(BR_UNE_F128, NUL_UNE_F128)
  AS_IS_NO_EXT(BR_ULT_F128, NUL_ULT_F128)
  AS_IS_NO_EXT(BR_UGE_F128, NUL_UGE_F128)
  AS_IS_NO_EXT(BR_U_F128,   NUL_U_F128)

// XX - short/long branch reg-imm branches convert to corresponding short/long nullifications
#define AS_IS_EXT(BCOND, NCOND)                                                                     \
  case POSTRISC::BCOND:        swap_args = false; swap_blocks = false; return POSTRISC::NCOND;      \
  case POSTRISC::BCOND##_EXT:  swap_args = false; swap_blocks = false; return POSTRISC::NCOND##_EXT;

  AS_IS_EXT(BR_MASK_ALL_I64,      NUL_MASK_ALL_I64)
  AS_IS_EXT(BR_MASK_NOTALL_I64,   NUL_MASK_NOTALL_I64)
  AS_IS_EXT(BR_MASK_NONE_I64,     NUL_MASK_NONE_I64)
  AS_IS_EXT(BR_MASK_ANY_I64,      NUL_MASK_ANY_I64)

  AS_IS_EXT(BR_MASK_ALL_I32,      NUL_MASK_ALL_I32)
  AS_IS_EXT(BR_MASK_NOTALL_I32,   NUL_MASK_NOTALL_I32)
  AS_IS_EXT(BR_MASK_NONE_I32,     NUL_MASK_NONE_I32)
  AS_IS_EXT(BR_MASK_ANY_I32,      NUL_MASK_ANY_I32)

  AS_IS_EXT(BR_MASK_ALL_I128,     NUL_MASK_ALL_I128)
  AS_IS_EXT(BR_MASK_NOTALL_I128,  NUL_MASK_NOTALL_I128)
  AS_IS_EXT(BR_MASK_NONE_I128,    NUL_MASK_NONE_I128)
  AS_IS_EXT(BR_MASK_ANY_I128,     NUL_MASK_ANY_I128)

  AS_IS_EXT(BR_EQ_IMM_I32,        NUL_EQ_IMM_I32)
  AS_IS_EXT(BR_EQ_IMM_I64,        NUL_EQ_IMM_I64)
  AS_IS_EXT(BR_EQ_IMM_I128,       NUL_EQ_IMM_I128)
  AS_IS_EXT(BR_NE_IMM_I32,        NUL_NE_IMM_I32)
  AS_IS_EXT(BR_NE_IMM_I64,        NUL_NE_IMM_I64)
  AS_IS_EXT(BR_NE_IMM_I128,       NUL_NE_IMM_I128)
  AS_IS_EXT(BR_LT_IMM_I32,        NUL_LT_IMM_I32)
  AS_IS_EXT(BR_LT_IMM_I64,        NUL_LT_IMM_I64)
  AS_IS_EXT(BR_LT_IMM_I128,       NUL_LT_IMM_I128)
  AS_IS_EXT(BR_LT_IMM_U32,        NUL_LT_IMM_U32)
  AS_IS_EXT(BR_LT_IMM_U64,        NUL_LT_IMM_U64)
  AS_IS_EXT(BR_LT_IMM_U128,       NUL_LT_IMM_U128)
  AS_IS_EXT(BR_GE_IMM_I32,        NUL_GE_IMM_I32)
  AS_IS_EXT(BR_GE_IMM_I64,        NUL_GE_IMM_I64)
  AS_IS_EXT(BR_GE_IMM_I128,       NUL_GE_IMM_I128)
  AS_IS_EXT(BR_GE_IMM_U32,        NUL_GE_IMM_U32)
  AS_IS_EXT(BR_GE_IMM_U64,        NUL_GE_IMM_U64)
  AS_IS_EXT(BR_GE_IMM_U128,       NUL_GE_IMM_U128)

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
    // special codegened NOP, trick to avoid nullification for MBB in tests
    case POSTRISC::NUL_NEVER:
    case POSTRISC::NUL_NEVER_EXT:
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
