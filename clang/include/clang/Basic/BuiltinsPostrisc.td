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

def nop   : PostriscBuiltin<"void(_Constant unsigned long long int)">;
def nop_l : PostriscBuiltin<"void(_Constant unsigned long long int)">;
def tpa   : PostriscBuiltin<"unsigned long long int(void*)">;

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
defm iib   : PostriscBuiltinsSpecialReg<"unsigned __int128_t">;
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

def clmulll : PostriscBuiltin<"_Vector<2, long long int>(_Vector<2, long long int>, _Vector<2, long long int>)">;
def clmulhl : PostriscBuiltin<"_Vector<2, long long int>(_Vector<2, long long int>, _Vector<2, long long int>)">;
def clmulhh : PostriscBuiltin<"_Vector<2, long long int>(_Vector<2, long long int>, _Vector<2, long long int>)">;

///////////////////////////////////////////////////////////////////////////////////////
// fp scalar half
///////////////////////////////////////////////////////////////////////////////////////

def fabssh   : PostriscBuiltinUnary<"_Float16">;
def fnabssh  : PostriscBuiltinUnary<"_Float16">;
def fnegsh   : PostriscBuiltinUnary<"_Float16">;
def frsqrtsh : PostriscBuiltinUnary<"_Float16">;
def fsqrtsh  : PostriscBuiltinUnary<"_Float16">;

def fabsdsh  : PostriscBuiltinBinary<"_Float16">;
def fnabsdsh : PostriscBuiltinBinary<"_Float16">;
def faddsh   : PostriscBuiltinBinary<"_Float16">;
def fnaddsh  : PostriscBuiltinBinary<"_Float16">;
def faminsh  : PostriscBuiltinBinary<"_Float16">;
def famaxsh  : PostriscBuiltinBinary<"_Float16">;
def fmaxsh   : PostriscBuiltinBinary<"_Float16">;
def fminsh   : PostriscBuiltinBinary<"_Float16">;
def fdivsh   : PostriscBuiltinBinary<"_Float16">;
def fdotsh   : PostriscBuiltinBinary<"_Float16">;
def fmulsh   : PostriscBuiltinBinary<"_Float16">;
def fnmulsh  : PostriscBuiltinBinary<"_Float16">;
def fsubsh   : PostriscBuiltinBinary<"_Float16">;

def fmaddsh  : PostriscBuiltinFused<"_Float16">;
def fnmaddsh : PostriscBuiltinFused<"_Float16">;
def fmsubsh  : PostriscBuiltinFused<"_Float16">;
def fnmsubsh : PostriscBuiltinFused<"_Float16">;
def fmergesh : PostriscBuiltinFused<"_Float16">;

///////////////////////////////////////////////////////////////////////////////////////
// fp scalar single
///////////////////////////////////////////////////////////////////////////////////////

def fabsss   : PostriscBuiltinUnary<"float">;
def fnabsss  : PostriscBuiltinUnary<"float">;
def fnegss   : PostriscBuiltinUnary<"float">;
def frsqrtss : PostriscBuiltinUnary<"float">;
def fsqrtss  : PostriscBuiltinUnary<"float">;

def fabsdss  : PostriscBuiltinBinary<"float">;
def fnabsdss : PostriscBuiltinBinary<"float">;
def faddss   : PostriscBuiltinBinary<"float">;
def fnaddss  : PostriscBuiltinBinary<"float">;
def faminss  : PostriscBuiltinBinary<"float">;
def famaxss  : PostriscBuiltinBinary<"float">;
def fmaxss   : PostriscBuiltinBinary<"float">;
def fminss   : PostriscBuiltinBinary<"float">;
def fdivss   : PostriscBuiltinBinary<"float">;
def fdotss   : PostriscBuiltinBinary<"float">;
def fmulss   : PostriscBuiltinBinary<"float">;
def fnmulss  : PostriscBuiltinBinary<"float">;
def fsubss   : PostriscBuiltinBinary<"float">;

