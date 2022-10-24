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
FunctionPass *createPostriscMergeMovesPass();
FunctionPass *createPostriscNullificationPass();

void initializePostriscAsmPrinterPass(PassRegistry &);
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

#define GENERAL_REGISTERS_CASES(X) \
  X(r0)  X(r1)  X(r2)  X(r3)  X(r4)  X(r5)  X(r6)  X(r7) \
  X(r8)  X(r9)  X(r10) X(r11) X(r12) X(r13) X(r14) X(r15) \
  X(r16) X(r17) X(r18) X(r19) X(r20) X(r21) X(r22) X(r23) \
  X(r24) X(r25) X(r26) X(r27) X(r28) X(r29) X(r30) X(r31) \
  X(r32) X(r33) X(r34) X(r35) X(r36) X(r37) X(r38) X(r39) \
  X(r40) X(r41) X(r42) X(r43) X(r44) X(r45) X(r46) X(r47) \
  X(r48) X(r49) X(r50) X(r51) X(r52) X(r53) X(r54) X(r55) \
  X(r56) X(r57) X(r58) X(r59) X(r60) X(r61) X(r62) X(r63) \
  X(r64) X(r65) X(r66) X(r67) X(r68) X(r69) X(r70) X(r71) \
  X(r72) X(r73) X(r74) X(r75) X(r76) X(r77) X(r78) X(r79) \
  X(r80) X(r81) X(r82) X(r83) X(r84) X(r85) X(r86) X(r87) \
  X(r88) X(r89) X(r90) X(r91) X(r92) X(r93) X(r94) X(r95) \
  X(r96) X(r97) X(r98) X(r99) X(r100) X(r101) X(r102) X(r103) \
  X(r104) X(r105) X(r106) X(r107) X(r108) X(r109) X(r110) X(r111) \
  X(r112) X(r113) X(r114) X(r115) X(r116) X(r117) X(r118) X(r119) \
  X(g0) X(g1) X(g2) X(g3) X(tp) X(fp) X(sp) X(gz)

#define SPECIAL_REGISTERS_CASES(X) \
    X(ip) X(eip) X(fpcr) X(eca) X(rsc) X(rsp) X(bsp) \
    X(psr) X(reip) X(kip) X(ksp) X(krsp) \
    X(peb) X(teb) X(itc) X(itm) X(pta) X(iva) \
    X(iip) X(iipa) X(ipsr) X(cause) X(ifa) X(iib) \
    X(irr0) X(irr1) X(irr2) X(irr3) \
    X(isr0) X(isr1) X(isr2) X(isr3) \
    X(iv) X(lid) X(tpr) X(itcv) X(tsv) X(pmv) X(cmcv) \

#endif
