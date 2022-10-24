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
// AES (v2i64)
//===----------------------------------------------------------------------===//
defm AES_IMC      : BUILTIN_R2<misc_opx_aes_imc,      int_postrisc_aesimc,     v2i64, v2i64>;
defm AES_ENC      : BUILTIN_R3<misc_opx_aes_enc,      int_postrisc_aesenc,     v2i64, v2i64, v2i64>;
defm AES_ENC_LAST : BUILTIN_R3<misc_opx_aes_enc_last, int_postrisc_aesenclast, v2i64, v2i64, v2i64>;
defm AES_DEC      : BUILTIN_R3<misc_opx_aes_dec,      int_postrisc_aesdec,     v2i64, v2i64, v2i64>;
defm AES_DEC_LAST : BUILTIN_R3<misc_opx_aes_dec_last, int_postrisc_aesdeclast, v2i64, v2i64, v2i64>;

def round_constant : Operand<i8>, TImmLeaf<i8, [{ return isInt<8>(Imm); }]> {
  let DecoderMethod = "DecodeSIMM<8>";
}
def AES_KEYGEN_ASSIST :
  MISC_RabI10<misc_opx_aes_keygen_assist,
              (outs GR:$ra), (ins GR:$rb, round_constant:$imm),
              "aeskeygenassist\t$ra, $rb, $imm",
              [(set v2i64:$ra, (int_postrisc_aeskeygenassist v2i64:$rb, i8:$imm))]>;

//===----------------------------------------------------------------------===//
// hasing, carry-less multiply
//===----------------------------------------------------------------------===//

defm CLMUL_LL : BUILTIN_R3<misc_opx_clmulll, int_postrisc_clmulll, v2i64, v2i64, v2i64>;
defm CLMUL_HL : BUILTIN_R3<misc_opx_clmulhl, int_postrisc_clmulhl, v2i64, v2i64, v2i64>;
defm CLMUL_HH : BUILTIN_R3<misc_opx_clmulhh, int_postrisc_clmulhh, v2i64, v2i64, v2i64>;

defm CRC32C : BUILTIN_R4<fused_opx_crc32c, int_postrisc_crc32c, i32, i32, i128, i64>;

//===----------------------------------------------------------------------===//
// fp SIMD compute
//===----------------------------------------------------------------------===//

defm PH : FP_BASE_INTRUCTIONS<"ph", v8f16>;
defm PS : FP_BASE_INTRUCTIONS<"ps", v4f32>;
defm PD : FP_BASE_INTRUCTIONS<"pd", v2f64>;

// horizontal
defm FMULH_PH : BUILTIN_R3<misc_opx_fmulh_ph, int_postrisc_fmulhph,  v8f16, v8f16, v8f16>;
defm FADDC_PH : BUILTIN_R3<misc_opx_faddc_ph, int_postrisc_faddcph,  v8f16, v8f16, v8f16>;
defm FADDH_PH : BUILTIN_R3<misc_opx_faddh_ph, int_postrisc_faddhph,  v8f16, v8f16, v8f16>;
defm FSUBC_PH : BUILTIN_R3<misc_opx_fsubc_ph, int_postrisc_fsubcph,  v8f16, v8f16, v8f16>;
defm FSUBH_PH : BUILTIN_R3<misc_opx_fsubh_ph, int_postrisc_fsubhph,  v8f16, v8f16, v8f16>;

// horizontal
defm FMULH_PS : BUILTIN_R3<misc_opx_fmulh_ps, int_postrisc_fmulhps,  v4f32, v4f32, v4f32>;
defm FADDC_PS : BUILTIN_R3<misc_opx_faddc_ps, int_postrisc_faddcps,  v4f32, v4f32, v4f32>;
defm FADDH_PS : BUILTIN_R3<misc_opx_faddh_ps, int_postrisc_faddhps,  v4f32, v4f32, v4f32>;
defm FSUBC_PS : BUILTIN_R3<misc_opx_fsubc_ps, int_postrisc_fsubcps,  v4f32, v4f32, v4f32>;
defm FSUBH_PS : BUILTIN_R3<misc_opx_fsubh_ps, int_postrisc_fsubhps,  v4f32, v4f32, v4f32>;

