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

multiclass int_postrisc_r2_shamt<LLVMType Ta, LLVMType Tb> {
  def int_postrisc_ # NAME : ClangBuiltin<!strconcat("__builtin_postrisc_", NAME)>,
      Intrinsic<[Ta], [Tb, llvm_i32_ty], [IntrNoMem, ImmArg<ArgIndex<1>>]>;
}

multiclass int_postrisc_r3<LLVMType Ta, LLVMType Tb, LLVMType Tc> {
  def int_postrisc_ # NAME : ClangBuiltin<!strconcat("__builtin_postrisc_", NAME)>,
      Intrinsic<[Ta], [Tb, Tc], [IntrNoMem]>;
}

multiclass int_postrisc_r4<LLVMType Ta, LLVMType Tb, LLVMType Tc, LLVMType Td> {
  def int_postrisc_ # NAME : ClangBuiltin<!strconcat("__builtin_postrisc_", NAME)>,
      Intrinsic<[Ta], [Tb, Tc, Td], [IntrNoMem]>;
}

///////////////////////////////////////////////////////////////////////////////////////
// patterns with explicit rpunding mode
///////////////////////////////////////////////////////////////////////////////////////
multiclass int_postrisc_r2rm<LLVMType Ta, LLVMType Tb> {
  def int_postrisc_ # NAME : ClangBuiltin<!strconcat("__builtin_postrisc_", NAME)>,
      Intrinsic<[Ta], [Tb, llvm_i32_ty], [IntrNoMem, ImmArg<ArgIndex<1>>]>;
}

multiclass int_postrisc_r3rm<LLVMType Ta, LLVMType Tb, LLVMType Tc> {
  def int_postrisc_ # NAME : ClangBuiltin<!strconcat("__builtin_postrisc_", NAME)>,
      Intrinsic<[Ta], [Tb, Tc, llvm_i32_ty], [IntrNoMem, ImmArg<ArgIndex<2>>]>;
}

