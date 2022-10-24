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

//===----------------------------------------------------------------------===//
// Compare reg-reg and nullify
//===----------------------------------------------------------------------===//
multiclass CompareRegRegAndNullify<nul_rr_opx opxCode, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_Rab<opcode_nul_rr, opxCode.value,
           (outs), (ins GR:$ra, GR:$rb, uimm5:$bb_yes, uimm5:$bb_no),
           !strconcat(opxCode.mnem, " $ra, $rb, $bb_yes, $bb_no"),
           [], itin>;
}

defm NUL_EQ_I32 : CompareRegRegAndNullify<opcode_nul_eq_i32>;
defm NUL_NE_I32 : CompareRegRegAndNullify<opcode_nul_ne_i32>;
defm NUL_LT_I32 : CompareRegRegAndNullify<opcode_nul_lt_i32>;
defm NUL_LE_I32 : CompareRegRegAndNullify<opcode_nul_le_i32>;
defm NUL_LT_U32 : CompareRegRegAndNullify<opcode_nul_lt_u32>;
defm NUL_LE_U32 : CompareRegRegAndNullify<opcode_nul_le_u32>;

defm NUL_EQ_I64 : CompareRegRegAndNullify<opcode_nul_eq_i64>;
defm NUL_NE_I64 : CompareRegRegAndNullify<opcode_nul_ne_i64>;
defm NUL_LT_I64 : CompareRegRegAndNullify<opcode_nul_lt_i64>;
defm NUL_LE_I64 : CompareRegRegAndNullify<opcode_nul_le_i64>;
defm NUL_LT_U64 : CompareRegRegAndNullify<opcode_nul_lt_u64>;
defm NUL_LE_U64 : CompareRegRegAndNullify<opcode_nul_le_u64>;

multiclass CompareRegRegAndNullifyI128<nul_i128_opx opxCode, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_Rab<opcode_nul_i128, opxCode.value,
           (outs), (ins GR:$ra, GR:$rb, uimm5:$bb_yes, uimm5:$bb_no),
           !strconcat(opxCode.mnem, " $ra, $rb, $bb_yes, $bb_no"),
           [], itin>;
}

defm NUL_EQ_I128 : CompareRegRegAndNullifyI128<opcode_nul_eq_i128>;
defm NUL_NE_I128 : CompareRegRegAndNullifyI128<opcode_nul_ne_i128>;
defm NUL_LT_I128 : CompareRegRegAndNullifyI128<opcode_nul_lt_i128>;
defm NUL_LE_I128 : CompareRegRegAndNullifyI128<opcode_nul_le_i128>;
defm NUL_LT_U128 : CompareRegRegAndNullifyI128<opcode_nul_lt_u128>;
defm NUL_LE_U128 : CompareRegRegAndNullifyI128<opcode_nul_le_u128>;

defm NUL_BS : CompareRegRegAndNullify<opcode_nul_bs>;
defm NUL_BC : CompareRegRegAndNullify<opcode_nul_bc>;

//===----------------------------------------------------------------------===//
// Compare reg-bitimm and nullify
//===----------------------------------------------------------------------===//
multiclass CompareRegBitAndNullify<nul_rr_opx opxCode, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_Rab<opcode_nul_rr, opxCode.value,
           (outs), (ins GR:$ra, uimm7:$rb, uimm5:$bb_yes, uimm5:$bb_no),
           !strconcat(opxCode.mnem, " $ra, $rb, $bb_yes, $bb_no"),
           [], itin>;
}

defm NUL_BS_IMM : CompareRegBitAndNullify<opcode_nul_bs_imm>;
defm NUL_BC_IMM : CompareRegBitAndNullify<opcode_nul_bc_imm>;

//===----------------------------------------------------------------------===//
// Compare immediate and nullify
//===----------------------------------------------------------------------===//
multiclass CompareRegImmAndNullify
  <fused_opx opxCode, Operand immOp, Operand immOpEx, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_RaIMM<opxCode,
           (outs), (ins GR:$ra, immOp:$imm, uimm5:$bb_yes, uimm5:$bb_no),
           !strconcat(opxCode.mnem, " $ra, $imm, $bb_yes, $bb_no"),
           [], itin>;

  def NAME # _EXT : Nullify_RaIMM_ext<opxCode,
           (outs), (ins GR:$ra, immOpEx:$imm, uimm5:$bb_yes, uimm5:$bb_no),
           !strconcat(opxCode.mnem, ".l $ra, $imm, $bb_yes, $bb_no"),
           [], itin>;
}

