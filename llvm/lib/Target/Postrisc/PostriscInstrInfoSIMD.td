//===---- PostriscInstrSIMD.td - Visual Instruction Set extensions (VIS) --===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains instruction formats, definitions and patterns needed for
// SIMD instructions on POSTRISC.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Feature predicates.
//===----------------------------------------------------------------------===//

// HasSIMD - This is true when the target processor has SIMD extensions.
def HasSIMD : Predicate<"Subtarget->HasSIMD()">,
             AssemblerPredicate<(all_of FeatureSIMD)>;

//===----------------------------------------------------------------------===//
// SIMD vector types are bit convertible to each other, f128, i128
//===----------------------------------------------------------------------===//
multiclass
vector_bitconversion<ValueType Ty, ValueType Ta>
{
  def : Pat<(Ty (bitconvert Ta:$val)),  (COPY_TO_REGCLASS $val, GR)>;
  def : Pat<(Ta (bitconvert Ty:$val)),  (COPY_TO_REGCLASS $val, GR)>;
}

defm : vector_bitconversion<v16i8, f128>;
defm : vector_bitconversion<v16i8, i128>;
defm : vector_bitconversion<v8i16, f128>;
defm : vector_bitconversion<v8i16, i128>;
defm : vector_bitconversion<v4i32, f128>;
defm : vector_bitconversion<v4i32, i128>;
defm : vector_bitconversion<v2i64, f128>;
defm : vector_bitconversion<v2i64, i128>;

defm : vector_bitconversion<v16i8, v8i16>;
defm : vector_bitconversion<v16i8, v4i32>;
defm : vector_bitconversion<v16i8, v2i64>;
defm : vector_bitconversion<v8i16, v4i32>;
defm : vector_bitconversion<v8i16, v2i64>;
defm : vector_bitconversion<v4i32, v2i64>;

defm : vector_bitconversion<v8i16, v8f16>;
defm : vector_bitconversion<v4i32, v4f32>;
defm : vector_bitconversion<v2i64, v2f64>;

//===----------------------------------------------------------------------===//
// SIMD vector types are bit convertible to corresponding scalars
//===----------------------------------------------------------------------===//
/*
def : Pat<(i64 (bitconvert v2i64:$val)), (COPY_TO_REGCLASS $val, GR)>;
def : Pat<(i32 (bitconvert v4i32:$val)), (COPY_TO_REGCLASS $val, GR)>;
def : Pat<(f64 (bitconvert v2f64:$val)), (COPY_TO_REGCLASS $val, GR)>;
def : Pat<(f32 (bitconvert v4f32:$val)), (COPY_TO_REGCLASS $val, GR)>;
*/

//===----------------------------------------------------------------------===//
// SIMD vector loads are ld16XXX
//===----------------------------------------------------------------------===//
defm : LdPat<"LDQ", load, v2f64>;
defm : LdPat<"LDQ", load, v4f32>;
defm : LdPat<"LDQ", load, v8f16>;
defm : LdPat<"LDQ", load, v16i8>;
defm : LdPat<"LDQ", load, v8i16>;
defm : LdPat<"LDQ", load, v4i32>;
defm : LdPat<"LDQ", load, v2i64>;

//===----------------------------------------------------------------------===//
// SIMD vector stores are st16XXX
//===----------------------------------------------------------------------===//
defm : StPat<"STQ", store, v8f16>;
defm : StPat<"STQ", store, v4f32>;
defm : StPat<"STQ", store, v2f64>;
defm : StPat<"STQ", store, v16i8>;
defm : StPat<"STQ", store, v8i16>;
defm : StPat<"STQ", store, v4i32>;
defm : StPat<"STQ", store, v2i64>;

