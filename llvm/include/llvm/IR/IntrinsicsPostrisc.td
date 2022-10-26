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

defvar Fh = llvm_half_ty;
defvar Fw = llvm_float_ty;
defvar Fd = llvm_double_ty;
defvar Fq = llvm_f128_ty;
defvar vFh = llvm_v8f16_ty;
defvar vFw = llvm_v4f32_ty;
defvar vFd = llvm_v2f64_ty;
defvar vIb = llvm_v16i8_ty;
defvar vIh = llvm_v8i16_ty;
defvar vIw = llvm_v4i32_ty;
defvar vId = llvm_v2i64_ty;

///////////////////////////////////////////////////////////////////////////////////////
// patterns
///////////////////////////////////////////////////////////////////////////////////////
multiclass fmt_r2<LLVMType Ta, LLVMType Tb> {
  def int_postrisc_ # NAME : ClangBuiltin<!strconcat("__builtin_postrisc_", NAME)>,
      Intrinsic<[Ta], [Tb], [IntrNoMem]>;
}

multiclass fmt_r2_shamt<LLVMType Ta, LLVMType Tb> {
  def int_postrisc_ # NAME : ClangBuiltin<!strconcat("__builtin_postrisc_", NAME)>,
      Intrinsic<[Ta], [Tb, llvm_i32_ty], [IntrNoMem, ImmArg<ArgIndex<1>>]>;
}

multiclass fmt_r3<LLVMType Ta, LLVMType Tb, LLVMType Tc> {
  def int_postrisc_ # NAME : ClangBuiltin<!strconcat("__builtin_postrisc_", NAME)>,
      Intrinsic<[Ta], [Tb, Tc], [IntrNoMem]>;
}

multiclass fmt_r3_shamt<LLVMType Ta, LLVMType Tb, LLVMType Tc> {
  def int_postrisc_ # NAME : ClangBuiltin<!strconcat("__builtin_postrisc_", NAME)>,
      Intrinsic<[Ta], [Tb, Tc, llvm_i32_ty], [IntrNoMem, ImmArg<ArgIndex<2>>]>;
}

multiclass fmt_r4<LLVMType Ta, LLVMType Tb, LLVMType Tc, LLVMType Td> {
  def int_postrisc_ # NAME : ClangBuiltin<!strconcat("__builtin_postrisc_", NAME)>,
      Intrinsic<[Ta], [Tb, Tc, Td], [IntrNoMem]>;
}

///////////////////////////////////////////////////////////////////////////////////////
// patterns with explicit rpunding mode
///////////////////////////////////////////////////////////////////////////////////////
multiclass fmt_r2rm<LLVMType Ta, LLVMType Tb> {
  def int_postrisc_ # NAME : ClangBuiltin<!strconcat("__builtin_postrisc_", NAME)>,
      Intrinsic<[Ta], [Tb, llvm_i32_ty], [IntrNoMem, ImmArg<ArgIndex<1>>]>;
}

multiclass fmt_r3rm<LLVMType Ta, LLVMType Tb, LLVMType Tc> {
  def int_postrisc_ # NAME : ClangBuiltin<!strconcat("__builtin_postrisc_", NAME)>,
      Intrinsic<[Ta], [Tb, Tc, llvm_i32_ty], [IntrNoMem, ImmArg<ArgIndex<2>>]>;
}

