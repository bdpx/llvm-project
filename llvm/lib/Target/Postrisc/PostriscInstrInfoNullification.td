//=== PostriscInstrInfoNullification.td - Target Description for Postrisc  ===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file describes the Postrisc nullification instructions.
//
//===----------------------------------------------------------------------===//


// immediate nullification distance
def nul_distance_xform : SDNodeXForm<imm, [{
  return getI64Imm(N->getZExtValue(), SDLoc(N));
}]>;
def nul_distance : Operand<i32>, IntImmLeaf<i32, [{ return isZextInt(Imm, 5); }], nul_distance_xform> {
  let DecoderMethod = "DecodeUIMM<5>";
}

//===----------------------------------------------------------------------===//
// compare and nullify reg-reg
//===----------------------------------------------------------------------===//
multiclass CompareRegRegAndNullify32<nul_32_opx opxCode, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_Rab<opcode_nul_32, opxCode.value,
           (outs), (ins GR:$ra, GR:$rb, nul_distance:$bb_yes, nul_distance:$bb_no),
           !strconcat(opxCode.mnem, " $ra, $rb, $bb_yes, $bb_no"),
           [], itin>;
}

defm NUL_EQ_I32  : CompareRegRegAndNullify32 <opcode_nul_eq_i32>;
defm NUL_NE_I32  : CompareRegRegAndNullify32 <opcode_nul_ne_i32>;
defm NUL_LT_I32  : CompareRegRegAndNullify32 <opcode_nul_lt_i32>;
defm NUL_LT_U32  : CompareRegRegAndNullify32 <opcode_nul_lt_u32>;
defm NUL_GE_I32  : CompareRegRegAndNullify32 <opcode_nul_ge_i32>;
defm NUL_GE_U32  : CompareRegRegAndNullify32 <opcode_nul_ge_u32>;
defm NUL_OEQ_F32 : CompareRegRegAndNullify32 <opcode_nul_oeq_f32>;
defm NUL_ONE_F32 : CompareRegRegAndNullify32 <opcode_nul_one_f32>;
defm NUL_OLT_F32 : CompareRegRegAndNullify32 <opcode_nul_olt_f32>;
defm NUL_OGE_F32 : CompareRegRegAndNullify32 <opcode_nul_oge_f32>;
defm NUL_O_F32   : CompareRegRegAndNullify32 <opcode_nul_o_f32>;
defm NUL_UEQ_F32 : CompareRegRegAndNullify32 <opcode_nul_ueq_f32>;
defm NUL_UNE_F32 : CompareRegRegAndNullify32 <opcode_nul_une_f32>;
defm NUL_ULT_F32 : CompareRegRegAndNullify32 <opcode_nul_ult_f32>;
defm NUL_UGE_F32 : CompareRegRegAndNullify32 <opcode_nul_uge_f32>;
defm NUL_U_F32   : CompareRegRegAndNullify32 <opcode_nul_u_f32>;

multiclass CompareRegRegAndNullify64<nul_64_opx opxCode, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_Rab<opcode_nul_64, opxCode.value,
           (outs), (ins GR:$ra, GR:$rb, nul_distance:$bb_yes, nul_distance:$bb_no),
           !strconcat(opxCode.mnem, " $ra, $rb, $bb_yes, $bb_no"),
           [], itin>;
}

defm NUL_EQ_I64  : CompareRegRegAndNullify64 <opcode_nul_eq_i64>;
defm NUL_NE_I64  : CompareRegRegAndNullify64 <opcode_nul_ne_i64>;
defm NUL_LT_I64  : CompareRegRegAndNullify64 <opcode_nul_lt_i64>;
defm NUL_LT_U64  : CompareRegRegAndNullify64 <opcode_nul_lt_u64>;
defm NUL_GE_I64  : CompareRegRegAndNullify64 <opcode_nul_ge_i64>;
defm NUL_GE_U64  : CompareRegRegAndNullify64 <opcode_nul_ge_u64>;
defm NUL_OEQ_F64 : CompareRegRegAndNullify64 <opcode_nul_oeq_f64>;
defm NUL_ONE_F64 : CompareRegRegAndNullify64 <opcode_nul_one_f64>;
defm NUL_OLT_F64 : CompareRegRegAndNullify64 <opcode_nul_olt_f64>;
defm NUL_OGE_F64 : CompareRegRegAndNullify64 <opcode_nul_oge_f64>;
defm NUL_O_F64   : CompareRegRegAndNullify64 <opcode_nul_o_f64>;
defm NUL_UEQ_F64 : CompareRegRegAndNullify64 <opcode_nul_ueq_f64>;
defm NUL_UNE_F64 : CompareRegRegAndNullify64 <opcode_nul_une_f64>;
defm NUL_ULT_F64 : CompareRegRegAndNullify64 <opcode_nul_ult_f64>;
defm NUL_UGE_F64 : CompareRegRegAndNullify64 <opcode_nul_uge_f64>;
defm NUL_U_F64   : CompareRegRegAndNullify64 <opcode_nul_u_f64>;

