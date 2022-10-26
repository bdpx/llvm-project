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
def int_postrisc_tpa      : ClangBuiltin<"__builtin_postrisc_tpa"     >, Intrinsic<[llvm_i64_ty], [llvm_ptr_ty], []>;
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

defm clmulll : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;
defm clmulhl : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;
defm clmulhh : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;

defm crc32c  : int_postrisc_r4<llvm_i32_ty, llvm_i32_ty, llvm_i128_ty, llvm_i64_ty>;

///////////////////////////////////////////////////////////////////////////////////////
// fp scalar half
///////////////////////////////////////////////////////////////////////////////////////

defm fabssh   : int_postrisc_r2<llvm_half_ty, llvm_half_ty>;
defm fnabssh  : int_postrisc_r2<llvm_half_ty, llvm_half_ty>;
defm fnegsh   : int_postrisc_r2<llvm_half_ty, llvm_half_ty>;
defm frsqrtsh : int_postrisc_r2<llvm_half_ty, llvm_half_ty>;
defm fsqrtsh  : int_postrisc_r2<llvm_half_ty, llvm_half_ty>;

defm fabsdsh  : int_postrisc_r3<llvm_half_ty, llvm_half_ty, llvm_half_ty>;
defm fnabsdsh : int_postrisc_r3<llvm_half_ty, llvm_half_ty, llvm_half_ty>;
defm faddsh   : int_postrisc_r3<llvm_half_ty, llvm_half_ty, llvm_half_ty>;
defm fnaddsh  : int_postrisc_r3<llvm_half_ty, llvm_half_ty, llvm_half_ty>;
defm faminsh  : int_postrisc_r3<llvm_half_ty, llvm_half_ty, llvm_half_ty>;
defm famaxsh  : int_postrisc_r3<llvm_half_ty, llvm_half_ty, llvm_half_ty>;
defm fminsh   : int_postrisc_r3<llvm_half_ty, llvm_half_ty, llvm_half_ty>;
defm fmaxsh   : int_postrisc_r3<llvm_half_ty, llvm_half_ty, llvm_half_ty>;
defm fdivsh   : int_postrisc_r3<llvm_half_ty, llvm_half_ty, llvm_half_ty>;
defm fdotsh   : int_postrisc_r3<llvm_half_ty, llvm_half_ty, llvm_half_ty>;
defm fmulsh   : int_postrisc_r3<llvm_half_ty, llvm_half_ty, llvm_half_ty>;
defm fnmulsh  : int_postrisc_r3<llvm_half_ty, llvm_half_ty, llvm_half_ty>;
defm fsubsh   : int_postrisc_r3<llvm_half_ty, llvm_half_ty, llvm_half_ty>;

defm fmaddsh  : int_postrisc_r4<llvm_half_ty, llvm_half_ty, llvm_half_ty, llvm_half_ty>;
defm fnmaddsh : int_postrisc_r4<llvm_half_ty, llvm_half_ty, llvm_half_ty, llvm_half_ty>;
defm fmsubsh  : int_postrisc_r4<llvm_half_ty, llvm_half_ty, llvm_half_ty, llvm_half_ty>;
defm fnmsubsh : int_postrisc_r4<llvm_half_ty, llvm_half_ty, llvm_half_ty, llvm_half_ty>;
defm fmergesh : int_postrisc_r4<llvm_half_ty, llvm_half_ty, llvm_half_ty, llvm_half_ty>;

///////////////////////////////////////////////////////////////////////////////////////
// fp scalar single
///////////////////////////////////////////////////////////////////////////////////////

defm fabsss   : int_postrisc_r2<llvm_float_ty, llvm_float_ty>;
defm fnabsss  : int_postrisc_r2<llvm_float_ty, llvm_float_ty>;
defm fnegss   : int_postrisc_r2<llvm_float_ty, llvm_float_ty>;
defm frsqrtss : int_postrisc_r2<llvm_float_ty, llvm_float_ty>;
defm fsqrtss  : int_postrisc_r2<llvm_float_ty, llvm_float_ty>;

defm fabsdss  : int_postrisc_r3<llvm_float_ty, llvm_float_ty, llvm_float_ty>;
defm fnabsdss : int_postrisc_r3<llvm_float_ty, llvm_float_ty, llvm_float_ty>;
defm faddss   : int_postrisc_r3<llvm_float_ty, llvm_float_ty, llvm_float_ty>;
defm fnaddss  : int_postrisc_r3<llvm_float_ty, llvm_float_ty, llvm_float_ty>;
defm faminss  : int_postrisc_r3<llvm_float_ty, llvm_float_ty, llvm_float_ty>;
defm famaxss  : int_postrisc_r3<llvm_float_ty, llvm_float_ty, llvm_float_ty>;
defm fminss   : int_postrisc_r3<llvm_float_ty, llvm_float_ty, llvm_float_ty>;
defm fmaxss   : int_postrisc_r3<llvm_float_ty, llvm_float_ty, llvm_float_ty>;
defm fdivss   : int_postrisc_r3<llvm_float_ty, llvm_float_ty, llvm_float_ty>;
defm fdotss   : int_postrisc_r3<llvm_float_ty, llvm_float_ty, llvm_float_ty>;
defm fmulss   : int_postrisc_r3<llvm_float_ty, llvm_float_ty, llvm_float_ty>;
defm fnmulss  : int_postrisc_r3<llvm_float_ty, llvm_float_ty, llvm_float_ty>;
defm fsubss   : int_postrisc_r3<llvm_float_ty, llvm_float_ty, llvm_float_ty>;

