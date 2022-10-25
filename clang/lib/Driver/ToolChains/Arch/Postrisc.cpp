//===--- Postrisc.cpp - Tools Implementations -------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "Postrisc.h"
#include "clang/Driver/Driver.h"
#include "clang/Driver/DriverDiagnostic.h"
#include "clang/Options/Options.h"
#include "llvm/ADT/StringSwitch.h"
#include "llvm/Option/ArgList.h"
#include "llvm/TargetParser/Host.h"

using namespace clang::driver;
using namespace clang::driver::tools;
using namespace clang;
using namespace llvm::opt;

const char *
postrisc::getPostriscAsmModeForCPU(StringRef Name, const llvm::Triple &Triple)
{
  assert(Triple.getArch() == llvm::Triple::postrisc);
  return llvm::StringSwitch<const char *>(Name)
      .Case("pv1", "-pv1")
      .Case("pv2", "-pv2")
      .Case("postrisc", "-postrisc")
      .Default("-generic");
}

postrisc::FloatABI
postrisc::getPostriscFloatABI(const Driver &D, const ArgList &Args)
{
  postrisc::FloatABI ABI = postrisc::FloatABI::Invalid;
  if (Arg *A = Args.getLastArg(options::OPT_msoft_float,
                               options::OPT_mhard_float,
                               options::OPT_mfloat_abi_EQ)) {
    if (A->getOption().matches(options::OPT_msoft_float))
      ABI = postrisc::FloatABI::Soft;
    else if (A->getOption().matches(options::OPT_mhard_float))
      ABI = postrisc::FloatABI::Hard;
    else {
      ABI = llvm::StringSwitch<postrisc::FloatABI>(A->getValue())
                .Case("soft", postrisc::FloatABI::Soft)
                .Case("hard", postrisc::FloatABI::Hard)
                .Default(postrisc::FloatABI::Invalid);
      if (ABI == postrisc::FloatABI::Invalid &&
          !StringRef(A->getValue()).empty()) {
        D.Diag(clang::diag::err_drv_invalid_mfloat_abi) << A->getAsString(Args);
        ABI = postrisc::FloatABI::Hard;
      }
    }
  }

  // If unspecified, choose the default based on the platform.
  // Only the hard-float ABI on Postrisc is standardized, and it is the
  // default. GCC also supports a nonstandard soft-float ABI mode, also
  // implemented in LLVM. However as this is not standard we set the default
  // to be hard-float.
  if (ABI == postrisc::FloatABI::Invalid) {
    ABI = postrisc::FloatABI::Hard;
  }

  return ABI;
}

std::string postrisc::getPostriscTargetCPU(const Driver &D, const ArgList &Args,
                                     const llvm::Triple &Triple) {
  if (const Arg *A = Args.getLastArg(options::OPT_mcpu_EQ)) {
    StringRef CPUName = A->getValue();
    if (CPUName == "native") {
      std::string CPU = std::string(llvm::sys::getHostCPUName());
      if (!CPU.empty() && CPU != "generic")
        return CPU;
      return "";
    }
    return std::string(CPUName);
  }

  if (Triple.getArch() == llvm::Triple::postrisc && Triple.isOSSolaris())
    return "v9";
  return "";
}

void
postrisc::getPostriscTargetFeatures(const Driver &D, const ArgList &Args,
  std::vector<StringRef> &Features)
{
  postrisc::FloatABI FloatABI = postrisc::getPostriscFloatABI(D, Args);
  if (FloatABI == postrisc::FloatABI::Soft)
    Features.push_back("+soft-float");

  if (Arg *A = Args.getLastArg(options::OPT_mv8plus, options::OPT_mno_v8plus)) {
    if (A->getOption().matches(options::OPT_mv8plus)) {
      Features.push_back("+v8plus");
    }
  }

}
