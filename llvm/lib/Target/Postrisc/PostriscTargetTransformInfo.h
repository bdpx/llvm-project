//===-- PostriscTargetTransformInfo.cpp - POSTRISC specific TTI--------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
/// \file
/// This file a TargetTransformInfoImplBase conforming object specific to the
/// POSTRISC target machine. It uses the target's detailed information to
/// provide more precise answers to certain TTI queries, while letting the
/// target independent and default TTI implementations handle the rest.
///
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_POSTRISC_POSTRISCTARGETTRANSFORMINFO_H
#define LLVM_LIB_TARGET_POSTRISC_POSTRISCTARGETTRANSFORMINFO_H

#include "PostriscTargetMachine.h"
#include "llvm/Analysis/TargetTransformInfo.h"
#include "llvm/CodeGen/BasicTTIImpl.h"

namespace llvm {

class PostriscTTIImpl final : public BasicTTIImplBase<PostriscTTIImpl> {
  typedef BasicTTIImplBase<PostriscTTIImpl> BaseT;
  typedef TargetTransformInfo TTI;
  friend BaseT;

  const PostriscSubtarget *ST;
  const PostriscTargetLowering *TLI;

  const PostriscSubtarget *getST() const { return ST; }
  const PostriscTargetLowering *getTLI() const { return TLI; }

public:
  explicit PostriscTTIImpl(const PostriscTargetMachine *TM, const Function &F)
      : BaseT(TM, F.getDataLayout()), ST(TM->getSubtargetImpl(F)),
        TLI(ST->getTargetLowering()) {}

  /// \name Scalar TTI Implementations
  /// @{
  TTI::PopcntSupportKind getPopcntSupport(unsigned TyWidth) const override;
  /// @}

  /// \name Vector TTI Implementations
  /// @{
  enum PostriscRegisterClass { GPRRC };
  unsigned getNumberOfRegisters(unsigned ClassID) const override;
  unsigned getRegisterClassForType(bool Vector,
                                   Type *Ty = nullptr) const override;
  TypeSize
  getRegisterBitWidth(TargetTransformInfo::RegisterKind K) const override;

  InstructionCost getPartialReductionCost(
      unsigned Opcode, Type *InputTypeA, Type *InputTypeB, Type *AccumType,
      ElementCount VF, TTI::PartialReductionExtendKind OpAExtend,
      TTI::PartialReductionExtendKind OpBExtend, std::optional<unsigned> BinOp,
      TTI::TargetCostKind CostKind,
      std::optional<FastMathFlags> FMF) const override {
    return InstructionCost::getInvalid();
  }
  /// @}
};

} // end namespace llvm

#endif
