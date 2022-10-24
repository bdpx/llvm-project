//===-- PostriscTargetInfo.cpp - Postrisc Target Implementation -----------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "TargetInfo/PostriscTargetInfo.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/Support/Compiler.h"
using namespace llvm;

Target &llvm::getThePostriscTarget() {
  static Target ThePostriscTarget;
  return ThePostriscTarget;
}

extern "C" LLVM_ABI LLVM_EXTERNAL_VISIBILITY void LLVMInitializePostriscTargetInfo() {
  RegisterTarget<Triple::postrisc, /*HasJIT=*/true> X(getThePostriscTarget(),
                                                    "postrisc", "Postrisc", "Postrisc");
}
