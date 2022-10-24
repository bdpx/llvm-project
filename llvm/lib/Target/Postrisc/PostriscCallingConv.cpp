//===---- PostriscCallingConv.cpp - Postrisc CC impl ------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains the table-generated and custom routines for the Postrisc
// Calling Convention.
//
//===----------------------------------------------------------------------===//

#include "PostriscCallingConv.h"
#include "Postrisc.h"
#include "PostriscInstrInfo.h"
#include "PostriscSubtarget.h"
#include "llvm/CodeGen/CallingConvLower.h"
#include "llvm/CodeGen/TargetInstrInfo.h"
#include "llvm/IR/CallingConv.h"
using namespace llvm;


//===----------------------------------------------------------------------===//
// Calling Convention Implementation
//===----------------------------------------------------------------------===//
static bool
IsSupportedType(const MVT &LocVT)
{
  for (auto VT : { MVT::i1, MVT::i32, MVT::i64, MVT::i128,
                   MVT::f32, MVT::f64, MVT::f128,
                   MVT::v4f32, MVT::v2f64,
                   MVT::v2i64, MVT::v4i32, MVT::v8i16, MVT::v16i8 }) {
      if (LocVT == VT) return true;
  }
  return false;
}

// TableGen provides definitions of the calling convention analysis entry
// points.
#include "PostriscGenCallingConv.inc"
