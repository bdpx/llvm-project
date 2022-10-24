//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_POSTRISC_POSTRISCASMPRINTER_H
#define LLVM_LIB_TARGET_POSTRISC_POSTRISCASMPRINTER_H

#include "llvm/CodeGen/MachineFunctionAnalysisManager.h"
#include "llvm/IR/Analysis.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/PassManager.h"

namespace llvm {

class PostriscAsmPrinterBeginPass
    : public RequiredPassInfoMixin<PostriscAsmPrinterBeginPass> {
public:
  PreservedAnalyses run(Module &M, ModuleAnalysisManager &MFAM);
};

class PostriscAsmPrinterPass : public RequiredPassInfoMixin<PostriscAsmPrinterPass> {
public:
  PreservedAnalyses run(MachineFunction &MF,
                        MachineFunctionAnalysisManager &MFAM);
};

class PostriscAsmPrinterEndPass
    : public RequiredPassInfoMixin<PostriscAsmPrinterEndPass> {
public:
  PreservedAnalyses run(Module &M, ModuleAnalysisManager &MFAM);
};

} // namespace llvm

#endif // LLVM_LIB_TARGET_POSTRISC_POSTRISCASMPRINTER_H
