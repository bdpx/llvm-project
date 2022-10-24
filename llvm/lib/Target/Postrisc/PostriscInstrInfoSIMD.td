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
defm AES_IMC      : BUILTIN_R2<opcode_aes_imc,      int_postrisc_aesimc,     v2i64, v2i64>;
defm AES_ENC      : BUILTIN_R3<opcode_aes_enc,      int_postrisc_aesenc,     v2i64, v2i64, v2i64>;
defm AES_ENC_LAST : BUILTIN_R3<opcode_aes_enc_last, int_postrisc_aesenclast, v2i64, v2i64, v2i64>;
defm AES_DEC      : BUILTIN_R3<opcode_aes_dec,      int_postrisc_aesdec,     v2i64, v2i64, v2i64>;
defm AES_DEC_LAST : BUILTIN_R3<opcode_aes_dec_last, int_postrisc_aesdeclast, v2i64, v2i64, v2i64>;

def round_constant : Operand<i8>, TImmLeaf<i8, [{ return isInt<8>(Imm); }]> {
  let DecoderMethod = "DecodeSIMM<8>";
}
def AES_KEYGEN_ASSIST :
  MISC_RabI10<opcode_aes_keygen_assist,
              (outs GR:$ra), (ins GR:$rb, round_constant:$imm),
              !strconcat(opcode_aes_keygen_assist.mnem, " $ra, $rb, $imm"),
              [(set v2i64:$ra, (int_postrisc_aeskeygenassist v2i64:$rb, i8:$imm))]>;

//===----------------------------------------------------------------------===//
// hasing, carry-less multiply
//===----------------------------------------------------------------------===//

defm CLMUL_LL : BUILTIN_R3<opcode_clmul_ll, int_postrisc_clmul_ll, v2i64, v2i64, v2i64>;
defm CLMUL_HL : BUILTIN_R3<opcode_clmul_hl, int_postrisc_clmul_hl, v2i64, v2i64, v2i64>;
defm CLMUL_HH : BUILTIN_R3<opcode_clmul_hh, int_postrisc_clmul_hh, v2i64, v2i64, v2i64>;

defm CRC32C : BUILTIN_R4<opcode_crc32c, int_postrisc_crc32c, i32, i32, i128, i64>;

//===----------------------------------------------------------------------===//
// fp SIMD compute
//===----------------------------------------------------------------------===//

defm VF16 : FP_BASE_INTRUCTIONS<"vf16", v8f16>;
defm VF32 : FP_BASE_INTRUCTIONS<"vf32", v4f32>;
defm VF64 : FP_BASE_INTRUCTIONS<"vf64", v2f64>;

// sign-alternating
defm ADD_ALT_VF16 : BUILTIN_R3<opcode_add_alt_vf16, int_postrisc_add_alt_vf16,  v8f16, v8f16, v8f16>;
defm SUB_ALT_VF16 : BUILTIN_R3<opcode_sub_alt_vf16, int_postrisc_sub_alt_vf16,  v8f16, v8f16, v8f16>;

defm ADD_ALT_VF32 : BUILTIN_R3<opcode_add_alt_vf32, int_postrisc_add_alt_vf32,  v4f32, v4f32, v4f32>;
defm SUB_ALT_VF32 : BUILTIN_R3<opcode_sub_alt_vf32, int_postrisc_sub_alt_vf32,  v4f32, v4f32, v4f32>;

defm ADD_ALT_VF64 : BUILTIN_R3<opcode_add_alt_vf64, int_postrisc_add_alt_vf64,  v2f64, v2f64, v2f64>;
defm SUB_ALT_VF64 : BUILTIN_R3<opcode_sub_alt_vf64, int_postrisc_sub_alt_vf64,  v2f64, v2f64, v2f64>;

// horizontal
defm MUL_HORIZ_VF16 : BUILTIN_R3<opcode_mul_horiz_vf16, int_postrisc_mul_horiz_vf16,  v8f16, v8f16, v8f16>;
defm ADD_HORIZ_VF16 : BUILTIN_R3<opcode_add_horiz_vf16, int_postrisc_add_horiz_vf16,  v8f16, v8f16, v8f16>;
defm SUB_HORIZ_VF16 : BUILTIN_R3<opcode_sub_horiz_vf16, int_postrisc_sub_horiz_vf16,  v8f16, v8f16, v8f16>;