multiclass CompareRegRegAndNullify128<nul_128_opx opxCode, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_Rab<opcode_nul_128, opxCode.value,
           (outs), (ins GR:$ra, GR:$rb, nul_distance:$bb_yes, nul_distance:$bb_no),
           !strconcat(opxCode.mnem, " $ra, $rb, $bb_yes, $bb_no"),
           [], itin>;
}

defm NUL_EQ_I128  : CompareRegRegAndNullify128 <opcode_nul_eq_i128>;
defm NUL_NE_I128  : CompareRegRegAndNullify128 <opcode_nul_ne_i128>;
defm NUL_LT_I128  : CompareRegRegAndNullify128 <opcode_nul_lt_i128>;
defm NUL_LT_U128  : CompareRegRegAndNullify128 <opcode_nul_lt_u128>;
defm NUL_GE_I128  : CompareRegRegAndNullify128 <opcode_nul_ge_i128>;
defm NUL_GE_U128  : CompareRegRegAndNullify128 <opcode_nul_ge_u128>;
defm NUL_OEQ_F128 : CompareRegRegAndNullify128 <opcode_nul_oeq_f128>;
defm NUL_ONE_F128 : CompareRegRegAndNullify128 <opcode_nul_one_f128>;
defm NUL_OLT_F128 : CompareRegRegAndNullify128 <opcode_nul_olt_f128>;
defm NUL_OGE_F128 : CompareRegRegAndNullify128 <opcode_nul_oge_f128>;
defm NUL_O_F128   : CompareRegRegAndNullify128 <opcode_nul_o_f128>;
defm NUL_UEQ_F128 : CompareRegRegAndNullify128 <opcode_nul_ueq_f128>;
defm NUL_UNE_F128 : CompareRegRegAndNullify128 <opcode_nul_une_f128>;
defm NUL_ULT_F128 : CompareRegRegAndNullify128 <opcode_nul_ult_f128>;
defm NUL_UGE_F128 : CompareRegRegAndNullify128 <opcode_nul_uge_f128>;
defm NUL_U_F128   : CompareRegRegAndNullify128 <opcode_nul_u_f128>;


//===----------------------------------------------------------------------===//
// Compare immediate and nullify
//===----------------------------------------------------------------------===//
multiclass CompareRegImmAndNullify
  <fused_opx opxCode, Operand immOp, Operand immOpEx, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_RaIMM<opxCode,
           (outs), (ins GR:$ra, immOp:$imm, nul_distance:$bb_yes, nul_distance:$bb_no),
           !strconcat(opxCode.mnem, " $ra, $imm, $bb_yes, $bb_no"),
           [], itin>;

  def NAME # _EXT : Nullify_RaIMM_ext<opxCode,
           (outs), (ins GR:$ra, immOpEx:$imm, nul_distance:$bb_yes, nul_distance:$bb_no),
           !strconcat(opxCode.mnem, ".l $ra, $imm, $bb_yes, $bb_no"),
           [], itin>;
}

defm NUL_EQ_IMM_I32 : CompareRegImmAndNullify<opcode_nul_eq_imm_i32, simm11i32, simm11i32_ext>;
defm NUL_NE_IMM_I32 : CompareRegImmAndNullify<opcode_nul_ne_imm_i32, simm11i32, simm11i32_ext>;
defm NUL_LT_IMM_I32 : CompareRegImmAndNullify<opcode_nul_lt_imm_i32, simm11i32, simm11i32_ext>;
defm NUL_LT_IMM_U32 : CompareRegImmAndNullify<opcode_nul_lt_imm_u32, uimm11i32, uimm11i32_ext>;
defm NUL_GE_IMM_I32 : CompareRegImmAndNullify<opcode_nul_ge_imm_i32, simm11i32, simm11i32_ext>;
defm NUL_GE_IMM_U32 : CompareRegImmAndNullify<opcode_nul_ge_imm_u32, uimm11i32, uimm11i32_ext>;

defm NUL_EQ_IMM_I64 : CompareRegImmAndNullify<opcode_nul_eq_imm_i64, simm11, simm11_ext>;
defm NUL_NE_IMM_I64 : CompareRegImmAndNullify<opcode_nul_ne_imm_i64, simm11, simm11_ext>;
defm NUL_LT_IMM_I64 : CompareRegImmAndNullify<opcode_nul_lt_imm_i64, simm11, simm11_ext>;
defm NUL_LT_IMM_U64 : CompareRegImmAndNullify<opcode_nul_lt_imm_u64, uimm11, uimm11_ext>;
defm NUL_GE_IMM_I64 : CompareRegImmAndNullify<opcode_nul_ge_imm_i64, simm11, simm11_ext>;
defm NUL_GE_IMM_U64 : CompareRegImmAndNullify<opcode_nul_ge_imm_u64, uimm11, uimm11_ext>;

