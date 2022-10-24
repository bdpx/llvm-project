//===-- PostriscFrameLowering.cpp - Postrisc Frame Information ------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains the Postrisc implementation of TargetFrameLowering class.
//
//===----------------------------------------------------------------------===//

#include "PostriscFrameLowering.h"
#include "PostriscInstrInfo.h"
#include "PostriscMachineFunctionInfo.h"
#include "PostriscSubtarget.h"
#include "Postrisc.h"
#include "PostriscRegisterInfo.h"
#include "llvm/CodeGen/CFIInstBuilder.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineModuleInfo.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/Postrisc/PostriscBundle.h"
#include "llvm/Target/TargetOptions.h"

#define DEBUG_TYPE "postrisc-framelowering"

using namespace llvm;

static void dumpRegisterUsage(const MachineRegisterInfo &MRI)
{
  for (unsigned reg = POSTRISC::r0; reg <= POSTRISC::r119; ++reg) {
    dbgs() << MRI.isPhysRegUsed(reg);
  }
  dbgs() << "-";
  // globals aren't ordered
  for (unsigned reg : { POSTRISC::g0, POSTRISC::g1, POSTRISC::g2, POSTRISC::g3,
                        POSTRISC::tp, POSTRISC::fp, POSTRISC::sp, POSTRISC::gz }) {
    dbgs() << MRI.isPhysRegUsed(reg);
  }
  dbgs() << "\n";
}

static cl::opt<bool>
DisableLeafProc("disable-postrisc-leaf-proc",
                cl::init(false),
                cl::desc("Disable Postrisc leaf procedure optimization."),
                cl::Hidden);

PostriscFrameLowering::PostriscFrameLowering(const PostriscSubtarget &ST)
    : TargetFrameLowering(TargetFrameLowering::StackGrowsDown,
                          Align(16), 0, Align(16)) {}

void PostriscFrameLowering::emitSPAdjustment(MachineFunction &MF,
    MachineBasicBlock &MBB, MachineBasicBlock::iterator MBBI, int NumBytes) const {

  DebugLoc dl;
  const PostriscInstrInfo &TII =
      *static_cast<const PostriscInstrInfo *>(MF.getSubtarget().getInstrInfo());

  // addi sp, sp, NumBytes
  unsigned const Opcode = isInt<llvm::postrisc::InstructionFieldSize::BinaryImm>(NumBytes) ? POSTRISC::ADD_IMM_I64 : POSTRISC::ADD_IMM_I64_EXT;
  assert(isInt<llvm::postrisc::LongInstructionFieldSize::BinaryImm>(NumBytes));
  BuildMI(MBB, MBBI, dl, TII.get(Opcode), POSTRISC::sp)
    .addReg(POSTRISC::sp)
    .addImm(NumBytes);
}

