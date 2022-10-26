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

class PostriscBuiltin_R2<string dst_type, string src_type, string features = "">
   : PostriscBuiltin<!strconcat(dst_type, " (", src_type, ")"), features> {}

class PostriscBuiltin_R3<string dst_type, string src1_type, string src2_type, string features = "">
   : PostriscBuiltin<!strconcat(dst_type, " (", src1_type, ", ", src2_type, ")"), features> {}

class PostriscBuiltin_R4<string dst_type, string src1_type, string src2_type, string src3_type, string features = "">
   : PostriscBuiltin<!strconcat(dst_type, " (", src1_type, ", ", src2_type, ", ", src3_type, ")"), features> {}

//===----------------------------------------------------------------------===//
// with rounding mode
//===----------------------------------------------------------------------===//
class PostriscBuiltin_R2_RM<string dst_type, string src1_type, string features = "">
   : PostriscBuiltin<!strconcat(dst_type, " (", src1_type, ", _Constant unsigned int)"), features> {}

class PostriscBuiltin_R3_RM<string dst_type, string src1_type, string src2_type, string features = "">
   : PostriscBuiltin<!strconcat(dst_type, " (", src1_type, ", ", src2_type, ", _Constant unsigned int)"), features> {}

class PostriscBuiltin_R4_RM<string dst_type, string src1_type, string src2_type, string src3_type, string features = "">
   : PostriscBuiltin<!strconcat(dst_type, " (", src1_type, ", ", src2_type, ", ", src3_type, ", _Constant unsigned int)"), features> {}

defvar type_ull = "unsigned long long int";
defvar type_i128 = "__int128_t";
defvar type_u128 = "unsigned __int128_t";

defvar type_i32  = "int";
defvar type_u32  = "unsigned int";
defvar type_i64  = "long long int";
defvar type_u64  = "unsigned long long int";

defvar type_f16  = "_Float16";
defvar type_f32  = "float";
defvar type_f64  = "double";
defvar type_f128 = "long double";

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
def aesenc          : PostriscBuiltin_R3<type_v2i64, type_v2i64, type_v2i64>;
def aesenclast      : PostriscBuiltin_R3<type_v2i64, type_v2i64, type_v2i64>;
def aesdec          : PostriscBuiltin_R3<type_v2i64, type_v2i64, type_v2i64>;
def aesdeclast      : PostriscBuiltin_R3<type_v2i64, type_v2i64, type_v2i64>;
def aeskeygenassist : PostriscBuiltin_R3<type_v2i64, type_v2i64, "_Constant unsigned int">;

def aesimc          : PostriscBuiltin_R2<type_v2i64, type_v2i64>;

def clmul_ll : PostriscBuiltin_R3<type_v2i64, type_v2i64, type_v2i64>;
def clmul_hl : PostriscBuiltin_R3<type_v2i64, type_v2i64, type_v2i64>;
def clmul_hh : PostriscBuiltin_R3<type_v2i64, type_v2i64, type_v2i64>;

// debug/monitor registers
def get_mr  : PostriscBuiltin_R2<type_ull, type_ull>;
def get_ibr : PostriscBuiltin_R2<type_ull, type_ull>;
def get_dbr : PostriscBuiltin_R2<type_ull, type_ull>;

def set_mr  : PostriscBuiltin_R3<"void", type_ull, type_ull>;
def set_ibr : PostriscBuiltin_R3<"void", type_ull, type_ull>;
def set_dbr : PostriscBuiltin_R3<"void", type_ull, type_ull>;

def set_dtr: PostriscBuiltin<"void (unsigned long long int, void*, unsigned int)">;
def set_itr: PostriscBuiltin<"void (unsigned long long int, void*, unsigned int)">;