//===----------------------------------------------------------------------===//
// SIMD select are SELECT
//===----------------------------------------------------------------------===//
def : Pat<(v8f16 (select i1:$rb, v8f16:$rc, v8f16:$rd)), (SELECT GR:$rb, GR:$rc, GR:$rd)>;
def : Pat<(v4f32 (select i1:$rb, v4f32:$rc, v4f32:$rd)), (SELECT GR:$rb, GR:$rc, GR:$rd)>;
def : Pat<(v2f64 (select i1:$rb, v2f64:$rc, v2f64:$rd)), (SELECT GR:$rb, GR:$rc, GR:$rd)>;
def : Pat<(v16i8 (select i1:$rb, v16i8:$rc, v16i8:$rd)), (SELECT GR:$rb, GR:$rc, GR:$rd)>;
def : Pat<(v8i16 (select i1:$rb, v8i16:$rc, v8i16:$rd)), (SELECT GR:$rb, GR:$rc, GR:$rd)>;
def : Pat<(v4i32 (select i1:$rb, v4i32:$rc, v4i32:$rd)), (SELECT GR:$rb, GR:$rc, GR:$rd)>;
def : Pat<(v2i64 (select i1:$rb, v2i64:$rc, v2i64:$rd)), (SELECT GR:$rb, GR:$rc, GR:$rd)>;

//===----------------------------------------------------------------------===//
// AES (v2i64)
//===----------------------------------------------------------------------===//
defm AESIMC     : BUILTIN_R2<misc_opx_aesimc,     "aesimc",     int_postrisc_aesimc,     v2i64, v2i64>;
defm AESENC     : BUILTIN_R3<misc_opx_aesenc,     "aesenc",     int_postrisc_aesenc,     v2i64, v2i64, v2i64>;
defm AESENCLAST : BUILTIN_R3<misc_opx_aesenclast, "aesenclast", int_postrisc_aesenclast, v2i64, v2i64, v2i64>;
defm AESDEC     : BUILTIN_R3<misc_opx_aesdec,     "aesdec",     int_postrisc_aesdec,     v2i64, v2i64, v2i64>;
defm AESDECLAST : BUILTIN_R3<misc_opx_aesdeclast, "aesdeclast", int_postrisc_aesdeclast, v2i64, v2i64, v2i64>;

def round_constant : Operand<i8>, TImmLeaf<i8, [{ return isInt<8>(Imm); }]> {
  let DecoderMethod = "DecodeSIMM<8>";
}
def AESKEYGENASSIST :
  MISC_RabI10<misc_opx_aeskeygenassist,
              (outs GR:$ra), (ins GR:$rb, round_constant:$imm),
              "aeskeygenassist\t$ra, $rb, $imm",
              [(set v2i64:$ra, (int_postrisc_aeskeygenassist v2i64:$rb, i8:$imm))]>;

//===----------------------------------------------------------------------===//
// hasing, carry-less multiply
//===----------------------------------------------------------------------===//

defm CLMULLL : BUILTIN_R3<misc_opx_clmulll, "clmulll", int_postrisc_clmulll, v2i64, v2i64, v2i64>;
defm CLMULHL : BUILTIN_R3<misc_opx_clmulhl, "clmulhl", int_postrisc_clmulhl, v2i64, v2i64, v2i64>;
defm CLMULHH : BUILTIN_R3<misc_opx_clmulhh, "clmulhh", int_postrisc_clmulhh, v2i64, v2i64, v2i64>;

defm CRC32C : BUILTIN_R4<fused_opx_crc32c, "crc32c", int_postrisc_crc32c, i32, i32, i128, i64>;

//===----------------------------------------------------------------------===//
// fp SIMD compute
//===----------------------------------------------------------------------===//

defm ph : FP_BASE_INTRUCTIONS<"ph", v8f16>;
defm ps : FP_BASE_INTRUCTIONS<"ps", v4f32>;
defm pd : FP_BASE_INTRUCTIONS<"pd", v2f64>;

// horizontal
defm FMULHPH  : BUILTIN_R3<misc_opx_fmulhph,   "fmulhph",  int_postrisc_fmulhph,  v8f16, v8f16, v8f16>;
defm FADDCPH  : BUILTIN_R3<misc_opx_faddcph,   "faddcph",  int_postrisc_faddcph,  v8f16, v8f16, v8f16>;
defm FADDHPH  : BUILTIN_R3<misc_opx_faddhph,   "faddhph",  int_postrisc_faddhph,  v8f16, v8f16, v8f16>;
defm FSUBCPH  : BUILTIN_R3<misc_opx_fsubcph,   "fsubcph",  int_postrisc_fsubcph,  v8f16, v8f16, v8f16>;
defm FSUBHPH  : BUILTIN_R3<misc_opx_fsubhph,   "fsubhph",  int_postrisc_fsubhph,  v8f16, v8f16, v8f16>;

