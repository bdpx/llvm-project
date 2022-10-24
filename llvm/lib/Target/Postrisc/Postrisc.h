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
#include "llvm/CodeGen/MachineFunctionAnalysisManager.h"
#include "llvm/CodeGen/SelectionDAGISel.h"
#include "llvm/IR/Analysis.h"
#include "llvm/IR/PassManager.h"
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

class PostriscDAGToDAGISelPass : public SelectionDAGISelPass {
public:
  PostriscDAGToDAGISelPass(PostriscTargetMachine &TM, CodeGenOptLevel OptLevel);
};

FunctionPass *createPostriscDAGToDAGISelLegacyPass(PostriscTargetMachine &TM,
                                                CodeGenOptLevel OptLevel);


class PostriscMergeMovesPass
    : public RequiredPassInfoMixin<PostriscMergeMovesPass> {
public:
  PreservedAnalyses run(MachineFunction &MF,
                        MachineFunctionAnalysisManager &MFAM);
};

class PostriscFrameFixerPass
    : public RequiredPassInfoMixin<PostriscFrameFixerPass> {
public:
  PreservedAnalyses run(MachineFunction &MF,
                        MachineFunctionAnalysisManager &MFAM);
};

class PostriscOptAddrModePass
    : public RequiredPassInfoMixin<PostriscOptAddrModePass> {
public:
  PreservedAnalyses run(MachineFunction &MF,
                        MachineFunctionAnalysisManager &MFAM);
};

class PostriscNullificationPass
    : public RequiredPassInfoMixin<PostriscNullificationPass> {
public:
  PreservedAnalyses run(MachineFunction &MF,
                        MachineFunctionAnalysisManager &MFAM);
};

class PostriscBlockMergerPass
    : public RequiredPassInfoMixin<PostriscBlockMergerPass> {
public:
  PreservedAnalyses run(MachineFunction &MF,
                        MachineFunctionAnalysisManager &MFAM);
};

class PostriscBundlerPass
    : public RequiredPassInfoMixin<PostriscBundlerPass> {
public:
  PreservedAnalyses run(MachineFunction &MF,
                        MachineFunctionAnalysisManager &MFAM);
};

FunctionPass *createPostriscOptAddrModePass();
FunctionPass *createPostriscBlockMergerPass();
FunctionPass *createPostriscFrameFixerPass();
FunctionPass *createPostriscMergeMovesPass();
FunctionPass *createPostriscNullificationPass();
FunctionPass *createPostriscBundlerPass();

void initializePostriscDAGToDAGISelLegacyPass(PassRegistry &);
void initializePostriscAsmPrinterPass(PassRegistry &);
void initializePostriscBlockMergerLegacyPass(PassRegistry &);
void initializePostriscBundlerLegacyPass(PassRegistry &);
void initializePostriscNullificationLegacyPass(PassRegistry &);
void initializePostriscMergeMovesLegacyPass(PassRegistry &);
void initializePostriscFrameFixerLegacyPass(PassRegistry &);
void initializePostriscOptAddrModeLegacyPass(PassRegistry &);
} // namespace llvm

#define GENERAL_LOCAL_REGISTERS_CASES(X) \
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

#define GENERAL_GLOBAL_REGISTERS_CASES(X) \
  X(g0) X(g1) X(g2) X(g3) X(tp) X(fp) X(sp) X(gz)

#define GENERAL_REGISTERS_CASES(X) GENERAL_LOCAL_REGISTERS_CASES(X) GENERAL_GLOBAL_REGISTERS_CASES(X)

#define SPECIAL_REGISTERS_CASES(X) \
    X(ip, i64) X(eip, i64) X(fpcr, i64) X(eca, i64) X(rsc, i64) X(rsp, i64) X(bsp, i64) \
    X(psr, i128) X(reip, i64) X(kip, i64) X(ksp, i64) X(krsp, i64) \
    X(peb, i64) X(teb, i64) X(itc, i64) X(itm, i64) X(pta, i64) X(iva, i64) X(icc, i64) \
    X(iip, i64) X(iipa, i64) X(ipsr, i128) X(cause, i64) X(ifa, i64) X(iib, i128) \
    X(irr0, i64) X(irr1, i64) X(irr2, i64) X(irr3, i64) \
    X(isr0, i64) X(isr1, i64) X(isr2, i64) X(isr3, i64) \
    X(iv, i64) X(lid, i64) X(tpr, i64) X(itcv, i64) X(tsv, i64) X(pmv, i64) X(cmcv, i64) \

#endif
