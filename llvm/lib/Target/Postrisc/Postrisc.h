//===-- Postrisc.h - Top-level interface for Postrisc representation --*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains the entry points for global functions defined in the LLVM
// Postrisc back-end.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_POSTRISC_POSTRISC_H
#define LLVM_LIB_TARGET_POSTRISC_POSTRISC_H

#include "MCTargetDesc/PostriscMCTargetDesc.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Target/TargetMachine.h"

#include "llvm/Support/Postrisc/PostriscBundle.h"

#if !defined(__POSTRISC__)
#error __POSTRISC__ should be defined
#endif

namespace llvm {
class AsmPrinter;
class FunctionPass;
class MCInst;
class MachineInstr;
class PassRegistry;
class PostriscTargetMachine;

FunctionPass *createPostriscISelDag(PostriscTargetMachine &TM);

FunctionPass *createPostriscBundlerPass();
FunctionPass *createPostriscOptAddrMode();
FunctionPass *createPostriscFrameFixer();
FunctionPass *createPostriscNullificationPass();

void LowerPostriscMachineInstrToMCInst(const MachineInstr *MI, MCInst &OutMI,
                                    AsmPrinter &AP);
void initializePostriscDAGToDAGISelLegacyPass(PassRegistry &);
} // namespace llvm

namespace llvm {

  namespace postrisc {
    // Postrisc TSFlags.
    enum {
      POSTRISC_IS_LONG               = 0x1,
      POSTRISC_IS_POST_INC           = 0x2,
      POSTRISC_IS_PRE_INC            = 0x4,
      POSTRISC_IS_INDEXED_MEM_ACCESS = 0x8,
    };

    inline bool isLong(uint64_t TSFlags) {
      return (TSFlags & POSTRISC_IS_LONG) != 0;
    }
    inline bool isPostIncrement(uint64_t TSFlags) {
      return (TSFlags & POSTRISC_IS_POST_INC) != 0;
    }
    inline bool isPreIncrement(uint64_t TSFlags) {
      return (TSFlags & POSTRISC_IS_PRE_INC) != 0;
    }
    inline bool isIndexedMemAccess(uint64_t TSFlags) {
      return (TSFlags & POSTRISC_IS_INDEXED_MEM_ACCESS) != 0;
    }
  }

}  // end namespace llvm
#endif
