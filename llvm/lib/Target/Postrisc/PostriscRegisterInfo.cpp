//===-- PostriscRegisterInfo.cpp - POSTRISC Register Information ----------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains the POSTRISC implementation of the TargetRegisterInfo class.
//
//===----------------------------------------------------------------------===//

#include "PostriscRegisterInfo.h"
#include "Postrisc.h"
#include "PostriscMachineFunctionInfo.h"
#include "PostriscSubtarget.h"
#include "llvm/ADT/BitVector.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/TargetInstrInfo.h"
#include "llvm/IR/Type.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/Postrisc/PostriscBundle.h"

using namespace llvm;

#define DEBUG_TYPE "postrisc-reg-info"

#define GET_REGINFO_TARGET_DESC
#include "PostriscGenRegisterInfo.inc"


PostriscRegisterInfo::PostriscRegisterInfo(const PostriscSubtarget &STI)
  : PostriscGenRegisterInfo(POSTRISC::r0) //link register, where return address can be found
{}

const MCPhysReg*
PostriscRegisterInfo::getCalleeSavedRegs(const MachineFunction *MF) const {
  return CSR_SaveList;
}

const uint32_t *
PostriscRegisterInfo::getCallPreservedMask(const MachineFunction &MF,
                                        CallingConv::ID CC) const {
  return CSR_RegMask;
}

BitVector PostriscRegisterInfo::getReservedRegs(const MachineFunction &MF) const {
  BitVector Reserved(getNumRegs());
#define X(NAME) Reserved.set(POSTRISC::NAME);
  X(r0) // link register is reserved
  X(g0) X(g1) X(g2) X(g3) X(tp) X(fp) X(sp) X(gz) // global regs are reserved
  SPECIAL_REGISTERS_CASES(X) // all special regs are reserved
#undef X
  return Reserved;
}

const TargetRegisterClass *
PostriscRegisterInfo::getPointerRegClass(unsigned Kind) const {
  assert(Kind == 0 && "this should only be used for default cases");
  return &POSTRISC::GRRegClass;
}

static void replaceFI(MachineFunction &MF, MachineBasicBlock::iterator II,
                      MachineInstr &MI, const DebugLoc &dl,
                      unsigned FIOperandNum, int Offset, unsigned FramePtr) {
  // Replace frame index with a frame pointer reference.
  assert(isInt<llvm::postrisc::LongInstructionFieldSize::BinaryImm>(Offset));
  // If the offset is small enough to fit in the immediate field, directly
  // encode it.
  MI.getOperand(FIOperandNum).ChangeToRegister(FramePtr, false);
  MI.getOperand(FIOperandNum + 1).ChangeToImmediate(Offset);
}

/*
This method must be overriden to eliminate abstract frame indices from instructions which may use them.
The instruction referenced by the iterator contains an MO_FrameIndex operand which must be eliminated by this method.
This method may modify or replace the specified instruction, as long as it keeps the iterator pointing at the finished product.
SPAdj is the SP adjustment due to call frame setup instruction. FIOperandNum is the FI operand number.
Returns true if the current instruction was removed and the iterator is not longer valid
*/
bool
PostriscRegisterInfo::eliminateFrameIndex(MachineBasicBlock::iterator II,
                                       int SPAdj, unsigned FIOperandNum,
                                       RegScavenger *RS) const {
  assert(SPAdj == 0 && "Unexpected");

  MachineInstr &MI = *II;
  DebugLoc dl = MI.getDebugLoc();
  int FrameIndex = MI.getOperand(FIOperandNum).getIndex();
  MachineFunction &MF = *MI.getParent()->getParent();
  // const PostriscSubtarget &Subtarget = MF.getSubtarget<PostriscSubtarget>();
  const PostriscFrameLowering *TFI = getFrameLowering(MF);

  Register FrameReg;
  int Offset;
  Offset = TFI->getFrameIndexReference(MF, FrameIndex, FrameReg).getFixed();

  LLVM_DEBUG(dbgs() << "eliminateFrameIndex: FIOperandNum=" << FIOperandNum << " "; MI.dump());

  Offset += MI.getOperand(FIOperandNum + 1).getImm();

  replaceFI(MF, II, MI, dl, FIOperandNum, Offset, FrameReg);
  // replaceFI never removes II
  return false;
}

Register PostriscRegisterInfo::getFrameRegister(const MachineFunction &MF) const {
  const PostriscSubtarget& Subtarget = MF.getSubtarget<PostriscSubtarget>();
  const PostriscRegisterInfo *TRI = Subtarget.getRegisterInfo();
  const PostriscFrameLowering *TFL = TRI->getFrameLowering(MF);
  Register frameReg;
  if (TFL->hasFP(MF)) {
    LLVM_DEBUG(dbgs() << "getFrameRegister: hasFP" << " MF=" << MF.getName() << "\n");
    frameReg = POSTRISC::fp;
  } else {
    LLVM_DEBUG(dbgs() << "getFrameRegister: no FP MF=" << MF.getName() << "\n");
    frameReg = POSTRISC::sp;
  }
  return frameReg;
}

// Postrisc has no architectural need for stack realignment support,
// except that LLVM unfortunately currently implements overaligned
// stack objects by depending upon stack realignment support.
// If that ever changes, this can probably be deleted.
bool PostriscRegisterInfo::canRealignStack(const MachineFunction &MF) const {
  if (!TargetRegisterInfo::canRealignStack(MF))
    return false;

  // Postrisc always has a fixed frame pointer register, so don't need to
  // worry about needing to reserve it. [even if we don't have a frame
  // pointer for our frame, it still cannot be used for other things,
  // or register window traps will be SADNESS.]

  // If there's a reserved call frame, we can use SP to access locals.
  if (getFrameLowering(MF)->hasReservedCallFrame(MF))
    return true;

  // Otherwise, we'd need a base pointer, but those aren't implemented
  // for POSTRISC at the moment.

  return false;
}

char const *
PostriscRegisterInfo::getRegisterName(unsigned id)
{
  switch (id) {
#define X(NAME) case POSTRISC::NAME: return #NAME;
    GENERAL_REGISTERS_CASES(X)
#undef X
  }
  return "unknown";
}
