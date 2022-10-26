//===--- BuiltinsPostrisc.td - Postrisc Builtin function defs ---*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file defines the Postrisc-specific builtin function database.
//
//===----------------------------------------------------------------------===//

include "clang/Basic/BuiltinsBase.td"

class PostriscBuiltin<string prototype, string features = ""> : TargetBuiltin {
  let Spellings = ["__builtin_postrisc_" # NAME];
  let Prototype = prototype;
  let Features = features;
}

class PostriscBuiltinUnary <string dst_type, string src_type, string features = "">
   : PostriscBuiltin<!strconcat(dst_type, " (", src_type, ")"), features> {}

class PostriscBuiltinBinary<string dst_type, string src1_type, string src2_type, string features = "">
   : PostriscBuiltin<!strconcat(dst_type, " (", src1_type, ", ", src2_type, ")"), features> {}

class PostriscBuiltinFused <string type, string features = "">
   : PostriscBuiltin<!strconcat(type, " (", type, ", ", type, ", ", type, ")"), features> {}

defvar type_ull = "unsigned long long int";
defvar type_u128 = "unsigned __int128_t";

defvar type_v8f16 = "_Vector<8, _Float16>";
defvar type_v4f32 = "_Vector<4, float>";
defvar type_v2f64 = "_Vector<2, double>";

defvar type_v16u8 = "_Vector<16, unsigned char>";
defvar type_v16i8 = "_Vector<16, signed char>";
defvar type_v8u16 = "_Vector<8, unsigned short>";
defvar type_v8i16 = "_Vector<8, short>";
defvar type_v4u32 = "_Vector<4, unsigned int>";
defvar type_v4i32 = "_Vector<4, int>";
defvar type_v2u64 = "_Vector<2, unsigned long int>";
defvar type_v2i64 = "_Vector<2, long int>";


// workaround for tablegen keywords like `int`
class PostriscBuiltinRawName<string prototype, string features = ""> : TargetBuiltin {
  let Spellings = [NAME];
  let Prototype = prototype;
  let Features = features;
}
def __builtin_postrisc_int : PostriscBuiltinRawName<"void(unsigned long long int)">;

let Attributes = [NoThrow] in {
  def cpuid : PostriscBuiltin<"unsigned long long int (unsigned long long int)">;
}

def syscall : PostriscBuiltin<"void()">;
def sysret : PostriscBuiltin<"void()">;
def rfi : PostriscBuiltin< "void()">;

let Attributes = [NoReturn] in {
  def halt : PostriscBuiltin<"void()">;
}

def undef : PostriscBuiltin<"void()">;
def nul_never : PostriscBuiltin<"void(_Constant unsigned long long int)">; // special trick to test branch instructions (never nullified)

def nop   : PostriscBuiltin<"void(_Constant unsigned long long int)">;
def nop_l : PostriscBuiltin<"void(_Constant unsigned long long int)">;
def tpa   : PostriscBuiltin<"unsigned long long int(void*, unsigned long long int)">;

def random_n : PostriscBuiltin<"unsigned long long int(unsigned long long int)">; // random(generator)
def random : PostriscBuiltin<"unsigned long long int()">; // random()

def dcbf : PostriscBuiltin<"void (void*)">;
def dcbi : PostriscBuiltin<"void (void*)">;
def dcbt : PostriscBuiltin<"void (void*)">;
def icbi : PostriscBuiltin<"void (void*)">;

def eh_throw : PostriscBuiltin<"void (void*)">;

// TODO: may be replaced by global __builtin_set_thread_pointer in the future
def set_thread_pointer : PostriscBuiltin<"void(void*)">;

def stack_pointer : PostriscBuiltin<"unsigned long long int ()">;

def tlb_purge : PostriscBuiltin<"void (void*, void*, unsigned int)">;

// crc32new = crc32c(crc32old, uint128data, sizetlen)
def crc32c : PostriscBuiltin<"unsigned int (unsigned int, unsigned __int128_t, unsigned long long int)">;

// AES
def aesenc          : PostriscBuiltinBinary<type_v2i64, type_v2i64, type_v2i64>;
def aesenclast      : PostriscBuiltinBinary<type_v2i64, type_v2i64, type_v2i64>;
def aesdec          : PostriscBuiltinBinary<type_v2i64, type_v2i64, type_v2i64>;
def aesdeclast      : PostriscBuiltinBinary<type_v2i64, type_v2i64, type_v2i64>;
def aeskeygenassist : PostriscBuiltinBinary<type_v2i64, type_v2i64, "_Constant unsigned char">;

def aesimc          : PostriscBuiltinUnary<type_v2i64, type_v2i64>;

def clmul_ll : PostriscBuiltinBinary<type_v2i64, type_v2i64, type_v2i64>;
def clmul_hl : PostriscBuiltinBinary<type_v2i64, type_v2i64, type_v2i64>;
def clmul_hh : PostriscBuiltinBinary<type_v2i64, type_v2i64, type_v2i64>;

// debug/monitor registers
def get_mr  : PostriscBuiltinUnary<type_ull, type_ull>;
def get_ibr : PostriscBuiltinUnary<type_ull, type_ull>;
def get_dbr : PostriscBuiltinUnary<type_ull, type_ull>;

def set_mr  : PostriscBuiltinBinary<"void", type_ull, type_ull>;
def set_ibr : PostriscBuiltinBinary<"void", type_ull, type_ull>;
def set_dbr : PostriscBuiltinBinary<"void", type_ull, type_ull>;

multiclass PostriscBuiltinsSpecialReg<string type>
{
  def get_ # NAME : PostriscBuiltin<!strconcat(type, " ()")>;
  def set_ # NAME : PostriscBuiltin<!strconcat("void (", type, ")")>;
}

defm ip    : PostriscBuiltinsSpecialReg<type_ull>;
defm eip   : PostriscBuiltinsSpecialReg<type_ull>;
defm fpcr  : PostriscBuiltinsSpecialReg<type_ull>;
defm eca   : PostriscBuiltinsSpecialReg<type_ull>;
defm rsc   : PostriscBuiltinsSpecialReg<type_ull>;
defm rsp   : PostriscBuiltinsSpecialReg<type_ull>;
defm bsp   : PostriscBuiltinsSpecialReg<type_ull>;
defm psr   : PostriscBuiltinsSpecialReg<type_ull>;
defm reip  : PostriscBuiltinsSpecialReg<type_ull>;
defm kip   : PostriscBuiltinsSpecialReg<type_ull>;
defm ksp   : PostriscBuiltinsSpecialReg<type_ull>;
defm krsp  : PostriscBuiltinsSpecialReg<type_ull>;
defm peb   : PostriscBuiltinsSpecialReg<type_ull>;
defm teb   : PostriscBuiltinsSpecialReg<type_ull>;
defm itc   : PostriscBuiltinsSpecialReg<type_ull>;
defm itm   : PostriscBuiltinsSpecialReg<type_ull>;
defm pta   : PostriscBuiltinsSpecialReg<type_ull>;
defm iva   : PostriscBuiltinsSpecialReg<type_ull>;
defm iip   : PostriscBuiltinsSpecialReg<type_ull>;
defm iipa  : PostriscBuiltinsSpecialReg<type_ull>;
defm ipsr  : PostriscBuiltinsSpecialReg<type_ull>;
defm cause : PostriscBuiltinsSpecialReg<type_ull>;
defm ifa   : PostriscBuiltinsSpecialReg<type_ull>;
defm iib   : PostriscBuiltinsSpecialReg<type_u128>; // IIB reg contains 128-bit instructions bundle
defm irr0  : PostriscBuiltinsSpecialReg<type_ull>;
defm irr1  : PostriscBuiltinsSpecialReg<type_ull>;
defm irr2  : PostriscBuiltinsSpecialReg<type_ull>;
defm irr3  : PostriscBuiltinsSpecialReg<type_ull>;
defm isr0  : PostriscBuiltinsSpecialReg<type_ull>;
defm isr1  : PostriscBuiltinsSpecialReg<type_ull>;
defm isr2  : PostriscBuiltinsSpecialReg<type_ull>;
defm isr3  : PostriscBuiltinsSpecialReg<type_ull>;
defm iv    : PostriscBuiltinsSpecialReg<type_ull>;
defm lid   : PostriscBuiltinsSpecialReg<type_ull>;
defm tpr   : PostriscBuiltinsSpecialReg<type_ull>;
defm itcv  : PostriscBuiltinsSpecialReg<type_ull>;
defm tsv   : PostriscBuiltinsSpecialReg<type_ull>;
defm pmv   : PostriscBuiltinsSpecialReg<type_ull>;
defm cmcv  : PostriscBuiltinsSpecialReg<type_ull>;

///////////////////////////////////////////////////////////////////////////////////////
// fp scalars
///////////////////////////////////////////////////////////////////////////////////////
multiclass FP_Scalar<string Ft>
{
  def abs       # NAME : PostriscBuiltinUnary<Ft, Ft>;
  def nabs      # NAME : PostriscBuiltinUnary<Ft, Ft>;
  def neg       # NAME : PostriscBuiltinUnary<Ft, Ft>;
  def rsqrt     # NAME : PostriscBuiltinUnary<Ft, Ft>;
  def sqrt      # NAME : PostriscBuiltinUnary<Ft, Ft>;

  def abs_diff  # NAME : PostriscBuiltinBinary<Ft, Ft, Ft>;
  def nabs_diff # NAME : PostriscBuiltinBinary<Ft, Ft, Ft>;
  def add       # NAME : PostriscBuiltinBinary<Ft, Ft, Ft>;
  def nadd      # NAME : PostriscBuiltinBinary<Ft, Ft, Ft>;
  def abs_min   # NAME : PostriscBuiltinBinary<Ft, Ft, Ft>;
  def abs_max   # NAME : PostriscBuiltinBinary<Ft, Ft, Ft>;
  def max       # NAME : PostriscBuiltinBinary<Ft, Ft, Ft>;
  def min       # NAME : PostriscBuiltinBinary<Ft, Ft, Ft>;
  def maxnum    # NAME : PostriscBuiltinBinary<Ft, Ft, Ft>;
  def minnum    # NAME : PostriscBuiltinBinary<Ft, Ft, Ft>;
  def div       # NAME : PostriscBuiltinBinary<Ft, Ft, Ft>;
  def dot       # NAME : PostriscBuiltinBinary<Ft, Ft, Ft>;
  def mul       # NAME : PostriscBuiltinBinary<Ft, Ft, Ft>;
  def nmul      # NAME : PostriscBuiltinBinary<Ft, Ft, Ft>;
  def sub       # NAME : PostriscBuiltinBinary<Ft, Ft, Ft>;

  def madd      # NAME : PostriscBuiltinFused<Ft>;
  def nmadd     # NAME : PostriscBuiltinFused<Ft>;
  def msub      # NAME : PostriscBuiltinFused<Ft>;
  def nmsub     # NAME : PostriscBuiltinFused<Ft>;
  def merge     # NAME : PostriscBuiltinFused<Ft>;
}

defm _f16  : FP_Scalar<"_Float16">;
defm _f32  : FP_Scalar<"float">;
defm _f64  : FP_Scalar<"double">;
defm _f128 : FP_Scalar<"long double">;

///////////////////////////////////////////////////////////////////////////////////////
// fp vector
///////////////////////////////////////////////////////////////////////////////////////
multiclass FP_Vector<string Ft, string Ut>
{
  def abs       # NAME : PostriscBuiltinUnary<Ft, Ft>;
  def nabs      # NAME : PostriscBuiltinUnary<Ft, Ft>;
  def neg       # NAME : PostriscBuiltinUnary<Ft, Ft>;
  def rsqrt     # NAME : PostriscBuiltinUnary<Ft, Ft>;
  def sqrt      # NAME : PostriscBuiltinUnary<Ft, Ft>;

  def ceil      # NAME : PostriscBuiltinUnary<Ft, Ft>;
  def floor     # NAME : PostriscBuiltinUnary<Ft, Ft>;
  def trunc     # NAME : PostriscBuiltinUnary<Ft, Ft>;
  def rint      # NAME : PostriscBuiltinUnary<Ft, Ft>;
  def nearbyint # NAME : PostriscBuiltinUnary<Ft, Ft>;
  def round     # NAME : PostriscBuiltinUnary<Ft, Ft>;
  def roundeven # NAME : PostriscBuiltinUnary<Ft, Ft>;

  def abs_diff  # NAME : PostriscBuiltinBinary<Ft, Ft, Ft>;
  def nabs_diff # NAME : PostriscBuiltinBinary<Ft, Ft, Ft>;
  def add       # NAME : PostriscBuiltinBinary<Ft, Ft, Ft>;
  def nadd      # NAME : PostriscBuiltinBinary<Ft, Ft, Ft>;
  def abs_min   # NAME : PostriscBuiltinBinary<Ft, Ft, Ft>;
  def abs_max   # NAME : PostriscBuiltinBinary<Ft, Ft, Ft>;
  def max       # NAME : PostriscBuiltinBinary<Ft, Ft, Ft>;
  def min       # NAME : PostriscBuiltinBinary<Ft, Ft, Ft>;
  def maxnum    # NAME : PostriscBuiltinBinary<Ft, Ft, Ft>;
  def minnum    # NAME : PostriscBuiltinBinary<Ft, Ft, Ft>;
  def div       # NAME : PostriscBuiltinBinary<Ft, Ft, Ft>;
  def dot       # NAME : PostriscBuiltinBinary<Ft, Ft, Ft>;
  def mul       # NAME : PostriscBuiltinBinary<Ft, Ft, Ft>;
  def nmul      # NAME : PostriscBuiltinBinary<Ft, Ft, Ft>;
  def sub       # NAME : PostriscBuiltinBinary<Ft, Ft, Ft>;

  def merge_low # NAME : PostriscBuiltinBinary<Ft, Ft, Ft>;
  def merge_high# NAME : PostriscBuiltinBinary<Ft, Ft, Ft>;

  def madd      # NAME : PostriscBuiltinFused<Ft>;
  def nmadd     # NAME : PostriscBuiltinFused<Ft>;
  def msub      # NAME : PostriscBuiltinFused<Ft>;
  def nmsub     # NAME : PostriscBuiltinFused<Ft>;
  def merge     # NAME : PostriscBuiltinFused<Ft>;
  def madd_alt  # NAME : PostriscBuiltinFused<Ft>;
  def msub_alt  # NAME : PostriscBuiltinFused<Ft>;

  // sign-alternating
  def add_alt   # NAME : PostriscBuiltinBinary<Ft, Ft, Ft>;
  def sub_alt   # NAME : PostriscBuiltinBinary<Ft, Ft, Ft>;

  // horizontal
  def add_horiz # NAME : PostriscBuiltinBinary<Ft, Ft, Ft>;
  def mul_horiz # NAME : PostriscBuiltinBinary<Ft, Ft, Ft>;
  def sub_horiz # NAME : PostriscBuiltinBinary<Ft, Ft, Ft>;

  // compare to vector of 0/1
  def cmp_oeq   # NAME : PostriscBuiltinBinary<Ut, Ft, Ft>;
  def cmp_one   # NAME : PostriscBuiltinBinary<Ut, Ft, Ft>;
  def cmp_olt   # NAME : PostriscBuiltinBinary<Ut, Ft, Ft>;
  def cmp_oge   # NAME : PostriscBuiltinBinary<Ut, Ft, Ft>;
  def cmp_ueq   # NAME : PostriscBuiltinBinary<Ut, Ft, Ft>;
  def cmp_une   # NAME : PostriscBuiltinBinary<Ut, Ft, Ft>;
  def cmp_ult   # NAME : PostriscBuiltinBinary<Ut, Ft, Ft>;
  def cmp_uge   # NAME : PostriscBuiltinBinary<Ut, Ft, Ft>;
  def cmp_o     # NAME : PostriscBuiltinBinary<Ut, Ft, Ft>;
  def cmp_u     # NAME : PostriscBuiltinBinary<Ut, Ft, Ft>;
}

defm _vf16 : FP_Vector<type_v8f16, type_v8u16>;
defm _vf32 : FP_Vector<type_v4f32, type_v4u32>;
defm _vf64 : FP_Vector<type_v2f64, type_v2u64>;

def trunc_vf16_vi16 : PostriscBuiltinUnary<type_v8i16, type_v8f16>;
def trunc_vf32_vi32 : PostriscBuiltinUnary<type_v4i32, type_v4f32>;
def trunc_vf64_vi64 : PostriscBuiltinUnary<type_v2i64, type_v2f64>;

def trunc_vf16_vu16 : PostriscBuiltinUnary<type_v8u16, type_v8f16>;
def trunc_vf32_vu32 : PostriscBuiltinUnary<type_v4u32, type_v4f32>;
def trunc_vf64_vu64 : PostriscBuiltinUnary<type_v2u64, type_v2f64>;

def cvt_vu16_vf16 : PostriscBuiltinUnary<type_v8f16, type_v8u16>;
def cvt_vu32_vf32 : PostriscBuiltinUnary<type_v4f32, type_v4u32>;
def cvt_vu64_vf64 : PostriscBuiltinUnary<type_v2f64, type_v2u64>;

def cvt_vi16_vf16 : PostriscBuiltinUnary<type_v8f16, type_v8i16>;
def cvt_vi32_vf32 : PostriscBuiltinUnary<type_v4f32, type_v4i32>;
def cvt_vi64_vf64 : PostriscBuiltinUnary<type_v2f64, type_v2i64>;

///////////////////////////////////////////////////////////////////////////////////////
// int vector
///////////////////////////////////////////////////////////////////////////////////////
multiclass MMX_Vector_Signed<string Ty>
{
  def addo      # NAME : PostriscBuiltinBinary<Ty, Ty, Ty>;
  def subo      # NAME : PostriscBuiltinBinary<Ty, Ty, Ty>;
  def add_sat   # NAME : PostriscBuiltinBinary<Ty, Ty, Ty>;
  def sub_sat   # NAME : PostriscBuiltinBinary<Ty, Ty, Ty>;
  def avg       # NAME : PostriscBuiltinBinary<Ty, Ty, Ty>;
  def cmp_eq    # NAME : PostriscBuiltinBinary<Ty, Ty, Ty>;
  def cmp_lt    # NAME : PostriscBuiltinBinary<Ty, Ty, Ty>;
  def max       # NAME : PostriscBuiltinBinary<Ty, Ty, Ty>;
  def min       # NAME : PostriscBuiltinBinary<Ty, Ty, Ty>;
  def sra       # NAME : PostriscBuiltinBinary<Ty, Ty, Ty>;
}

defm _vi8  : MMX_Vector_Signed<type_v16i8>;
defm _vi16 : MMX_Vector_Signed<type_v8i16>;
defm _vi32 : MMX_Vector_Signed<type_v4i32>;
defm _vi64 : MMX_Vector_Signed<type_v2i64>;

multiclass MMX_Vector_Unsigned<string Ty>
{
  def add        # NAME : PostriscBuiltinBinary<Ty, Ty, Ty>;
  def sub        # NAME : PostriscBuiltinBinary<Ty, Ty, Ty>;
  def addc       # NAME : PostriscBuiltinBinary<Ty, Ty, Ty>;
  def subb       # NAME : PostriscBuiltinBinary<Ty, Ty, Ty>;
  def add_sat    # NAME : PostriscBuiltinBinary<Ty, Ty, Ty>;
  def sub_sat    # NAME : PostriscBuiltinBinary<Ty, Ty, Ty>;
  def avg        # NAME : PostriscBuiltinBinary<Ty, Ty, Ty>;
  def cmp_lt     # NAME : PostriscBuiltinBinary<Ty, Ty, Ty>;
  def max        # NAME : PostriscBuiltinBinary<Ty, Ty, Ty>;
  def min        # NAME : PostriscBuiltinBinary<Ty, Ty, Ty>;
  def rol        # NAME : PostriscBuiltinBinary<Ty, Ty, Ty>;
  def ror        # NAME : PostriscBuiltinBinary<Ty, Ty, Ty>;
  def sll        # NAME : PostriscBuiltinBinary<Ty, Ty, Ty>;
  def srl        # NAME : PostriscBuiltinBinary<Ty, Ty, Ty>;
  def merge_high # NAME : PostriscBuiltinBinary<Ty, Ty, Ty>;
  def merge_low  # NAME : PostriscBuiltinBinary<Ty, Ty, Ty>;
}

defm _vu8  : MMX_Vector_Unsigned<type_v16u8>;
defm _vu16 : MMX_Vector_Unsigned<type_v8u16>;
defm _vu32 : MMX_Vector_Unsigned<type_v4u32>;
defm _vu64 : MMX_Vector_Unsigned<type_v2u64>;

///////////////////////////////////////////////////////////////////////////////////////
// int vector mixed
///////////////////////////////////////////////////////////////////////////////////////

def pack_sat_vi16 : PostriscBuiltinBinary<type_v16u8, type_v8u16, type_v8u16>;
def pack_sat_vi32 : PostriscBuiltinBinary<type_v8u16, type_v4u32, type_v4u32>;
def pack_sat_vi64 : PostriscBuiltinBinary<type_v4u32, type_v2u64, type_v2u64>;

def pack_sat_vu16 : PostriscBuiltinBinary<type_v16u8, type_v8u16, type_v8u16>;
def pack_sat_vu32 : PostriscBuiltinBinary<type_v8u16, type_v4u32, type_v4u32>;
def pack_sat_vu64 : PostriscBuiltinBinary<type_v4u32, type_v2u64, type_v2u64>;

def pack_mod_vu16 : PostriscBuiltinBinary<type_v16u8, type_v8u16, type_v8u16>;
def pack_mod_vu32 : PostriscBuiltinBinary<type_v8u16, type_v4u32, type_v4u32>;
def pack_mod_vu64 : PostriscBuiltinBinary<type_v4u32, type_v2u64, type_v2u64>;

def pack_usat_vi16 : PostriscBuiltinBinary<type_v16u8, type_v8u16, type_v8u16>;
def pack_usat_vi32 : PostriscBuiltinBinary<type_v8u16, type_v4u32, type_v4u32>;
def pack_usat_vi64 : PostriscBuiltinBinary<type_v4u32, type_v2u64, type_v2u64>;

def unpack_high_vi8  : PostriscBuiltinUnary<type_v8i16, type_v16i8>;
def unpack_high_vi16 : PostriscBuiltinUnary<type_v4i32, type_v8i16>;
def unpack_high_vi32 : PostriscBuiltinUnary<type_v2i64, type_v4i32>;

def unpack_high_vu8  : PostriscBuiltinUnary<type_v8u16, type_v16u8>;
def unpack_high_vu16 : PostriscBuiltinUnary<type_v4u32, type_v8u16>;
def unpack_high_vu32 : PostriscBuiltinUnary<type_v2u64, type_v4u32>;

def unpack_low_vi8  : PostriscBuiltinUnary<type_v8i16, type_v16i8>;
def unpack_low_vi16 : PostriscBuiltinUnary<type_v4i32, type_v8i16>;
def unpack_low_vi32 : PostriscBuiltinUnary<type_v2i64, type_v4i32>;

def unpack_low_vu8  : PostriscBuiltinUnary<type_v8u16, type_v16u8>;
def unpack_low_vu16 : PostriscBuiltinUnary<type_v4u32, type_v8u16>;
def unpack_low_vu32 : PostriscBuiltinUnary<type_v2u64, type_v4u32>;

///////////////////////////////////////////////////////////////////////////////////////
// int vector misc
///////////////////////////////////////////////////////////////////////////////////////

def perm_vu8 : PostriscBuiltinFused<type_v16u8>;
