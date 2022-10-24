//===- PostriscMachineFunctionInfo.h - Postrisc Machine Function Info -*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file declares  Postrisc specific per-machine-function information.
//
//===----------------------------------------------------------------------===//
#ifndef LLVM_LIB_TARGET_POSTRISC_POSTRISCMACHINEFUNCTIONINFO_H
#define LLVM_LIB_TARGET_POSTRISC_POSTRISCMACHINEFUNCTIONINFO_H

#include "llvm/CodeGen/MachineFunction.h"

namespace llvm {

  class PostriscMachineFunctionInfo : public MachineFunctionInfo {
    virtual void anchor();
  private:
    /// FrameIndex for start of varargs area
    /// FIXME: for the va_list va_start creation workaround - ste initially any positive value (invalid FI)
    int VarArgsFrameIndex;
    ///
    MachineInstr *FrameSaveInstr = nullptr;

    /// SRetReturnReg - Holds the virtual register into which the sret
    /// argument is passed.
    Register SRetReturnReg;

    /// IsLeafProc - True if the function is a leaf procedure.
    bool IsLeafProc;
  public:
    PostriscMachineFunctionInfo()
      : VarArgsFrameIndex(0), SRetReturnReg(0), IsLeafProc(false) {}
    PostriscMachineFunctionInfo(const Function &F, const TargetSubtargetInfo *STI)
      : VarArgsFrameIndex(0), SRetReturnReg(0), IsLeafProc(false) {}

    MachineFunctionInfo *
    clone(BumpPtrAllocator &Allocator, MachineFunction &DestMF,
          const DenseMap<MachineBasicBlock *, MachineBasicBlock *> &Src2DstMBB)
        const override;

    int getVarArgsFrameIndex() const { return VarArgsFrameIndex; }
    void setVarArgsFrameIndex(int Index) { VarArgsFrameIndex = Index; }

    MachineInstr *getFrameSaveInstr() const { return FrameSaveInstr; }
    void setFrameSaveInstr(MachineInstr *MI) { FrameSaveInstr = MI; }

    Register getSRetReturnReg() const { return SRetReturnReg; }
    void setSRetReturnReg(Register Reg) { SRetReturnReg = Reg; }

    void setLeafProc(bool rhs) { IsLeafProc = rhs; }
    bool isLeafProc() const { return IsLeafProc; }
  };
}

#endif