def rscover : PostriscBuiltin<"void()">;
def rsflush : PostriscBuiltin<"void()">;
def rsload : PostriscBuiltin<"void()">;


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
multiclass FP_Common<string Ft>
{
  def sqrt      # NAME : PostriscBuiltin_R2_RM<Ft, Ft>;
  def rsqrt     # NAME : PostriscBuiltin_R2_RM<Ft, Ft>;
  def round     # NAME : PostriscBuiltin_R2_RM<Ft, Ft>;
  def roundnx   # NAME : PostriscBuiltin_R2_RM<Ft, Ft>;

  def abs_diff  # NAME : PostriscBuiltin_R3_RM<Ft, Ft, Ft>;
  def nabs_diff # NAME : PostriscBuiltin_R3_RM<Ft, Ft, Ft>;
  def add       # NAME : PostriscBuiltin_R3_RM<Ft, Ft, Ft>;
  def nadd      # NAME : PostriscBuiltin_R3_RM<Ft, Ft, Ft>;
  def sub       # NAME : PostriscBuiltin_R3_RM<Ft, Ft, Ft>;
  def mul       # NAME : PostriscBuiltin_R3_RM<Ft, Ft, Ft>;
  def nmul      # NAME : PostriscBuiltin_R3_RM<Ft, Ft, Ft>;
  def div       # NAME : PostriscBuiltin_R3_RM<Ft, Ft, Ft>;

  def madd      # NAME : PostriscBuiltin_R4_RM<Ft, Ft, Ft, Ft>;
  def msub      # NAME : PostriscBuiltin_R4_RM<Ft, Ft, Ft, Ft>;
  def nmadd     # NAME : PostriscBuiltin_R4_RM<Ft, Ft, Ft, Ft>;
  def nmsub     # NAME : PostriscBuiltin_R4_RM<Ft, Ft, Ft, Ft>;

  def merge     # NAME : PostriscBuiltin_R4<Ft, Ft, Ft, Ft>;
}

multiclass FP_Scalar<string Ft>
{
  defm NAME : FP_Common<Ft>;

  def cvt # NAME # _i32  : PostriscBuiltin_R2_RM<type_i32, Ft>;
  def cvt # NAME # _u32  : PostriscBuiltin_R2_RM<type_u32, Ft>;

  def cvt # NAME # _i64  : PostriscBuiltin_R2_RM<type_i64, Ft>;
  def cvt # NAME # _u64  : PostriscBuiltin_R2_RM<type_u64, Ft>;

  def cvt # NAME # _i128  : PostriscBuiltin_R2_RM<type_i128, Ft>;
  def cvt # NAME # _u128  : PostriscBuiltin_R2_RM<type_u128, Ft>;

  def cvt_i32 # NAME  : PostriscBuiltin_R2_RM<Ft, type_i32>;
  def cvt_u32 # NAME  : PostriscBuiltin_R2_RM<Ft, type_u32>;

  def cvt_i64 # NAME  : PostriscBuiltin_R2_RM<Ft, type_i64>;
  def cvt_u64 # NAME  : PostriscBuiltin_R2_RM<Ft, type_u64>;

  def cvt_i128 # NAME  : PostriscBuiltin_R2_RM<Ft, type_i128>;
  def cvt_u128 # NAME  : PostriscBuiltin_R2_RM<Ft, type_u128>;

  def minimum  # NAME : PostriscBuiltin_R3<Ft, Ft, Ft>; // FIXME: __builtin_fminimum in future
  def maximum  # NAME : PostriscBuiltin_R3<Ft, Ft, Ft>; // FIXME: __builtin_fmaximum in future
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
  defm NAME : FP_Common<Ft>;

  def dot      # NAME : PostriscBuiltin_R3_RM<Ft, Ft, Ft>;

  def madd_alt  # NAME : PostriscBuiltin_R4_RM<Ft, Ft, Ft, Ft>;
  def msub_alt  # NAME : PostriscBuiltin_R4_RM<Ft, Ft, Ft, Ft>;

  // sign-alternating
  def add_alt   # NAME : PostriscBuiltin_R3_RM<Ft, Ft, Ft>;
  def sub_alt   # NAME : PostriscBuiltin_R3_RM<Ft, Ft, Ft>;

  // horizontal
  def add_horiz # NAME : PostriscBuiltin_R3_RM<Ft, Ft, Ft>;
  def mul_horiz # NAME : PostriscBuiltin_R3_RM<Ft, Ft, Ft>;
  def sub_horiz # NAME : PostriscBuiltin_R3_RM<Ft, Ft, Ft>;

  // compare to vector of 0/1
  def cmp_oeq   # NAME : PostriscBuiltin_R3<Ut, Ft, Ft>;
  def cmp_one   # NAME : PostriscBuiltin_R3<Ut, Ft, Ft>;
  def cmp_olt   # NAME : PostriscBuiltin_R3<Ut, Ft, Ft>;
  def cmp_oge   # NAME : PostriscBuiltin_R3<Ut, Ft, Ft>;
  def cmp_ueq   # NAME : PostriscBuiltin_R3<Ut, Ft, Ft>;
  def cmp_une   # NAME : PostriscBuiltin_R3<Ut, Ft, Ft>;
  def cmp_ult   # NAME : PostriscBuiltin_R3<Ut, Ft, Ft>;
  def cmp_uge   # NAME : PostriscBuiltin_R3<Ut, Ft, Ft>;
  def cmp_o     # NAME : PostriscBuiltin_R3<Ut, Ft, Ft>;
  def cmp_u     # NAME : PostriscBuiltin_R3<Ut, Ft, Ft>;

  def merge_low  # NAME : PostriscBuiltin_R3<Ft, Ft, Ft>;
  def merge_high # NAME : PostriscBuiltin_R3<Ft, Ft, Ft>;

  def unpack_high # NAME : PostriscBuiltin_R2<Ft, Ft>;
  def unpack_low  # NAME : PostriscBuiltin_R2<Ft, Ft>;
}