void PostriscFrameLowering::emitPrologue(MachineFunction &MF,
                                      MachineBasicBlock &MBB) const {
  // PostriscMachineFunctionInfo *FuncInfo = MF.getInfo<PostriscMachineFunctionInfo>();

  assert(&MF.front() == &MBB && "Shrink-wrapping not yet supported");
  MachineRegisterInfo &MRI = MF.getRegInfo();

  LLVM_DEBUG(dbgs() << "emitPrologue: " << MF.getName() << "\n");
  LLVM_DEBUG(dumpRegisterUsage(MRI));

  unsigned LastUsedLocalRegister = POSTRISC::r0;
  for (unsigned reg = POSTRISC::r0; reg <= POSTRISC::r119; ++reg) {
      if (MRI.isPhysRegUsed(reg))
          LastUsedLocalRegister = reg;
  }
  LLVM_DEBUG(dbgs() << "LastUsedLocalRegister="
                    << PostriscRegisterInfo::getRegisterName(LastUsedLocalRegister) << "\n");

  MachineFrameInfo &MFI = MF.getFrameInfo();
  const PostriscSubtarget &Subtarget = MF.getSubtarget<PostriscSubtarget>();
  const PostriscInstrInfo &TII =
      *static_cast<const PostriscInstrInfo *>(Subtarget.getInstrInfo());
  const PostriscRegisterInfo &RegInfo =
      *static_cast<const PostriscRegisterInfo *>(Subtarget.getRegisterInfo());
  MachineBasicBlock::iterator MBBI = MBB.begin();
  // Debug location must be unknown since the first debug location is used
  // to determine the end of the prologue.
  DebugLoc dl;

  bool NeedsStackRealignment = RegInfo.shouldRealignStack(MF);

  if (NeedsStackRealignment && !RegInfo.canRealignStack(MF))
    report_fatal_error("Function \"" + Twine(MF.getName()) + "\" required "
                       "stack re-alignment, but LLVM couldn't handle it "
                       "(probably because it has a dynamic alloca).");

  // Get the number of bytes to allocate from the FrameInfo
  int64_t NumBytes = MFI.getStackSize();

  // all the stack objects are placed by
  // PrologEpilogInserter calculateFrameObjectOffsets. However, since the stack needs to be
  // aligned *after* the extra size is added, we need to disable
  // calculateFrameObjectOffsets's built-in stack alignment, by having
  // targetHandlesStackFrameRounding return true.


  // Add the extra call frame stack size, if needed. (This is the same
  // code as in PrologEpilogInserter, but also gets disabled by
  // targetHandlesStackFrameRounding)
  if (MFI.adjustsStack() && hasReservedCallFrame(MF))
    NumBytes += MFI.getMaxCallFrameSize();

  // Adds the POSTRISC subtarget-specific spill area to the stack
  // size. Also ensures target-required alignment.
  NumBytes = Subtarget.getAdjustedFrameSize(NumBytes);

  // Finally, ensure that the size is sufficiently aligned for the
  // data on the stack.
  NumBytes = alignTo(NumBytes, MFI.getMaxAlign());

  if (!hasFPImpl(MF) && NumBytes == 0) { // FuncInfo->isLeafProc()
    // the 'alloc' instruction extend current register window
    // Add it if we need new registers
    BuildMI(MBB, MBBI, dl, TII.get(POSTRISC::ALLOC))
           .addImm(LastUsedLocalRegister - POSTRISC::r0 + 1);
    MFI.setStackSize(NumBytes);
    return;
  }

  unsigned const Opcode = isUInt<llvm::postrisc::InstructionFieldSize::BinaryImm>(NumBytes) ? POSTRISC::ALLOCSP : POSTRISC::ALLOCSP_EXT;
  BuildMI(MBB, MBBI, dl, TII.get(Opcode))
    .addImm(LastUsedLocalRegister - POSTRISC::r0 + 1)
    .addImm(NumBytes);

  if (hasFPImpl(MF)) {
    PostriscMachineFunctionInfo *PostriscFI = MF.getInfo<PostriscMachineFunctionInfo>();
    MachineInstr *NewI = PostriscFI->getFrameSaveInstr();

    assert((NewI->getOpcode() == POSTRISC::ADD_IMM_I64 || NewI->getOpcode() == POSTRISC::ADD_IMM_I64_EXT)
           && "Can't find SP-save ADDri instruction!");
    assert(NewI->getOperand(0).isReg() && "1st operand should be register");
    assert(NewI->getOperand(1).isReg() && "2nd operand should be register");
    assert(NewI->getOperand(1).getReg() == POSTRISC::sp && "2nd operand should be SP register");
    assert(NewI->getOperand(2).isImm() && "3nd operand should be imm");
    NewI->getOperand(2).setImm(NumBytes);
    MFI.setStackSize(NumBytes);
    return;
  }

  // Update stack size with corrected value.
  MFI.setStackSize(NumBytes);
  if (NumBytes) {
    LLVM_DEBUG(dbgs() << "emitPrologue:SPAdjustment: " << -NumBytes << "\n");
    // emitSPAdjustment(MF, MBB, MBBI, -NumBytes);
  }

#if 0
  // FIXME: CFI
  unsigned regFP = RegInfo.getDwarfRegNum(POSTRISC::fp, true);

  // Emit ".cfi_def_cfa_register 30".
  unsigned CFIIndex =
      MF.addFrameInst(MCCFIInstruction::createDefCfaRegister(nullptr, regFP));
  BuildMI(MBB, MBBI, dl, TII.get(TargetOpcode::CFI_INSTRUCTION))
      .addCFIIndex(CFIIndex);

  // Emit ".cfi_window_save".
  CFIIndex = MF.addFrameInst(MCCFIInstruction::createWindowSave(nullptr));
  BuildMI(MBB, MBBI, dl, TII.get(TargetOpcode::CFI_INSTRUCTION))
      .addCFIIndex(CFIIndex);

  unsigned regInRA = RegInfo.getDwarfRegNum(POSTRISC::sp, true);
  unsigned regOutRA = RegInfo.getDwarfRegNum(POSTRISC::fp, true);
  // Emit ".cfi_register 15, 31".
  CFIIndex = MF.addFrameInst(
      MCCFIInstruction::createRegister(nullptr, regOutRA, regInRA));
  BuildMI(MBB, MBBI, dl, TII.get(TargetOpcode::CFI_INSTRUCTION))
      .addCFIIndex(CFIIndex);
#endif

  if (NeedsStackRealignment) {
    int64_t Bias = Subtarget.getStackPointerBias();
    unsigned regUnbiased;
    if (Bias) {
      // This clobbers G1 which we always know is available here.
      regUnbiased = POSTRISC::g1;
      // add %o6, BIAS, %g1
      BuildMI(MBB, MBBI, dl, TII.get(POSTRISC::ADD_IMM_I64), regUnbiased)
        .addReg(POSTRISC::sp).addImm(Bias);
    } else
      regUnbiased = POSTRISC::sp;

    // andn %regUnbiased, MaxAlign-1, %regUnbiased
    Align MaxAlign = MFI.getMaxAlign();
    unsigned const Opcode = isInt<llvm::postrisc::InstructionFieldSize::BinaryImm>(MaxAlign.value() - 1U) ? POSTRISC::ANDN_IMM : POSTRISC::ANDN_IMM_EXT;
    BuildMI(MBB, MBBI, dl, TII.get(Opcode), POSTRISC::sp)
        .addReg(POSTRISC::sp)
        .addImm(MaxAlign.value() - 1U);

    if (Bias) {
      // add %g1, -BIAS, %o6
      BuildMI(MBB, MBBI, dl, TII.get(POSTRISC::ADD_IMM_I64), POSTRISC::sp)
        .addReg(regUnbiased).addImm(-Bias);
    }
  }
}

