//===-- PostriscSubtarget.cpp - POSTRISC Subtarget Information ------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements the POSTRISC specific subclass of TargetSubtargetInfo.
//
//===----------------------------------------------------------------------===//

#include "PostriscSubtarget.h"
#include "Postrisc.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/Support/MathExtras.h"

using namespace llvm;

#define DEBUG_TYPE "postrisc-subtarget"

#define GET_SUBTARGETINFO_TARGET_DESC
#define GET_SUBTARGETINFO_CTOR
#include "PostriscGenSubtargetInfo.inc"

void PostriscSubtarget::anchor() { }

PostriscSubtarget &PostriscSubtarget::initializeSubtargetDependencies(
    StringRef CPU, StringRef TuneCPU, StringRef FS) {
  // Determine default and user specified characteristics
  std::string CPUName = std::string(CPU);
  if (CPUName.empty())
    CPUName = "pv1";

  if (TuneCPU.empty())
    TuneCPU = CPUName;

  // Parse features string.
  ParseSubtargetFeatures(CPUName, TuneCPU, FS);

  return *this;
}

PostriscSubtarget::PostriscSubtarget(const StringRef &CPU, const StringRef &TuneCPU,
                               const StringRef &FS, const TargetMachine &TM,
                               bool is64Bit)
    : PostriscGenSubtargetInfo(TM.getTargetTriple(), CPU, TuneCPU, FS),
      TargetTriple(TM.getTargetTriple()), Is64Bit(is64Bit),
      InstrInfo(initializeSubtargetDependencies(CPU, TuneCPU, FS)),
      TLInfo(TM, *this), FrameLowering(*this) {}

int PostriscSubtarget::getAdjustedFrameSize(int frameSize) const {
  // All 64-bit stack frames must be 16-byte aligned, and must reserve space
  // for 6 outgoing arguments at %sp+BIAS..%sp+BIAS+128.
  // whether they are used or not. LowerCall_64 takes care of that.
  frameSize = alignTo(frameSize, 16);
  return frameSize;
}

bool PostriscSubtarget::enableMachineScheduler() const {
  return true;
}