// horizontal
defm FMULHPS  : BUILTIN_R3<misc_opx_fmulhps,   "fmulhps",  int_postrisc_fmulhps,  v4f32, v4f32, v4f32>;
defm FADDCPS  : BUILTIN_R3<misc_opx_faddcps,   "faddcps",  int_postrisc_faddcps,  v4f32, v4f32, v4f32>;
defm FADDHPS  : BUILTIN_R3<misc_opx_faddhps,   "faddhps",  int_postrisc_faddhps,  v4f32, v4f32, v4f32>;
defm FSUBCPS  : BUILTIN_R3<misc_opx_fsubcps,   "fsubcps",  int_postrisc_fsubcps,  v4f32, v4f32, v4f32>;
defm FSUBHPS  : BUILTIN_R3<misc_opx_fsubhps,   "fsubhps",  int_postrisc_fsubhps,  v4f32, v4f32, v4f32>;

// horizontal
defm FADDCPD  : BUILTIN_R3<misc_opx_faddcpd,   "faddcpd",  int_postrisc_faddcpd,  v2f64, v2f64, v2f64>;
defm FADDHPD  : BUILTIN_R3<misc_opx_faddhpd,   "faddhpd",  int_postrisc_faddhpd,  v2f64, v2f64, v2f64>;
defm FMULHPD  : BUILTIN_R3<misc_opx_fmulhpd,   "fmulhpd",  int_postrisc_fmulhpd,  v2f64, v2f64, v2f64>;
defm FSUBCPD  : BUILTIN_R3<misc_opx_fsubcpd,   "fsubcpd",  int_postrisc_fsubcpd,  v2f64, v2f64, v2f64>;
defm FSUBHPD  : BUILTIN_R3<misc_opx_fsubhpd,   "fsubhpd",  int_postrisc_fsubhpd,  v2f64, v2f64, v2f64>;

//===----------------------------------------------------------------------===//
// FMA postrisc intrinsics int_postrisc_fma_ps/int_postrisc_fma_pd
//===----------------------------------------------------------------------===//

multiclass
IntrinsicPostriscFma<ClangBuiltin Op,
  InstBase FMA, InstBase FNMA, InstBase FMS, InstBase FNMS, ValueType Ty>
{
  def : Pat<(      Op       Ty:$a ,       Ty:$b,        Ty:$c) , (FMA  GR:$a, GR:$b, GR:$c)>;
  def : Pat<(      Op       Ty:$a ,       Ty:$b,  (fneg Ty:$c)), (FMS  GR:$a, GR:$b, GR:$c)>;
  def : Pat<(      Op (fneg Ty:$a),       Ty:$b,        Ty:$c) , (FNMA GR:$a, GR:$b, GR:$c)>;
  def : Pat<(      Op       Ty:$a , (fneg Ty:$b),       Ty:$c) , (FNMA GR:$a, GR:$b, GR:$c)>;
  def : Pat<(fneg (Op       Ty:$a ,       Ty:$b,        Ty:$c)), (FNMS GR:$a, GR:$b, GR:$c)>;
  def : Pat<(      Op (fneg Ty:$a),       Ty:$b,  (fneg Ty:$c)), (FNMS GR:$a, GR:$b, GR:$c)>;
  def : Pat<(      Op       Ty:$a , (fneg Ty:$b), (fneg Ty:$c)), (FNMS GR:$a, GR:$b, GR:$c)>;
}

//defm : IntrinsicPostriscFma<int_postrisc_fma_ps, FMADDPS, FNMADDPS, FMSUBPS, FNMSUBPS, v4f32>;
//defm : IntrinsicPostriscFma<int_postrisc_fma_pd, FMADDPD, FNMADDPD, FMSUBPD, FNMSUBPD, v2f64>;

//===----------------------------------------------------------------------===//
// add/sub
//===----------------------------------------------------------------------===//
defm VADDUB   : BUILTIN_R3<misc_opx_vaddub, "vaddub", int_postrisc_vaddub, v16i8, v16i8, v16i8>;
defm VADDUH   : BUILTIN_R3<misc_opx_vadduh, "vadduh", int_postrisc_vadduh, v8i16, v8i16, v8i16>;
defm VADDUW   : BUILTIN_R3<misc_opx_vadduw, "vadduw", int_postrisc_vadduw, v4i32, v4i32, v4i32>;
defm VADDUD   : BUILTIN_R3<misc_opx_vaddud, "vaddud", int_postrisc_vaddud, v2i64, v2i64, v2i64>;

