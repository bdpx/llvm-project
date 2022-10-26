//===--- Postrisc.h - declare Postrisc target feature support ---*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file declares Postrisc TargetInfo objects.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CLANG_LIB_BASIC_TARGETS_POSTRISC_H
#define LLVM_CLANG_LIB_BASIC_TARGETS_POSTRISC_H
#include "clang/Basic/TargetInfo.h"
#include "clang/Basic/TargetOptions.h"
#include "llvm/Support/Compiler.h"
#include "llvm/TargetParser/Triple.h"
namespace clang {
namespace targets {
// Shared base class for Postrisc.
class LLVM_LIBRARY_VISIBILITY PostriscTargetInfo : public TargetInfo {
  static const TargetInfo::GCCRegAlias GCCRegAliases[];
  static const char *const GCCRegNames[];
  bool SoftFloat;

public:
  PostriscTargetInfo(const llvm::Triple &Triple, const TargetOptions &)
      : TargetInfo(Triple), SoftFloat(false)
  {
    HasFloat16 = true;
    HasFloat128 = true;
    HasBFloat16 = false;
    // FIXME: next crashes
    // HasStrictFP = true;
    // HasLegalHalfType = true;
    // HalfArgsAndReturns = true;
  }

  int getEHDataRegisterNumber(unsigned RegNo) const override {
    if (RegNo == 0)
      return 24;
    if (RegNo == 1)
      return 25;
    return -1;
  }

  bool handleTargetFeatures(std::vector<std::string> &Features,
                            DiagnosticsEngine &Diags) override {
    // Check if software floating point is enabled
    if (llvm::is_contained(Features, "+soft-float"))
      SoftFloat = true;
    return true;
  }
  void getTargetDefines(const LangOptions &Opts,
                        MacroBuilder &Builder) const override;

  bool hasFeature(StringRef Feature) const override;

  bool hasSjLjLowering() const override { return true; }

  llvm::SmallVector<Builtin::InfosShard> getTargetBuiltins() const override;

  BuiltinVaListKind getBuiltinVaListKind() const override {
    return TargetInfo::VoidPtrBuiltinVaList;
  }
  ArrayRef<const char *> getGCCRegNames() const override;
  ArrayRef<TargetInfo::GCCRegAlias> getGCCRegAliases() const override;
  bool validateAsmConstraint(const char *&Name,
                             TargetInfo::ConstraintInfo &info) const override;

  std::string_view getClobbers() const override;

  enum CPUKind {
    CK_GENERIC,
    CK_V1,
    CK_V2,
  } CPU = CK_GENERIC;

  enum CPUGeneration {
    CG_V1,
    CG_V2,
  };

  CPUGeneration getCPUGeneration(CPUKind Kind) const;

  CPUKind getCPUKind(StringRef Name) const;

  bool isValidCPUName(StringRef Name) const override {
    return getCPUKind(Name) != CK_GENERIC;
  }

  void fillValidCPUList(SmallVectorImpl<StringRef> &Values) const override;

  bool setCPU(const std::string &Name) override {
    CPU = getCPUKind(Name);
    return CPU != CK_GENERIC;
  }

  std::pair<unsigned, unsigned> hardwareInterferenceSizes() const override {
    return std::make_pair(64, 64);
  }
};

// POSTRISC v1 is the 64-bit mode selected by Triple::Postrisc.
class LLVM_LIBRARY_VISIBILITY PostriscV1TargetInfo : public PostriscTargetInfo {
public:
  PostriscV1TargetInfo(const llvm::Triple &Triple, const TargetOptions &Opts);

  void getTargetDefines(const LangOptions &Opts,
                        MacroBuilder &Builder) const override;

  bool isValidCPUName(StringRef Name) const override {
    return getCPUGeneration(PostriscTargetInfo::getCPUKind(Name)) == CG_V1;
  }

  void fillValidCPUList(SmallVectorImpl<StringRef> &Values) const override;

  bool setCPU(const std::string &Name) override {
    if (!PostriscTargetInfo::setCPU(Name))
      return false;
    return getCPUGeneration(CPU) == CG_V1;
  }

  bool hasBitIntType() const override { return true; }
  // bool hasExtIntType() const override { return true; }
};
} // namespace targets
} // namespace clang
#endif // LLVM_CLANG_LIB_BASIC_TARGETS_POSTRISC_H