// horizontal
defm FADDC_PD : BUILTIN_R3<misc_opx_faddc_pd, int_postrisc_faddcpd,  v2f64, v2f64, v2f64>;
defm FADDH_PD : BUILTIN_R3<misc_opx_faddh_pd, int_postrisc_faddhpd,  v2f64, v2f64, v2f64>;
defm FMULH_PD : BUILTIN_R3<misc_opx_fmulh_pd, int_postrisc_fmulhpd,  v2f64, v2f64, v2f64>;
defm FSUBC_PD : BUILTIN_R3<misc_opx_fsubc_pd, int_postrisc_fsubcpd,  v2f64, v2f64, v2f64>;
defm FSUBH_PD : BUILTIN_R3<misc_opx_fsubh_pd, int_postrisc_fsubhpd,  v2f64, v2f64, v2f64>;

//===----------------------------------------------------------------------===//
// FMA postrisc intrinsics int_postrisc_fma_p[h|s|d]
//===----------------------------------------------------------------------===//
multiclass IntrinsicPostriscFma<ClangBuiltin Op, InstBase FMA, InstBase FNMA, InstBase FMS, InstBase FNMS, ValueType Ty>
{
  def : Pat<(      Op       Ty:$a ,       Ty:$b,        Ty:$c) , (FMA  GR:$a, GR:$b, GR:$c)>;
  def : Pat<(      Op       Ty:$a ,       Ty:$b,  (fneg Ty:$c)), (FMS  GR:$a, GR:$b, GR:$c)>;
  def : Pat<(      Op (fneg Ty:$a),       Ty:$b,        Ty:$c) , (FNMA GR:$a, GR:$b, GR:$c)>;
  def : Pat<(      Op       Ty:$a , (fneg Ty:$b),       Ty:$c) , (FNMA GR:$a, GR:$b, GR:$c)>;
  def : Pat<(fneg (Op       Ty:$a ,       Ty:$b,        Ty:$c)), (FNMS GR:$a, GR:$b, GR:$c)>;
  def : Pat<(      Op (fneg Ty:$a),       Ty:$b,  (fneg Ty:$c)), (FNMS GR:$a, GR:$b, GR:$c)>;
  def : Pat<(      Op       Ty:$a , (fneg Ty:$b), (fneg Ty:$c)), (FNMS GR:$a, GR:$b, GR:$c)>;
}

defm : IntrinsicPostriscFma<int_postrisc_fma_ph, FMADD_PH, FNMADD_PH, FMSUB_PH, FNMSUB_PH, v8f16>;
defm : IntrinsicPostriscFma<int_postrisc_fma_ps, FMADD_PS, FNMADD_PS, FMSUB_PS, FNMSUB_PS, v4f32>;
defm : IntrinsicPostriscFma<int_postrisc_fma_pd, FMADD_PD, FNMADD_PD, FMSUB_PD, FNMSUB_PD, v2f64>;

//===----------------------------------------------------------------------===//
// add/sub
//===----------------------------------------------------------------------===//
defm VADDUB : BUILTIN_R3<misc_opx_vaddu_b, int_postrisc_vaddub, v16i8, v16i8, v16i8>;
defm VADDUH : BUILTIN_R3<misc_opx_vaddu_h, int_postrisc_vadduh, v8i16, v8i16, v8i16>;
defm VADDUW : BUILTIN_R3<misc_opx_vaddu_w, int_postrisc_vadduw, v4i32, v4i32, v4i32>;
defm VADDUD : BUILTIN_R3<misc_opx_vaddu_d, int_postrisc_vaddud, v2i64, v2i64, v2i64>;

//===----------------------------------------------------------------------===//
// overflow signed add/sub
//===----------------------------------------------------------------------===//
defm VADDOB : BUILTIN_R3<misc_opx_vaddo_b, int_postrisc_vaddob, v16i8, v16i8, v16i8>;
defm VADDOH : BUILTIN_R3<misc_opx_vaddo_h, int_postrisc_vaddoh, v8i16, v8i16, v8i16>;
defm VADDOW : BUILTIN_R3<misc_opx_vaddo_w, int_postrisc_vaddow, v4i32, v4i32, v4i32>;
defm VADDOD : BUILTIN_R3<misc_opx_vaddo_d, int_postrisc_vaddod, v2i64, v2i64, v2i64>;

defm VSUBOB : BUILTIN_R3<misc_opx_vsubo_b, int_postrisc_vsubob, v16i8, v16i8, v16i8>;
defm VSUBOH : BUILTIN_R3<misc_opx_vsubo_h, int_postrisc_vsuboh, v8i16, v8i16, v8i16>;
defm VSUBOW : BUILTIN_R3<misc_opx_vsubo_w, int_postrisc_vsubow, v4i32, v4i32, v4i32>;
defm VSUBOD : BUILTIN_R3<misc_opx_vsubo_d, int_postrisc_vsubod, v2i64, v2i64, v2i64>;

