//===-- PostriscBundlerPass.cpp - Postrisc delay slot filler --------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This is a simple local pass that forms bundles.
// If there is not enough instructions, then NOPs are added.
//===----------------------------------------------------------------------===//

#include "llvm/ADT/SmallSet.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/TargetInstrInfo.h"
#include "llvm/CodeGen/TargetRegisterInfo.h"
#include "llvm/Support/Debug.h"
#include "llvm/Target/TargetMachine.h"

#include "Postrisc.h"
#include "PostriscSubtarget.h"
#include "llvm/Support/Postrisc/PostriscBundle.h"

using namespace llvm;

#define DEBUG_TYPE "postrisc-bundler"
#define PASS_NAME "Postrisc Bundler"

STATISTIC(NumFilledSlots, "Number of useful slots");
STATISTIC(NumLongInstructions, "Number of long instructions");
STATISTIC(NumNopsBlockEnd, "Number of nops added due to block alignment");
STATISTIC(NumNopsCallInst, "Number of nops added due to call instruction bundle alignment");
STATISTIC(NumNopsEhLabel, "Number of nops added due to eh label bundle alignment");
STATISTIC(NumNopsFilled, "Number of nops added");
STATISTIC(NumNopsLongInst, "Number of nops added due to long instruction bundle alignment");
STATISTIC(NumShortInstructions, "Number of short instructions");
STATISTIC(NumBundles, "Number of bundles");

namespace {
  struct Bundler : public MachineFunctionPass {
    static char ID;
    Bundler() : MachineFunctionPass(ID) {}

    StringRef getPassName() const override { return PASS_NAME; }

    bool runOnMachineFunction(MachineFunction& MF) override;

    MachineFunctionProperties getRequiredProperties() const override {
      MachineFunctionProperties mfp;
      mfp.set(MachineFunctionProperties::Property::NoVRegs);
      // mfp.set(MachineFunctionProperties::Property::FailsVerification);
      return mfp;
    }

    void runNopFiller(const PostriscInstrInfo& PII, MachineBasicBlock &MBB);
    void runBundling(const PostriscInstrInfo& PII, MachineBasicBlock &MBB);
  };
  const PostriscSubtarget *Subtarget = nullptr;
  char Bundler::ID = 0;
} // end of anonymous namespace

namespace llvm {
  void initializeBundlerPass(PassRegistry &);
} // namespace llvm

INITIALIZE_PASS(Bundler, DEBUG_TYPE, PASS_NAME, false, false)

bool Bundler::runOnMachineFunction(MachineFunction& MF) {
  LLVM_DEBUG(dbgs() << "Bundler: " << MF.getName() << "\n");

  Subtarget = &MF.getSubtarget<PostriscSubtarget>();
  const PostriscInstrInfo *PII = Subtarget->getInstrInfo();

  // const PostriscInstrInfo *TII = Subtarget->getInstrInfo();

  // This transformation may cause verification failures.
  // We need to merge blocks with several internal branches -
  // we merge fallthrough blocks,
  // even if there is cond branch at the end of previous block
  // also we insert padding non-terminal nops after final terminator
  MF.getProperties().set(MachineFunctionProperties::Property::FailsVerification);

  for (MachineBasicBlock &MBB : MF) {
    LLVM_DEBUG(dbgs() << "Original:\n"; MBB.dump());
    runNopFiller(*PII, MBB);
    LLVM_DEBUG(dbgs() << "Filled:\n"; MBB.dump());
    runBundling(*PII, MBB);
    LLVM_DEBUG(dbgs() << "Bundled:\n"; MBB.dump());
  }

  MF.getRegInfo().invalidateLiveness();
  return true; // always changed
}

static bool IsLikeDebugInstruction(const MachineInstr& MI) {
  return MI.isDebugInstr() || MI.isImplicitDef();
}

// to align addresses which are used in unwind tables, CFI, etc
static bool IsLikeBarrierInstruction(const MachineInstr& MI) {
  switch (MI.getOpcode()) {
    case TargetOpcode::CFI_INSTRUCTION:
    case TargetOpcode::EH_LABEL:
    case TargetOpcode::MEMBARRIER:
      return true;
  }
  return false;
}

static bool IsLikeCallInstruction(const MachineInstr& MI) {
  if (MI.isCall())
    return true;

  switch (MI.getOpcode()) {
    case POSTRISC::SYSCALL:
      return true;
  }
  return false;
}

enum NopImmKind {
  kNopImmEndBlock = 0,
  kNopImmAlignedCall = 1,
  kNopImmLongInstruction = 2,
  kNopImmBarrier = 3,
};

