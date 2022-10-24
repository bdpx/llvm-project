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
multiclass CompareRegRegAndNullify
  <nullrr_opx opxCode, string OpcStr, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_Rab<fused_opx_nullrr, opxCode.value,
           (outs), (ins GR:$ra, GR:$rb, uimm5:$bb_yes, uimm5:$bb_no),
           !strconcat(OpcStr, "\t$ra, $rb, $bb_yes, $bb_no"),
           [], itin>;
}

defm insn_nuldeq  : CompareRegRegAndNullify<nullrr_opx_nuldeq,  "nuldeq">;
defm insn_nuldne  : CompareRegRegAndNullify<nullrr_opx_nuldne,  "nuldne">;
defm insn_nuldlt  : CompareRegRegAndNullify<nullrr_opx_nuldlt,  "nuldlt">;
defm insn_nuldle  : CompareRegRegAndNullify<nullrr_opx_nuldle,  "nuldle">;
defm insn_nuldltu : CompareRegRegAndNullify<nullrr_opx_nuldltu, "nuldltu">;
defm insn_nuldleu : CompareRegRegAndNullify<nullrr_opx_nuldleu, "nuldleu">;

defm insn_nulweq  : CompareRegRegAndNullify<nullrr_opx_nulweq,  "nulweq">;
defm insn_nulwne  : CompareRegRegAndNullify<nullrr_opx_nulwne,  "nulwne">;
defm insn_nulwlt  : CompareRegRegAndNullify<nullrr_opx_nulwlt,  "nulwlt">;
defm insn_nulwle  : CompareRegRegAndNullify<nullrr_opx_nulwle,  "nulwle">;
defm insn_nulwltu : CompareRegRegAndNullify<nullrr_opx_nulwltu, "nulwltu">;
defm insn_nulwleu : CompareRegRegAndNullify<nullrr_opx_nulwleu, "nulwleu">;

defm insn_nulbs   : CompareRegRegAndNullify<nullrr_opx_nulbs,   "nulbs">;
defm insn_nulbc   : CompareRegRegAndNullify<nullrr_opx_nulbc,   "nulbc">;

//===----------------------------------------------------------------------===//
// Compare reg-bitimm and nullify
//===----------------------------------------------------------------------===//
multiclass CompareRegBitAndNullify
  <nullrr_opx opxCode, string OpcStr, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_Rab<fused_opx_nullrr, opxCode.value,
           (outs), (ins GR:$ra, uimm7:$rb, uimm5:$bb_yes, uimm5:$bb_no),
           !strconcat(OpcStr, "\t$ra, $rb, $bb_yes, $bb_no"),
           [], itin>;
}

defm insn_nulbsi : CompareRegBitAndNullify<nullrr_opx_nulbsi, "nulbsi">;
defm insn_nulbci : CompareRegBitAndNullify<nullrr_opx_nulbci, "nulbci">;

//===----------------------------------------------------------------------===//
// Compare immediate and nullify
//===----------------------------------------------------------------------===//
multiclass CompareRegImmAndNullify
  <fused_opx opxCode, string OpcStr, Operand immOp, Operand immOpEx, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_RaIMM<opxCode,
           (outs), (ins GR:$ra, immOp:$imm, uimm5:$bb_yes, uimm5:$bb_no),
           !strconcat(OpcStr, "\t$ra, $imm, $bb_yes, $bb_no"),
           [], itin>;

  def NAME # _ext : Nullify_RaIMM_ext<opxCode,
           (outs), (ins GR:$ra, immOpEx:$imm, uimm5:$bb_yes, uimm5:$bb_no),
           !strconcat(OpcStr, ".l\t$ra, $imm, $bb_yes, $bb_no"),
           [], itin>;
}

defm insn_nuldeqi  : CompareRegImmAndNullify<fused_opx_nuldeqi,      "nuldeqi",    simm11, simm11_ext>;
defm insn_nuldnei  : CompareRegImmAndNullify<fused_opx_nuldnei,      "nuldnei",    simm11, simm11_ext>;
defm insn_nuldlti  : CompareRegImmAndNullify<fused_opx_nuldlti,      "nuldlti",    simm11, simm11_ext>;
defm insn_nuldgti  : CompareRegImmAndNullify<fused_opx_nuldgti,      "nuldgti",    simm11, simm11_ext>;
defm insn_nuldltui : CompareRegImmAndNullify<fused_opx_nuldltui,     "nuldltui",   uimm11, uimm11_ext>;
defm insn_nuldgtui : CompareRegImmAndNullify<fused_opx_nuldgtui,     "nuldgtui",   uimm11, uimm11_ext>;

