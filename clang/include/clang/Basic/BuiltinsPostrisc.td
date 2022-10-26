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

class PostriscBuiltinUnary <string type, string features = ""> : PostriscBuiltin<!strconcat(type, " (", type,                         ")"), features> {}
class PostriscBuiltinBinary<string type, string features = ""> : PostriscBuiltin<!strconcat(type, " (", type, ", ", type,             ")"), features> {}
class PostriscBuiltinFused <string type, string features = ""> : PostriscBuiltin<!strconcat(type, " (", type, ", ", type, ", ", type, ")"), features> {}

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
def aesenc          : PostriscBuiltinBinary<"_Vector<2, long long int>">;
def aesenclast      : PostriscBuiltinBinary<"_Vector<2, long long int>">;
def aesdec          : PostriscBuiltinBinary<"_Vector<2, long long int>">;
def aesdeclast      : PostriscBuiltinBinary<"_Vector<2, long long int>">;
def aesimc          : PostriscBuiltin<"_Vector<2, long long int>(_Vector<2, long long int>)">;
def aeskeygenassist : PostriscBuiltin<"_Vector<2, long long int>(_Vector<2, long long int>, _Constant unsigned char)">;

// debug/monitor registers
def get_mr  : PostriscBuiltin<"unsigned long long int (unsigned long long int)">;
def set_mr  : PostriscBuiltin<"void (unsigned long long int, unsigned long long int)">;
def get_ibr : PostriscBuiltin<"unsigned long long int (unsigned long long int)">;
def set_ibr : PostriscBuiltin<"void (unsigned long long int, unsigned long long int)">;
def get_dbr : PostriscBuiltin<"unsigned long long int (unsigned long long int)">;
def set_dbr : PostriscBuiltin<"void (unsigned long long int, unsigned long long int)">;

multiclass PostriscBuiltinsSpecialReg<string type>
{
  def get_ # NAME : PostriscBuiltin<!strconcat(type, " ()")>;
  def set_ # NAME : PostriscBuiltin<!strconcat("void (", type, ")")>;
}

defm ip    : PostriscBuiltinsSpecialReg<"unsigned long long int">;
defm eip   : PostriscBuiltinsSpecialReg<"unsigned long long int">;
defm fpcr  : PostriscBuiltinsSpecialReg<"unsigned long long int">;
defm eca   : PostriscBuiltinsSpecialReg<"unsigned long long int">;
defm rsc   : PostriscBuiltinsSpecialReg<"unsigned long long int">;
defm rsp   : PostriscBuiltinsSpecialReg<"unsigned long long int">;
defm bsp   : PostriscBuiltinsSpecialReg<"unsigned long long int">;
defm psr   : PostriscBuiltinsSpecialReg<"unsigned long long int">;
defm reip  : PostriscBuiltinsSpecialReg<"unsigned long long int">;
defm kip   : PostriscBuiltinsSpecialReg<"unsigned long long int">;
defm ksp   : PostriscBuiltinsSpecialReg<"unsigned long long int">;
defm krsp  : PostriscBuiltinsSpecialReg<"unsigned long long int">;
defm peb   : PostriscBuiltinsSpecialReg<"unsigned long long int">;
defm teb   : PostriscBuiltinsSpecialReg<"unsigned long long int">;
defm itc   : PostriscBuiltinsSpecialReg<"unsigned long long int">;
defm itm   : PostriscBuiltinsSpecialReg<"unsigned long long int">;
defm pta   : PostriscBuiltinsSpecialReg<"unsigned long long int">;
defm iva   : PostriscBuiltinsSpecialReg<"unsigned long long int">;
defm iip   : PostriscBuiltinsSpecialReg<"unsigned long long int">;
defm iipa  : PostriscBuiltinsSpecialReg<"unsigned long long int">;
defm ipsr  : PostriscBuiltinsSpecialReg<"unsigned long long int">;
defm cause : PostriscBuiltinsSpecialReg<"unsigned long long int">;
defm ifa   : PostriscBuiltinsSpecialReg<"unsigned long long int">;
defm iib   : PostriscBuiltinsSpecialReg<"unsigned __int128_t">; // IIB reg contains 128-bit instructions bundle
defm irr0  : PostriscBuiltinsSpecialReg<"unsigned long long int">;
defm irr1  : PostriscBuiltinsSpecialReg<"unsigned long long int">;
defm irr2  : PostriscBuiltinsSpecialReg<"unsigned long long int">;
defm irr3  : PostriscBuiltinsSpecialReg<"unsigned long long int">;
defm isr0  : PostriscBuiltinsSpecialReg<"unsigned long long int">;
defm isr1  : PostriscBuiltinsSpecialReg<"unsigned long long int">;
defm isr2  : PostriscBuiltinsSpecialReg<"unsigned long long int">;
defm isr3  : PostriscBuiltinsSpecialReg<"unsigned long long int">;
defm iv    : PostriscBuiltinsSpecialReg<"unsigned long long int">;
defm lid   : PostriscBuiltinsSpecialReg<"unsigned long long int">;
defm tpr   : PostriscBuiltinsSpecialReg<"unsigned long long int">;
defm itcv  : PostriscBuiltinsSpecialReg<"unsigned long long int">;
defm tsv   : PostriscBuiltinsSpecialReg<"unsigned long long int">;
defm pmv   : PostriscBuiltinsSpecialReg<"unsigned long long int">;
defm cmcv  : PostriscBuiltinsSpecialReg<"unsigned long long int">;