defm fmaddss  : int_postrisc_r4<llvm_float_ty, llvm_float_ty, llvm_float_ty, llvm_float_ty>;
defm fnmaddss : int_postrisc_r4<llvm_float_ty, llvm_float_ty, llvm_float_ty, llvm_float_ty>;
defm fmsubss  : int_postrisc_r4<llvm_float_ty, llvm_float_ty, llvm_float_ty, llvm_float_ty>;
defm fnmsubss : int_postrisc_r4<llvm_float_ty, llvm_float_ty, llvm_float_ty, llvm_float_ty>;
defm fmergess : int_postrisc_r4<llvm_float_ty, llvm_float_ty, llvm_float_ty, llvm_float_ty>;

///////////////////////////////////////////////////////////////////////////////////////
// fp scalar double
///////////////////////////////////////////////////////////////////////////////////////

defm fabssd   : int_postrisc_r2<llvm_double_ty, llvm_double_ty>;
defm fnabssd  : int_postrisc_r2<llvm_double_ty, llvm_double_ty>;
defm fnegsd   : int_postrisc_r2<llvm_double_ty, llvm_double_ty>;
defm frsqrtsd : int_postrisc_r2<llvm_double_ty, llvm_double_ty>;
defm fsqrtsd  : int_postrisc_r2<llvm_double_ty, llvm_double_ty>;

defm fabsdsd  : int_postrisc_r3<llvm_double_ty, llvm_double_ty, llvm_double_ty>;
defm fnabsdsd : int_postrisc_r3<llvm_double_ty, llvm_double_ty, llvm_double_ty>;
defm faddsd   : int_postrisc_r3<llvm_double_ty, llvm_double_ty, llvm_double_ty>;
defm fnaddsd  : int_postrisc_r3<llvm_double_ty, llvm_double_ty, llvm_double_ty>;
defm faminsd  : int_postrisc_r3<llvm_double_ty, llvm_double_ty, llvm_double_ty>;
defm famaxsd  : int_postrisc_r3<llvm_double_ty, llvm_double_ty, llvm_double_ty>;
defm fminsd   : int_postrisc_r3<llvm_double_ty, llvm_double_ty, llvm_double_ty>;
defm fmaxsd   : int_postrisc_r3<llvm_double_ty, llvm_double_ty, llvm_double_ty>;
defm fdivsd   : int_postrisc_r3<llvm_double_ty, llvm_double_ty, llvm_double_ty>;
defm fdotsd   : int_postrisc_r3<llvm_double_ty, llvm_double_ty, llvm_double_ty>;
defm fmulsd   : int_postrisc_r3<llvm_double_ty, llvm_double_ty, llvm_double_ty>;
defm fnmulsd  : int_postrisc_r3<llvm_double_ty, llvm_double_ty, llvm_double_ty>;
defm fsubsd   : int_postrisc_r3<llvm_double_ty, llvm_double_ty, llvm_double_ty>;

defm fmaddsd  : int_postrisc_r4<llvm_double_ty, llvm_double_ty, llvm_double_ty, llvm_double_ty>;
defm fnmaddsd : int_postrisc_r4<llvm_double_ty, llvm_double_ty, llvm_double_ty, llvm_double_ty>;
defm fmsubsd  : int_postrisc_r4<llvm_double_ty, llvm_double_ty, llvm_double_ty, llvm_double_ty>;
defm fnmsubsd : int_postrisc_r4<llvm_double_ty, llvm_double_ty, llvm_double_ty, llvm_double_ty>;
defm fmergesd : int_postrisc_r4<llvm_double_ty, llvm_double_ty, llvm_double_ty, llvm_double_ty>;

///////////////////////////////////////////////////////////////////////////////////////
// fp scalar quadruple
///////////////////////////////////////////////////////////////////////////////////////

defm fabssq   : int_postrisc_r2<llvm_f128_ty, llvm_f128_ty>;
defm fnabssq  : int_postrisc_r2<llvm_f128_ty, llvm_f128_ty>;
defm fnegsq   : int_postrisc_r2<llvm_f128_ty, llvm_f128_ty>;
defm frsqrtsq : int_postrisc_r2<llvm_f128_ty, llvm_f128_ty>;
defm fsqrtsq  : int_postrisc_r2<llvm_f128_ty, llvm_f128_ty>;