defm MUL_HORIZ_VF32 : BUILTIN_R3<opcode_mul_horiz_vf32, int_postrisc_mul_horiz_vf32,  v4f32, v4f32, v4f32>;
defm ADD_HORIZ_VF32 : BUILTIN_R3<opcode_add_horiz_vf32, int_postrisc_add_horiz_vf32,  v4f32, v4f32, v4f32>;
defm SUB_HORIZ_VF32 : BUILTIN_R3<opcode_sub_horiz_vf32, int_postrisc_sub_horiz_vf32,  v4f32, v4f32, v4f32>;

defm ADD_HORIZ_VF64 : BUILTIN_R3<opcode_add_horiz_vf64, int_postrisc_add_horiz_vf64,  v2f64, v2f64, v2f64>;
defm MUL_HORIZ_VF64 : BUILTIN_R3<opcode_mul_horiz_vf64, int_postrisc_mul_horiz_vf64,  v2f64, v2f64, v2f64>;
defm SUB_HORIZ_VF64 : BUILTIN_R3<opcode_sub_horiz_vf64, int_postrisc_sub_horiz_vf64,  v2f64, v2f64, v2f64>;

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

defm : IntrinsicPostriscFma<int_postrisc_madd_vf16, MADD_VF16, NMADD_VF16, MSUB_VF16, NMSUB_VF16, v8f16>;
defm : IntrinsicPostriscFma<int_postrisc_madd_vf32, MADD_VF32, NMADD_VF32, MSUB_VF32, NMSUB_VF32, v4f32>;
defm : IntrinsicPostriscFma<int_postrisc_madd_vf64, MADD_VF64, NMADD_VF64, MSUB_VF64, NMSUB_VF64, v2f64>;

//===----------------------------------------------------------------------===//
// add/sub
//===----------------------------------------------------------------------===//
defm ADD_VU8  : BUILTIN_R3<opcode_add_vu8,  int_postrisc_add_vu8,  v16i8, v16i8, v16i8>;
defm ADD_VU16 : BUILTIN_R3<opcode_add_vu16, int_postrisc_add_vu16, v8i16, v8i16, v8i16>;
defm ADD_VU32 : BUILTIN_R3<opcode_add_vu32, int_postrisc_add_vu32, v4i32, v4i32, v4i32>;
defm ADD_VU64 : BUILTIN_R3<opcode_add_vu64, int_postrisc_add_vu64, v2i64, v2i64, v2i64>;

//===----------------------------------------------------------------------===//
// overflow signed add/sub
//===----------------------------------------------------------------------===//
defm ADDO_VI8  : BUILTIN_R3<opcode_addo_vi8,  int_postrisc_addo_vi8, v16i8, v16i8, v16i8>;
defm ADDO_VI16 : BUILTIN_R3<opcode_addo_vi16, int_postrisc_addo_vi16, v8i16, v8i16, v8i16>;
defm ADDO_VI32 : BUILTIN_R3<opcode_addo_vi32, int_postrisc_addo_vi32, v4i32, v4i32, v4i32>;
defm ADDO_VI64 : BUILTIN_R3<opcode_addo_vi64, int_postrisc_addo_vi64, v2i64, v2i64, v2i64>;

defm SUBO_VI8  : BUILTIN_R3<opcode_subo_vi8,  int_postrisc_subo_vi8, v16i8, v16i8, v16i8>;
defm SUBO_VI16 : BUILTIN_R3<opcode_subo_vi16, int_postrisc_subo_vi16, v8i16, v8i16, v8i16>;
defm SUBO_VI32 : BUILTIN_R3<opcode_subo_vi32, int_postrisc_subo_vi32, v4i32, v4i32, v4i32>;
defm SUBO_VI64 : BUILTIN_R3<opcode_subo_vi64, int_postrisc_subo_vi64, v2i64, v2i64, v2i64>;

