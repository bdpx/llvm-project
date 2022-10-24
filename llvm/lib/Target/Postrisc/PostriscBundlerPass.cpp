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
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Target/TargetMachine.h"

#include "Postrisc.h"
#include "PostriscSubtarget.h"
#include "llvm/Support/Postrisc/PostriscBundle.h"

using namespace llvm;

#define DEBUG_TYPE "postrisc-bundler"
#define PASS_NAME "Postrisc Bundler"

STATISTIC(NumBasicBlocks, "Number of basic blocks");
STATISTIC(NumFilledSlots, "Number of useful slots");
STATISTIC(NumLongInstructions, "Number of long instructions");
STATISTIC(NumNopsBlockEnd, "Number of nops added due to block alignment");
STATISTIC(NumNopsCallInst, "Number of nops added due to call instruction bundle alignment");
STATISTIC(NumNopsEhLabel, "Number of nops added due to eh label bundle alignment");
STATISTIC(NumNopsFilled, "Number of nops added");
STATISTIC(NumNopsLongInst, "Number of nops added due to long instruction bundle alignment");
STATISTIC(NumShortInstructions, "Number of short instructions");
STATISTIC(NumBundles, "Number of bundles");
STATISTIC(NumMergedBasicBlocks, "Number of merged basic blocks");

static cl::opt<bool>
EnableBlockMerging("enable-block-merging",
              cl::init(false),
              cl::desc("Enable fallthrough blocks merging"),
              cl::NotHidden);

static cl::opt<bool>
EnableDenseCalls("postrisc-enable-dense-calls",
                cl::init(false),
                cl::desc("Postrisc enable calls inside bundle."),
                cl::NotHidden);

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

    bool runBlockMerging(MachineFunction& MF);
    bool runNopFiller(const PostriscInstrInfo& PII, MachineBasicBlock &MBB);
    bool runBundling(const PostriscInstrInfo& PII, MachineBasicBlock &MBB);
  };
  char Bundler::ID = 0;
} // end of anonymous namespace

namespace llvm {
  void initializeBundlerPass(PassRegistry &);
} // namespace llvm

INITIALIZE_PASS(Bundler, DEBUG_TYPE, PASS_NAME, false, false)

// isBlockOnlyReachableByFallthough - Return true if the basic block has
// exactly one predecessor and the control transfer mechanism between
// the predecessor and this block is a fall-through.
// copied from CodeGen/AsmPrinter
static bool isBlockOnlyReachableByFallthrough(const MachineBasicBlock& MBB) {
  // If this is a landing pad, it isn't a fall through.  If it has no preds,
  // then nothing falls through to it.
  if (MBB.isEHPad() || MBB.pred_empty())
    return false;

  // If there isn't exactly one predecessor, it can't be a fall through.
  if (MBB.pred_size() > 1)
    return false;

  // The predecessor has to be immediately before this block.
  MachineBasicBlock *Pred = *MBB.pred_begin();
  if (!Pred->isLayoutSuccessor(&MBB))
    return false;

  // If the block is completely empty, then it definitely does fall through.
  if (Pred->empty())
    return true;

  // Check the terminators in the previous blocks
  for (const auto &MI : Pred->terminators()) {
    // If it is not a simple branch, we are in a table somewhere.
    if (!MI.isBranch() || MI.isIndirectBranch())
      return false;

    // If we are the operands of one of the branches, this is not a fall
    // through. Note that targets with delay slots will usually bundle
    // terminators with the delay slot instruction.
    for (ConstMIBundleOperands OP(MI); OP.isValid(); ++OP) {
      if (OP->isJTI())
        return false;
      if (OP->isMBB() && OP->getMBB() == &MBB)
        return false;
    }
  }

  return true;
}

// This method decides whether the specified basic block requires a label.
// copied from CodeGen/AsmPrinter
static bool
shouldEmitLabelForBasicBlock(MachineFunction &MF, const MachineBasicBlock &MBB) {
  // With `-fbasic-block-sections=`, a label is needed for every non-entry block
  // in the labels mode (option `=labels`) and every section beginning in the
  // sections mode (`=all` and `=list=`).
  if ((/*MF.hasBBLabels() ||*/ MBB.isBeginSection()) && !MBB.isEntryBlock())
    return true;
  // A label is needed for any block with at least one predecessor (when that
  // predecessor is not the fallthrough predecessor, or if it is an EH funclet
  // entry, or if a label is forced).
  return !MBB.pred_empty() &&
         (!isBlockOnlyReachableByFallthrough(MBB) || MBB.isEHFuncletEntry() ||
          MBB.hasLabelMustBeEmitted());
}

