//===------ PostriscMergeMovesPass.cpp - Transform moves to mov2 ----------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
//
//===----------------------------------------------------------------------===//

#include "Postrisc.h"
#include "PostriscMachineFunctionInfo.h"
#include "PostriscSubtarget.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/CodeGen/MachineBasicBlock.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineInstrBundle.h"
#include "llvm/CodeGen/MachineOperand.h"
using namespace llvm;

#define DEBUG_TYPE "postrisc-merge-moves"
#define PASS_NAME "Postrisc Merge Moves"

static cl::opt<bool>
EnableMoveMerging("enable-move-merging",
              cl::init(false),
              cl::desc("Enable mov2 merging"),
              cl::NotHidden);

STATISTIC(NumMov2Merges, "Number of mov2 merges");

namespace llvm {
  void initializePostriscMergeMovesPass(PassRegistry &);
} // namespace llvm

namespace {
  class PostriscMergeMoves : public MachineFunctionPass {
  public:
    static char ID;
    const PostriscInstrInfo *TII;

    PostriscMergeMoves() : MachineFunctionPass(ID) {}

    bool runOnMachineFunction(MachineFunction &MF) override;

    StringRef getPassName() const override {
      return PASS_NAME;
    }
  private:
    bool MergeMoves(MachineFunction &MF);
    bool MergeMoves(MachineBasicBlock& MBB);
  };
  char PostriscMergeMoves::ID = 0;
} // end anonymous namespace

INITIALIZE_PASS(PostriscMergeMoves, DEBUG_TYPE, PASS_NAME, false, false)

bool PostriscMergeMoves::MergeMoves(MachineBasicBlock& MBB) {
  LLVM_DEBUG(dbgs() << "MergeMoves:\n");
  //MBB.dump();
  MachineInstr *Prev = nullptr;
  for (auto & MI : MBB) {
    LLVM_DEBUG(dbgs() << "MRG: " << MI.getOpcode() << " " << MI << "\n");
    if (Prev && Prev->isCopy() && MI.isCopy()) {
      assert(Prev->getOperand(0).isReg() && "1st mov 1st operand should be register");
      assert(Prev->getOperand(1).isReg() && "1st mov 2nd operand should be register");
      assert(MI.getOperand(0).isReg() && "2nd mov 1st operand should be register");
      assert(MI.getOperand(1).isReg() && "2nd mov 2nd operand should be register");

      Register dst1 = Prev->getOperand(0).getReg();
      Register src1 = Prev->getOperand(1).getReg();
      Register dst2 = MI.getOperand(0).getReg();
      Register src2 = MI.getOperand(1).getReg();

      // (dst1, dst2) <= (src1, src2), check if first mov doesn't overwrite second mov src, and we may do both mov in parallel
      if (src2 == dst1) src2 = src1; // a=b; c=a; => a=b; c=b;
      bool const do_merge = (src2 != dst1 && POSTRISC::GRRegClass.contains(src1, src2) && POSTRISC::GRRegClass.contains(dst1, dst2));

      if (do_merge) {
        DebugLoc DL;
        LLVM_DEBUG(dbgs() << "insert mov2: mov=" << *Prev << " mov=" << MI << "\n");
        MachineInstrBuilder MIB = BuildMI(MBB, MI, DL, TII->get(POSTRISC::MOV2));
        MIB.addReg(dst1);
        MIB.addReg(dst2);
        MIB.addReg(src1);
        MIB.addReg(src2);
        assert(MIB->getOperand(0).isReg() && "mov2 1st operand should be register");
        assert(MIB->getOperand(1).isReg() && "mov2 2nd operand should be register");
        MIB->getOperand(0).setIsDef();
        MIB->getOperand(1).setIsDef();
        Prev->eraseFromParent();
        MI.eraseFromParent();
        ++NumMov2Merges;
        return true;
      }
    }
    Prev = &MI;
  }

  return false;
}

bool PostriscMergeMoves::MergeMoves(MachineFunction &MF) {
  LLVM_DEBUG(dbgs() << "MergeMoves: MF=" << MF.getName() << "\n");
  bool Changed = false;
  // If merged, start again.
  for (auto &MBB : MF) {
    while (MergeMoves(MBB)) {
      Changed = true;
    }
  }
  return Changed;
}

bool PostriscMergeMoves::runOnMachineFunction(MachineFunction &MF) {
  TII = MF.getSubtarget<PostriscSubtarget>().getInstrInfo();
  LLVM_DEBUG(dbgs() << "PostriscMergeMoves::runOnMachineFunction\n");
  LLVM_DEBUG(dbgs() << "*** Original basic blocks ***\n"; for (auto &MBB : MF) dbgs() << MBB;);
  bool Modified = false;

  if (EnableMoveMerging)
    Modified |= MergeMoves(MF);

  if (Modified)
    MF.getRegInfo().invalidateLiveness();
  return Modified;
}

/// createPostriscMergeMovesPass - Returns an instance of the PostriscMergeMoves
FunctionPass *llvm::createPostriscMergeMovesPass() {
  return new PostriscMergeMoves();
}
