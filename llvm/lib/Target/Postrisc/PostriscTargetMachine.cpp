//===-- PostriscTargetMachine.cpp - Define TargetMachine for Postrisc -----===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
//
//===----------------------------------------------------------------------===//

#include "PostriscTargetMachine.h"
#include "PostriscPasses.h"
#include "Postrisc.h"
#include "PostriscMachineFunctionInfo.h"
#include "PostriscTargetObjectFile.h"
#include "TargetInfo/PostriscTargetInfo.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/CodeGen/TargetPassConfig.h"
// #include "llvm/IR/LegacyPassManager.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/Support/Debug.h"
#include <optional>

#define DEBUG_TYPE "postrisc-targetmachine"

using namespace llvm;

extern "C" LLVM_EXTERNAL_VISIBILITY void LLVMInitializePostriscTarget() {
  // Register the target.
  RegisterTargetMachine<PostriscV1TargetMachine> X(getThePostriscTarget());
  PassRegistry &PR = *PassRegistry::getPassRegistry();
  initializePostriscDAGToDAGISelLegacyPass(PR);
}

static std::string computeDataLayout(const Triple &T, bool is64Bit) {
  // https://llvm.org/docs/LangRef.html, Data Layout

  std::string Ret =
     "e"             // little-endian
     "-m:e"          // ELF mangling
     "-S128"         // stack alignment
     "-p:64:64"      // pointers size/alignment
     "-i8:8"         // Alignments for 8 bit integers
     "-i16:16"       // Alignments for 16 bit integers
     "-i32:32"       // Alignments for 32 bit integers
     "-i64:64"       // Alignments for 64 bit integers
     "-i128:128"     // Alignments for 128 bit integers
     "-n64"          // native integers are 64-bit
     "-f32:32:32"    // float is 32-bit aligned
     "-f64:64:64"    // double is 64-bit aligned
     "-f128:128:128" // quad is 128-bit aligned
     "-v128:128:128" // 128-bit vector is 128-bit aligned
     "-a:0:64"       // aggregates are 64-bit aligned
     // "-n32"
  ;

  return Ret;
}

static Reloc::Model getEffectiveRelocModel(std::optional<Reloc::Model> RM) {
  return RM.value_or(Reloc::PIC_); // FIXME: Static?
}

static char const *getCodeModelName(CodeModel::Model CM)
{
  switch (CM) {
    case CodeModel::Tiny:   return "Tiny";
    case CodeModel::Small:  return "Small";
    case CodeModel::Medium: return "Medium";
    case CodeModel::Large:  return "Large";
    case CodeModel::Kernel: return "Kernel";
  }
  llvm_unreachable("Unknown code model");
  return "unknown_code_model";
}

static char const *getRelocationModelName(Reloc::Model RM)
{
  switch (RM) {
    case Reloc::Static:       return "Static";
    case Reloc::PIC_:         return "PIC_";
    case Reloc::DynamicNoPIC: return "DynamicNoPIC";
    case Reloc::ROPI:         return "ROPI";
    case Reloc::RWPI:         return "RWPI";
    case Reloc::ROPI_RWPI:    return "ROPI_RWPI";
  }
  llvm_unreachable("Unknown reloc model");
  return "unknown_reloc_model";
}

// Code models. Some only make sense for 64-bit code.
//
// SunCC  Reloc   CodeModel  Constraints
// abs32  Static  Small      text+data+bss linked below 2^32 bytes
// abs44  Static  Medium     text+data+bss linked below 2^44 bytes
// abs64  Static  Large      text smaller than 2^31 bytes
// pic13  PIC_    Small      GOT < 2^13 bytes
// pic32  PIC_    Medium     GOT < 2^32 bytes
//
// All code models require that the text segment is smaller than 2GB.
static CodeModel::Model
getEffectivePostriscCodeModel(std::optional<CodeModel::Model> CM, Reloc::Model RM,
                           bool Is64Bit, bool JIT) {
  LLVM_DEBUG(dbgs() << "JIT=" << JIT
                    << " relocmodel=" << getRelocationModelName(RM) << "\n");
  if (CM) {
    LLVM_DEBUG(dbgs() << "CodeModel: " << getCodeModelName(*CM) << "\n");
    if (*CM == CodeModel::Tiny)
      report_fatal_error("Target does not support the tiny CodeModel", false);
    if (*CM == CodeModel::Kernel)
      report_fatal_error("Target does not support the kernel CodeModel", false);
    return *CM;
  }
  if (Is64Bit) {
    if (JIT)
      return CodeModel::Large;
    return RM == Reloc::PIC_ ? CodeModel::Small : CodeModel::Medium;
  }
  return CodeModel::Small;
}