defm NUL_EQ_IMM_I32 : CompareRegImmAndNullify<opcode_nul_eq_imm_i32, simm11i32, simm11i32_ext>;
defm NUL_NE_IMM_I32 : CompareRegImmAndNullify<opcode_nul_ne_imm_i32, simm11i32, simm11i32_ext>;
defm NUL_LT_IMM_I32 : CompareRegImmAndNullify<opcode_nul_lt_imm_i32, simm11i32, simm11i32_ext>;
defm NUL_GT_IMM_I32 : CompareRegImmAndNullify<opcode_nul_gt_imm_i32, simm11i32, simm11i32_ext>;
defm NUL_LT_IMM_U32 : CompareRegImmAndNullify<opcode_nul_lt_imm_u32, uimm11i32, uimm11i32_ext>;
defm NUL_GT_IMM_U32 : CompareRegImmAndNullify<opcode_nul_gt_imm_u32, uimm11i32, uimm11i32_ext>;

defm NUL_EQ_IMM_I64 : CompareRegImmAndNullify<opcode_nul_eq_imm_i64, simm11, simm11_ext>;
defm NUL_NE_IMM_I64 : CompareRegImmAndNullify<opcode_nul_ne_imm_i64, simm11, simm11_ext>;
defm NUL_LT_IMM_I64 : CompareRegImmAndNullify<opcode_nul_lt_imm_i64, simm11, simm11_ext>;
defm NUL_GT_IMM_I64 : CompareRegImmAndNullify<opcode_nul_gt_imm_i64, simm11, simm11_ext>;
defm NUL_LT_IMM_U64 : CompareRegImmAndNullify<opcode_nul_lt_imm_u64, uimm11, uimm11_ext>;
defm NUL_GT_IMM_U64 : CompareRegImmAndNullify<opcode_nul_gt_imm_u64, uimm11, uimm11_ext>;

defm NUL_EQ_IMM_I128 : CompareRegImmAndNullify<opcode_nul_eq_imm_i128, simm11i128, simm11i128_ext>;
defm NUL_NE_IMM_I128 : CompareRegImmAndNullify<opcode_nul_ne_imm_i128, simm11i128, simm11i128_ext>;
defm NUL_LT_IMM_I128 : CompareRegImmAndNullify<opcode_nul_lt_imm_i128, simm11i128, simm11i128_ext>;
defm NUL_GT_IMM_I128 : CompareRegImmAndNullify<opcode_nul_gt_imm_i128, simm11i128, simm11i128_ext>;
defm NUL_LT_IMM_U128 : CompareRegImmAndNullify<opcode_nul_lt_imm_u128, uimm11i128, uimm11i128_ext>;
defm NUL_GT_IMM_U128 : CompareRegImmAndNullify<opcode_nul_gt_imm_u128, uimm11i128, uimm11i128_ext>;

defm NUL_MASK_ALL    : CompareRegImmAndNullify<opcode_nul_mask_all,    uimm11, uimm11_ext>;
defm NUL_MASK_NOTALL : CompareRegImmAndNullify<opcode_nul_mask_notall, uimm11, uimm11_ext>;
defm NUL_MASK_NONE   : CompareRegImmAndNullify<opcode_nul_mask_none,   uimm11, uimm11_ext>;
defm NUL_MASK_ANY    : CompareRegImmAndNullify<opcode_nul_mask_any,    uimm11, uimm11_ext>;

//===----------------------------------------------------------------------===//
// fp compare and nullification
//===----------------------------------------------------------------------===//
multiclass CompareRegRegAndNullifyF32<nul_f32_opx opxCode, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_Rab<opcode_nul_f32, opxCode.value,
           (outs), (ins GR:$ra, GR:$rb, uimm5:$bb_yes, uimm5:$bb_no),
           !strconcat(opxCode.mnem, " $ra, $rb, $bb_yes, $bb_no"),
           [], itin>;
}

defm NUL_OEQ_F32 : CompareRegRegAndNullifyF32<opcode_nul_oeq_f32>;
defm NUL_ONE_F32 : CompareRegRegAndNullifyF32<opcode_nul_one_f32>;
defm NUL_OLT_F32 : CompareRegRegAndNullifyF32<opcode_nul_olt_f32>;
defm NUL_OLE_F32 : CompareRegRegAndNullifyF32<opcode_nul_ole_f32>;
defm NUL_O_F32   : CompareRegRegAndNullifyF32<opcode_nul_o_f32>;
defm NUL_UEQ_F32 : CompareRegRegAndNullifyF32<opcode_nul_ueq_f32>;
defm NUL_UNE_F32 : CompareRegRegAndNullifyF32<opcode_nul_une_f32>;
defm NUL_ULT_F32 : CompareRegRegAndNullifyF32<opcode_nul_ult_f32>;
defm NUL_ULE_F32 : CompareRegRegAndNullifyF32<opcode_nul_ule_f32>;
defm NUL_U_F32   : CompareRegRegAndNullifyF32<opcode_nul_u_f32>;