// merge Tail into Head at the end
static void MergeBlocks(MachineBasicBlock &Head, MachineBasicBlock &Tail)
{
  // Splice Tail onto the end of Head.
  LLVM_DEBUG(dbgs() << "joining tail " << printMBBReference(Tail)
                    << " into head " << printMBBReference(Head) << '\n');

  Head.splice(Head.end(), &Tail, Tail.begin(), Tail.end());

  while (!Tail.succ_empty()) {
    MachineBasicBlock *Succ = *Tail.succ_begin();
    if (!Head.isSuccessor(Succ)) {
      Head.addSuccessorWithoutProb(Succ);
    }
    Tail.removeSuccessor(Succ);
  }

  Head.removeSuccessor(&Tail);
  Head.normalizeSuccProbs();
  Tail.eraseFromParent();
}

bool Bundler::runBlockMerging(MachineFunction& MF) {
  LLVM_DEBUG(dbgs() << "runBlockMerging: MF=" << MF.getName() << "\n");
  std::vector<std::pair<MachineBasicBlock *, bool>> MachineBasicBlockWorklist;
  for (MachineBasicBlock& MBB : MF) {
    const bool hasLabel = shouldEmitLabelForBasicBlock(MF, MBB);
    MachineBasicBlockWorklist.push_back(std::pair<MachineBasicBlock *, bool>(&MBB, hasLabel));
    LLVM_DEBUG(dbgs() << "\tMBB=" << printMBBReference(MBB)
                      << " hasLabel=" << hasLabel << "\n");
  }

  LLVM_DEBUG(dbgs() << "runBlockMerging: start merging\n");
  bool Changed = false;
  MachineBasicBlock *Prev = nullptr;
  for (auto const& pair : MachineBasicBlockWorklist) {
    MachineBasicBlock *MBB = pair.first;
    const bool hasLabel = pair.second;
    LLVM_DEBUG(dbgs() << "runBlockMerging: MBB=" << printMBBReference(*MBB)
                      << " hasLabel=" << hasLabel << "\n");
    if (!hasLabel && Prev) {
      MergeBlocks(*Prev, *MBB);
      ++NumMergedBasicBlocks;
      Changed = true;
    } else {
      Prev = MBB;
      // FIXME: this should not be used, but some MBBs are not labeled after merge
      MBB->setLabelMustBeEmitted();
    }
    LLVM_DEBUG(dbgs() << "runBlockMerging: next\n");
  }
  return Changed;
}

bool Bundler::runOnMachineFunction(MachineFunction& MF) {
  LLVM_DEBUG(dbgs() << "Bundler: " << MF.getName() << "\n");
  bool Changed = false;

  const PostriscSubtarget& Subtarget = MF.getSubtarget<PostriscSubtarget>();
  const PostriscInstrInfo *PII = Subtarget.getInstrInfo();

  // const PostriscInstrInfo *TII = Subtarget->getInstrInfo();

  // This transformation may cause verification failures.
  // We need to merge blocks with several internal branches -
  // we merge fallthrough blocks,
  // even if there is cond branch at the end of previous block
  // also we insert padding non-terminal nops after final terminator
  MF.getProperties().set(MachineFunctionProperties::Property::FailsVerification);

  if (EnableBlockMerging) {
    Changed |= runBlockMerging(MF);
  }
  LLVM_DEBUG(dbgs() << "Merged:\n"; MF.dump());

  for (MachineBasicBlock &MBB : MF) {
    Changed |= runNopFiller(*PII, MBB);
  }
  LLVM_DEBUG(dbgs() << "Filled:\n"; MF.dump());

  for (MachineBasicBlock &MBB : MF)
    Changed |= runBundling(*PII, MBB);
  LLVM_DEBUG(dbgs() << "Bundled:\n"; MF.dump());

  MF.getRegInfo().invalidateLiveness();
  return Changed;
}

static bool IsLikeCallInstruction(const MachineInstr& MI)
{
  switch (MI.getOpcode()) {
    case POSTRISC::SYSCALL:
      return true;
  }
  return false;
}

