//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "Postrisc.h"
#include "PostriscAsmPrinter.h"
#include "PostriscTargetMachine.h"
#include "llvm/CodeGen/AtomicExpand.h"
#include "llvm/CodeGen/BranchRelaxation.h"
#include "llvm/IR/PassInstrumentation.h"
#include "llvm/Passes/CodeGenPassBuilder.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Target/CGPassBuilderOption.h"

using namespace llvm;

namespace {

class PostriscCodeGenPassBuilder : public CodeGenPassBuilder {
  using Base = CodeGenPassBuilder;

  PostriscTargetMachine &getTM() const {
    return static_cast<PostriscTargetMachine &>(TM);
  }

public:
  explicit PostriscCodeGenPassBuilder(PostriscTargetMachine &TM,
                                   const CGPassBuilderOption &Opts,
                                   PassInstrumentationCallbacks *PIC)
      : CodeGenPassBuilder(TM, Opts, PIC) {}

  void addIRPasses(PassManagerWrapper &PMW) override;
  Error addInstSelector(PassManagerWrapper &PMW) override;
  void addAsmPrinterBegin(PassManagerWrapper &PMW) override;
  void addAsmPrinter(PassManagerWrapper &PMW) override;
  void addAsmPrinterEnd(PassManagerWrapper &PMW) override;

  void addPreRegAlloc(PassManagerWrapper &PMW) override;
  void addMachineLateOptimization(PassManagerWrapper &PMW) override;
  void addPreEmitPass2(PassManagerWrapper &PMW) override;
};

void PostriscCodeGenPassBuilder::addIRPasses(PassManagerWrapper &PMW) {
  addFunctionPass(AtomicExpandPass(getTM()), PMW);

  Base::addIRPasses(PMW);
}

Error PostriscCodeGenPassBuilder::addInstSelector(PassManagerWrapper &PMW) {
  addMachineFunctionPass(PostriscDAGToDAGISelPass(getTM(), getOptLevel()), PMW);
  return Error::success();
}

void PostriscCodeGenPassBuilder::addAsmPrinterBegin(PassManagerWrapper &PMW) {
  addModulePass(PostriscAsmPrinterBeginPass(), PMW, /*Force=*/true);
}

void PostriscCodeGenPassBuilder::addAsmPrinter(PassManagerWrapper &PMW) {
  addMachineFunctionPass(PostriscAsmPrinterPass(), PMW, /*Force=*/true);
}

void PostriscCodeGenPassBuilder::addAsmPrinterEnd(PassManagerWrapper &PMW) {
  addModulePass(PostriscAsmPrinterEndPass(), PMW, /*Force=*/true);
}

void PostriscCodeGenPassBuilder::addMachineLateOptimization(PassManagerWrapper &PMW) {
  addMachineFunctionPass(PostriscMergeMovesPass(), PMW);
}

void PostriscCodeGenPassBuilder::addPreRegAlloc(PassManagerWrapper &PMW)
{
  addMachineFunctionPass(PostriscOptAddrModePass(), PMW);
  addMachineFunctionPass(PostriscFrameFixerPass(), PMW);
}

void PostriscCodeGenPassBuilder::addPreEmitPass2(PassManagerWrapper &PMW)
{
  addMachineFunctionPass(PostriscNullificationPass(), PMW);
  addMachineFunctionPass(PostriscBlockMergerPass(), PMW);
  addMachineFunctionPass(PostriscBundlerPass(), PMW);
}

} // namespace

void PostriscTargetMachine::registerPassBuilderCallbacks(PassBuilder &PB){
#define GET_PASS_REGISTRY "PostriscPassRegistry.def"
#include "llvm/Passes/TargetPassRegistry.inc"
}

Error PostriscTargetMachine::buildCodeGenPipeline(
    ModulePassManager &MPM, ModuleAnalysisManager &MAM, raw_pwrite_stream &Out,
    raw_pwrite_stream *DwoOut, CodeGenFileType FileType,
    const CGPassBuilderOption &Opt, MCContext &Ctx,
    PassInstrumentationCallbacks *PIC) {
  auto CGPB = PostriscCodeGenPassBuilder(*this, Opt, PIC);
  return CGPB.buildPipeline(MPM, MAM, Out, DwoOut, FileType, Ctx);
}