/// Create an ILP32 architecture model
PostriscTargetMachine::PostriscTargetMachine(const Target &T, const Triple &TT,
                                       StringRef CPU, StringRef FS,
                                       const TargetOptions &Options,
                                       std::optional<Reloc::Model> RM,
                                       std::optional<CodeModel::Model> CM,
                                       CodeGenOptLevel OL, bool JIT,
                                       bool is64bit)
    : LLVMTargetMachine(T, computeDataLayout(TT, is64bit), TT, CPU, FS, Options,
                        getEffectiveRelocModel(RM),
                        getEffectivePostriscCodeModel(
                            CM, getEffectiveRelocModel(RM), is64bit, JIT),
                        OL),
      TLOF(std::make_unique<PostriscELFTargetObjectFile>()), is64Bit(is64bit) {
  LLVM_DEBUG(dbgs() << "PTM: isPositionIndependent=" << isPositionIndependent()
         << " relocmodel=" << getRelocationModelName(getRelocationModel())
         << " CodeModel=" << getCodeModelName(getCodeModel()) << "\n");
  initAsmInfo();
}

PostriscTargetMachine::~PostriscTargetMachine() = default;

const PostriscSubtarget *
PostriscTargetMachine::getSubtargetImpl(const Function &F) const {
  Attribute CPUAttr = F.getFnAttribute("target-cpu");
  Attribute TuneAttr = F.getFnAttribute("tune-cpu");
  Attribute FSAttr = F.getFnAttribute("target-features");

  std::string CPU =
      CPUAttr.isValid() ? CPUAttr.getValueAsString().str() : TargetCPU;
  std::string TuneCPU =
      TuneAttr.isValid() ? TuneAttr.getValueAsString().str() : CPU;
  std::string FS =
      FSAttr.isValid() ? FSAttr.getValueAsString().str() : TargetFS;

  auto &I = SubtargetMap[CPU + FS];
  if (!I) {
    // This needs to be done before we create a new subtarget since any
    // creation will depend on the TM and the code generation flags on the
    // function that reside in TargetOptions.
    resetTargetOptions(F);
    I = std::make_unique<PostriscSubtarget>(CPU, TuneCPU, FS, *this,
                                          this->is64Bit);
  }
  return I.get();
}

MachineFunctionInfo *PostriscTargetMachine::createMachineFunctionInfo(
    BumpPtrAllocator &Allocator, const Function &F,
    const TargetSubtargetInfo *STI) const {
  return PostriscMachineFunctionInfo::create<PostriscMachineFunctionInfo>(Allocator,
                                                                    F, STI);
}

namespace {
/// Postrisc Code Generator Pass Configuration Options.
class PostriscPassConfig : public TargetPassConfig {
public:
  PostriscPassConfig(PostriscTargetMachine &TM, PassManagerBase &PM)
    : TargetPassConfig(TM, PM) {}

  PostriscTargetMachine &getPostriscTargetMachine() const {
    return getTM<PostriscTargetMachine>();
  }

  void addIRPasses() override;
  bool addInstSelector() override;
  void addPreRegAlloc() override;
  void addPostRegAlloc() override;
  void addPreEmitPass() override;
  void addPreEmitPass2() override;
  void addMachineLateOptimization() override;
};
} // namespace

TargetPassConfig *PostriscTargetMachine::createPassConfig(PassManagerBase &PM) {
  return new PostriscPassConfig(*this, PM);
}

void PostriscPassConfig::addIRPasses() {
  addPass(createAtomicExpandLegacyPass());
  TargetPassConfig::addIRPasses();
}

bool PostriscPassConfig::addInstSelector() {
  addPass(createPostriscISelDag(getPostriscTargetMachine()));
  return false;
}

void PostriscPassConfig::addPreRegAlloc()
{
  TargetPassConfig::addPreRegAlloc();

  addPass(createPostriscFrameFixer());
  addPass(createPostriscOptAddrMode());
}

void PostriscPassConfig::addMachineLateOptimization() {
  TargetPassConfig::addMachineLateOptimization();

  addPass(createPostriscNullificationPass());
}
void PostriscPassConfig::addPostRegAlloc()
{
  TargetPassConfig::addPostRegAlloc();
}

void PostriscPassConfig::addPreEmitPass(){
  TargetPassConfig::addPreEmitPass();
}

void PostriscPassConfig::addPreEmitPass2()
{
  TargetPassConfig::addPreEmitPass2();

  addPass(createPostriscBundlerPass());
}

void PostriscV1TargetMachine::anchor() { }

PostriscV1TargetMachine::PostriscV1TargetMachine(const Target &T, const Triple &TT,
                                           StringRef CPU, StringRef FS,
                                           const TargetOptions &Options,
                                           std::optional<Reloc::Model> RM,
                                           std::optional<CodeModel::Model> CM,
                                           CodeGenOptLevel OL, bool JIT)
    : PostriscTargetMachine(T, TT, CPU, FS, Options, RM, CM, OL, JIT, true) {}

void PostriscV2TargetMachine::anchor() {}

PostriscV2TargetMachine::PostriscV2TargetMachine(const Target &T, const Triple &TT,
                                           StringRef CPU, StringRef FS,
                                           const TargetOptions &Options,
                                           std::optional<Reloc::Model> RM,
                                           std::optional<CodeModel::Model> CM,
                                           CodeGenOptLevel OL, bool JIT)
    : PostriscTargetMachine(T, TT, CPU, FS, Options, RM, CM, OL, JIT, true) {}