static bool FillBundle(const PostriscInstrInfo& PII, MachineBasicBlock &MBB,
                       MachineBasicBlock::iterator I, unsigned &size,
                       unsigned imm, llvm::Statistic& stat)
{
  bool Changed = false;
  DebugLoc DL;
  for ( ; size % 3 != 0; ++size) {
    LLVM_DEBUG(dbgs() << "insert nops: " << *I << "\n");
    BuildMI(MBB, I, DL, PII.get(POSTRISC::NOP)).addImm(imm);
    ++stat;
    ++NumNopsFilled;
    Changed = true;
  }
  return Changed;
}

bool Bundler::runNopFiller(const PostriscInstrInfo& PII, MachineBasicBlock &MBB)
{
  bool Changed = false;
  LLVM_DEBUG(dbgs() << "NopFiller:\n"; MBB.dump());
  ++NumBasicBlocks;

  unsigned size = 0;
  for (MachineBasicBlock::iterator I = MBB.begin(); I != MBB.end(); ) {
    MachineBasicBlock::iterator MI = I;
    // remove compiler-time barriers
    if (MI->getOpcode() == TargetOpcode::MEMBARRIER) {
      MachineBasicBlock::iterator TMP = std::next(MI);
      MBB.erase(I);
      I = TMP;
      continue;
    }
    // FIXME: don't bundle CFI and EH_LABEL
    //if (MI->getOpcode() == TargetOpcode::CFI_INSTRUCTION ||
    //    MI->getOpcode() == TargetOpcode::EH_LABEL) {
    //  ++I;
    //  continue;
    //}

    if (MI->isDebugInstr() || MI->isImplicitDef()) {
      MachineBasicBlock::iterator TMP = std::next(MI);
      MBB.erase(I);
      I = TMP;
      continue;
    }

    // FIXME: align EH_LABEL, address is used in unwind tables
    if (MI->getOpcode() == TargetOpcode::CFI_INSTRUCTION ||
        MI->getOpcode() == TargetOpcode::EH_LABEL) {
      Changed |= FillBundle(PII, MBB, I, size, 3, NumNopsEhLabel);
      ++I;
      continue;
    }
    if (PII.isLong(MI->getOpcode())) {
      if (size % 3 == 2) {
        Changed |= FillBundle(PII, MBB, I, size, 2, NumNopsLongInst);
      }
      ++NumLongInstructions;
      NumFilledSlots += 2;
      size += 2;
    } else {
      NumShortInstructions += 1;
      NumFilledSlots += 1;
      size++;
    }
    ++I;
    // optional filling after call/syscall/etc
    if (!EnableDenseCalls && (MI->isCall() || IsLikeCallInstruction(*MI))) {
      MachineBasicBlock::iterator TMP = std::prev(I);
      Changed |= FillBundle(PII, MBB, TMP, size, 1, NumNopsCallInst);
    }
  }

  Changed |= FillBundle(PII, MBB, MBB.end(), size, 0, NumNopsBlockEnd);
  return Changed;
}

bool Bundler::runBundling(const PostriscInstrInfo& PII, MachineBasicBlock &MBB)
{
  LLVM_DEBUG(dbgs() << "split into bundles: MBB=\n"; MBB.dump());

  for (MachineBasicBlock::iterator I = MBB.begin(); I != MBB.end(); ) {
    unsigned size = 0;
    MachineBasicBlock::iterator MI = I;
    if (MI->getOpcode() == TargetOpcode::CFI_INSTRUCTION ||
        MI->getOpcode() == TargetOpcode::EH_LABEL) {
      LLVM_DEBUG(dbgs() << "skip CFI_INSTRUCTION: " << &*MI << "\n");
      ++I;
      continue;
    }
    if (MI->isDebugInstr() || MI->isImplicitDef()) {
      ++I;
      continue;
    }

    LLVM_DEBUG(dbgs() << "fill bundle: " << &*MI << "\n");
    MachineBasicBlock::iterator J = I;
    for (; J != MBB.end() && size < 3; ++J) {
      if (J->getOpcode() != TargetOpcode::CFI_INSTRUCTION &&
          J->getOpcode() != TargetOpcode::EH_LABEL) {
         if (PII.isLong(J->getOpcode())) {
           assert(size < 2);
           size += 2;
         } else {
           size += 1;
         }
      } else {
         ++J;
         break;
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

  return true; // always changed
}

/// createPostriscBundlerPass
/// returns a pass that creates bundles from Postrisc MachineFunctions
///
FunctionPass *llvm::createPostriscBundlerPass() {
  return new Bundler;
}
