//===- IntrinsicsPostrisc.td - Defines Postrisc intrinsics -*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file defines all of the POSTRISC-specific intrinsics.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// DSP data types
def postrisc_v2q15_ty: LLVMType<v2i16>;
def postrisc_v4q7_ty: LLVMType<v4i8>;
def postrisc_q31_ty: LLVMType<i32>;

// ImmArg<ArgIndex<0>>

// All intrinsics start with "llvm.postrisc.".
let TargetPrefix = "postrisc" in {

///////////////////////////////////////////////////////////////////////////////////////
// patterns
///////////////////////////////////////////////////////////////////////////////////////
multiclass int_postrisc_r2<LLVMType Ta, LLVMType Tb> {
  def int_postrisc_ # NAME : ClangBuiltin<!strconcat("__builtin_postrisc_", NAME)>,
      Intrinsic<[Ta], [Tb], [IntrNoMem]>;
}

multiclass int_postrisc_r3<LLVMType Ta, LLVMType Tb, LLVMType Tc> {
  def int_postrisc_ # NAME : ClangBuiltin<!strconcat("__builtin_postrisc_", NAME)>,
      Intrinsic<[Ta], [Tb, Tc], [IntrNoMem]>;
}

multiclass int_postrisc_r4<LLVMType Ta, LLVMType Tb, LLVMType Tc, LLVMType Td> {
  def int_postrisc_ # NAME : ClangBuiltin<!strconcat("__builtin_postrisc_", NAME)>,
      Intrinsic<[Ta], [Tb, Tc, Td], [IntrNoMem]>;
}

// FIXME: may be implemented as global builtin in future
def int_postrisc_set_thread_pointer : ClangBuiltin<"__builtin_postrisc_set_thread_pointer">, DefaultAttrsIntrinsic<[], [llvm_ptr_ty], [IntrNoMem, IntrHasSideEffects]>;

def int_postrisc_int      : ClangBuiltin<"__builtin_postrisc_int"     >, Intrinsic<[], [llvm_i64_ty], []>;
def int_postrisc_syscall  : ClangBuiltin<"__builtin_postrisc_syscall" >, Intrinsic<[], [], []>;
def int_postrisc_sysret   : ClangBuiltin<"__builtin_postrisc_sysret"  >, Intrinsic<[], [], []>;
def int_postrisc_cpuid    : ClangBuiltin<"__builtin_postrisc_cpuid"   >, Intrinsic<[llvm_i64_ty], [llvm_i64_ty], []>;
def int_postrisc_tpa      : ClangBuiltin<"__builtin_postrisc_tpa"     >, Intrinsic<[llvm_i64_ty], [llvm_ptr_ty, llvm_i64_ty], []>;
def int_postrisc_halt     : ClangBuiltin<"__builtin_postrisc_halt"    >, Intrinsic<[], [], [IntrNoMem, IntrHasSideEffects]>;
def int_postrisc_undef    : ClangBuiltin<"__builtin_postrisc_undef"   >, Intrinsic<[], [], [IntrNoMem, IntrHasSideEffects]>;
def int_postrisc_rfi      : ClangBuiltin<"__builtin_postrisc_rfi"     >, Intrinsic<[], [], [IntrNoMem, IntrHasSideEffects]>;
def int_postrisc_nop      : ClangBuiltin<"__builtin_postrisc_nop"     >, Intrinsic<[], [llvm_i64_ty], [IntrNoMem, IntrHasSideEffects]>;
def int_postrisc_nop_l    : ClangBuiltin<"__builtin_postrisc_nop_l"   >, Intrinsic<[], [llvm_i64_ty], [IntrNoMem, IntrHasSideEffects]>;
def int_postrisc_random_n : ClangBuiltin<"__builtin_postrisc_random_n">, Intrinsic<[llvm_i64_ty], [llvm_i64_ty], [IntrNoMem, IntrHasSideEffects]>;
def int_postrisc_random   : ClangBuiltin<"__builtin_postrisc_random"  >, Intrinsic<[llvm_i64_ty], [], [IntrNoMem, IntrHasSideEffects]>;
def int_postrisc_dcbf     : ClangBuiltin<"__builtin_postrisc_dcbf"    >, DefaultAttrsIntrinsic<[], [llvm_ptr_ty], [IntrNoMem, IntrHasSideEffects]>;
def int_postrisc_dcbi     : ClangBuiltin<"__builtin_postrisc_dcbi"    >, DefaultAttrsIntrinsic<[], [llvm_ptr_ty], [IntrNoMem, IntrHasSideEffects]>;
def int_postrisc_dcbt     : ClangBuiltin<"__builtin_postrisc_dcbt"    >, DefaultAttrsIntrinsic<[], [llvm_ptr_ty], [IntrNoMem, IntrHasSideEffects]>;
def int_postrisc_icbi     : ClangBuiltin<"__builtin_postrisc_icbi"    >, DefaultAttrsIntrinsic<[], [llvm_ptr_ty], [IntrNoMem, IntrHasSideEffects]>;
def int_postrisc_eh_throw : ClangBuiltin<"__builtin_postrisc_eh_throw">, DefaultAttrsIntrinsic<[], [llvm_i64_ty], [IntrNoMem, IntrHasSideEffects]>;

// trick to test branch instructions
def int_postrisc_nul_never : ClangBuiltin<"__builtin_postrisc_nul_never">, Intrinsic<[], [llvm_i64_ty], [IntrNoMem, IntrHasSideEffects]>;

///////////////////////////////////////////////////////////////////////////////////////
// TLB
///////////////////////////////////////////////////////////////////////////////////////

def int_postrisc_tlb_purge : ClangBuiltin<"__builtin_postrisc_tlb_purge">,
  Intrinsic<[], [llvm_ptr_ty, llvm_ptr_ty, llvm_i32_ty], []>;

///////////////////////////////////////////////////////////////////////////////////////
// stack/frame
///////////////////////////////////////////////////////////////////////////////////////
def int_postrisc_stack_pointer : ClangBuiltin<"__builtin_postrisc_stack_pointer">,
      Intrinsic<[llvm_i64_ty], [], []>;

///////////////////////////////////////////////////////////////////////////////////////
// special registers
///////////////////////////////////////////////////////////////////////////////////////
multiclass int_postrisc_special_reg<LLVMType Ty> {
  def int_postrisc_get_ # NAME : ClangBuiltin<!strconcat("__builtin_postrisc_get_", NAME)>,
      Intrinsic<[Ty], [], [IntrNoMem]>;
  def int_postrisc_set_ # NAME : ClangBuiltin<!strconcat("__builtin_postrisc_set_", NAME)>,
      Intrinsic<[], [Ty], [IntrNoMem, IntrHasSideEffects]>;
}

defm ip:    int_postrisc_special_reg<llvm_i64_ty>;
defm eip:   int_postrisc_special_reg<llvm_i64_ty>;
defm fpcr:  int_postrisc_special_reg<llvm_i64_ty>;
defm eca:   int_postrisc_special_reg<llvm_i64_ty>;
defm rsc:   int_postrisc_special_reg<llvm_i64_ty>;
defm rsp:   int_postrisc_special_reg<llvm_i64_ty>;
defm bsp:   int_postrisc_special_reg<llvm_i64_ty>;
defm psr:   int_postrisc_special_reg<llvm_i64_ty>;
defm reip:  int_postrisc_special_reg<llvm_i64_ty>;
defm kip:   int_postrisc_special_reg<llvm_i64_ty>;
defm ksp:   int_postrisc_special_reg<llvm_i64_ty>;
defm krsp:  int_postrisc_special_reg<llvm_i64_ty>;
defm peb:   int_postrisc_special_reg<llvm_i64_ty>;
defm teb:   int_postrisc_special_reg<llvm_i64_ty>;
defm itc:   int_postrisc_special_reg<llvm_i64_ty>;
defm itm:   int_postrisc_special_reg<llvm_i64_ty>;
defm pta:   int_postrisc_special_reg<llvm_i64_ty>;
defm iva:   int_postrisc_special_reg<llvm_i64_ty>;
defm iip:   int_postrisc_special_reg<llvm_i64_ty>;
defm iipa:  int_postrisc_special_reg<llvm_i64_ty>;
defm ipsr:  int_postrisc_special_reg<llvm_i64_ty>;
defm cause: int_postrisc_special_reg<llvm_i64_ty>;
defm ifa:   int_postrisc_special_reg<llvm_i64_ty>;
defm iib:   int_postrisc_special_reg<llvm_i128_ty>;
defm irr0:  int_postrisc_special_reg<llvm_i64_ty>;
defm irr1:  int_postrisc_special_reg<llvm_i64_ty>;
defm irr2:  int_postrisc_special_reg<llvm_i64_ty>;
defm irr3:  int_postrisc_special_reg<llvm_i64_ty>;
defm isr0:  int_postrisc_special_reg<llvm_i64_ty>;
defm isr1:  int_postrisc_special_reg<llvm_i64_ty>;
defm isr2:  int_postrisc_special_reg<llvm_i64_ty>;
defm isr3:  int_postrisc_special_reg<llvm_i64_ty>;
defm iv:    int_postrisc_special_reg<llvm_i64_ty>;
defm lid:   int_postrisc_special_reg<llvm_i64_ty>;
defm tpr:   int_postrisc_special_reg<llvm_i64_ty>;
defm itcv:  int_postrisc_special_reg<llvm_i64_ty>;
defm tsv:   int_postrisc_special_reg<llvm_i64_ty>;
defm pmv:   int_postrisc_special_reg<llvm_i64_ty>;
defm cmcv:  int_postrisc_special_reg<llvm_i64_ty>;

///////////////////////////////////////////////////////////////////////////////////////
// debug registers
///////////////////////////////////////////////////////////////////////////////////////

def int_postrisc_get_mr : ClangBuiltin<"__builtin_postrisc_get_mr">,
  Intrinsic<[llvm_i64_ty], [llvm_i64_ty], []>;
def int_postrisc_set_mr : ClangBuiltin<"__builtin_postrisc_set_mr">,
  Intrinsic<[], [llvm_i64_ty, llvm_i64_ty], []>;
def int_postrisc_get_ibr : ClangBuiltin<"__builtin_postrisc_get_ibr">,
  Intrinsic<[llvm_i64_ty], [llvm_i64_ty], []>;
def int_postrisc_set_ibr : ClangBuiltin<"__builtin_postrisc_set_ibr">,
  Intrinsic<[], [llvm_i64_ty, llvm_i64_ty], []>;
def int_postrisc_get_dbr : ClangBuiltin<"__builtin_postrisc_get_dbr">,
  Intrinsic<[llvm_i64_ty], [llvm_i64_ty], []>;
def int_postrisc_set_dbr : ClangBuiltin<"__builtin_postrisc_set_dbr">,
  Intrinsic<[], [llvm_i64_ty, llvm_i64_ty], []>;

///////////////////////////////////////////////////////////////////////////////////////
// Advanced Encryption Standard (AES) Instructions
///////////////////////////////////////////////////////////////////////////////////////

defm aesimc     : int_postrisc_r2<llvm_v2i64_ty, llvm_v2i64_ty>;
defm aesenc     : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;
defm aesenclast : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;
defm aesdec     : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;
defm aesdeclast : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;

def int_postrisc_aeskeygenassist : ClangBuiltin<"__builtin_postrisc_aeskeygenassist">,
  Intrinsic<[llvm_v2i64_ty], [llvm_v2i64_ty, llvm_i8_ty], [IntrNoMem, ImmArg<ArgIndex<1>>]>;

///////////////////////////////////////////////////////////////////////////////////////
// hashing, carry less multiply
///////////////////////////////////////////////////////////////////////////////////////

defm clmul_ll : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;
defm clmul_hl : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;
defm clmul_hh : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;

defm crc32c  : int_postrisc_r4<llvm_i32_ty, llvm_i32_ty, llvm_i128_ty, llvm_i64_ty>;

///////////////////////////////////////////////////////////////////////////////////////
// fp scalar
///////////////////////////////////////////////////////////////////////////////////////
multiclass FP_Scalar<LLVMType Ty> {
  defm abs        # NAME : int_postrisc_r2<Ty, Ty>;
  defm nabs       # NAME : int_postrisc_r2<Ty, Ty>;
  defm neg        # NAME : int_postrisc_r2<Ty, Ty>;
  defm rsqrt      # NAME : int_postrisc_r2<Ty, Ty>;
  defm sqrt       # NAME : int_postrisc_r2<Ty, Ty>;

  defm abs_diff   # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm nabs_diff  # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm add        # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm nadd       # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm abs_min    # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm abs_max    # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm min        # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm max        # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm minnum     # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm maxnum     # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm div        # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm dot        # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm mul        # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm nmul       # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm sub        # NAME : int_postrisc_r3<Ty, Ty, Ty>;

  defm madd       # NAME : int_postrisc_r4<Ty, Ty, Ty, Ty>;
  defm nmadd      # NAME : int_postrisc_r4<Ty, Ty, Ty, Ty>;
  defm msub       # NAME : int_postrisc_r4<Ty, Ty, Ty, Ty>;
  defm nmsub      # NAME : int_postrisc_r4<Ty, Ty, Ty, Ty>;
  defm merge      # NAME : int_postrisc_r4<Ty, Ty, Ty, Ty>;
}

defm _f16  : FP_Scalar<llvm_half_ty>;
defm _f32  : FP_Scalar<llvm_float_ty>;
defm _f64  : FP_Scalar<llvm_double_ty>;
defm _f128 : FP_Scalar<llvm_f128_ty>;

///////////////////////////////////////////////////////////////////////////////////////
// fp vector
///////////////////////////////////////////////////////////////////////////////////////
multiclass FP_Vector<LLVMType Ty> {
  defm abs        # NAME : int_postrisc_r2<Ty, Ty>;
  defm nabs       # NAME : int_postrisc_r2<Ty, Ty>;
  defm neg        # NAME : int_postrisc_r2<Ty, Ty>;
  defm rsqrt      # NAME : int_postrisc_r2<Ty, Ty>;
  defm sqrt       # NAME : int_postrisc_r2<Ty, Ty>;

  defm abs_diff   # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm nabs_diff  # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm add        # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm nadd       # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm abs_min    # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm abs_max    # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm min        # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm max        # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm minnum     # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm maxnum     # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm div        # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm dot        # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm mul        # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm nmul       # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm sub        # NAME : int_postrisc_r3<Ty, Ty, Ty>;

  defm madd       # NAME : int_postrisc_r4<Ty, Ty, Ty, Ty>;
  defm nmadd      # NAME : int_postrisc_r4<Ty, Ty, Ty, Ty>;
  defm msub       # NAME : int_postrisc_r4<Ty, Ty, Ty, Ty>;
  defm nmsub      # NAME : int_postrisc_r4<Ty, Ty, Ty, Ty>;
  defm merge      # NAME : int_postrisc_r4<Ty, Ty, Ty, Ty>;
  defm madd_alt   # NAME : int_postrisc_r4<Ty, Ty, Ty, Ty>;
  defm msub_alt   # NAME : int_postrisc_r4<Ty, Ty, Ty, Ty>;

  // sign-alternating
  defm add_alt    # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm sub_alt    # NAME : int_postrisc_r3<Ty, Ty, Ty>;

  // horizontal
  defm add_horiz  # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm mul_horiz  # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm sub_horiz  # NAME : int_postrisc_r3<Ty, Ty, Ty>;
}

defm _vf16 : FP_Vector<llvm_v8f16_ty>;
defm _vf32 : FP_Vector<llvm_v4f32_ty>;
defm _vf64 : FP_Vector<llvm_v2f64_ty>;

///////////////////////////////////////////////////////////////////////////////////////
// int vector
///////////////////////////////////////////////////////////////////////////////////////
multiclass MMX_Signed<LLVMType Ty> {
  defm addo    # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm subo    # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm add_sat # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm sub_sat # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm avg     # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm cmp_eq  # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm cmp_lt  # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm max     # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm min     # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm sra     # NAME : int_postrisc_r3<Ty, Ty, Ty>;
}

defm _vi8  : MMX_Signed<llvm_v16i8_ty>;
defm _vi16 : MMX_Signed<llvm_v8i16_ty>;
defm _vi32 : MMX_Signed<llvm_v4i32_ty>;
defm _vi64 : MMX_Signed<llvm_v2i64_ty>;

multiclass MMX_Unsigned<LLVMType Ty> {
  defm add        # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm sub        # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm add_sat    # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm sub_sat    # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm addc       # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm subb       # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm avg        # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm cmp_lt     # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm max        # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm min        # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm rol        # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm ror        # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm sll        # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm srl        # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm merge_high # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm merge_low  # NAME : int_postrisc_r3<Ty, Ty, Ty>;
}

defm _vu8  : MMX_Unsigned<llvm_v16i8_ty>;
defm _vu16 : MMX_Unsigned<llvm_v8i16_ty>;
defm _vu32 : MMX_Unsigned<llvm_v4i32_ty>;
defm _vu64 : MMX_Unsigned<llvm_v2i64_ty>;

///////////////////////////////////////////////////////////////////////////////////////
// pack two vectors into one
///////////////////////////////////////////////////////////////////////////////////////
defm pack_sat_vi16 : int_postrisc_r3<llvm_v16i8_ty, llvm_v8i16_ty, llvm_v8i16_ty>;
defm pack_sat_vi32 : int_postrisc_r3<llvm_v8i16_ty, llvm_v4i32_ty, llvm_v4i32_ty>;
defm pack_sat_vi64 : int_postrisc_r3<llvm_v4i32_ty, llvm_v2i64_ty, llvm_v2i64_ty>;

defm pack_sat_vu16 : int_postrisc_r3<llvm_v16i8_ty, llvm_v8i16_ty, llvm_v8i16_ty>;
defm pack_sat_vu32 : int_postrisc_r3<llvm_v8i16_ty, llvm_v4i32_ty, llvm_v4i32_ty>;
defm pack_sat_vu64 : int_postrisc_r3<llvm_v4i32_ty, llvm_v2i64_ty, llvm_v2i64_ty>;

defm pack_usat_vi16 : int_postrisc_r3<llvm_v16i8_ty, llvm_v8i16_ty, llvm_v8i16_ty>;
defm pack_usat_vi32 : int_postrisc_r3<llvm_v8i16_ty, llvm_v4i32_ty, llvm_v4i32_ty>;
defm pack_usat_vi64 : int_postrisc_r3<llvm_v4i32_ty, llvm_v2i64_ty, llvm_v2i64_ty>;

defm pack_mod_vu16 : int_postrisc_r3<llvm_v16i8_ty, llvm_v8i16_ty, llvm_v8i16_ty>;
defm pack_mod_vu32 : int_postrisc_r3<llvm_v8i16_ty, llvm_v4i32_ty, llvm_v4i32_ty>;
defm pack_mod_vu64 : int_postrisc_r3<llvm_v4i32_ty, llvm_v2i64_ty, llvm_v2i64_ty>;

///////////////////////////////////////////////////////////////////////////////////////
// unpack vector half into bigger one
///////////////////////////////////////////////////////////////////////////////////////
defm unpack_high_vi8  : int_postrisc_r2<llvm_v8i16_ty, llvm_v16i8_ty>;
defm unpack_high_vi16 : int_postrisc_r2<llvm_v4i32_ty, llvm_v8i16_ty>;
defm unpack_high_vi32 : int_postrisc_r2<llvm_v2i64_ty, llvm_v4i32_ty>;

defm unpack_low_vi8  : int_postrisc_r2<llvm_v8i16_ty, llvm_v16i8_ty>;
defm unpack_low_vi16 : int_postrisc_r2<llvm_v4i32_ty, llvm_v8i16_ty>;
defm unpack_low_vi32 : int_postrisc_r2<llvm_v2i64_ty, llvm_v4i32_ty>;

defm unpack_high_vu8  : int_postrisc_r2<llvm_v8i16_ty, llvm_v16i8_ty>;
defm unpack_high_vu16 : int_postrisc_r2<llvm_v4i32_ty, llvm_v8i16_ty>;
defm unpack_high_vu32 : int_postrisc_r2<llvm_v2i64_ty, llvm_v4i32_ty>;

defm unpack_low_vu8  : int_postrisc_r2<llvm_v8i16_ty, llvm_v16i8_ty>;
defm unpack_low_vu16 : int_postrisc_r2<llvm_v4i32_ty, llvm_v8i16_ty>;
defm unpack_low_vu32 : int_postrisc_r2<llvm_v2i64_ty, llvm_v4i32_ty>;

} // postrisc