//===----------------------------------------------------------------------===//
// overflow signed add/sub
//===----------------------------------------------------------------------===//
defm VADDOB   : BUILTIN_R3<misc_opx_vaddob, "vaddob", int_postrisc_vaddob, v16i8, v16i8, v16i8>;
defm VADDOH   : BUILTIN_R3<misc_opx_vaddoh, "vaddoh", int_postrisc_vaddoh, v8i16, v8i16, v8i16>;
defm VADDOW   : BUILTIN_R3<misc_opx_vaddow, "vaddow", int_postrisc_vaddow, v4i32, v4i32, v4i32>;
defm VADDOD   : BUILTIN_R3<misc_opx_vaddod, "vaddod", int_postrisc_vaddod, v2i64, v2i64, v2i64>;

defm VSUBOB   : BUILTIN_R3<misc_opx_vsubob, "vsubob", int_postrisc_vsubob, v16i8, v16i8, v16i8>;
defm VSUBOH   : BUILTIN_R3<misc_opx_vsuboh, "vsuboh", int_postrisc_vsuboh, v8i16, v8i16, v8i16>;
defm VSUBOW   : BUILTIN_R3<misc_opx_vsubow, "vsubow", int_postrisc_vsubow, v4i32, v4i32, v4i32>;
defm VSUBOD   : BUILTIN_R3<misc_opx_vsubod, "vsubod", int_postrisc_vsubod, v2i64, v2i64, v2i64>;

//===----------------------------------------------------------------------===//
// carry/borrow unsigned add/sub
//===----------------------------------------------------------------------===//
defm VADDCB   : BUILTIN_R3<misc_opx_vaddcb, "vaddcb", int_postrisc_vaddcb, v16i8, v16i8, v16i8>;
defm VADDCH   : BUILTIN_R3<misc_opx_vaddch, "vaddch", int_postrisc_vaddch, v8i16, v8i16, v8i16>;
defm VADDCW   : BUILTIN_R3<misc_opx_vaddcw, "vaddcw", int_postrisc_vaddcw, v4i32, v4i32, v4i32>;
defm VADDCD   : BUILTIN_R3<misc_opx_vaddcd, "vaddcd", int_postrisc_vaddcd, v2i64, v2i64, v2i64>;

defm VSUBBB   : BUILTIN_R3<misc_opx_vsubbb, "vsubbb", int_postrisc_vsubbb, v16i8, v16i8, v16i8>;
defm VSUBBH   : BUILTIN_R3<misc_opx_vsubbh, "vsubbh", int_postrisc_vsubbh, v8i16, v8i16, v8i16>;
defm VSUBBW   : BUILTIN_R3<misc_opx_vsubbw, "vsubbw", int_postrisc_vsubbw, v4i32, v4i32, v4i32>;
defm VSUBBD   : BUILTIN_R3<misc_opx_vsubbd, "vsubbd", int_postrisc_vsubbd, v2i64, v2i64, v2i64>;

//===----------------------------------------------------------------------===//
// saturated signed/unsigned add/sub
//===----------------------------------------------------------------------===//
defm VADDSSB  : BUILTIN_R3<misc_opx_vaddssb, "vaddssb", int_postrisc_vaddssb, v16i8, v16i8, v16i8>;
defm VADDSSH  : BUILTIN_R3<misc_opx_vaddssh, "vaddssh", int_postrisc_vaddssh, v8i16, v8i16, v8i16>;
defm VADDSSW  : BUILTIN_R3<misc_opx_vaddssw, "vaddssw", int_postrisc_vaddssw, v4i32, v4i32, v4i32>;
defm VADDSSD  : BUILTIN_R3<misc_opx_vaddssd, "vaddssd", int_postrisc_vaddssd, v2i64, v2i64, v2i64>;

