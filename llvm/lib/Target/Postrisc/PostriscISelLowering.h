//===-- PostriscISelLowering.h - Postrisc DAG Lowering Interface ------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file defines the interfaces that Postrisc uses to lower LLVM code into a
// selection DAG.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_POSTRISC_POSTRISCISELLOWERING_H
#define LLVM_LIB_TARGET_POSTRISC_POSTRISCISELLOWERING_H

#include "Postrisc.h"
#include "llvm/CodeGen/TargetLowering.h"
#include "llvm/CodeGen/CallingConvLower.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/SelectionDAG.h"
#include "llvm/IR/CallingConv.h"
#include "llvm/IR/Instruction.h"

namespace llvm {
  class PostriscSubtarget;

  class PostriscTargetLowering : public TargetLowering {
    const PostriscSubtarget *Subtarget;
  public:
    PostriscTargetLowering(const TargetMachine &TM, const PostriscSubtarget &STI);
    SDValue LowerOperation(SDValue Op, SelectionDAG &DAG) const override;

    bool useSoftFloat() const override;

    /// computeKnownBitsForTargetNode - Determine which of the bits specified
    /// in Mask are known to be either zero or one and return them in the
    /// KnownZero/KnownOne bitsets.
    void computeKnownBitsForTargetNode(const SDValue Op,
                                       KnownBits &Known,
                                       const APInt &DemandedElts,
                                       const SelectionDAG &DAG,
                                       unsigned Depth = 0) const override;

    MVT getPointerTy(const DataLayout &DL, uint32_t AS = 0) const override {
      // Returning i64 unconditionally here means that
      // the *DAG* representation of pointers will always be 64-bits.
      // They may be truncated and extended when transferred to memory,
      // but the 64-bit DAG allows us to use addressing modes much more easily.
      return MVT::getIntegerVT(64);
    }

    MachineBasicBlock *
    EmitInstrWithCustomInserter(MachineInstr &MI,
                                MachineBasicBlock *MBB) const override;

    ConstraintType getConstraintType(StringRef Constraint) const override;
    ConstraintWeight
    getSingleConstraintMatchWeight(AsmOperandInfo &info,
                                   const char *constraint) const override;
    void LowerAsmOperandForConstraint(SDValue Op, StringRef Constraint,
                                      std::vector<SDValue> &Ops,
                                      SelectionDAG &DAG) const override;

    std::pair<unsigned, const TargetRegisterClass *>
    getRegForInlineAsmConstraint(const TargetRegisterInfo *TRI,
                                 StringRef Constraint, MVT VT) const override;

    bool isOffsetFoldingLegal(const GlobalAddressSDNode *GA) const override;
    MVT getScalarShiftAmountTy(const DataLayout &, EVT) const override {
      return MVT::i32;
    }

    Register getRegisterByName(const char* RegName, LLT VT,
                               const MachineFunction &MF) const override;

    /// If a physical register, this returns the register that receives the
    /// exception address on entry to an EH pad.
    Register
    getExceptionPointerRegister(const Constant *PersonalityFn) const override {
      return POSTRISC::g1;
    }

    /// If a physical register, this returns the register that receives the
    /// exception typeid on entry to a landing pad.
    Register
    getExceptionSelectorRegister(const Constant *PersonalityFn) const override {
      return POSTRISC::g2;
    }

    bool isIntDivCheap(EVT VT, AttributeList Attr) const override;

    /// Override to support customized stack guard loading.
    bool useLoadStackGuardNode(const Module &M) const override;

    /// getSetCCResultType - Return the ISD::SETCC ValueType
    EVT getSetCCResultType(const DataLayout &DL, LLVMContext &Context,
                           EVT VT) const override;

    SDValue
    LowerFormalArguments(SDValue Chain, CallingConv::ID CallConv, bool isVarArg,
                         const SmallVectorImpl<ISD::InputArg> &Ins,
                         const SDLoc &dl, SelectionDAG &DAG,
                         SmallVectorImpl<SDValue> &InVals) const override;

