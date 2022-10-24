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

def round_constant : Operand<i32>, TImmLeaf<i32, [{ return isUInt<10>(Imm); }]> {
  let DecoderMethod = "DecodeUIMM<10>";
}
def AES_KEYGEN_ASSIST : MISC_RabI10<opcode_aes_keygen_assist,
              (outs GR:$ra), (ins GR:$rb, round_constant:$imm),
              !strconcat(opcode_aes_keygen_assist.mnem, " $ra, $rb, $imm"),
              [(set v2i64:$ra, (int_postrisc_aeskeygenassist v2i64:$rb, i32:$imm))]>;

//===----------------------------------------------------------------------===//
// carry-less multiply
//===----------------------------------------------------------------------===//
def CLMUL : MISC_RabcScale<opcode_clmul, (outs GR:$ra), (ins GR:$rb, GR:$rc, scale:$scale),
                             !strconcat(opcode_clmul.mnem, " $ra, $rb, $rc, $scale"), []>;

def : Pat<(v2i64 (int_postrisc_clmul_ll v2i64:$rb, v2i64:$rc)), (CLMUL GR:$rb, GR:$rc, (i32 0))>;
def : Pat<(v2i64 (int_postrisc_clmul_hl v2i64:$rb, v2i64:$rc)), (CLMUL GR:$rb, GR:$rc, (i32 1))>;
def : Pat<(v2i64 (int_postrisc_clmul_hh v2i64:$rb, v2i64:$rc)), (CLMUL GR:$rb, GR:$rc, (i32 3))>;

//===----------------------------------------------------------------------===//
// CRC
//===----------------------------------------------------------------------===//
defm CRC32C : BUILTIN_R4<opcode_crc32c, int_postrisc_crc32c, i32, i32, i128, i64>;

//===----------------------------------------------------------------------===//
// fp SIMD compute
//===----------------------------------------------------------------------===//
defm VF16 : FP_BASE_INTRUCTIONS<"vf16", v8f16>;
defm VF32 : FP_BASE_INTRUCTIONS<"vf32", v4f32>;
defm VF64 : FP_BASE_INTRUCTIONS<"vf64", v2f64>;

multiclass FP_SIMD_INTRUCTIONS<string T, ValueType Ty, ValueType utype>
{
  defm CMP_OEQ_ # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_cmp_oeq_" # T), !cast<ClangBuiltin>("int_postrisc_cmp_oeq_" # T), utype, Ty, Ty>;
  defm CMP_ONE_ # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_cmp_one_" # T), !cast<ClangBuiltin>("int_postrisc_cmp_one_" # T), utype, Ty, Ty>;
  defm CMP_OLT_ # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_cmp_olt_" # T), !cast<ClangBuiltin>("int_postrisc_cmp_olt_" # T), utype, Ty, Ty>;
  defm CMP_OGE_ # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_cmp_oge_" # T), !cast<ClangBuiltin>("int_postrisc_cmp_oge_" # T), utype, Ty, Ty>;
  defm CMP_O_   # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_cmp_o_"   # T), !cast<ClangBuiltin>("int_postrisc_cmp_o_"   # T), utype, Ty, Ty>;
  defm CMP_UEQ_ # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_cmp_ueq_" # T), !cast<ClangBuiltin>("int_postrisc_cmp_ueq_" # T), utype, Ty, Ty>;
  defm CMP_UNE_ # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_cmp_une_" # T), !cast<ClangBuiltin>("int_postrisc_cmp_une_" # T), utype, Ty, Ty>;
  defm CMP_ULT_ # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_cmp_ult_" # T), !cast<ClangBuiltin>("int_postrisc_cmp_ult_" # T), utype, Ty, Ty>;
  defm CMP_UGE_ # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_cmp_uge_" # T), !cast<ClangBuiltin>("int_postrisc_cmp_uge_" # T), utype, Ty, Ty>;
  defm CMP_U_   # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_cmp_u_"   # T), !cast<ClangBuiltin>("int_postrisc_cmp_u_"   # T), utype, Ty, Ty>;

  def DOT_ # NAME : FORMAT_R3_RM<!cast<misc_opx>("opcode_dot_" # T), !cast<ClangBuiltin>("int_postrisc_dot_" # T), Ty, Ty, Ty>;
}