defm VADDUSB  : BUILTIN_R3<misc_opx_vaddusb, "vaddusb", int_postrisc_vaddusb, v16i8, v16i8, v16i8>;
defm VADDUSH  : BUILTIN_R3<misc_opx_vaddush, "vaddush", int_postrisc_vaddush, v8i16, v8i16, v8i16>;
defm VADDUSW  : BUILTIN_R3<misc_opx_vaddusw, "vaddusw", int_postrisc_vaddusw, v4i32, v4i32, v4i32>;
defm VADDUSD  : BUILTIN_R3<misc_opx_vaddusd, "vaddusd", int_postrisc_vaddusd, v2i64, v2i64, v2i64>;

defm VSUBSSB  : BUILTIN_R3<misc_opx_vsubssb, "vsubssb", int_postrisc_vsubssb, v16i8, v16i8, v16i8>;
defm VSUBSSH  : BUILTIN_R3<misc_opx_vsubssh, "vsubssh", int_postrisc_vsubssh, v8i16, v8i16, v8i16>;
defm VSUBSSW  : BUILTIN_R3<misc_opx_vsubssw, "vsubssw", int_postrisc_vsubssw, v4i32, v4i32, v4i32>;
defm VSUBSSD  : BUILTIN_R3<misc_opx_vsubssd, "vsubssd", int_postrisc_vsubssd, v2i64, v2i64, v2i64>;

defm VSUBUSB  : BUILTIN_R3<misc_opx_vsubusb, "vsubusb", int_postrisc_vsubusb, v16i8, v16i8, v16i8>;
defm VSUBUSH  : BUILTIN_R3<misc_opx_vsubush, "vsubush", int_postrisc_vsubush, v8i16, v8i16, v8i16>;
defm VSUBUSW  : BUILTIN_R3<misc_opx_vsubusw, "vsubusw", int_postrisc_vsubusw, v4i32, v4i32, v4i32>;
defm VSUBUSD  : BUILTIN_R3<misc_opx_vsubusd, "vsubusd", int_postrisc_vsubusd, v2i64, v2i64, v2i64>;

//===----------------------------------------------------------------------===//
// compare
//===-----------------------------------------------h----------------------===//
defm VCMPEQB  : BUILTIN_R3<misc_opx_vcmpeqb, "vcmpeqb", int_postrisc_vcmpeqb, v16i8, v16i8, v16i8>;
defm VCMPEQH  : BUILTIN_R3<misc_opx_vcmpeqh, "vcmpeqh", int_postrisc_vcmpeqh, v8i16, v8i16, v8i16>;
defm VCMPEQW  : BUILTIN_R3<misc_opx_vcmpeqw, "vcmpeqw", int_postrisc_vcmpeqw, v4i32, v4i32, v4i32>;
defm VCMPEQD  : BUILTIN_R3<misc_opx_vcmpeqd, "vcmpeqd", int_postrisc_vcmpeqd, v2i64, v2i64, v2i64>;

defm VCMPLTB  : BUILTIN_R3<misc_opx_vcmpltb, "vcmpltb", int_postrisc_vcmpltb, v16i8, v16i8, v16i8>;
defm VCMPLTH  : BUILTIN_R3<misc_opx_vcmplth, "vcmplth", int_postrisc_vcmplth, v8i16, v8i16, v8i16>;
defm VCMPLTW  : BUILTIN_R3<misc_opx_vcmpltw, "vcmpltw", int_postrisc_vcmpltw, v4i32, v4i32, v4i32>;
defm VCMPLTD  : BUILTIN_R3<misc_opx_vcmpltd, "vcmpltd", int_postrisc_vcmpltd, v2i64, v2i64, v2i64>;

defm VCMPLTUB : BUILTIN_R3<misc_opx_vcmpltub, "vcmpltub", int_postrisc_vcmpltub, v16i8, v16i8, v16i8>;
defm VCMPLTUH : BUILTIN_R3<misc_opx_vcmpltuh, "vcmpltuh", int_postrisc_vcmpltuh, v8i16, v8i16, v8i16>;
defm VCMPLTUW : BUILTIN_R3<misc_opx_vcmpltuw, "vcmpltuw", int_postrisc_vcmpltuw, v4i32, v4i32, v4i32>;
defm VCMPLTUD : BUILTIN_R3<misc_opx_vcmpltud, "vcmpltud", int_postrisc_vcmpltud, v2i64, v2i64, v2i64>;

