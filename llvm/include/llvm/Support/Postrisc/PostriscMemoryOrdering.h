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
namespace MemoryOrdering {

#define GET_MemoryOrdering_DECL
#include "PostriscGenSearchableTables.inc"
#undef GET_MemoryOrdering_DECL

using Type = MemoryOrdering;

inline static StringRef toString(Type RndMode) {
  switch (RndMode) {
  case RELAXED: return "relaxed";
  case ACQUIRE: return "acquire";
  case RELEASE: return "release";
  case ACQ_REL: return "acq_rel";
  case SEQ_CST: return "seq_cst";
  }
  llvm_unreachable("Unknown memory ordering");
  return "!invalid_mo";
}

inline static std::optional<Type> toEnum(StringRef Str) {
  return StringSwitch<std::optional<Type>>(Str)
      .Case("relaxed", RELAXED)
      .Case("acquire", ACQUIRE)
      .Case("release", RELEASE)
      .Case("acq_rel", ACQ_REL)
      .Case("seq_cst", SEQ_CST)
      .Default(std::nullopt);
}

inline static bool isValid(unsigned Mode) {
  switch (Mode) {
  case RELAXED:
  case ACQUIRE:
  case RELEASE:
  case ACQ_REL:
  case SEQ_CST:
    return true;
  }
  return false;
}

}}} // end namespace llvm::postrisc::MemoryOrdering

#endif
