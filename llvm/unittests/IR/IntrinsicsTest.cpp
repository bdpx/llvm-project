//===- llvm/unittest/IR/IntrinsicsTest.cpp - ------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "llvm/IR/Intrinsics.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/IR/Constant.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/IntrinsicsAArch64.h"
#include "llvm/IR/IntrinsicsAMDGPU.h"
#include "llvm/IR/IntrinsicsARM.h"
#include "llvm/IR/IntrinsicsBPF.h"
#include "llvm/IR/IntrinsicsDirectX.h"
#include "llvm/IR/IntrinsicsHexagon.h"
#include "llvm/IR/IntrinsicsLoongArch.h"
#include "llvm/IR/IntrinsicsMips.h"
#include "llvm/IR/IntrinsicsNVPTX.h"
#include "llvm/IR/IntrinsicsPowerPC.h"
#include "llvm/IR/IntrinsicsRISCV.h"
#include "llvm/IR/IntrinsicsS390.h"
#include "llvm/IR/IntrinsicsX86.h"
#include "llvm/IR/Module.h"
#include "gtest/gtest.h"

using namespace llvm;

namespace {

class IntrinsicsTest : public ::testing::Test {
  LLVMContext Context;
  std::unique_ptr<Module> M;
  BasicBlock *BB = nullptr;

  void TearDown() override { M.reset(); }