multiclass int_postrisc_r4rm<LLVMType Ta, LLVMType Tb, LLVMType Tc, LLVMType Td> {
  def int_postrisc_ # NAME : ClangBuiltin<!strconcat("__builtin_postrisc_", NAME)>,
      Intrinsic<[Ta], [Tb, Tc, Td, llvm_i32_ty], [IntrNoMem, ImmArg<ArgIndex<3>>]>;
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
defm iib:   int_postrisc_special_reg<llvm_i128_ty>; // 128-bit bundle
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

def int_postrisc_get_mr  : ClangBuiltin<"__builtin_postrisc_get_mr">,  Intrinsic<[llvm_i64_ty], [llvm_i64_ty], []>;
def int_postrisc_get_ibr : ClangBuiltin<"__builtin_postrisc_get_ibr">, Intrinsic<[llvm_i64_ty], [llvm_i64_ty], []>;
def int_postrisc_get_dbr : ClangBuiltin<"__builtin_postrisc_get_dbr">, Intrinsic<[llvm_i64_ty], [llvm_i64_ty], []>;

def int_postrisc_set_mr  : ClangBuiltin<"__builtin_postrisc_set_mr">,  Intrinsic<[], [llvm_i64_ty, llvm_i64_ty], []>;
def int_postrisc_set_ibr : ClangBuiltin<"__builtin_postrisc_set_ibr">, Intrinsic<[], [llvm_i64_ty, llvm_i64_ty], []>;
def int_postrisc_set_dbr : ClangBuiltin<"__builtin_postrisc_set_dbr">, Intrinsic<[], [llvm_i64_ty, llvm_i64_ty], []>;

def int_postrisc_set_dtr : ClangBuiltin<"__builtin_postrisc_set_dtr">, Intrinsic<[], [llvm_i64_ty, llvm_ptr_ty, llvm_i32_ty], []>;
def int_postrisc_set_itr : ClangBuiltin<"__builtin_postrisc_set_itr">, Intrinsic<[], [llvm_i64_ty, llvm_ptr_ty, llvm_i32_ty], []>;

def int_postrisc_rscover : ClangBuiltin<"__builtin_postrisc_rscover">, Intrinsic<[], [], []>;
def int_postrisc_rsflush : ClangBuiltin<"__builtin_postrisc_rsflush">, Intrinsic<[], [], []>;
def int_postrisc_rsload  : ClangBuiltin<"__builtin_postrisc_rsload">,  Intrinsic<[], [], []>;

///////////////////////////////////////////////////////////////////////////////////////
// Advanced Encryption Standard (AES) Instructions
///////////////////////////////////////////////////////////////////////////////////////

defm aesimc     : int_postrisc_r2<llvm_v2i64_ty, llvm_v2i64_ty>;
defm aesenc     : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;
defm aesenclast : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;
defm aesdec     : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;
defm aesdeclast : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;

def int_postrisc_aeskeygenassist : ClangBuiltin<"__builtin_postrisc_aeskeygenassist">,
  Intrinsic<[llvm_v2i64_ty], [llvm_v2i64_ty, llvm_i32_ty], [IntrNoMem, ImmArg<ArgIndex<1>>]>;

///////////////////////////////////////////////////////////////////////////////////////
// hashing, carry less multiply
///////////////////////////////////////////////////////////////////////////////////////

defm clmul_ll : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;
defm clmul_hl : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;
defm clmul_hh : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;

defm crc32c  : int_postrisc_r4<llvm_i32_ty, llvm_i32_ty, llvm_i128_ty, llvm_i64_ty>;

///////////////////////////////////////////////////////////////////////////////////////
// fp common scalar/vector
///////////////////////////////////////////////////////////////////////////////////////
multiclass FP_Common<LLVMType Ft> {
  defm sqrt      # NAME : int_postrisc_r2rm<Ft, Ft>;
  defm rsqrt     # NAME : int_postrisc_r2rm<Ft, Ft>;
  defm round     # NAME : int_postrisc_r2rm<Ft, Ft>;
  defm roundnx   # NAME : int_postrisc_r2rm<Ft, Ft>;

  defm abs_diff  # NAME : int_postrisc_r3rm<Ft, Ft, Ft>;
  defm nabs_diff # NAME : int_postrisc_r3rm<Ft, Ft, Ft>;
  defm add       # NAME : int_postrisc_r3rm<Ft, Ft, Ft>;
  defm nadd      # NAME : int_postrisc_r3rm<Ft, Ft, Ft>;
  defm sub       # NAME : int_postrisc_r3rm<Ft, Ft, Ft>;
  defm mul       # NAME : int_postrisc_r3rm<Ft, Ft, Ft>;
  defm nmul      # NAME : int_postrisc_r3rm<Ft, Ft, Ft>;
  defm div       # NAME : int_postrisc_r3rm<Ft, Ft, Ft>;

  defm madd      # NAME : int_postrisc_r4rm<Ft, Ft, Ft, Ft>;
  defm msub      # NAME : int_postrisc_r4rm<Ft, Ft, Ft, Ft>;
  defm nmadd     # NAME : int_postrisc_r4rm<Ft, Ft, Ft, Ft>;
  defm nmsub     # NAME : int_postrisc_r4rm<Ft, Ft, Ft, Ft>;

  defm merge     # NAME : int_postrisc_r4<Ft, Ft, Ft, Ft>;
}

///////////////////////////////////////////////////////////////////////////////////////
// fp scalar
///////////////////////////////////////////////////////////////////////////////////////
multiclass FP_Scalar<LLVMType Ft> {
  defm NAME : FP_Common<Ft>;

  defm minimum # NAME : int_postrisc_r3<Ft, Ft, Ft>;
  defm maximum # NAME : int_postrisc_r3<Ft, Ft, Ft>;

  defm cvt # NAME # _i32  : int_postrisc_r2rm<llvm_i32_ty, Ft>;
  defm cvt # NAME # _u32  : int_postrisc_r2rm<llvm_i32_ty, Ft>;

  defm cvt # NAME # _i64  : int_postrisc_r2rm<llvm_i64_ty, Ft>;
  defm cvt # NAME # _u64  : int_postrisc_r2rm<llvm_i64_ty, Ft>;

  defm cvt # NAME # _i128  : int_postrisc_r2rm<llvm_i128_ty, Ft>;
  defm cvt # NAME # _u128  : int_postrisc_r2rm<llvm_i128_ty, Ft>;

  defm cvt_i32 # NAME  : int_postrisc_r2rm<Ft, llvm_i32_ty>;
  defm cvt_u32 # NAME  : int_postrisc_r2rm<Ft, llvm_i32_ty>;

  defm cvt_i64 # NAME  : int_postrisc_r2rm<Ft, llvm_i64_ty>;
  defm cvt_u64 # NAME  : int_postrisc_r2rm<Ft, llvm_i64_ty>;

  defm cvt_i128 # NAME  : int_postrisc_r2rm<Ft, llvm_i128_ty>;
  defm cvt_u128 # NAME  : int_postrisc_r2rm<Ft, llvm_i128_ty>;
}

defm _f16  : FP_Scalar<llvm_half_ty>;
defm _f32  : FP_Scalar<llvm_float_ty>;
defm _f64  : FP_Scalar<llvm_double_ty>;
defm _f128 : FP_Scalar<llvm_f128_ty>;

///////////////////////////////////////////////////////////////////////////////////////
// fp vector
///////////////////////////////////////////////////////////////////////////////////////
multiclass FP_Vector<LLVMType Ft, LLVMType utype> {
  defm NAME : FP_Common<Ft>;

  defm dot        # NAME : int_postrisc_r3rm<Ft, Ft, Ft>;

  defm madd_alt   # NAME : int_postrisc_r4rm<Ft, Ft, Ft, Ft>;
  defm msub_alt   # NAME : int_postrisc_r4rm<Ft, Ft, Ft, Ft>;

  // sign-alternating
  defm add_alt    # NAME : int_postrisc_r3rm<Ft, Ft, Ft>;
  defm sub_alt    # NAME : int_postrisc_r3rm<Ft, Ft, Ft>;

  // horizontal
  defm add_horiz  # NAME : int_postrisc_r3rm<Ft, Ft, Ft>;
  defm mul_horiz  # NAME : int_postrisc_r3rm<Ft, Ft, Ft>;
  defm sub_horiz  # NAME : int_postrisc_r3rm<Ft, Ft, Ft>;

  defm cmp_oeq   # NAME : int_postrisc_r3<utype, Ft, Ft>;
  defm cmp_one   # NAME : int_postrisc_r3<utype, Ft, Ft>;
  defm cmp_olt   # NAME : int_postrisc_r3<utype, Ft, Ft>;
  defm cmp_oge   # NAME : int_postrisc_r3<utype, Ft, Ft>;
  defm cmp_ueq   # NAME : int_postrisc_r3<utype, Ft, Ft>;
  defm cmp_une   # NAME : int_postrisc_r3<utype, Ft, Ft>;
  defm cmp_ult   # NAME : int_postrisc_r3<utype, Ft, Ft>;
  defm cmp_uge   # NAME : int_postrisc_r3<utype, Ft, Ft>;
  defm cmp_o     # NAME : int_postrisc_r3<utype, Ft, Ft>;
  defm cmp_u     # NAME : int_postrisc_r3<utype, Ft, Ft>;

  defm merge_high  # NAME : int_postrisc_r3<Ft, Ft, Ft>;
  defm merge_low   # NAME : int_postrisc_r3<Ft, Ft, Ft>;
  defm unpack_high # NAME : int_postrisc_r2<Ft, Ft>;
  defm unpack_low  # NAME : int_postrisc_r2<Ft, Ft>;
}

defm _vf16 : FP_Vector<llvm_v8f16_ty, llvm_v8i16_ty>;
defm _vf32 : FP_Vector<llvm_v4f32_ty, llvm_v4i32_ty>;
defm _vf64 : FP_Vector<llvm_v2f64_ty, llvm_v2i64_ty>;

defm cvt_f32_f16  : int_postrisc_r2rm<llvm_half_ty,   llvm_float_ty>;
defm cvt_f64_f16  : int_postrisc_r2rm<llvm_half_ty,   llvm_double_ty>;
defm cvt_f64_f32  : int_postrisc_r2rm<llvm_float_ty,  llvm_double_ty>;
defm cvt_f128_f16 : int_postrisc_r2rm<llvm_half_ty,   llvm_f128_ty>;
defm cvt_f128_f32 : int_postrisc_r2rm<llvm_float_ty,  llvm_f128_ty>;
defm cvt_f128_f64 : int_postrisc_r2rm<llvm_double_ty, llvm_f128_ty>;

defm cvt_vu16_vf16 : int_postrisc_r2rm<llvm_v8f16_ty, llvm_v8i16_ty>;
defm cvt_vu32_vf32 : int_postrisc_r2rm<llvm_v4f32_ty, llvm_v4i32_ty>;
defm cvt_vu64_vf64 : int_postrisc_r2rm<llvm_v2f64_ty, llvm_v2i64_ty>;

defm cvt_vi16_vf16 : int_postrisc_r2rm<llvm_v8f16_ty, llvm_v8i16_ty>;
defm cvt_vi32_vf32 : int_postrisc_r2rm<llvm_v4f32_ty, llvm_v4i32_ty>;
defm cvt_vi64_vf64 : int_postrisc_r2rm<llvm_v2f64_ty, llvm_v2i64_ty>;

defm cvt_vf16_vu16 : int_postrisc_r2rm<llvm_v8i16_ty, llvm_v8f16_ty>;
defm cvt_vf32_vu32 : int_postrisc_r2rm<llvm_v4i32_ty, llvm_v4f32_ty>;
defm cvt_vf64_vu64 : int_postrisc_r2rm<llvm_v2i64_ty, llvm_v2f64_ty>;

defm cvt_vf16_vi16 : int_postrisc_r2rm<llvm_v8i16_ty, llvm_v8f16_ty>;
defm cvt_vf32_vi32 : int_postrisc_r2rm<llvm_v4i32_ty, llvm_v4f32_ty>;
defm cvt_vf64_vi64 : int_postrisc_r2rm<llvm_v2i64_ty, llvm_v2f64_ty>;

///////////////////////////////////////////////////////////////////////////////////////
// int vector
///////////////////////////////////////////////////////////////////////////////////////
multiclass POSTRISC_VECTOR_SINT<LLVMType Ty> {
  defm addo    # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm subo    # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm add_sat # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm sub_sat # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm min     # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm max     # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm avg     # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm cmp_eq  # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm cmp_lt  # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm sra     # NAME : int_postrisc_r3<Ty, Ty, Ty>;

  defm sra_imm # NAME : int_postrisc_r2_shamt<Ty, Ty>;
}

defm _vi8  : POSTRISC_VECTOR_SINT<llvm_v16i8_ty>;
defm _vi16 : POSTRISC_VECTOR_SINT<llvm_v8i16_ty>;
defm _vi32 : POSTRISC_VECTOR_SINT<llvm_v4i32_ty>;
defm _vi64 : POSTRISC_VECTOR_SINT<llvm_v2i64_ty>;

multiclass POSTRISC_VECTOR_UINT<LLVMType Ty> {
  defm add        # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm sub        # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm addc       # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm subb       # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm add_sat    # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm sub_sat    # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm min        # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm max        # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm avg        # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm cmp_lt     # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm rol        # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm ror        # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm sll        # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm srl        # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm merge_high # NAME : int_postrisc_r3<Ty, Ty, Ty>;
  defm merge_low  # NAME : int_postrisc_r3<Ty, Ty, Ty>;

  defm sll_imm    # NAME : int_postrisc_r2_shamt<Ty, Ty>;
  defm srl_imm    # NAME : int_postrisc_r2_shamt<Ty, Ty>;
}

defm _vu8  : POSTRISC_VECTOR_UINT<llvm_v16i8_ty>;
defm _vu16 : POSTRISC_VECTOR_UINT<llvm_v8i16_ty>;
defm _vu32 : POSTRISC_VECTOR_UINT<llvm_v4i32_ty>;
defm _vu64 : POSTRISC_VECTOR_UINT<llvm_v2i64_ty>;

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

///////////////////////////////////////////////////////////////////////////////////////
// int vector misc
///////////////////////////////////////////////////////////////////////////////////////

defm perm_vu8 : int_postrisc_r4<llvm_v16i8_ty, llvm_v16i8_ty, llvm_v16i8_ty, llvm_v16i8_ty>;

} // postrisc