defm _vf16 : FP_Vector<type_v8f16, type_v8u16>;
defm _vf32 : FP_Vector<type_v4f32, type_v4u32>;
defm _vf64 : FP_Vector<type_v2f64, type_v2u64>;

def cvt_f32_f16  : PostriscBuiltin_R2_RM<type_f16, type_f32>;
def cvt_f64_f16  : PostriscBuiltin_R2_RM<type_f16, type_f64>;
def cvt_f64_f32  : PostriscBuiltin_R2_RM<type_f32, type_f64>;
def cvt_f128_f16 : PostriscBuiltin_R2_RM<type_f16, type_f128>;
def cvt_f128_f32 : PostriscBuiltin_R2_RM<type_f32, type_f128>;
def cvt_f128_f64 : PostriscBuiltin_R2_RM<type_f64, type_f128>;

def cvt_vu16_vf16 : PostriscBuiltin_R2_RM<type_v8f16, type_v8u16>;
def cvt_vu32_vf32 : PostriscBuiltin_R2_RM<type_v4f32, type_v4u32>;
def cvt_vu64_vf64 : PostriscBuiltin_R2_RM<type_v2f64, type_v2u64>;

def cvt_vi16_vf16 : PostriscBuiltin_R2_RM<type_v8f16, type_v8i16>;
def cvt_vi32_vf32 : PostriscBuiltin_R2_RM<type_v4f32, type_v4i32>;
def cvt_vi64_vf64 : PostriscBuiltin_R2_RM<type_v2f64, type_v2i64>;

def cvt_vf16_vu16 : PostriscBuiltin_R2_RM<type_v8u16, type_v8f16>;
def cvt_vf32_vu32 : PostriscBuiltin_R2_RM<type_v4u32, type_v4f32>;
def cvt_vf64_vu64 : PostriscBuiltin_R2_RM<type_v2u64, type_v2f64>;

def cvt_vf16_vi16 : PostriscBuiltin_R2_RM<type_v8i16, type_v8f16>;
def cvt_vf32_vi32 : PostriscBuiltin_R2_RM<type_v4i32, type_v4f32>;
def cvt_vf64_vi64 : PostriscBuiltin_R2_RM<type_v2i64, type_v2f64>;

///////////////////////////////////////////////////////////////////////////////////////
// int vector
///////////////////////////////////////////////////////////////////////////////////////
multiclass MMX_Vector_Signed<string St>
{
  def addo      # NAME : PostriscBuiltin_R3<St, St, St>;
  def subo      # NAME : PostriscBuiltin_R3<St, St, St>;
  def add_sat   # NAME : PostriscBuiltin_R3<St, St, St>;
  def sub_sat   # NAME : PostriscBuiltin_R3<St, St, St>;
  def min       # NAME : PostriscBuiltin_R3<St, St, St>;
  def max       # NAME : PostriscBuiltin_R3<St, St, St>;
  def avg       # NAME : PostriscBuiltin_R3<St, St, St>;
  def cmp_eq    # NAME : PostriscBuiltin_R3<St, St, St>;
  def cmp_lt    # NAME : PostriscBuiltin_R3<St, St, St>;
  def sra       # NAME : PostriscBuiltin_R3<St, St, St>;

  def sra_imm   # NAME : PostriscBuiltin_R3<St, St, "_Constant unsigned int">;
}

defm _vi8  : MMX_Vector_Signed<type_v16i8>;
defm _vi16 : MMX_Vector_Signed<type_v8i16>;
defm _vi32 : MMX_Vector_Signed<type_v4i32>;
defm _vi64 : MMX_Vector_Signed<type_v2i64>;