def fmaddss  : PostriscBuiltinFused<"float">;
def fnmaddss : PostriscBuiltinFused<"float">;
def fmsubss  : PostriscBuiltinFused<"float">;
def fnmsubss : PostriscBuiltinFused<"float">;
def fmergess : PostriscBuiltinFused<"float">;

///////////////////////////////////////////////////////////////////////////////////////
// fp scalar double
///////////////////////////////////////////////////////////////////////////////////////

def fabssd   : PostriscBuiltinUnary<"double">;
def fnabssd  : PostriscBuiltinUnary<"double">;
def fnegsd   : PostriscBuiltinUnary<"double">;
def frsqrtsd : PostriscBuiltinUnary<"double">;
def fsqrtsd  : PostriscBuiltinUnary<"double">;

def fabsdsd  : PostriscBuiltinBinary<"double">;
def fnabsdsd : PostriscBuiltinBinary<"double">;
def faddsd   : PostriscBuiltinBinary<"double">;
def fnaddsd  : PostriscBuiltinBinary<"double">;
def faminsd  : PostriscBuiltinBinary<"double">;
def famaxsd  : PostriscBuiltinBinary<"double">;
def fmaxsd   : PostriscBuiltinBinary<"double">;
def fminsd   : PostriscBuiltinBinary<"double">;
def fdivsd   : PostriscBuiltinBinary<"double">;
def fdotsd   : PostriscBuiltinBinary<"double">;
def fmulsd   : PostriscBuiltinBinary<"double">;
def fnmulsd  : PostriscBuiltinBinary<"double">;
def fsubsd   : PostriscBuiltinBinary<"double">;

def fmaddsd  : PostriscBuiltinFused<"double">;
def fnmaddsd : PostriscBuiltinFused<"double">;
def fmsubsd  : PostriscBuiltinFused<"double">;
def fnmsubsd : PostriscBuiltinFused<"double">;
def fmergesd : PostriscBuiltinFused<"double">;

///////////////////////////////////////////////////////////////////////////////////////
// fp scalar quadruple
///////////////////////////////////////////////////////////////////////////////////////

def fabssq   : PostriscBuiltinUnary<"long double">;
def fnabssq  : PostriscBuiltinUnary<"long double">;
def fnegsq   : PostriscBuiltinUnary<"long double">;
def frsqrtsq : PostriscBuiltinUnary<"long double">;
def fsqrtsq  : PostriscBuiltinUnary<"long double">;

def fabsdsq  : PostriscBuiltinBinary<"long double">;
def fnabsdsq : PostriscBuiltinBinary<"long double">;
def faddsq   : PostriscBuiltinBinary<"long double">;
def fnaddsq  : PostriscBuiltinBinary<"long double">;
def faminsq  : PostriscBuiltinBinary<"long double">;
def famaxsq  : PostriscBuiltinBinary<"long double">;
def fmaxsq   : PostriscBuiltinBinary<"long double">;
def fminsq   : PostriscBuiltinBinary<"long double">;
def fdivsq   : PostriscBuiltinBinary<"long double">;
def fdotsq   : PostriscBuiltinBinary<"long double">;
def fmulsq   : PostriscBuiltinBinary<"long double">;
def fnmulsq  : PostriscBuiltinBinary<"long double">;
def fsubsq   : PostriscBuiltinBinary<"long double">;

def fmaddsq  : PostriscBuiltinFused<"long double">;
def fnmaddsq : PostriscBuiltinFused<"long double">;
def fmsubsq  : PostriscBuiltinFused<"long double">;
def fnmsubsq : PostriscBuiltinFused<"long double">;
def fmergesq : PostriscBuiltinFused<"long double">;

///////////////////////////////////////////////////////////////////////////////////////
// fp vector packed half
///////////////////////////////////////////////////////////////////////////////////////

def fabsph   : PostriscBuiltinUnary<"_Vector<8, _Float16>">;
def fnabsph  : PostriscBuiltinUnary<"_Vector<8, _Float16>">;
def fnegph   : PostriscBuiltinUnary<"_Vector<8, _Float16>">;
def frsqrtph : PostriscBuiltinUnary<"_Vector<8, _Float16>">;
def fsqrtph  : PostriscBuiltinUnary<"_Vector<8, _Float16>">;