//===----------------------------------------------------------------------===//
// signed/unsigned average
//===----------------------------------------------------------------------===//
defm VAVGUB   : BUILTIN_R3<misc_opx_vavgub, "vavgub", int_postrisc_vavgub, v16i8, v16i8, v16i8>;
defm VAVGUH   : BUILTIN_R3<misc_opx_vavguh, "vavguh", int_postrisc_vavguh, v8i16, v8i16, v8i16>;
defm VAVGUW   : BUILTIN_R3<misc_opx_vavguw, "vavguw", int_postrisc_vavguw, v4i32, v4i32, v4i32>;
defm VAVGUD   : BUILTIN_R3<misc_opx_vavgud, "vavgud", int_postrisc_vavgud, v2i64, v2i64, v2i64>;

defm VAVGSB   : BUILTIN_R3<misc_opx_vavgsb, "vavgsb", int_postrisc_vavgsb, v16i8, v16i8, v16i8>;
defm VAVGSH   : BUILTIN_R3<misc_opx_vavgsh, "vavgsh", int_postrisc_vavgsh, v8i16, v8i16, v8i16>;
defm VAVGSW   : BUILTIN_R3<misc_opx_vavgsw, "vavgsw", int_postrisc_vavgsw, v4i32, v4i32, v4i32>;
defm VAVGSD   : BUILTIN_R3<misc_opx_vavgsd, "vavgsd", int_postrisc_vavgsd, v2i64, v2i64, v2i64>;

//===----------------------------------------------------------------------===//
// shifts/rotates
//===----------------------------------------------------------------------===//
defm VROLB    : BUILTIN_R3<misc_opx_vrolb, "vrolb", int_postrisc_vrolb, v16i8, v16i8, v16i8>;
defm VROLH    : BUILTIN_R3<misc_opx_vrolh, "vrolh", int_postrisc_vrolh, v8i16, v8i16, v8i16>;
defm VROLW    : BUILTIN_R3<misc_opx_vrolw, "vrolw", int_postrisc_vrolw, v4i32, v4i32, v4i32>;
defm VROLD    : BUILTIN_R3<misc_opx_vrold, "vrold", int_postrisc_vrold, v2i64, v2i64, v2i64>;

defm VRORB    : BUILTIN_R3<misc_opx_vrorb, "vrorb", int_postrisc_vrorb, v16i8, v16i8, v16i8>;
defm VRORH    : BUILTIN_R3<misc_opx_vrorh, "vrorh", int_postrisc_vrorh, v8i16, v8i16, v8i16>;
defm VRORW    : BUILTIN_R3<misc_opx_vrorw, "vrorw", int_postrisc_vrorw, v4i32, v4i32, v4i32>;
defm VRORD    : BUILTIN_R3<misc_opx_vrord, "vrord", int_postrisc_vrord, v2i64, v2i64, v2i64>;

defm VSLL1    : BUILTIN_R3<misc_opx_vsllb, "vsllb", int_postrisc_vsllb, v16i8, v16i8, v16i8>;
defm VSLL2    : BUILTIN_R3<misc_opx_vsllh, "vsllh", int_postrisc_vsllh, v8i16, v8i16, v8i16>;
defm VSLL4    : BUILTIN_R3<misc_opx_vsllw, "vsllw", int_postrisc_vsllw, v4i32, v4i32, v4i32>;
defm VSLL8    : BUILTIN_R3<misc_opx_vslld, "vslld", int_postrisc_vslld, v2i64, v2i64, v2i64>;

defm VSRAB    : BUILTIN_R3<misc_opx_vsrab, "vsrab", int_postrisc_vsrab, v16i8, v16i8, v16i8>;
defm VSRAH    : BUILTIN_R3<misc_opx_vsrah, "vsrah", int_postrisc_vsrah, v8i16, v8i16, v8i16>;
defm VSRAW    : BUILTIN_R3<misc_opx_vsraw, "vsraw", int_postrisc_vsraw, v4i32, v4i32, v4i32>;
defm VSRAD    : BUILTIN_R3<misc_opx_vsrad, "vsrad", int_postrisc_vsrad, v2i64, v2i64, v2i64>;

