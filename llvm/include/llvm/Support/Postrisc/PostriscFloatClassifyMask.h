//===-------------- PostriscFloatClassifyMask.h --*- C++ -*----------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_SUPPORT_POSTRISC_FLOAT_CLASSIFY_MASK_H
#define LLVM_SUPPORT_POSTRISC_FLOAT_CLASSIFY_MASK_H

#include "llvm/ADT/StringRef.h"
#include "llvm/ADT/StringSwitch.h"

namespace llvm {
namespace postrisc {
namespace FClassMask {

#define GET_FpClassifyFlag_DECL
#include "PostriscGenSearchableTables.inc"
#undef GET_FpClassifyFlag_DECL

}}} // end namespace llvm::postrisc::FClassMask

#endif
