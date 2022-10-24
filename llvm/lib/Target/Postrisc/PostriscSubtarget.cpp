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
#include "PostriscSelectionDAGInfo.h"
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
  const Triple &TT = getTargetTriple();
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
                               const StringRef &FS, const TargetMachine &TM)
    : PostriscGenSubtargetInfo(TM.getTargetTriple(), CPU, TuneCPU, FS),
      InstrInfo(initializeSubtargetDependencies(CPU, TuneCPU, FS)),
      TLInfo(TM, *this), FrameLowering(*this) {
  TSInfo = std::make_unique<PostriscSelectionDAGInfo>();
}

PostriscSubtarget::~PostriscSubtarget() = default;

const SelectionDAGTargetInfo *PostriscSubtarget::getSelectionDAGInfo() const {
  return TSInfo.get();
}

void PostriscSubtarget::initLibcallLoweringInfo(LibcallLoweringInfo &Info) const {
  return;

  // FIXME: setup Runtime library names.
  if (!useSoftFloat()) {
    Info.setLibcallImpl(RTLIB::SQRT_F128, RTLIB::impl__Qp_sqrt);
    Info.setLibcallImpl(RTLIB::FPTOSINT_F128_I32, RTLIB::impl__Qp_qtoi);
    Info.setLibcallImpl(RTLIB::FPTOUINT_F128_I32, RTLIB::impl__Qp_qtoui);
    Info.setLibcallImpl(RTLIB::SINTTOFP_I32_F128, RTLIB::impl__Qp_itoq);
    Info.setLibcallImpl(RTLIB::UINTTOFP_I32_F128, RTLIB::impl__Qp_uitoq);
    Info.setLibcallImpl(RTLIB::FPTOSINT_F128_I64, RTLIB::impl__Qp_qtox);
    Info.setLibcallImpl(RTLIB::FPTOUINT_F128_I64, RTLIB::impl__Qp_qtoux);
    Info.setLibcallImpl(RTLIB::SINTTOFP_I64_F128, RTLIB::impl__Qp_xtoq);
    Info.setLibcallImpl(RTLIB::UINTTOFP_I64_F128, RTLIB::impl__Qp_uxtoq);
    Info.setLibcallImpl(RTLIB::FPEXT_F32_F128, RTLIB::impl__Qp_stoq);
    Info.setLibcallImpl(RTLIB::FPEXT_F64_F128, RTLIB::impl__Qp_dtoq);
    Info.setLibcallImpl(RTLIB::FPROUND_F128_F32, RTLIB::impl__Qp_qtos);
    Info.setLibcallImpl(RTLIB::FPROUND_F128_F64, RTLIB::impl__Qp_qtod);
  }
}

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