//===----------------------------------------------------------------------===//
// carry/borrow unsigned add/sub
//===----------------------------------------------------------------------===//
defm VADDCB : BUILTIN_R3<misc_opx_vaddc_b, int_postrisc_vaddcb, v16i8, v16i8, v16i8>;
defm VADDCH : BUILTIN_R3<misc_opx_vaddc_h, int_postrisc_vaddch, v8i16, v8i16, v8i16>;
defm VADDCW : BUILTIN_R3<misc_opx_vaddc_w, int_postrisc_vaddcw, v4i32, v4i32, v4i32>;
defm VADDCD : BUILTIN_R3<misc_opx_vaddc_d, int_postrisc_vaddcd, v2i64, v2i64, v2i64>;

defm VSUBBB : BUILTIN_R3<misc_opx_vsubb_b, int_postrisc_vsubbb, v16i8, v16i8, v16i8>;
defm VSUBBH : BUILTIN_R3<misc_opx_vsubb_h, int_postrisc_vsubbh, v8i16, v8i16, v8i16>;
defm VSUBBW : BUILTIN_R3<misc_opx_vsubb_w, int_postrisc_vsubbw, v4i32, v4i32, v4i32>;
defm VSUBBD : BUILTIN_R3<misc_opx_vsubb_d, int_postrisc_vsubbd, v2i64, v2i64, v2i64>;

defm VSUBUB : BUILTIN_R3<misc_opx_vsubu_b, int_postrisc_vsubub, v16i8, v16i8, v16i8>;
defm VSUBUH : BUILTIN_R3<misc_opx_vsubu_h, int_postrisc_vsubuh, v8i16, v8i16, v8i16>;
defm VSUBUW : BUILTIN_R3<misc_opx_vsubu_w, int_postrisc_vsubuw, v4i32, v4i32, v4i32>;
defm VSUBUD : BUILTIN_R3<misc_opx_vsubu_d, int_postrisc_vsubud, v2i64, v2i64, v2i64>;

//===----------------------------------------------------------------------===//
// saturated signed/unsigned add/sub
//===----------------------------------------------------------------------===//
defm VADDSSB : BUILTIN_R3<misc_opx_vaddss_b, int_postrisc_vaddssb, v16i8, v16i8, v16i8>;
defm VADDSSH : BUILTIN_R3<misc_opx_vaddss_h, int_postrisc_vaddssh, v8i16, v8i16, v8i16>;
defm VADDSSW : BUILTIN_R3<misc_opx_vaddss_w, int_postrisc_vaddssw, v4i32, v4i32, v4i32>;
defm VADDSSD : BUILTIN_R3<misc_opx_vaddss_d, int_postrisc_vaddssd, v2i64, v2i64, v2i64>;

defm VADDUSB : BUILTIN_R3<misc_opx_vaddus_b, int_postrisc_vaddusb, v16i8, v16i8, v16i8>;
defm VADDUSH : BUILTIN_R3<misc_opx_vaddus_h, int_postrisc_vaddush, v8i16, v8i16, v8i16>;
defm VADDUSW : BUILTIN_R3<misc_opx_vaddus_w, int_postrisc_vaddusw, v4i32, v4i32, v4i32>;
defm VADDUSD : BUILTIN_R3<misc_opx_vaddus_d, int_postrisc_vaddusd, v2i64, v2i64, v2i64>;

defm VSUBSSB : BUILTIN_R3<misc_opx_vsubss_b, int_postrisc_vsubssb, v16i8, v16i8, v16i8>;
defm VSUBSSH : BUILTIN_R3<misc_opx_vsubss_h, int_postrisc_vsubssh, v8i16, v8i16, v8i16>;
defm VSUBSSW : BUILTIN_R3<misc_opx_vsubss_w, int_postrisc_vsubssw, v4i32, v4i32, v4i32>;
defm VSUBSSD : BUILTIN_R3<misc_opx_vsubss_d, int_postrisc_vsubssd, v2i64, v2i64, v2i64>;

defm VSUBUSB : BUILTIN_R3<misc_opx_vsubus_b, int_postrisc_vsubusb, v16i8, v16i8, v16i8>;
defm VSUBUSH : BUILTIN_R3<misc_opx_vsubus_h, int_postrisc_vsubush, v8i16, v8i16, v8i16>;
defm VSUBUSW : BUILTIN_R3<misc_opx_vsubus_w, int_postrisc_vsubusw, v4i32, v4i32, v4i32>;
defm VSUBUSD : BUILTIN_R3<misc_opx_vsubus_d, int_postrisc_vsubusd, v2i64, v2i64, v2i64>;

