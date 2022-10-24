//===-- PostriscMCTargetDesc.cpp - Postrisc Target Descriptions -----------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file provides Postrisc specific target descriptions.
//
//===----------------------------------------------------------------------===//

#include "PostriscMCTargetDesc.h"
#include "PostriscInstPrinter.h"
#include "PostriscMCAsmInfo.h"
#include "PostriscTargetStreamer.h"
#include "TargetInfo/PostriscTargetInfo.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/Support/Compiler.h"
#include "llvm/Support/ErrorHandling.h"

using namespace llvm;

#define GET_INSTRINFO_MC_DESC
#define ENABLE_INSTR_PREDICATE_VERIFIER
#include "PostriscGenInstrInfo.inc"

#define GET_SUBTARGETINFO_MC_DESC
#include "PostriscGenSubtargetInfo.inc"

#define GET_REGINFO_MC_DESC
#include "PostriscGenRegisterInfo.inc"

static MCAsmInfo *createPostriscMCAsmInfo(const MCRegisterInfo &MRI,
                                       const Triple &TT,
                                       const MCTargetOptions &Options) {
  MCAsmInfo *MAI = new PostriscELFMCAsmInfo(TT);
  unsigned Reg = MRI.getDwarfRegNum(POSTRISC::sp, true);
  MCCFIInstruction Inst = MCCFIInstruction::cfiDefCfa(nullptr, Reg, 0);
  MAI->addInitialFrameState(Inst);
  return MAI;
}

static MCInstrInfo *createPostriscMCInstrInfo() {
  MCInstrInfo *X = new MCInstrInfo();
  InitPostriscMCInstrInfo(X);
  return X;
}

static MCRegisterInfo *createPostriscMCRegisterInfo(const Triple &TT) {
  MCRegisterInfo *X = new MCRegisterInfo();
  InitPostriscMCRegisterInfo(X, POSTRISC::r0); //link register, where return address can be found
  return X;
}

static MCSubtargetInfo *
createPostriscMCSubtargetInfo(const Triple &TT, StringRef CPU, StringRef FS) {
  if (CPU.empty())
    CPU = "postrisc";

  MCSubtargetInfo *STI =
      createPostriscMCSubtargetInfoImpl(TT, CPU, /*TuneCPU=*/CPU, FS);

  return STI;
}

static MCTargetStreamer *
createObjectTargetStreamer(MCStreamer &S, const MCSubtargetInfo &STI) {
  return new PostriscTargetELFStreamer(S, STI);
}

static MCTargetStreamer *createTargetAsmStreamer(MCStreamer &S,
                                                 formatted_raw_ostream &OS,
                                                 MCInstPrinter *InstPrint) {
  return new PostriscTargetAsmStreamer(S, OS);
}

static MCTargetStreamer *createNullTargetStreamer(MCStreamer &S) {
  return new PostriscTargetStreamer(S);
}

static MCInstPrinter *createPostriscMCInstPrinter(const Triple &T,
                                               unsigned SyntaxVariant,
                                               const MCAsmInfo &MAI,
                                               const MCInstrInfo &MII,
                                               const MCRegisterInfo &MRI) {
  return new PostriscInstPrinter(MAI, MII, MRI);
}

extern "C" LLVM_ABI LLVM_EXTERNAL_VISIBILITY void
LLVMInitializePostriscTargetMC() {
  // Register the MC asm info.
  RegisterMCAsmInfoFn X(getThePostriscTarget(), createPostriscMCAsmInfo);

  for (Target *T :
       {&getThePostriscTarget()}) {
    // Register the MC instruction info.
    TargetRegistry::RegisterMCInstrInfo(*T, createPostriscMCInstrInfo);

    // Register the MC register info.
    TargetRegistry::RegisterMCRegInfo(*T, createPostriscMCRegisterInfo);

    // Register the MC subtarget info.
    TargetRegistry::RegisterMCSubtargetInfo(*T, createPostriscMCSubtargetInfo);

    // Register the MC Code Emitter.
    TargetRegistry::RegisterMCCodeEmitter(*T, createPostriscMCCodeEmitter);

    // Register the asm backend.
    TargetRegistry::RegisterMCAsmBackend(*T, createPostriscAsmBackend);

    // Register the object target streamer.
    TargetRegistry::RegisterObjectTargetStreamer(*T,
                                                 createObjectTargetStreamer);

    // Register the asm streamer.
    TargetRegistry::RegisterAsmTargetStreamer(*T, createTargetAsmStreamer);

    // Register the null streamer.
    TargetRegistry::RegisterNullTargetStreamer(*T, createNullTargetStreamer);

    // Register the MCInstPrinter
    TargetRegistry::RegisterMCInstPrinter(*T, createPostriscMCInstPrinter);
  }
}
