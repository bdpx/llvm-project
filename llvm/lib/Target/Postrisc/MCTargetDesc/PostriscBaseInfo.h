//===- PostriscBaseInfo.h - Top level definitions for Postrisc MC *- C++ -===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains small standalone enum definitions for the Postrisc target
// useful for the compiler back-end and the MC libraries.
// WARNING: enumeration should be synced with emulator!
//
//===----------------------------------------------------------------------===//
#ifndef LLVM_LIB_TARGET_POSTRISC_MCTARGETDESC_POSTRISCBASEINFO_H
#define LLVM_LIB_TARGET_POSTRISC_MCTARGETDESC_POSTRISCBASEINFO_H

#include "MCTargetDesc/PostriscMCTargetDesc.h"
#include "llvm/ADT/APFloat.h"
#include "llvm/ADT/APInt.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/ADT/StringSwitch.h"
#include "llvm/MC/MCInstrDesc.h"

namespace llvm {

namespace PostriscOp {

enum OperandType : unsigned {
  OPERAND_FIRST_POSTRISC = MCOI::OPERAND_FIRST_TARGET,
  OPERAND_FRMARG = OPERAND_FIRST_POSTRISC,
  OPERAND_MEMORY_ORDERING,
};
} // namespace PostriscOp

// Describes the supported floating point rounding mode encodings.
namespace PostriscFPRndMode {
// #define GET_RoundingMode_DECL
// #include "PostriscGenSearchableTables.inc"
// #undef GET_RoundingMode_DECL
enum RoundingMode {
  RNE = 0,
  RTZ = 1,
  RDN = 2,
  RUP = 3,
  RMM = 4,
  DYN = 7,
  Invalid // FIXME
};

inline static StringRef roundingModeToString(RoundingMode RndMode) {
  switch (RndMode) {
  default:
    llvm_unreachable("Unknown floating point rounding mode");
  case PostriscFPRndMode::RNE:  return "rne";
  case PostriscFPRndMode::RTZ:  return "rtz";
  case PostriscFPRndMode::RDN:  return "rdn";
  case PostriscFPRndMode::RUP:  return "rup";
  case PostriscFPRndMode::RMM:  return "rmm";
  case PostriscFPRndMode::DYN:  return "dyn";
  }
}

inline static RoundingMode stringToRoundingMode(StringRef Str) {
  return StringSwitch<RoundingMode>(Str)
      .Case("rne", PostriscFPRndMode::RNE)
      .Case("rtz", PostriscFPRndMode::RTZ)
      .Case("rdn", PostriscFPRndMode::RDN)
      .Case("rup", PostriscFPRndMode::RUP)
      .Case("rmm", PostriscFPRndMode::RMM)
      .Case("dyn", PostriscFPRndMode::DYN)
      .Default(PostriscFPRndMode::Invalid);
}

inline static bool isValidRoundingMode(unsigned Mode) {
  switch (Mode) {
  default:
    return false;
  case PostriscFPRndMode::RNE:
  case PostriscFPRndMode::RTZ:
  case PostriscFPRndMode::RDN:
  case PostriscFPRndMode::RUP:
  case PostriscFPRndMode::RMM:
  case PostriscFPRndMode::DYN:
    return true;
  }
}
} // namespace PostriscFPRndMode


// Describes the supported floating point rounding mode encodings.
namespace PostriscMemoryOrdering {
// #define GET_MemoryOrdering_DECL
// #include "PostriscGenSearchableTables.inc"
// #undef GET_MemoryOrdering_DECL
enum MemoryOrdering {
  RELAXED = 0,
  ACQUIRE = 1,
  RELEASE = 2,
  ACQ_REL = 3,
  SEQ_CST = 7,
  Invalid // FIXME
};

inline static StringRef memoryOrderingToString(MemoryOrdering RndMode) {
  switch (RndMode) {
  default:
    llvm_unreachable("Unknown memory ordering");
  case PostriscMemoryOrdering::RELAXED: return "relaxed";
  case PostriscMemoryOrdering::ACQUIRE: return "acquire";
  case PostriscMemoryOrdering::RELEASE: return "release";
  case PostriscMemoryOrdering::ACQ_REL: return "acq_rel";
  case PostriscMemoryOrdering::SEQ_CST: return "seq_cst";
  }
}

inline static MemoryOrdering stringToMemoryOrdering(StringRef Str) {
  return StringSwitch<MemoryOrdering>(Str)
      .Case("relaxed", PostriscMemoryOrdering::RELAXED)
      .Case("acquire", PostriscMemoryOrdering::ACQUIRE)
      .Case("release", PostriscMemoryOrdering::RELEASE)
      .Case("acq_rel", PostriscMemoryOrdering::ACQ_REL)
      .Case("seq_cst", PostriscMemoryOrdering::SEQ_CST)
      .Default(PostriscMemoryOrdering::Invalid);
}

inline static bool isValidMemoryOrdering(unsigned Mode) {
  switch (Mode) {
  default:
    return false;
  case PostriscMemoryOrdering::RELAXED:
  case PostriscMemoryOrdering::ACQUIRE:
  case PostriscMemoryOrdering::RELEASE:
  case PostriscMemoryOrdering::ACQ_REL:
  case PostriscMemoryOrdering::SEQ_CST:
    return true;
  }
}
} // namespace PostriscMemoryOrdering


namespace Postrisc {
// Mask assignments for floating-point.

namespace FClassMask {
#define GET_FpClassifyFlag_DECL
#include "PostriscGenSearchableTables.inc"
#undef GET_FpClassifyFlag_DECL
} // namespace FClassMask
} // namespace Postrisc

} // namespace llvm

#endif
