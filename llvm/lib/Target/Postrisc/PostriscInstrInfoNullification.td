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

defm NULDEQ  : CompareRegRegAndNullify<nullrr_opx_nuldeq,  "nuldeq">;
defm NULDNE  : CompareRegRegAndNullify<nullrr_opx_nuldne,  "nuldne">;
defm NULDLT  : CompareRegRegAndNullify<nullrr_opx_nuldlt,  "nuldlt">;
defm NULDLE  : CompareRegRegAndNullify<nullrr_opx_nuldle,  "nuldle">;
defm NULDLTU : CompareRegRegAndNullify<nullrr_opx_nuldltu, "nuldltu">;
defm NULDLEU : CompareRegRegAndNullify<nullrr_opx_nuldleu, "nuldleu">;

defm NULWEQ  : CompareRegRegAndNullify<nullrr_opx_nulweq,  "nulweq">;
defm NULWNE  : CompareRegRegAndNullify<nullrr_opx_nulwne,  "nulwne">;
defm NULWLT  : CompareRegRegAndNullify<nullrr_opx_nulwlt,  "nulwlt">;
defm NULWLE  : CompareRegRegAndNullify<nullrr_opx_nulwle,  "nulwle">;
defm NULWLTU : CompareRegRegAndNullify<nullrr_opx_nulwltu, "nulwltu">;
defm NULWLEU : CompareRegRegAndNullify<nullrr_opx_nulwleu, "nulwleu">;

defm NULBS   : CompareRegRegAndNullify<nullrr_opx_nulbs,   "nulbs">;
defm NULBC   : CompareRegRegAndNullify<nullrr_opx_nulbc,   "nulbc">;

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

defm NULBSI : CompareRegBitAndNullify<nullrr_opx_nulbsi, "nulbsi">;
defm NULBCI : CompareRegBitAndNullify<nullrr_opx_nulbci, "nulbci">;

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

  def NAME # _EXT : Nullify_RaIMM_ext<opxCode,
           (outs), (ins GR:$ra, immOpEx:$imm, uimm5:$bb_yes, uimm5:$bb_no),
           !strconcat(OpcStr, ".l\t$ra, $imm, $bb_yes, $bb_no"),
           [], itin>;
}

defm NULDEQI  : CompareRegImmAndNullify<fused_opx_nuldeqi,      "nuldeqi",    simm11, simm11_ext>;
defm NULDNEI  : CompareRegImmAndNullify<fused_opx_nuldnei,      "nuldnei",    simm11, simm11_ext>;
defm NULDLTI  : CompareRegImmAndNullify<fused_opx_nuldlti,      "nuldlti",    simm11, simm11_ext>;
defm NULDGTI  : CompareRegImmAndNullify<fused_opx_nuldgti,      "nuldgti",    simm11, simm11_ext>;
defm NULDLTUI : CompareRegImmAndNullify<fused_opx_nuldltui,     "nuldltui",   uimm11, uimm11_ext>;
defm NULDGTUI : CompareRegImmAndNullify<fused_opx_nuldgtui,     "nuldgtui",   uimm11, uimm11_ext>;

defm NULWEQI  : CompareRegImmAndNullify<fused_opx_nulweqi,      "nulweqi",    simm11i32, simm11i32_ext>;
defm NULWNEI  : CompareRegImmAndNullify<fused_opx_nulwnei,      "nulwnei",    simm11i32, simm11i32_ext>;
defm NULWLTI  : CompareRegImmAndNullify<fused_opx_nulwlti,      "nulwlti",    simm11i32, simm11i32_ext>;
defm NULWGTI  : CompareRegImmAndNullify<fused_opx_nulwgti,      "nulwgti",    simm11i32, simm11i32_ext>;
defm NULWLTUI : CompareRegImmAndNullify<fused_opx_nulwltui,     "nulwltui",   uimm11i32, uimm11i32_ext>;
defm NULWGTUI : CompareRegImmAndNullify<fused_opx_nulwgtui,     "nulwgtui",   uimm11i32, uimm11i32_ext>;

defm NULMALL    : CompareRegImmAndNullify<fused_opx_nulmall,    "nulmall",    uimm11, uimm11_ext>;
defm NULMNOTALL : CompareRegImmAndNullify<fused_opx_nulmnotall, "nulmnotall", uimm11, uimm11_ext>;
defm NULMNONE   : CompareRegImmAndNullify<fused_opx_nulmnone,   "nulmnone",   uimm11, uimm11_ext>;
defm NULMANY    : CompareRegImmAndNullify<fused_opx_nulmany,    "nulmany",    uimm11, uimm11_ext>;

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

defm NULFSSOEQ : CompareRegRegAndNullifyF32<nulfss_opx_nulfssoeq,  "nulfssoeq">;
defm NULFSSONE : CompareRegRegAndNullifyF32<nulfss_opx_nulfssone,  "nulfssone">;
defm NULFSSOLT : CompareRegRegAndNullifyF32<nulfss_opx_nulfssolt,  "nulfssolt">;
defm NULFSSOLE : CompareRegRegAndNullifyF32<nulfss_opx_nulfssole,  "nulfssole">;
defm NULFSSUEQ : CompareRegRegAndNullifyF32<nulfss_opx_nulfssueq,  "nulfssueq">;
defm NULFSSUNE : CompareRegRegAndNullifyF32<nulfss_opx_nulfssune,  "nulfssune">;
defm NULFSSULT : CompareRegRegAndNullifyF32<nulfss_opx_nulfssult,  "nulfssult">;
defm NULFSSULE : CompareRegRegAndNullifyF32<nulfss_opx_nulfssule,  "nulfssule">;
defm NULFSSO   : CompareRegRegAndNullifyF32<nulfss_opx_nulfsso,    "nulfsso">;
defm NULFSSUO  : CompareRegRegAndNullifyF32<nulfss_opx_nulfssuo,   "nulfssuo">;