defm fabsdsq  : int_postrisc_r3<llvm_f128_ty, llvm_f128_ty, llvm_f128_ty>;
defm fnabsdsq : int_postrisc_r3<llvm_f128_ty, llvm_f128_ty, llvm_f128_ty>;
defm faddsq   : int_postrisc_r3<llvm_f128_ty, llvm_f128_ty, llvm_f128_ty>;
defm fnaddsq  : int_postrisc_r3<llvm_f128_ty, llvm_f128_ty, llvm_f128_ty>;
defm faminsq  : int_postrisc_r3<llvm_f128_ty, llvm_f128_ty, llvm_f128_ty>;
defm famaxsq  : int_postrisc_r3<llvm_f128_ty, llvm_f128_ty, llvm_f128_ty>;
defm fminsq   : int_postrisc_r3<llvm_f128_ty, llvm_f128_ty, llvm_f128_ty>;
defm fmaxsq   : int_postrisc_r3<llvm_f128_ty, llvm_f128_ty, llvm_f128_ty>;
defm fdivsq   : int_postrisc_r3<llvm_f128_ty, llvm_f128_ty, llvm_f128_ty>;
defm fdotsq   : int_postrisc_r3<llvm_f128_ty, llvm_f128_ty, llvm_f128_ty>;
defm fmulsq   : int_postrisc_r3<llvm_f128_ty, llvm_f128_ty, llvm_f128_ty>;
defm fnmulsq  : int_postrisc_r3<llvm_f128_ty, llvm_f128_ty, llvm_f128_ty>;
defm fsubsq   : int_postrisc_r3<llvm_f128_ty, llvm_f128_ty, llvm_f128_ty>;

defm fmaddsq  : int_postrisc_r4<llvm_f128_ty, llvm_f128_ty, llvm_f128_ty, llvm_f128_ty>;
defm fnmaddsq : int_postrisc_r4<llvm_f128_ty, llvm_f128_ty, llvm_f128_ty, llvm_f128_ty>;
defm fmsubsq  : int_postrisc_r4<llvm_f128_ty, llvm_f128_ty, llvm_f128_ty, llvm_f128_ty>;
defm fnmsubsq : int_postrisc_r4<llvm_f128_ty, llvm_f128_ty, llvm_f128_ty, llvm_f128_ty>;
defm fmergesq : int_postrisc_r4<llvm_f128_ty, llvm_f128_ty, llvm_f128_ty, llvm_f128_ty>;

///////////////////////////////////////////////////////////////////////////////////////
// fp vector packed half
///////////////////////////////////////////////////////////////////////////////////////

defm fabsph   : int_postrisc_r2<llvm_v8f16_ty, llvm_v8f16_ty>;
defm fnabsph  : int_postrisc_r2<llvm_v8f16_ty, llvm_v8f16_ty>;
defm fnegph   : int_postrisc_r2<llvm_v8f16_ty, llvm_v8f16_ty>;
defm frsqrtph : int_postrisc_r2<llvm_v8f16_ty, llvm_v8f16_ty>;
defm fsqrtph  : int_postrisc_r2<llvm_v8f16_ty, llvm_v8f16_ty>;

defm fabsdph  : int_postrisc_r3<llvm_v8f16_ty, llvm_v8f16_ty, llvm_v8f16_ty>;
defm fnabsdph : int_postrisc_r3<llvm_v8f16_ty, llvm_v8f16_ty, llvm_v8f16_ty>;
defm faddph   : int_postrisc_r3<llvm_v8f16_ty, llvm_v8f16_ty, llvm_v8f16_ty>;
defm fnaddph  : int_postrisc_r3<llvm_v8f16_ty, llvm_v8f16_ty, llvm_v8f16_ty>;
defm faminph  : int_postrisc_r3<llvm_v8f16_ty, llvm_v8f16_ty, llvm_v8f16_ty>;
defm famaxph  : int_postrisc_r3<llvm_v8f16_ty, llvm_v8f16_ty, llvm_v8f16_ty>;
defm fminph   : int_postrisc_r3<llvm_v8f16_ty, llvm_v8f16_ty, llvm_v8f16_ty>;
defm fmaxph   : int_postrisc_r3<llvm_v8f16_ty, llvm_v8f16_ty, llvm_v8f16_ty>;
defm fdivph   : int_postrisc_r3<llvm_v8f16_ty, llvm_v8f16_ty, llvm_v8f16_ty>;
defm fdotph   : int_postrisc_r3<llvm_v8f16_ty, llvm_v8f16_ty, llvm_v8f16_ty>;
defm fmulph   : int_postrisc_r3<llvm_v8f16_ty, llvm_v8f16_ty, llvm_v8f16_ty>;
defm fnmulph  : int_postrisc_r3<llvm_v8f16_ty, llvm_v8f16_ty, llvm_v8f16_ty>;
defm fsubph   : int_postrisc_r3<llvm_v8f16_ty, llvm_v8f16_ty, llvm_v8f16_ty>;

