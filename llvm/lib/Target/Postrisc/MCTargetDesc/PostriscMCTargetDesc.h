//===-- PostriscMCTargetDesc.h - Postrisc Target Descriptions ---------*- C++ -*-===//
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

#ifndef LLVM_LIB_TARGET_POSTRISC_MCTARGETDESC_POSTRISCMCTARGETDESC_H
#define LLVM_LIB_TARGET_POSTRISC_MCTARGETDESC_POSTRISCMCTARGETDESC_H

#include "llvm/ADT/StringRef.h"
#include "llvm/Support/DataTypes.h"

#include <memory>

namespace llvm {
class MCAsmBackend;
class MCCodeEmitter;
class MCContext;
class MCInstrInfo;
class MCObjectTargetWriter;
class MCRegisterInfo;
class MCSubtargetInfo;
class MCTargetOptions;
class Target;
class Triple;

MCCodeEmitter *createPostriscMCCodeEmitter(const MCInstrInfo &MCII,
                                        MCContext &Ctx);
MCAsmBackend *createPostriscAsmBackend(const Target &T, const MCSubtargetInfo &STI,
                                    const MCRegisterInfo &MRI,
                                    const MCTargetOptions &Options);
std::unique_ptr<MCObjectTargetWriter>
createPostriscELFObjectWriter(bool Is64Bit, uint8_t OSABI);

namespace postrisc {
#include "PostriscGenSearchableTables.inc"
}
} // End llvm namespace

// Defines symbolic names for Postrisc registers.  This defines a mapping from
// register name to register number.
//
#define GET_REGINFO_ENUM
#include "PostriscGenRegisterInfo.inc"

// Defines symbolic names for the Postrisc instructions.
//
#define GET_INSTRINFO_ENUM
#define GET_INSTRINFO_MC_HELPER_DECLS
#include "PostriscGenInstrInfo.inc"

#define GET_SUBTARGETINFO_ENUM
#include "PostriscGenSubtargetInfo.inc"

#endif