MachineBasicBlock::iterator PostriscFrameLowering::
eliminateCallFramePseudoInstr(MachineFunction &MF, MachineBasicBlock &MBB,
                              MachineBasicBlock::iterator I) const {
  if (!hasReservedCallFrame(MF)) {
    MachineInstr &MI = *I;
    int64_t Size = MI.getOperand(0).getImm();
    if (MI.getOpcode() == POSTRISC::ADJCALLSTACKDOWN) {
      Size = -Size;
      LLVM_DEBUG(dbgs() << "eliminateCallFramePseudoInstr:ADJCALLSTACKDOWN" << Size << "\n");
    } else {
      LLVM_DEBUG(dbgs() << "eliminateCallFramePseudoInstr:ADJCALLSTACKUP" << Size << "\n");
    }

    if (Size) {
      emitSPAdjustment(MF, MBB, I, Size);
    }
  }
  return MBB.erase(I);
}


void PostriscFrameLowering::emitEpilogue(MachineFunction &MF,
                                  MachineBasicBlock &MBB) const {
  // PostriscMachineFunctionInfo *FuncInfo = MF.getInfo<PostriscMachineFunctionInfo>();
  LLVM_DEBUG(dbgs() << "emitEpilogue: " << MF.getName() << "\n"; MBB.dump());
  MachineBasicBlock::iterator MBBI = MBB.getLastNonDebugInstr();
  const PostriscInstrInfo &TII =
      *static_cast<const PostriscInstrInfo *>(MF.getSubtarget().getInstrInfo());
  DebugLoc dl = MBBI->getDebugLoc();
  if (MBBI->getOpcode() != POSTRISC::RETF)
     dbgs() << "MF=" << MF.getName() << " no RETF at the end\n";

  if (hasFPImpl(MF)) {
    // we do hasFPImpl save/restore SP/FP in PostriscFrameFixer
    return;
  }
  MachineFrameInfo &MFI = MF.getFrameInfo();
  uint64_t const NumBytes = MFI.getStackSize();
  if (NumBytes == 0) // retf already has default 0 SP adjustment
    return;

  LLVM_DEBUG(dbgs() << "emitEpilogue: SP adjustment: " << NumBytes << "\n");
  if (!isUInt<llvm::postrisc::InstructionFieldSize::BinaryImm>(NumBytes)) {
    assert(isUInt<llvm::postrisc::LongInstructionFieldSize::BinaryImm>(NumBytes));
    MBBI->setDesc(TII.get(POSTRISC::RETF_EXT));
  }
  assert(MBBI->getOperand(0).isImm() && "RETF Operand should be IMM");
  MBBI->getOperand(0).setImm(NumBytes);
}