multiclass fmt_r4rm<LLVMType Ta, LLVMType Tb, LLVMType Tc, LLVMType Td> {
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

defm bit_gather  : fmt_r3<llvm_i64_ty, llvm_i64_ty, llvm_i64_ty>;
defm bit_scatter : fmt_r3<llvm_i64_ty, llvm_i64_ty, llvm_i64_ty>;

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
multiclass special_reg<LLVMType Ty> {
  def int_postrisc_get_ # NAME : ClangBuiltin<!strconcat("__builtin_postrisc_get_", NAME)>,
      Intrinsic<[Ty], [], [IntrNoMem]>;
  def int_postrisc_set_ # NAME : ClangBuiltin<!strconcat("__builtin_postrisc_set_", NAME)>,
      Intrinsic<[], [Ty], [IntrNoMem, IntrHasSideEffects]>;
}

defm ip:    special_reg<llvm_i64_ty>;
defm eip:   special_reg<llvm_i64_ty>;
defm fpcr:  special_reg<llvm_i64_ty>;
defm eca:   special_reg<llvm_i64_ty>;
defm rsc:   special_reg<llvm_i64_ty>;
defm rsp:   special_reg<llvm_i64_ty>;
defm bsp:   special_reg<llvm_i64_ty>;
defm psr:   special_reg<llvm_i64_ty>;
defm reip:  special_reg<llvm_i64_ty>;
defm kip:   special_reg<llvm_i64_ty>;
defm ksp:   special_reg<llvm_i64_ty>;
defm krsp:  special_reg<llvm_i64_ty>;
defm peb:   special_reg<llvm_i64_ty>;
defm teb:   special_reg<llvm_i64_ty>;
defm itc:   special_reg<llvm_i64_ty>;
defm itm:   special_reg<llvm_i64_ty>;
defm pta:   special_reg<llvm_i64_ty>;
defm iva:   special_reg<llvm_i64_ty>;
defm iip:   special_reg<llvm_i64_ty>;
defm iipa:  special_reg<llvm_i64_ty>;
defm ipsr:  special_reg<llvm_i64_ty>;
defm cause: special_reg<llvm_i64_ty>;
defm ifa:   special_reg<llvm_i64_ty>;
defm iib:   special_reg<llvm_i128_ty>; // 128-bit bundle
defm irr0:  special_reg<llvm_i64_ty>;
defm irr1:  special_reg<llvm_i64_ty>;
defm irr2:  special_reg<llvm_i64_ty>;
defm irr3:  special_reg<llvm_i64_ty>;
defm isr0:  special_reg<llvm_i64_ty>;
defm isr1:  special_reg<llvm_i64_ty>;
defm isr2:  special_reg<llvm_i64_ty>;
defm isr3:  special_reg<llvm_i64_ty>;
defm iv:    special_reg<llvm_i64_ty>;
defm lid:   special_reg<llvm_i64_ty>;
defm tpr:   special_reg<llvm_i64_ty>;
defm itcv:  special_reg<llvm_i64_ty>;
defm tsv:   special_reg<llvm_i64_ty>;
defm pmv:   special_reg<llvm_i64_ty>;
defm cmcv:  special_reg<llvm_i64_ty>;

///////////////////////////////////////////////////////////////////////////////////////
// debug registers
///////////////////////////////////////////////////////////////////////////////////////

def int_postrisc_get_mr  : ClangBuiltin<"__builtin_postrisc_get_mr">,  Intrinsic<[llvm_i64_ty], [llvm_i64_ty], []>;
def int_postrisc_get_ibr : ClangBuiltin<"__builtin_postrisc_get_ibr">, Intrinsic<[llvm_i64_ty], [llvm_i64_ty], []>;
def int_postrisc_get_dbr : ClangBuiltin<"__builtin_postrisc_get_dbr">, Intrinsic<[llvm_i64_ty], [llvm_i64_ty], []>;

def int_postrisc_set_mr  : ClangBuiltin<"__builtin_postrisc_set_mr">,  Intrinsic<[], [llvm_i64_ty, llvm_i64_ty], [IntrNoMem, IntrHasSideEffects]>;
def int_postrisc_set_ibr : ClangBuiltin<"__builtin_postrisc_set_ibr">, Intrinsic<[], [llvm_i64_ty, llvm_i64_ty], [IntrNoMem, IntrHasSideEffects]>;
def int_postrisc_set_dbr : ClangBuiltin<"__builtin_postrisc_set_dbr">, Intrinsic<[], [llvm_i64_ty, llvm_i64_ty], [IntrNoMem, IntrHasSideEffects]>;

def int_postrisc_set_dtr : ClangBuiltin<"__builtin_postrisc_set_dtr">, Intrinsic<[], [llvm_i64_ty, llvm_ptr_ty, llvm_i32_ty], [IntrNoMem, IntrHasSideEffects]>;
def int_postrisc_set_itr : ClangBuiltin<"__builtin_postrisc_set_itr">, Intrinsic<[], [llvm_i64_ty, llvm_ptr_ty, llvm_i32_ty], [IntrNoMem, IntrHasSideEffects]>;

def int_postrisc_rscover : ClangBuiltin<"__builtin_postrisc_rscover">, Intrinsic<[], [], []>;
def int_postrisc_rsflush : ClangBuiltin<"__builtin_postrisc_rsflush">, Intrinsic<[], [], []>;
def int_postrisc_rsload  : ClangBuiltin<"__builtin_postrisc_rsload">,  Intrinsic<[], [], []>;

///////////////////////////////////////////////////////////////////////////////////////
// Advanced Encryption Standard (AES) Instructions
///////////////////////////////////////////////////////////////////////////////////////

defm aesimc     : fmt_r2<vId, vId>;
defm aesenc     : fmt_r3<vId, vId, vId>;
defm aesenclast : fmt_r3<vId, vId, vId>;
defm aesdec     : fmt_r3<vId, vId, vId>;
defm aesdeclast : fmt_r3<vId, vId, vId>;

def int_postrisc_aeskeygenassist : ClangBuiltin<"__builtin_postrisc_aeskeygenassist">,
  Intrinsic<[vId], [vId, llvm_i32_ty], [IntrNoMem, ImmArg<ArgIndex<1>>]>;

///////////////////////////////////////////////////////////////////////////////////////
// hashing, carry less multiply
///////////////////////////////////////////////////////////////////////////////////////

defm clmul_ll : fmt_r3<vId, vId, vId>;
defm clmul_hl : fmt_r3<vId, vId, vId>;
defm clmul_hh : fmt_r3<vId, vId, vId>;

defm crc32cb : fmt_r3<llvm_i32_ty, llvm_i32_ty, llvm_i32_ty>; // FIXME i8
defm crc32ch : fmt_r3<llvm_i32_ty, llvm_i32_ty, llvm_i32_ty>; // FIXME i16
defm crc32cw : fmt_r3<llvm_i32_ty, llvm_i32_ty, llvm_i32_ty>;
defm crc32cd : fmt_r3<llvm_i32_ty, llvm_i32_ty, llvm_i64_ty>;
defm crc32cq : fmt_r3<llvm_i32_ty, llvm_i32_ty, llvm_i128_ty>;

///////////////////////////////////////////////////////////////////////////////////////
// fp scalar
///////////////////////////////////////////////////////////////////////////////////////
defm fsqrth      : fmt_r2rm<Fh, Fh>;
defm frsqrth     : fmt_r2rm<Fh, Fh>;
defm frndh       : fmt_r2rm<Fh, Fh>;
defm frndxh      : fmt_r2rm<Fh, Fh>;
defm fiwtoh      : fmt_r2rm<Fh, llvm_i32_ty>;
defm fuwtoh      : fmt_r2rm<Fh, llvm_i32_ty>;
defm fidtoh      : fmt_r2rm<Fh, llvm_i64_ty>;
defm fudtoh      : fmt_r2rm<Fh, llvm_i64_ty>;
defm fiqtoh      : fmt_r2rm<Fh, llvm_i128_ty>;
defm fuqtoh      : fmt_r2rm<Fh, llvm_i128_ty>;
defm fhtoiw      : fmt_r2rm<llvm_i32_ty, Fh>;
defm fhtouw      : fmt_r2rm<llvm_i32_ty, Fh>;
defm fhtoid      : fmt_r2rm<llvm_i64_ty, Fh>;
defm fhtoud      : fmt_r2rm<llvm_i64_ty, Fh>;
defm fhtoiq      : fmt_r2rm<llvm_i128_ty, Fh>;
defm fhtouq      : fmt_r2rm<llvm_i128_ty, Fh>;
defm fabdh       : fmt_r3rm<Fh, Fh, Fh>;
defm fnabdh      : fmt_r3rm<Fh, Fh, Fh>;
defm faddh       : fmt_r3rm<Fh, Fh, Fh>;
defm fnaddh      : fmt_r3rm<Fh, Fh, Fh>;
defm fsubh       : fmt_r3rm<Fh, Fh, Fh>;
defm fmulh       : fmt_r3rm<Fh, Fh, Fh>;
defm fnmulh      : fmt_r3rm<Fh, Fh, Fh>;
defm fdivh       : fmt_r3rm<Fh, Fh, Fh>;
defm fmaddh      : fmt_r4rm<Fh, Fh, Fh, Fh>;
defm fmsubh      : fmt_r4rm<Fh, Fh, Fh, Fh>;
defm fnmaddh     : fmt_r4rm<Fh, Fh, Fh, Fh>;
defm fnmsubh     : fmt_r4rm<Fh, Fh, Fh, Fh>;
defm fmergeh     : fmt_r4<Fh, Fh, Fh, Fh>;
defm fminimumh   : fmt_r3<Fh, Fh, Fh>;
defm fmaximumh   : fmt_r3<Fh, Fh, Fh>;

defm fsqrts      : fmt_r2rm<Fw, Fw>;
defm frsqrts     : fmt_r2rm<Fw, Fw>;
defm frnds       : fmt_r2rm<Fw, Fw>;
defm frndxs      : fmt_r2rm<Fw, Fw>;
defm fiwtos      : fmt_r2rm<Fw, llvm_i32_ty>;
defm fuwtos      : fmt_r2rm<Fw, llvm_i32_ty>;
defm fidtos      : fmt_r2rm<Fw, llvm_i64_ty>;
defm fudtos      : fmt_r2rm<Fw, llvm_i64_ty>;
defm fiqtos      : fmt_r2rm<Fw, llvm_i128_ty>;
defm fuqtos      : fmt_r2rm<Fw, llvm_i128_ty>;
defm fstoiw      : fmt_r2rm<llvm_i32_ty, Fw>;
defm fstouw      : fmt_r2rm<llvm_i32_ty, Fw>;
defm fstoid      : fmt_r2rm<llvm_i64_ty, Fw>;
defm fstoud      : fmt_r2rm<llvm_i64_ty, Fw>;
defm fstoiq      : fmt_r2rm<llvm_i128_ty, Fw>;
defm fstouq      : fmt_r2rm<llvm_i128_ty, Fw>;
defm fabds       : fmt_r3rm<Fw, Fw, Fw>;
defm fnabds      : fmt_r3rm<Fw, Fw, Fw>;
defm fadds       : fmt_r3rm<Fw, Fw, Fw>;
defm fnadds      : fmt_r3rm<Fw, Fw, Fw>;
defm fsubs       : fmt_r3rm<Fw, Fw, Fw>;
defm fmuls       : fmt_r3rm<Fw, Fw, Fw>;
defm fnmuls      : fmt_r3rm<Fw, Fw, Fw>;
defm fdivs       : fmt_r3rm<Fw, Fw, Fw>;
defm fmadds      : fmt_r4rm<Fw, Fw, Fw, Fw>;
defm fmsubs      : fmt_r4rm<Fw, Fw, Fw, Fw>;
defm fnmadds     : fmt_r4rm<Fw, Fw, Fw, Fw>;
defm fnmsubs     : fmt_r4rm<Fw, Fw, Fw, Fw>;
defm fmerges     : fmt_r4<Fw, Fw, Fw, Fw>;
defm fminimums   : fmt_r3<Fw, Fw, Fw>;
defm fmaximums   : fmt_r3<Fw, Fw, Fw>;

defm fsqrtd      : fmt_r2rm<Fd, Fd>;
defm frsqrtd     : fmt_r2rm<Fd, Fd>;
defm frndd       : fmt_r2rm<Fd, Fd>;
defm frndxd      : fmt_r2rm<Fd, Fd>;
defm fiwtod      : fmt_r2rm<Fd, llvm_i32_ty>;
defm fuwtod      : fmt_r2rm<Fd, llvm_i32_ty>;
defm fidtod      : fmt_r2rm<Fd, llvm_i64_ty>;
defm fudtod      : fmt_r2rm<Fd, llvm_i64_ty>;
defm fiqtod      : fmt_r2rm<Fd, llvm_i128_ty>;
defm fuqtod      : fmt_r2rm<Fd, llvm_i128_ty>;
defm fdtoiw      : fmt_r2rm<llvm_i32_ty, Fd>;
defm fdtouw      : fmt_r2rm<llvm_i32_ty, Fd>;
defm fdtoid      : fmt_r2rm<llvm_i64_ty, Fd>;
defm fdtoud      : fmt_r2rm<llvm_i64_ty, Fd>;
defm fdtoiq      : fmt_r2rm<llvm_i128_ty, Fd>;
defm fdtouq      : fmt_r2rm<llvm_i128_ty, Fd>;
defm fabdd       : fmt_r3rm<Fd, Fd, Fd>;
defm fnabdd      : fmt_r3rm<Fd, Fd, Fd>;
defm faddd       : fmt_r3rm<Fd, Fd, Fd>;
defm fnaddd      : fmt_r3rm<Fd, Fd, Fd>;
defm fsubd       : fmt_r3rm<Fd, Fd, Fd>;
defm fmuld       : fmt_r3rm<Fd, Fd, Fd>;
defm fnmuld      : fmt_r3rm<Fd, Fd, Fd>;
defm fdivd       : fmt_r3rm<Fd, Fd, Fd>;
defm fmaddd      : fmt_r4rm<Fd, Fd, Fd, Fd>;
defm fmsubd      : fmt_r4rm<Fd, Fd, Fd, Fd>;
defm fnmaddd     : fmt_r4rm<Fd, Fd, Fd, Fd>;
defm fnmsubd     : fmt_r4rm<Fd, Fd, Fd, Fd>;
defm fmerged     : fmt_r4<Fd, Fd, Fd, Fd>;
defm fminimumd   : fmt_r3<Fd, Fd, Fd>;
defm fmaximumd   : fmt_r3<Fd, Fd, Fd>;

defm fsqrtq      : fmt_r2rm<Fq, Fq>;
defm frsqrtq     : fmt_r2rm<Fq, Fq>;
defm frndq       : fmt_r2rm<Fq, Fq>;
defm frndxq      : fmt_r2rm<Fq, Fq>;
defm fiwtoq      : fmt_r2rm<Fq, llvm_i32_ty>;
defm fuwtoq      : fmt_r2rm<Fq, llvm_i32_ty>;
defm fidtoq      : fmt_r2rm<Fq, llvm_i64_ty>;
defm fudtoq      : fmt_r2rm<Fq, llvm_i64_ty>;
defm fiqtoq      : fmt_r2rm<Fq, llvm_i128_ty>;
defm fuqtoq      : fmt_r2rm<Fq, llvm_i128_ty>;
defm fqtoiw      : fmt_r2rm<llvm_i32_ty, Fq>;
defm fqtouw      : fmt_r2rm<llvm_i32_ty, Fq>;
defm fqtoid      : fmt_r2rm<llvm_i64_ty, Fq>;
defm fqtoud      : fmt_r2rm<llvm_i64_ty, Fq>;
defm fqtoiq      : fmt_r2rm<llvm_i128_ty, Fq>;
defm fqtouq      : fmt_r2rm<llvm_i128_ty, Fq>;
defm fabdq       : fmt_r3rm<Fq, Fq, Fq>;
defm fnabdq      : fmt_r3rm<Fq, Fq, Fq>;
defm faddq       : fmt_r3rm<Fq, Fq, Fq>;
defm fnaddq      : fmt_r3rm<Fq, Fq, Fq>;
defm fsubq       : fmt_r3rm<Fq, Fq, Fq>;
defm fmulq       : fmt_r3rm<Fq, Fq, Fq>;
defm fnmulq      : fmt_r3rm<Fq, Fq, Fq>;
defm fdivq       : fmt_r3rm<Fq, Fq, Fq>;
defm fmaddq      : fmt_r4rm<Fq, Fq, Fq, Fq>;
defm fmsubq      : fmt_r4rm<Fq, Fq, Fq, Fq>;
defm fnmaddq     : fmt_r4rm<Fq, Fq, Fq, Fq>;
defm fnmsubq     : fmt_r4rm<Fq, Fq, Fq, Fq>;
defm fmergeq     : fmt_r4<Fq, Fq, Fq, Fq>;
defm fminimumq   : fmt_r3<Fq, Fq, Fq>;
defm fmaximumq   : fmt_r3<Fq, Fq, Fq>;

defm fstoh : fmt_r2rm<Fh, Fw>;
defm fdtoh : fmt_r2rm<Fh, Fd>;
defm fdtos : fmt_r2rm<Fw, Fd>;
defm fqtoh : fmt_r2rm<Fh, Fq>;
defm fqtos : fmt_r2rm<Fw, Fq>;
defm fqtod : fmt_r2rm<Fd, Fq>;

///////////////////////////////////////////////////////////////////////////////////////
// fp vector
///////////////////////////////////////////////////////////////////////////////////////
defm vfsqrth    : fmt_r2rm<vFh, vFh>;
defm vfrsqrth   : fmt_r2rm<vFh, vFh>;
defm vfrndh     : fmt_r2rm<vFh, vFh>;
defm vfrndxh    : fmt_r2rm<vFh, vFh>;
defm vfuhtoh    : fmt_r2rm<vFh, vIh>;
defm vfihtoh    : fmt_r2rm<vFh, vIh>;
defm vfhtouh    : fmt_r2rm<vIh, vFh>;
defm vfhtoih    : fmt_r2rm<vIh, vFh>;
defm vfabdh     : fmt_r3rm<vFh, vFh, vFh>;
defm vfnabdh    : fmt_r3rm<vFh, vFh, vFh>;
defm vfaddh     : fmt_r3rm<vFh, vFh, vFh>;
defm vfnaddh    : fmt_r3rm<vFh, vFh, vFh>;
defm vfsubh     : fmt_r3rm<vFh, vFh, vFh>;
defm vfmulh     : fmt_r3rm<vFh, vFh, vFh>;
defm vfnmulh    : fmt_r3rm<vFh, vFh, vFh>;
defm vfdivh     : fmt_r3rm<vFh, vFh, vFh>;
defm vfaddsubh  : fmt_r3rm<vFh, vFh, vFh>;
defm vfsubaddh  : fmt_r3rm<vFh, vFh, vFh>;
defm vfhaddh    : fmt_r3rm<vFh, vFh, vFh>;
defm vfhmulh    : fmt_r3rm<vFh, vFh, vFh>;
defm vfhsubh    : fmt_r3rm<vFh, vFh, vFh>;
defm vfdoth     : fmt_r3rm<vFh, vFh, vFh>;
defm vfmaddh    : fmt_r4rm<vFh, vFh, vFh, vFh>;
defm vfmsubh    : fmt_r4rm<vFh, vFh, vFh, vFh>;
defm vfnmaddh   : fmt_r4rm<vFh, vFh, vFh, vFh>;
defm vfnmsubh   : fmt_r4rm<vFh, vFh, vFh, vFh>;
defm vfmaddsubh : fmt_r4rm<vFh, vFh, vFh, vFh>;
defm vfmsubaddh : fmt_r4rm<vFh, vFh, vFh, vFh>;
defm vfmergeh   : fmt_r4<vFh, vFh, vFh, vFh>;
defm vfcmpoeqh  : fmt_r3<vIh, vFh, vFh>;
defm vfcmponeh  : fmt_r3<vIh, vFh, vFh>;
defm vfcmpolth  : fmt_r3<vIh, vFh, vFh>;
defm vfcmpogeh  : fmt_r3<vIh, vFh, vFh>;
defm vfcmpueqh  : fmt_r3<vIh, vFh, vFh>;
defm vfcmpuneh  : fmt_r3<vIh, vFh, vFh>;
defm vfcmpulth  : fmt_r3<vIh, vFh, vFh>;
defm vfcmpugeh  : fmt_r3<vIh, vFh, vFh>;
defm vfcmpoh    : fmt_r3<vIh, vFh, vFh>;
defm vfcmpuh    : fmt_r3<vIh, vFh, vFh>;
defm vfmergehh  : fmt_r3<vFh, vFh, vFh>;
defm vfmergelh  : fmt_r3<vFh, vFh, vFh>;
defm vfupkhh    : fmt_r2<vFh, vFh>;
defm vfupklh    : fmt_r2<vFh, vFh>;

defm vfsqrts    : fmt_r2rm<vFw, vFw>;
defm vfrsqrts   : fmt_r2rm<vFw, vFw>;
defm vfrnds     : fmt_r2rm<vFw, vFw>;
defm vfrndxs    : fmt_r2rm<vFw, vFw>;
defm vfuwtos    : fmt_r2rm<vFw, vIw>;
defm vfiwtos    : fmt_r2rm<vFw, vIw>;
defm vfstouw    : fmt_r2rm<vIw, vFw>;
defm vfstoiw    : fmt_r2rm<vIw, vFw>;
defm vfabds     : fmt_r3rm<vFw, vFw, vFw>;
defm vfnabds    : fmt_r3rm<vFw, vFw, vFw>;
defm vfadds     : fmt_r3rm<vFw, vFw, vFw>;
defm vfnadds    : fmt_r3rm<vFw, vFw, vFw>;
defm vfsubs     : fmt_r3rm<vFw, vFw, vFw>;
defm vfmuls     : fmt_r3rm<vFw, vFw, vFw>;
defm vfnmuls    : fmt_r3rm<vFw, vFw, vFw>;
defm vfdivs     : fmt_r3rm<vFw, vFw, vFw>;
defm vfaddsubs  : fmt_r3rm<vFw, vFw, vFw>;
defm vfsubadds  : fmt_r3rm<vFw, vFw, vFw>;
defm vfhadds    : fmt_r3rm<vFw, vFw, vFw>;
defm vfhmuls    : fmt_r3rm<vFw, vFw, vFw>;
defm vfhsubs    : fmt_r3rm<vFw, vFw, vFw>;
defm vfdots     : fmt_r3rm<vFw, vFw, vFw>;
defm vfmadds    : fmt_r4rm<vFw, vFw, vFw, vFw>;
defm vfmsubs    : fmt_r4rm<vFw, vFw, vFw, vFw>;
defm vfnmadds   : fmt_r4rm<vFw, vFw, vFw, vFw>;
defm vfnmsubs   : fmt_r4rm<vFw, vFw, vFw, vFw>;
defm vfmaddsubs : fmt_r4rm<vFw, vFw, vFw, vFw>;
defm vfmsubadds : fmt_r4rm<vFw, vFw, vFw, vFw>;
defm vfmerges   : fmt_r4<vFw, vFw, vFw, vFw>;
defm vfcmpoeqs  : fmt_r3<vIw, vFw, vFw>;
defm vfcmpones  : fmt_r3<vIw, vFw, vFw>;
defm vfcmpolts  : fmt_r3<vIw, vFw, vFw>;
defm vfcmpoges  : fmt_r3<vIw, vFw, vFw>;
defm vfcmpueqs  : fmt_r3<vIw, vFw, vFw>;
defm vfcmpunes  : fmt_r3<vIw, vFw, vFw>;
defm vfcmpults  : fmt_r3<vIw, vFw, vFw>;
defm vfcmpuges  : fmt_r3<vIw, vFw, vFw>;
defm vfcmpos    : fmt_r3<vIw, vFw, vFw>;
defm vfcmpus    : fmt_r3<vIw, vFw, vFw>;
defm vfmergehs  : fmt_r3<vFw, vFw, vFw>;
defm vfmergels  : fmt_r3<vFw, vFw, vFw>;
defm vfupkhs    : fmt_r2<vFw, vFw>;
defm vfupkls    : fmt_r2<vFw, vFw>;

defm vfsqrtd    : fmt_r2rm<vFd, vFd>;
defm vfrsqrtd   : fmt_r2rm<vFd, vFd>;
defm vfrndd     : fmt_r2rm<vFd, vFd>;
defm vfrndxd    : fmt_r2rm<vFd, vFd>;
defm vfudtod    : fmt_r2rm<vFd, vId>;
defm vfidtod    : fmt_r2rm<vFd, vId>;
defm vfdtoud    : fmt_r2rm<vId, vFd>;
defm vfdtoid    : fmt_r2rm<vId, vFd>;
defm vfabdd     : fmt_r3rm<vFd, vFd, vFd>;
defm vfnabdd    : fmt_r3rm<vFd, vFd, vFd>;
defm vfaddd     : fmt_r3rm<vFd, vFd, vFd>;
defm vfnaddd    : fmt_r3rm<vFd, vFd, vFd>;
defm vfsubd     : fmt_r3rm<vFd, vFd, vFd>;
defm vfmuld     : fmt_r3rm<vFd, vFd, vFd>;
defm vfnmuld    : fmt_r3rm<vFd, vFd, vFd>;
defm vfdivd     : fmt_r3rm<vFd, vFd, vFd>;
defm vfaddsubd  : fmt_r3rm<vFd, vFd, vFd>;
defm vfsubaddd  : fmt_r3rm<vFd, vFd, vFd>;
defm vfhaddd    : fmt_r3rm<vFd, vFd, vFd>;
defm vfhmuld    : fmt_r3rm<vFd, vFd, vFd>;
defm vfhsubd    : fmt_r3rm<vFd, vFd, vFd>;
defm vfdotd     : fmt_r3rm<vFd, vFd, vFd>;
defm vfmaddd    : fmt_r4rm<vFd, vFd, vFd, vFd>;
defm vfmsubd    : fmt_r4rm<vFd, vFd, vFd, vFd>;
defm vfnmaddd   : fmt_r4rm<vFd, vFd, vFd, vFd>;
defm vfnmsubd   : fmt_r4rm<vFd, vFd, vFd, vFd>;
defm vfmaddsubd : fmt_r4rm<vFd, vFd, vFd, vFd>;
defm vfmsubaddd : fmt_r4rm<vFd, vFd, vFd, vFd>;
defm vfmerged   : fmt_r4<vFd, vFd, vFd, vFd>;
defm vfcmpoeqd  : fmt_r3<vId, vFd, vFd>;
defm vfcmponed  : fmt_r3<vId, vFd, vFd>;
defm vfcmpoltd  : fmt_r3<vId, vFd, vFd>;
defm vfcmpoged  : fmt_r3<vId, vFd, vFd>;
defm vfcmpueqd  : fmt_r3<vId, vFd, vFd>;
defm vfcmpuned  : fmt_r3<vId, vFd, vFd>;
defm vfcmpultd  : fmt_r3<vId, vFd, vFd>;
defm vfcmpuged  : fmt_r3<vId, vFd, vFd>;
defm vfcmpod    : fmt_r3<vId, vFd, vFd>;
defm vfcmpud    : fmt_r3<vId, vFd, vFd>;
defm vfmergehd  : fmt_r3<vFd, vFd, vFd>;
defm vfmergeld  : fmt_r3<vFd, vFd, vFd>;
defm vfupkhd    : fmt_r2<vFd, vFd>;
defm vfupkld    : fmt_r2<vFd, vFd>;

///////////////////////////////////////////////////////////////////////////////////////
// int vector
///////////////////////////////////////////////////////////////////////////////////////
defm vaddb      : fmt_r3<vIb, vIb, vIb>;
defm vsubb      : fmt_r3<vIb, vIb, vIb>;
defm vaddcb     : fmt_r3<vIb, vIb, vIb>;
defm vsubcb     : fmt_r3<vIb, vIb, vIb>;
defm vaddob     : fmt_r3<vIb, vIb, vIb>;
defm vsubob     : fmt_r3<vIb, vIb, vIb>;
defm vaddssatb  : fmt_r3<vIb, vIb, vIb>;
defm vsubssatb  : fmt_r3<vIb, vIb, vIb>;
defm vaddusatb  : fmt_r3<vIb, vIb, vIb>;
defm vsubusatb  : fmt_r3<vIb, vIb, vIb>;
defm vminsb     : fmt_r3<vIb, vIb, vIb>;
defm vmaxsb     : fmt_r3<vIb, vIb, vIb>;
defm vminub     : fmt_r3<vIb, vIb, vIb>;
defm vmaxub     : fmt_r3<vIb, vIb, vIb>;
defm vavgsb     : fmt_r3<vIb, vIb, vIb>;
defm vavgub     : fmt_r3<vIb, vIb, vIb>;
defm vcmpeqb    : fmt_r3<vIb, vIb, vIb>;
defm vcmpltsb   : fmt_r3<vIb, vIb, vIb>;
defm vcmpltub   : fmt_r3<vIb, vIb, vIb>;
defm vsllb      : fmt_r3<vIb, vIb, vIb>;
defm vsrlb      : fmt_r3<vIb, vIb, vIb>;
defm vsrab      : fmt_r3<vIb, vIb, vIb>;
defm vmergehb   : fmt_r3<vIb, vIb, vIb>;
defm vmergelb   : fmt_r3<vIb, vIb, vIb>;
defm vsllib     : fmt_r2_shamt<vIb, vIb>;
defm vsrlib     : fmt_r2_shamt<vIb, vIb>;
defm vsraib     : fmt_r2_shamt<vIb, vIb>;
defm vsrpib     : fmt_r3_shamt<vIb, vIb, vIb>;
defm vslpb      : fmt_r4<vIb, vIb, vIb, vIb>;
defm vsrpb      : fmt_r4<vIb, vIb, vIb, vIb>;
defm vsplatb    : fmt_r3<vIb, vIb, llvm_i32_ty>;

defm vaddh      : fmt_r3<vIh, vIh, vIh>;
defm vsubh      : fmt_r3<vIh, vIh, vIh>;
defm vaddch     : fmt_r3<vIh, vIh, vIh>;
defm vsubch     : fmt_r3<vIh, vIh, vIh>;
defm vaddoh     : fmt_r3<vIh, vIh, vIh>;
defm vsuboh     : fmt_r3<vIh, vIh, vIh>;
defm vaddssath  : fmt_r3<vIh, vIh, vIh>;
defm vsubssath  : fmt_r3<vIh, vIh, vIh>;
defm vaddusath  : fmt_r3<vIh, vIh, vIh>;
defm vsubusath  : fmt_r3<vIh, vIh, vIh>;
defm vminsh     : fmt_r3<vIh, vIh, vIh>;
defm vmaxsh     : fmt_r3<vIh, vIh, vIh>;
defm vminuh     : fmt_r3<vIh, vIh, vIh>;
defm vmaxuh     : fmt_r3<vIh, vIh, vIh>;
defm vavgsh     : fmt_r3<vIh, vIh, vIh>;
defm vavguh     : fmt_r3<vIh, vIh, vIh>;
defm vcmpeqh    : fmt_r3<vIh, vIh, vIh>;
defm vcmpltsh   : fmt_r3<vIh, vIh, vIh>;
defm vcmpltuh   : fmt_r3<vIh, vIh, vIh>;
defm vsllh      : fmt_r3<vIh, vIh, vIh>;
defm vsrlh      : fmt_r3<vIh, vIh, vIh>;
defm vsrah      : fmt_r3<vIh, vIh, vIh>;
defm vmergehh   : fmt_r3<vIh, vIh, vIh>;
defm vmergelh   : fmt_r3<vIh, vIh, vIh>;
defm vsllih     : fmt_r2_shamt<vIh, vIh>;
defm vsrlih     : fmt_r2_shamt<vIh, vIh>;
defm vsraih     : fmt_r2_shamt<vIh, vIh>;
defm vsrpih     : fmt_r3_shamt<vIh, vIh, vIh>;
defm vslph      : fmt_r4<vIh, vIh, vIh, vIh>;
defm vsrph      : fmt_r4<vIh, vIh, vIh, vIh>;
defm vsplath    : fmt_r3<vIh, vIh, llvm_i32_ty>;

defm vaddw      : fmt_r3<vIw, vIw, vIw>;
defm vsubw      : fmt_r3<vIw, vIw, vIw>;
defm vaddcw     : fmt_r3<vIw, vIw, vIw>;
defm vsubcw     : fmt_r3<vIw, vIw, vIw>;
defm vaddow     : fmt_r3<vIw, vIw, vIw>;
defm vsubow     : fmt_r3<vIw, vIw, vIw>;
defm vaddssatw  : fmt_r3<vIw, vIw, vIw>;
defm vsubssatw  : fmt_r3<vIw, vIw, vIw>;
defm vaddusatw  : fmt_r3<vIw, vIw, vIw>;
defm vsubusatw  : fmt_r3<vIw, vIw, vIw>;
defm vminsw     : fmt_r3<vIw, vIw, vIw>;
defm vmaxsw     : fmt_r3<vIw, vIw, vIw>;
defm vminuw     : fmt_r3<vIw, vIw, vIw>;
defm vmaxuw     : fmt_r3<vIw, vIw, vIw>;
defm vavgsw     : fmt_r3<vIw, vIw, vIw>;
defm vavguw     : fmt_r3<vIw, vIw, vIw>;
defm vcmpeqw    : fmt_r3<vIw, vIw, vIw>;
defm vcmpltsw   : fmt_r3<vIw, vIw, vIw>;
defm vcmpltuw   : fmt_r3<vIw, vIw, vIw>;
defm vsllw      : fmt_r3<vIw, vIw, vIw>;
defm vsrlw      : fmt_r3<vIw, vIw, vIw>;
defm vsraw      : fmt_r3<vIw, vIw, vIw>;
defm vmergehw   : fmt_r3<vIw, vIw, vIw>;
defm vmergelw   : fmt_r3<vIw, vIw, vIw>;
defm vslliw     : fmt_r2_shamt<vIw, vIw>;
defm vsrliw     : fmt_r2_shamt<vIw, vIw>;
defm vsraiw     : fmt_r2_shamt<vIw, vIw>;
defm vsrpiw     : fmt_r3_shamt<vIw, vIw, vIw>;
defm vslpw      : fmt_r4<vIw, vIw, vIw, vIw>;
defm vsrpw      : fmt_r4<vIw, vIw, vIw, vIw>;
defm vsplatw    : fmt_r3<vIw, vIw, llvm_i32_ty>;

defm vaddd      : fmt_r3<vId, vId, vId>;
defm vsubd      : fmt_r3<vId, vId, vId>;
defm vaddcd     : fmt_r3<vId, vId, vId>;
defm vsubcd     : fmt_r3<vId, vId, vId>;
defm vaddod     : fmt_r3<vId, vId, vId>;
defm vsubod     : fmt_r3<vId, vId, vId>;
defm vaddssatd  : fmt_r3<vId, vId, vId>;
defm vsubssatd  : fmt_r3<vId, vId, vId>;
defm vaddusatd  : fmt_r3<vId, vId, vId>;
defm vsubusatd  : fmt_r3<vId, vId, vId>;
defm vminsd     : fmt_r3<vId, vId, vId>;
defm vmaxsd     : fmt_r3<vId, vId, vId>;
defm vminud     : fmt_r3<vId, vId, vId>;
defm vmaxud     : fmt_r3<vId, vId, vId>;
defm vavgsd     : fmt_r3<vId, vId, vId>;
defm vavgud     : fmt_r3<vId, vId, vId>;
defm vcmpeqd    : fmt_r3<vId, vId, vId>;
defm vcmpltsd   : fmt_r3<vId, vId, vId>;
defm vcmpltud   : fmt_r3<vId, vId, vId>;
defm vslld      : fmt_r3<vId, vId, vId>;
defm vsrld      : fmt_r3<vId, vId, vId>;
defm vsrad      : fmt_r3<vId, vId, vId>;
defm vmergehd   : fmt_r3<vId, vId, vId>;
defm vmergeld   : fmt_r3<vId, vId, vId>;
defm vsllid     : fmt_r2_shamt<vId, vId>;
defm vsrlid     : fmt_r2_shamt<vId, vId>;
defm vsraid     : fmt_r2_shamt<vId, vId>;
defm vsrpid     : fmt_r3_shamt<vId, vId, vId>;
defm vslpd      : fmt_r4<vId, vId, vId, vId>;
defm vsrpd      : fmt_r4<vId, vId, vId, vId>;
defm vsplatd    : fmt_r3<vId, vId, llvm_i32_ty>;

///////////////////////////////////////////////////////////////////////////////////////
// pack two vectors into one
///////////////////////////////////////////////////////////////////////////////////////
defm vpkssath : fmt_r3<vIb, vIh, vIh>;
defm vpkssatw : fmt_r3<vIh, vIw, vIw>;
defm vpkssatd : fmt_r3<vIw, vId, vId>;

defm vpkusath : fmt_r3<vIb, vIh, vIh>;
defm vpkusatw : fmt_r3<vIh, vIw, vIw>;
defm vpkusatd : fmt_r3<vIw, vId, vId>;

defm vpkusatsh : fmt_r3<vIb, vIh, vIh>;
defm vpkusatsw : fmt_r3<vIh, vIw, vIw>;
defm vpkusatsd : fmt_r3<vIw, vId, vId>;

defm vpkumodh : fmt_r3<vIb, vIh, vIh>;
defm vpkumodw : fmt_r3<vIh, vIw, vIw>;
defm vpkumodd : fmt_r3<vIw, vId, vId>;

///////////////////////////////////////////////////////////////////////////////////////
// unpack vector half into bigger one
///////////////////////////////////////////////////////////////////////////////////////
defm vupkhsb : fmt_r2<vIh, vIb>;
defm vupkhsh : fmt_r2<vIw, vIh>;
defm vupkhsw : fmt_r2<vId, vIw>;

defm vupklsb : fmt_r2<vIh, vIb>;
defm vupklsh : fmt_r2<vIw, vIh>;
defm vupklsw : fmt_r2<vId, vIw>;

defm vupkhub : fmt_r2<vIh, vIb>;
defm vupkhuh : fmt_r2<vIw, vIh>;
defm vupkhuw : fmt_r2<vId, vIw>;

defm vupklub : fmt_r2<vIh, vIb>;
defm vupkluh : fmt_r2<vIw, vIh>;
defm vupkluw : fmt_r2<vId, vIw>;

///////////////////////////////////////////////////////////////////////////////////////
// int vector misc
///////////////////////////////////////////////////////////////////////////////////////

defm vpermb : fmt_r4<vIb, vIb, vIb, vIb>;

} // postrisc
