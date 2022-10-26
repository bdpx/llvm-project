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

//===----------------------------------------------------------------------===//
// short type names
//===----------------------------------------------------------------------===//
defvar Fh = "_Float16";
defvar Fw = "float";
defvar Fd = "double";
defvar Fq = "long double";
defvar u32imm =  "_Constant unsigned int";

defvar vFh = "_Vector<8, _Float16>";
defvar vFw = "_Vector<4, float>";
defvar vFd = "_Vector<2, double>";

defvar vUb = "_Vector<16, unsigned char>";
defvar vIb = "_Vector<16, signed char>";
defvar vUh = "_Vector<8, unsigned short>";
defvar vIh = "_Vector<8, short>";
defvar vUw = "_Vector<4, unsigned int>";
defvar vIw = "_Vector<4, int>";
defvar vUd = "_Vector<2, unsigned long int>";
defvar vId = "_Vector<2, long int>";

defvar type_ull = "unsigned long long int";
defvar type_i128 = "__int128_t";
defvar type_u128 = "unsigned __int128_t";

defvar type_i32  = "int";
defvar type_u32  = "unsigned int";
defvar type_i64  = "long long int";
defvar type_u64  = "unsigned long long int";


class PostriscBuiltin<string prototype, string features = ""> : TargetBuiltin {
  let Spellings = ["__builtin_postrisc_" # NAME];
  let Prototype = prototype;
  let Features = features;
}

class fmt_r2<string dst_type, string src_type, string features = "">
   : PostriscBuiltin<!strconcat(dst_type, " (", src_type, ")"), features> {}

class fmt_r3<string dst_type, string src1_type, string src2_type, string features = "">
   : PostriscBuiltin<!strconcat(dst_type, " (", src1_type, ", ", src2_type, ")"), features> {}

class fmt_r4<string dst_type, string src1_type, string src2_type, string src3_type, string features = "">
   : PostriscBuiltin<!strconcat(dst_type, " (", src1_type, ", ", src2_type, ", ", src3_type, ")"), features> {}

//===----------------------------------------------------------------------===//
// with rounding mode
//===----------------------------------------------------------------------===//
class fmt_r2rm<string dst_type, string src1_type, string features = "">
   : PostriscBuiltin<!strconcat(dst_type, " (", src1_type, ", ", u32imm, ")"), features> {}

class fmt_r3rm<string dst_type, string src1_type, string src2_type, string features = "">
   : PostriscBuiltin<!strconcat(dst_type, " (", src1_type, ", ", src2_type, ", ", u32imm, ")"), features> {}

class fmt_r4rm<string dst_type, string src1_type, string src2_type, string src3_type, string features = "">
   : PostriscBuiltin<!strconcat(dst_type, " (", src1_type, ", ", src2_type, ", ", src3_type, ", ", u32imm, ")"), features> {}

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

def bit_gather  : fmt_r3<type_ull, type_ull, type_ull>;
def bit_scatter : fmt_r3<type_ull, type_ull, type_ull>;

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

// crc32new = crc32cX(crc32old, data)
def crc32cb : PostriscBuiltin<"unsigned int (unsigned int, unsigned int)">; // FIXME: char
def crc32ch : PostriscBuiltin<"unsigned int (unsigned int, unsigned int)">; // FIXME: short
def crc32cw : PostriscBuiltin<"unsigned int (unsigned int, unsigned int)">;
def crc32cd : PostriscBuiltin<"unsigned int (unsigned int, unsigned long long int)">;
def crc32cq : PostriscBuiltin<"unsigned int (unsigned int, unsigned __int128_t)">;

def aesenc          : fmt_r3<vId, vId, vId>;
def aesenclast      : fmt_r3<vId, vId, vId>;
def aesdec          : fmt_r3<vId, vId, vId>;
def aesdeclast      : fmt_r3<vId, vId, vId>;
def aeskeygenassist : fmt_r3<vId, vId, u32imm>;
def aesimc          : fmt_r2<vId, vId>;

def clmul_ll : fmt_r3<vId, vId, vId>;
def clmul_hl : fmt_r3<vId, vId, vId>;
def clmul_hh : fmt_r3<vId, vId, vId>;

// debug/monitor registers
def get_mr  : fmt_r2<type_ull, type_ull>;
def get_ibr : fmt_r2<type_ull, type_ull>;
def get_dbr : fmt_r2<type_ull, type_ull>;

def set_mr  : fmt_r3<"void", type_ull, type_ull>;
def set_ibr : fmt_r3<"void", type_ull, type_ull>;
def set_dbr : fmt_r3<"void", type_ull, type_ull>;

def set_dtr: PostriscBuiltin<"void (unsigned long long int, void*, unsigned int)">;
def set_itr: PostriscBuiltin<"void (unsigned long long int, void*, unsigned int)">;

def rscover : PostriscBuiltin<"void()">;
def rsflush : PostriscBuiltin<"void()">;
def rsload : PostriscBuiltin<"void()">;

multiclass SpecialReg<string type>
{
  def get_ # NAME : PostriscBuiltin<!strconcat(type, " ()")>;
  def set_ # NAME : PostriscBuiltin<!strconcat("void (", type, ")")>;
}

defm ip    : SpecialReg<type_ull>;
defm eip   : SpecialReg<type_ull>;
defm fpcr  : SpecialReg<type_ull>;
defm eca   : SpecialReg<type_ull>;
defm rsc   : SpecialReg<type_ull>;
defm rsp   : SpecialReg<type_ull>;
defm bsp   : SpecialReg<type_ull>;
defm psr   : SpecialReg<type_ull>;
defm reip  : SpecialReg<type_ull>;
defm kip   : SpecialReg<type_ull>;
defm ksp   : SpecialReg<type_ull>;
defm krsp  : SpecialReg<type_ull>;
defm peb   : SpecialReg<type_ull>;
defm teb   : SpecialReg<type_ull>;
defm itc   : SpecialReg<type_ull>;
defm itm   : SpecialReg<type_ull>;
defm pta   : SpecialReg<type_ull>;
defm iva   : SpecialReg<type_ull>;
defm iip   : SpecialReg<type_ull>;
defm iipa  : SpecialReg<type_ull>;
defm ipsr  : SpecialReg<type_ull>;
defm cause : SpecialReg<type_ull>;
defm ifa   : SpecialReg<type_ull>;
defm iib   : SpecialReg<type_u128>; // IIB reg contains 128-bit instructions bundle
defm irr0  : SpecialReg<type_ull>;
defm irr1  : SpecialReg<type_ull>;
defm irr2  : SpecialReg<type_ull>;
defm irr3  : SpecialReg<type_ull>;
defm isr0  : SpecialReg<type_ull>;
defm isr1  : SpecialReg<type_ull>;
defm isr2  : SpecialReg<type_ull>;
defm isr3  : SpecialReg<type_ull>;
defm iv    : SpecialReg<type_ull>;
defm lid   : SpecialReg<type_ull>;
defm tpr   : SpecialReg<type_ull>;
defm itcv  : SpecialReg<type_ull>;
defm tsv   : SpecialReg<type_ull>;
defm pmv   : SpecialReg<type_ull>;
defm cmcv  : SpecialReg<type_ull>;

///////////////////////////////////////////////////////////////////////////////////////
// fp scalars
///////////////////////////////////////////////////////////////////////////////////////
def fsqrth    : fmt_r2rm<Fh, Fh>;
def frsqrth   : fmt_r2rm<Fh, Fh>;
def frndh     : fmt_r2rm<Fh, Fh>;
def frndxh    : fmt_r2rm<Fh, Fh>;
def fhtoiw    : fmt_r2rm<type_i32, Fh>;
def fhtouw    : fmt_r2rm<type_u32, Fh>;
def fhtoid    : fmt_r2rm<type_i64, Fh>;
def fhtoud    : fmt_r2rm<type_u64, Fh>;
def fhtoiq    : fmt_r2rm<type_i128, Fh>;
def fhtouq    : fmt_r2rm<type_u128, Fh>;
def fiwtoh    : fmt_r2rm<Fh, type_i32>;
def fuwtoh    : fmt_r2rm<Fh, type_u32>;
def fidtoh    : fmt_r2rm<Fh, type_i64>;
def fudtoh    : fmt_r2rm<Fh, type_u64>;
def fiqtoh    : fmt_r2rm<Fh, type_i128>;
def fuqtoh    : fmt_r2rm<Fh, type_u128>;
def fabdh     : fmt_r3rm<Fh, Fh, Fh>;
def fnabdh    : fmt_r3rm<Fh, Fh, Fh>;
def faddh     : fmt_r3rm<Fh, Fh, Fh>;
def fnaddh    : fmt_r3rm<Fh, Fh, Fh>;
def fsubh     : fmt_r3rm<Fh, Fh, Fh>;
def fmulh     : fmt_r3rm<Fh, Fh, Fh>;
def fnmulh    : fmt_r3rm<Fh, Fh, Fh>;
def fdivh     : fmt_r3rm<Fh, Fh, Fh>;
def fmaddh    : fmt_r4rm<Fh, Fh, Fh, Fh>;
def fmsubh    : fmt_r4rm<Fh, Fh, Fh, Fh>;
def fnmaddh   : fmt_r4rm<Fh, Fh, Fh, Fh>;
def fnmsubh   : fmt_r4rm<Fh, Fh, Fh, Fh>;
def fminimumh : fmt_r3<Fh, Fh, Fh>;
def fmaximumh : fmt_r3<Fh, Fh, Fh>;
def fmergeh   : fmt_r4<Fh, Fh, Fh, Fh>;

def fsqrts    : fmt_r2rm<Fw, Fw>;
def frsqrts   : fmt_r2rm<Fw, Fw>;
def frnds     : fmt_r2rm<Fw, Fw>;
def frndxs    : fmt_r2rm<Fw, Fw>;
def fstoiw    : fmt_r2rm<type_i32, Fw>;
def fstouw    : fmt_r2rm<type_u32, Fw>;
def fstoid    : fmt_r2rm<type_i64, Fw>;
def fstoud    : fmt_r2rm<type_u64, Fw>;
def fstoiq    : fmt_r2rm<type_i128, Fw>;
def fstouq    : fmt_r2rm<type_u128, Fw>;
def fiwtos    : fmt_r2rm<Fw, type_i32>;
def fuwtos    : fmt_r2rm<Fw, type_u32>;
def fidtos    : fmt_r2rm<Fw, type_i64>;
def fudtos    : fmt_r2rm<Fw, type_u64>;
def fiqtos    : fmt_r2rm<Fw, type_i128>;
def fuqtos    : fmt_r2rm<Fw, type_u128>;
def fabds     : fmt_r3rm<Fw, Fw, Fw>;
def fnabds    : fmt_r3rm<Fw, Fw, Fw>;
def fadds     : fmt_r3rm<Fw, Fw, Fw>;
def fnadds    : fmt_r3rm<Fw, Fw, Fw>;
def fsubs     : fmt_r3rm<Fw, Fw, Fw>;
def fmuls     : fmt_r3rm<Fw, Fw, Fw>;
def fnmuls    : fmt_r3rm<Fw, Fw, Fw>;
def fdivs     : fmt_r3rm<Fw, Fw, Fw>;
def fmadds    : fmt_r4rm<Fw, Fw, Fw, Fw>;
def fmsubs    : fmt_r4rm<Fw, Fw, Fw, Fw>;
def fnmadds   : fmt_r4rm<Fw, Fw, Fw, Fw>;
def fnmsubs   : fmt_r4rm<Fw, Fw, Fw, Fw>;
def fminimums : fmt_r3<Fw, Fw, Fw>;
def fmaximums : fmt_r3<Fw, Fw, Fw>;
def fmerges   : fmt_r4<Fw, Fw, Fw, Fw>;

def fsqrtd    : fmt_r2rm<Fd, Fd>;
def frsqrtd   : fmt_r2rm<Fd, Fd>;
def frndd     : fmt_r2rm<Fd, Fd>;
def frndxd    : fmt_r2rm<Fd, Fd>;
def fdtoiw    : fmt_r2rm<type_i32, Fd>;
def fdtouw    : fmt_r2rm<type_u32, Fd>;
def fdtoid    : fmt_r2rm<type_i64, Fd>;
def fdtoud    : fmt_r2rm<type_u64, Fd>;
def fdtoiq    : fmt_r2rm<type_i128, Fd>;
def fdtouq    : fmt_r2rm<type_u128, Fd>;
def fiwtod    : fmt_r2rm<Fd, type_i32>;
def fuwtod    : fmt_r2rm<Fd, type_u32>;
def fidtod    : fmt_r2rm<Fd, type_i64>;
def fudtod    : fmt_r2rm<Fd, type_u64>;
def fiqtod    : fmt_r2rm<Fd, type_i128>;
def fuqtod    : fmt_r2rm<Fd, type_u128>;
def fabdd     : fmt_r3rm<Fd, Fd, Fd>;
def fnabdd    : fmt_r3rm<Fd, Fd, Fd>;
def faddd     : fmt_r3rm<Fd, Fd, Fd>;
def fnaddd    : fmt_r3rm<Fd, Fd, Fd>;
def fsubd     : fmt_r3rm<Fd, Fd, Fd>;
def fmuld     : fmt_r3rm<Fd, Fd, Fd>;
def fnmuld    : fmt_r3rm<Fd, Fd, Fd>;
def fdivd     : fmt_r3rm<Fd, Fd, Fd>;
def fmaddd    : fmt_r4rm<Fd, Fd, Fd, Fd>;
def fmsubd    : fmt_r4rm<Fd, Fd, Fd, Fd>;
def fnmaddd   : fmt_r4rm<Fd, Fd, Fd, Fd>;
def fnmsubd   : fmt_r4rm<Fd, Fd, Fd, Fd>;
def fminimumd : fmt_r3<Fd, Fd, Fd>;
def fmaximumd : fmt_r3<Fd, Fd, Fd>;
def fmerged   : fmt_r4<Fd, Fd, Fd, Fd>;

def fsqrtq    : fmt_r2rm<Fq, Fq>;
def frsqrtq   : fmt_r2rm<Fq, Fq>;
def frndq     : fmt_r2rm<Fq, Fq>;
def frndxq    : fmt_r2rm<Fq, Fq>;
def fqtoiw    : fmt_r2rm<type_i32, Fq>;
def fqtouw    : fmt_r2rm<type_u32, Fq>;
def fqtoid    : fmt_r2rm<type_i64, Fq>;
def fqtoud    : fmt_r2rm<type_u64, Fq>;
def fqtoiq    : fmt_r2rm<type_i128, Fq>;
def fqtouq    : fmt_r2rm<type_u128, Fq>;
def fiwtoq    : fmt_r2rm<Fq, type_i32>;
def fuwtoq    : fmt_r2rm<Fq, type_u32>;
def fidtoq    : fmt_r2rm<Fq, type_i64>;
def fudtoq    : fmt_r2rm<Fq, type_u64>;
def fiqtoq    : fmt_r2rm<Fq, type_i128>;
def fuqtoq    : fmt_r2rm<Fq, type_u128>;
def fabdq     : fmt_r3rm<Fq, Fq, Fq>;
def fnabdq    : fmt_r3rm<Fq, Fq, Fq>;
def faddq     : fmt_r3rm<Fq, Fq, Fq>;
def fnaddq    : fmt_r3rm<Fq, Fq, Fq>;
def fsubq     : fmt_r3rm<Fq, Fq, Fq>;
def fmulq     : fmt_r3rm<Fq, Fq, Fq>;
def fnmulq    : fmt_r3rm<Fq, Fq, Fq>;
def fdivq     : fmt_r3rm<Fq, Fq, Fq>;
def fmaddq    : fmt_r4rm<Fq, Fq, Fq, Fq>;
def fmsubq    : fmt_r4rm<Fq, Fq, Fq, Fq>;
def fnmaddq   : fmt_r4rm<Fq, Fq, Fq, Fq>;
def fnmsubq   : fmt_r4rm<Fq, Fq, Fq, Fq>;
def fminimumq : fmt_r3<Fq, Fq, Fq>;
def fmaximumq : fmt_r3<Fq, Fq, Fq>;
def fmergeq   : fmt_r4<Fq, Fq, Fq, Fq>;

def fstoh   : fmt_r2rm<Fh, Fw>;
def fdtoh   : fmt_r2rm<Fh, Fd>;
def fdtos   : fmt_r2rm<Fw, Fd>;
def fqtoh   : fmt_r2rm<Fh, Fq>;
def fqtos   : fmt_r2rm<Fw, Fq>;
def fqtod   : fmt_r2rm<Fd, Fq>;

///////////////////////////////////////////////////////////////////////////////////////
// fp vector
///////////////////////////////////////////////////////////////////////////////////////
def vfsqrth    : fmt_r2rm<vFh, vFh>;
def vfrsqrth   : fmt_r2rm<vFh, vFh>;
def vfrndh     : fmt_r2rm<vFh, vFh>;
def vfrndxh    : fmt_r2rm<vFh, vFh>;
def vfuhtoh    : fmt_r2rm<vFh, vUh>;
def vfihtoh    : fmt_r2rm<vFh, vIh>;
def vfhtouh    : fmt_r2rm<vUh, vFh>;
def vfhtoih    : fmt_r2rm<vIh, vFh>;
def vfabdh     : fmt_r3rm<vFh, vFh, vFh>;
def vfnabdh    : fmt_r3rm<vFh, vFh, vFh>;
def vfaddh     : fmt_r3rm<vFh, vFh, vFh>;
def vfnaddh    : fmt_r3rm<vFh, vFh, vFh>;
def vfsubh     : fmt_r3rm<vFh, vFh, vFh>;
def vfmulh     : fmt_r3rm<vFh, vFh, vFh>;
def vfnmulh    : fmt_r3rm<vFh, vFh, vFh>;
def vfdivh     : fmt_r3rm<vFh, vFh, vFh>;
def vfaddsubh  : fmt_r3rm<vFh, vFh, vFh>;
def vfsubaddh  : fmt_r3rm<vFh, vFh, vFh>;
def vfhaddh    : fmt_r3rm<vFh, vFh, vFh>;
def vfhmulh    : fmt_r3rm<vFh, vFh, vFh>;
def vfhsubh    : fmt_r3rm<vFh, vFh, vFh>;
def vfdoth     : fmt_r3rm<vFh, vFh, vFh>;
def vfmaddh    : fmt_r4rm<vFh, vFh, vFh, vFh>;
def vfmsubh    : fmt_r4rm<vFh, vFh, vFh, vFh>;
def vfnmaddh   : fmt_r4rm<vFh, vFh, vFh, vFh>;
def vfnmsubh   : fmt_r4rm<vFh, vFh, vFh, vFh>;
def vfmaddsubh : fmt_r4rm<vFh, vFh, vFh, vFh>;
def vfmsubaddh : fmt_r4rm<vFh, vFh, vFh, vFh>;
def vfmergeh   : fmt_r4<vFh, vFh, vFh, vFh>;
def vfcmpoeqh  : fmt_r3<vUh, vFh, vFh>;
def vfcmponeh  : fmt_r3<vUh, vFh, vFh>;
def vfcmpolth  : fmt_r3<vUh, vFh, vFh>;
def vfcmpogeh  : fmt_r3<vUh, vFh, vFh>;
def vfcmpueqh  : fmt_r3<vUh, vFh, vFh>;
def vfcmpuneh  : fmt_r3<vUh, vFh, vFh>;
def vfcmpulth  : fmt_r3<vUh, vFh, vFh>;
def vfcmpugeh  : fmt_r3<vUh, vFh, vFh>;
def vfcmpoh    : fmt_r3<vUh, vFh, vFh>;
def vfcmpuh    : fmt_r3<vUh, vFh, vFh>;
def vfmergelh  : fmt_r3<vFh, vFh, vFh>;
def vfmergehh  : fmt_r3<vFh, vFh, vFh>;
def vfupkhh    : fmt_r2<vFh, vFh>;
def vfupklh    : fmt_r2<vFh, vFh>;

def vfsqrts    : fmt_r2rm<vFw, vFw>;
def vfrsqrts   : fmt_r2rm<vFw, vFw>;
def vfrnds     : fmt_r2rm<vFw, vFw>;
def vfrndxs    : fmt_r2rm<vFw, vFw>;
def vfuwtos    : fmt_r2rm<vFw, vUw>;
def vfiwtos    : fmt_r2rm<vFw, vIw>;
def vfstouw    : fmt_r2rm<vUw, vFw>;
def vfstoiw    : fmt_r2rm<vIw, vFw>;
def vfabds     : fmt_r3rm<vFw, vFw, vFw>;
def vfnabds    : fmt_r3rm<vFw, vFw, vFw>;
def vfadds     : fmt_r3rm<vFw, vFw, vFw>;
def vfnadds    : fmt_r3rm<vFw, vFw, vFw>;
def vfsubs     : fmt_r3rm<vFw, vFw, vFw>;
def vfmuls     : fmt_r3rm<vFw, vFw, vFw>;
def vfnmuls    : fmt_r3rm<vFw, vFw, vFw>;
def vfdivs     : fmt_r3rm<vFw, vFw, vFw>;
def vfaddsubs  : fmt_r3rm<vFw, vFw, vFw>;
def vfsubadds  : fmt_r3rm<vFw, vFw, vFw>;
def vfhadds    : fmt_r3rm<vFw, vFw, vFw>;
def vfhmuls    : fmt_r3rm<vFw, vFw, vFw>;
def vfhsubs    : fmt_r3rm<vFw, vFw, vFw>;
def vfdots     : fmt_r3rm<vFw, vFw, vFw>;
def vfmadds    : fmt_r4rm<vFw, vFw, vFw, vFw>;
def vfmsubs    : fmt_r4rm<vFw, vFw, vFw, vFw>;
def vfnmadds   : fmt_r4rm<vFw, vFw, vFw, vFw>;
def vfnmsubs   : fmt_r4rm<vFw, vFw, vFw, vFw>;
def vfmaddsubs : fmt_r4rm<vFw, vFw, vFw, vFw>;
def vfmsubadds : fmt_r4rm<vFw, vFw, vFw, vFw>;
def vfmerges   : fmt_r4<vFw, vFw, vFw, vFw>;
def vfcmpoeqs  : fmt_r3<vUw, vFw, vFw>;
def vfcmpones  : fmt_r3<vUw, vFw, vFw>;
def vfcmpolts  : fmt_r3<vUw, vFw, vFw>;
def vfcmpoges  : fmt_r3<vUw, vFw, vFw>;
def vfcmpueqs  : fmt_r3<vUw, vFw, vFw>;
def vfcmpunes  : fmt_r3<vUw, vFw, vFw>;
def vfcmpults  : fmt_r3<vUw, vFw, vFw>;
def vfcmpuges  : fmt_r3<vUw, vFw, vFw>;
def vfcmpos    : fmt_r3<vUw, vFw, vFw>;
def vfcmpus    : fmt_r3<vUw, vFw, vFw>;
def vfmergels  : fmt_r3<vFw, vFw, vFw>;
def vfmergehs  : fmt_r3<vFw, vFw, vFw>;
def vfupkhs    : fmt_r2<vFw, vFw>;
def vfupkls    : fmt_r2<vFw, vFw>;

def vfsqrtd    : fmt_r2rm<vFd, vFd>;
def vfrsqrtd   : fmt_r2rm<vFd, vFd>;
def vfrndd     : fmt_r2rm<vFd, vFd>;
def vfrndxd    : fmt_r2rm<vFd, vFd>;
def vfudtod    : fmt_r2rm<vFd, vUd>;
def vfidtod    : fmt_r2rm<vFd, vId>;
def vfdtoud    : fmt_r2rm<vUd, vFd>;
def vfdtoid    : fmt_r2rm<vId, vFd>;
def vfabdd     : fmt_r3rm<vFd, vFd, vFd>;
def vfnabdd    : fmt_r3rm<vFd, vFd, vFd>;
def vfaddd     : fmt_r3rm<vFd, vFd, vFd>;
def vfnaddd    : fmt_r3rm<vFd, vFd, vFd>;
def vfsubd     : fmt_r3rm<vFd, vFd, vFd>;
def vfmuld     : fmt_r3rm<vFd, vFd, vFd>;
def vfnmuld    : fmt_r3rm<vFd, vFd, vFd>;
def vfdivd     : fmt_r3rm<vFd, vFd, vFd>;
def vfaddsubd  : fmt_r3rm<vFd, vFd, vFd>;
def vfsubaddd  : fmt_r3rm<vFd, vFd, vFd>;
def vfhaddd    : fmt_r3rm<vFd, vFd, vFd>;
def vfhmuld    : fmt_r3rm<vFd, vFd, vFd>;
def vfhsubd    : fmt_r3rm<vFd, vFd, vFd>;
def vfdotd     : fmt_r3rm<vFd, vFd, vFd>;
def vfmaddd    : fmt_r4rm<vFd, vFd, vFd, vFd>;
def vfmsubd    : fmt_r4rm<vFd, vFd, vFd, vFd>;
def vfnmaddd   : fmt_r4rm<vFd, vFd, vFd, vFd>;
def vfnmsubd   : fmt_r4rm<vFd, vFd, vFd, vFd>;
def vfmaddsubd : fmt_r4rm<vFd, vFd, vFd, vFd>;
def vfmsubaddd : fmt_r4rm<vFd, vFd, vFd, vFd>;
def vfmerged   : fmt_r4<vFd, vFd, vFd, vFd>;
def vfcmpoeqd  : fmt_r3<vUd, vFd, vFd>;
def vfcmponed  : fmt_r3<vUd, vFd, vFd>;
def vfcmpoltd  : fmt_r3<vUd, vFd, vFd>;
def vfcmpoged  : fmt_r3<vUd, vFd, vFd>;
def vfcmpueqd  : fmt_r3<vUd, vFd, vFd>;
def vfcmpuned  : fmt_r3<vUd, vFd, vFd>;
def vfcmpultd  : fmt_r3<vUd, vFd, vFd>;
def vfcmpuged  : fmt_r3<vUd, vFd, vFd>;
def vfcmpod    : fmt_r3<vUd, vFd, vFd>;
def vfcmpud    : fmt_r3<vUd, vFd, vFd>;
def vfmergeld  : fmt_r3<vFd, vFd, vFd>;
def vfmergehd  : fmt_r3<vFd, vFd, vFd>;
def vfupkhd    : fmt_r2<vFd, vFd>;
def vfupkld    : fmt_r2<vFd, vFd>;

///////////////////////////////////////////////////////////////////////////////////////
// int vector
///////////////////////////////////////////////////////////////////////////////////////
def vaddb        : fmt_r3<vUb, vUb, vUb>;
def vsubb        : fmt_r3<vUb, vUb, vUb>;
def vaddcb       : fmt_r3<vUb, vUb, vUb>;
def vsubcb       : fmt_r3<vUb, vUb, vUb>;
def vaddob       : fmt_r3<vIb, vIb, vIb>;
def vsubob       : fmt_r3<vIb, vIb, vIb>;
def vaddssatb    : fmt_r3<vIb, vIb, vIb>;
def vsubssatb    : fmt_r3<vIb, vIb, vIb>;
def vaddusatb    : fmt_r3<vUb, vUb, vUb>;
def vsubusatb    : fmt_r3<vUb, vUb, vUb>;
def vminsb       : fmt_r3<vIb, vIb, vIb>;
def vmaxsb       : fmt_r3<vIb, vIb, vIb>;
def vminub       : fmt_r3<vUb, vUb, vUb>;
def vmaxub       : fmt_r3<vUb, vUb, vUb>;
def vavgsb       : fmt_r3<vIb, vIb, vIb>;
def vavgub       : fmt_r3<vUb, vUb, vUb>;
def vcmpeqb      : fmt_r3<vIb, vIb, vIb>;
def vcmpltsb     : fmt_r3<vIb, vIb, vIb>;
def vcmpltub     : fmt_r3<vUb, vUb, vUb>;
def vsllb        : fmt_r3<vUb, vUb, vUb>;
def vsrlb        : fmt_r3<vUb, vUb, vUb>;
def vsrab        : fmt_r3<vIb, vIb, vIb>;
def vsllib       : fmt_r3<vUb, vUb, u32imm>;
def vsrlib       : fmt_r3<vUb, vUb, u32imm>;
def vsraib       : fmt_r3<vIb, vIb, u32imm>;
def vmergehb     : fmt_r3<vUb, vUb, vUb>;
def vmergelb     : fmt_r3<vUb, vUb, vUb>;
def vsrpib       : fmt_r4<vUb, vUb, vUb, u32imm>;
def vslpb        : fmt_r4<vUb, vUb, vUb, vUb>;
def vsrpb        : fmt_r4<vUb, vUb, vUb, vUb>;
def vsplatb      : fmt_r3<vUb, vUb, type_i32>;

def vaddh        : fmt_r3<vUh, vUh, vUh>;
def vsubh        : fmt_r3<vUh, vUh, vUh>;
def vaddch       : fmt_r3<vUh, vUh, vUh>;
def vsubch       : fmt_r3<vUh, vUh, vUh>;
def vaddoh       : fmt_r3<vIh, vIh, vIh>;
def vsuboh       : fmt_r3<vIh, vIh, vIh>;
def vaddssath    : fmt_r3<vIh, vIh, vIh>;
def vsubssath    : fmt_r3<vIh, vIh, vIh>;
def vaddusath    : fmt_r3<vUh, vUh, vUh>;
def vsubusath    : fmt_r3<vUh, vUh, vUh>;
def vminsh       : fmt_r3<vIh, vIh, vIh>;
def vmaxsh       : fmt_r3<vIh, vIh, vIh>;
def vminuh       : fmt_r3<vUh, vUh, vUh>;
def vmaxuh       : fmt_r3<vUh, vUh, vUh>;
def vavgsh       : fmt_r3<vIh, vIh, vIh>;
def vavguh       : fmt_r3<vUh, vUh, vUh>;
def vcmpeqh      : fmt_r3<vIh, vIh, vIh>;
def vcmpltsh     : fmt_r3<vIh, vIh, vIh>;
def vcmpltuh     : fmt_r3<vUh, vUh, vUh>;
def vsllh        : fmt_r3<vUh, vUh, vUh>;
def vsrlh        : fmt_r3<vUh, vUh, vUh>;
def vsrah        : fmt_r3<vIh, vIh, vIh>;
def vsllih       : fmt_r3<vUh, vUh, u32imm>;
def vsrlih       : fmt_r3<vUh, vUh, u32imm>;
def vsraih       : fmt_r3<vIh, vIh, u32imm>;
def vmergehh     : fmt_r3<vUh, vUh, vUh>;
def vmergelh     : fmt_r3<vUh, vUh, vUh>;
def vsrpih       : fmt_r4<vUh, vUh, vUh, u32imm>;
def vslph        : fmt_r4<vUh, vUh, vUh, vUh>;
def vsrph        : fmt_r4<vUh, vUh, vUh, vUh>;
def vsplath      : fmt_r3<vUh, vUh, type_i32>;

def vaddw        : fmt_r3<vUw, vUw, vUw>;
def vsubw        : fmt_r3<vUw, vUw, vUw>;
def vaddcw       : fmt_r3<vUw, vUw, vUw>;
def vsubcw       : fmt_r3<vUw, vUw, vUw>;
def vaddow       : fmt_r3<vIw, vIw, vIw>;
def vsubow       : fmt_r3<vIw, vIw, vIw>;
def vaddssatw    : fmt_r3<vIw, vIw, vIw>;
def vsubssatw    : fmt_r3<vIw, vIw, vIw>;
def vaddusatw    : fmt_r3<vUw, vUw, vUw>;
def vsubusatw    : fmt_r3<vUw, vUw, vUw>;
def vminsw       : fmt_r3<vIw, vIw, vIw>;
def vmaxsw       : fmt_r3<vIw, vIw, vIw>;
def vminuw       : fmt_r3<vUw, vUw, vUw>;
def vmaxuw       : fmt_r3<vUw, vUw, vUw>;
def vavgsw       : fmt_r3<vIw, vIw, vIw>;
def vavguw       : fmt_r3<vUw, vUw, vUw>;
def vcmpeqw      : fmt_r3<vIw, vIw, vIw>;
def vcmpltsw     : fmt_r3<vIw, vIw, vIw>;
def vcmpltuw     : fmt_r3<vUw, vUw, vUw>;
def vsllw        : fmt_r3<vUw, vUw, vUw>;
def vsrlw        : fmt_r3<vUw, vUw, vUw>;
def vsraw        : fmt_r3<vIw, vIw, vIw>;
def vslliw       : fmt_r3<vUw, vUw, u32imm>;
def vsrliw       : fmt_r3<vUw, vUw, u32imm>;
def vsraiw       : fmt_r3<vIw, vIw, u32imm>;
def vmergehw     : fmt_r3<vUw, vUw, vUw>;
def vmergelw     : fmt_r3<vUw, vUw, vUw>;
def vsrpiw       : fmt_r4<vUw, vUw, vUw, u32imm>;
def vslpw        : fmt_r4<vUw, vUw, vUw, vUw>;
def vsrpw        : fmt_r4<vUw, vUw, vUw, vUw>;
def vsplatw      : fmt_r3<vUw, vUw, type_i32>;

def vaddd        : fmt_r3<vUd, vUd, vUd>;
def vsubd        : fmt_r3<vUd, vUd, vUd>;
def vaddcd       : fmt_r3<vUd, vUd, vUd>;
def vsubcd       : fmt_r3<vUd, vUd, vUd>;
def vaddod       : fmt_r3<vId, vId, vId>;
def vsubod       : fmt_r3<vId, vId, vId>;
def vaddssatd    : fmt_r3<vId, vId, vId>;
def vsubssatd    : fmt_r3<vId, vId, vId>;
def vaddusatd    : fmt_r3<vUd, vUd, vUd>;
def vsubusatd    : fmt_r3<vUd, vUd, vUd>;
def vminsd       : fmt_r3<vId, vId, vId>;
def vmaxsd       : fmt_r3<vId, vId, vId>;
def vminud       : fmt_r3<vUd, vUd, vUd>;
def vmaxud       : fmt_r3<vUd, vUd, vUd>;
def vavgsd       : fmt_r3<vId, vId, vId>;
def vavgud       : fmt_r3<vUd, vUd, vUd>;
def vcmpeqd      : fmt_r3<vId, vId, vId>;
def vcmpltsd     : fmt_r3<vId, vId, vId>;
def vcmpltud     : fmt_r3<vUd, vUd, vUd>;
def vslld        : fmt_r3<vUd, vUd, vUd>;
def vsrld        : fmt_r3<vUd, vUd, vUd>;
def vsrad        : fmt_r3<vId, vId, vId>;
def vsllid       : fmt_r3<vUd, vUd, u32imm>;
def vsrlid       : fmt_r3<vUd, vUd, u32imm>;
def vsraid       : fmt_r3<vId, vId, u32imm>;
def vmergehd     : fmt_r3<vUd, vUd, vUd>;
def vmergeld     : fmt_r3<vUd, vUd, vUd>;
def vsrpid       : fmt_r4<vUd, vUd, vUd, u32imm>;
def vslpd        : fmt_r4<vUd, vUd, vUd, vUd>;
def vsrpd        : fmt_r4<vUd, vUd, vUd, vUd>;
def vsplatd      : fmt_r3<vUd, vUd, type_i32>;

///////////////////////////////////////////////////////////////////////////////////////
// int vector misc
///////////////////////////////////////////////////////////////////////////////////////
def vpkssath : fmt_r3<vUb, vUh, vUh>;
def vpkssatw : fmt_r3<vUh, vUw, vUw>;
def vpkssatd : fmt_r3<vUw, vUd, vUd>;

def vpkusath : fmt_r3<vUb, vUh, vUh>;
def vpkusatw : fmt_r3<vUh, vUw, vUw>;
def vpkusatd : fmt_r3<vUw, vUd, vUd>;

def vpkumodh : fmt_r3<vUb, vUh, vUh>;
def vpkumodw : fmt_r3<vUh, vUw, vUw>;
def vpkumodd : fmt_r3<vUw, vUd, vUd>;

def vpkusatsh : fmt_r3<vUb, vUh, vUh>;
def vpkusatsw : fmt_r3<vUh, vUw, vUw>;
def vpkusatsd : fmt_r3<vUw, vUd, vUd>;

def vupkhsb : fmt_r2<vIh, vIb>;
def vupkhsh : fmt_r2<vIw, vIh>;
def vupkhsw : fmt_r2<vId, vIw>;

def vupkhub : fmt_r2<vUh, vUb>;
def vupkhuh : fmt_r2<vUw, vUh>;
def vupkhuw : fmt_r2<vUd, vUw>;

def vupklsb : fmt_r2<vIh, vIb>;
def vupklsh : fmt_r2<vIw, vIh>;
def vupklsw : fmt_r2<vId, vIw>;

def vupklub : fmt_r2<vUh, vUb>;
def vupkluh : fmt_r2<vUw, vUh>;
def vupkluw : fmt_r2<vUd, vUw>;

def vpermb : fmt_r4<vUb, vUb, vUb, vUb>;