defm insn_nulweqi  : CompareRegImmAndNullify<fused_opx_nulweqi,      "nulweqi",    simm11i32, simm11i32_ext>;
defm insn_nulwnei  : CompareRegImmAndNullify<fused_opx_nulwnei,      "nulwnei",    simm11i32, simm11i32_ext>;
defm insn_nulwlti  : CompareRegImmAndNullify<fused_opx_nulwlti,      "nulwlti",    simm11i32, simm11i32_ext>;
defm insn_nulwgti  : CompareRegImmAndNullify<fused_opx_nulwgti,      "nulwgti",    simm11i32, simm11i32_ext>;
defm insn_nulwltui : CompareRegImmAndNullify<fused_opx_nulwltui,     "nulwltui",   uimm11i32, uimm11i32_ext>;
defm insn_nulwgtui : CompareRegImmAndNullify<fused_opx_nulwgtui,     "nulwgtui",   uimm11i32, uimm11i32_ext>;

defm insn_nulmall    : CompareRegImmAndNullify<fused_opx_nulmall,    "nulmall",    uimm11, uimm11_ext>;
defm insn_nulmnotall : CompareRegImmAndNullify<fused_opx_nulmnotall, "nulmnotall", uimm11, uimm11_ext>;
defm insn_nulmnone   : CompareRegImmAndNullify<fused_opx_nulmnone,   "nulmnone",   uimm11, uimm11_ext>;
defm insn_nulmany    : CompareRegImmAndNullify<fused_opx_nulmany,    "nulmany",    uimm11, uimm11_ext>;

//===----------------------------------------------------------------------===//
// fp compare and nullification
//===----------------------------------------------------------------------===//
multiclass CompareRegRegAndNullifyF32
  <nulfss_opx opxCode, string OpcStr, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_Rab<fused_opx_nulfss, opxCode.value,
           (outs), (ins GR:$ra, GR:$rb, uimm5:$bb_yes, uimm5:$bb_no),
           !strconcat(OpcStr, "\t$ra, $rb, $bb_yes, $bb_no"),
           [], itin>;
}

defm insn_nulfssoeq : CompareRegRegAndNullifyF32<nulfss_opx_nulfssoeq,  "nulfssoeq">;
defm insn_nulfssone : CompareRegRegAndNullifyF32<nulfss_opx_nulfssone,  "nulfssone">;
defm insn_nulfssolt : CompareRegRegAndNullifyF32<nulfss_opx_nulfssolt,  "nulfssolt">;
defm insn_nulfssole : CompareRegRegAndNullifyF32<nulfss_opx_nulfssole,  "nulfssole">;
defm insn_nulfssueq : CompareRegRegAndNullifyF32<nulfss_opx_nulfssueq,  "nulfssueq">;
defm insn_nulfssune : CompareRegRegAndNullifyF32<nulfss_opx_nulfssune,  "nulfssune">;
defm insn_nulfssult : CompareRegRegAndNullifyF32<nulfss_opx_nulfssult,  "nulfssult">;
defm insn_nulfssule : CompareRegRegAndNullifyF32<nulfss_opx_nulfssule,  "nulfssule">;
defm insn_nulfsso   : CompareRegRegAndNullifyF32<nulfss_opx_nulfsso,    "nulfsso">;
defm insn_nulfssuo  : CompareRegRegAndNullifyF32<nulfss_opx_nulfssuo,   "nulfssuo">;

multiclass CompareRegRegAndNullifyF64
  <nulfsd_opx opxCode, string OpcStr, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_Rab<fused_opx_nulfsd, opxCode.value,
           (outs), (ins GR:$ra, GR:$rb, uimm5:$bb_yes, uimm5:$bb_no),
           !strconcat(OpcStr, "\t$ra, $rb, $bb_yes, $bb_no"),
           [], itin>;
}

