//===-- PostriscFrameFixer.cpp --------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Postrisc has no fixed FP register.
// If function needs FP for any reason
// (vararrays, alloca, overalignment, varargs, debug build, etc)
// arbitrary local register is used to save/restore old SP value.
// The PostriscFrameFixer pass runs BEFORE register allocation.
// It allocs virtual register and inserts SP/FP save/restore instructions.
// Later PostriscFrameLowering finalizes offsets computing.
//
//===----------------------------------------------------------------------===//

#include "llvm/ADT/Statistic.h"
#include "llvm/CodeGen/MachineBasicBlock.h"
#include "llvm/CodeGen/MachineDominators.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/TargetRegisterInfo.h"
#include "llvm/IR/Function.h"
#include "llvm/InitializePasses.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"

#include "Postrisc.h"
#define GET_INSTRMAP_INFO
#include "PostriscInstrInfo.h"
#include "PostriscTargetMachine.h"
#include "PostriscMachineFunctionInfo.h"

using namespace llvm;

#define DEBUG_TYPE "postrisc-frame-fixer"
#define PASS_NAME "Postrisc frame fixer"

STATISTIC(NumFPFunctions, "Number of functions which use arbitrary FP");
STATISTIC(NumSPFunctions, "Number of functions which use SP");

namespace llvm {
  void initializePostriscFrameFixerPass(PassRegistry &);
} // namespace llvm

namespace {
class PostriscFrameFixer : public MachineFunctionPass {
public:
  static char ID;

  PostriscFrameFixer() : MachineFunctionPass(ID) {}

  StringRef getPassName() const override { return PASS_NAME; }

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.setPreservesCFG();
    MachineFunctionPass::getAnalysisUsage(AU);
    AU.addRequired<MachineDominatorTreeWrapperPass>();
    AU.addPreserved<MachineDominatorTreeWrapperPass>();
  }

  bool runOnMachineFunction(MachineFunction &MF) override;
};

char PostriscFrameFixer::ID = 0;

} // end anonymous namespace

INITIALIZE_PASS(PostriscFrameFixer, DEBUG_TYPE, PASS_NAME, false, false)

bool
PostriscFrameFixer::runOnMachineFunction(MachineFunction &MF)
{
  const PostriscSubtarget& Subtarget = MF.getSubtarget<PostriscSubtarget>();
  const PostriscRegisterInfo *TRI = Subtarget.getRegisterInfo();
  const PostriscFrameLowering *TFL = TRI->getFrameLowering(MF);
  const PostriscInstrInfo *TII = Subtarget.getInstrInfo();

  bool const has_fp = TFL->hasFP(MF);

  LLVM_DEBUG(dbgs() << "PostriscFrameFixer: " << MF.getName()
                    << " has_fp=" << has_fp << "\n");

  if (!has_fp) {
    ++NumSPFunctions;
    return false;
  }

  ++NumFPFunctions;

  MachineRegisterInfo &MRI = MF.getRegInfo();
  Register tempFP = MRI.createVirtualRegister(&POSTRISC::GRRegClass);
  LLVM_DEBUG(dbgs() << "PostriscFrameFixer: VirtFrameReg=" << tempFP.id() << "\n");

  // Insert the set of tempFP into the first MBB of the function
  // mov   vr, fp
  // addi  sp, sp, 0(will be fixed in frameLowering)
  MachineBasicBlock &FirstMBB = MF.front();
  MachineBasicBlock::iterator MBBI = FirstMBB.begin();
  DebugLoc dl;
  BuildMI(FirstMBB, MBBI, dl, TII->get(POSTRISC::MOV), tempFP)
    .addReg(POSTRISC::fp);
  MachineInstr *NewI =
  BuildMI(FirstMBB, MBBI, dl, TII->get(POSTRISC::ADD_IMM_I64), POSTRISC::fp)
    .addReg(POSTRISC::sp)
    .addImm(0);

  PostriscMachineFunctionInfo *PostriscFI = MF.getInfo<PostriscMachineFunctionInfo>();
  PostriscFI->setFrameSaveInstr(NewI);

  // insert before RET:
  // mov  sp, fp
  // mov  fp, vr

  MBBI = MF.back().getLastNonDebugInstr();
  LLVM_DEBUG(dbgs() << "PostriscFrameFixer: hasFP MF=" << MF.getName() << "\n");

  switch (MBBI->getOpcode()) {
    case POSTRISC::RETF: // normal return
    case POSTRISC::JMP: // tail-call
    case POSTRISC::JMP_EXT: // tail-call
    case POSTRISC::ADJCALLSTACKUP:// no-return function
       break;
    default: // FIXME: what to do
      LLVM_DEBUG(
        MBBI->dump();
        dbgs() << "func:\n";
        MF.dump();
      );
      assert(0 && "invalid getOpcode() for fp stuff insertion");
  }

  // TODO: use mov2?
  BuildMI(MF.back(), MBBI, dl, TII->get(POSTRISC::MOV), POSTRISC::sp)
    .addReg(POSTRISC::fp);
  BuildMI(MF.back(), MBBI, dl, TII->get(POSTRISC::MOV), POSTRISC::fp)
    .addReg(tempFP);

  return true;
}

FunctionPass *llvm::createPostriscFrameFixer()
{
  return new PostriscFrameFixer();
}
