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

multiclass FP_SIMD_INTRUCTIONS<string T, ValueType Ty>
{
  // sign-alternating
  defm ADD_ALT_   # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_add_alt_"  # T), !cast<ClangBuiltin>("int_postrisc_add_alt_"  # T),  Ty, Ty, Ty>;
  defm SUB_ALT_   # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_sub_alt_"  # T), !cast<ClangBuiltin>("int_postrisc_sub_alt_"  # T),  Ty, Ty, Ty>;

  // horizontal
  defm MUL_HORIZ_ # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_mul_horiz_"  # T), !cast<ClangBuiltin>("int_postrisc_mul_horiz_" # T),  Ty, Ty, Ty>;
  defm ADD_HORIZ_ # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_add_horiz_"  # T), !cast<ClangBuiltin>("int_postrisc_add_horiz_" # T),  Ty, Ty, Ty>;
  defm SUB_HORIZ_ # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_sub_horiz_"  # T), !cast<ClangBuiltin>("int_postrisc_sub_horiz_" # T),  Ty, Ty, Ty>;

  defm MADD_ALT_  # NAME : FMA_BUILTIN_R4<!cast<fma_opx>("opcode_madd_alt_"  # T), !cast<ClangBuiltin>("int_postrisc_madd_alt_" # T), Ty, Ty, Ty, Ty>;
  defm MSUB_ALT_  # NAME : FMA_BUILTIN_R4<!cast<fma_opx>("opcode_msub_alt_"  # T), !cast<ClangBuiltin>("int_postrisc_msub_alt_" # T), Ty, Ty, Ty, Ty>;
}

defm VF16 : FP_SIMD_INTRUCTIONS<"vf16", v8f16>;
defm VF32 : FP_SIMD_INTRUCTIONS<"vf32", v4f32>;
defm VF64 : FP_SIMD_INTRUCTIONS<"vf64", v2f64>;

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

multiclass SINT_SIMD_INTRUCTIONS<string T, ValueType Ty>
{
    // overflow signed add/sub
    defm ADDO_ # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_addo_"  # T),  !cast<ClangBuiltin>("int_postrisc_addo_" # T),  Ty, Ty, Ty>;
    defm SUBO_ # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_subo_"  # T),  !cast<ClangBuiltin>("int_postrisc_subo_" # T),  Ty, Ty, Ty>;

    // saturated signed add/sub
    defm ADD_SAT_  # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_add_sat_" # T),  !cast<ClangBuiltin>("int_postrisc_add_sat_"  # T),  Ty, Ty, Ty>;
    defm SUB_SAT_  # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_sub_sat_" # T),  !cast<ClangBuiltin>("int_postrisc_sub_sat_"  # T),  Ty, Ty, Ty>;

    // compare
    defm CMP_EQ_ # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_cmp_eq_" # T),  !cast<ClangBuiltin>("int_postrisc_cmp_eq_" # T),  Ty, Ty, Ty>;
    defm CMP_LT_ # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_cmp_lt_" # T),  !cast<ClangBuiltin>("int_postrisc_cmp_lt_" # T),  Ty, Ty, Ty>;

    // signed average
    defm AVG_ # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_avg_"    # T),  !cast<ClangBuiltin>("int_postrisc_avg_" # T),  Ty, Ty, Ty>;

    defm SRA_ # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_sra_"    # T),  !cast<ClangBuiltin>("int_postrisc_sra_" # T),  Ty, Ty, Ty>;

    defm MIN_ # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_min_"    # T),  !cast<ClangBuiltin>("int_postrisc_min_" # T),  Ty, Ty, Ty>;
    defm MAX_ # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_max_"    # T),  !cast<ClangBuiltin>("int_postrisc_max_" # T),  Ty, Ty, Ty>;
}

defm VI8  : SINT_SIMD_INTRUCTIONS<"vi8",  v16i8>;
defm VI16 : SINT_SIMD_INTRUCTIONS<"vi16", v8i16>;
defm VI32 : SINT_SIMD_INTRUCTIONS<"vi32", v4i32>;
defm VI64 : SINT_SIMD_INTRUCTIONS<"vi64", v2i64>;