//===----------------------------------------------------------------------===//
// compare
//===-----------------------------------------------h----------------------===//
defm VCMPEQB : BUILTIN_R3<misc_opx_vcmp_eq_b, int_postrisc_vcmpeqb, v16i8, v16i8, v16i8>;
defm VCMPEQH : BUILTIN_R3<misc_opx_vcmp_eq_h, int_postrisc_vcmpeqh, v8i16, v8i16, v8i16>;
defm VCMPEQW : BUILTIN_R3<misc_opx_vcmp_eq_w, int_postrisc_vcmpeqw, v4i32, v4i32, v4i32>;
defm VCMPEQD : BUILTIN_R3<misc_opx_vcmp_eq_d, int_postrisc_vcmpeqd, v2i64, v2i64, v2i64>;

defm VCMPLTB : BUILTIN_R3<misc_opx_vcmp_lt_b, int_postrisc_vcmpltb, v16i8, v16i8, v16i8>;
defm VCMPLTH : BUILTIN_R3<misc_opx_vcmp_lt_h, int_postrisc_vcmplth, v8i16, v8i16, v8i16>;
defm VCMPLTW : BUILTIN_R3<misc_opx_vcmp_lt_w, int_postrisc_vcmpltw, v4i32, v4i32, v4i32>;
defm VCMPLTD : BUILTIN_R3<misc_opx_vcmp_lt_d, int_postrisc_vcmpltd, v2i64, v2i64, v2i64>;

defm VCMPLTUB : BUILTIN_R3<misc_opx_vcmp_ltu_b, int_postrisc_vcmpltub, v16i8, v16i8, v16i8>;
defm VCMPLTUH : BUILTIN_R3<misc_opx_vcmp_ltu_h, int_postrisc_vcmpltuh, v8i16, v8i16, v8i16>;
defm VCMPLTUW : BUILTIN_R3<misc_opx_vcmp_ltu_w, int_postrisc_vcmpltuw, v4i32, v4i32, v4i32>;
defm VCMPLTUD : BUILTIN_R3<misc_opx_vcmp_ltu_d, int_postrisc_vcmpltud, v2i64, v2i64, v2i64>;

//===----------------------------------------------------------------------===//
// signed/unsigned average
//===----------------------------------------------------------------------===//
defm VAVGUB : BUILTIN_R3<misc_opx_vavgu_b, int_postrisc_vavgub, v16i8, v16i8, v16i8>;
defm VAVGUH : BUILTIN_R3<misc_opx_vavgu_h, int_postrisc_vavguh, v8i16, v8i16, v8i16>;
defm VAVGUW : BUILTIN_R3<misc_opx_vavgu_w, int_postrisc_vavguw, v4i32, v4i32, v4i32>;
defm VAVGUD : BUILTIN_R3<misc_opx_vavgu_d, int_postrisc_vavgud, v2i64, v2i64, v2i64>;

defm VAVGSB : BUILTIN_R3<misc_opx_vavgs_b, int_postrisc_vavgsb, v16i8, v16i8, v16i8>;
defm VAVGSH : BUILTIN_R3<misc_opx_vavgs_h, int_postrisc_vavgsh, v8i16, v8i16, v8i16>;
defm VAVGSW : BUILTIN_R3<misc_opx_vavgs_w, int_postrisc_vavgsw, v4i32, v4i32, v4i32>;
defm VAVGSD : BUILTIN_R3<misc_opx_vavgs_d, int_postrisc_vavgsd, v2i64, v2i64, v2i64>;

//===----------------------------------------------------------------------===//
// shifts/rotates
//===----------------------------------------------------------------------===//
defm VROLB : BUILTIN_R3<misc_opx_vrol_b, int_postrisc_vrolb, v16i8, v16i8, v16i8>;
defm VROLH : BUILTIN_R3<misc_opx_vrol_h, int_postrisc_vrolh, v8i16, v8i16, v8i16>;
defm VROLW : BUILTIN_R3<misc_opx_vrol_w, int_postrisc_vrolw, v4i32, v4i32, v4i32>;
defm VROLD : BUILTIN_R3<misc_opx_vrol_d, int_postrisc_vrold, v2i64, v2i64, v2i64>;

