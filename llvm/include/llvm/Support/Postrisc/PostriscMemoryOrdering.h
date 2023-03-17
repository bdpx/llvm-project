//===---------------- PostriscMemoryOrdering.h --*- C++ -*-----------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_SUPPORT_POSTRISC_MEMORY_ORDERING_H
#define LLVM_SUPPORT_POSTRISC_MEMORY_ORDERING_H

#include "llvm/ADT/StringRef.h"
#include "llvm/ADT/StringSwitch.h"

namespace llvm {
namespace postrisc {

enum MemoryOrdering {
  RELAXED = 0,
  ACQUIRE = 1,
  RELEASE = 2,
  ACQ_REL = 3,
  SEQ_CST = 7,
  MO_INVALID // FIXME
};

inline static StringRef memoryOrderingToString(MemoryOrdering RndMode) {
  switch (RndMode) {
  default:
    llvm_unreachable("Unknown memory ordering");
  case llvm::postrisc::RELAXED: return "relaxed";
  case llvm::postrisc::ACQUIRE: return "acquire";
  case llvm::postrisc::RELEASE: return "release";
  case llvm::postrisc::ACQ_REL: return "acq_rel";
  case llvm::postrisc::SEQ_CST: return "seq_cst";
  }
}

inline static MemoryOrdering stringToMemoryOrdering(StringRef Str) {
  return StringSwitch<MemoryOrdering>(Str)
      .Case("relaxed", llvm::postrisc::RELAXED)
      .Case("acquire", llvm::postrisc::ACQUIRE)
      .Case("release", llvm::postrisc::RELEASE)
      .Case("acq_rel", llvm::postrisc::ACQ_REL)
      .Case("seq_cst", llvm::postrisc::SEQ_CST)
      .Default(llvm::postrisc::MO_INVALID);
}

inline static bool isValidMemoryOrdering(unsigned Mode) {
  switch (Mode) {
  default:
    return false;
  case llvm::postrisc::RELAXED:
  case llvm::postrisc::ACQUIRE:
  case llvm::postrisc::RELEASE:
  case llvm::postrisc::ACQ_REL:
  case llvm::postrisc::SEQ_CST:
    return true;
  }
}

}}  // end namespace llvm::postrisc

#endif
