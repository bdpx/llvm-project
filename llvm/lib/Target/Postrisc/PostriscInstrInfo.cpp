//===-- PostriscInstrInfo.cpp - Postrisc Instruction Information ----------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains the Postrisc implementation of the TargetInstrInfo class.
//
//===----------------------------------------------------------------------===//

#include "PostriscInstrInfo.h"
#include "Postrisc.h"
#include "PostriscMachineFunctionInfo.h"
#include "PostriscSubtarget.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineMemOperand.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/Debug.h"

#define DEBUG_TYPE "postrisc-instinfo"

using namespace llvm;

#define GET_INSTRINFO_CTOR_DTOR
#include "PostriscGenInstrInfo.inc"

// Pin the vtable to this file.
void PostriscInstrInfo::anchor() {}

PostriscInstrInfo::PostriscInstrInfo(PostriscSubtarget &ST)
    : PostriscGenInstrInfo(POSTRISC::ADJCALLSTACKDOWN, POSTRISC::ADJCALLSTACKUP), RI(),
      Subtarget(ST) {}

bool PostriscInstrInfo::isLong(unsigned Opc) const
{
  return postrisc::isLong(get(Opc).TSFlags);
}

bool PostriscInstrInfo::isPostIncrement(const MachineInstr &MI) const {
  return postrisc::isPostIncrement(MI.getDesc().TSFlags);
}

bool PostriscInstrInfo::isPreIncrement(const MachineInstr &MI) const {
  return postrisc::isPreIncrement(MI.getDesc().TSFlags);
}

// Return true if the instruction contains a base register and offset.
// If true, sets the operand position in the instruction for the base register and offset.
bool PostriscInstrInfo::getBaseAndOffsetPosition(const MachineInstr &MI,
                        unsigned &BasePos, unsigned &OffsetPos) const {
  if (!MI.mayLoad() && !MI.mayStore())
    return false;

  BasePos = 1;
  OffsetPos = 2;

  if (isPostIncrement(MI) || isPreIncrement(MI)) {
    BasePos++;
    OffsetPos++;
  }

  if (!MI.getOperand(BasePos).isReg())
    return false;
  if (!MI.getOperand(OffsetPos).isImm())
    return false;

  return true;
}

/// isLoadFromStackSlot - If the specified machine instruction is a direct
/// load from a stack slot, return the virtual or physical register number of
/// the destination along with the FrameIndex of the loaded stack slot.  If
/// not, return 0.  This predicate must return 0 if the instruction has
/// any side effects other than loading from the stack slot.
Register PostriscInstrInfo::isLoadFromStackSlot(const MachineInstr &MI,
                                             int &FrameIndex) const {
  if (MI.getOpcode() == POSTRISC::LDWZri ||
      MI.getOpcode() == POSTRISC::LDWSri ||
      MI.getOpcode() == POSTRISC::LDDZri ||
      MI.getOpcode() == POSTRISC::LDDSri ||
      MI.getOpcode() == POSTRISC::LDQri) {
    if (MI.getOperand(1).isFI() &&
        MI.getOperand(2).isImm() &&
        MI.getOperand(2).getImm() == 0) {
      FrameIndex = MI.getOperand(1).getIndex();
      return MI.getOperand(0).getReg();
    }
  }
  return 0;
}

/// isStoreToStackSlot - If the specified machine instruction is a direct
/// store to a stack slot, return the virtual or physical register number of
/// the source reg along with the FrameIndex of the loaded stack slot.  If
/// not, return 0.  This predicate must return 0 if the instruction has
/// any side effects other than storing to the stack slot.
Register PostriscInstrInfo::isStoreToStackSlot(const MachineInstr &MI,
                                            int &FrameIndex) const {
  if (MI.getOpcode() == POSTRISC::STWri ||
      MI.getOpcode() == POSTRISC::STDri ||
      MI.getOpcode() == POSTRISC::STQri) {
    if (MI.getOperand(1).isFI() &&
        MI.getOperand(2).isImm() &&
        MI.getOperand(2).getImm() == 0) {
      FrameIndex = MI.getOperand(1).getIndex();
      return MI.getOperand(0).getReg();
    }
  }
  return 0;
}