def fabsdph  : PostriscBuiltinBinary<"_Vector<8, _Float16>">;
def fnabsdph : PostriscBuiltinBinary<"_Vector<8, _Float16>">;
def faddph   : PostriscBuiltinBinary<"_Vector<8, _Float16>">;
def fnaddph  : PostriscBuiltinBinary<"_Vector<8, _Float16>">;
def faminph  : PostriscBuiltinBinary<"_Vector<8, _Float16>">;
def famaxph  : PostriscBuiltinBinary<"_Vector<8, _Float16>">;
def fmaxph   : PostriscBuiltinBinary<"_Vector<8, _Float16>">;
def fminph   : PostriscBuiltinBinary<"_Vector<8, _Float16>">;
def fdivph   : PostriscBuiltinBinary<"_Vector<8, _Float16>">;
def fdotph   : PostriscBuiltinBinary<"_Vector<8, _Float16>">;
def fmulph   : PostriscBuiltinBinary<"_Vector<8, _Float16>">;
def fnmulph  : PostriscBuiltinBinary<"_Vector<8, _Float16>">;
def fsubph   : PostriscBuiltinBinary<"_Vector<8, _Float16>">;

def fmaddph  : PostriscBuiltinFused<"_Vector<8, _Float16>">;
def fnmaddph : PostriscBuiltinFused<"_Vector<8, _Float16>">;
def fmsubph  : PostriscBuiltinFused<"_Vector<8, _Float16>">;
def fnmsubph : PostriscBuiltinFused<"_Vector<8, _Float16>">;
def fmergeph : PostriscBuiltinFused<"_Vector<8, _Float16>">;
def fma_ph   : PostriscBuiltinFused<"_Vector<8, _Float16>">;

// horizontal
def faddcph : PostriscBuiltinBinary<"_Vector<8, _Float16>">;
def faddhph : PostriscBuiltinBinary<"_Vector<8, _Float16>">;
def fmulhph : PostriscBuiltinBinary<"_Vector<8, _Float16>">;
def fsubcph : PostriscBuiltinBinary<"_Vector<8, _Float16>">;
def fsubhph : PostriscBuiltinBinary<"_Vector<8, _Float16>">;

///////////////////////////////////////////////////////////////////////////////////////
// fp vector packed single
///////////////////////////////////////////////////////////////////////////////////////

def fabsps   : PostriscBuiltinUnary<"_Vector<4, float>">;
def fnabsps  : PostriscBuiltinUnary<"_Vector<4, float>">;
def fnegps   : PostriscBuiltinUnary<"_Vector<4, float>">;
def frsqrtps : PostriscBuiltinUnary<"_Vector<4, float>">;
def fsqrtps  : PostriscBuiltinUnary<"_Vector<4, float>">;

def fabsdps  : PostriscBuiltinBinary<"_Vector<4, float>">;
def fnabsdps : PostriscBuiltinBinary<"_Vector<4, float>">;
def faddps   : PostriscBuiltinBinary<"_Vector<4, float>">;
def fnaddps  : PostriscBuiltinBinary<"_Vector<4, float>">;
def faminps  : PostriscBuiltinBinary<"_Vector<4, float>">;
def famaxps  : PostriscBuiltinBinary<"_Vector<4, float>">;
def fmaxps   : PostriscBuiltinBinary<"_Vector<4, float>">;
def fminps   : PostriscBuiltinBinary<"_Vector<4, float>">;
def fdivps   : PostriscBuiltinBinary<"_Vector<4, float>">;
def fdotps   : PostriscBuiltinBinary<"_Vector<4, float>">;
def fmulps   : PostriscBuiltinBinary<"_Vector<4, float>">;
def fnmulps  : PostriscBuiltinBinary<"_Vector<4, float>">;
def fsubps   : PostriscBuiltinBinary<"_Vector<4, float>">;

def fmaddps  : PostriscBuiltinFused<"_Vector<4, float>">;
def fnmaddps : PostriscBuiltinFused<"_Vector<4, float>">;
def fmsubps  : PostriscBuiltinFused<"_Vector<4, float>">;
def fnmsubps : PostriscBuiltinFused<"_Vector<4, float>">;
def fmergeps : PostriscBuiltinFused<"_Vector<4, float>">;
def fma_ps   : PostriscBuiltinFused<"_Vector<4, float>">;

