//===------ PostriscCallingConv.h - Postrisc CC entry points ----*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file declares the entry points for Postrisc calling convention analysis.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_POSTRISC_POSTRISCCALLINGCONV_H
#define LLVM_LIB_TARGET_POSTRISC_POSTRISCCALLINGCONV_H

#include "llvm/CodeGen/CallingConvLower.h"

namespace llvm {

// see HexagonCCState
class PostriscCCState : public CCState {
  unsigned NumNamedVarArgParams = 0;

public:
  PostriscCCState(CallingConv::ID CC, bool IsVarArg, MachineFunction &MF,
                  SmallVectorImpl<CCValAssign> &locs, LLVMContext &C,
                  unsigned NumNamedArgs)
      : CCState(CC, IsVarArg, MF, locs, C),
        NumNamedVarArgParams(NumNamedArgs) {}
  unsigned getNumNamedVarArgParams() const { return NumNamedVarArgParams; }
};

bool CC_Postrisc_C(unsigned ValNo, MVT ValVT, MVT LocVT,
                   CCValAssign::LocInfo LocInfo, ISD::ArgFlagsTy ArgFlags,
                   CCState &State);
bool RetCC_Postrisc_C(unsigned ValNo, MVT ValVT, MVT LocVT,
                      CCValAssign::LocInfo LocInfo, ISD::ArgFlagsTy ArgFlags,
                      CCState &State);
} // namespace llvm

#endif