defm fmaddph  : int_postrisc_r4<llvm_v8f16_ty, llvm_v8f16_ty, llvm_v8f16_ty, llvm_v8f16_ty>;
defm fnmaddph : int_postrisc_r4<llvm_v8f16_ty, llvm_v8f16_ty, llvm_v8f16_ty, llvm_v8f16_ty>;
defm fmsubph  : int_postrisc_r4<llvm_v8f16_ty, llvm_v8f16_ty, llvm_v8f16_ty, llvm_v8f16_ty>;
defm fnmsubph : int_postrisc_r4<llvm_v8f16_ty, llvm_v8f16_ty, llvm_v8f16_ty, llvm_v8f16_ty>;
defm fmergeph : int_postrisc_r4<llvm_v8f16_ty, llvm_v8f16_ty, llvm_v8f16_ty, llvm_v8f16_ty>;

defm fma_ph   : int_postrisc_r4<llvm_v8f16_ty, llvm_v8f16_ty, llvm_v8f16_ty, llvm_v8f16_ty>;

// horizontal
defm faddcph  : int_postrisc_r3<llvm_v8f16_ty, llvm_v8f16_ty, llvm_v8f16_ty>;
defm faddhph  : int_postrisc_r3<llvm_v8f16_ty, llvm_v8f16_ty, llvm_v8f16_ty>;
defm fmulhph  : int_postrisc_r3<llvm_v8f16_ty, llvm_v8f16_ty, llvm_v8f16_ty>;
defm fsubcph  : int_postrisc_r3<llvm_v8f16_ty, llvm_v8f16_ty, llvm_v8f16_ty>;
defm fsubhph  : int_postrisc_r3<llvm_v8f16_ty, llvm_v8f16_ty, llvm_v8f16_ty>;

///////////////////////////////////////////////////////////////////////////////////////
// fp vector packed single
///////////////////////////////////////////////////////////////////////////////////////

defm fabsps   : int_postrisc_r2<llvm_v4f32_ty, llvm_v4f32_ty>;
defm fnabsps  : int_postrisc_r2<llvm_v4f32_ty, llvm_v4f32_ty>;
defm fnegps   : int_postrisc_r2<llvm_v4f32_ty, llvm_v4f32_ty>;
defm frsqrtps : int_postrisc_r2<llvm_v4f32_ty, llvm_v4f32_ty>;
defm fsqrtps  : int_postrisc_r2<llvm_v4f32_ty, llvm_v4f32_ty>;

defm fabsdps  : int_postrisc_r3<llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty>;
defm fnabsdps : int_postrisc_r3<llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty>;
defm faddps   : int_postrisc_r3<llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty>;
defm fnaddps  : int_postrisc_r3<llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty>;
defm faminps  : int_postrisc_r3<llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty>;
defm famaxps  : int_postrisc_r3<llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty>;
defm fminps   : int_postrisc_r3<llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty>;
defm fmaxps   : int_postrisc_r3<llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty>;
defm fdivps   : int_postrisc_r3<llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty>;
defm fdotps   : int_postrisc_r3<llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty>;
defm fmulps   : int_postrisc_r3<llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty>;
defm fnmulps  : int_postrisc_r3<llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty>;
defm fsubps   : int_postrisc_r3<llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty>;

defm fmaddps  : int_postrisc_r4<llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty>;
defm fnmaddps : int_postrisc_r4<llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty>;
defm fmsubps  : int_postrisc_r4<llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty>;
defm fnmsubps : int_postrisc_r4<llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty>;
defm fmergeps : int_postrisc_r4<llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty>;

defm fma_ps   : int_postrisc_r4<llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty>;

// horizontal
defm faddcps  : int_postrisc_r3<llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty>;
defm faddhps  : int_postrisc_r3<llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty>;
defm fmulhps  : int_postrisc_r3<llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty>;
defm fsubcps  : int_postrisc_r3<llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty>;
defm fsubhps  : int_postrisc_r3<llvm_v4f32_ty, llvm_v4f32_ty, llvm_v4f32_ty>;

///////////////////////////////////////////////////////////////////////////////////////
// fp vector packed double
///////////////////////////////////////////////////////////////////////////////////////