bool PostriscInstrInfo::isUncondBranchOpcode(unsigned Opc) const {
  return Opc == POSTRISC::JMP ||
         Opc == POSTRISC::JMP_ext;
}

bool PostriscInstrInfo::isIndirectBranchOpcode(unsigned Opc) const {
  return Opc == POSTRISC::JMPR;
}

// conditional branches, paired with inverted branch
#define DECLARE_INVERTED_WITHOUT_ARG_SWAP_COND_BRANCHES(X) \
  X(insn_bdeq,    insn_bdne) \
  X(insn_bdeqi,   insn_bdnei) \
  X(insn_bdlti,   insn_bdgei) \
  X(insn_bdltui,  insn_bdgeui) \
  X(insn_bweq,    insn_bwne) \
  X(insn_bweqi,   insn_bwnei) \
  X(insn_bwlti,   insn_bwgei) \
  X(insn_bwltui,  insn_bwgeui) \
  X(insn_bbs,     insn_bbc) \
  X(insn_bbsi,    insn_bbci) \
  X(insn_bmall,   insn_bmnotall) \
  X(insn_bmnone,  insn_bmany) \
  X(insn_bfssoeq, insn_bfssune) \
  X(insn_bfssone, insn_bfssueq) \
  X(insn_bfsso,   insn_bfssuo) \
  X(insn_bfsdoeq, insn_bfsdune) \
  X(insn_bfsdone, insn_bfsdueq) \
  X(insn_bfsdo,   insn_bfsduo) \
  X(insn_bfsqoeq, insn_bfsqune) \
  X(insn_bfsqone, insn_bfsqueq) \
  X(insn_bfsqo,   insn_bfsquo) \

#define DECLARE_INVERTED_WITH_ARG_SWAP_COND_BRANCHES(X) \
  X(insn_bdlt,    insn_bdle)    /* lt  invert=> ge  swap=> le  */ \
  X(insn_bdltu,   insn_bdleu)   /* lt  invert=> ge  swap=> le  */ \
  X(insn_bwlt,    insn_bwle)    /* lt  invert=> ge  swap=> le  */ \
  X(insn_bwltu,   insn_bwleu)   /* lt  invert=> ge  swap=> le  */ \
  X(insn_bfssolt, insn_bfssule) /* olt invert=> uge swap=> ule */ \
  X(insn_bfssole, insn_bfssult) /* ole invert=> ugt swap=> ult */ \
  X(insn_bfsdolt, insn_bfsdule) /* olt invert=> uge swap=> ule */ \
  X(insn_bfsdole, insn_bfsdult) /* ole invert=> ugt swap=> ult */ \
  X(insn_bfsqolt, insn_bfsqule) /* olt invert=> uge swap=> ule */ \
  X(insn_bfsqole, insn_bfsqult) /* ole invert=> ugt swap=> ult */ \

#define DECLARE_COND_BRANCHES(X) \
  DECLARE_INVERTED_WITH_ARG_SWAP_COND_BRANCHES(X)    \
  DECLARE_INVERTED_WITHOUT_ARG_SWAP_COND_BRANCHES(X)

static bool isArgSwappedOppositeCondBranch(unsigned Opc) {
  switch (Opc) {
#define X(OPC, OPCOP)          \
  case POSTRISC::OPC:          \
  case POSTRISC::OPC##_ext:    \
  case POSTRISC::OPCOP:        \
  case POSTRISC::OPCOP##_ext:

  DECLARE_INVERTED_WITH_ARG_SWAP_COND_BRANCHES(X)
#undef X
    return true;
  default:
    return false;
  }
}

static unsigned getOppositeBranchOpc(unsigned Opc) {
  switch (Opc) {
#define X(OPC, OPCOP)                                         \
  case POSTRISC::OPC:         return POSTRISC::OPCOP;         \
  case POSTRISC::OPC##_ext:   return POSTRISC::OPCOP##_ext;   \
  case POSTRISC::OPCOP:       return POSTRISC::OPC;           \
  case POSTRISC::OPCOP##_ext: return POSTRISC::OPC##_ext;     \

  DECLARE_COND_BRANCHES(X)
#undef X
  }
  LLVM_DEBUG(dbgs() << "getOppositeBranchOpc: unrecognized " << Opc << "\n");
  llvm_unreachable("getOppositeBranchOpc: Invalid cond code");
}