def clmul_ll : PostriscBuiltin<"_Vector<2, long long int>(_Vector<2, long long int>, _Vector<2, long long int>)">;
def clmul_hl : PostriscBuiltin<"_Vector<2, long long int>(_Vector<2, long long int>, _Vector<2, long long int>)">;
def clmul_hh : PostriscBuiltin<"_Vector<2, long long int>(_Vector<2, long long int>, _Vector<2, long long int>)">;

///////////////////////////////////////////////////////////////////////////////////////
// fp scalars
///////////////////////////////////////////////////////////////////////////////////////
multiclass FP_Scalar<string type>
{
  def abs       # NAME : PostriscBuiltinUnary<type>;
  def nabs      # NAME : PostriscBuiltinUnary<type>;
  def neg       # NAME : PostriscBuiltinUnary<type>;
  def rsqrt     # NAME : PostriscBuiltinUnary<type>;
  def sqrt      # NAME : PostriscBuiltinUnary<type>;

  def abs_diff  # NAME : PostriscBuiltinBinary<type>;
  def nabs_diff # NAME : PostriscBuiltinBinary<type>;
  def add       # NAME : PostriscBuiltinBinary<type>;
  def nadd      # NAME : PostriscBuiltinBinary<type>;
  def abs_min   # NAME : PostriscBuiltinBinary<type>;
  def abs_max   # NAME : PostriscBuiltinBinary<type>;
  def max       # NAME : PostriscBuiltinBinary<type>;
  def min       # NAME : PostriscBuiltinBinary<type>;
  def maxnum    # NAME : PostriscBuiltinBinary<type>;
  def minnum    # NAME : PostriscBuiltinBinary<type>;
  def div       # NAME : PostriscBuiltinBinary<type>;
  def dot       # NAME : PostriscBuiltinBinary<type>;
  def mul       # NAME : PostriscBuiltinBinary<type>;
  def nmul      # NAME : PostriscBuiltinBinary<type>;
  def sub       # NAME : PostriscBuiltinBinary<type>;

  def madd      # NAME : PostriscBuiltinFused<type>;
  def nmadd     # NAME : PostriscBuiltinFused<type>;
  def msub      # NAME : PostriscBuiltinFused<type>;
  def nmsub     # NAME : PostriscBuiltinFused<type>;
  def merge     # NAME : PostriscBuiltinFused<type>;
}

defm _f16  : FP_Scalar<"_Float16">;
defm _f32  : FP_Scalar<"float">;
defm _f64  : FP_Scalar<"double">;
defm _f128 : FP_Scalar<"long double">;