//===----------------------------------------------------------------------===//
// carry/borrow unsigned add/sub
//===----------------------------------------------------------------------===//
defm ADDC_VU8  : BUILTIN_R3<opcode_addc_vu8,  int_postrisc_addc_vu8,  v16i8, v16i8, v16i8>;
defm ADDC_VU16 : BUILTIN_R3<opcode_addc_vu16, int_postrisc_addc_vu16, v8i16, v8i16, v8i16>;
defm ADDC_VU32 : BUILTIN_R3<opcode_addc_vu32, int_postrisc_addc_vu32, v4i32, v4i32, v4i32>;
defm ADDC_VU64 : BUILTIN_R3<opcode_addc_vu64, int_postrisc_addc_vu64, v2i64, v2i64, v2i64>;

defm SUBB_VU8  : BUILTIN_R3<opcode_subb_vu8,  int_postrisc_subb_vu8,  v16i8, v16i8, v16i8>;
defm SUBB_VU16 : BUILTIN_R3<opcode_subb_vu16, int_postrisc_subb_vu16, v8i16, v8i16, v8i16>;
defm SUBB_VU32 : BUILTIN_R3<opcode_subb_vu32, int_postrisc_subb_vu32, v4i32, v4i32, v4i32>;
defm SUBB_VU64 : BUILTIN_R3<opcode_subb_vu64, int_postrisc_subb_vu64, v2i64, v2i64, v2i64>;

defm SUB_VU8  : BUILTIN_R3<opcode_sub_vu8,  int_postrisc_sub_vu8,  v16i8, v16i8, v16i8>;
defm SUB_VU16 : BUILTIN_R3<opcode_sub_vu16, int_postrisc_sub_vu16, v8i16, v8i16, v8i16>;
defm SUB_VU32 : BUILTIN_R3<opcode_sub_vu32, int_postrisc_sub_vu32, v4i32, v4i32, v4i32>;
defm SUB_VU64 : BUILTIN_R3<opcode_sub_vu64, int_postrisc_sub_vu64, v2i64, v2i64, v2i64>;

//===----------------------------------------------------------------------===//
// saturated signed/unsigned add/sub
//===----------------------------------------------------------------------===//
defm ADD_SAT_VI8  : BUILTIN_R3<opcode_add_sat_vi8,  int_postrisc_add_sat_vi8,  v16i8, v16i8, v16i8>;
defm ADD_SAT_VI16 : BUILTIN_R3<opcode_add_sat_vi16, int_postrisc_add_sat_vi16, v8i16, v8i16, v8i16>;
defm ADD_SAT_VI32 : BUILTIN_R3<opcode_add_sat_vi32, int_postrisc_add_sat_vi32, v4i32, v4i32, v4i32>;
defm ADD_SAT_VI64 : BUILTIN_R3<opcode_add_sat_vi64, int_postrisc_add_sat_vi64, v2i64, v2i64, v2i64>;

defm ADD_SAT_VU8  : BUILTIN_R3<opcode_add_sat_vu8,  int_postrisc_add_sat_vu8,  v16i8, v16i8, v16i8>;
defm ADD_SAT_VU16 : BUILTIN_R3<opcode_add_sat_vu16, int_postrisc_add_sat_vu16, v8i16, v8i16, v8i16>;
defm ADD_SAT_VU32 : BUILTIN_R3<opcode_add_sat_vu32, int_postrisc_add_sat_vu32, v4i32, v4i32, v4i32>;
defm ADD_SAT_VU64 : BUILTIN_R3<opcode_add_sat_vu64, int_postrisc_add_sat_vu64, v2i64, v2i64, v2i64>;

defm SUB_SAT_VI8  : BUILTIN_R3<opcode_sub_sat_vi8,  int_postrisc_sub_sat_vi8,  v16i8, v16i8, v16i8>;
defm SUB_SAT_VI16 : BUILTIN_R3<opcode_sub_sat_vi16, int_postrisc_sub_sat_vi16, v8i16, v8i16, v8i16>;
defm SUB_SAT_VI32 : BUILTIN_R3<opcode_sub_sat_vi32, int_postrisc_sub_sat_vi32, v4i32, v4i32, v4i32>;
defm SUB_SAT_VI64 : BUILTIN_R3<opcode_sub_sat_vi64, int_postrisc_sub_sat_vi64, v2i64, v2i64, v2i64>;