multiclass UINT_SIMD_INTRUCTIONS<string T, ValueType Ty>
{
    // add/sub
    defm ADD_ # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_add_"   # T),  !cast<ClangBuiltin>("int_postrisc_add_"  # T),  Ty, Ty, Ty>;
    defm SUB_ # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_sub_"   # T),  !cast<ClangBuiltin>("int_postrisc_sub_"  # T),  Ty, Ty, Ty>;

    // carry/borrow unsigned add/sub
    defm ADDC_ # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_addc_"   # T),  !cast<ClangBuiltin>("int_postrisc_addc_"  # T),  Ty, Ty, Ty>;
    defm SUBB_ # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_subb_"   # T),  !cast<ClangBuiltin>("int_postrisc_subb_"  # T),  Ty, Ty, Ty>;

    // saturated unsigned add/sub
    defm ADD_SAT_ # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_add_sat_"   # T),  !cast<ClangBuiltin>("int_postrisc_add_sat_"  # T),  Ty, Ty, Ty>;
    defm SUB_SAT_ # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_sub_sat_"   # T),  !cast<ClangBuiltin>("int_postrisc_sub_sat_"  # T),  Ty, Ty, Ty>;

    // compare
    defm CMP_LT_ # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_cmp_lt_" # T),  !cast<ClangBuiltin>("int_postrisc_cmp_lt_" # T),  Ty, Ty, Ty>;

    // unsigned average
    defm AVG_ # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_avg_"    # T),  !cast<ClangBuiltin>("int_postrisc_avg_" # T),  Ty, Ty, Ty>;

    defm ROL_ # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_rol_"    # T),  !cast<ClangBuiltin>("int_postrisc_rol_" # T),  Ty, Ty, Ty>;
    defm ROR_ # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_ror_"    # T),  !cast<ClangBuiltin>("int_postrisc_ror_" # T),  Ty, Ty, Ty>;
    defm SLL_ # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_sll_"    # T),  !cast<ClangBuiltin>("int_postrisc_sll_" # T),  Ty, Ty, Ty>;
    defm SRL_ # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_srl_"    # T),  !cast<ClangBuiltin>("int_postrisc_srl_" # T),  Ty, Ty, Ty>;

    defm MIN_ # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_min_"    # T),  !cast<ClangBuiltin>("int_postrisc_min_" # T),  Ty, Ty, Ty>;
    defm MAX_ # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_max_"    # T),  !cast<ClangBuiltin>("int_postrisc_max_" # T),  Ty, Ty, Ty>;

    defm MERGE_LOW_  # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_merge_low_"  # T),  !cast<ClangBuiltin>("int_postrisc_merge_low_"  # T),  Ty, Ty, Ty>;
    defm MERGE_HIGH_ # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_merge_high_" # T),  !cast<ClangBuiltin>("int_postrisc_merge_high_" # T),  Ty, Ty, Ty>;
}

defm VU8  : UINT_SIMD_INTRUCTIONS<"vu8",  v16i8>;
defm VU16 : UINT_SIMD_INTRUCTIONS<"vu16", v8i16>;
defm VU32 : UINT_SIMD_INTRUCTIONS<"vu32", v4i32>;
defm VU64 : UINT_SIMD_INTRUCTIONS<"vu64", v2i64>;

//===----------------------------------------------------------------------===//
// integer SIMD mixed type conversions
//===----------------------------------------------------------------------===//
multiclass SINT_SIMD_PACK<string T, ValueType Tr, ValueType Ty>
{
    defm PACK_SAT_  # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_pack_sat_"  # T),  !cast<ClangBuiltin>("int_postrisc_pack_sat_"  # T),  Tr, Ty, Ty>;
    defm PACK_USAT_ # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_pack_usat_" # T),  !cast<ClangBuiltin>("int_postrisc_pack_usat_" # T),  Tr, Ty, Ty>;
}

defm VI16 : SINT_SIMD_PACK<"vi16", v16i8, v8i16>;
defm VI32 : SINT_SIMD_PACK<"vi32", v8i16, v4i32>;
defm VI64 : SINT_SIMD_PACK<"vi64", v4i32, v2i64>;

multiclass UINT_SIMD_PACK<string T, ValueType Tr, ValueType Ty>
{
    defm PACK_SAT_ # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_pack_sat_" # T),  !cast<ClangBuiltin>("int_postrisc_pack_sat_" # T),  Tr, Ty, Ty>;
    defm PACK_MOD_ # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_pack_mod_" # T),  !cast<ClangBuiltin>("int_postrisc_pack_mod_" # T),  Tr, Ty, Ty>;
}

defm VU16 : UINT_SIMD_PACK<"vu16", v16i8, v8i16>;
defm VU32 : UINT_SIMD_PACK<"vu32", v8i16, v4i32>;
defm VU64 : UINT_SIMD_PACK<"vu64", v4i32, v2i64>;


multiclass SINT_SIMD_UNPACK<string T, ValueType Tr, ValueType Ty>
{
    defm UNPACK_LOW_  # NAME : BUILTIN_R2<!cast<misc_opx>("opcode_unpack_low_"  # T),  !cast<ClangBuiltin>("int_postrisc_unpack_low_"  # T),  Ty, Tr>;
    defm UNPACK_HIGH_ # NAME : BUILTIN_R2<!cast<misc_opx>("opcode_unpack_high_" # T),  !cast<ClangBuiltin>("int_postrisc_unpack_high_" # T),  Ty, Tr>;
}

defm VI8  : SINT_SIMD_UNPACK<"vi8",  v16i8, v8i16>;
defm VI16 : SINT_SIMD_UNPACK<"vi16", v8i16, v4i32>;
defm VI32 : SINT_SIMD_UNPACK<"vi32", v4i32, v2i64>;

multiclass UINT_SIMD_UNPACK<string T, ValueType Tr, ValueType Ty>
{
    defm UNPACK_LOW_  # NAME : BUILTIN_R2<!cast<misc_opx>("opcode_unpack_low_"  # T),  !cast<ClangBuiltin>("int_postrisc_unpack_low_"  # T),  Ty, Tr>;
    defm UNPACK_HIGH_ # NAME : BUILTIN_R2<!cast<misc_opx>("opcode_unpack_high_" # T),  !cast<ClangBuiltin>("int_postrisc_unpack_high_" # T),  Ty, Tr>;
}

defm VU8  : UINT_SIMD_UNPACK<"vu8",  v16i8, v8i16>;
defm VU16 : UINT_SIMD_UNPACK<"vu16", v8i16, v4i32>;
defm VU32 : UINT_SIMD_UNPACK<"vu32", v4i32, v2i64>;