bool PostriscInstrInfo::isCondBranchOpcode(unsigned Opc) const {
  switch (Opc) {
#define X(OPC, OPCOP)            \
    case POSTRISC::OPC:          \
    case POSTRISC::OPC##_ext:    \
    case POSTRISC::OPCOP:        \
    case POSTRISC::OPCOP##_ext:  \

  DECLARE_COND_BRANCHES(X)
#undef X
    return true;
  }
  return false;
}

MachineBasicBlock *PostriscInstrInfo::getBranchTargetMBB(const MachineInstr *Inst) const {
  assert(Inst);
  assert(Inst->getNumExplicitOperands() > 0);
  unsigned const n = Inst->getNumExplicitOperands() - 1;
  assert(Inst->getOperand(n).isMBB());
  return Inst->getOperand(n).getMBB();
}

void PostriscInstrInfo::parseCondBranch(MachineInstr *LastInst, MachineBasicBlock *&Target,
                                        SmallVectorImpl<MachineOperand> &Cond) const {
  unsigned Opc = LastInst->getOpcode();

  // Block ends with fall-through condbranch.
  assert(LastInst->getDesc().isConditionalBranch()
         && "Unknown conditional branch");
  int const NumOp = LastInst->getNumExplicitOperands();

  // Push the branch opcode into Cond too so later in insertBranch
  // it can use the information to emit the correct POSTRISC branch opcode.
  Cond.push_back(MachineOperand::CreateImm(Opc));
  for (int i = 0; i < NumOp - 1; i++) {
    Cond.push_back(LastInst->getOperand(i));
  }

  Target = getBranchTargetMBB(LastInst);
  LLVM_DEBUG(dbgs() << "parseCondBranch:"
                    << " Target=" << printMBBReference(*Target)
                    << " Inst=" << *LastInst);
}

MachineBasicBlock *
PostriscInstrInfo::getBranchDestBlock(const MachineInstr &MI) const {

  switch (MI.getOpcode()) {
  default:
    LLVM_DEBUG(dbgs() << "getBranchDestBlock unreachable opcode: " << MI << "\n");
    llvm_unreachable("unexpected opcode!");
  case POSTRISC::JMP:
  case POSTRISC::JMP_ext:
    // opc mbb
    assert(MI.getOperand(0).isMBB());
    return MI.getOperand(0).getMBB();

#define X(OPC, OPCOP)            \
    case POSTRISC::OPC:          \
    case POSTRISC::OPC##_ext:    \
    case POSTRISC::OPCOP:        \
    case POSTRISC::OPCOP##_ext:  \

  DECLARE_COND_BRANCHES(X)
#undef X
    // opc reg, reg, mbb
    // opc reg, imm, mbb
    return getBranchTargetMBB(&MI);
  }
}

// returns fallthrough or last jump target block
MachineBasicBlock *PostriscInstrInfo::getLastSuccessor(MachineBasicBlock& MBB) const
{
  MachineBasicBlock *FBB = MBB.getFallThrough();
  if (FBB) return FBB;

  // If the block has no terminators,
  // it just falls into the block after it.
  MachineBasicBlock::iterator I = MBB.getLastNonDebugInstr();
  if (I == MBB.end())
    return nullptr;
  MachineInstr& LastInst = *I;
  if (!isUnpredicatedTerminator(LastInst))
    return nullptr;
  // If the last instruction in the block is jump, get its target.
  if (isUncondBranchOpcode(LastInst.getOpcode())) {
    return getBranchTargetMBB(&LastInst);
  }
  return nullptr;
}