defm insn_nulfsdoeq : CompareRegRegAndNullifyF64<nulfsd_opx_nulfsdoeq,  "nulfsdoeq">;
defm insn_nulfsdone : CompareRegRegAndNullifyF64<nulfsd_opx_nulfsdone,  "nulfsdone">;
defm insn_nulfsdolt : CompareRegRegAndNullifyF64<nulfsd_opx_nulfsdolt,  "nulfsdolt">;
defm insn_nulfsdole : CompareRegRegAndNullifyF64<nulfsd_opx_nulfsdole,  "nulfsdole">;
defm insn_nulfsdueq : CompareRegRegAndNullifyF64<nulfsd_opx_nulfsdueq,  "nulfsdueq">;
defm insn_nulfsdune : CompareRegRegAndNullifyF64<nulfsd_opx_nulfsdune,  "nulfsdune">;
defm insn_nulfsdult : CompareRegRegAndNullifyF64<nulfsd_opx_nulfsdult,  "nulfsdult">;
defm insn_nulfsdule : CompareRegRegAndNullifyF64<nulfsd_opx_nulfsdule,  "nulfsdule">;
defm insn_nulfsdo   : CompareRegRegAndNullifyF64<nulfsd_opx_nulfsdo,    "nulfsdo">;
defm insn_nulfsduo  : CompareRegRegAndNullifyF64<nulfsd_opx_nulfsduo,   "nulfsduo">;

multiclass CompareRegRegAndNullifyF128
  <nulfsq_opx opxCode, string OpcStr, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_Rab<fused_opx_nulfsq, opxCode.value,
           (outs), (ins GR:$ra, GR:$rb, uimm5:$bb_yes, uimm5:$bb_no),
           !strconcat(OpcStr, "\t$ra, $rb, $bb_yes, $bb_no"),
           [], itin>;
}

defm insn_nulfsqoeq : CompareRegRegAndNullifyF128<nulfsq_opx_nulfsqoeq,  "nulfsqoeq">;
defm insn_nulfsqone : CompareRegRegAndNullifyF128<nulfsq_opx_nulfsqone,  "nulfsqone">;
defm insn_nulfsqolt : CompareRegRegAndNullifyF128<nulfsq_opx_nulfsqolt,  "nulfsqolt">;
defm insn_nulfsqole : CompareRegRegAndNullifyF128<nulfsq_opx_nulfsqole,  "nulfsqole">;
defm insn_nulfsqueq : CompareRegRegAndNullifyF128<nulfsq_opx_nulfsqueq,  "nulfsqueq">;
defm insn_nulfsqune : CompareRegRegAndNullifyF128<nulfsq_opx_nulfsqune,  "nulfsqune">;
defm insn_nulfsqult : CompareRegRegAndNullifyF128<nulfsq_opx_nulfsqult,  "nulfsqult">;
defm insn_nulfsqule : CompareRegRegAndNullifyF128<nulfsq_opx_nulfsqule,  "nulfsqule">;
defm insn_nulfsqo   : CompareRegRegAndNullifyF128<nulfsq_opx_nulfsqo,    "nulfsqo">;
defm insn_nulfsquo  : CompareRegRegAndNullifyF128<nulfsq_opx_nulfsquo,   "nulfsquo">;

//===----------------------------------------------------------------------===//
// fp classify and nullification
//===----------------------------------------------------------------------===//
multiclass CompareFPImmAndNullifyF32
  <nulfss_opx opxCode, string OpcStr, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_Rab<fused_opx_nulfss, opxCode.value,
           (outs), (ins GR:$ra, uimm7:$rb, uimm5:$bb_yes, uimm5:$bb_no),
           !strconcat(OpcStr, "\t$ra, $rb, $bb_yes, $bb_no"),
           [], itin>;
}
defm insn_nulfssclass : CompareFPImmAndNullifyF32<nulfss_opx_nulfssclass, "nulfssclass">;

multiclass CompareFPImmAndNullifyF64
  <nulfsd_opx opxCode, string OpcStr, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_Rab<fused_opx_nulfsd, opxCode.value,
           (outs), (ins GR:$ra, uimm7:$rb, uimm5:$bb_yes, uimm5:$bb_no),
           !strconcat(OpcStr, "\t$ra, $rb, $bb_yes, $bb_no"),
           [], itin>;
}
defm insn_nullfsdclass : CompareFPImmAndNullifyF64<nulfsd_opx_nulfsdclass, "nulfsdclass">;

multiclass CompareFPImmAndNullifyF128
  <nulfsq_opx opxCode, string OpcStr, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_Rab<fused_opx_nulfsq, opxCode.value,
           (outs), (ins GR:$ra, uimm7:$rb, uimm5:$bb_yes, uimm5:$bb_no),
           !strconcat(OpcStr, "\t$ra, $rb, $bb_yes, $bb_no"),
           [], itin>;
}
defm insn_nulfsqclass : CompareFPImmAndNullifyF128<nulfsq_opx_nulfsqclass, "nulfsqclass">;