defm SUB_SAT_VU8  : BUILTIN_R3<opcode_sub_sat_vu8,  int_postrisc_sub_sat_vu8,  v16i8, v16i8, v16i8>;
defm SUB_SAT_VU16 : BUILTIN_R3<opcode_sub_sat_vu16, int_postrisc_sub_sat_vu16, v8i16, v8i16, v8i16>;
defm SUB_SAT_VU32 : BUILTIN_R3<opcode_sub_sat_vu32, int_postrisc_sub_sat_vu32, v4i32, v4i32, v4i32>;
defm SUB_SAT_VU64 : BUILTIN_R3<opcode_sub_sat_vu64, int_postrisc_sub_sat_vu64, v2i64, v2i64, v2i64>;

//===----------------------------------------------------------------------===//
// compare
//===-----------------------------------------------h----------------------===//
defm CMP_EQ_VI8  : BUILTIN_R3<opcode_cmp_eq_vi8,  int_postrisc_cmp_eq_vi8,  v16i8, v16i8, v16i8>;
defm CMP_EQ_VI16 : BUILTIN_R3<opcode_cmp_eq_vi16, int_postrisc_cmp_eq_vi16, v8i16, v8i16, v8i16>;
defm CMP_EQ_VI32 : BUILTIN_R3<opcode_cmp_eq_vi32, int_postrisc_cmp_eq_vi32, v4i32, v4i32, v4i32>;
defm CMP_EQ_VI64 : BUILTIN_R3<opcode_cmp_eq_vi64, int_postrisc_cmp_eq_vi64, v2i64, v2i64, v2i64>;

defm CMP_LT_VI8  : BUILTIN_R3<opcode_cmp_lt_vi8,  int_postrisc_cmp_lt_vi8,  v16i8, v16i8, v16i8>;
defm CMP_LT_VI16 : BUILTIN_R3<opcode_cmp_lt_vi16, int_postrisc_cmp_lt_vi16, v8i16, v8i16, v8i16>;
defm CMP_LT_VI32 : BUILTIN_R3<opcode_cmp_lt_vi32, int_postrisc_cmp_lt_vi32, v4i32, v4i32, v4i32>;
defm CMP_LT_VI64 : BUILTIN_R3<opcode_cmp_lt_vi64, int_postrisc_cmp_lt_vi64, v2i64, v2i64, v2i64>;

defm CMP_LT_VU8  : BUILTIN_R3<opcode_cmp_lt_vu8,  int_postrisc_cmp_lt_vu8,  v16i8, v16i8, v16i8>;
defm CMP_LT_VU16 : BUILTIN_R3<opcode_cmp_lt_vu16, int_postrisc_cmp_lt_vu16, v8i16, v8i16, v8i16>;
defm CMP_LT_VU32 : BUILTIN_R3<opcode_cmp_lt_vu32, int_postrisc_cmp_lt_vu32, v4i32, v4i32, v4i32>;
defm CMP_LT_VU64 : BUILTIN_R3<opcode_cmp_lt_vu64, int_postrisc_cmp_lt_vu64, v2i64, v2i64, v2i64>;

//===----------------------------------------------------------------------===//
// signed/unsigned average
//===----------------------------------------------------------------------===//
defm AVG_VU8  : BUILTIN_R3<opcode_avg_vu8,  int_postrisc_avg_vu8,  v16i8, v16i8, v16i8>;
defm AVG_VU16 : BUILTIN_R3<opcode_avg_vu16, int_postrisc_avg_vu16, v8i16, v8i16, v8i16>;
defm AVG_VU32 : BUILTIN_R3<opcode_avg_vu32, int_postrisc_avg_vu32, v4i32, v4i32, v4i32>;
defm AVG_VU64 : BUILTIN_R3<opcode_avg_vu64, int_postrisc_avg_vu64, v2i64, v2i64, v2i64>;