// horizontal
def faddcps : PostriscBuiltinBinary<"_Vector<4, float>">;
def faddhps : PostriscBuiltinBinary<"_Vector<4, float>">;
def fmulhps : PostriscBuiltinBinary<"_Vector<4, float>">;
def fsubcps : PostriscBuiltinBinary<"_Vector<4, float>">;
def fsubhps : PostriscBuiltinBinary<"_Vector<4, float>">;

///////////////////////////////////////////////////////////////////////////////////////
// fp vector packed double
///////////////////////////////////////////////////////////////////////////////////////

def fabspd   : PostriscBuiltinUnary<"_Vector<2, double>">;
def fnabspd  : PostriscBuiltinUnary<"_Vector<2, double>">;
def fnegpd   : PostriscBuiltinUnary<"_Vector<2, double>">;
def frsqrtpd : PostriscBuiltinUnary<"_Vector<2, double>">;
def fsqrtpd  : PostriscBuiltinUnary<"_Vector<2, double>">;

def fabsdpd  : PostriscBuiltinBinary<"_Vector<2, double>">;
def fnabsdpd : PostriscBuiltinBinary<"_Vector<2, double>">;
def faddpd   : PostriscBuiltinBinary<"_Vector<2, double>">;
def fnaddpd  : PostriscBuiltinBinary<"_Vector<2, double>">;
def faminpd  : PostriscBuiltinBinary<"_Vector<2, double>">;
def famaxpd  : PostriscBuiltinBinary<"_Vector<2, double>">;
def fmaxpd   : PostriscBuiltinBinary<"_Vector<2, double>">;
def fminpd   : PostriscBuiltinBinary<"_Vector<2, double>">;
def fdivpd   : PostriscBuiltinBinary<"_Vector<2, double>">;
def fdotpd   : PostriscBuiltinBinary<"_Vector<2, double>">;
def fmulpd   : PostriscBuiltinBinary<"_Vector<2, double>">;
def fnmulpd  : PostriscBuiltinBinary<"_Vector<2, double>">;
def fsubpd   : PostriscBuiltinBinary<"_Vector<2, double>">;

def fmaddpd  : PostriscBuiltinFused<"_Vector<2, double>">;
def fnmaddpd : PostriscBuiltinFused<"_Vector<2, double>">;
def fmsubpd  : PostriscBuiltinFused<"_Vector<2, double>">;
def fnmsubpd : PostriscBuiltinFused<"_Vector<2, double>">;
def fmergepd : PostriscBuiltinFused<"_Vector<2, double>">;
def fma_pd   : PostriscBuiltinFused<"_Vector<2, double>">;

// horizontal
def faddcpd : PostriscBuiltinBinary<"_Vector<2, double>">;
def faddhpd : PostriscBuiltinBinary<"_Vector<2, double>">;
def fmulhpd : PostriscBuiltinBinary<"_Vector<2, double>">;
def fsubcpd : PostriscBuiltinBinary<"_Vector<2, double>">;
def fsubhpd : PostriscBuiltinBinary<"_Vector<2, double>">;

///////////////////////////////////////////////////////////////////////////////////////
// int vector 1-byte
///////////////////////////////////////////////////////////////////////////////////////

