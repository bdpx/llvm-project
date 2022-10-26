//===--  PostriscTargetParser.cpp - Parser for Postrisc target features --===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements a target parser to recognise hardware features
// for Postrisc CPUs.
//
//===----------------------------------------------------------------------===//

#include "llvm/TargetParser/PostriscTargetParser.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/TargetParser/TargetParser.h"

#define GET_SUBTARGETFEATURES_ENUM
#define GET_SUBTARGETFEATURES_KV
#include "llvm/TargetParser/PostriscGenTargetFeatures.inc"

namespace llvm {
namespace Postrisc {

bool isValidCPU(StringRef CPU) {
  ArrayRef<BasicSubtargetSubTypeKV> A = BasicPostriscSubTypeKV;
  const BasicSubtargetSubTypeKV *P = llvm::lower_bound(A, CPU);
  return P != A.end() && StringRef(P->Key) == CPU;
}

void fillValidCPUList(SmallVectorImpl<StringRef> &Values) {
  for (const BasicSubtargetSubTypeKV &P : BasicPostriscSubTypeKV)
    Values.emplace_back(P.Key);
}

StringRef getNormalizedPostriscTargetCPU(const Triple &T, StringRef CPUName) {
  if (!CPUName.empty())
    return CPUName;
  return "v1";
}

std::optional<StringMap<bool>> getPostriscDefaultTargetFeatures(StringRef CPU) {
  return getCPUDefaultTargetFeatures(CPU, BasicPostriscSubTypeKV,
                                     BasicPostriscFeatureKV);
}

bool isValidFeatureName(StringRef Name) {
  ArrayRef<BasicSubtargetFeatureKV> A = BasicPostriscFeatureKV;
  const BasicSubtargetFeatureKV *F = llvm::lower_bound(A, Name);
  return F != A.end() && StringRef(F->Key) == Name;
}

} // namespace Postrisc
} // namespace llvm