    SDValue
      LowerCall(TargetLowering::CallLoweringInfo &CLI,
                SmallVectorImpl<SDValue> &InVals) const override;
    bool CanLowerReturn(CallingConv::ID CallConv, MachineFunction &MF,
                        bool isVarArg,
                        const SmallVectorImpl<ISD::OutputArg> &Outs,
                        LLVMContext &Context, const Type *RetTy) const override;

    SDValue LowerReturn(SDValue Chain, CallingConv::ID CallConv, bool isVarArg,
                        const SmallVectorImpl<ISD::OutputArg> &Outs,
                        const SmallVectorImpl<SDValue> &OutVals,
                        const SDLoc &dl, SelectionDAG &DAG) const override;

    SDValue getTargetNode(GlobalAddressSDNode  *N, EVT Ty, SelectionDAG &DAG, unsigned Flag) const;
    SDValue getTargetNode(ExternalSymbolSDNode *N, EVT Ty, SelectionDAG &DAG, unsigned Flag) const;
    SDValue getTargetNode(JumpTableSDNode      *N, EVT Ty, SelectionDAG &DAG, unsigned Flag) const;
    SDValue getTargetNode(ConstantPoolSDNode   *N, EVT Ty, SelectionDAG &DAG, unsigned Flag) const;
    SDValue getTargetNode(BlockAddressSDNode   *N, EVT Ty, SelectionDAG &DAG, unsigned Flag) const;

    SDValue withTargetFlags(SDValue Op, unsigned TF, SelectionDAG &DAG) const;
    SDValue makeAddress(SDValue Op, SelectionDAG &DAG, bool isCode) const;