/*
Analyze the branching code at the end of MBB, returning true if it cannot be understood (e.g.
it's a switch dispatch or isn't implemented for a target).
Upon success, this returns false and returns with the following information in various cases:
  1) If this block ends with no branches (it just falls through to its succ)
     just return false, leaving TBB/FBB null.
  2) If this block ends with only an unconditional branch, it sets TBB to be the destination block.
  3) If this block ends with a conditional branch and it falls through to a successor block,
     it sets TBB to be the branch destination block and a list of operands that evaluate the condition.
     These operands can be passed to other TargetInstrInfo methods to create new branches.
  4) If this block ends with a conditional branch followed by an unconditional branch,
     it returns the 'true' destination in TBB, the 'false' destination in FBB,
     and a list of operands that evaluate the condition.
     These operands can be passed to other TargetInstrInfo methods to create new branches.

Note that removeBranch and insertBranch must be implemented
to support cases where this method returns success.
If AllowModify is true, then this routine is allowed to modify the basic block
(e.g. delete instructions after the unconditional branch).
The CFG information in MBB.Predecessors and MBB.
Successors must be valid before calling this function.
*/
bool PostriscInstrInfo::analyzeBranch(MachineBasicBlock &MBB,
                                   MachineBasicBlock *&TBB,
                                   MachineBasicBlock *&FBB,
                                   SmallVectorImpl<MachineOperand> &Cond,
                                   bool AllowModify) const {
  // FIXME: issues with build branch
  // return true;

  // If the block has no terminators, it just falls into the block after it.
  MachineBasicBlock::iterator I = MBB.getLastNonDebugInstr();
  if (I == MBB.end())
    return false;

  if (!isUnpredicatedTerminator(*I))
    return false;

  // Get the last instruction in the block.
  MachineInstr *LastInst = &*I;

  // If there is only one terminator instruction, process it.
  unsigned LastOpc = LastInst->getOpcode();
  if (I == MBB.begin() || !isUnpredicatedTerminator(*--I)) {
    if (isUncondBranchOpcode(LastOpc)) {
      TBB = getBranchTargetMBB(LastInst);
      LLVM_DEBUG(dbgs() << "analyzeBranch: uncond, false"
                        << " TBB=" << printMBBReference(*TBB)
                        << " LastInst=" << *LastInst);
      return false;
    }
    if (isCondBranchOpcode(LastOpc)) {
      // Block ends with fall-through condbranch.
      parseCondBranch(LastInst, TBB, Cond);
      LLVM_DEBUG(dbgs() << "analyzeBranch: cond, false"
                        << " TBB=" << printMBBReference(*TBB)
                        << " LastInst=" << *LastInst);
      return false;
    }
    return true; // Can't handle indirect branch.
  }

  // Get the instruction before it if it is a terminator.
  MachineInstr *SecondLastInst = &*I;
  unsigned SecondLastOpc = SecondLastInst->getOpcode();

  // If AllowModify is true and the block ends with two or more unconditional
  // branches, delete all but the first unconditional branch.
  if (AllowModify && isUncondBranchOpcode(LastOpc)) {
    while (isUncondBranchOpcode(SecondLastOpc)) {
      LastInst->eraseFromParent();
      LastInst = SecondLastInst;
      LastOpc = LastInst->getOpcode();
      if (I == MBB.begin() || !isUnpredicatedTerminator(*--I)) {
        // Return now the only terminator is an unconditional branch.
        TBB = getBranchTargetMBB(LastInst);
        LLVM_DEBUG(dbgs() << "analyzeBranch: second, false"
                          << " TBB=" << printMBBReference(*TBB)
                          << " LastInst=" << *LastInst);
        return false;
      } else {
        SecondLastInst = &*I;
        SecondLastOpc = SecondLastInst->getOpcode();
      }
    }
  }

  // If we're allowed to modify and the block ends in a unconditional branch
  // which could simply fallthrough, remove the branch.  (Note: This case only
  // matters when we can't understand the whole sequence, otherwise it's also
  // handled by BranchFolding.cpp.)
  if (AllowModify && isUncondBranchOpcode(LastOpc) &&
      MBB.isLayoutSuccessor(getBranchDestBlock(*LastInst))) {
    LastInst->eraseFromParent();
    LastInst = SecondLastInst;
    LastOpc = LastInst->getOpcode();
    if (I == MBB.begin() || !isUnpredicatedTerminator(*--I)) {
      assert(!isUncondBranchOpcode(LastOpc) &&
             "unreachable unconditional branches removed above");

      if (isCondBranchOpcode(LastOpc)) {
        // Block ends with fall-through condbranch.
        parseCondBranch(LastInst, TBB, Cond);
        LLVM_DEBUG(dbgs() << "analyzeBranch: second/succ, false"
                          << " TBB=" << printMBBReference(*TBB)
                          << " LastInst=" << *LastInst);
        return false;
      }
      return true; // Can't handle indirect branch.
    } else {
      SecondLastInst = &*I;
      SecondLastOpc = SecondLastInst->getOpcode();
    }
  }

  // If there are three terminators, we don't know what sort of block this is.
  if (SecondLastInst && I != MBB.begin() && isUnpredicatedTerminator(*--I))
    return true;

  // If the block ends with a B and a Bcc, handle it.
  if (isCondBranchOpcode(SecondLastOpc) && isUncondBranchOpcode(LastOpc)) {
    parseCondBranch(SecondLastInst, TBB, Cond);
    FBB = getBranchTargetMBB(LastInst);
    LLVM_DEBUG(dbgs() << "analyzeBranch: cond+uncond FBB=" << printMBBReference(*FBB)
                      << " LastInst=" << *LastInst);
    return false;
  }

  // If the block ends with two unconditional branches, handle it.  The second
  // one is not executed, so remove it.
  if (isUncondBranchOpcode(SecondLastOpc) && isUncondBranchOpcode(LastOpc)) {
    TBB = getBranchTargetMBB(SecondLastInst);
    I = LastInst;
    LLVM_DEBUG(dbgs() << "analyzeBranch: uncond+uncond TBB=" << printMBBReference(*TBB)
                      << " I=" << *I);
    if (AllowModify) {
      LLVM_DEBUG(dbgs() << "analyzeBranch: erase\n");
      I->eraseFromParent();
    }
    return false;
  }

  // ...likewise if it ends with an indirect branch followed by an unconditional
  // branch.
  if (isIndirectBranchOpcode(SecondLastOpc) && isUncondBranchOpcode(LastOpc)) {
    I = LastInst;
    LLVM_DEBUG(dbgs() << "analyzeBranch: indir+uncond " << printMBBReference(MBB)
                      << " I=" << *I);
    if (AllowModify) {
      LLVM_DEBUG(dbgs() << "analyzeBranch: erase\n");
      I->eraseFromParent();
    }
    return true;
  }

  // Otherwise, can't handle this.
  return true;
}