defm VSRLB    : BUILTIN_R3<misc_opx_vsrlb, "vsrlb", int_postrisc_vsrlb, v16i8, v16i8, v16i8>;
defm VSRLH    : BUILTIN_R3<misc_opx_vsrlh, "vsrlh", int_postrisc_vsrlh, v8i16, v8i16, v8i16>;
defm VSRLW    : BUILTIN_R3<misc_opx_vsrlw, "vsrlw", int_postrisc_vsrlw, v4i32, v4i32, v4i32>;
defm VSRLD    : BUILTIN_R3<misc_opx_vsrld, "vsrld", int_postrisc_vsrld, v2i64, v2i64, v2i64>;

//===----------------------------------------------------------------------===//
// signed/unsigned min/max
//===----------------------------------------------------------------------===//
defm VSUBUB   : BUILTIN_R3<misc_opx_vsubub,  "vsubub",  int_postrisc_vsubub, v16i8, v16i8, v16i8>;
defm VSUBUH   : BUILTIN_R3<misc_opx_vsubuh,  "vsubuh",  int_postrisc_vsubuh, v8i16, v8i16, v8i16>;
defm VSUBUW   : BUILTIN_R3<misc_opx_vsubuw,  "vsubuw",  int_postrisc_vsubuw, v4i32, v4i32, v4i32>;
defm VSUBUD   : BUILTIN_R3<misc_opx_vsubud,  "vsubud",  int_postrisc_vsubud, v2i64, v2i64, v2i64>;

defm VMAXSB   : BUILTIN_R3<misc_opx_vmaxsb,  "vmaxsb",  int_postrisc_vmaxsb, v16i8, v16i8, v16i8>;
defm VMAXSH   : BUILTIN_R3<misc_opx_vmaxsh,  "vmaxsh",  int_postrisc_vmaxsh, v8i16, v8i16, v8i16>;
defm VMAXSW   : BUILTIN_R3<misc_opx_vmaxsw,  "vmaxsw",  int_postrisc_vmaxsw, v4i32, v4i32, v4i32>;
defm VMAXSD   : BUILTIN_R3<misc_opx_vmaxsd,  "vmaxsd",  int_postrisc_vmaxsd, v2i64, v2i64, v2i64>;

defm VMAXUB   : BUILTIN_R3<misc_opx_vmaxub,  "vmaxub",  int_postrisc_vmaxub, v16i8, v16i8, v16i8>;
defm VMAXUH   : BUILTIN_R3<misc_opx_vmaxuh,  "vmaxuh",  int_postrisc_vmaxuh, v8i16, v8i16, v8i16>;
defm VMAXUW   : BUILTIN_R3<misc_opx_vmaxuw,  "vmaxuw",  int_postrisc_vmaxuw, v4i32, v4i32, v4i32>;
defm VMAXUD   : BUILTIN_R3<misc_opx_vmaxud,  "vmaxud",  int_postrisc_vmaxud, v2i64, v2i64, v2i64>;

defm VMINSB   : BUILTIN_R3<misc_opx_vminsb,  "vminsb",  int_postrisc_vminsb, v16i8, v16i8, v16i8>;
defm VMINSH   : BUILTIN_R3<misc_opx_vminsh,  "vminsh",  int_postrisc_vminsh, v8i16, v8i16, v8i16>;
defm VMINSW   : BUILTIN_R3<misc_opx_vminsw,  "vminsw",  int_postrisc_vminsw, v4i32, v4i32, v4i32>;
defm VMINSD   : BUILTIN_R3<misc_opx_vminsd,  "vminsd",  int_postrisc_vminsd, v2i64, v2i64, v2i64>;

defm VMINUB   : BUILTIN_R3<misc_opx_vminub,  "vminub",  int_postrisc_vminub, v16i8, v16i8, v16i8>;
defm VMINUH   : BUILTIN_R3<misc_opx_vminuh,  "vminuh",  int_postrisc_vminuh, v8i16, v8i16, v8i16>;
defm VMINUW   : BUILTIN_R3<misc_opx_vminuw,  "vminuw",  int_postrisc_vminuw, v4i32, v4i32, v4i32>;
defm VMINUD   : BUILTIN_R3<misc_opx_vminud,  "vminud",  int_postrisc_vminud, v2i64, v2i64, v2i64>;

