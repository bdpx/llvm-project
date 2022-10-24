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
#include "llvm/ADT/SmallVector.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineMemOperand.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/Postrisc/PostriscBundle.h"

#define DEBUG_TYPE "postrisc-instinfo"

using namespace llvm;

#define GET_INSTRINFO_CTOR_DTOR
#include "PostriscGenInstrInfo.inc"

// Pin the vtable to this file.
void PostriscInstrInfo::anchor() {}

PostriscInstrInfo::PostriscInstrInfo(const PostriscSubtarget &ST)
    : PostriscGenInstrInfo(ST, RI, POSTRISC::ADJCALLSTACKDOWN, POSTRISC::ADJCALLSTACKUP),
      RI(ST), Subtarget(ST) {}

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
  if (MI.getOpcode() == POSTRISC::LD_U32 ||
      MI.getOpcode() == POSTRISC::LD_I32 ||
      MI.getOpcode() == POSTRISC::LD_U64 ||
      MI.getOpcode() == POSTRISC::LD_I64 ||
      MI.getOpcode() == POSTRISC::LD_I128) {
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
  if (MI.getOpcode() == POSTRISC::ST_I32 ||
      MI.getOpcode() == POSTRISC::ST_I64 ||
      MI.getOpcode() == POSTRISC::ST_I128) {
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
         Opc == POSTRISC::JMP_EXT;
}

bool PostriscInstrInfo::isIndirectBranchOpcode(unsigned Opc) const {
  return Opc == POSTRISC::JMP_R;
}

// conditional branches, paired with inverted branch
#define DECLARE_COND_BRANCHES(X) \
  X(BR_EQ_I32,         BR_NE_I32) \
  X(BR_EQ_I64,         BR_NE_I64) \
  X(BR_EQ_I128,        BR_NE_I128) \
  X(BR_EQ_IMM_I32,     BR_NE_IMM_I32) \
  X(BR_EQ_IMM_I64,     BR_NE_IMM_I64) \
  X(BR_EQ_IMM_I128,    BR_NE_IMM_I128) \
  X(BR_LT_IMM_I32,     BR_GE_IMM_I32) \
  X(BR_LT_IMM_I64,     BR_GE_IMM_I64) \
  X(BR_LT_IMM_I128,    BR_GE_IMM_I128) \
  X(BR_LT_IMM_U32,     BR_GE_IMM_U32) \
  X(BR_LT_IMM_U64,     BR_GE_IMM_U64) \
  X(BR_LT_IMM_U128,    BR_GE_IMM_U128) \
  X(BR_BS,             BR_BC) \
  X(BR_BS_IMM,         BR_BC_IMM) \
  X(BR_MASK_ALL_I64,   BR_MASK_NOTALL_I64) \
  X(BR_MASK_NONE_I64,  BR_MASK_ANY_I64) \
  X(BR_MASK_ALL_I32,   BR_MASK_NOTALL_I32) \
  X(BR_MASK_NONE_I32,  BR_MASK_ANY_I32) \
  X(BR_MASK_ALL_I128,  BR_MASK_NOTALL_I128) \
  X(BR_MASK_NONE_I128, BR_MASK_ANY_I128) \
  X(BR_OEQ_F32,        BR_UNE_F32) \
  X(BR_ONE_F32,        BR_UEQ_F32) \
  X(BR_O_F32,          BR_U_F32) \
  X(BR_OEQ_F64,        BR_UNE_F64) \
  X(BR_ONE_F64,        BR_UEQ_F64) \
  X(BR_O_F64,          BR_U_F64) \
  X(BR_OEQ_F128,       BR_UNE_F128) \
  X(BR_ONE_F128,       BR_UEQ_F128) \
  X(BR_O_F128,         BR_U_F128) \
  X(BR_LT_I32,         BR_GE_I32) \
  X(BR_LT_I64,         BR_GE_I64) \
  X(BR_LT_I128,        BR_GE_I128) \
  X(BR_LT_U32,         BR_GE_U32) \
  X(BR_LT_U64,         BR_GE_U64) \
  X(BR_LT_U128,        BR_GE_U128) \
  X(BR_OLT_F32,        BR_UGE_F32) \
  X(BR_OLT_F64,        BR_UGE_F64) \
  X(BR_OLT_F128,       BR_UGE_F128) \
  X(BR_OGE_F32,        BR_ULT_F32) \
  X(BR_OGE_F64,        BR_ULT_F64) \
  X(BR_OGE_F128,       BR_ULT_F128) \

static bool isArgSwappedOppositeCondBranch(unsigned Opc) {
    return false;
}

static unsigned getOppositeBranchOpc(unsigned Opc) {
  switch (Opc) {
#define X(OPC, OPCOP)                                         \
  case POSTRISC::OPC:         return POSTRISC::OPCOP;         \
  case POSTRISC::OPC##_EXT:   return POSTRISC::OPCOP##_EXT;   \
  case POSTRISC::OPCOP:       return POSTRISC::OPC;           \
  case POSTRISC::OPCOP##_EXT: return POSTRISC::OPC##_EXT;     \

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
    case POSTRISC::OPC##_EXT:    \
    case POSTRISC::OPCOP:        \
    case POSTRISC::OPCOP##_EXT:  \

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
  case POSTRISC::JMP_EXT:
    // opc mbb
    assert(MI.getOperand(0).isMBB());
    return MI.getOperand(0).getMBB();

#define X(OPC, OPCOP)            \
    case POSTRISC::OPC:          \
    case POSTRISC::OPC##_EXT:    \
    case POSTRISC::OPCOP:        \
    case POSTRISC::OPCOP##_EXT:  \

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
  // return true; // if failed with build branch

  // If the block has no terminators, it just falls into the block after it.
  MachineBasicBlock::iterator I = MBB.getLastNonDebugInstr();
  if (I == MBB.end())
    return false;

  if (!isUnpredicatedTerminator(*I))
    return false;

  // Get the last instruction in the block.
  MachineInstr *LastInst = &*I;
  unsigned LastOpc = LastInst->getOpcode();

  // If there is only one terminator instruction, process it.
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
  // one is not executed.
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
  // TODO: always failed, maybe not needed
  return true;

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
// NOTE: can't return true because otherwise produces something like: insn %r1, %r2, ".LBB92_-1"
bool PostriscInstrInfo::reverseBranchCondition(
    SmallVectorImpl<MachineOperand> &Cond) const {
  LLVM_DEBUG(
    dbgs() << "reverseBranchCondition: " << Cond.size() << "\n";
    for (auto const& c : Cond) {
      dbgs() << "  cond: " << c << "\n";
    });

  assert((Cond.size() >= 3) && "invalid cond size, should be: Opc, Reg, Reg/Imm");
  assert(Cond[0].isImm() && "invalid cond[0] MachineOperand - Opc");
  assert(Cond[1].isReg() && "invalid cond[1] MachineOperand - Reg");
  assert((Cond[2].isReg() || Cond[2].isImm()) && "invalid cond[2] MachineOperand - Reg/Imm");

  unsigned opcode = Cond[0].getImm();
  LLVM_DEBUG(dbgs() << "reverseBranchCondition opcode: " << opcode << " isLong=" << isLong(opcode) << "\n");

  opcode = getOppositeBranchOpc(opcode);
  LLVM_DEBUG(dbgs() << "reverseBranchCondition opposite opcode: "
                    << opcode << " isLong=" << isLong(opcode) << "\n");
  // opc ra, rb/imm, bb
  if (isArgSwappedOppositeCondBranch(opcode)) {
    // opc ra, rb, bb <=> opcOpp rb, ra, bb
    assert(Cond[1].isReg() && "invalid cond MachineOperand r1");
    assert(Cond[2].isReg() && "invalid cond MachineOperand r2");
    LLVM_DEBUG(dbgs() << "reverseBranchCondition SWAP regs: " << Cond[1] << " " << Cond[2] << "\n");
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
  case POSTRISC::JMP:        return isIntN(llvm::postrisc::InstructionFieldSize::CallDisp, Offset >> 4);
  case POSTRISC::JMP_EXT:    return isIntN(llvm::postrisc::LongInstructionFieldSize::CallDisp, Offset >> 4);

#define X(OPC, OPCOP)               \
  case POSTRISC::OPC:               \
  case POSTRISC::OPCOP:             \
    return isIntN((int)llvm::postrisc::InstructionFieldSize::BranchDisp, Offset >> 4); \
  case POSTRISC::OPC##_EXT:         \
  case POSTRISC::OPCOP##_EXT:       \
    return isIntN((int)llvm::postrisc::LongInstructionFieldSize::BranchDisp, Offset >> 4); \

  DECLARE_COND_BRANCHES(X)
#undef X
  }

  llvm_unreachable("Unknown branch instruction!");
}

void PostriscInstrInfo::copyPhysReg(MachineBasicBlock &MBB,
                                 MachineBasicBlock::iterator I,
                                 const DebugLoc &DL, Register DestReg,
                                 Register SrcReg, bool KillSrc,
                                 bool RenamableDest, bool RenamableSrc) const {
  if (POSTRISC::GRRegClass.contains(DestReg, SrcReg)) {
    BuildMI(MBB, I, DL, get(POSTRISC::MOV), DestReg)
      .addReg(SrcReg, getKillRegState(KillSrc));
  } else if (POSTRISC::SRRegClass.contains(DestReg) && POSTRISC::GRRegClass.contains(SrcReg)) {
    BuildMI(MBB, I, DL, get(POSTRISC::SET_SPR), DestReg)
      .addReg(SrcReg, getKillRegState(KillSrc));
  } else if (POSTRISC::SRRegClass.contains(SrcReg) && POSTRISC::GRRegClass.contains(DestReg)) {
    BuildMI(MBB, I, DL, get(POSTRISC::GET_SPR), DestReg)
      .addReg(SrcReg, getKillRegState(KillSrc));
  } else {
    llvm_unreachable("Impossible reg-to-reg copy");
  }
}

void PostriscInstrInfo::storeRegToStackSlot(MachineBasicBlock &MBB,
                                         MachineBasicBlock::iterator I,
                                         Register SrcReg, bool isKill, int FI,
                                         const TargetRegisterClass *RC,
                                         Register VReg,
                                         MachineInstr::MIFlag Flags) const {
  DebugLoc DL;
  if (I != MBB.end()) DL = I->getDebugLoc();

  MachineFunction *MF = MBB.getParent();
  const MachineFrameInfo &MFI = MF->getFrameInfo();
  MachineMemOperand *MMO = MF->getMachineMemOperand(
      MachinePointerInfo::getFixedStack(*MF, FI), MachineMemOperand::MOStore,
      MFI.getObjectSize(FI), MFI.getObjectAlign(FI));

  // On the order of operands here: think "[FrameIdx + 0] = SrcReg".
  assert(RC == &POSTRISC::GRRegClass);
  BuildMI(MBB, I, DL, get(POSTRISC::ST_I128))
      .addReg(SrcReg, getKillRegState(isKill))
      .addFrameIndex(FI)
      .addImm(0)
      .addMemOperand(MMO);
}

void PostriscInstrInfo::loadRegFromStackSlot(MachineBasicBlock &MBB,
                                          MachineBasicBlock::iterator I,
                                          Register DestReg, int FI,
                                          const TargetRegisterClass *RC,
                                          Register VReg, unsigned SubReg,
                                          MachineInstr::MIFlag Flags) const {
  DebugLoc DL;
  if (I != MBB.end()) DL = I->getDebugLoc();

  MachineFunction *MF = MBB.getParent();
  const MachineFrameInfo &MFI = MF->getFrameInfo();
  MachineMemOperand *MMO = MF->getMachineMemOperand(
      MachinePointerInfo::getFixedStack(*MF, FI), MachineMemOperand::MOLoad,
      MFI.getObjectSize(FI), MFI.getObjectAlign(FI));

  assert(RC == &POSTRISC::GRRegClass);
  BuildMI(MBB, I, DL, get(POSTRISC::LD_I128))
      .addReg(DestReg, RegState::Define)
      .addFrameIndex(FI)
      .addImm(0)
      .addMemOperand(MMO);

}

bool PostriscInstrInfo::expandPostRAPseudo(MachineInstr &MI) const {
  switch (MI.getOpcode()) {
  case TargetOpcode::LOAD_STACK_GUARD: {
    assert(Subtarget.getTargetTriple().isOSLinux() &&
           "Only Linux target is expected to contain LOAD_STACK_GUARD");
    // offsetof(tcbhead_t, stack_guard) from sysdeps/postrisc/nptl/tls.h in glibc.
    const int64_t Offset = Subtarget.is64Bit() ? 0x28 : 0x14;
    MI.setDesc(get(POSTRISC::LD_U64));
    MachineInstrBuilder(*MI.getParent()->getParent(), MI)
        .addReg(POSTRISC::tp)
        .addImm(Offset);
    return true;
  }
  }
  return false;
}
