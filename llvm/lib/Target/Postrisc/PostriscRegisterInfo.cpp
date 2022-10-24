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

using namespace llvm;

#define DEBUG_TYPE "postrisc-reg-info"

#define GET_REGINFO_TARGET_DESC
#include "PostriscGenRegisterInfo.inc"


PostriscRegisterInfo::PostriscRegisterInfo()
  : PostriscGenRegisterInfo(POSTRISC::r0) //FIXME - link register?
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
  // link register is reserved
  X(r0)
  // all global regs are reserved
  X(g0) X(g1) X(g2) X(g3) X(tp) X(fp) X(sp) X(gz)
  // all special regs are reserved
  X(ip) X(eip) X(fpcr) X(eca) X(rsc) X(rsp) X(bsp) X(psr) X(reip)
  X(kip) X(ksp) X(krsp) X(peb) X(teb)
  X(itc) X(itm) X(pta)
  X(iva) X(iip) X(iipa) X(ipsr) X(cause) X(ifa) X(iib)
  X(irr0) X(irr1) X(irr2) X(irr3)
  X(isr0) X(isr1) X(isr2) X(isr3)
  X(iv) X(lid) X(tpr)
  X(itcv) X(tsv) X(pmv) X(cmcv)
#undef X
  return Reserved;
}

const TargetRegisterClass*
PostriscRegisterInfo::getPointerRegClass(const MachineFunction &MF,
                                      unsigned Kind) const {
  // const PostriscSubtarget &Subtarget = MF.getSubtarget<PostriscSubtarget>();
  return &POSTRISC::GRRegClass;
}

static void replaceFI(MachineFunction &MF, MachineBasicBlock::iterator II,
                      MachineInstr &MI, const DebugLoc &dl,
                      unsigned FIOperandNum, int Offset, unsigned FramePtr) {
  // Replace frame index with a frame pointer reference.
  assert(isInt<63>(Offset));
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
#define X(NAME) case POSTRISC::NAME: return #NAME;
  switch (id) {
#define R(ID) X(r##ID)
  R(0)  R(1)  R(2)  R(3)  R(4)  R(5)  R(6)  R(7)
  R(8)  R(9)  R(10) R(11) R(12) R(13) R(14) R(15)
  R(16) R(17) R(18) R(19) R(20) R(21) R(22) R(23)
  R(24) R(25) R(26) R(27) R(28) R(29) R(30) R(31)
  R(32) R(33) R(34) R(35) R(36) R(37) R(38) R(39)
  R(40) R(41) R(42) R(43) R(44) R(45) R(46) R(47)
  R(48) R(49) R(50) R(51) R(52) R(53) R(54) R(55)
  R(56) R(57) R(58) R(59) R(60) R(61) R(62) R(63)
  R(64) R(65) R(66) R(67) R(68) R(69) R(70) R(71)
  R(72) R(73) R(74) R(75) R(76) R(77) R(78) R(79)
  R(80) R(81) R(82) R(83) R(84) R(85) R(86) R(87)
  R(88) R(89) R(90) R(91) R(92) R(93) R(94) R(95)
  R(96) R(97) R(98) R(99) R(100) R(101) R(102) R(103)
  R(104) R(105) R(106) R(107) R(108) R(109) R(110) R(111)
  R(112) R(113) R(114) R(115) R(116) R(117) R(118) R(119)
#undef R
  X(g0) X(g1) X(g2) X(g3) X(tp) X(fp) X(sp) X(gz)
#undef X
  }
  return "unknown";
}