defm VF16 : FP_COMMON_PATTERNS<v8f16>;
defm VF32 : FP_COMMON_PATTERNS<v4f32>;
defm VF64 : FP_COMMON_PATTERNS<v2f64>;

defm VF16 : FP_SIMD_INTRUCTIONS<"vf16", v8f16, v8i16>;
defm VF32 : FP_SIMD_INTRUCTIONS<"vf32", v4f32, v4i32>;
defm VF64 : FP_SIMD_INTRUCTIONS<"vf64", v2f64, v2i64>;

//===----------------------------------------------------------------------===//
// fp merge/unpack
//===----------------------------------------------------------------------===//
defm MERGE_HIGH_VF16 : BUILTIN_R3<opcode_merge_high_vf16, int_postrisc_merge_high_vf16, v8f16, v8f16, v8f16>;
defm MERGE_HIGH_VF32 : BUILTIN_R3<opcode_merge_high_vf32, int_postrisc_merge_high_vf32, v4f32, v4f32, v4f32>;
defm MERGE_HIGH_VF64 : BUILTIN_R3<opcode_merge_high_vf64, int_postrisc_merge_high_vf64, v2f64, v2f64, v2f64>;

defm MERGE_LOW_VF16 : BUILTIN_R3<opcode_merge_low_vf16, int_postrisc_merge_low_vf16, v8f16, v8f16, v8f16>;
defm MERGE_LOW_VF32 : BUILTIN_R3<opcode_merge_low_vf32, int_postrisc_merge_low_vf32, v4f32, v4f32, v4f32>;
defm MERGE_LOW_VF64 : BUILTIN_R3<opcode_merge_low_vf64, int_postrisc_merge_low_vf64, v2f64, v2f64, v2f64>;

defm UNPACK_HIGH_VF16 : BUILTIN_R2<opcode_unpack_high_vf16,  int_postrisc_unpack_high_vf16, v8f16, v8f16>;
defm UNPACK_HIGH_VF32 : BUILTIN_R2<opcode_unpack_high_vf32,  int_postrisc_unpack_high_vf32, v4f32, v4f32>;
defm UNPACK_HIGH_VF64 : BUILTIN_R2<opcode_unpack_high_vf64,  int_postrisc_unpack_high_vf64, v2f64, v2f64>;

defm UNPACK_LOW_VF16 : BUILTIN_R2<opcode_unpack_low_vf16,  int_postrisc_unpack_low_vf16, v8f16, v8f16>;
defm UNPACK_LOW_VF32 : BUILTIN_R2<opcode_unpack_low_vf32,  int_postrisc_unpack_low_vf32, v4f32, v4f32>;
defm UNPACK_LOW_VF64 : BUILTIN_R2<opcode_unpack_low_vf64,  int_postrisc_unpack_low_vf64, v2f64, v2f64>;