defm fabspd   : int_postrisc_r2<llvm_v2f64_ty, llvm_v2f64_ty>;
defm fnabspd  : int_postrisc_r2<llvm_v2f64_ty, llvm_v2f64_ty>;
defm fnegpd   : int_postrisc_r2<llvm_v2f64_ty, llvm_v2f64_ty>;
defm frsqrtpd : int_postrisc_r2<llvm_v2f64_ty, llvm_v2f64_ty>;
defm fsqrtpd  : int_postrisc_r2<llvm_v2f64_ty, llvm_v2f64_ty>;

defm fabsdpd  : int_postrisc_r3<llvm_v2f64_ty, llvm_v2f64_ty, llvm_v2f64_ty>;
defm fnabsdpd : int_postrisc_r3<llvm_v2f64_ty, llvm_v2f64_ty, llvm_v2f64_ty>;
defm faddpd   : int_postrisc_r3<llvm_v2f64_ty, llvm_v2f64_ty, llvm_v2f64_ty>;
defm fnaddpd  : int_postrisc_r3<llvm_v2f64_ty, llvm_v2f64_ty, llvm_v2f64_ty>;
defm faminpd  : int_postrisc_r3<llvm_v2f64_ty, llvm_v2f64_ty, llvm_v2f64_ty>;
defm famaxpd  : int_postrisc_r3<llvm_v2f64_ty, llvm_v2f64_ty, llvm_v2f64_ty>;
defm fminpd   : int_postrisc_r3<llvm_v2f64_ty, llvm_v2f64_ty, llvm_v2f64_ty>;
defm fmaxpd   : int_postrisc_r3<llvm_v2f64_ty, llvm_v2f64_ty, llvm_v2f64_ty>;
defm fdivpd   : int_postrisc_r3<llvm_v2f64_ty, llvm_v2f64_ty, llvm_v2f64_ty>;
defm fdotpd   : int_postrisc_r3<llvm_v2f64_ty, llvm_v2f64_ty, llvm_v2f64_ty>;
defm fmulpd   : int_postrisc_r3<llvm_v2f64_ty, llvm_v2f64_ty, llvm_v2f64_ty>;
defm fnmulpd  : int_postrisc_r3<llvm_v2f64_ty, llvm_v2f64_ty, llvm_v2f64_ty>;
defm fsubpd   : int_postrisc_r3<llvm_v2f64_ty, llvm_v2f64_ty, llvm_v2f64_ty>;

defm fmaddpd  : int_postrisc_r4<llvm_v2f64_ty, llvm_v2f64_ty, llvm_v2f64_ty, llvm_v2f64_ty>;
defm fnmaddpd : int_postrisc_r4<llvm_v2f64_ty, llvm_v2f64_ty, llvm_v2f64_ty, llvm_v2f64_ty>;
defm fmsubpd  : int_postrisc_r4<llvm_v2f64_ty, llvm_v2f64_ty, llvm_v2f64_ty, llvm_v2f64_ty>;
defm fnmsubpd : int_postrisc_r4<llvm_v2f64_ty, llvm_v2f64_ty, llvm_v2f64_ty, llvm_v2f64_ty>;
defm fmergepd : int_postrisc_r4<llvm_v2f64_ty, llvm_v2f64_ty, llvm_v2f64_ty, llvm_v2f64_ty>;

defm fma_pd   : int_postrisc_r4<llvm_v2f64_ty, llvm_v2f64_ty, llvm_v2f64_ty, llvm_v2f64_ty>;

// horizontal
defm faddcpd  : int_postrisc_r3<llvm_v2f64_ty, llvm_v2f64_ty, llvm_v2f64_ty>;
defm faddhpd  : int_postrisc_r3<llvm_v2f64_ty, llvm_v2f64_ty, llvm_v2f64_ty>;
defm fmulhpd  : int_postrisc_r3<llvm_v2f64_ty, llvm_v2f64_ty, llvm_v2f64_ty>;
defm fsubcpd  : int_postrisc_r3<llvm_v2f64_ty, llvm_v2f64_ty, llvm_v2f64_ty>;
defm fsubhpd  : int_postrisc_r3<llvm_v2f64_ty, llvm_v2f64_ty, llvm_v2f64_ty>;

///////////////////////////////////////////////////////////////////////////////////////
// int vector 1-byte
///////////////////////////////////////////////////////////////////////////////////////