static bool FillBundle(const PostriscInstrInfo& PII, MachineBasicBlock &MBB,
                       MachineBasicBlock::iterator I, unsigned &size,
                       NopImmKind imm, llvm::Statistic& stat)
{
  bool Changed = false;
  DebugLoc DL;
  for ( ; size % 3 != 0; ++size) {
    LLVM_DEBUG(dbgs() << "insert nops: " << *I << "\n");
    // insert NOP before I
    BuildMI(MBB, I, DL, PII.get(POSTRISC::NOP)).addImm(static_cast<unsigned>(imm));
    ++stat;
    ++NumNopsFilled;
    Changed = true;
  }
  return Changed;
}

void Bundler::runNopFiller(const PostriscInstrInfo& PII, MachineBasicBlock &MBB)
{
  LLVM_DEBUG(dbgs() << "NopFiller:\n"; MBB.dump());

  unsigned size = 0;
  for (MachineBasicBlock::iterator I = MBB.begin(); I != MBB.end(); ) {
    MachineBasicBlock::iterator MI = I;

    if (IsLikeBarrierInstruction(*MI)) {
      FillBundle(PII, MBB, MI, size, kNopImmBarrier, NumNopsEhLabel);
      ++I;
      continue;
    }

    if (IsLikeDebugInstruction(*MI)) {
      ++I;
      continue;
    }

    if (PII.isLong(MI->getOpcode())) {
      if (size % 3 == 2) {
        FillBundle(PII, MBB, MI, size, kNopImmLongInstruction, NumNopsLongInst);
      }
      ++NumLongInstructions;
      NumFilledSlots += 2;
      size += 2;
    } else {
      NumShortInstructions += 1;
      NumFilledSlots += 1;
      size++;
    }

    // optionally filling after call/syscall/etc
    if (!Subtarget->getCLOpts().enable_dense_calls && IsLikeCallInstruction(*MI)) {
      FillBundle(PII, MBB, MI, size, kNopImmAlignedCall, NumNopsCallInst);
    }

    ++I;
  }

  FillBundle(PII, MBB, MBB.end(), size, kNopImmEndBlock, NumNopsBlockEnd);
}

void Bundler::runBundling(const PostriscInstrInfo& PII, MachineBasicBlock &MBB)
{
  LLVM_DEBUG(dbgs() << "split into bundles: MBB=\n"; MBB.dump());

  for (MachineBasicBlock::iterator I = MBB.begin(); I != MBB.end(); ) {
    unsigned size = 0;
    MachineBasicBlock::iterator MI = I;
    if (IsLikeBarrierInstruction(*MI)) {
      LLVM_DEBUG(dbgs() << "skip barrier-like: " << &*MI << "\n");
      ++I;
      continue;
    }
    if (IsLikeDebugInstruction(*MI)) {
      ++I;
      continue;
    }

    LLVM_DEBUG(dbgs() << "fill bundle: " << &*MI << "\n");
    MachineBasicBlock::iterator J = I;
    for (; J != MBB.end() && size < 3; ++J) {
      if (IsLikeBarrierInstruction(*J)) {
         ++J; // make barrier a stop iterator
         break;
      }
      if (IsLikeDebugInstruction(*J)) {
        continue;
      }
      if (PII.isLong(J->getOpcode())) {
        assert(size < 2);
        size += 2;
      } else {
        size += 1;
      }
      LLVM_DEBUG(dbgs() << "J=" << &*J
             << " pred=" << J->isBundledWithPred()
             << " succ="  << J->isBundledWithSucc()
             << " size=" << size
             << " insn=" << *J);
    }

    if (size != 3) {
        dbgs() << "size=" << size << " opcode=" << J->getOpcode() << "\n";
    }
    assert(size == 3);
    LLVM_DEBUG(dbgs() << "end fill bundle\n");
    // finalize bundle for range [FirstMI, LastMI)
    finalizeBundle(MBB, MI.getInstrIterator(), J.getInstrIterator());
    ++NumBundles;
    I = J;
  }

  LLVM_DEBUG(
    dbgs() << "Bundler: modified MBB=" << printMBBReference(MBB) << "\n";
    for (const auto& MI : MBB) {
      LLVM_DEBUG(dbgs() << " pred=" << MI.isBundledWithPred()
                        << " succ="  << MI.isBundledWithSucc()
                        << " insn=" << MI);
    });
}

/// createPostriscBundlerPass
/// returns a pass that creates bundles from Postrisc MachineFunctions
///
FunctionPass *llvm::createPostriscBundlerPass() {
  return new Bundler;
}