//===----------------------------------------------------------------------===//
// integer
// signed average: ceiled (A+B+1)/2
// unsigned average, ceiled (A+B+1)/2
//===----------------------------------------------------------------------===//
multiclass SINT_SIMD_INTRUCTIONS<string T, ValueType Ty>
{
    defm ADDO_    # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_addo_"    # T), !cast<ClangBuiltin>("int_postrisc_addo_"    # T), Ty, Ty, Ty>;
    defm SUBO_    # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_subo_"    # T), !cast<ClangBuiltin>("int_postrisc_subo_"    # T), Ty, Ty, Ty>;
    defm ADD_SAT_ # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_add_sat_" # T), !cast<ClangBuiltin>("int_postrisc_add_sat_" # T), Ty, Ty, Ty>;
    defm SUB_SAT_ # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_sub_sat_" # T), !cast<ClangBuiltin>("int_postrisc_sub_sat_" # T), Ty, Ty, Ty>;
    defm CMP_EQ_  # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_cmp_eq_"  # T), !cast<ClangBuiltin>("int_postrisc_cmp_eq_"  # T), Ty, Ty, Ty>;
    defm CMP_LT_  # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_cmp_lt_"  # T), !cast<ClangBuiltin>("int_postrisc_cmp_lt_"  # T), Ty, Ty, Ty>;
    defm AVG_     # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_avg_"     # T), !cast<ClangBuiltin>("int_postrisc_avg_"     # T), Ty, Ty, Ty>;
    defm SRA_     # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_sra_"     # T), !cast<ClangBuiltin>("int_postrisc_sra_"     # T), Ty, Ty, Ty>;
    defm MIN_     # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_min_"     # T), !cast<ClangBuiltin>("int_postrisc_min_"     # T), Ty, Ty, Ty>;
    defm MAX_     # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_max_"     # T), !cast<ClangBuiltin>("int_postrisc_max_"     # T), Ty, Ty, Ty>;

    def : Pat<(Ty (avgceils Ty:$rb, Ty:$rc)), (!cast<InstBase>("AVG_"     # NAME) GR:$rb, GR:$rc)>;
    def : Pat<(Ty (sra      Ty:$rb, Ty:$rc)), (!cast<InstBase>("SRA_"     # NAME) GR:$rb, GR:$rc)>;
    def : Pat<(Ty (smin     Ty:$rb, Ty:$rc)), (!cast<InstBase>("MIN_"     # NAME) GR:$rb, GR:$rc)>;
    def : Pat<(Ty (smax     Ty:$rb, Ty:$rc)), (!cast<InstBase>("MAX_"     # NAME) GR:$rb, GR:$rc)>;
    def : Pat<(Ty (saddsat  Ty:$rb, Ty:$rc)), (!cast<InstBase>("ADD_SAT_" # NAME) GR:$rb, GR:$rc)>;
    def : Pat<(Ty (ssubsat  Ty:$rb, Ty:$rc)), (!cast<InstBase>("SUB_SAT_" # NAME) GR:$rb, GR:$rc)>;
}

defm VI8  : SINT_SIMD_INTRUCTIONS<"vi8",  v16i8>;
defm VI16 : SINT_SIMD_INTRUCTIONS<"vi16", v8i16>;
defm VI32 : SINT_SIMD_INTRUCTIONS<"vi32", v4i32>;
defm VI64 : SINT_SIMD_INTRUCTIONS<"vi64", v2i64>;

multiclass UINT_SIMD_INTRUCTIONS<string T, ValueType Ty>
{
    defm ADD_        # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_add_"        # T), !cast<ClangBuiltin>("int_postrisc_add_"        # T), Ty, Ty, Ty>;
    defm SUB_        # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_sub_"        # T), !cast<ClangBuiltin>("int_postrisc_sub_"        # T), Ty, Ty, Ty>;
    defm ADDC_       # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_addc_"       # T), !cast<ClangBuiltin>("int_postrisc_addc_"       # T), Ty, Ty, Ty>;
    defm SUBB_       # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_subb_"       # T), !cast<ClangBuiltin>("int_postrisc_subb_"       # T), Ty, Ty, Ty>;
    defm ADD_SAT_    # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_add_sat_"    # T), !cast<ClangBuiltin>("int_postrisc_add_sat_"    # T), Ty, Ty, Ty>;
    defm SUB_SAT_    # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_sub_sat_"    # T), !cast<ClangBuiltin>("int_postrisc_sub_sat_"    # T), Ty, Ty, Ty>;
    defm CMP_LT_     # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_cmp_lt_"     # T), !cast<ClangBuiltin>("int_postrisc_cmp_lt_"     # T), Ty, Ty, Ty>;
    defm AVG_        # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_avg_"        # T), !cast<ClangBuiltin>("int_postrisc_avg_"        # T), Ty, Ty, Ty>;
    defm ROL_        # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_rol_"        # T), !cast<ClangBuiltin>("int_postrisc_rol_"        # T), Ty, Ty, Ty>;
    defm ROR_        # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_ror_"        # T), !cast<ClangBuiltin>("int_postrisc_ror_"        # T), Ty, Ty, Ty>;
    defm SLL_        # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_sll_"        # T), !cast<ClangBuiltin>("int_postrisc_sll_"        # T), Ty, Ty, Ty>;
    defm SRL_        # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_srl_"        # T), !cast<ClangBuiltin>("int_postrisc_srl_"        # T), Ty, Ty, Ty>;
    defm MIN_        # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_min_"        # T), !cast<ClangBuiltin>("int_postrisc_min_"        # T), Ty, Ty, Ty>;
    defm MAX_        # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_max_"        # T), !cast<ClangBuiltin>("int_postrisc_max_"        # T), Ty, Ty, Ty>;
    defm MERGE_LOW_  # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_merge_low_"  # T), !cast<ClangBuiltin>("int_postrisc_merge_low_"  # T), Ty, Ty, Ty>;
    defm MERGE_HIGH_ # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_merge_high_" # T), !cast<ClangBuiltin>("int_postrisc_merge_high_" # T), Ty, Ty, Ty>;

    def : Pat<(Ty (add      Ty:$rb, Ty:$rc)), (!cast<InstBase>("ADD_"     # NAME) GR:$rb, GR:$rc)>;
    def : Pat<(Ty (sub      Ty:$rb, Ty:$rc)), (!cast<InstBase>("SUB_"     # NAME) GR:$rb, GR:$rc)>;
    def : Pat<(Ty (avgceilu Ty:$rb, Ty:$rc)), (!cast<InstBase>("AVG_"     # NAME) GR:$rb, GR:$rc)>;
    def : Pat<(Ty (shl      Ty:$rb, Ty:$rc)), (!cast<InstBase>("SLL_"     # NAME) GR:$rb, GR:$rc)>;
    def : Pat<(Ty (srl      Ty:$rb, Ty:$rc)), (!cast<InstBase>("SRL_"     # NAME) GR:$rb, GR:$rc)>;
    def : Pat<(Ty (umin     Ty:$rb, Ty:$rc)), (!cast<InstBase>("MIN_"     # NAME) GR:$rb, GR:$rc)>;
    def : Pat<(Ty (umax     Ty:$rb, Ty:$rc)), (!cast<InstBase>("MAX_"     # NAME) GR:$rb, GR:$rc)>;
    def : Pat<(Ty (uaddsat  Ty:$rb, Ty:$rc)), (!cast<InstBase>("ADD_SAT_" # NAME) GR:$rb, GR:$rc)>;
    def : Pat<(Ty (usubsat  Ty:$rb, Ty:$rc)), (!cast<InstBase>("SUB_SAT_" # NAME) GR:$rb, GR:$rc)>;
}

defm VU8  : UINT_SIMD_INTRUCTIONS<"vu8",  v16i8>;
defm VU16 : UINT_SIMD_INTRUCTIONS<"vu16", v8i16>;
defm VU32 : UINT_SIMD_INTRUCTIONS<"vu32", v4i32>;
defm VU64 : UINT_SIMD_INTRUCTIONS<"vu64", v2i64>;

//===----------------------------------------------------------------------===//
// integer SIMD immediate shifts
// note: build_imm_vector_64 requires explicit i64 immediates
//===----------------------------------------------------------------------===//
defm SRA_IMM_VI64 : BUILTIN_SHIFT_IMM<opcode_sra_imm_vi64, int_postrisc_sra_imm_vi64, v2i64>;
defm SLL_IMM_VU64 : BUILTIN_SHIFT_IMM<opcode_sll_imm_vu64, int_postrisc_sll_imm_vu64, v2i64>;
defm SRL_IMM_VU64 : BUILTIN_SHIFT_IMM<opcode_srl_imm_vu64, int_postrisc_srl_imm_vu64, v2i64>;

def build_imm_vector_64 : PatFrag<(ops node:$imm), (v2i64 (build_vector
          node:$imm, node:$imm))>;

def cast_shift_i64_to_i32 : SDNodeXForm<imm, [{
  return getU32Imm(N->getZExtValue(), SDLoc(N));
}]>;

def : Pat<(v2i64 (shl v2i64:$rb, (build_imm_vector_64 uimm7i64:$shcnt))), (SLL_IMM_VU64 GR:$rb, (cast_shift_i64_to_i32 $shcnt))>;
def : Pat<(v2i64 (srl v2i64:$rb, (build_imm_vector_64 uimm7i64:$shcnt))), (SRL_IMM_VU64 GR:$rb, (cast_shift_i64_to_i32 $shcnt))>;
def : Pat<(v2i64 (sra v2i64:$rb, (build_imm_vector_64 uimm7i64:$shcnt))), (SRA_IMM_VI64 GR:$rb, (cast_shift_i64_to_i32 $shcnt))>;

defm SRA_IMM_VI32 : BUILTIN_SHIFT_IMM<opcode_sra_imm_vi32, int_postrisc_sra_imm_vi32, v4i32>;
defm SLL_IMM_VU32 : BUILTIN_SHIFT_IMM<opcode_sll_imm_vu32, int_postrisc_sll_imm_vu32, v4i32>;
defm SRL_IMM_VU32 : BUILTIN_SHIFT_IMM<opcode_srl_imm_vu32, int_postrisc_srl_imm_vu32, v4i32>;

def build_imm_vector_32 : PatFrag<(ops node:$imm), (v4i32 (build_vector
          node:$imm, node:$imm, node:$imm, node:$imm))>;

def : Pat<(v4i32 (shl v4i32:$rb, (build_imm_vector_32 uimm7:$shcnt))), (SLL_IMM_VU32 GR:$rb, uimm7:$shcnt)>;
def : Pat<(v4i32 (srl v4i32:$rb, (build_imm_vector_32 uimm7:$shcnt))), (SRL_IMM_VU32 GR:$rb, uimm7:$shcnt)>;
def : Pat<(v4i32 (sra v4i32:$rb, (build_imm_vector_32 uimm7:$shcnt))), (SRA_IMM_VI32 GR:$rb, uimm7:$shcnt)>;

defm SRA_IMM_VI16 : BUILTIN_SHIFT_IMM<opcode_sra_imm_vi16, int_postrisc_sra_imm_vi16, v8i16>;
defm SLL_IMM_VU16 : BUILTIN_SHIFT_IMM<opcode_sll_imm_vu16, int_postrisc_sll_imm_vu16, v8i16>;
defm SRL_IMM_VU16 : BUILTIN_SHIFT_IMM<opcode_srl_imm_vu16, int_postrisc_srl_imm_vu16, v8i16>;

def build_imm_vector_16 : PatFrag<(ops node:$imm), (v8i16 (build_vector
          node:$imm, node:$imm, node:$imm, node:$imm,
          node:$imm, node:$imm, node:$imm, node:$imm))>;

def : Pat<(v8i16 (shl v8i16:$rb, (build_imm_vector_16 uimm7:$shcnt))), (SLL_IMM_VU16 GR:$rb, uimm7:$shcnt)>;
def : Pat<(v8i16 (srl v8i16:$rb, (build_imm_vector_16 uimm7:$shcnt))), (SRL_IMM_VU16 GR:$rb, uimm7:$shcnt)>;
def : Pat<(v8i16 (sra v8i16:$rb, (build_imm_vector_16 uimm7:$shcnt))), (SRA_IMM_VI16 GR:$rb, uimm7:$shcnt)>;

defm SRA_IMM_VI8 : BUILTIN_SHIFT_IMM<opcode_sra_imm_vi8, int_postrisc_sra_imm_vi8, v16i8>;
defm SLL_IMM_VU8 : BUILTIN_SHIFT_IMM<opcode_sll_imm_vu8, int_postrisc_sll_imm_vu8, v16i8>;
defm SRL_IMM_VU8 : BUILTIN_SHIFT_IMM<opcode_srl_imm_vu8, int_postrisc_srl_imm_vu8, v16i8>;

def build_imm_vector_8  : PatFrag<(ops node:$imm), (v16i8 (build_vector
          node:$imm, node:$imm, node:$imm, node:$imm,
          node:$imm, node:$imm, node:$imm, node:$imm,
          node:$imm, node:$imm, node:$imm, node:$imm,
          node:$imm, node:$imm, node:$imm, node:$imm))>;

def : Pat<(v16i8 (shl v16i8:$rb, (build_imm_vector_8 uimm7:$shcnt))), (SLL_IMM_VU8 GR:$rb, uimm7:$shcnt)>;
def : Pat<(v16i8 (srl v16i8:$rb, (build_imm_vector_8 uimm7:$shcnt))), (SRL_IMM_VU8 GR:$rb, uimm7:$shcnt)>;
def : Pat<(v16i8 (sra v16i8:$rb, (build_imm_vector_8 uimm7:$shcnt))), (SRA_IMM_VI8 GR:$rb, uimm7:$shcnt)>;

//===----------------------------------------------------------------------===//
// integer SIMD mixed type conversions
//===----------------------------------------------------------------------===//
defm PACK_SAT_VI16  : BUILTIN_R3<opcode_pack_sat_vi16,  int_postrisc_pack_sat_vi16,  v16i8, v8i16, v8i16>;
defm PACK_USAT_V16  : BUILTIN_R3<opcode_pack_usat_vi16, int_postrisc_pack_usat_vi16, v16i8, v8i16, v8i16>;
defm PACK_SAT_VU16  : BUILTIN_R3<opcode_pack_sat_vu16,  int_postrisc_pack_sat_vu16,  v16i8, v8i16, v8i16>;
defm PACK_MOD_VU16  : BUILTIN_R3<opcode_pack_mod_vu16,  int_postrisc_pack_mod_vu16,  v16i8, v8i16, v8i16>;

defm PACK_SAT_VI32  : BUILTIN_R3<opcode_pack_sat_vi32,  int_postrisc_pack_sat_vi32,  v8i16, v4i32, v4i32>;
defm PACK_USAT_VI32 : BUILTIN_R3<opcode_pack_usat_vi32, int_postrisc_pack_usat_vi32, v8i16, v4i32, v4i32>;
defm PACK_SAT_VU32  : BUILTIN_R3<opcode_pack_sat_vu32,  int_postrisc_pack_sat_vu32,  v8i16, v4i32, v4i32>;
defm PACK_MOD_VU32  : BUILTIN_R3<opcode_pack_mod_vu32,  int_postrisc_pack_mod_vu32,  v8i16, v4i32, v4i32>;

defm PACK_SAT_VI64  : BUILTIN_R3<opcode_pack_sat_vi64,  int_postrisc_pack_sat_vi64,  v4i32, v2i64, v2i64>;
defm PACK_USAT_VI64 : BUILTIN_R3<opcode_pack_usat_vi64, int_postrisc_pack_usat_vi64, v4i32, v2i64, v2i64>;
defm PACK_SAT_VU64  : BUILTIN_R3<opcode_pack_sat_vu64,  int_postrisc_pack_sat_vu64,  v4i32, v2i64, v2i64>;
defm PACK_MOD_VU64  : BUILTIN_R3<opcode_pack_mod_vu64,  int_postrisc_pack_mod_vu64,  v4i32, v2i64, v2i64>;

defm UNPACK_LOW_VI8   : BUILTIN_R2<opcode_unpack_low_vi8,   int_postrisc_unpack_low_vi8,   v8i16, v16i8>;
defm UNPACK_HIGH_VI8  : BUILTIN_R2<opcode_unpack_high_vi8,  int_postrisc_unpack_high_vi8,  v8i16, v16i8>;
defm UNPACK_LOW_VU8   : BUILTIN_R2<opcode_unpack_low_vu8,   int_postrisc_unpack_low_vu8,   v8i16, v16i8>;
defm UNPACK_HIGH_VU8  : BUILTIN_R2<opcode_unpack_high_vu8,  int_postrisc_unpack_high_vu8,  v8i16, v16i8>;

defm UNPACK_LOW_VI16  : BUILTIN_R2<opcode_unpack_low_vi16,  int_postrisc_unpack_low_vi16,  v4i32, v8i16>;
defm UNPACK_HIGH_VI16 : BUILTIN_R2<opcode_unpack_high_vi16, int_postrisc_unpack_high_vi16, v4i32, v8i16>;
defm UNPACK_LOW_VU16  : BUILTIN_R2<opcode_unpack_low_vu16,  int_postrisc_unpack_low_vu16,  v4i32, v8i16>;
defm UNPACK_HIGH_VU16 : BUILTIN_R2<opcode_unpack_high_vu16, int_postrisc_unpack_high_vu16, v4i32, v8i16>;

defm UNPACK_LOW_VI32  : BUILTIN_R2<opcode_unpack_low_vi32,  int_postrisc_unpack_low_vi32,  v2i64, v4i32>;
defm UNPACK_HIGH_VI32 : BUILTIN_R2<opcode_unpack_high_vi32, int_postrisc_unpack_high_vi32, v2i64, v4i32>;
defm UNPACK_LOW_VU32  : BUILTIN_R2<opcode_unpack_low_vu32,  int_postrisc_unpack_low_vu32,  v2i64, v4i32>;
defm UNPACK_HIGH_VU32 : BUILTIN_R2<opcode_unpack_high_vu32, int_postrisc_unpack_high_vu32, v2i64, v4i32>;

defm PERM_VU8 : BUILTIN_R4<opcode_perm, int_postrisc_perm_vu8, v16i8, v16i8, v16i8, v16i8>;
