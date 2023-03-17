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

enum RoundingMode {
  RM_RNE = 0,
  RM_RTZ = 1,
  RM_RDN = 2,
  RM_RUP = 3,
  RM_RMM = 4,
  RM_RNO = 5,
  RM_RTO = 6,
  RM_DYN = 7,
  RM_INVALID // FIXME
};

inline static StringRef roundingModeToString(llvm::postrisc::RoundingMode RndMode) {
  switch (RndMode) {
  default:
    llvm_unreachable("Unknown floating point rounding mode");
  case llvm::postrisc::RM_RNE:  return "rne";
  case llvm::postrisc::RM_RTZ:  return "rtz";
  case llvm::postrisc::RM_RDN:  return "rdn";
  case llvm::postrisc::RM_RUP:  return "rup";
  case llvm::postrisc::RM_RMM:  return "rmm";
  case llvm::postrisc::RM_RNO:  return "rno";
  case llvm::postrisc::RM_RTO:  return "rto";
  case llvm::postrisc::RM_DYN:  return "dyn";
  }
}

inline static llvm::postrisc::RoundingMode stringToRoundingMode(StringRef Str) {
  return StringSwitch<llvm::postrisc::RoundingMode>(Str)
      .Case("rne", llvm::postrisc::RM_RNE)
      .Case("rtz", llvm::postrisc::RM_RTZ)
      .Case("rdn", llvm::postrisc::RM_RDN)
      .Case("rup", llvm::postrisc::RM_RUP)
      .Case("rmm", llvm::postrisc::RM_RMM)
      .Case("rno", llvm::postrisc::RM_RNO)
      .Case("rto", llvm::postrisc::RM_RTO)
      .Case("dyn", llvm::postrisc::RM_DYN)
      .Default(llvm::postrisc::RM_INVALID);
}

inline static bool isValidRoundingMode(unsigned Mode) {
  switch (Mode) {
  default:
    return false;
  case llvm::postrisc::RM_RNE:
  case llvm::postrisc::RM_RTZ:
  case llvm::postrisc::RM_RDN:
  case llvm::postrisc::RM_RUP:
  case llvm::postrisc::RM_RMM:
  case llvm::postrisc::RM_RNO:
  case llvm::postrisc::RM_RTO:
  case llvm::postrisc::RM_DYN:
    return true;
  }
}

}}  // end namespace llvm::postrisc

#endif
