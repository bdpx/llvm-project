//===-- PostriscFrameLowering.h - Define frame lowering for Postrisc --*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
//
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_POSTRISC_POSTRISCFRAMELOWERING_H
#define LLVM_LIB_TARGET_POSTRISC_POSTRISCFRAMELOWERING_H

#include "Postrisc.h"
#include "llvm/CodeGen/TargetFrameLowering.h"
#include "llvm/Support/TypeSize.h"

namespace llvm {

class PostriscSubtarget;
class PostriscFrameLowering : public TargetFrameLowering {
public:
  explicit PostriscFrameLowering(const PostriscSubtarget &ST);

  /// emitProlog/emitEpilog - These methods insert prolog and epilog code into
  /// the function.
  void emitPrologue(MachineFunction &MF, MachineBasicBlock &MBB) const override;
  void emitEpilogue(MachineFunction &MF, MachineBasicBlock &MBB) const override;

  MachineBasicBlock::iterator
  eliminateCallFramePseudoInstr(MachineFunction &MF,
                                MachineBasicBlock &MBB,
                                MachineBasicBlock::iterator I) const override;

  bool hasReservedCallFrame(const MachineFunction &MF) const override;
  void determineCalleeSaves(MachineFunction &MF, BitVector &SavedRegs,
                            RegScavenger *RS = nullptr) const override;

  StackOffset getFrameIndexReference(const MachineFunction &MF, int FI,
                                     Register &FrameReg) const override;

  /// targetHandlesStackFrameRounding - Returns true if the target is
  /// responsible for rounding up the stack frame (probably at emitPrologue
  /// time).
  bool targetHandlesStackFrameRounding() const override { return true; }
  bool hasFP(const MachineFunction &MF) const { return hasFPImpl(MF); }

protected:
  bool hasFPImpl(const MachineFunction &MF) const override;

private:
  void remapOutputRegs(MachineFunction &MF) const;

  // Returns true if MF is a leaf procedure.
  bool isLeafProc(MachineFunction &MF) const;


  // Emits code for adjusting SP in function prologue/epilogue.
  void emitSPAdjustment(MachineFunction &MF,
                        MachineBasicBlock &MBB,
                        MachineBasicBlock::iterator MBBI,
                        int NumBytes) const;

};

} // End llvm namespace

#endif