///////////////////////////////////////////////////////////////////////////////////////
// fp vector
///////////////////////////////////////////////////////////////////////////////////////
multiclass FP_Vector<string type>
{
  def abs       # NAME : PostriscBuiltinUnary<type>;
  def nabs      # NAME : PostriscBuiltinUnary<type>;
  def neg       # NAME : PostriscBuiltinUnary<type>;
  def rsqrt     # NAME : PostriscBuiltinUnary<type>;
  def sqrt      # NAME : PostriscBuiltinUnary<type>;

  def abs_diff  # NAME : PostriscBuiltinBinary<type>;
  def nabs_diff # NAME : PostriscBuiltinBinary<type>;
  def add       # NAME : PostriscBuiltinBinary<type>;
  def nadd      # NAME : PostriscBuiltinBinary<type>;
  def abs_min   # NAME : PostriscBuiltinBinary<type>;
  def abs_max   # NAME : PostriscBuiltinBinary<type>;
  def max       # NAME : PostriscBuiltinBinary<type>;
  def min       # NAME : PostriscBuiltinBinary<type>;
  def maxnum    # NAME : PostriscBuiltinBinary<type>;
  def minnum    # NAME : PostriscBuiltinBinary<type>;
  def div       # NAME : PostriscBuiltinBinary<type>;
  def dot       # NAME : PostriscBuiltinBinary<type>;
  def mul       # NAME : PostriscBuiltinBinary<type>;
  def nmul      # NAME : PostriscBuiltinBinary<type>;
  def sub       # NAME : PostriscBuiltinBinary<type>;

  def madd      # NAME : PostriscBuiltinFused<type>;
  def nmadd     # NAME : PostriscBuiltinFused<type>;
  def msub      # NAME : PostriscBuiltinFused<type>;
  def nmsub     # NAME : PostriscBuiltinFused<type>;
  def merge     # NAME : PostriscBuiltinFused<type>;
  def madd_alt  # NAME : PostriscBuiltinFused<type>;
  def msub_alt  # NAME : PostriscBuiltinFused<type>;

  // sign-alternating
  def add_alt   # NAME : PostriscBuiltinBinary<type>;
  def sub_alt   # NAME : PostriscBuiltinBinary<type>;

  // horizontal
  def add_horiz # NAME : PostriscBuiltinBinary<type>;
  def mul_horiz # NAME : PostriscBuiltinBinary<type>;
  def sub_horiz # NAME : PostriscBuiltinBinary<type>;
}

defm _vf16 : FP_Vector<"_Vector<8, _Float16>">;
defm _vf32 : FP_Vector<"_Vector<4, float>">;
defm _vf64 : FP_Vector<"_Vector<2, double>">;

///////////////////////////////////////////////////////////////////////////////////////
// int vector
///////////////////////////////////////////////////////////////////////////////////////
multiclass MMX_Vector_Signed<string Ty>
{
  def addo      # NAME : PostriscBuiltinBinary<Ty>;
  def subo      # NAME : PostriscBuiltinBinary<Ty>;
  def add_sat   # NAME : PostriscBuiltinBinary<Ty>;
  def sub_sat   # NAME : PostriscBuiltinBinary<Ty>;
  def avg       # NAME : PostriscBuiltinBinary<Ty>;
  def cmp_eq    # NAME : PostriscBuiltinBinary<Ty>;
  def cmp_lt    # NAME : PostriscBuiltinBinary<Ty>;
  def max       # NAME : PostriscBuiltinBinary<Ty>;
  def min       # NAME : PostriscBuiltinBinary<Ty>;
  def sra       # NAME : PostriscBuiltinBinary<Ty>;
}

defm _vi8  : MMX_Vector_Signed<"_Vector<16, signed char>">;
defm _vi16 : MMX_Vector_Signed<"_Vector<8,  short>">;
defm _vi32 : MMX_Vector_Signed<"_Vector<4,  int>">;
defm _vi64 : MMX_Vector_Signed<"_Vector<2,  long long int>">;

multiclass MMX_Vector_Unsigned<string Ty>
{
  def add        # NAME : PostriscBuiltinBinary<Ty>;
  def sub        # NAME : PostriscBuiltinBinary<Ty>;
  def addc       # NAME : PostriscBuiltinBinary<Ty>;
  def subb       # NAME : PostriscBuiltinBinary<Ty>;
  def add_sat    # NAME : PostriscBuiltinBinary<Ty>;
  def sub_sat    # NAME : PostriscBuiltinBinary<Ty>;
  def avg        # NAME : PostriscBuiltinBinary<Ty>;
  def cmp_lt     # NAME : PostriscBuiltinBinary<Ty>;
  def max        # NAME : PostriscBuiltinBinary<Ty>;
  def min        # NAME : PostriscBuiltinBinary<Ty>;
  def rol        # NAME : PostriscBuiltinBinary<Ty>;
  def ror        # NAME : PostriscBuiltinBinary<Ty>;
  def sll        # NAME : PostriscBuiltinBinary<Ty>;
  def srl        # NAME : PostriscBuiltinBinary<Ty>;
  def merge_high # NAME : PostriscBuiltinBinary<Ty>;
  def merge_low  # NAME : PostriscBuiltinBinary<Ty>;
}