def vaddcb   : PostriscBuiltinBinary<"_Vector<16, unsigned char>">;
def vaddob   : PostriscBuiltinBinary<"_Vector<16,   signed char>">;
def vaddssb  : PostriscBuiltinBinary<"_Vector<16,   signed char>">;
def vaddusb  : PostriscBuiltinBinary<"_Vector<16, unsigned char>">;
def vaddub   : PostriscBuiltinBinary<"_Vector<16, unsigned char>">;
def vavgub   : PostriscBuiltinBinary<"_Vector<16, unsigned char>">;
def vavgsb   : PostriscBuiltinBinary<"_Vector<16,   signed char>">;
def vcmpeqb  : PostriscBuiltinBinary<"_Vector<16,   signed char>">;
def vcmpltb  : PostriscBuiltinBinary<"_Vector<16,   signed char>">;
def vcmpltub : PostriscBuiltinBinary<"_Vector<16, unsigned char>">;
def vmaxsb   : PostriscBuiltinBinary<"_Vector<16,   signed char>">;
def vmaxub   : PostriscBuiltinBinary<"_Vector<16, unsigned char>">;
def vminsb   : PostriscBuiltinBinary<"_Vector<16,   signed char>">;
def vminub   : PostriscBuiltinBinary<"_Vector<16, unsigned char>">;
def vrolb    : PostriscBuiltinBinary<"_Vector<16, unsigned char>">;
def vrorb    : PostriscBuiltinBinary<"_Vector<16, unsigned char>">;
def vsllb    : PostriscBuiltinBinary<"_Vector<16, unsigned char>">;
def vsrab    : PostriscBuiltinBinary<"_Vector<16,   signed char>">;
def vsrlb    : PostriscBuiltinBinary<"_Vector<16, unsigned char>">;
def vsubbb   : PostriscBuiltinBinary<"_Vector<16, unsigned char>">;
def vsubob   : PostriscBuiltinBinary<"_Vector<16,   signed char>">;
def vsubub   : PostriscBuiltinBinary<"_Vector<16, unsigned char>">;
def vsubssb  : PostriscBuiltinBinary<"_Vector<16,   signed char>">;
def vsubusb  : PostriscBuiltinBinary<"_Vector<16, unsigned char>">;
def vmrghb   : PostriscBuiltinBinary<"_Vector<16, unsigned char>">;
def vmrglb   : PostriscBuiltinBinary<"_Vector<16, unsigned char>">;

///////////////////////////////////////////////////////////////////////////////////////
// int vector 2-byte
///////////////////////////////////////////////////////////////////////////////////////

def vaddch   : PostriscBuiltinBinary<"_Vector<8, unsigned short>">;
def vaddoh   : PostriscBuiltinBinary<"_Vector<8,   signed short>">;
def vaddssh  : PostriscBuiltinBinary<"_Vector<8,   signed short>">;
def vaddush  : PostriscBuiltinBinary<"_Vector<8, unsigned short>">;
def vadduh   : PostriscBuiltinBinary<"_Vector<8, unsigned short>">;
def vavguh   : PostriscBuiltinBinary<"_Vector<8, unsigned short>">;
def vavgsh   : PostriscBuiltinBinary<"_Vector<8,   signed short>">;
def vcmpeqh  : PostriscBuiltinBinary<"_Vector<8,   signed short>">;
def vcmplth  : PostriscBuiltinBinary<"_Vector<8,   signed short>">;
def vcmpltuh : PostriscBuiltinBinary<"_Vector<8, unsigned short>">;
def vmaxsh   : PostriscBuiltinBinary<"_Vector<8,   signed short>">;
def vmaxuh   : PostriscBuiltinBinary<"_Vector<8, unsigned short>">;
def vminsh   : PostriscBuiltinBinary<"_Vector<8,   signed short>">;
def vminuh   : PostriscBuiltinBinary<"_Vector<8, unsigned short>">;
def vrolh    : PostriscBuiltinBinary<"_Vector<8, unsigned short>">;
def vrorh    : PostriscBuiltinBinary<"_Vector<8, unsigned short>">;
def vsllh    : PostriscBuiltinBinary<"_Vector<8, unsigned short>">;
def vsrah    : PostriscBuiltinBinary<"_Vector<8,   signed short>">;
def vsrlh    : PostriscBuiltinBinary<"_Vector<8, unsigned short>">;
def vsubbh   : PostriscBuiltinBinary<"_Vector<8, unsigned short>">;
def vsuboh   : PostriscBuiltinBinary<"_Vector<8,   signed short>">;
def vsubuh   : PostriscBuiltinBinary<"_Vector<8, unsigned short>">;
def vsubssh  : PostriscBuiltinBinary<"_Vector<8,   signed short>">;
def vsubush  : PostriscBuiltinBinary<"_Vector<8, unsigned short>">;
def vmrghh   : PostriscBuiltinBinary<"_Vector<8, unsigned short>">;
def vmrglh   : PostriscBuiltinBinary<"_Vector<8, unsigned short>">;