defm VRORB : BUILTIN_R3<misc_opx_vror_b, int_postrisc_vrorb, v16i8, v16i8, v16i8>;
defm VRORH : BUILTIN_R3<misc_opx_vror_h, int_postrisc_vrorh, v8i16, v8i16, v8i16>;
defm VRORW : BUILTIN_R3<misc_opx_vror_w, int_postrisc_vrorw, v4i32, v4i32, v4i32>;
defm VRORD : BUILTIN_R3<misc_opx_vror_d, int_postrisc_vrord, v2i64, v2i64, v2i64>;

defm VSLLB : BUILTIN_R3<misc_opx_vsll_b, int_postrisc_vsllb, v16i8, v16i8, v16i8>;
defm VSLLH : BUILTIN_R3<misc_opx_vsll_h, int_postrisc_vsllh, v8i16, v8i16, v8i16>;
defm VSLLW : BUILTIN_R3<misc_opx_vsll_w, int_postrisc_vsllw, v4i32, v4i32, v4i32>;
defm VSLLD : BUILTIN_R3<misc_opx_vsll_d, int_postrisc_vslld, v2i64, v2i64, v2i64>;

defm VSRAB : BUILTIN_R3<misc_opx_vsra_b, int_postrisc_vsrab, v16i8, v16i8, v16i8>;
defm VSRAH : BUILTIN_R3<misc_opx_vsra_h, int_postrisc_vsrah, v8i16, v8i16, v8i16>;
defm VSRAW : BUILTIN_R3<misc_opx_vsra_w, int_postrisc_vsraw, v4i32, v4i32, v4i32>;
defm VSRAD : BUILTIN_R3<misc_opx_vsra_d, int_postrisc_vsrad, v2i64, v2i64, v2i64>;

defm VSRLB : BUILTIN_R3<misc_opx_vsrl_b, int_postrisc_vsrlb, v16i8, v16i8, v16i8>;
defm VSRLH : BUILTIN_R3<misc_opx_vsrl_h, int_postrisc_vsrlh, v8i16, v8i16, v8i16>;
defm VSRLW : BUILTIN_R3<misc_opx_vsrl_w, int_postrisc_vsrlw, v4i32, v4i32, v4i32>;
defm VSRLD : BUILTIN_R3<misc_opx_vsrl_d, int_postrisc_vsrld, v2i64, v2i64, v2i64>;

//===----------------------------------------------------------------------===//
// signed/unsigned min/max
//===----------------------------------------------------------------------===//
defm VMAXSB : BUILTIN_R3<misc_opx_vmaxs_b, int_postrisc_vmaxsb, v16i8, v16i8, v16i8>;
defm VMAXSH : BUILTIN_R3<misc_opx_vmaxs_h, int_postrisc_vmaxsh, v8i16, v8i16, v8i16>;
defm VMAXSW : BUILTIN_R3<misc_opx_vmaxs_w, int_postrisc_vmaxsw, v4i32, v4i32, v4i32>;
defm VMAXSD : BUILTIN_R3<misc_opx_vmaxs_d, int_postrisc_vmaxsd, v2i64, v2i64, v2i64>;

defm VMAXUB : BUILTIN_R3<misc_opx_vmaxu_b, int_postrisc_vmaxub, v16i8, v16i8, v16i8>;
defm VMAXUH : BUILTIN_R3<misc_opx_vmaxu_h, int_postrisc_vmaxuh, v8i16, v8i16, v8i16>;
defm VMAXUW : BUILTIN_R3<misc_opx_vmaxu_w, int_postrisc_vmaxuw, v4i32, v4i32, v4i32>;
defm VMAXUD : BUILTIN_R3<misc_opx_vmaxu_d, int_postrisc_vmaxud, v2i64, v2i64, v2i64>;

defm VMINSB : BUILTIN_R3<misc_opx_vmins_b, int_postrisc_vminsb, v16i8, v16i8, v16i8>;
defm VMINSH : BUILTIN_R3<misc_opx_vmins_h, int_postrisc_vminsh, v8i16, v8i16, v8i16>;
defm VMINSW : BUILTIN_R3<misc_opx_vmins_w, int_postrisc_vminsw, v4i32, v4i32, v4i32>;
defm VMINSD : BUILTIN_R3<misc_opx_vmins_d, int_postrisc_vminsd, v2i64, v2i64, v2i64>;

