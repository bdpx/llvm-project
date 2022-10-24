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
  return getU64Imm(N->getZExtValue(), SDLoc(N));
}]>;
def nul_distance : Operand<i32>, IntImmLeaf<i32, [{ return isZextInt(Imm, 5); }], nul_distance_xform> {
  let DecoderMethod = "DecodeUIMM<5>";
}

//===----------------------------------------------------------------------===//
// compare and nullify reg-reg
//===----------------------------------------------------------------------===//
multiclass CompareRegRegAndNullifyW<nulw_opx opxCode, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_Rab<opcode_nulw, opxCode.value,
           (outs), (ins GR:$ra, GR:$rb, nul_distance:$bb_yes, nul_distance:$bb_no),
           !strconcat(opxCode.mnem, " $ra, $rb, $bb_yes, $bb_no"),
           [], itin>;
}

defm NULEQW  : CompareRegRegAndNullifyW<opcode_nuleqw>;
defm NULNEW  : CompareRegRegAndNullifyW<opcode_nulnew>;
defm NULLTSW : CompareRegRegAndNullifyW<opcode_nulltsw>;
defm NULLTUW : CompareRegRegAndNullifyW<opcode_nulltuw>;
defm NULGESW : CompareRegRegAndNullifyW<opcode_nulgesw>;
defm NULGEUW : CompareRegRegAndNullifyW<opcode_nulgeuw>;

defm FNULOEQS : CompareRegRegAndNullifyW<opcode_fnuloeqs>;
defm FNULONES : CompareRegRegAndNullifyW<opcode_fnulones>;
defm FNULOLTS : CompareRegRegAndNullifyW<opcode_fnulolts>;
defm FNULOGES : CompareRegRegAndNullifyW<opcode_fnuloges>;
defm FNULOS   : CompareRegRegAndNullifyW<opcode_fnulos>;
defm FNULUEQS : CompareRegRegAndNullifyW<opcode_fnulueqs>;
defm FNULUNES : CompareRegRegAndNullifyW<opcode_fnulunes>;
defm FNULULTS : CompareRegRegAndNullifyW<opcode_fnulults>;
defm FNULUGES : CompareRegRegAndNullifyW<opcode_fnuluges>;
defm FNULUS   : CompareRegRegAndNullifyW<opcode_fnulus>;

multiclass CompareRegRegAndNullifyD<nuld_opx opxCode, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_Rab<opcode_nuld, opxCode.value,
           (outs), (ins GR:$ra, GR:$rb, nul_distance:$bb_yes, nul_distance:$bb_no),
           !strconcat(opxCode.mnem, " $ra, $rb, $bb_yes, $bb_no"),
           [], itin>;
}

defm NULEQD  : CompareRegRegAndNullifyD<opcode_nuleqd>;
defm NULNED  : CompareRegRegAndNullifyD<opcode_nulned>;
defm NULLTSD : CompareRegRegAndNullifyD<opcode_nulltsd>;
defm NULLTUD : CompareRegRegAndNullifyD<opcode_nulltud>;
defm NULGESD : CompareRegRegAndNullifyD<opcode_nulgesd>;
defm NULGEUD : CompareRegRegAndNullifyD<opcode_nulgeud>;

defm FNULOEQD : CompareRegRegAndNullifyD<opcode_fnuloeqd>;
defm FNULONED : CompareRegRegAndNullifyD<opcode_fnuloned>;
defm FNULOLTD : CompareRegRegAndNullifyD<opcode_fnuloltd>;
defm FNULOGED : CompareRegRegAndNullifyD<opcode_fnuloged>;
defm FNULOD   : CompareRegRegAndNullifyD<opcode_fnulod>;
defm FNULUEQD : CompareRegRegAndNullifyD<opcode_fnulueqd>;
defm FNULUNED : CompareRegRegAndNullifyD<opcode_fnuluned>;
defm FNULULTD : CompareRegRegAndNullifyD<opcode_fnulultd>;
defm FNULUGED : CompareRegRegAndNullifyD<opcode_fnuluged>;
defm FNULUD   : CompareRegRegAndNullifyD<opcode_fnulud>;