// Analyze the branching code at the end of MBB and
// parse it into the MachineBranchPredicate structure if possible.
// Returns false on success and true on failure.
// If AllowModify is true, then this routine is allowed to modify the basic block
// (e.g. delete instructions after the unconditional branch).
bool PostriscInstrInfo::analyzeBranchPredicate(MachineBasicBlock &MBB,
                                              MachineBranchPredicate &MBP,
                                              bool AllowModify) const {
  // For the moment, handle only a block which ends with a cb(n)zx followed by
  // a fallthrough.  Why this?  Because it is a common form.
  // TODO: Should we handle b.cc?
  MachineBasicBlock::iterator I = MBB.getLastNonDebugInstr();
  if (I == MBB.end())
    return true;

  if (!isUnpredicatedTerminator(*I))
    return true;

  // Get the last instruction in the block.
  MachineInstr *LastInst = &*I;
  unsigned LastOpc = LastInst->getOpcode();
  if (!isCondBranchOpcode(LastOpc))
    return true;

  switch (LastOpc) {
  default:
    LLVM_DEBUG(dbgs() << "analyzeBranchPredicate: " << printMBBReference(MBB) << '\n');
    return true;
  };
  return false;
}

// OVERRIDE: Reverses the branch condition of the specified condition list,
// returning false on success and true if it cannot be reversed.
// FIXME: can't return true
// because otherwise produces sometning like:
// insn %r1, %r2, ".LBB92_-1"
bool PostriscInstrInfo::reverseBranchCondition(
    SmallVectorImpl<MachineOperand> &Cond) const {
  LLVM_DEBUG(dbgs() << "reverseBranchCondition: " << Cond.size() << "\n";
  for (auto const& c : Cond) {
    dbgs() << "  cond: " << c << "\n";
  });

  assert((Cond.size() >= 3) && "invalid cond size, should be: Opc, Reg, Reg/Imm");
  assert(Cond[0].isImm() && "invalid cond[0] MachineOperand - Opc");
  assert(Cond[1].isReg() && "invalid cond[1] MachineOperand - Reg");
  assert((Cond[2].isReg() || Cond[2].isImm()) && "invalid cond[2] MachineOperand - Reg/Imm");

  unsigned opcode = Cond[0].getImm();
  LLVM_DEBUG(dbgs() << "reverseBranchCondition opcode: "
         << opcode << " isLong=" << isLong(opcode) << "\n");

  opcode = getOppositeBranchOpc(opcode);
  LLVM_DEBUG(dbgs() << "reverseBranchCondition opposite opcode: "
                    << opcode << " isLong=" << isLong(opcode) << "\n");
  // opc ra, rb/imm, bb
  if (isArgSwappedOppositeCondBranch(opcode)) {
    // opc ra, rb, bb <=> opcOpp rb, ra, bb
    assert(Cond[1].isReg() && "invalid cond MachineOperand r1");
    assert(Cond[2].isReg() && "invalid cond MachineOperand r2");
    LLVM_DEBUG(dbgs() << "reverseBranchCondition SWAP regs: "
                      << Cond[1] << " " << Cond[2] << "\n");
    std::swap(Cond[1], Cond[2]);
  }
  Cond[0].setImm(opcode);

  LLVM_DEBUG(dbgs() << "reverseBranchCondition final: " << Cond.size() << "\n";
  for (auto const& c : Cond) {
    dbgs() << "  cond: " << c << "\n";
  });
  return false;
}

