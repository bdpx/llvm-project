//===----------------- PostriscRoundingMode.h --*- C++ -*------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_SUPPORT_POSTRISC_ROUNDING_MODE_H
#define LLVM_SUPPORT_POSTRISC_ROUNDING_MODE_H

#include "llvm/ADT/StringRef.h"
#include "llvm/ADT/StringSwitch.h"

namespace llvm {
namespace postrisc {
namespace RoundingMode {

#define GET_RoundingMode_DECL
#include "PostriscGenSearchableTables.inc"
#undef GET_RoundingMode_DECL

using Type = RoundingMode;

inline static StringRef toString(Type RndMode) {
  switch (RndMode) {
  case RM_RNE:  return "rne";
  case RM_RTZ:  return "rtz";
  case RM_RDN:  return "rdn";
  case RM_RUP:  return "rup";
  case RM_RMM:  return "rmm";
  case RM_RNO:  return "rno";
  case RM_RTO:  return "rto";
  case RM_DYN:  return "dyn";
  }
  llvm_unreachable("Unknown floating point rounding mode");
  return "!invalid_rm";
}

inline static std::optional<Type> toEnum(StringRef Str) {
  return StringSwitch<std::optional<Type>>(Str)
      .Case("rne", RM_RNE)
      .Case("rtz", RM_RTZ)
      .Case("rdn", RM_RDN)
      .Case("rup", RM_RUP)
      .Case("rmm", RM_RMM)
      .Case("rno", RM_RNO)
      .Case("rto", RM_RTO)
      .Case("dyn", RM_DYN)
      .Default(std::nullopt);
}

inline static bool isValid(unsigned Mode) {
  switch (Mode) {
  case RM_RNE:
  case RM_RTZ:
  case RM_RDN:
  case RM_RUP:
  case RM_RMM:
  case RM_RNO:
  case RM_RTO:
  case RM_DYN:
    return true;
  }
  return false;
}

}}}  // end namespace llvm::postrisc::RoundingMode

#endif