///////////////////////////////////////////////////////////////////////////////////////
// int vector 4-byte
///////////////////////////////////////////////////////////////////////////////////////

def vaddcw   : PostriscBuiltinBinary<"_Vector<4, unsigned int>">;
def vaddow   : PostriscBuiltinBinary<"_Vector<4, int>">;
def vaddssw  : PostriscBuiltinBinary<"_Vector<4, int>">;
def vaddusw  : PostriscBuiltinBinary<"_Vector<4, unsigned int>">;
def vadduw   : PostriscBuiltinBinary<"_Vector<4, unsigned int>">;
def vavguw   : PostriscBuiltinBinary<"_Vector<4, unsigned int>">;
def vavgsw   : PostriscBuiltinBinary<"_Vector<4, int>">;
def vcmpeqw  : PostriscBuiltinBinary<"_Vector<4, int>">;
def vcmpltw  : PostriscBuiltinBinary<"_Vector<4, int>">;
def vcmpltuw : PostriscBuiltinBinary<"_Vector<4, unsigned int>">;
def vmaxsw   : PostriscBuiltinBinary<"_Vector<4, int>">;
def vmaxuw   : PostriscBuiltinBinary<"_Vector<4, unsigned int>">;
def vminsw   : PostriscBuiltinBinary<"_Vector<4, int>">;
def vminuw   : PostriscBuiltinBinary<"_Vector<4, unsigned int>">;
def vrolw    : PostriscBuiltinBinary<"_Vector<4, unsigned int>">;
def vrorw    : PostriscBuiltinBinary<"_Vector<4, unsigned int>">;
def vsllw    : PostriscBuiltinBinary<"_Vector<4, unsigned int>">;
def vsraw    : PostriscBuiltinBinary<"_Vector<4, int>">;
def vsrlw    : PostriscBuiltinBinary<"_Vector<4, unsigned int>">;
def vsubbw   : PostriscBuiltinBinary<"_Vector<4, unsigned int>">;
def vsubow   : PostriscBuiltinBinary<"_Vector<4, int>">;
def vsubuw   : PostriscBuiltinBinary<"_Vector<4, unsigned int>">;
def vsubssw  : PostriscBuiltinBinary<"_Vector<4, int>">;
def vsubusw  : PostriscBuiltinBinary<"_Vector<4, unsigned int>">;
def vmrghw   : PostriscBuiltinBinary<"_Vector<4, unsigned int>">;
def vmrglw   : PostriscBuiltinBinary<"_Vector<4, unsigned int>">;

///////////////////////////////////////////////////////////////////////////////////////
// int vector 8-byte
///////////////////////////////////////////////////////////////////////////////////////