defm AVG_VI8  : BUILTIN_R3<opcode_avg_vi8,  int_postrisc_avg_vi8,  v16i8, v16i8, v16i8>;
defm AVG_VI16 : BUILTIN_R3<opcode_avg_vi16, int_postrisc_avg_vi16, v8i16, v8i16, v8i16>;
defm AVG_VI32 : BUILTIN_R3<opcode_avg_vi32, int_postrisc_avg_vi32, v4i32, v4i32, v4i32>;
defm AVG_VI64 : BUILTIN_R3<opcode_avg_vi64, int_postrisc_avg_vi64, v2i64, v2i64, v2i64>;

//===----------------------------------------------------------------------===//
// shifts/rotates
//===----------------------------------------------------------------------===//
defm ROL_VU8  : BUILTIN_R3<opcode_rol_vu8,  int_postrisc_rol_vu8,  v16i8, v16i8, v16i8>;
defm ROL_VU16 : BUILTIN_R3<opcode_rol_vu16, int_postrisc_rol_vu16, v8i16, v8i16, v8i16>;
defm ROL_VU32 : BUILTIN_R3<opcode_rol_vu32, int_postrisc_rol_vu32, v4i32, v4i32, v4i32>;
defm ROL_VU64 : BUILTIN_R3<opcode_rol_vu64, int_postrisc_rol_vu64, v2i64, v2i64, v2i64>;

defm ROR_VU8  : BUILTIN_R3<opcode_ror_vu8,  int_postrisc_ror_vu8,  v16i8, v16i8, v16i8>;
defm ROR_VU16 : BUILTIN_R3<opcode_ror_vu16, int_postrisc_ror_vu16, v8i16, v8i16, v8i16>;
defm ROR_VU32 : BUILTIN_R3<opcode_ror_vu32, int_postrisc_ror_vu32, v4i32, v4i32, v4i32>;
defm ROR_VU64 : BUILTIN_R3<opcode_ror_vu64, int_postrisc_ror_vu64, v2i64, v2i64, v2i64>;

defm SLL_VU8  : BUILTIN_R3<opcode_sll_vu8,  int_postrisc_sll_vu8,  v16i8, v16i8, v16i8>;
defm SLL_VU16 : BUILTIN_R3<opcode_sll_vu16, int_postrisc_sll_vu16, v8i16, v8i16, v8i16>;
defm SLL_VU32 : BUILTIN_R3<opcode_sll_vu32, int_postrisc_sll_vu32, v4i32, v4i32, v4i32>;
defm SLL_VU64 : BUILTIN_R3<opcode_sll_vu64, int_postrisc_sll_vu64, v2i64, v2i64, v2i64>;

defm SRA_VI8  : BUILTIN_R3<opcode_sra_vi8,  int_postrisc_sra_vi8,  v16i8, v16i8, v16i8>;
defm SRA_VI16 : BUILTIN_R3<opcode_sra_vi16, int_postrisc_sra_vi16, v8i16, v8i16, v8i16>;
defm SRA_VI32 : BUILTIN_R3<opcode_sra_vi32, int_postrisc_sra_vi32, v4i32, v4i32, v4i32>;
defm SRA_VI64 : BUILTIN_R3<opcode_sra_vi64, int_postrisc_sra_vi64, v2i64, v2i64, v2i64>;

defm SRL_VU8  : BUILTIN_R3<opcode_srl_vu8,  int_postrisc_srl_vu8,  v16i8, v16i8, v16i8>;
defm SRL_VU16 : BUILTIN_R3<opcode_srl_vu16, int_postrisc_srl_vu16, v8i16, v8i16, v8i16>;
defm SRL_VU32 : BUILTIN_R3<opcode_srl_vu32, int_postrisc_srl_vu32, v4i32, v4i32, v4i32>;
defm SRL_VU64 : BUILTIN_R3<opcode_srl_vu64, int_postrisc_srl_vu64, v2i64, v2i64, v2i64>;