multiclass MMX_Vector_Unsigned<string Ut>
{
  def add        # NAME : PostriscBuiltin_R3<Ut, Ut, Ut>;
  def sub        # NAME : PostriscBuiltin_R3<Ut, Ut, Ut>;
  def addc       # NAME : PostriscBuiltin_R3<Ut, Ut, Ut>;
  def subb       # NAME : PostriscBuiltin_R3<Ut, Ut, Ut>;
  def add_sat    # NAME : PostriscBuiltin_R3<Ut, Ut, Ut>;
  def sub_sat    # NAME : PostriscBuiltin_R3<Ut, Ut, Ut>;
  def min        # NAME : PostriscBuiltin_R3<Ut, Ut, Ut>;
  def max        # NAME : PostriscBuiltin_R3<Ut, Ut, Ut>;
  def avg        # NAME : PostriscBuiltin_R3<Ut, Ut, Ut>;
  def cmp_lt     # NAME : PostriscBuiltin_R3<Ut, Ut, Ut>;
  def rol        # NAME : PostriscBuiltin_R3<Ut, Ut, Ut>;
  def ror        # NAME : PostriscBuiltin_R3<Ut, Ut, Ut>;
  def sll        # NAME : PostriscBuiltin_R3<Ut, Ut, Ut>;
  def srl        # NAME : PostriscBuiltin_R3<Ut, Ut, Ut>;
  def merge_high # NAME : PostriscBuiltin_R3<Ut, Ut, Ut>;
  def merge_low  # NAME : PostriscBuiltin_R3<Ut, Ut, Ut>;

  def sll_imm    # NAME : PostriscBuiltin_R3<Ut, Ut, "_Constant unsigned int">;
  def srl_imm    # NAME : PostriscBuiltin_R3<Ut, Ut, "_Constant unsigned int">;
}

defm _vu8  : MMX_Vector_Unsigned<type_v16u8>;
defm _vu16 : MMX_Vector_Unsigned<type_v8u16>;
defm _vu32 : MMX_Vector_Unsigned<type_v4u32>;
defm _vu64 : MMX_Vector_Unsigned<type_v2u64>;

///////////////////////////////////////////////////////////////////////////////////////
// int vector mixed
///////////////////////////////////////////////////////////////////////////////////////

def pack_sat_vi16 : PostriscBuiltin_R3<type_v16u8, type_v8u16, type_v8u16>;
def pack_sat_vi32 : PostriscBuiltin_R3<type_v8u16, type_v4u32, type_v4u32>;
def pack_sat_vi64 : PostriscBuiltin_R3<type_v4u32, type_v2u64, type_v2u64>;

def pack_sat_vu16 : PostriscBuiltin_R3<type_v16u8, type_v8u16, type_v8u16>;
def pack_sat_vu32 : PostriscBuiltin_R3<type_v8u16, type_v4u32, type_v4u32>;
def pack_sat_vu64 : PostriscBuiltin_R3<type_v4u32, type_v2u64, type_v2u64>;

def pack_mod_vu16 : PostriscBuiltin_R3<type_v16u8, type_v8u16, type_v8u16>;
def pack_mod_vu32 : PostriscBuiltin_R3<type_v8u16, type_v4u32, type_v4u32>;
def pack_mod_vu64 : PostriscBuiltin_R3<type_v4u32, type_v2u64, type_v2u64>;

def pack_usat_vi16 : PostriscBuiltin_R3<type_v16u8, type_v8u16, type_v8u16>;
def pack_usat_vi32 : PostriscBuiltin_R3<type_v8u16, type_v4u32, type_v4u32>;
def pack_usat_vi64 : PostriscBuiltin_R3<type_v4u32, type_v2u64, type_v2u64>;

def unpack_high_vi8  : PostriscBuiltin_R2<type_v8i16, type_v16i8>;
def unpack_high_vi16 : PostriscBuiltin_R2<type_v4i32, type_v8i16>;
def unpack_high_vi32 : PostriscBuiltin_R2<type_v2i64, type_v4i32>;

def unpack_high_vu8  : PostriscBuiltin_R2<type_v8u16, type_v16u8>;
def unpack_high_vu16 : PostriscBuiltin_R2<type_v4u32, type_v8u16>;
def unpack_high_vu32 : PostriscBuiltin_R2<type_v2u64, type_v4u32>;

def unpack_low_vi8  : PostriscBuiltin_R2<type_v8i16, type_v16i8>;
def unpack_low_vi16 : PostriscBuiltin_R2<type_v4i32, type_v8i16>;
def unpack_low_vi32 : PostriscBuiltin_R2<type_v2i64, type_v4i32>;

def unpack_low_vu8  : PostriscBuiltin_R2<type_v8u16, type_v16u8>;
def unpack_low_vu16 : PostriscBuiltin_R2<type_v4u32, type_v8u16>;
def unpack_low_vu32 : PostriscBuiltin_R2<type_v2u64, type_v4u32>;

///////////////////////////////////////////////////////////////////////////////////////
// int vector misc
///////////////////////////////////////////////////////////////////////////////////////

def perm_vu8 : PostriscBuiltin_R4<type_v16u8, type_v16u8, type_v16u8, type_v16u8>;