defm _vu8  : MMX_Vector_Unsigned<"_Vector<16, unsigned char>">;
defm _vu16 : MMX_Vector_Unsigned<"_Vector<8,  unsigned short>">;
defm _vu32 : MMX_Vector_Unsigned<"_Vector<4,  unsigned int>">;
defm _vu64 : MMX_Vector_Unsigned<"_Vector<2,  unsigned long long int>">;

///////////////////////////////////////////////////////////////////////////////////////
// int vector mixed
///////////////////////////////////////////////////////////////////////////////////////

def pack_sat_vi16 : PostriscBuiltin<"_Vector<16, unsigned char>(_Vector<8, unsigned short>, _Vector<8, unsigned short>)">;
def pack_sat_vi32 : PostriscBuiltin<"_Vector<8, unsigned short>(_Vector<4, unsigned int>, _Vector<4, unsigned int>)">;
def pack_sat_vi64 : PostriscBuiltin<"_Vector<4, unsigned int>(_Vector<2, unsigned long long int>, _Vector<2, unsigned long long int>)">;

def pack_sat_vu16 : PostriscBuiltin<"_Vector<16, unsigned char>(_Vector<8, unsigned short>, _Vector<8, unsigned short>)">;
def pack_sat_vu32 : PostriscBuiltin<"_Vector<8, unsigned short>(_Vector<4, unsigned int>, _Vector<4, unsigned int>)">;
def pack_sat_vu64 : PostriscBuiltin<"_Vector<4, unsigned int>(_Vector<2, unsigned long long int>, _Vector<2, unsigned long long int>)">;

def pack_mod_vu16 : PostriscBuiltin<"_Vector<16, unsigned char>(_Vector<8, unsigned short>, _Vector<8, unsigned short>)">;
def pack_mod_vu32 : PostriscBuiltin<"_Vector<8, unsigned short>(_Vector<4, unsigned int>, _Vector<4, unsigned int>)">;
def pack_mod_vu64 : PostriscBuiltin<"_Vector<4, unsigned int>(_Vector<2, unsigned long long int>, _Vector<2, unsigned long long int>)">;

def pack_usat_vi16 : PostriscBuiltin<"_Vector<16, unsigned char>(_Vector<8, unsigned short>, _Vector<8, unsigned short>)">;
def pack_usat_vi32 : PostriscBuiltin<"_Vector<8, unsigned short>(_Vector<4, unsigned int>, _Vector<4, unsigned int>)">;
def pack_usat_vi64 : PostriscBuiltin<"_Vector<4, unsigned int>(_Vector<2, unsigned long long int>, _Vector<2, unsigned long long int>)">;

def unpack_high_vi8  : PostriscBuiltin<"_Vector<8, unsigned short>(_Vector<16, signed char>)">;
def unpack_high_vi16 : PostriscBuiltin<"_Vector<4, unsigned int>(_Vector<8, short>)">;
def unpack_high_vi32 : PostriscBuiltin<"_Vector<2, unsigned long long int>(_Vector<4, int>)">;

def unpack_low_vi8  : PostriscBuiltin<"_Vector<8, unsigned short>(_Vector<16, signed char>)">;
def unpack_low_vi16 : PostriscBuiltin<"_Vector<4, unsigned int>(_Vector<8, short>)">;
def unpack_low_vi32 : PostriscBuiltin<"_Vector<2, unsigned long long int>(_Vector<4, int>)">;

def unpack_high_vu8  : PostriscBuiltin<"_Vector<8, unsigned short>(_Vector<16, unsigned char>)">;
def unpack_high_vu16 : PostriscBuiltin<"_Vector<4, unsigned int>(_Vector<8, unsigned short>)">;
def unpack_high_vu32 : PostriscBuiltin<"_Vector<2, unsigned long long int>(_Vector<4, unsigned int>)">;

def unpack_low_vu8  : PostriscBuiltin<"_Vector<8, unsigned short>(_Vector<16, unsigned char>)">;
def unpack_low_vu16 : PostriscBuiltin<"_Vector<4, unsigned int>(_Vector<8, unsigned short>)">;
def unpack_low_vu32 : PostriscBuiltin<"_Vector<2, unsigned long long int>(_Vector<4, unsigned int>)">;