  void SetUp() override {
    M = std::make_unique<Module>("Test", Context);
    auto F = M->getOrInsertFunction(
        "test", FunctionType::get(Type::getVoidTy(Context), false));
    BB = BasicBlock::Create(Context, "", cast<Function>(F.getCallee()));
    EXPECT_NE(BB, nullptr);
  }

public:
  Instruction *makeIntrinsic(Intrinsic::ID ID) const {
    IRBuilder<> Builder(BB);
    SmallVector<Value *, 4> ProcessedArgs;
    auto *Decl = Intrinsic::getOrInsertDeclaration(M.get(), ID);
    for (auto *Ty : Decl->getFunctionType()->params()) {
      auto *Val = Constant::getNullValue(Ty);
      ProcessedArgs.push_back(Val);
    }
    return Builder.CreateCall(Decl, ProcessedArgs);
  }
  template <typename T> void checkIsa(const Instruction &I) {
    EXPECT_TRUE(isa<T>(I));
  }
};

TEST(IntrinsicNameLookup, Basic) {
  using namespace Intrinsic;
  EXPECT_EQ(Intrinsic::memcpy, lookupIntrinsicID("llvm.memcpy"));

  // Partial, either between dots or not the last dot are not intrinsics.
  EXPECT_EQ(not_intrinsic, lookupIntrinsicID("llvm.mem"));
  EXPECT_EQ(not_intrinsic, lookupIntrinsicID("llvm.gc"));

  // Look through intrinsic names with internal dots.
  EXPECT_EQ(memcpy_inline, lookupIntrinsicID("llvm.memcpy.inline"));

  // Check that overloaded names are mapped to the underlying ID.
  EXPECT_EQ(memcpy_inline, lookupIntrinsicID("llvm.memcpy.inline.p0.p0.i8"));
  EXPECT_EQ(memcpy_inline, lookupIntrinsicID("llvm.memcpy.inline.p0.p0.i32"));
  EXPECT_EQ(memcpy_inline, lookupIntrinsicID("llvm.memcpy.inline.p0.p0.i64"));
  EXPECT_EQ(memcpy_inline, lookupIntrinsicID("llvm.memcpy.inline.p0.p0.i1024"));
}

TEST(IntrinsicNameLookup, NonNullterminatedStringRef) {
  using namespace Intrinsic;
  // This reproduces an issue where lookupIntrinsicID() can access memory beyond
  // the bounds of the passed in StringRef. For ASAN to catch this as an error,
  // create a StringRef using heap allocated memory and make it not null
  // terminated.

  // ASAN will report a "AddressSanitizer: heap-buffer-overflow" error in
  // `lookupLLVMIntrinsicByName` when LLVM is built with these options:
  //  -DCMAKE_BUILD_TYPE=Debug
  //  -DLLVM_USE_SANITIZER=Address
  //  -DLLVM_OPTIMIZE_SANITIZED_BUILDS=OFF

  // Make an intrinsic name "llvm.memcpy.inline" on the heap.
  std::string Name = "llvm.memcpy.inline";
  assert(Name.size() == 18);
  // Create a StringRef backed by heap allocated memory such that OOB access
  // in that StringRef can be flagged by asan. Here, the String `S` is of size
  // 18, and backed by a heap allocated buffer `Data`, so access to S[18] will
  // be flagged bby asan.
  auto Data = std::make_unique<char[]>(Name.size());
  std::strncpy(Data.get(), Name.data(), Name.size());
  StringRef S(Data.get(), Name.size());
  EXPECT_EQ(memcpy_inline, lookupIntrinsicID(S));
}

// Tests to verify getIntrinsicForClangBuiltin.
TEST(IntrinsicNameLookup, ClangBuiltinLookup) {
  using namespace Intrinsic;
  static constexpr std::tuple<StringRef, StringRef, ID> ClangTests[] = {
      {"__builtin_adjust_trampoline", "", adjust_trampoline},
      {"__builtin_trap", "", trap},
      {"__builtin_arm_chkfeat", "aarch64", aarch64_chkfeat},
      {"__builtin_amdgcn_alignbyte", "amdgcn", amdgcn_alignbyte},
      {"__builtin_amdgcn_workgroup_id_z", "amdgcn", amdgcn_workgroup_id_z},
      {"__builtin_arm_cdp", "arm", arm_cdp},
      {"__builtin_bpf_preserve_type_info", "bpf", bpf_preserve_type_info},
      {"__builtin_HEXAGON_A2_tfr", "hexagon", hexagon_A2_tfr},
      {"__builtin_lasx_xbz_w", "loongarch", loongarch_lasx_xbz_w},
      {"__builtin_mips_bitrev", "mips", mips_bitrev},
      {"__nvvm_add_rn_d", "nvvm", nvvm_add_rn_d},
      {"__builtin_altivec_dss", "ppc", ppc_altivec_dss},
      {"__builtin_riscv_sha512sum1r", "riscv", riscv_sha512sum1r},
      {"__builtin_tend", "s390", s390_tend},
      {"__builtin_ia32_pause", "x86", x86_sse2_pause},

      {"__does_not_exist", "", not_intrinsic},
      {"__does_not_exist", "arm", not_intrinsic},
      {"__builtin_arm_cdp", "", not_intrinsic},
      {"__builtin_arm_cdp", "x86", not_intrinsic},
  };

  for (const auto &[Builtin, Target, ID] : ClangTests)
    EXPECT_EQ(ID, getIntrinsicForClangBuiltin(Target, Builtin));
}

// Tests to verify getIntrinsicForMSBuiltin.
TEST(IntrinsicNameLookup, MSBuiltinLookup) {
  using namespace Intrinsic;
  static constexpr std::tuple<StringRef, StringRef, ID> MSTests[] = {
      {"__dmb", "aarch64", aarch64_dmb},
      {"__dmb", "arm", arm_dmb},
      {"__dmb", "", not_intrinsic},
      {"__does_not_exist", "", not_intrinsic},
      {"__does_not_exist", "arm", not_intrinsic},
  };
  for (const auto &[Builtin, Target, ID] : MSTests)
    EXPECT_EQ(ID, getIntrinsicForMSBuiltin(Target, Builtin));
}

TEST_F(IntrinsicsTest, InstrProfInheritance) {
  auto isInstrProfInstBase = [](const Instruction &I) {
    return isa<InstrProfInstBase>(I);
  };
#define __ISA(TYPE, PARENT)                                                    \
  auto is##TYPE = [&](const Instruction &I) -> bool {                          \
    return isa<TYPE>(I) && is##PARENT(I);                                      \
  }
  __ISA(InstrProfCntrInstBase, InstrProfInstBase);
  __ISA(InstrProfCoverInst, InstrProfCntrInstBase);
  __ISA(InstrProfIncrementInst, InstrProfCntrInstBase);
  __ISA(InstrProfIncrementInstStep, InstrProfIncrementInst);
  __ISA(InstrProfCallsite, InstrProfCntrInstBase);
  __ISA(InstrProfTimestampInst, InstrProfCntrInstBase);
  __ISA(InstrProfValueProfileInst, InstrProfCntrInstBase);
  __ISA(InstrProfMCDCBitmapInstBase, InstrProfInstBase);
  __ISA(InstrProfMCDCBitmapParameters, InstrProfMCDCBitmapInstBase);
  __ISA(InstrProfMCDCTVBitmapUpdate, InstrProfMCDCBitmapInstBase);
#undef __ISA

  std::vector<
      std::pair<Intrinsic::ID, std::function<bool(const Instruction &)>>>
      LeafIDs = {
          {Intrinsic::instrprof_cover, isInstrProfCoverInst},
          {Intrinsic::instrprof_increment, isInstrProfIncrementInst},
          {Intrinsic::instrprof_increment_step, isInstrProfIncrementInstStep},
          {Intrinsic::instrprof_callsite, isInstrProfCallsite},
          {Intrinsic::instrprof_mcdc_parameters,
           isInstrProfMCDCBitmapParameters},
          {Intrinsic::instrprof_mcdc_tvbitmap_update,
           isInstrProfMCDCTVBitmapUpdate},
          {Intrinsic::instrprof_timestamp, isInstrProfTimestampInst},
          {Intrinsic::instrprof_value_profile, isInstrProfValueProfileInst}};
  for (const auto &[ID, Checker] : LeafIDs) {
    auto *Intr = makeIntrinsic(ID);
    EXPECT_TRUE(Checker(*Intr));
  }
}

} // end namespace