defm VMINUB : BUILTIN_R3<misc_opx_vminu_b, int_postrisc_vminub, v16i8, v16i8, v16i8>;
defm VMINUH : BUILTIN_R3<misc_opx_vminu_h, int_postrisc_vminuh, v8i16, v8i16, v8i16>;
defm VMINUW : BUILTIN_R3<misc_opx_vminu_w, int_postrisc_vminuw, v4i32, v4i32, v4i32>;
defm VMINUD : BUILTIN_R3<misc_opx_vminu_d, int_postrisc_vminud, v2i64, v2i64, v2i64>;

defm VMRGHB : BUILTIN_R3<misc_opx_vmrgh_b, int_postrisc_vmrghb, v16i8, v16i8, v16i8>;
defm VMRGLB : BUILTIN_R3<misc_opx_vmrgl_b, int_postrisc_vmrglb, v16i8, v16i8, v16i8>;
defm VMRGHH : BUILTIN_R3<misc_opx_vmrgh_h, int_postrisc_vmrghh, v8i16, v8i16, v8i16>;
defm VMRGLH : BUILTIN_R3<misc_opx_vmrgl_h, int_postrisc_vmrglh, v8i16, v8i16, v8i16>;
defm VMRGHW : BUILTIN_R3<misc_opx_vmrgh_w, int_postrisc_vmrghw, v4i32, v4i32, v4i32>;
defm VMRGLW : BUILTIN_R3<misc_opx_vmrgl_w, int_postrisc_vmrglw, v4i32, v4i32, v4i32>;
defm VMRGHD : BUILTIN_R3<misc_opx_vmrgh_d, int_postrisc_vmrghd, v2i64, v2i64, v2i64>;
defm VMRGLD : BUILTIN_R3<misc_opx_vmrgl_d, int_postrisc_vmrgld, v2i64, v2i64, v2i64>;

defm VPKSSSH : BUILTIN_R3<misc_opx_vpksss_h, int_postrisc_vpksssh, v16i8, v8i16, v8i16>;
defm VPKSSSW : BUILTIN_R3<misc_opx_vpksss_w, int_postrisc_vpksssw, v8i16, v4i32, v4i32>;
defm VPKSSSD : BUILTIN_R3<misc_opx_vpksss_d, int_postrisc_vpksssd, v4i32, v2i64, v2i64>;
defm VPKSUSH : BUILTIN_R3<misc_opx_vpksus_h, int_postrisc_vpksush, v16i8, v8i16, v8i16>;
defm VPKSUSW : BUILTIN_R3<misc_opx_vpksus_w, int_postrisc_vpksusw, v8i16, v4i32, v4i32>;
defm VPKSUSD : BUILTIN_R3<misc_opx_vpksus_d, int_postrisc_vpksusd, v4i32, v2i64, v2i64>;
defm VPKUUMH : BUILTIN_R3<misc_opx_vpkuum_h, int_postrisc_vpkuumh, v16i8, v8i16, v8i16>;
defm VPKUUMW : BUILTIN_R3<misc_opx_vpkuum_w, int_postrisc_vpkuumw, v8i16, v4i32, v4i32>;
defm VPKUUMD : BUILTIN_R3<misc_opx_vpkuum_d, int_postrisc_vpkuumd, v4i32, v2i64, v2i64>;
defm VPKUUSH : BUILTIN_R3<misc_opx_vpkuus_h, int_postrisc_vpkuush, v16i8, v8i16, v8i16>;
defm VPKUUSW : BUILTIN_R3<misc_opx_vpkuus_w, int_postrisc_vpkuusw, v8i16, v4i32, v4i32>;
defm VPKUUSD : BUILTIN_R3<misc_opx_vpkuus_d, int_postrisc_vpkuusd, v4i32, v2i64, v2i64>;

defm VUPKHSB : BUILTIN_R2<misc_opx_vupkhs_b, int_postrisc_vupkhsb, v8i16, v16i8>;
defm VUPKHSH : BUILTIN_R2<misc_opx_vupkhs_h, int_postrisc_vupkhsh, v4i32, v8i16>;
defm VUPKHSW : BUILTIN_R2<misc_opx_vupkhs_w, int_postrisc_vupkhsw, v2i64, v4i32>;
defm VUPKLSB : BUILTIN_R2<misc_opx_vupkls_b, int_postrisc_vupklsb, v8i16, v16i8>;
defm VUPKLSH : BUILTIN_R2<misc_opx_vupkls_h, int_postrisc_vupklsh, v4i32, v8i16>;
defm VUPKLSW : BUILTIN_R2<misc_opx_vupkls_w, int_postrisc_vupklsw, v2i64, v4i32>;