defm vaddcb   : int_postrisc_r3<llvm_v16i8_ty, llvm_v16i8_ty, llvm_v16i8_ty>;
defm vaddob   : int_postrisc_r3<llvm_v16i8_ty, llvm_v16i8_ty, llvm_v16i8_ty>;
defm vaddssb  : int_postrisc_r3<llvm_v16i8_ty, llvm_v16i8_ty, llvm_v16i8_ty>;
defm vaddusb  : int_postrisc_r3<llvm_v16i8_ty, llvm_v16i8_ty, llvm_v16i8_ty>;
defm vaddub   : int_postrisc_r3<llvm_v16i8_ty, llvm_v16i8_ty, llvm_v16i8_ty>;
defm vavgub   : int_postrisc_r3<llvm_v16i8_ty, llvm_v16i8_ty, llvm_v16i8_ty>;
defm vavgsb   : int_postrisc_r3<llvm_v16i8_ty, llvm_v16i8_ty, llvm_v16i8_ty>;
defm vcmpeqb  : int_postrisc_r3<llvm_v16i8_ty, llvm_v16i8_ty, llvm_v16i8_ty>;
defm vcmpltb  : int_postrisc_r3<llvm_v16i8_ty, llvm_v16i8_ty, llvm_v16i8_ty>;
defm vcmpltub : int_postrisc_r3<llvm_v16i8_ty, llvm_v16i8_ty, llvm_v16i8_ty>;
defm vmaxsb   : int_postrisc_r3<llvm_v16i8_ty, llvm_v16i8_ty, llvm_v16i8_ty>;
defm vmaxub   : int_postrisc_r3<llvm_v16i8_ty, llvm_v16i8_ty, llvm_v16i8_ty>;
defm vminsb   : int_postrisc_r3<llvm_v16i8_ty, llvm_v16i8_ty, llvm_v16i8_ty>;
defm vminub   : int_postrisc_r3<llvm_v16i8_ty, llvm_v16i8_ty, llvm_v16i8_ty>;
defm vrolb    : int_postrisc_r3<llvm_v16i8_ty, llvm_v16i8_ty, llvm_v16i8_ty>;
defm vrorb    : int_postrisc_r3<llvm_v16i8_ty, llvm_v16i8_ty, llvm_v16i8_ty>;
defm vsllb    : int_postrisc_r3<llvm_v16i8_ty, llvm_v16i8_ty, llvm_v16i8_ty>;
defm vsrab    : int_postrisc_r3<llvm_v16i8_ty, llvm_v16i8_ty, llvm_v16i8_ty>;
defm vsrlb    : int_postrisc_r3<llvm_v16i8_ty, llvm_v16i8_ty, llvm_v16i8_ty>;
defm vsubbb   : int_postrisc_r3<llvm_v16i8_ty, llvm_v16i8_ty, llvm_v16i8_ty>;
defm vsubob   : int_postrisc_r3<llvm_v16i8_ty, llvm_v16i8_ty, llvm_v16i8_ty>;
defm vsubub   : int_postrisc_r3<llvm_v16i8_ty, llvm_v16i8_ty, llvm_v16i8_ty>;
defm vsubssb  : int_postrisc_r3<llvm_v16i8_ty, llvm_v16i8_ty, llvm_v16i8_ty>;
defm vsubusb  : int_postrisc_r3<llvm_v16i8_ty, llvm_v16i8_ty, llvm_v16i8_ty>;
defm vmrghb   : int_postrisc_r3<llvm_v16i8_ty, llvm_v16i8_ty, llvm_v16i8_ty>;
defm vmrglb   : int_postrisc_r3<llvm_v16i8_ty, llvm_v16i8_ty, llvm_v16i8_ty>;

///////////////////////////////////////////////////////////////////////////////////////
// int vector 2-byte
///////////////////////////////////////////////////////////////////////////////////////

