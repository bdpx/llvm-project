//===-- PostriscInstrInfo.h - Postrisc Instruction Information --------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains the Postrisc implementation of the TargetInstrInfo class.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_POSTRISC_POSTRISCINSTRINFO_H
#define LLVM_LIB_TARGET_POSTRISC_POSTRISCINSTRINFO_H

#include "PostriscRegisterInfo.h"
#include "llvm/CodeGen/TargetInstrInfo.h"

#define GET_INSTRINFO_HEADER
#include "PostriscGenInstrInfo.inc"

namespace llvm {

class PostriscSubtarget;

/// SPII - This namespace holds all of the target specific flags that
/// instruction info tracks.
///
namespace SPII {
  enum {
    Pseudo = (1<<0),
    Load = (1<<1),
    Store = (1<<2),
  };
}

// based on TargetInstrInfo
class PostriscInstrInfo : public PostriscGenInstrInfo {
  const PostriscRegisterInfo RI;
  const PostriscSubtarget& Subtarget;
  virtual void anchor();
public:
  explicit PostriscInstrInfo(const PostriscSubtarget &ST);

  /// getRegisterInfo - TargetInstrInfo is a superset of MRegister info.  As
  /// such, whenever a client has an instance of instruction info, it should
  /// always be able to get register info as well (through this method).
  ///
  const PostriscRegisterInfo &getRegisterInfo() const { return RI; }

  bool isLong(unsigned Opc) const;
  MachineBasicBlock *getBranchTargetMBB(const MachineInstr *Inst) const;
  MachineBasicBlock *getLastSuccessor(MachineBasicBlock& MBB) const;
  bool isUncondBranchOpcode(unsigned Opc) const;
  bool isIndirectBranchOpcode(unsigned Opc) const;
  bool isCondBranchOpcode(unsigned Opc) const;
  void parseCondBranch(MachineInstr *LastInst, MachineBasicBlock *&Target,
                       SmallVectorImpl<MachineOperand> &Cond) const;

  bool getBaseAndOffsetPosition(const MachineInstr& MI,
           unsigned &BasePos, unsigned &OffsetPos) const override;

  bool isPostIncrement(const MachineInstr &MI) const override;

  // Postrisc-specific
  bool isPreIncrement(const MachineInstr &MI) const;

  /// isLoadFromStackSlot - If the specified machine instruction is a direct
  /// load from a stack slot, return the virtual or physical register number of
  /// the destination along with the FrameIndex of the loaded stack slot.  If
  /// not, return 0.  This predicate must return 0 if the instruction has
  /// any side effects other than loading from the stack slot.
  Register isLoadFromStackSlot(const MachineInstr &MI,
                               int &FrameIndex) const override;

  /// isStoreToStackSlot - If the specified machine instruction is a direct
  /// store to a stack slot, return the virtual or physical register number of
  /// the source reg along with the FrameIndex of the loaded stack slot.  If
  /// not, return 0.  This predicate must return 0 if the instruction has
  /// any side effects other than storing to the stack slot.
  Register isStoreToStackSlot(const MachineInstr &MI,
                              int &FrameIndex) const override;

  MachineBasicBlock *getBranchDestBlock(const MachineInstr &MI) const override;

  bool analyzeBranch(MachineBasicBlock &MBB, MachineBasicBlock *&TBB,
                     MachineBasicBlock *&FBB,
                     SmallVectorImpl<MachineOperand> &Cond,
                     bool AllowModify = false) const override;

  bool analyzeBranchPredicate(MachineBasicBlock &MBB,
                              MachineBranchPredicate &MBP,
                              bool AllowModify) const override;

  unsigned removeBranch(MachineBasicBlock &MBB,
                        int *BytesRemoved = nullptr) const override;

  unsigned insertBranch(MachineBasicBlock &MBB, MachineBasicBlock *TBB,
                        MachineBasicBlock *FBB, ArrayRef<MachineOperand> Cond,
                        const DebugLoc &DL,
                        int *BytesAdded = nullptr) const override;

  // helper function for `insertBranch`
  void instantiateCondBranch(MachineBasicBlock &MBB, const DebugLoc &DL,
                             MachineBasicBlock *TBB, ArrayRef<MachineOperand> Cond) const;

  bool
  reverseBranchCondition(SmallVectorImpl<MachineOperand> &Cond) const override;

  /// Determine if the branch target is in range.
  bool isBranchOffsetInRange(unsigned BranchOpc, int64_t Offset) const override;

  void copyPhysReg(MachineBasicBlock &MBB, MachineBasicBlock::iterator I,
                   const DebugLoc &DL, Register DestReg, Register SrcReg,
                   bool KillSrc, bool RenamableDest = false,
                   bool RenamableSrc = false) const override;

  void storeRegToStackSlot(
      MachineBasicBlock &MBB, MachineBasicBlock::iterator MBBI, Register SrcReg,
      bool isKill, int FrameIndex, const TargetRegisterClass *RC,
      const TargetRegisterInfo *TRI, Register VReg,
      MachineInstr::MIFlag Flags = MachineInstr::NoFlags) const override;

  void loadRegFromStackSlot(
      MachineBasicBlock &MBB, MachineBasicBlock::iterator MBBI,
      Register DestReg, int FrameIndex, const TargetRegisterClass *RC,
      const TargetRegisterInfo *TRI, Register VReg,
      MachineInstr::MIFlag Flags = MachineInstr::NoFlags) const override;

  // Lower pseudo instructions after register allocation.
  bool expandPostRAPseudo(MachineInstr &MI) const override;
};

}

#endif