//===----------------------------------------------------------------------===//
// signed/unsigned min/max
//===----------------------------------------------------------------------===//
defm MAX_VI8  : BUILTIN_R3<opcode_max_vi8,  int_postrisc_max_vi8,  v16i8, v16i8, v16i8>;
defm MAX_VI16 : BUILTIN_R3<opcode_max_vi16, int_postrisc_max_vi16, v8i16, v8i16, v8i16>;
defm MAX_VI32 : BUILTIN_R3<opcode_max_vi32, int_postrisc_max_vi32, v4i32, v4i32, v4i32>;
defm MAX_VI64 : BUILTIN_R3<opcode_max_vi64, int_postrisc_max_vi64, v2i64, v2i64, v2i64>;

defm MAX_VU8  : BUILTIN_R3<opcode_max_vu8,  int_postrisc_max_vu8,  v16i8, v16i8, v16i8>;
defm MAX_VU16 : BUILTIN_R3<opcode_max_vu16, int_postrisc_max_vu16, v8i16, v8i16, v8i16>;
defm MAX_VU32 : BUILTIN_R3<opcode_max_vu32, int_postrisc_max_vu32, v4i32, v4i32, v4i32>;
defm MAX_VU64 : BUILTIN_R3<opcode_max_vu64, int_postrisc_max_vu64, v2i64, v2i64, v2i64>;

defm MIN_VI8  : BUILTIN_R3<opcode_min_vi8,  int_postrisc_min_vi8,  v16i8, v16i8, v16i8>;
defm MIN_VI16 : BUILTIN_R3<opcode_min_vi16, int_postrisc_min_vi16, v8i16, v8i16, v8i16>;
defm MIN_VI32 : BUILTIN_R3<opcode_min_vi32, int_postrisc_min_vi32, v4i32, v4i32, v4i32>;
defm MIN_VI64 : BUILTIN_R3<opcode_min_vi64, int_postrisc_min_vi64, v2i64, v2i64, v2i64>;

defm MIN_VU8  : BUILTIN_R3<opcode_min_vu8,  int_postrisc_min_vu8,  v16i8, v16i8, v16i8>;
defm MIN_VU16 : BUILTIN_R3<opcode_min_vu16, int_postrisc_min_vu16, v8i16, v8i16, v8i16>;
defm MIN_VU32 : BUILTIN_R3<opcode_min_vu32, int_postrisc_min_vu32, v4i32, v4i32, v4i32>;
defm MIN_VU64 : BUILTIN_R3<opcode_min_vu64, int_postrisc_min_vu64, v2i64, v2i64, v2i64>;

defm MERGE_HIGH_VU8  : BUILTIN_R3<opcode_merge_high_vu8,  int_postrisc_merge_high_vu8,  v16i8, v16i8, v16i8>;
defm MERGE_HIGH_VU16 : BUILTIN_R3<opcode_merge_high_vu16, int_postrisc_merge_high_vu16, v8i16, v8i16, v8i16>;
defm MERGE_HIGH_VU32 : BUILTIN_R3<opcode_merge_high_vu32, int_postrisc_merge_high_vu32, v4i32, v4i32, v4i32>;
defm MERGE_HIGH_VU64 : BUILTIN_R3<opcode_merge_high_vu64, int_postrisc_merge_high_vu64, v2i64, v2i64, v2i64>;

defm MERGE_LOW_VU8  : BUILTIN_R3<opcode_merge_low_vu8,  int_postrisc_merge_low_vu8,  v16i8, v16i8, v16i8>;
defm MERGE_LOW_VU16 : BUILTIN_R3<opcode_merge_low_vu16, int_postrisc_merge_low_vu16, v8i16, v8i16, v8i16>;
defm MERGE_LOW_VU32 : BUILTIN_R3<opcode_merge_low_vu32, int_postrisc_merge_low_vu32, v4i32, v4i32, v4i32>;
defm MERGE_LOW_VU64 : BUILTIN_R3<opcode_merge_low_vu64, int_postrisc_merge_low_vu64, v2i64, v2i64, v2i64>;