defm vaddch   : int_postrisc_r3<llvm_v8i16_ty, llvm_v8i16_ty, llvm_v8i16_ty>;
defm vaddoh   : int_postrisc_r3<llvm_v8i16_ty, llvm_v8i16_ty, llvm_v8i16_ty>;
defm vaddssh  : int_postrisc_r3<llvm_v8i16_ty, llvm_v8i16_ty, llvm_v8i16_ty>;
defm vaddush  : int_postrisc_r3<llvm_v8i16_ty, llvm_v8i16_ty, llvm_v8i16_ty>;
defm vadduh   : int_postrisc_r3<llvm_v8i16_ty, llvm_v8i16_ty, llvm_v8i16_ty>;
defm vavguh   : int_postrisc_r3<llvm_v8i16_ty, llvm_v8i16_ty, llvm_v8i16_ty>;
defm vavgsh   : int_postrisc_r3<llvm_v8i16_ty, llvm_v8i16_ty, llvm_v8i16_ty>;
defm vcmpeqh  : int_postrisc_r3<llvm_v8i16_ty, llvm_v8i16_ty, llvm_v8i16_ty>;
defm vcmplth  : int_postrisc_r3<llvm_v8i16_ty, llvm_v8i16_ty, llvm_v8i16_ty>;
defm vcmpltuh : int_postrisc_r3<llvm_v8i16_ty, llvm_v8i16_ty, llvm_v8i16_ty>;
defm vmaxsh   : int_postrisc_r3<llvm_v8i16_ty, llvm_v8i16_ty, llvm_v8i16_ty>;
defm vmaxuh   : int_postrisc_r3<llvm_v8i16_ty, llvm_v8i16_ty, llvm_v8i16_ty>;
defm vminsh   : int_postrisc_r3<llvm_v8i16_ty, llvm_v8i16_ty, llvm_v8i16_ty>;
defm vminuh   : int_postrisc_r3<llvm_v8i16_ty, llvm_v8i16_ty, llvm_v8i16_ty>;
defm vrolh    : int_postrisc_r3<llvm_v8i16_ty, llvm_v8i16_ty, llvm_v8i16_ty>;
defm vrorh    : int_postrisc_r3<llvm_v8i16_ty, llvm_v8i16_ty, llvm_v8i16_ty>;
defm vsllh    : int_postrisc_r3<llvm_v8i16_ty, llvm_v8i16_ty, llvm_v8i16_ty>;
defm vsrah    : int_postrisc_r3<llvm_v8i16_ty, llvm_v8i16_ty, llvm_v8i16_ty>;
defm vsrlh    : int_postrisc_r3<llvm_v8i16_ty, llvm_v8i16_ty, llvm_v8i16_ty>;
defm vsubbh   : int_postrisc_r3<llvm_v8i16_ty, llvm_v8i16_ty, llvm_v8i16_ty>;
defm vsuboh   : int_postrisc_r3<llvm_v8i16_ty, llvm_v8i16_ty, llvm_v8i16_ty>;
defm vsubuh   : int_postrisc_r3<llvm_v8i16_ty, llvm_v8i16_ty, llvm_v8i16_ty>;
defm vsubssh  : int_postrisc_r3<llvm_v8i16_ty, llvm_v8i16_ty, llvm_v8i16_ty>;
defm vsubush  : int_postrisc_r3<llvm_v8i16_ty, llvm_v8i16_ty, llvm_v8i16_ty>;
defm vmrghh   : int_postrisc_r3<llvm_v8i16_ty, llvm_v8i16_ty, llvm_v8i16_ty>;
defm vmrglh   : int_postrisc_r3<llvm_v8i16_ty, llvm_v8i16_ty, llvm_v8i16_ty>;

///////////////////////////////////////////////////////////////////////////////////////
// int vector 4-byte
///////////////////////////////////////////////////////////////////////////////////////

defm vaddcw   : int_postrisc_r3<llvm_v4i32_ty, llvm_v4i32_ty, llvm_v4i32_ty>;
defm vaddow   : int_postrisc_r3<llvm_v4i32_ty, llvm_v4i32_ty, llvm_v4i32_ty>;
defm vaddssw  : int_postrisc_r3<llvm_v4i32_ty, llvm_v4i32_ty, llvm_v4i32_ty>;
defm vaddusw  : int_postrisc_r3<llvm_v4i32_ty, llvm_v4i32_ty, llvm_v4i32_ty>;
defm vadduw   : int_postrisc_r3<llvm_v4i32_ty, llvm_v4i32_ty, llvm_v4i32_ty>;
defm vavguw   : int_postrisc_r3<llvm_v4i32_ty, llvm_v4i32_ty, llvm_v4i32_ty>;
defm vavgsw   : int_postrisc_r3<llvm_v4i32_ty, llvm_v4i32_ty, llvm_v4i32_ty>;
defm vcmpeqw  : int_postrisc_r3<llvm_v4i32_ty, llvm_v4i32_ty, llvm_v4i32_ty>;
defm vcmpltw  : int_postrisc_r3<llvm_v4i32_ty, llvm_v4i32_ty, llvm_v4i32_ty>;
defm vcmpltuw : int_postrisc_r3<llvm_v4i32_ty, llvm_v4i32_ty, llvm_v4i32_ty>;
defm vmaxsw   : int_postrisc_r3<llvm_v4i32_ty, llvm_v4i32_ty, llvm_v4i32_ty>;
defm vmaxuw   : int_postrisc_r3<llvm_v4i32_ty, llvm_v4i32_ty, llvm_v4i32_ty>;
defm vminsw   : int_postrisc_r3<llvm_v4i32_ty, llvm_v4i32_ty, llvm_v4i32_ty>;
defm vminuw   : int_postrisc_r3<llvm_v4i32_ty, llvm_v4i32_ty, llvm_v4i32_ty>;
defm vrolw    : int_postrisc_r3<llvm_v4i32_ty, llvm_v4i32_ty, llvm_v4i32_ty>;
defm vrorw    : int_postrisc_r3<llvm_v4i32_ty, llvm_v4i32_ty, llvm_v4i32_ty>;
defm vsllw    : int_postrisc_r3<llvm_v4i32_ty, llvm_v4i32_ty, llvm_v4i32_ty>;
defm vsraw    : int_postrisc_r3<llvm_v4i32_ty, llvm_v4i32_ty, llvm_v4i32_ty>;
defm vsrlw    : int_postrisc_r3<llvm_v4i32_ty, llvm_v4i32_ty, llvm_v4i32_ty>;
defm vsubbw   : int_postrisc_r3<llvm_v4i32_ty, llvm_v4i32_ty, llvm_v4i32_ty>;
defm vsubow   : int_postrisc_r3<llvm_v4i32_ty, llvm_v4i32_ty, llvm_v4i32_ty>;
defm vsubuw   : int_postrisc_r3<llvm_v4i32_ty, llvm_v4i32_ty, llvm_v4i32_ty>;
defm vsubssw  : int_postrisc_r3<llvm_v4i32_ty, llvm_v4i32_ty, llvm_v4i32_ty>;
defm vsubusw  : int_postrisc_r3<llvm_v4i32_ty, llvm_v4i32_ty, llvm_v4i32_ty>;
defm vmrghw   : int_postrisc_r3<llvm_v4i32_ty, llvm_v4i32_ty, llvm_v4i32_ty>;
defm vmrglw   : int_postrisc_r3<llvm_v4i32_ty, llvm_v4i32_ty, llvm_v4i32_ty>;

