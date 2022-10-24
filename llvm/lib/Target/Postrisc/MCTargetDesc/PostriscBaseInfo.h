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
#include "llvm/Support/Postrisc/PostriscBundle.h"
#include "llvm/Support/Postrisc/PostriscRoundingMode.h"
#include "llvm/Support/Postrisc/PostriscMemoryOrdering.h"

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
#define GET_RoundingMode_DECL
#include "PostriscGenSearchableTables.inc"
#undef GET_RoundingMode_DECL
} // namespace PostriscFPRndMode

static_assert(static_cast<int>(llvm::postrisc::RM_RNE) == static_cast<int>(PostriscFPRndMode::RNE));
static_assert(static_cast<int>(llvm::postrisc::RM_RTZ) == static_cast<int>(PostriscFPRndMode::RTZ));
static_assert(static_cast<int>(llvm::postrisc::RM_RDN) == static_cast<int>(PostriscFPRndMode::RDN));
static_assert(static_cast<int>(llvm::postrisc::RM_RUP) == static_cast<int>(PostriscFPRndMode::RUP));
static_assert(static_cast<int>(llvm::postrisc::RM_RMM) == static_cast<int>(PostriscFPRndMode::RMM));
static_assert(static_cast<int>(llvm::postrisc::RM_RNO) == static_cast<int>(PostriscFPRndMode::RNO));
static_assert(static_cast<int>(llvm::postrisc::RM_RTO) == static_cast<int>(PostriscFPRndMode::RTO));
static_assert(static_cast<int>(llvm::postrisc::RM_DYN) == static_cast<int>(PostriscFPRndMode::DYN));

// Describes the supported floating point rounding mode encodings.
namespace PostriscMemoryOrdering {
#define GET_MemoryOrdering_DECL
#include "PostriscGenSearchableTables.inc"
#undef GET_MemoryOrdering_DECL
} // namespace PostriscMemoryOrdering


// Mask assignments for floating-point.
namespace FClassMask {
#define GET_FpClassifyFlag_DECL
#include "PostriscGenSearchableTables.inc"
#undef GET_FpClassifyFlag_DECL
} // namespace FClassMask


// PostriscII - this namespace holds all of the target specific flags that instruction info tracks.
namespace PostriscII {
  enum {
    POSTRISC_IS_LONG               = 0x01,
    POSTRISC_IS_POST_INC           = 0x02,
    POSTRISC_IS_PRE_INC            = 0x04,
    POSTRISC_IS_INDEXED_MEM_ACCESS = 0x08,
    POSTRISC_IS_BASE_MEM_ACCESS    = 0x10,
  };

  inline bool isLong             (uint64_t TSFlags) { return (TSFlags & POSTRISC_IS_LONG) != 0; }
  inline bool isPostIncrement    (uint64_t TSFlags) { return (TSFlags & POSTRISC_IS_POST_INC) != 0; }
  inline bool isPreIncrement     (uint64_t TSFlags) { return (TSFlags & POSTRISC_IS_PRE_INC) != 0; }
  inline bool isIndexedMemAccess (uint64_t TSFlags) { return (TSFlags & POSTRISC_IS_INDEXED_MEM_ACCESS) != 0;}
  inline bool isBaseMemAccess    (uint64_t TSFlags) { return (TSFlags & POSTRISC_IS_BASE_MEM_ACCESS) != 0; }
} // namespace PostriscII

} // namespace llvm

#endif
