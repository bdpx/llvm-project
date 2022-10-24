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
multiclass CompareRegRegAndNullify<nullrr_opx opxCode, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_Rab<fused_opx_nullrr, opxCode.value,
           (outs), (ins GR:$ra, GR:$rb, uimm5:$bb_yes, uimm5:$bb_no),
           !strconcat(opxCode.mnem, "\t$ra, $rb, $bb_yes, $bb_no"),
           [], itin>;
}

defm NUL_EQ_D  : CompareRegRegAndNullify<nullrr_opx_nul_eq_d>;
defm NUL_NE_D  : CompareRegRegAndNullify<nullrr_opx_nul_ne_d>;
defm NULS_LT_D : CompareRegRegAndNullify<nullrr_opx_nuls_lt_d>;
defm NULS_LE_D : CompareRegRegAndNullify<nullrr_opx_nuls_le_d>;
defm NULU_LT_D : CompareRegRegAndNullify<nullrr_opx_nulu_lt_d>;
defm NULU_LE_D : CompareRegRegAndNullify<nullrr_opx_nulu_le_d>;

defm NUL_EQ_W  : CompareRegRegAndNullify<nullrr_opx_nul_eq_w>;
defm NUL_NE_W  : CompareRegRegAndNullify<nullrr_opx_nul_ne_w>;
defm NULS_LT_W : CompareRegRegAndNullify<nullrr_opx_nuls_lt_w>;
defm NULS_LE_W : CompareRegRegAndNullify<nullrr_opx_nuls_le_w>;
defm NULU_LT_W : CompareRegRegAndNullify<nullrr_opx_nulu_lt_w>;
defm NULU_LE_W : CompareRegRegAndNullify<nullrr_opx_nulu_le_w>;

defm NULBS   : CompareRegRegAndNullify<nullrr_opx_nul_bs>;
defm NULBC   : CompareRegRegAndNullify<nullrr_opx_nul_bc>;

//===----------------------------------------------------------------------===//
// Compare reg-bitimm and nullify
//===----------------------------------------------------------------------===//
multiclass CompareRegBitAndNullify<nullrr_opx opxCode, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_Rab<fused_opx_nullrr, opxCode.value,
           (outs), (ins GR:$ra, uimm7:$rb, uimm5:$bb_yes, uimm5:$bb_no),
           !strconcat(opxCode.mnem, "\t$ra, $rb, $bb_yes, $bb_no"),
           [], itin>;
}

defm NULBSI : CompareRegBitAndNullify<nullrr_opx_nul_bsi>;
defm NULBCI : CompareRegBitAndNullify<nullrr_opx_nul_bci>;

//===----------------------------------------------------------------------===//
// Compare immediate and nullify
//===----------------------------------------------------------------------===//
multiclass CompareRegImmAndNullify
  <fused_opx opxCode, Operand immOp, Operand immOpEx, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_RaIMM<opxCode,
           (outs), (ins GR:$ra, immOp:$imm, uimm5:$bb_yes, uimm5:$bb_no),
           !strconcat(opxCode.mnem, "\t$ra, $imm, $bb_yes, $bb_no"),
           [], itin>;

  def NAME # _EXT : Nullify_RaIMM_ext<opxCode,
           (outs), (ins GR:$ra, immOpEx:$imm, uimm5:$bb_yes, uimm5:$bb_no),
           !strconcat(opxCode.mnem, ".l\t$ra, $imm, $bb_yes, $bb_no"),
           [], itin>;
}

defm NULI_EQ_D  : CompareRegImmAndNullify<fused_opx_nuli_eq_d,      simm11, simm11_ext>;
defm NULI_NE_D  : CompareRegImmAndNullify<fused_opx_nuli_ne_d,      simm11, simm11_ext>;
defm NULSI_LT_D : CompareRegImmAndNullify<fused_opx_nulsi_lt_d,     simm11, simm11_ext>;
defm NULSI_GT_D : CompareRegImmAndNullify<fused_opx_nulsi_gt_d,     simm11, simm11_ext>;
defm NULUI_LT_D : CompareRegImmAndNullify<fused_opx_nului_lt_d,     uimm11, uimm11_ext>;
defm NULUI_GT_D : CompareRegImmAndNullify<fused_opx_nului_gt_d,     uimm11, uimm11_ext>;