multiclass CompareRegRegAndNullifyQ<nulq_opx opxCode, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_Rab<opcode_nulq, opxCode.value,
           (outs), (ins GR:$ra, GR:$rb, nul_distance:$bb_yes, nul_distance:$bb_no),
           !strconcat(opxCode.mnem, " $ra, $rb, $bb_yes, $bb_no"),
           [], itin>;
}

defm NULEQQ  : CompareRegRegAndNullifyQ<opcode_nuleqq>;
defm NULNEQ  : CompareRegRegAndNullifyQ<opcode_nulneq>;
defm NULLTSQ : CompareRegRegAndNullifyQ<opcode_nulltsq>;
defm NULLTUQ : CompareRegRegAndNullifyQ<opcode_nulltuq>;
defm NULGESQ : CompareRegRegAndNullifyQ<opcode_nulgesq>;
defm NULGEUQ : CompareRegRegAndNullifyQ<opcode_nulgeuq>;

defm FNULOEQQ : CompareRegRegAndNullifyQ<opcode_fnuloeqq>;
defm FNULONEQ : CompareRegRegAndNullifyQ<opcode_fnuloneq>;
defm FNULOLTQ : CompareRegRegAndNullifyQ<opcode_fnuloltq>;
defm FNULOGEQ : CompareRegRegAndNullifyQ<opcode_fnulogeq>;
defm FNULOQ   : CompareRegRegAndNullifyQ<opcode_fnuloq>;
defm FNULUEQQ : CompareRegRegAndNullifyQ<opcode_fnulueqq>;
defm FNULUNEQ : CompareRegRegAndNullifyQ<opcode_fnuluneq>;
defm FNULULTQ : CompareRegRegAndNullifyQ<opcode_fnulultq>;
defm FNULUGEQ : CompareRegRegAndNullifyQ<opcode_fnulugeq>;
defm FNULUQ   : CompareRegRegAndNullifyQ<opcode_fnuluq>;


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

defm NULEQIW  : CompareRegImmAndNullify<opcode_nuleqiw,  simm11i32, simm11i32_ext>;
defm NULNEIW  : CompareRegImmAndNullify<opcode_nulneiw,  simm11i32, simm11i32_ext>;
defm NULLTSIW : CompareRegImmAndNullify<opcode_nulltsiw, simm11i32, simm11i32_ext>;
defm NULLTUIW : CompareRegImmAndNullify<opcode_nulltuiw, uimm11i32, uimm11i32_ext>;
defm NULGESIW : CompareRegImmAndNullify<opcode_nulgesiw, simm11i32, simm11i32_ext>;
defm NULGEUIW : CompareRegImmAndNullify<opcode_nulgeuiw, uimm11i32, uimm11i32_ext>;

defm NULEQID  : CompareRegImmAndNullify<opcode_nuleqid,  simm11, simm11_ext>;
defm NULNEID  : CompareRegImmAndNullify<opcode_nulneid,  simm11, simm11_ext>;
defm NULLTSID : CompareRegImmAndNullify<opcode_nulltsid, simm11, simm11_ext>;
defm NULLTUID : CompareRegImmAndNullify<opcode_nulltuid, uimm11, uimm11_ext>;
defm NULGESID : CompareRegImmAndNullify<opcode_nulgesid, simm11, simm11_ext>;
defm NULGEUID : CompareRegImmAndNullify<opcode_nulgeuid, uimm11, uimm11_ext>;

defm NULEQIQ  : CompareRegImmAndNullify<opcode_nuleqiq,  simm11i128, simm11i128_ext>;
defm NULNEIQ  : CompareRegImmAndNullify<opcode_nulneiq,  simm11i128, simm11i128_ext>;
defm NULLTSIQ : CompareRegImmAndNullify<opcode_nulltsiq, simm11i128, simm11i128_ext>;
defm NULLTUIQ : CompareRegImmAndNullify<opcode_nulltuiq, uimm11i128, uimm11i128_ext>;
defm NULGESIQ : CompareRegImmAndNullify<opcode_nulgesiq, simm11i128, simm11i128_ext>;
defm NULGEUIQ : CompareRegImmAndNullify<opcode_nulgeuiq, uimm11i128, uimm11i128_ext>;

