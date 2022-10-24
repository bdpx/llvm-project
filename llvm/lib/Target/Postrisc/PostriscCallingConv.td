//===-- PostriscCallingConv.td - Calling Conventions Postrisc -*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This describes the calling conventions for the Postrisc architectures.
//
//===----------------------------------------------------------------------===//

class CCIfArgIsNotVarArg<CCAction A>
  : CCIf<"State.isVarArg() && "
         "ValNo < static_cast<PostriscCCState&>(State).getNumNamedVarArgParams()", A>;

class CCIfArgIsVarArg<CCAction A>
  : CCIf<"State.isVarArg() && "
         "ValNo >= static_cast<PostriscCCState&>(State).getNumNamedVarArgParams()", A>;

def CC_Postrisc_C : CallingConv<[
  CCIfType<[iPTR], CCBitConvertToType<i64>>,
  CCIfInReg<CCIfType<[i64],
    CCIfSRet<CCIfType<[i64], CCAssignToReg<[r1, r2]>>>>>,

  CCIfSRet<CCIfType<[i64], CCAssignToReg<[r1]>>>,

  // Put ByVal arguments directly on the stack. Minimum size and alignment of a
  // slot is 64-bit.
  CCIfByVal<CCPassByVal<8, 8>>,

  // Handle i1, i8, i16, i32, i64, f16, f32, f64 and v2f64 by passing in registers,
  // up to eight each of GPR and FPR.
  CCIfType<[i8, i16], CCPromoteToType<i32>>,

  // for NON-VARARG func first 16 args are in regs
  CCIfType<[i1, i32, i64, i128, v2i64, v4i32, v8i16, v16i8,
            f16, f32, f64, f128, v8f16, v4f32, v2f64],
          CCIfNotVarArg<
          CCAssignToReg<[r1, r2, r3, r4, r5, r6, r7, r8,
                         r9, r10, r11, r12, r13, r14, r15, r16]>>>,

  // for VARARG func first 16 non-vararg args are in regs
  CCIfType<[i1, i32, i64, i128, v2i64, v4i32, v8i16, v16i8,
            f16, f32, f64, f128, v8f16, v4f32, v2f64],
          CCIfVarArg<CCIfArgIsNotVarArg<
          CCAssignToReg<[r1, r2, r3, r4, r5, r6, r7, r8,
                         r9, r10, r11, r12, r13, r14, r15, r16]>>>>,

  // all other passes on the stack instead.
  CCIfType<[i1, i8, i16, i32, f16, f32], CCAssignToStack<4, 4>>,
  CCIfType<[i64, f64], CCAssignToStack<8, 8>>,
  CCIfType<[f128, v2i64, v4i32, v8i16, v16i8, v8f16, v4f32, v2f64], CCAssignToStack<16, 16>>
]>;

def RetCC_Postrisc_C : CallingConv<[
  CCIfType<[iPTR], CCBitConvertToType<i64>>,
  CCIfType<[i8, i16], CCPromoteToType<i32>>,
  CCIfType<[i1, i32, i64, i128, v2i64, v4i32, v8i16, v16i8,
            f16, f32, f64, f128, v2f64, v4f32, v8f16],
          CCAssignToReg<[r1, r2, r3, r4, r5, r6, r7, r8]>>,
]>;

// Callee-saved registers are handled by the register window mechanism.
def CSR : CalleeSavedRegs<(add)> {
  let OtherPreserved = (add (sequence "r%u", 0, 119));
}