bool PostriscFrameLowering::hasReservedCallFrame(const MachineFunction &MF) const {
  // Reserve call frame if there are no variable sized objects on the stack.
  return !MF.getFrameInfo().hasVarSizedObjects();
}

// hasFPImpl - Return true if the specified function should have a dedicated
// frame pointer register.  This is true if the function has variable sized
// allocas or if frame pointer elimination is disabled.
bool PostriscFrameLowering::hasFPImpl(const MachineFunction &MF) const {
  const TargetRegisterInfo *RegInfo = MF.getSubtarget().getRegisterInfo();
  const MachineFrameInfo &MFI = MF.getFrameInfo();
  return MF.getTarget().Options.DisableFramePointerElim(MF) ||
         RegInfo->hasStackRealignment(MF) ||
         MFI.hasVarSizedObjects() || MFI.isFrameAddressTaken();
}

StackOffset
PostriscFrameLowering::getFrameIndexReference(const MachineFunction &MF, int FI,
                                           Register &FrameReg) const {
  const PostriscSubtarget &Subtarget = MF.getSubtarget<PostriscSubtarget>();
  const MachineFrameInfo &MFI = MF.getFrameInfo();
  const PostriscRegisterInfo *RegInfo = Subtarget.getRegisterInfo();
  // const PostriscMachineFunctionInfo *FuncInfo = MF.getInfo<PostriscMachineFunctionInfo>();
  bool isFixed = MFI.isFixedObjectIndex(FI);

  // Addressable stack objects are accessed using neg. offsets from
  // temp %fp, or positive offsets from %sp.
  bool UseFP = hasFPImpl(MF);
  if (isFixed) {
    // argument access should always use %fp.
    LLVM_DEBUG(dbgs() << "isFixedObjectIndex: FI=" << FI << " MF=" << MF.getName() << "\n");
    // UseFP = true;
  } else if (RegInfo->hasStackRealignment(MF)) {
    dbgs() << "hasStackRealignment: MF=" << MF.getName() << "\n";
    // If there is dynamic stack realignment, all local object
    // references need to be via %sp, to take account of the
    // re-alignment.
    // UseFP = false;
  }

  int64_t FrameOffset = MF.getFrameInfo().getObjectOffset(FI) +
      Subtarget.getStackPointerBias();

  if (UseFP) {
    FrameReg = RegInfo->getFrameRegister(MF);
    LLVM_DEBUG(dbgs() << "getFrameIndexReference: " << MF.getName() << " FI=" << FI
                      << " FP=" << PostriscRegisterInfo::getRegisterName(FrameReg.id())
                      << " FrameOffset=" << FrameOffset << "\n");
    return StackOffset::getFixed(FrameOffset);
  } else {
    FrameReg = POSTRISC::sp;
    LLVM_DEBUG(dbgs() << "getFrameIndexReference: " << MF.getName() << " FI=" << FI
                      << " SP FrameOffset=" << FrameOffset
                      << " StackSize=" << MF.getFrameInfo().getStackSize() << "\n");
    return StackOffset::getFixed(FrameOffset + MF.getFrameInfo().getStackSize());
  }
}

