//===-- PostriscTargetStreamer.h - Postrisc Target Streamer ----------*- C++ -*--===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_POSTRISC_MCTARGETDESC_POSTRISCTARGETSTREAMER_H
#define LLVM_LIB_TARGET_POSTRISC_MCTARGETDESC_POSTRISCTARGETSTREAMER_H

#include "llvm/MC/MCELFStreamer.h"
#include "llvm/MC/MCStreamer.h"

namespace llvm {

class formatted_raw_ostream;

class PostriscTargetStreamer : public MCTargetStreamer {
  virtual void anchor();

public:
  PostriscTargetStreamer(MCStreamer &S);
  /// Emit ".register <reg>, #ignore".
  virtual void emitPostriscRegisterIgnore(unsigned reg){};
  /// Emit ".register <reg>, #scratch".
  virtual void emitPostriscRegisterScratch(unsigned reg){};
};

// This part is for ascii assembly output
class PostriscTargetAsmStreamer : public PostriscTargetStreamer {
  formatted_raw_ostream &OS;

public:
  PostriscTargetAsmStreamer(MCStreamer &S, formatted_raw_ostream &OS);
  void emitPostriscRegisterIgnore(unsigned reg) override;
  void emitPostriscRegisterScratch(unsigned reg) override;
};

// This part is for ELF object output
class PostriscTargetELFStreamer : public PostriscTargetStreamer {
public:
  PostriscTargetELFStreamer(MCStreamer &S, const MCSubtargetInfo &STI);
  MCELFStreamer &getStreamer();
  void emitPostriscRegisterIgnore(unsigned reg) override {}
  void emitPostriscRegisterScratch(unsigned reg) override {}
};
} // end namespace llvm

#endif