// OVERRIDE: Remove the branching code at the end of the specific MBB.
// This is only invoked in cases where analyzeBranch returns success.
// It returns the number of instructions that were removed.
// If BytesRemoved is non-null, report the change in code size from the removed instructions.
unsigned PostriscInstrInfo::removeBranch(MachineBasicBlock &MBB,
                                      int *BytesRemoved) const {
  assert(!BytesRemoved && "code size not handled");

  MachineBasicBlock::iterator I = MBB.getLastNonDebugInstr();
  if (I == MBB.end())
    return 0;

  if (!isUncondBranchOpcode(I->getOpcode()) &&
      !isCondBranchOpcode(I->getOpcode())) {
    LLVM_DEBUG(dbgs() << "removeBranch (0): MBB=" << printMBBReference(MBB) << '\n');
    return 0;
  }

  // Remove the branch.
  LLVM_DEBUG(dbgs() << "removeBranch (1): MBB.size=" << MBB.size() << " I=" << *I; MBB.dump());
  I->eraseFromParent();

  I = MBB.end();

  if (I == MBB.begin()) {
    if (BytesRemoved)
      *BytesRemoved = 4;
    LLVM_DEBUG(dbgs() << "removeBranch (1, empty): MBB=" << printMBBReference(MBB) << '\n');
    return 1;
  }
  --I;
  if (!isCondBranchOpcode(I->getOpcode())) {
    if (BytesRemoved)
      *BytesRemoved = 4;
    LLVM_DEBUG(dbgs() << "removeBranch (1): MBB=" << printMBBReference(MBB) << '\n');
    return 1;
  }

  // Remove the branch.
  LLVM_DEBUG(dbgs() << "removeBranch (2): MBB.size=" << MBB.size() << " I=" << *I; MBB.dump());
  I->eraseFromParent();
  if (BytesRemoved)
    *BytesRemoved = 8;

  LLVM_DEBUG(dbgs() << "removeBranch (2): MBB=" << printMBBReference(MBB) << '\n');
  return 2;
}