defm NULI_EQ_W  : CompareRegImmAndNullify<fused_opx_nuli_eq_w,      simm11i32, simm11i32_ext>;
defm NULI_NE_W  : CompareRegImmAndNullify<fused_opx_nuli_ne_w,      simm11i32, simm11i32_ext>;
defm NULSI_LT_W : CompareRegImmAndNullify<fused_opx_nulsi_lt_w,     simm11i32, simm11i32_ext>;
defm NULSI_GT_W : CompareRegImmAndNullify<fused_opx_nulsi_gt_w,     simm11i32, simm11i32_ext>;
defm NULUI_LT_W : CompareRegImmAndNullify<fused_opx_nului_lt_w,     uimm11i32, uimm11i32_ext>;
defm NULUI_GT_W : CompareRegImmAndNullify<fused_opx_nului_gt_w,     uimm11i32, uimm11i32_ext>;

defm NULM_ALL    : CompareRegImmAndNullify<fused_opx_nulm_all,    uimm11, uimm11_ext>;
defm NULM_NOTALL : CompareRegImmAndNullify<fused_opx_nulm_notall, uimm11, uimm11_ext>;
defm NULM_NONE   : CompareRegImmAndNullify<fused_opx_nulm_none,   uimm11, uimm11_ext>;
defm NULM_ANY    : CompareRegImmAndNullify<fused_opx_nulm_any,    uimm11, uimm11_ext>;

//===----------------------------------------------------------------------===//
// fp compare and nullification
//===----------------------------------------------------------------------===//
multiclass CompareRegRegAndNullifyF32<nulfss_opx opxCode, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_Rab<fused_opx_nulfss, opxCode.value,
           (outs), (ins GR:$ra, GR:$rb, uimm5:$bb_yes, uimm5:$bb_no),
           !strconcat(opxCode.mnem, "\t$ra, $rb, $bb_yes, $bb_no"),
           [], itin>;
}

defm NULFO_EQ_SS : CompareRegRegAndNullifyF32<nulfss_opx_nulfo_eq_ss>;
defm NULFO_NE_SS : CompareRegRegAndNullifyF32<nulfss_opx_nulfo_ne_ss>;
defm NULFO_LT_SS : CompareRegRegAndNullifyF32<nulfss_opx_nulfo_lt_ss>;
defm NULFO_LE_SS : CompareRegRegAndNullifyF32<nulfss_opx_nulfo_le_ss>;
defm NULFO_SS    : CompareRegRegAndNullifyF32<nulfss_opx_nulfo_ss>;
defm NULFU_EQ_SS : CompareRegRegAndNullifyF32<nulfss_opx_nulfu_eq_ss>;
defm NULFU_NE_SS : CompareRegRegAndNullifyF32<nulfss_opx_nulfu_ne_ss>;
defm NULFU_LT_SS : CompareRegRegAndNullifyF32<nulfss_opx_nulfu_lt_ss>;
defm NULFU_LE_SS : CompareRegRegAndNullifyF32<nulfss_opx_nulfu_le_ss>;
defm NULFU_SS    : CompareRegRegAndNullifyF32<nulfss_opx_nulfu_ss>;

multiclass CompareRegRegAndNullifyF64<nulfsd_opx opxCode, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_Rab<fused_opx_nulfsd, opxCode.value,
           (outs), (ins GR:$ra, GR:$rb, uimm5:$bb_yes, uimm5:$bb_no),
           !strconcat(opxCode.mnem, "\t$ra, $rb, $bb_yes, $bb_no"),
           [], itin>;
}

