//===------- PostriscPasses.h - Define passes specific to POSTRISC ----------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_POSTRISC_POSTRISC_PASSES_H
#define LLVM_LIB_TARGET_POSTRISC_POSTRISC_PASSES_H

#include "llvm/CodeGen/MachineFunctionPass.h"

namespace llvm {
class PostriscSubtarget;

class LLVM_LIBRARY_VISIBILITY PostriscMachineFunctionPass
    : public MachineFunctionPass {
protected:
  const PostriscSubtarget *Subtarget = nullptr;
  const int LAST_OPERAND = -1;

  // this vector holds free registers that we allocate in groups for some of the
  // POSTRISC passes
  std::vector<int> UsedRegisters;

protected:
  PostriscMachineFunctionPass(char &ID);

  void clearUsedRegisterList() { UsedRegisters.clear(); }

  void markRegisterUsed(int registerIndex) {
    UsedRegisters.push_back(registerIndex);
  }
};

class LLVM_LIBRARY_VISIBILITY FixAllFDIVSQRT : public PostriscMachineFunctionPass {
public:
  static char ID;

  FixAllFDIVSQRT();
  bool runOnMachineFunction(MachineFunction &MF) override;

  StringRef getPassName() const override {
    return "FixAllFDIVSQRT: fix FDIVS/FDIVD/FSQRTS/FSQRTD "
           "instructions with NOPs and floating-point store";
  }
};
} // namespace llvm

#endif // LLVM_LIB_TARGET_POSTRISC_POSTRISC_PASSES_H