def vaddcd   : PostriscBuiltinBinary<"_Vector<2, unsigned long long int>">;
def vaddod   : PostriscBuiltinBinary<"_Vector<2, long long int>">;
def vaddssd  : PostriscBuiltinBinary<"_Vector<2, long long int>">;
def vaddusd  : PostriscBuiltinBinary<"_Vector<2, unsigned long long int>">;
def vaddud   : PostriscBuiltinBinary<"_Vector<2, unsigned long long int>">;
def vavgud   : PostriscBuiltinBinary<"_Vector<2, unsigned long long int>">;
def vavgsd   : PostriscBuiltinBinary<"_Vector<2, long long int>">;
def vcmpeqd  : PostriscBuiltinBinary<"_Vector<2, long long int>">;
def vcmpltd  : PostriscBuiltinBinary<"_Vector<2, long long int>">;
def vcmpltud : PostriscBuiltinBinary<"_Vector<2, unsigned long long int>">;
def vmaxsd   : PostriscBuiltinBinary<"_Vector<2, long long int>">;
def vmaxud   : PostriscBuiltinBinary<"_Vector<2, unsigned long long int>">;
def vminsd   : PostriscBuiltinBinary<"_Vector<2, long long int>">;
def vminud   : PostriscBuiltinBinary<"_Vector<2, unsigned long long int>">;
def vrold    : PostriscBuiltinBinary<"_Vector<2, unsigned long long int>">;
def vrord    : PostriscBuiltinBinary<"_Vector<2, unsigned long long int>">;
def vslld    : PostriscBuiltinBinary<"_Vector<2, unsigned long long int>">;
def vsrad    : PostriscBuiltinBinary<"_Vector<2, long long int>">;
def vsrld    : PostriscBuiltinBinary<"_Vector<2, unsigned long long int>">;
def vsubbd   : PostriscBuiltinBinary<"_Vector<2, unsigned long long int>">;
def vsubod   : PostriscBuiltinBinary<"_Vector<2, long long int>">;
def vsubud   : PostriscBuiltinBinary<"_Vector<2, unsigned long long int>">;
def vsubssd  : PostriscBuiltinBinary<"_Vector<2, long long int>">;
def vsubusd  : PostriscBuiltinBinary<"_Vector<2, unsigned long long int>">;
def vmrghd   : PostriscBuiltinBinary<"_Vector<2, unsigned long long int>">;
def vmrgld   : PostriscBuiltinBinary<"_Vector<2, unsigned long long int>">;

///////////////////////////////////////////////////////////////////////////////////////
// int vector mixed
///////////////////////////////////////////////////////////////////////////////////////

def vpksssh : PostriscBuiltin<"_Vector<16, unsigned char>(_Vector<8, unsigned short>, _Vector<8, unsigned short>)">;
def vpksssw : PostriscBuiltin<"_Vector<8, unsigned short>(_Vector<4, unsigned int>, _Vector<4, unsigned int>)">;
def vpksssd : PostriscBuiltin<"_Vector<4, unsigned int>(_Vector<2, unsigned long long int>, _Vector<2, unsigned long long int>)">;
def vpksush : PostriscBuiltin<"_Vector<16, unsigned char>(_Vector<8, unsigned short>, _Vector<8, unsigned short>)">;
def vpksusw : PostriscBuiltin<"_Vector<8, unsigned short>(_Vector<4, unsigned int>, _Vector<4, unsigned int>)">;
def vpksusd : PostriscBuiltin<"_Vector<4, unsigned int>(_Vector<2, unsigned long long int>, _Vector<2, unsigned long long int>)">;
def vpkuumh : PostriscBuiltin<"_Vector<16, unsigned char>(_Vector<8, unsigned short>, _Vector<8, unsigned short>)">;
def vpkuumw : PostriscBuiltin<"_Vector<8, unsigned short>(_Vector<4, unsigned int>, _Vector<4, unsigned int>)">;
def vpkuumd : PostriscBuiltin<"_Vector<4, unsigned int>(_Vector<2, unsigned long long int>, _Vector<2, unsigned long long int>)">;
def vpkuush : PostriscBuiltin<"_Vector<16, unsigned char>(_Vector<8, unsigned short>, _Vector<8, unsigned short>)">;
def vpkuusw : PostriscBuiltin<"_Vector<8, unsigned short>(_Vector<4, unsigned int>, _Vector<4, unsigned int>)">;
def vpkuusd : PostriscBuiltin<"_Vector<4, unsigned int>(_Vector<2, unsigned long long int>, _Vector<2, unsigned long long int>)">;

def vupkhsb : PostriscBuiltin<"_Vector<8, unsigned short>(_Vector<16, unsigned char>)">;
def vupkhsh : PostriscBuiltin<"_Vector<4, unsigned int>(_Vector<8, unsigned short>)">;
def vupkhsw : PostriscBuiltin<"_Vector<2, unsigned long long int>(_Vector<4, unsigned int>)">;
def vupklsb : PostriscBuiltin<"_Vector<8, unsigned short>(_Vector<16, unsigned char>)">;
def vupklsh : PostriscBuiltin<"_Vector<4, unsigned int>(_Vector<8, unsigned short>)">;
def vupklsw : PostriscBuiltin<"_Vector<2, unsigned long long int>(_Vector<4, unsigned int>)">;
