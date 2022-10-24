//===-- PostriscTargetStreamer.cpp - Postrisc Target Streamer Methods -----------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file provides Postrisc specific target streamer methods.
//
//===----------------------------------------------------------------------===//

#include "PostriscTargetStreamer.h"
#include "PostriscInstPrinter.h"
#include "PostriscMCTargetDesc.h"
#include "llvm/BinaryFormat/ELF.h"
#include "llvm/MC/MCELFObjectWriter.h"
#include "llvm/MC/MCRegister.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/Support/FormattedStream.h"

using namespace llvm;

static unsigned getEFlagsForFeatureSet(const MCSubtargetInfo &STI) {
  unsigned EFlags = 0;

  // add custom arch ELF features (sample)
  if (STI.hasFeature(Postrisc::FeatureSIMD))
    EFlags |= ELF::EF_POSTRISC_ARCH_32;

  return EFlags;
}

// pin vtable to this file
PostriscTargetStreamer::PostriscTargetStreamer(MCStreamer &S) : MCTargetStreamer(S) {}

void PostriscTargetStreamer::anchor() {}

PostriscTargetAsmStreamer::PostriscTargetAsmStreamer(MCStreamer &S,
                                               formatted_raw_ostream &OS)
    : PostriscTargetStreamer(S), OS(OS) {}

void PostriscTargetAsmStreamer::emitPostriscRegisterIgnore(unsigned reg) {
  OS << "\t.register "
     << "%" << StringRef(PostriscInstPrinter::getRegisterName(reg)).lower()
     << ", #ignore\n";
}

void PostriscTargetAsmStreamer::emitPostriscRegisterScratch(unsigned reg) {
  OS << "\t.register "
     << "%" << StringRef(PostriscInstPrinter::getRegisterName(reg)).lower()
     << ", #scratch\n";
}

PostriscTargetELFStreamer::PostriscTargetELFStreamer(MCStreamer &S,
                                               const MCSubtargetInfo &STI)
    : PostriscTargetStreamer(S) {
  ELFObjectWriter &W = getStreamer().getWriter();
  unsigned EFlags = W.getELFHeaderEFlags();

  EFlags |= getEFlagsForFeatureSet(STI);

  W.setELFHeaderEFlags(EFlags);
}

MCELFStreamer &PostriscTargetELFStreamer::getStreamer() {
  return static_cast<MCELFStreamer &>(Streamer);
}
