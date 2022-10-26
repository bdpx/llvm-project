//===-- SemaPostrisc.h -- Postrisc target-specific routines --*- C++ -*----===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
/// \file
/// This file declares semantic analysis functions specific to Postrisc.
///
//===----------------------------------------------------------------------===//

#ifndef LLVM_CLANG_SEMA_SEMAPOSTRISC_H
#define LLVM_CLANG_SEMA_SEMAPOSTRISC_H

#include "clang/AST/Expr.h"
#include "clang/Basic/TargetInfo.h"
#include "clang/Sema/SemaBase.h"

namespace clang {
class SemaPostrisc : public SemaBase {
public:
  SemaPostrisc(Sema &S);

  bool CheckPostriscBuiltinFunctionCall(const TargetInfo &TI,
                                        unsigned BuiltinID, CallExpr *TheCall);
};
} // namespace clang

#endif // LLVM_CLANG_SEMA_SEMAPOSTRISC_H