void PostriscInstrInfo::instantiateCondBranch(
    MachineBasicBlock &MBB, const DebugLoc &DL, MachineBasicBlock *TBB,
    ArrayRef<MachineOperand> Cond) const {
  // # of condition operands:
  //  Unconditional branches: 0
  //  Int BranchZero: 2 (opc, reg)
  //  Int Branch: 3 (opc, reg0, reg1/imm)
  //  FP branch: 3 (opc, reg0, reg1)
  assert((Cond.size() <= 3) &&
     "Postrisc branch conditions should have <= 3!");

  // Folded compare-and-branch
  LLVM_DEBUG(dbgs() << "instantiateCondBranch: Cond.size=" << Cond.size() << "\n");
  assert(Cond[0].isImm());
  unsigned const Opc = Cond[0].getImm();
  LLVM_DEBUG(dbgs() << "Opc=" << Opc << "\n");
  const MCInstrDesc &MCID = get(Opc);
  MachineInstrBuilder MIB = BuildMI(&MBB, DL, MCID);

  LLVM_DEBUG(dbgs() << "after BuildMI\n");
  for (unsigned i = 1; i < Cond.size(); ++i) {
    assert((Cond[i].isImm() || Cond[i].isReg())
           && "Cannot copy operand for conditional branch!");
    MIB.add(Cond[i]);
    LLVM_DEBUG(dbgs() << "after MIB.Add\n");
  }
  MIB.addMBB(TBB);
  LLVM_DEBUG(dbgs() << "instantiateCondBranch final:"
                    << " MBB=" << printMBBReference(MBB)
                    << " Inst=" << *MIB.getInstr());
}

// OVERRIDE: Insert branch code into the end of the specified MachineBasicBlock.
// The operands to this method are the same as those returned by analyzeBranch.
// This is only invoked in cases where analyzeBranch returns success.
// It returns the number of instructions inserted.
// If BytesAdded is non-null, report the change in code size from the added instructions.
// It is also invoked by tail merging to add unconditional branches in cases where
// analyzeBranch doesn't apply because there was no original branch to analyze.
// At least this much must be implemented, else tail merging needs to be disabled.
// The CFG information in MBB.Predecessors and MBB.
// Successors must be valid before calling this function.
unsigned PostriscInstrInfo::insertBranch(
                MachineBasicBlock &MBB, MachineBasicBlock *TBB, MachineBasicBlock *FBB,
                ArrayRef<MachineOperand> Cond, const DebugLoc &DL, int *BytesAdded) const {
  LLVM_DEBUG(
    dbgs() << "PII::insertBranch:";
    if (TBB)   dbgs() << " TBB=" << printMBBReference(*TBB);
    else       dbgs() << " TBB=NULL";
    if (FBB)   dbgs() << " FBB=" << printMBBReference(*FBB);
    else       dbgs() << " FBB=NULL";
    dbgs() << " MBB=" << printMBBReference(MBB) << '\n';
  );
  // Shouldn't be a fall through.
  assert(TBB && "insertBranch must not be told to insert a fallthrough");
  assert(!BytesAdded && "code size not handled");

  if (Cond.empty()) {
    // Unconditional branch?
    assert(!FBB && "Unconditional branch with multiple successors!");
    BuildMI(&MBB, DL, get(POSTRISC::JMP)).addMBB(TBB);
    LLVM_DEBUG(dbgs() << "insertBranch (only one):\n"; MBB.dump());
    return 1;
  }

  // Conditional branch.
  unsigned Count = 0;
  instantiateCondBranch(MBB, DL, TBB, Cond);
  LLVM_DEBUG(dbgs() << "insertBranch (cond):\n"; MBB.dump());
  ++Count;

  // If FBB is null, it is implied to be a fall-through block.
  if (FBB) {
    // Two-way Conditional branch. Insert the second branch.
    BuildMI(&MBB, DL, get(POSTRISC::JMP)).addMBB(FBB);
    LLVM_DEBUG(dbgs() << "insertBranch (second):\n"; MBB.dump());
    ++Count;
  }

  return Count;
}

