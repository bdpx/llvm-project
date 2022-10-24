//===------ PostriscPasses.cpp - Define passes specific to POSTRISC ---------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
//
//===----------------------------------------------------------------------===//

#include "PostriscPasses.h"
#include "PostriscSubtarget.h"
#include "llvm/CodeGen/MachineBasicBlock.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

PostriscMachineFunctionPass::PostriscMachineFunctionPass(char &ID)
    : MachineFunctionPass(ID) {}


//*****************************************************************************
//**** FixAllFDIVSQRT pass
//*****************************************************************************
// This pass fixes the incorrectly working FDIVx and FSQRTx instructions that
// exist for some earlier versions of the POSTRISC processor line. Five NOP
// instructions need to be inserted after these instructions to ensure the
// correct result is placed in the destination registers before they are used.
//
// This pass implements two fixes:
//  1) fixing the FSQRTS and FSQRTD instructions.
//  2) fixing the FDIVS and FDIVD instructions.
//
// FSQRTS and FDIVS are converted to FDIVD and FSQRTD respectively earlier in
// the pipeline when this option is enabled, so this pass needs only to deal
// with the changes that still need implementing for the "double" versions
// of these instructions.
//
char FixAllFDIVSQRT::ID = 0;

FixAllFDIVSQRT::FixAllFDIVSQRT() : PostriscMachineFunctionPass(ID) {}

bool FixAllFDIVSQRT::runOnMachineFunction(MachineFunction &MF) {
  Subtarget = &MF.getSubtarget<PostriscSubtarget>();
  const TargetInstrInfo &TII = *Subtarget->getInstrInfo();
  DebugLoc DL = DebugLoc();

  bool Modified = false;
  for (MachineBasicBlock &MBB : MF) {
    for (auto MBBI = MBB.begin(), E = MBB.end(); MBBI != E; ++MBBI) {
      MachineInstr &MI = *MBBI;
      unsigned Opcode = MI.getOpcode();

      // Note: FDIVS and FSQRTS cannot be generated when this erratum fix is
      // switched on so we don't need to check for them here. They will
      // already have been converted to FSQRTD or FDIVD earlier in the
      // pipeline.
      if (Opcode == POSTRISC::SQRT_F64 || Opcode == POSTRISC::DIV_F64) {
        for (int InsertedCount = 0; InsertedCount < 5; InsertedCount++)
          BuildMI(MBB, MBBI, DL, TII.get(POSTRISC::NOP))
             .addImm(0);

        MachineBasicBlock::iterator NMBBI = std::next(MBBI);
        for (int InsertedCount = 0; InsertedCount < 28; InsertedCount++)
          BuildMI(MBB, NMBBI, DL, TII.get(POSTRISC::NOP))
             .addImm(0);

        Modified = true;
      }
    }
  }

  return Modified;
}
