//===-- PostriscBlockMergerPass.cpp - Postrisc delay slot filler ----------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This is a local pass that merge fallthrough blocks.
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

#define DEBUG_TYPE "postrisc-block-merger"
#define PASS_NAME "Postrisc Block Merger"

STATISTIC(NumBasicBlocks, "Number of basic blocks");
STATISTIC(NumMergedBasicBlocks, "Number of merged basic blocks");

namespace {
  struct BlockMerger : public MachineFunctionPass {
    static char ID;
    BlockMerger() : MachineFunctionPass(ID) {}

    StringRef getPassName() const override { return PASS_NAME; }

    bool runOnMachineFunction(MachineFunction& MF) override;

    MachineFunctionProperties getRequiredProperties() const override {
      MachineFunctionProperties mfp;
      mfp.set(MachineFunctionProperties::Property::NoVRegs);
      return mfp;
    }

    bool runBlockMerging(MachineFunction& MF);
  };
  const PostriscSubtarget *Subtarget = nullptr;
  char BlockMerger::ID = 0;
} // end of anonymous namespace

namespace llvm {
  void initializeBlockMergerPass(PassRegistry &);
} // namespace llvm

INITIALIZE_PASS(BlockMerger, DEBUG_TYPE, PASS_NAME, false, false)

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

bool BlockMerger::runBlockMerging(MachineFunction& MF) {
  LLVM_DEBUG(dbgs() << "runBlockMerging: MF=" << MF.getName() << "\n");
  std::vector<std::pair<MachineBasicBlock *, bool>> MachineBasicBlockWorklist;
  for (MachineBasicBlock& MBB : MF) {
    ++NumBasicBlocks;
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

bool BlockMerger::runOnMachineFunction(MachineFunction& MF) {
  Subtarget = &MF.getSubtarget<PostriscSubtarget>();

  if (!Subtarget->getCLOpts().enable_block_merging)
    return false;

  LLVM_DEBUG(dbgs() << "BlockMerger: " << MF.getName() << "\n");
  bool Changed = false;

  const PostriscInstrInfo *PII = Subtarget->getInstrInfo();

  Changed |= runBlockMerging(MF);
  if (Changed) {
    LLVM_DEBUG(dbgs() << "Merged:\n"; MF.dump());
    MF.getRegInfo().invalidateLiveness();

    // This transformation may cause verification failures.
    // We need to merge blocks with several internal branches -
    // we merge fallthrough blocks,
    // even if there is cond branch at the end of previous block
    // also we insert padding non-terminal nops after final terminator
    MF.getProperties().setFailsVerification();
  }
  return Changed;
}

/// createPostriscBlockMergerPass
/// returns a pass that merges fallthrough blocks
///
FunctionPass *llvm::createPostriscBlockMergerPass() {
  return new BlockMerger;
}