defm VMRGHB   : BUILTIN_R3<misc_opx_vmrghb,  "vmrghb",  int_postrisc_vmrghb, v16i8, v16i8, v16i8>;
defm VMRGLB   : BUILTIN_R3<misc_opx_vmrglb,  "vmrglb",  int_postrisc_vmrglb, v16i8, v16i8, v16i8>;
defm VMRGHH   : BUILTIN_R3<misc_opx_vmrghh,  "vmrghh",  int_postrisc_vmrghh, v8i16, v8i16, v8i16>;
defm VMRGLH   : BUILTIN_R3<misc_opx_vmrglh,  "vmrglh",  int_postrisc_vmrglh, v8i16, v8i16, v8i16>;
defm VMRGHW   : BUILTIN_R3<misc_opx_vmrghw,  "vmrghw",  int_postrisc_vmrghw, v4i32, v4i32, v4i32>;
defm VMRGLW   : BUILTIN_R3<misc_opx_vmrglw,  "vmrglw",  int_postrisc_vmrglw, v4i32, v4i32, v4i32>;
defm VMRGHD   : BUILTIN_R3<misc_opx_vmrghd,  "vmrghd",  int_postrisc_vmrghd, v2i64, v2i64, v2i64>;
defm VMRGLD   : BUILTIN_R3<misc_opx_vmrgld,  "vmrgld",  int_postrisc_vmrgld, v2i64, v2i64, v2i64>;

defm VPKSSSH  : BUILTIN_R3<misc_opx_vpksssh, "vpksssh", int_postrisc_vpksssh, v16i8, v8i16, v8i16>;
defm VPKSSSW  : BUILTIN_R3<misc_opx_vpksssw, "vpksssw", int_postrisc_vpksssw, v8i16, v4i32, v4i32>;
defm VPKSSSD  : BUILTIN_R3<misc_opx_vpksssd, "vpksssd", int_postrisc_vpksssd, v4i32, v2i64, v2i64>;
defm VPKSUSH  : BUILTIN_R3<misc_opx_vpksush, "vpksush", int_postrisc_vpksush, v16i8, v8i16, v8i16>;
defm VPKSUSW  : BUILTIN_R3<misc_opx_vpksusw, "vpksusw", int_postrisc_vpksusw, v8i16, v4i32, v4i32>;
defm VPKSUSD  : BUILTIN_R3<misc_opx_vpksusd, "vpksusd", int_postrisc_vpksusd, v4i32, v2i64, v2i64>;
defm VPKUUMH  : BUILTIN_R3<misc_opx_vpkuumh, "vpkuumh", int_postrisc_vpkuumh, v16i8, v8i16, v8i16>;
defm VPKUUMW  : BUILTIN_R3<misc_opx_vpkuumw, "vpkuumw", int_postrisc_vpkuumw, v8i16, v4i32, v4i32>;
defm VPKUUMD  : BUILTIN_R3<misc_opx_vpkuumd, "vpkuumd", int_postrisc_vpkuumd, v4i32, v2i64, v2i64>;
defm VPKUUSH  : BUILTIN_R3<misc_opx_vpkuush, "vpkuush", int_postrisc_vpkuush, v16i8, v8i16, v8i16>;
defm VPKUUSW  : BUILTIN_R3<misc_opx_vpkuusw, "vpkuusw", int_postrisc_vpkuusw, v8i16, v4i32, v4i32>;
defm VPKUUSD  : BUILTIN_R3<misc_opx_vpkuusd, "vpkuusd", int_postrisc_vpkuusd, v4i32, v2i64, v2i64>;

defm VUPKHSB  : BUILTIN_R2<misc_opx_vupkhsb, "vupkhsb", int_postrisc_vupkhsb, v8i16, v16i8>;
defm VUPKHSH  : BUILTIN_R2<misc_opx_vupkhsh, "vupkhsh", int_postrisc_vupkhsh, v4i32, v8i16>;
defm VUPKHSW  : BUILTIN_R2<misc_opx_vupkhsw, "vupkhsw", int_postrisc_vupkhsw, v2i64, v4i32>;
defm VUPKLSB  : BUILTIN_R2<misc_opx_vupklsb, "vupklsb", int_postrisc_vupklsb, v8i16, v16i8>;
defm VUPKLSH  : BUILTIN_R2<misc_opx_vupklsh, "vupklsh", int_postrisc_vupklsh, v4i32, v8i16>;
defm VUPKLSW  : BUILTIN_R2<misc_opx_vupklsw, "vupklsw", int_postrisc_vupklsw, v2i64, v4i32>;