///////////////////////////////////////////////////////////////////////////////////////
// int vector 8-byte
///////////////////////////////////////////////////////////////////////////////////////

defm vaddcd   : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;
defm vaddod   : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;
defm vaddssd  : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;
defm vaddusd  : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;
defm vaddud   : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;
defm vavgud   : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;
defm vavgsd   : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;
defm vcmpeqd  : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;
defm vcmpltd  : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;
defm vcmpltud : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;
defm vmaxsd   : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;
defm vmaxud   : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;
defm vminsd   : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;
defm vminud   : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;
defm vrold    : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;
defm vrord    : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;
defm vslld    : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;
defm vsrad    : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;
defm vsrld    : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;
defm vsubbd   : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;
defm vsubod   : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;
defm vsubud   : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;
defm vsubssd  : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;
defm vsubusd  : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;
defm vmrghd   : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;
defm vmrgld   : int_postrisc_r3<llvm_v2i64_ty, llvm_v2i64_ty, llvm_v2i64_ty>;

///////////////////////////////////////////////////////////////////////////////////////
// int vector mixed
///////////////////////////////////////////////////////////////////////////////////////

defm vpksssh  : int_postrisc_r3<llvm_v16i8_ty, llvm_v8i16_ty, llvm_v8i16_ty>;
defm vpksssw  : int_postrisc_r3<llvm_v8i16_ty, llvm_v4i32_ty, llvm_v4i32_ty>;
defm vpksssd  : int_postrisc_r3<llvm_v4i32_ty, llvm_v2i64_ty, llvm_v2i64_ty>;
defm vpksush  : int_postrisc_r3<llvm_v16i8_ty, llvm_v8i16_ty, llvm_v8i16_ty>;
defm vpksusw  : int_postrisc_r3<llvm_v8i16_ty, llvm_v4i32_ty, llvm_v4i32_ty>;
defm vpksusd  : int_postrisc_r3<llvm_v4i32_ty, llvm_v2i64_ty, llvm_v2i64_ty>;
defm vpkuumh  : int_postrisc_r3<llvm_v16i8_ty, llvm_v8i16_ty, llvm_v8i16_ty>;
defm vpkuumw  : int_postrisc_r3<llvm_v8i16_ty, llvm_v4i32_ty, llvm_v4i32_ty>;
defm vpkuumd  : int_postrisc_r3<llvm_v4i32_ty, llvm_v2i64_ty, llvm_v2i64_ty>;
defm vpkuush  : int_postrisc_r3<llvm_v16i8_ty, llvm_v8i16_ty, llvm_v8i16_ty>;
defm vpkuusw  : int_postrisc_r3<llvm_v8i16_ty, llvm_v4i32_ty, llvm_v4i32_ty>;
defm vpkuusd  : int_postrisc_r3<llvm_v4i32_ty, llvm_v2i64_ty, llvm_v2i64_ty>;

defm vupkhsb  : int_postrisc_r2<llvm_v8i16_ty, llvm_v16i8_ty>;
defm vupkhsh  : int_postrisc_r2<llvm_v4i32_ty, llvm_v8i16_ty>;
defm vupkhsw  : int_postrisc_r2<llvm_v2i64_ty, llvm_v4i32_ty>;
defm vupklsb  : int_postrisc_r2<llvm_v8i16_ty, llvm_v16i8_ty>;
defm vupklsh  : int_postrisc_r2<llvm_v4i32_ty, llvm_v8i16_ty>;
defm vupklsw  : int_postrisc_r2<llvm_v2i64_ty, llvm_v4i32_ty>;

} // postrisc