defm NULFO_EQ_SD : CompareRegRegAndNullifyF64<nulfsd_opx_nulfo_eq_sd>;
defm NULFO_NE_SD : CompareRegRegAndNullifyF64<nulfsd_opx_nulfo_ne_sd>;
defm NULFO_LT_SD : CompareRegRegAndNullifyF64<nulfsd_opx_nulfo_lt_sd>;
defm NULFO_LE_SD : CompareRegRegAndNullifyF64<nulfsd_opx_nulfo_le_sd>;
defm NULFO_SD    : CompareRegRegAndNullifyF64<nulfsd_opx_nulfo_sd>;
defm NULFU_EQ_SD : CompareRegRegAndNullifyF64<nulfsd_opx_nulfu_eq_sd>;
defm NULFU_NE_SD : CompareRegRegAndNullifyF64<nulfsd_opx_nulfu_ne_sd>;
defm NULFU_LT_SD : CompareRegRegAndNullifyF64<nulfsd_opx_nulfu_lt_sd>;
defm NULFU_LE_SD : CompareRegRegAndNullifyF64<nulfsd_opx_nulfu_le_sd>;
defm NULFU_SD    : CompareRegRegAndNullifyF64<nulfsd_opx_nulfu_sd>;

multiclass CompareRegRegAndNullifyF128<nulfsq_opx opxCode, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_Rab<fused_opx_nulfsq, opxCode.value,
           (outs), (ins GR:$ra, GR:$rb, uimm5:$bb_yes, uimm5:$bb_no),
           !strconcat(opxCode.mnem, "\t$ra, $rb, $bb_yes, $bb_no"),
           [], itin>;
}

defm NULFO_EQ_SQ : CompareRegRegAndNullifyF128<nulfsq_opx_nulfo_eq_sq>;
defm NULFO_NE_SQ : CompareRegRegAndNullifyF128<nulfsq_opx_nulfo_ne_sq>;
defm NULFO_LT_SQ : CompareRegRegAndNullifyF128<nulfsq_opx_nulfo_lt_sq>;
defm NULFO_LE_SQ : CompareRegRegAndNullifyF128<nulfsq_opx_nulfo_le_sq>;
defm NULFO_SQ    : CompareRegRegAndNullifyF128<nulfsq_opx_nulfo_sq>;
defm NULFU_EQ_SQ : CompareRegRegAndNullifyF128<nulfsq_opx_nulfu_eq_sq>;
defm NULFU_NE_SQ : CompareRegRegAndNullifyF128<nulfsq_opx_nulfu_ne_sq>;
defm NULFU_LT_SQ : CompareRegRegAndNullifyF128<nulfsq_opx_nulfu_lt_sq>;
defm NULFU_LE_SQ : CompareRegRegAndNullifyF128<nulfsq_opx_nulfu_le_sq>;
defm NULFU_SQ    : CompareRegRegAndNullifyF128<nulfsq_opx_nulfu_sq>;

//===----------------------------------------------------------------------===//
// fp classify and nullification
//===----------------------------------------------------------------------===//
multiclass CompareFPImmAndNullifyF32<nulfss_opx opxCode, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_Rab<fused_opx_nulfss, opxCode.value,
           (outs), (ins GR:$ra, uimm7:$rb, uimm5:$bb_yes, uimm5:$bb_no),
           !strconcat(opxCode.mnem, "\t$ra, $rb, $bb_yes, $bb_no"),
           [], itin>;
}
defm NULF_CLASS_SS : CompareFPImmAndNullifyF32<nulfss_opx_nulf_class_ss>;

multiclass CompareFPImmAndNullifyF64<nulfsd_opx opxCode, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_Rab<fused_opx_nulfsd, opxCode.value,
           (outs), (ins GR:$ra, uimm7:$rb, uimm5:$bb_yes, uimm5:$bb_no),
           !strconcat(opxCode.mnem, "\t$ra, $rb, $bb_yes, $bb_no"),
           [], itin>;
}
defm NULF_CLASS_SD : CompareFPImmAndNullifyF64<nulfsd_opx_nulf_class_sd>;

multiclass CompareFPImmAndNullifyF128<nulfsq_opx opxCode, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_Rab<fused_opx_nulfsq, opxCode.value,
           (outs), (ins GR:$ra, uimm7:$rb, uimm5:$bb_yes, uimm5:$bb_no),
           !strconcat(opxCode.mnem, "\t$ra, $rb, $bb_yes, $bb_no"),
           [], itin>;
}
defm NULF_CLASS_SQ : CompareFPImmAndNullifyF128<nulfsq_opx_nulf_class_sq>;