bool PostriscInstrInfo::isBranchOffsetInRange(unsigned BranchOpc,
                                           int64_t Offset) const {
  assert((Offset & 0b1111) == 0 && "Malformed branch offset");

  switch (BranchOpc) {
  case POSTRISC::JMP:        return isIntN(28, Offset >> 4);
  case POSTRISC::JMP_ext:    return isIntN(64, Offset >> 4);

#define X(OPC, OPCOP)               \
  case POSTRISC::OPC:               \
  case POSTRISC::OPCOP:             \
    return isIntN(17, Offset >> 4); \
  case POSTRISC::OPC##_ext:         \
  case POSTRISC::OPCOP##_ext:       \
    return isIntN(30, Offset >> 4); \

  DECLARE_COND_BRANCHES(X)
#undef X
  }

  llvm_unreachable("Unknown branch instruction!");
}

void PostriscInstrInfo::copyPhysReg(MachineBasicBlock &MBB,
                                 MachineBasicBlock::iterator I,
                                 const DebugLoc &DL, MCRegister DestReg,
                                 MCRegister SrcReg, bool KillSrc) const {
  if (POSTRISC::GRRegClass.contains(DestReg, SrcReg)) {
    BuildMI(MBB, I, DL, get(POSTRISC::MOV), DestReg)
      .addReg(SrcReg, getKillRegState(KillSrc));
  } else
    llvm_unreachable("Impossible reg-to-reg copy");
}

void PostriscInstrInfo::storeRegToStackSlot(MachineBasicBlock &MBB,
                                         MachineBasicBlock::iterator I,
                                         Register SrcReg, bool isKill, int FI,
                                         const TargetRegisterClass *RC,
                                         const TargetRegisterInfo *TRI,
                                         Register VReg) const {
  DebugLoc DL;
  if (I != MBB.end()) DL = I->getDebugLoc();

  MachineFunction *MF = MBB.getParent();
  const MachineFrameInfo &MFI = MF->getFrameInfo();
  MachineMemOperand *MMO = MF->getMachineMemOperand(
      MachinePointerInfo::getFixedStack(*MF, FI), MachineMemOperand::MOStore,
      MFI.getObjectSize(FI), MFI.getObjectAlign(FI));

  // On the order of operands here: think "[FrameIdx + 0] = SrcReg".
  assert(RC == &POSTRISC::GRRegClass);
  BuildMI(MBB, I, DL, get(POSTRISC::STQri))
      .addReg(SrcReg, getKillRegState(isKill))
      .addFrameIndex(FI)
      .addImm(0)
      .addMemOperand(MMO);
}

void PostriscInstrInfo::loadRegFromStackSlot(MachineBasicBlock &MBB,
                                          MachineBasicBlock::iterator I,
                                          Register DestReg, int FI,
                                          const TargetRegisterClass *RC,
                                          const TargetRegisterInfo *TRI,
                                          Register VReg) const {
  DebugLoc DL;
  if (I != MBB.end()) DL = I->getDebugLoc();

  MachineFunction *MF = MBB.getParent();
  const MachineFrameInfo &MFI = MF->getFrameInfo();
  MachineMemOperand *MMO = MF->getMachineMemOperand(
      MachinePointerInfo::getFixedStack(*MF, FI), MachineMemOperand::MOLoad,
      MFI.getObjectSize(FI), MFI.getObjectAlign(FI));

  assert(RC == &POSTRISC::GRRegClass);
  BuildMI(MBB, I, DL, get(POSTRISC::LDQri))
      .addReg(DestReg, RegState::Define)
      .addFrameIndex(FI)
      .addImm(0)
      .addMemOperand(MMO);

}

bool PostriscInstrInfo::expandPostRAPseudo(MachineInstr &MI) const {
  switch (MI.getOpcode()) {
  case TargetOpcode::LOAD_STACK_GUARD: {
    assert(Subtarget.isTargetLinux() &&
           "Only Linux target is expected to contain LOAD_STACK_GUARD");
    // offsetof(tcbhead_t, stack_guard) from sysdeps/postrisc/nptl/tls.h in glibc.
    const int64_t Offset = Subtarget.is64Bit() ? 0x28 : 0x14;
    MI.setDesc(get(POSTRISC::LDDZri));
    MachineInstrBuilder(*MI.getParent()->getParent(), MI)
        .addReg(POSTRISC::tp)
        .addImm(Offset);
    return true;
  }
  }
  return false;
}