defm NUL_EQ_IMM_I128 : CompareRegImmAndNullify<opcode_nul_eq_imm_i128, simm11i128, simm11i128_ext>;
defm NUL_NE_IMM_I128 : CompareRegImmAndNullify<opcode_nul_ne_imm_i128, simm11i128, simm11i128_ext>;
defm NUL_LT_IMM_I128 : CompareRegImmAndNullify<opcode_nul_lt_imm_i128, simm11i128, simm11i128_ext>;
defm NUL_LT_IMM_U128 : CompareRegImmAndNullify<opcode_nul_lt_imm_u128, uimm11i128, uimm11i128_ext>;
defm NUL_GE_IMM_I128 : CompareRegImmAndNullify<opcode_nul_ge_imm_i128, simm11i128, simm11i128_ext>;
defm NUL_GE_IMM_U128 : CompareRegImmAndNullify<opcode_nul_ge_imm_u128, uimm11i128, uimm11i128_ext>;

defm NUL_MASK_ALL_I64    : CompareRegImmAndNullify<opcode_nul_mask_all,    uimm11, uimm11_ext>;
defm NUL_MASK_NOTALL_I64 : CompareRegImmAndNullify<opcode_nul_mask_notall, uimm11, uimm11_ext>;
defm NUL_MASK_NONE_I64   : CompareRegImmAndNullify<opcode_nul_mask_none,   uimm11, uimm11_ext>;
defm NUL_MASK_ANY_I64    : CompareRegImmAndNullify<opcode_nul_mask_any,    uimm11, uimm11_ext>;

// same masked nul-branches work for i32,i64,i128
// FIXME: can model different type immediates only via codegen
let isCodeGenOnly = 1 in {
  defm NUL_MASK_ALL_I32    : CompareRegImmAndNullify<opcode_nul_mask_all,    uimm11i32, uimm11i32_ext>;
  defm NUL_MASK_NOTALL_I32 : CompareRegImmAndNullify<opcode_nul_mask_notall, uimm11i32, uimm11i32_ext>;
  defm NUL_MASK_NONE_I32   : CompareRegImmAndNullify<opcode_nul_mask_none,   uimm11i32, uimm11i32_ext>;
  defm NUL_MASK_ANY_I32    : CompareRegImmAndNullify<opcode_nul_mask_any,    uimm11i32, uimm11i32_ext>;

  defm NUL_MASK_ALL_I128    : CompareRegImmAndNullify<opcode_nul_mask_all,    uimm11i128, uimm11i128_ext>;
  defm NUL_MASK_NOTALL_I128 : CompareRegImmAndNullify<opcode_nul_mask_notall, uimm11i128, uimm11i128_ext>;
  defm NUL_MASK_NONE_I128   : CompareRegImmAndNullify<opcode_nul_mask_none,   uimm11i128, uimm11i128_ext>;
  defm NUL_MASK_ANY_I128    : CompareRegImmAndNullify<opcode_nul_mask_any,    uimm11i128, uimm11i128_ext>;
}

//===----------------------------------------------------------------------===//
// Compare reg-bitimm and nullify
//===----------------------------------------------------------------------===//
multiclass CompareRegRegAndNullifyMisc<nul_misc_opx opxCode, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_Rab<opcode_nul_misc, opxCode.value,
           (outs), (ins GR:$ra, GR:$rb, nul_distance:$bb_yes, nul_distance:$bb_no),
           !strconcat(opxCode.mnem, " $ra, $rb, $bb_yes, $bb_no"),
           [], itin>;
}

defm NUL_BS : CompareRegRegAndNullifyMisc<opcode_nul_bs>;
defm NUL_BC : CompareRegRegAndNullifyMisc<opcode_nul_bc>;

multiclass CompareRegBitAndNullify<nul_misc_opx opxCode, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_Rab<opcode_nul_misc, opxCode.value,
           (outs), (ins GR:$ra, uimm7:$rb, nul_distance:$bb_yes, nul_distance:$bb_no),
           !strconcat(opxCode.mnem, " $ra, $rb, $bb_yes, $bb_no"),
           [], itin>;
}

defm NUL_BS_IMM : CompareRegBitAndNullify<opcode_nul_bs_imm>;
defm NUL_BC_IMM : CompareRegBitAndNullify<opcode_nul_bc_imm>;