multiclass CompareRegRegAndNullifyF64<nul_f64_opx opxCode, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_Rab<opcode_nul_f64, opxCode.value,
           (outs), (ins GR:$ra, GR:$rb, uimm5:$bb_yes, uimm5:$bb_no),
           !strconcat(opxCode.mnem, " $ra, $rb, $bb_yes, $bb_no"),
           [], itin>;
}

defm NUL_OEQ_F64 : CompareRegRegAndNullifyF64<opcode_nul_oeq_f64>;
defm NUL_ONE_F64 : CompareRegRegAndNullifyF64<opcode_nul_one_f64>;
defm NUL_OLT_F64 : CompareRegRegAndNullifyF64<opcode_nul_olt_f64>;
defm NUL_OLE_F64 : CompareRegRegAndNullifyF64<opcode_nul_ole_f64>;
defm NUL_O_F64   : CompareRegRegAndNullifyF64<opcode_nul_o_f64>;
defm NUL_UEQ_F64 : CompareRegRegAndNullifyF64<opcode_nul_ueq_f64>;
defm NUL_UNE_F64 : CompareRegRegAndNullifyF64<opcode_nul_une_f64>;
defm NUL_ULT_F64 : CompareRegRegAndNullifyF64<opcode_nul_ult_f64>;
defm NUL_ULE_F64 : CompareRegRegAndNullifyF64<opcode_nul_ule_f64>;
defm NUL_U_F64   : CompareRegRegAndNullifyF64<opcode_nul_u_f64>;

multiclass CompareRegRegAndNullifyF128<nul_f128_opx opxCode, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_Rab<opcode_nul_f128, opxCode.value,
           (outs), (ins GR:$ra, GR:$rb, uimm5:$bb_yes, uimm5:$bb_no),
           !strconcat(opxCode.mnem, " $ra, $rb, $bb_yes, $bb_no"),
           [], itin>;
}

defm NUL_OEQ_F128 : CompareRegRegAndNullifyF128<opcode_nul_oeq_f128>;
defm NUL_ONE_F128 : CompareRegRegAndNullifyF128<opcode_nul_one_f128>;
defm NUL_OLT_F128 : CompareRegRegAndNullifyF128<opcode_nul_olt_f128>;
defm NUL_OLE_F128 : CompareRegRegAndNullifyF128<opcode_nul_ole_f128>;
defm NUL_O_F128   : CompareRegRegAndNullifyF128<opcode_nul_o_f128>;
defm NUL_UEQ_F128 : CompareRegRegAndNullifyF128<opcode_nul_ueq_f128>;
defm NUL_UNE_F128 : CompareRegRegAndNullifyF128<opcode_nul_une_f128>;
defm NUL_ULT_F128 : CompareRegRegAndNullifyF128<opcode_nul_ult_f128>;
defm NUL_ULE_F128 : CompareRegRegAndNullifyF128<opcode_nul_ule_f128>;
defm NUL_U_F128   : CompareRegRegAndNullifyF128<opcode_nul_u_f128>;

//===----------------------------------------------------------------------===//
// fp classify and nullification
//===----------------------------------------------------------------------===//
multiclass CompareFPImmAndNullifyF32<nul_f32_opx opxCode, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_Rab<opcode_nul_f32, opxCode.value,
           (outs), (ins GR:$ra, uimm7:$rb, uimm5:$bb_yes, uimm5:$bb_no),
           !strconcat(opxCode.mnem, " $ra, $rb, $bb_yes, $bb_no"),
           [], itin>;
}
defm NUL_CLASS_F32 : CompareFPImmAndNullifyF32<opcode_nul_class_f32>;

multiclass CompareFPImmAndNullifyF64<nul_f64_opx opxCode, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_Rab<opcode_nul_f64, opxCode.value,
           (outs), (ins GR:$ra, uimm7:$rb, uimm5:$bb_yes, uimm5:$bb_no),
           !strconcat(opxCode.mnem, " $ra, $rb, $bb_yes, $bb_no"),
           [], itin>;
}
defm NUL_CLASS_F64 : CompareFPImmAndNullifyF64<opcode_nul_class_f64>;

multiclass CompareFPImmAndNullifyF128<nul_f128_opx opxCode, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_Rab<opcode_nul_f128, opxCode.value,
           (outs), (ins GR:$ra, uimm7:$rb, uimm5:$bb_yes, uimm5:$bb_no),
           !strconcat(opxCode.mnem, " $ra, $rb, $bb_yes, $bb_no"),
           [], itin>;
}
defm NUL_CLASS_F128 : CompareFPImmAndNullifyF128<opcode_nul_class_f128>;