defm NULMALLD    : CompareRegImmAndNullify<opcode_nulmall,    uimm11, uimm11_ext>;
defm NULMNOTALLD : CompareRegImmAndNullify<opcode_nulmnotall, uimm11, uimm11_ext>;
defm NULMNONED   : CompareRegImmAndNullify<opcode_nulmnone,   uimm11, uimm11_ext>;
defm NULMANYD    : CompareRegImmAndNullify<opcode_nulmany,    uimm11, uimm11_ext>;

// same masked nul-branches work for i32,i64,i128
// FIXME: can model different type immediates only via codegen
let isCodeGenOnly = 1 in {
  defm NULMALLW    : CompareRegImmAndNullify<opcode_nulmall,    uimm11i32, uimm11i32_ext>;
  defm NULMNOTALLW : CompareRegImmAndNullify<opcode_nulmnotall, uimm11i32, uimm11i32_ext>;
  defm NULMNONEW   : CompareRegImmAndNullify<opcode_nulmnone,   uimm11i32, uimm11i32_ext>;
  defm NULMANYW    : CompareRegImmAndNullify<opcode_nulmany,    uimm11i32, uimm11i32_ext>;

  defm NULMALLQ    : CompareRegImmAndNullify<opcode_nulmall,    uimm11i128, uimm11i128_ext>;
  defm NULMNOTALLQ : CompareRegImmAndNullify<opcode_nulmnotall, uimm11i128, uimm11i128_ext>;
  defm NULMNONEQ   : CompareRegImmAndNullify<opcode_nulmnone,   uimm11i128, uimm11i128_ext>;
  defm NULMANYQ    : CompareRegImmAndNullify<opcode_nulmany,    uimm11i128, uimm11i128_ext>;
}

//===----------------------------------------------------------------------===//
// Compare reg-bitimm and nullify
//===----------------------------------------------------------------------===//
multiclass CompareRegRegAndNullifyH<nulh_opx opxCode, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_Rab<opcode_nulh, opxCode.value,
           (outs), (ins GR:$ra, GR:$rb, nul_distance:$bb_yes, nul_distance:$bb_no),
           !strconcat(opxCode.mnem, " $ra, $rb, $bb_yes, $bb_no"),
           [], itin>;
}

defm NULBS : CompareRegRegAndNullifyH<opcode_nulbs>;
defm NULBC : CompareRegRegAndNullifyH<opcode_nulbc>;

defm FNULOEQH : CompareRegRegAndNullifyH<opcode_fnuloeqh>;
defm FNULONEH : CompareRegRegAndNullifyH<opcode_fnuloneh>;
defm FNULOLTH : CompareRegRegAndNullifyH<opcode_fnulolth>;
defm FNULOGEH : CompareRegRegAndNullifyH<opcode_fnulogeh>;
defm FNULOH   : CompareRegRegAndNullifyH<opcode_fnuloh>;
defm FNULUEQH : CompareRegRegAndNullifyH<opcode_fnulueqh>;
defm FNULUNEH : CompareRegRegAndNullifyH<opcode_fnuluneh>;
defm FNULULTH : CompareRegRegAndNullifyH<opcode_fnululth>;
defm FNULUGEH : CompareRegRegAndNullifyH<opcode_fnulugeh>;
defm FNULUH   : CompareRegRegAndNullifyH<opcode_fnuluh>;

multiclass CompareRegBitAndNullifyH<nulh_opx opxCode, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : Nullify_Rab<opcode_nulh, opxCode.value,
           (outs), (ins GR:$ra, uimm7:$rb, nul_distance:$bb_yes, nul_distance:$bb_no),
           !strconcat(opxCode.mnem, " $ra, $rb, $bb_yes, $bb_no"),
           [], itin>;
}

defm NULBSI : CompareRegBitAndNullifyH<opcode_nulbsi>;
defm NULBCI : CompareRegBitAndNullifyH<opcode_nulbci>;

