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
#include "llvm/TargetParser/PostriscTargetParser.h"
#include "llvm/TargetParser/Triple.h"
namespace clang {
namespace targets {
// Shared base class for Postrisc.
class LLVM_LIBRARY_VISIBILITY PostriscTargetInfo : public TargetInfo {
  static const TargetInfo::GCCRegAlias GCCRegAliases[];
  static const char *const GCCRegNames[];
  bool SoftFloat;

protected:
  // Features of the CPU and target features, as defined by the backend.
  bool IsV2 = false;

public:
  PostriscTargetInfo(const llvm::Triple &Triple, const TargetOptions &)
      : TargetInfo(Triple), SoftFloat(false)
  {
    HasFloat16 = true;
    HasFloat128 = true;
    HasBFloat16 = false;
    HasFastHalfType = true;
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

  bool
  initFeatureMap(llvm::StringMap<bool> &Features, DiagnosticsEngine &Diags,
                 StringRef CPU,
                 const std::vector<std::string> &FeaturesVec) const override;

  bool handleTargetFeatures(std::vector<std::string> &Features,
                            DiagnosticsEngine &Diags) override;
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

  bool isValidCPUName(StringRef Name) const override;

  void fillValidCPUList(SmallVectorImpl<StringRef> &Values) const override;

  bool setCPU(StringRef Name) override { return isValidCPUName(Name); }

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

  bool isValidCPUName(StringRef Name) const override;

  void fillValidCPUList(SmallVectorImpl<StringRef> &Values) const override;

  bool hasBitIntType() const override { return true; }
};
} // namespace targets
} // namespace clang
#endif // LLVM_CLANG_LIB_BASIC_TARGETS_POSTRISC_H
