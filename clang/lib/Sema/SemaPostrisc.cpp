//===------ SemaPostrisc.cpp ---- Postrisc target-specific routines -----===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
//  This file implements semantic analysis functions specific to Postrisc.
//
//===----------------------------------------------------------------------===//

#include "clang/Sema/SemaPostrisc.h"
#include "clang/Basic/TargetBuiltins.h"
#include "clang/Sema/Sema.h"
#include "llvm/Support/MathExtras.h"

namespace clang {

SemaPostrisc::SemaPostrisc(Sema &S) : SemaBase(S) {}

bool SemaPostrisc::CheckPostriscBuiltinFunctionCall(const TargetInfo &TI,
                                            unsigned BuiltinID, CallExpr *TheCall) {
  // default: ok
  return false;
}

} // namespace clang