    SDValue LowerGlobalAddress(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerExternalSymbol(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerGlobalTLSAddress(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerConstantPool(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerBlockAddress(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerJumpTable(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerRETURNADDR(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerFRAMEADDR(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerVASTART(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerDYNAMIC_STACKALLOC(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerSTORE(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerATOMIC_LOAD_STORE(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerATOMIC_FENCE(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerINTRINSIC_WO_CHAIN(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerINTRINSIC_VOID(SDValue Op, SelectionDAG &DAG) const;

    SDValue PerformBITCASTCombine(SDNode *N, DAGCombinerInfo &DCI) const;

    SDValue bitcastConstantFPToInt(ConstantFPSDNode *C, const SDLoc &DL,
                                   SelectionDAG &DAG) const;

    SDValue PerformDAGCombine(SDNode *N, DAGCombinerInfo &DCI) const override;

    bool IsEligibleForTailCallOptimization(CCState &CCInfo,
                                           CallLoweringInfo &CLI,
                                           MachineFunction &MF) const;

    bool ShouldShrinkFPConstant(EVT VT) const override {
      // Do not shrink FP constpool if VT == MVT::f128.
      // (ldd, call _Q_fdtoq) is more expensive than two ldds.
      return VT != MVT::f128;
    }

    bool isFNegFree(EVT VT) const override;

    bool isFPImmLegal(const APFloat &Imm, EVT VT,
                      bool ForCodeSize) const override;

    bool isCtlzFast() const override { return true; }

    bool isCheapToSpeculateCtlz(Type *Ty) const override {
      return isCtlzFast();
    }

    bool isCheapToSpeculateCttz(Type *Ty) const override {
      return isCtlzFast();
    }

    bool shouldInsertFencesForAtomic(const Instruction *I) const override;

    AtomicExpansionKind
    shouldExpandAtomicRMWInIR(const AtomicRMWInst *AI) const override;

    /// Returns how the platform's atomic operations are extended (ZERO_EXTEND,
    /// SIGN_EXTEND, or ANY_EXTEND).
    /// TargetLowering inherited value is ZERO_EXTEND.
    /// But we need to fix this and do manually later differently:
    /// SIGN_EXTEND for SMIN, SMAX
    /// ZERO_EXTEND for ADD, SUB, AND, OR, XOR, UMIN, UMAX
    ISD::NodeType getExtendForAtomicOps() const override {
      return ISD::ZERO_EXTEND;
    }

    /// Returns how the platform's atomic compare and swap expects its comparison
    /// value to be extended (ZERO_EXTEND, SIGN_EXTEND, or ANY_EXTEND). This is
    /// separate from getExtendForAtomicOps, which is concerned with the
    /// sign-extension of the instruction's output, whereas here we are concerned
    /// with the sign-extension of the input. For targets with compare-and-swap
    /// instructions (or sub-word comparisons in their LL/SC loop expansions),
    /// the input can be ANY_EXTEND, but the output will still have a specific
    /// extension.
    ISD::NodeType getExtendForAtomicCmpSwapArg() const override {
      return ISD::ANY_EXTEND;
    }

    /// Returns how the platform's atomic rmw operations expect their input
    /// argument to be extended (ZERO_EXTEND, SIGN_EXTEND, or ANY_EXTEND).
    ISD::NodeType getExtendForAtomicRMWArg(unsigned Op) const override {
      return ISD::ANY_EXTEND;
    }

    void ReplaceNodeResults(SDNode *N,
                            SmallVectorImpl<SDValue>& Results,
                            SelectionDAG &DAG) const override;

    MachineBasicBlock *expandSelectCC(MachineInstr &MI, MachineBasicBlock *BB,
                                      unsigned BROpcode) const;

    // TODO: the default is the same as pointer type,
    // but BR_JT emit unneeded zero extension if the index is i32.
    // Because switch with i32 index is more usable than with i64, may be better use i32.
    // Currently crashes with i32.
    MVT getJumpTableRegTy(const DataLayout &) const override { return MVT::i64; }

    unsigned getJumpTableEncoding() const override;
    const MCExpr *
    LowerCustomJumpTableEntry(const MachineJumpTableInfo *MJTI,
                              const MachineBasicBlock *MBB, unsigned uid,
                              MCContext &Ctx) const override;

    /// Returns relocation base for the given PIC jumptable.
    SDValue getPICJumpTableRelocBase(SDValue Table,
                                     SelectionDAG &DAG) const override;
    const MCExpr *
    getPICJumpTableRelocBaseExpr(const MachineFunction *MF,
                                 unsigned JTI, MCContext &Ctx) const override;

    Instruction *emitLeadingFence(IRBuilderBase &Builder,
                 Instruction *Inst, AtomicOrdering Ord) const override;

    Instruction *emitTrailingFence(IRBuilderBase &Builder,
                  Instruction *Inst, AtomicOrdering Ord) const override;

    bool shouldInsertTrailingSeqCstFenceForAtomicStore(const Instruction *I) const override;

    bool isFMAFasterThanFMulAndFAdd(const MachineFunction &MF, EVT VT) const override;

    // Return true if the half type should be promoted using soft promotion rules
    // where each operation is promoted to f32 individually, then converted to
    // fp16. The default behavior (false) is to promote chains of operations, keeping
    // intermediate results in f32 precision and range.
    // bool softPromoteHalfType() const override { return true; }

    bool IsCodeModelExtInsnRequired(bool is_code = true) const;

    /// Selects the correct CCAssignFn for a given CallingConvention value.
    CCAssignFn *CCAssignFnForCall(CallingConv::ID CC, bool IsVarArg) const;
    /// Selects the correct CCAssignFn for a given CallingConvention value.
    CCAssignFn *CCAssignFnForReturn(CallingConv::ID CC, bool IsVarArg) const;
  };
} // end namespace llvm

#endif // LLVM_LIB_TARGET_POSTRISC_POSTRISCISELLOWERING_H