multiclass CompareRegRegAndNullifyF64
  <nulfsd_opx opxCode, string OpcStr, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_Rab<fused_opx_nulfsd, opxCode.value,
           (outs), (ins GR:$ra, GR:$rb, uimm5:$bb_yes, uimm5:$bb_no),
           !strconcat(OpcStr, "\t$ra, $rb, $bb_yes, $bb_no"),
           [], itin>;
}

defm NULFSDOEQ : CompareRegRegAndNullifyF64<nulfsd_opx_nulfsdoeq,  "nulfsdoeq">;
defm NULFSDONE : CompareRegRegAndNullifyF64<nulfsd_opx_nulfsdone,  "nulfsdone">;
defm NULFSDOLT : CompareRegRegAndNullifyF64<nulfsd_opx_nulfsdolt,  "nulfsdolt">;
defm NULFSDOLE : CompareRegRegAndNullifyF64<nulfsd_opx_nulfsdole,  "nulfsdole">;
defm NULFSDUEQ : CompareRegRegAndNullifyF64<nulfsd_opx_nulfsdueq,  "nulfsdueq">;
defm NULFSDUNE : CompareRegRegAndNullifyF64<nulfsd_opx_nulfsdune,  "nulfsdune">;
defm NULFSDULT : CompareRegRegAndNullifyF64<nulfsd_opx_nulfsdult,  "nulfsdult">;
defm NULFSDULE : CompareRegRegAndNullifyF64<nulfsd_opx_nulfsdule,  "nulfsdule">;
defm NULFSDO   : CompareRegRegAndNullifyF64<nulfsd_opx_nulfsdo,    "nulfsdo">;
defm NULFSDUO  : CompareRegRegAndNullifyF64<nulfsd_opx_nulfsduo,   "nulfsduo">;

multiclass CompareRegRegAndNullifyF128
  <nulfsq_opx opxCode, string OpcStr, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_Rab<fused_opx_nulfsq, opxCode.value,
           (outs), (ins GR:$ra, GR:$rb, uimm5:$bb_yes, uimm5:$bb_no),
           !strconcat(OpcStr, "\t$ra, $rb, $bb_yes, $bb_no"),
           [], itin>;
}

defm NULFSQOEQ : CompareRegRegAndNullifyF128<nulfsq_opx_nulfsqoeq,  "nulfsqoeq">;
defm NULFSQONE : CompareRegRegAndNullifyF128<nulfsq_opx_nulfsqone,  "nulfsqone">;
defm NULFSQOLT : CompareRegRegAndNullifyF128<nulfsq_opx_nulfsqolt,  "nulfsqolt">;
defm NULFSQOLE : CompareRegRegAndNullifyF128<nulfsq_opx_nulfsqole,  "nulfsqole">;
defm NULFSQUEQ : CompareRegRegAndNullifyF128<nulfsq_opx_nulfsqueq,  "nulfsqueq">;
defm NULFSQUNE : CompareRegRegAndNullifyF128<nulfsq_opx_nulfsqune,  "nulfsqune">;
defm NULFSQULT : CompareRegRegAndNullifyF128<nulfsq_opx_nulfsqult,  "nulfsqult">;
defm NULFSQULE : CompareRegRegAndNullifyF128<nulfsq_opx_nulfsqule,  "nulfsqule">;
defm NULFSQO   : CompareRegRegAndNullifyF128<nulfsq_opx_nulfsqo,    "nulfsqo">;
defm NULFSQUO  : CompareRegRegAndNullifyF128<nulfsq_opx_nulfsquo,   "nulfsquo">;

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
defm NULFSSCLASS : CompareFPImmAndNullifyF32<nulfss_opx_nulfssclass, "nulfssclass">;

multiclass CompareFPImmAndNullifyF64
  <nulfsd_opx opxCode, string OpcStr, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_Rab<fused_opx_nulfsd, opxCode.value,
           (outs), (ins GR:$ra, uimm7:$rb, uimm5:$bb_yes, uimm5:$bb_no),
           !strconcat(OpcStr, "\t$ra, $rb, $bb_yes, $bb_no"),
           [], itin>;
}
defm NULFSDCLASS : CompareFPImmAndNullifyF64<nulfsd_opx_nulfsdclass, "nulfsdclass">;

multiclass CompareFPImmAndNullifyF128
  <nulfsq_opx opxCode, string OpcStr, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_Rab<fused_opx_nulfsq, opxCode.value,
           (outs), (ins GR:$ra, uimm7:$rb, uimm5:$bb_yes, uimm5:$bb_no),
           !strconcat(OpcStr, "\t$ra, $rb, $bb_yes, $bb_no"),
           [], itin>;
}
defm NULFSQCLASS : CompareFPImmAndNullifyF128<nulfsq_opx_nulfsqclass, "nulfsqclass">;