// mixed
defm PACK_SAT_VI16 : BUILTIN_R3<opcode_pack_sat_vi16, int_postrisc_pack_sat_vi16, v16i8, v8i16, v8i16>;
defm PACK_SAT_VI32 : BUILTIN_R3<opcode_pack_sat_vi32, int_postrisc_pack_sat_vi32, v8i16, v4i32, v4i32>;
defm PACK_SAT_VI64 : BUILTIN_R3<opcode_pack_sat_vi64, int_postrisc_pack_sat_vi64, v4i32, v2i64, v2i64>;

defm PACK_SAT_VU16 : BUILTIN_R3<opcode_pack_sat_vu16, int_postrisc_pack_sat_vu16, v16i8, v8i16, v8i16>;
defm PACK_SAT_VU32 : BUILTIN_R3<opcode_pack_sat_vu32, int_postrisc_pack_sat_vu32, v8i16, v4i32, v4i32>;
defm PACK_SAT_VU64 : BUILTIN_R3<opcode_pack_sat_vu64, int_postrisc_pack_sat_vu64, v4i32, v2i64, v2i64>;

defm PACK_USAT_VI16 : BUILTIN_R3<opcode_pack_usat_vi16, int_postrisc_pack_usat_vi16, v16i8, v8i16, v8i16>;
defm PACK_USAT_VI32 : BUILTIN_R3<opcode_pack_usat_vi32, int_postrisc_pack_usat_vi32, v8i16, v4i32, v4i32>;
defm PACK_USAT_VI64 : BUILTIN_R3<opcode_pack_usat_vi64, int_postrisc_pack_usat_vi64, v4i32, v2i64, v2i64>;

defm PACK_MOD_VU16 : BUILTIN_R3<opcode_pack_mod_vu16, int_postrisc_pack_mod_vu16, v16i8, v8i16, v8i16>;
defm PACK_MOD_VU32 : BUILTIN_R3<opcode_pack_mod_vu32, int_postrisc_pack_mod_vu32, v8i16, v4i32, v4i32>;
defm PACK_MOD_VU64 : BUILTIN_R3<opcode_pack_mod_vu64, int_postrisc_pack_mod_vu64, v4i32, v2i64, v2i64>;

defm UNPACK_HIGH_VI8  : BUILTIN_R2<opcode_unpack_high_vi8,  int_postrisc_unpack_high_vi8,  v8i16, v16i8>;
defm UNPACK_HIGH_VI16 : BUILTIN_R2<opcode_unpack_high_vi16, int_postrisc_unpack_high_vi16, v4i32, v8i16>;
defm UNPACK_HIGH_VI32 : BUILTIN_R2<opcode_unpack_high_vi32, int_postrisc_unpack_high_vi32, v2i64, v4i32>;

defm UNPACK_HIGH_VU8  : BUILTIN_R2<opcode_unpack_high_vu8,  int_postrisc_unpack_high_vu8,  v8i16, v16i8>;
defm UNPACK_HIGH_VU16 : BUILTIN_R2<opcode_unpack_high_vu16, int_postrisc_unpack_high_vu16, v4i32, v8i16>;
defm UNPACK_HIGH_VU32 : BUILTIN_R2<opcode_unpack_high_vu32, int_postrisc_unpack_high_vu32, v2i64, v4i32>;

defm UNPACK_LOW_VI8  : BUILTIN_R2<opcode_unpack_low_vi8,  int_postrisc_unpack_low_vi8,  v8i16, v16i8>;
defm UNPACK_LOW_VI16 : BUILTIN_R2<opcode_unpack_low_vi16, int_postrisc_unpack_low_vi16, v4i32, v8i16>;
defm UNPACK_LOW_VI32 : BUILTIN_R2<opcode_unpack_low_vi32, int_postrisc_unpack_low_vi32, v2i64, v4i32>;

defm UNPACK_LOW_VU8  : BUILTIN_R2<opcode_unpack_low_vu8,  int_postrisc_unpack_low_vu8,  v8i16, v16i8>;
defm UNPACK_LOW_VU16 : BUILTIN_R2<opcode_unpack_low_vu16, int_postrisc_unpack_low_vu16, v4i32, v8i16>;
defm UNPACK_LOW_VU32 : BUILTIN_R2<opcode_unpack_low_vu32, int_postrisc_unpack_low_vu32, v2i64, v4i32>;