bool PostriscFrameLowering::isLeafProc(MachineFunction &MF) const
{

  MachineRegisterInfo &MRI = MF.getRegInfo();
  MachineFrameInfo    &MFI = MF.getFrameInfo();

  return !(MFI.hasCalls()               // has calls
        // || MRI.isPhysRegUsed(POSTRISC::L0) // Too many registers needed
           || MRI.isPhysRegUsed(POSTRISC::sp) // %sp is used
           || hasFPImpl(MF)                 // need %fp
           || MF.hasInlineAsm());       // has inline assembly
}

void PostriscFrameLowering::remapOutputRegs(MachineFunction &MF) const {
  MachineRegisterInfo &MRI = MF.getRegInfo();
  LLVM_DEBUG(dbgs() << "usage map: " << MF.getName() << "\n");
  LLVM_DEBUG(dumpRegisterUsage(MRI));

  if (!MRI.isPhysRegUsed(POSTRISC::r119)) {
    LLVM_DEBUG(dbgs() << "!MRI.isPhysRegUsed(POSTRISC::r119): " << MF.getName() << "\n");
    // probably there is no calls inside
    return;
  }

  // assert(MRI.isPhysRegUsed(POSTRISC::r0)); //link register
  unsigned gap_stop = 0;
  for (unsigned reg = POSTRISC::r119; reg > POSTRISC::r0 && MRI.isPhysRegUsed(reg); --reg) {
    gap_stop = reg;
  }
  assert(gap_stop != 0);
  LLVM_DEBUG(dbgs() << "gap_stop=" << PostriscRegisterInfo::getRegisterName(gap_stop) << "\n");
  if (gap_stop == POSTRISC::r1) {
    // all regs are used
    return;
  }
  unsigned gap_start = 0;
  for (unsigned reg = gap_stop - 1; reg > POSTRISC::r0 && !MRI.isPhysRegUsed(reg); --reg) {
    gap_start = reg;
  }
  assert(gap_start != 0);
  LLVM_DEBUG(dbgs() << "gap_start=" << PostriscRegisterInfo::getRegisterName(gap_start) << "\n");

  unsigned const gap_len = gap_stop - gap_start;
  LLVM_DEBUG(dbgs() << " gap_len=" << gap_len << "\n");

  if (gap_len == 0) {
    LLVM_DEBUG(dbgs() << "gap_len == 0: " << MF.getName() << "\n");
    return;
  }

  // replace out registers
  for (unsigned reg = gap_stop; reg <= POSTRISC::r119; ++reg) {
    unsigned const mapped_reg = reg - gap_len;
    MRI.replaceRegWith(reg, mapped_reg);
  }

  // Rewrite MBB's Live-ins.
  for (MachineBasicBlock &MBB : MF) {
    for (unsigned reg = gap_stop; reg <= POSTRISC::r119; ++reg) {
      if (!MBB.isLiveIn(reg))
        continue;
      MBB.removeLiveIn(reg);
      MBB.addLiveIn(reg - gap_len);
    }
  }

  LLVM_DEBUG(dbgs() << "remapped: " << MF.getName() << "\n");
  LLVM_DEBUG(dumpRegisterUsage(MRI));

#ifdef EXPENSIVE_CHECKS
  MF.verify(0, "After output reg remapping");
#endif
}

// this function is called first
// so here we should detect if we need fp saving and prepare this
void PostriscFrameLowering::determineCalleeSaves(MachineFunction &MF,
                                              BitVector &SavedRegs,
                                              RegScavenger *RS) const {
  LLVM_DEBUG(dbgs() << "determineCalleeSaves: " << MF.getName() << "\n");
  TargetFrameLowering::determineCalleeSaves(MF, SavedRegs, RS);
  if (!DisableLeafProc && isLeafProc(MF)) {
    PostriscMachineFunctionInfo *MFI = MF.getInfo<PostriscMachineFunctionInfo>();
    MFI->setLeafProc(true);
  }
  remapOutputRegs(MF);
}
