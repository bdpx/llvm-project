//===-- PostriscInstrInfo.td - Target Description for Postrisc Target -----===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file describes the Postrisc instructions in TableGen format.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Addressing modes aren't used in POSTRISC backend.
// Only this one is necessary because a frameindex can't be matched directly.
//===----------------------------------------------------------------------===//
def AddrFI : ComplexPattern<i64, 1, "SelectAddrFI", [frameindex], []>;

def TLSSym : Operand<i64>;

//===----------------------------------------------------------------------===//
// Pseudo instructions.
//===----------------------------------------------------------------------===//
class Pseudo<dag outs, dag ins, string asmstr, list<dag> pattern>
   : InstBase<opcode_misc, outs, ins, asmstr, pattern> {
  let isCodeGenOnly = 1;
  let isPseudo = 1;
}

// Branch targets have OtherVT type.
def jump_target : Operand<OtherVT> {
  let EncoderMethod = "getJumpTargetOpValue<false>";
  let DecoderMethod = "DecodeBranch<28>";
}
def jump_target_ext : Operand<OtherVT> {
  let EncoderMethod = "getJumpTargetOpValue<true>";
  let DecoderMethod = "DecodeBranch<60>";
}

def brtarget : Operand<OtherVT> {
  let EncoderMethod = "getBranchTargetOpValue<false>";
  let DecoderMethod = "DecodeBranch<17>";
}
def brtarget_ext : Operand<OtherVT> {
  let EncoderMethod = "getBranchTargetOpValue<true>";
  let DecoderMethod = "DecodeBranch<30>";
}

def calltarget : Operand<i64> {
  let EncoderMethod = "getCallTargetOpValue";
  let DecoderMethod = "DecodeBranch<28>";
}
def calltarget_ext : Operand<i64> {
  let EncoderMethod = "getCallTargetOpValue";
  let DecoderMethod = "DecodeBranch<60>";
}

def SDTSPFTOI     : SDTypeProfile<1, 1, [SDTCisVT<0, i32>, SDTCisFP<1>]>;
def SDTSPFTOX     : SDTypeProfile<1, 1, [SDTCisVT<0, f64>, SDTCisFP<1>]>;
def SDTSPITOF     : SDTypeProfile<1, 1, [SDTCisFP<0>, SDTCisVT<1, i32>]>;
def SDTSPXTOF     : SDTypeProfile<1, 1, [SDTCisFP<0>, SDTCisVT<1, f64>]>;

def SDT_PostriscAddress : SDTypeProfile<1, 1, [SDTCisSameAs<0, 1>, SDTCisPtrTy<0>]>;
def pcrel_code_wrapper     : SDNode<"PostriscISD::PCREL_CODE_WRAPPER",     SDT_PostriscAddress, []>;
def pcrel_code_wrapper_ext : SDNode<"PostriscISD::PCREL_CODE_WRAPPER_EXT", SDT_PostriscAddress, []>;
def pcrel_data_wrapper     : SDNode<"PostriscISD::PCREL_DATA_WRAPPER",     SDT_PostriscAddress, []>;
def pcrel_data_wrapper_ext : SDNode<"PostriscISD::PCREL_DATA_WRAPPER_EXT", SDT_PostriscAddress, []>;

def absaddr_wrapper     : SDNode<"PostriscISD::ABSADDR_WRAPPER",     SDT_PostriscAddress, []>;
def absaddr_wrapper_ext : SDNode<"PostriscISD::ABSADDR_WRAPPER_EXT", SDT_PostriscAddress, []>;

def SDT_TLS_OFFSET : SDTypeProfile<1, 1, [SDTCisSameAs<0, 1>, SDTCisPtrTy<0>]>;
def tls_offset_wrapper:     SDNode<"PostriscISD::TLS_OFFSET_WRAPPER",     SDT_TLS_OFFSET, []>;
def tls_offset_wrapper_ext: SDNode<"PostriscISD::TLS_OFFSET_WRAPPER_EXT", SDT_TLS_OFFSET, []>;

def SPftoi  : SDNode<"PostriscISD::FTOI", SDTSPFTOI>;
def SPitof  : SDNode<"PostriscISD::ITOF", SDTSPITOF>;
def SPftox  : SDNode<"PostriscISD::FTOX", SDTSPFTOX>;
def SPxtof  : SDNode<"PostriscISD::XTOF", SDTSPXTOF>;

//===----------------------------------------------------------------------===//
// util: pat fragments
//===----------------------------------------------------------------------===//
def pr_add  : PatFrag<(ops node:$src1, node:$src2), (add node:$src1, node:$src2)>;
def pr_sub  : PatFrag<(ops node:$src1, node:$src2), (sub node:$src1, node:$src2)>;
def pr_subf : PatFrag<(ops node:$src1, node:$src2), (sub node:$src2, node:$src1)>; // inverted: subtract from
def pr_absd : PatFrag<(ops node:$src1, node:$src2), (abs (sub node:$src2, node:$src1))>;  // absolute difference: abs(a-b)
def pr_mul  : PatFrag<(ops node:$src1, node:$src2), (mul node:$src1, node:$src2)>;

//===----------------------------------------------------------------------===//
// Instruction Class Templates
//===----------------------------------------------------------------------===//
multiclass MISC_R3<misc_opx opx, PatFrag OpNode, ValueType Tdst, ValueType Tsrc, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : MISC_Rabc<opx, (outs GR:$ra), (ins GR:$rb, GR:$rc),
         !strconcat(opx.mnem, "\t$ra, $rb, $rc"),
         [(set Tdst:$ra, (OpNode Tsrc:$rb, Tsrc:$rc))], itin>;
}

multiclass MISC_R2<misc_opx opx, string OpcStr, PatFrag OpNode, ValueType Tdst, ValueType Tsrc, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : MISC_Rab<opx, (outs GR:$ra), (ins GR:$rb),
         !strconcat(OpcStr, "\t$ra, $rb"),
         [(set Tdst:$ra, (OpNode Tsrc:$rb))], itin>;
}

multiclass PRIM_R2_IMM<opcode_opx opcode, PatFrag OpNode, ValueType Tdst, ValueType Tsrc,
  Operand immOp, Operand immOpExt, InstrItinClass itin = IIC_iu_instr>
{
  // Ra = Rb Op imm21
  def NAME : PRIMARY_RabI21<opcode, (outs GR:$ra), (ins GR:$rb, immOp:$imm),
                 !strconcat(opcode.mnem, "\t$ra, $rb, $imm"),
                 [(set Tdst:$ra, (OpNode Tsrc:$rb, immOp:$imm))],
                 itin>;

  // Ra = Rb Op imm21_ext
  def NAME # _EXT : PRIMARY_RabI21_ext<opcode, (outs GR:$ra), (ins GR:$rb, immOpExt:$imm),
                 !strconcat(opcode.mnem, ".l\t$ra, $rb, $imm"),
                 [(set Tdst:$ra, (OpNode Tsrc:$rb, immOpExt:$imm))],
                 itin>;
}

defm ADD   : MISC_R3<misc_opx_add,     pr_add,  i64, i64>;
defm ADDWS : MISC_R3<misc_opx_add_ws,  pr_add,  i32, i32>;
defm ADDWZ : MISC_R3<misc_opx_add_wz,  pr_add,  i32, i32>;
defm SUB   : MISC_R3<misc_opx_sub,     pr_sub,  i64, i64>;
defm SUBWS : MISC_R3<misc_opx_sub_ws,  pr_sub,  i32, i32>;
defm SUBWZ : MISC_R3<misc_opx_sub_wz,  pr_sub,  i32, i32>;
defm MUL   : MISC_R3<misc_opx_mul,     pr_mul,  i64, i64>;
defm MULWS : MISC_R3<misc_opx_mul_ws,  pr_mul,  i32, i32>;
defm MULWZ : MISC_R3<misc_opx_mul_wz,  pr_mul,  i32, i32>;
defm ADDQ  : MISC_R3<misc_opx_add_q,   pr_add,  i128, i128>;
defm SUBQ  : MISC_R3<misc_opx_sub_q,   pr_sub,  i128, i128>;

//===----------------------------------------------------------------------===//
// extend add/sub/mul instructions for pre-trunc and post-(sign/zero) extension
//===----------------------------------------------------------------------===//
multiclass OP_SEXT<InstBase INSN, PatFrag OpNode> {
  def : Pat<(i64 (sext (OpNode i32:$rb, i32:$rc))), (INSN GR:$rb, GR:$rc)>;
  def : Pat<(i64 (sext (OpNode i32:$rb, (i32 (trunc i64:$rc))))), (INSN GR:$rb, GR:$rc)>;
  def : Pat<(i64 (sext (OpNode (i32 (trunc i64:$rb)), i32:$rc))), (INSN GR:$rb, GR:$rc)>;
}
defm : OP_SEXT<ADDWS, pr_add>;
defm : OP_SEXT<SUBWS, pr_sub>;
defm : OP_SEXT<MULWS, pr_mul>;

multiclass OP_ZEXT<InstBase INSN, PatFrag OpNode> {
  def : Pat<(i64 (zext (OpNode i32:$rb, i32:$rc))), (INSN GR:$rb, GR:$rc)>;
  def : Pat<(i64 (zext (OpNode i32:$rb, (i32 (trunc i64:$rc))))), (INSN GR:$rb, GR:$rc)>;
  def : Pat<(i64 (zext (OpNode (i32 (trunc i64:$rb)), i32:$rc))), (INSN GR:$rb, GR:$rc)>;
}
defm : OP_ZEXT<ADDWZ, pr_add>;
defm : OP_ZEXT<SUBWZ, pr_sub>;
defm : OP_ZEXT<MULWZ, pr_mul>;

// absolute difference i32/i64
defm ABSD  : MISC_R3<misc_opx_absd,   pr_absd,  i64, i64>;
defm ABSDW : MISC_R3<misc_opx_absd_w, pr_absd,  i32, i32>;
// abs(v) => abs(v-0)
def : Pat<(i64 (abs i64:$src)), (ABSD  GR:$src, (i64 gz))>;
def : Pat<(i32 (abs i32:$src)), (ABSDW GR:$src, (i32 gz))>;

defm ADDI    : PRIM_R2_IMM<opcode_addi,     pr_add,  i64, i64, simm21,    simm21_ext>;
defm SUBFI   : PRIM_R2_IMM<opcode_subfi,    pr_subf, i64, i64, simm21,    simm21_ext>;
defm ADDIWS  : PRIM_R2_IMM<opcode_addi_ws,  pr_add,  i32, i32, simm21i32, simm21i32_ext>;
defm ADDIWZ  : PRIM_R2_IMM<opcode_addi_wz,  pr_add,  i32, i32, simm21i32, simm21i32_ext>;
defm SUBFIWS : PRIM_R2_IMM<opcode_subfi_ws, pr_subf, i32, i32, simm21i32, simm21i32_ext>;
defm SUBFIWZ : PRIM_R2_IMM<opcode_subfi_wz, pr_subf, i32, i32, simm21i32, simm21i32_ext>;
defm MULI    : PRIM_R2_IMM<opcode_muli,     pr_mul,  i64, i64, simm21,    simm21_ext>;
defm MULWSI  : PRIM_R2_IMM<opcode_muli_ws,  pr_mul,  i32, i32, simm21i32, simm21i32_ext>;
defm MULWZI  : PRIM_R2_IMM<opcode_muli_wz,  pr_mul,  i32, i32, uimm21i32, uimm21i32_ext>;

// neg rd -> sub %g0, rd, rd
def : InstAlias<"neg\t$ra", (SUBFI GR:$ra, GR:$ra, 0), 0>;
// neg reg, rd -> sub %g0, reg, rd
def : InstAlias<"neg\t$ra, $rb", (SUBFI GR:$ra, GR:$rb, 0), 0>;

// FrameIndex calculations
def : Pat<(i64 AddrFI:$Rs), (ADDI (i64 AddrFI:$Rs), 0)>;
def : Pat<(add (i64 AddrFI:$Rs), simm21:$imm), (ADDI (i64 AddrFI:$Rs), simm21:$imm)>;
def : Pat<(add (i64 AddrFI:$Rs), simm21_ext:$imm), (ADDI_EXT (i64 AddrFI:$Rs), simm21_ext:$imm)>;

//===----------------------------------------------------------------------===//
// extend multiply-immediate instructions for pre-trunc and post-(sign/zero) extension
//===----------------------------------------------------------------------===//

// i32 with signed immediate, post-sign-extension, pre-trunc
multiclass OP_SEXT_IMM<InstBase INSN, InstBaseExt INSN_ext, PatFrag OpNode> {
  // i32 with post-sign-extension
  def : Pat<(i64 (sext (OpNode i32:$rb, simm21i32    :$imm))), (INSN     GR:$rb, simm21i32    :$imm)>;
  def : Pat<(i64 (sext (OpNode i32:$rb, simm21i32_ext:$imm))), (INSN_ext GR:$rb, simm21i32_ext:$imm)>;
  // i32 with pre-trunc and post-sign-extension
  def : Pat<(i64 (sext (OpNode (i32 (trunc i64:$rb)), simm21i32    :$imm))), (INSN     GR:$rb, simm21i32    :$imm)>;
  def : Pat<(i64 (sext (OpNode (i32 (trunc i64:$rb)), simm21i32_ext:$imm))), (INSN_ext GR:$rb, simm21i32_ext:$imm)>;
}
defm : OP_SEXT_IMM<ADDIWS,  ADDIWS_EXT,  pr_add>;
defm : OP_SEXT_IMM<SUBFIWS, SUBFIWS_EXT, pr_subf>;
defm : OP_SEXT_IMM<MULWSI,  MULWSI_EXT,  pr_mul>;

// i32 with unsigned immediate, post-zero-extension, pre-trunc
multiclass OP_ZEXT_IMM<InstBase INSN, InstBaseExt INSN_ext, PatFrag OpNode> {
  // i32 with post-zero-extension
  def : Pat<(i64 (zext (OpNode i32:$rb, uimm21i32    :$imm))), (INSN     GR:$rb, uimm21i32    :$imm)>;
  def : Pat<(i64 (zext (OpNode i32:$rb, uimm21i32_ext:$imm))), (INSN_ext GR:$rb, uimm21i32_ext:$imm)>;
  // i32 with pre-trunc and post-zero-extension
  def : Pat<(i64 (zext (OpNode (i32 (trunc i64:$rb)), uimm21i32    :$imm))), (INSN     GR:$rb, uimm21i32    :$imm)>;
  def : Pat<(i64 (zext (OpNode (i32 (trunc i64:$rb)), uimm21i32_ext:$imm))), (INSN_ext GR:$rb, uimm21i32_ext:$imm)>;
}
defm : OP_ZEXT_IMM<MULWZI,  MULWZI_EXT,  pr_mul>;

// i32 with signed immediate, post-zero-extension, pre-trunc
multiclass OP_ZEXT_SEXT_IMM<InstBase INSN, InstBaseExt INSN_ext, PatFrag OpNode> {
  // i32 with post-zero-extension
  def : Pat<(i64 (zext (OpNode i32:$rb, simm21i32    :$imm))), (INSN     GR:$rb, simm21i32    :$imm)>;
  def : Pat<(i64 (zext (OpNode i32:$rb, simm21i32_ext:$imm))), (INSN_ext GR:$rb, simm21i32_ext:$imm)>;
  // i32 with pre-trunc and post-zero-extension
  def : Pat<(i64 (zext (OpNode (i32 (trunc i64:$rb)), simm21i32    :$imm))), (INSN     GR:$rb, simm21i32    :$imm)>;
  def : Pat<(i64 (zext (OpNode (i32 (trunc i64:$rb)), simm21i32_ext:$imm))), (INSN_ext GR:$rb, simm21i32_ext:$imm)>;
}
defm : OP_ZEXT_SEXT_IMM<ADDIWZ,  ADDIWZ_EXT,  pr_add>;
defm : OP_ZEXT_SEXT_IMM<SUBFIWZ, SUBFIWZ_EXT, pr_subf>;

//===----------------------------------------------------------------------===//
// min/max
//===----------------------------------------------------------------------===//
def pr_smin : PatFrag<(ops node:$src1, node:$src2), (smin node:$src1, node:$src2)>;
def pr_umin : PatFrag<(ops node:$src1, node:$src2), (umin node:$src1, node:$src2)>;
def pr_smax : PatFrag<(ops node:$src1, node:$src2), (smax node:$src1, node:$src2)>;
def pr_umax : PatFrag<(ops node:$src1, node:$src2), (umax node:$src1, node:$src2)>;

defm MINSD : MISC_R3<misc_opx_mins, pr_smin, i64, i64>;
defm MINUD : MISC_R3<misc_opx_minu, pr_umin, i64, i64>;
defm MAXSD : MISC_R3<misc_opx_maxs, pr_smax, i64, i64>;
defm MAXUD : MISC_R3<misc_opx_maxu, pr_umax, i64, i64>;

defm MINSW : MISC_R3<misc_opx_mins_w, pr_smin, i32, i32>;
defm MINUW : MISC_R3<misc_opx_minu_w, pr_umin, i32, i32>;
defm MAXSW : MISC_R3<misc_opx_maxs_w, pr_smax, i32, i32>;
defm MAXUW : MISC_R3<misc_opx_maxu_w, pr_umax, i32, i32>;

defm MINSDI : PRIM_R2_IMM<opcode_minsi, pr_smin, i64, i64, simm21, simm21_ext>;
defm MAXSDI : PRIM_R2_IMM<opcode_maxsi, pr_smax, i64, i64, simm21, simm21_ext>;
defm MINUDI : PRIM_R2_IMM<opcode_minui, pr_umin, i64, i64, uimm21, uimm21_ext>;
defm MAXUDI : PRIM_R2_IMM<opcode_maxui, pr_umax, i64, i64, uimm21, uimm21_ext>;

//===----------------------------------------------------------------------===//
// fused ALU operations
//===----------------------------------------------------------------------===//
def pr_addadd  : PatFrag<(ops node:$src1, node:$src2, node:$src3), (add (add node:$src1, node:$src2), node:$src3)>;
def pr_addsub  : PatFrag<(ops node:$src1, node:$src2, node:$src3), (sub (add node:$src1, node:$src2), node:$src3)>;
def pr_subsub  : PatFrag<(ops node:$src1, node:$src2, node:$src3), (sub node:$src1, (add node:$src2, node:$src3))>;
def pr_muladd  : PatFrag<(ops node:$src1, node:$src2, node:$src3), (add (mul node:$src1, node:$src2), node:$src3)>;
def pr_mulsub  : PatFrag<(ops node:$src1, node:$src2, node:$src3), (sub (mul node:$src1, node:$src2), node:$src3)>;
def pr_mulsubf : PatFrag<(ops node:$src1, node:$src2, node:$src3), (sub node:$src3, (mul node:$src1, node:$src2))>;

defm ADDADD  : FUSED_R4<fused_opx_add_add,  pr_addadd,  i64>;
defm ADDSUB  : FUSED_R4<fused_opx_add_sub,  pr_addsub,  i64>;
defm SUBSUB  : FUSED_R4<fused_opx_sub_sub,  pr_subsub,  i64>;
defm MULADD  : FUSED_R4<fused_opx_mul_add,  pr_muladd,  i64>;
defm MULSUB  : FUSED_R4<fused_opx_mul_sub,  pr_mulsub,  i64>;
defm MULSUBF : FUSED_R4<fused_opx_mul_subf, pr_mulsubf, i64>;

//===----------------------------------------------------------------------===//
/// Compare instructions
//===----------------------------------------------------------------------===//
defm CMPWEQ  : MISC_R3<misc_opx_cmp_eq_w,  seteq,  i1, i32>;
defm CMPWNE  : MISC_R3<misc_opx_cmp_ne_w,  setne,  i1, i32>;
defm CMPWLT  : MISC_R3<misc_opx_cmps_lt_w, setlt,  i1, i32>;
defm CMPWLE  : MISC_R3<misc_opx_cmps_le_w, setle,  i1, i32>;
defm CMPWLTU : MISC_R3<misc_opx_cmpu_lt_w, setult, i1, i32>;
defm CMPWLEU : MISC_R3<misc_opx_cmpu_le_w, setule, i1, i32>;

defm CMPDEQ  : MISC_R3<misc_opx_cmp_eq_d,  seteq,  i1, i64>;
defm CMPDNE  : MISC_R3<misc_opx_cmp_ne_d,  setne,  i1, i64>;
defm CMPDLT  : MISC_R3<misc_opx_cmps_lt_d, setlt,  i1, i64>;
defm CMPDLE  : MISC_R3<misc_opx_cmps_le_d, setle,  i1, i64>;
defm CMPDLTU : MISC_R3<misc_opx_cmpu_lt_d, setult, i1, i64>;
defm CMPDLEU : MISC_R3<misc_opx_cmpu_le_d, setule, i1, i64>;

defm CMPQEQ  : MISC_R3<misc_opx_cmp_eq_q,  seteq,  i1, i128>;
defm CMPQNE  : MISC_R3<misc_opx_cmp_ne_q,  setne,  i1, i128>;
defm CMPQLT  : MISC_R3<misc_opx_cmps_lt_q, setlt,  i1, i128>;
defm CMPQLE  : MISC_R3<misc_opx_cmps_le_q, setle,  i1, i128>;
defm CMPQLTU : MISC_R3<misc_opx_cmpu_lt_q, setult, i1, i128>;
defm CMPQLEU : MISC_R3<misc_opx_cmpu_le_q, setule, i1, i128>;

multiclass CompareGreater<InstBase LT, InstBase LE, InstBase LTU, InstBase LEU, ValueType Ty>
{
  def : Pat<(i1 (setgt  Ty:$rc, Ty:$rb)), (LT  GR:$rb, GR:$rc)>;
  def : Pat<(i1 (setge  Ty:$rc, Ty:$rb)), (LE  GR:$rb, GR:$rc)>;
  def : Pat<(i1 (setugt Ty:$rc, Ty:$rb)), (LTU GR:$rb, GR:$rc)>;
  def : Pat<(i1 (setuge Ty:$rc, Ty:$rb)), (LEU GR:$rb, GR:$rc)>;
}
defm : CompareGreater<CMPWLT, CMPWLE, CMPWLTU, CMPWLEU, i32>;
defm : CompareGreater<CMPDLT, CMPDLE, CMPDLTU, CMPDLEU, i64>;
defm : CompareGreater<CMPQLT, CMPQLE, CMPQLTU, CMPQLEU, i128>;

defm CMPWEQI  : PRIM_R2_IMM<opcode_cmpi_eq_w,  seteq,  i1, i32, simm21i32, simm21i32_ext>;
defm CMPWNEI  : PRIM_R2_IMM<opcode_cmpi_ne_w,  setne,  i1, i32, simm21i32, simm21i32_ext>;
defm CMPWLTI  : PRIM_R2_IMM<opcode_cmpsi_lt_w, setlt,  i1, i32, simm21i32, simm21i32_ext>;
defm CMPWGTI  : PRIM_R2_IMM<opcode_cmpsi_gt_w, setgt,  i1, i32, simm21i32, simm21i32_ext>;
defm CMPWLTUI : PRIM_R2_IMM<opcode_cmpui_lt_w, setult, i1, i32, uimm21i32, uimm21i32_ext>;
defm CMPWGTUI : PRIM_R2_IMM<opcode_cmpui_gt_w, setugt, i1, i32, uimm21i32, uimm21i32_ext>;

defm CMPDEQI  : PRIM_R2_IMM<opcode_cmpi_eq_d,  seteq,  i1, i64, simm21, simm21_ext>;
defm CMPDNEI  : PRIM_R2_IMM<opcode_cmpi_ne_d,  setne,  i1, i64, simm21, simm21_ext>;
defm CMPDLTI  : PRIM_R2_IMM<opcode_cmpsi_lt_d, setlt,  i1, i64, simm21, simm21_ext>;
defm CMPDGTI  : PRIM_R2_IMM<opcode_cmpsi_gt_d, setgt,  i1, i64, simm21, simm21_ext>;
defm CMPDLTUI : PRIM_R2_IMM<opcode_cmpui_lt_d, setult, i1, i64, uimm21, uimm21_ext>;
defm CMPDGTUI : PRIM_R2_IMM<opcode_cmpui_gt_d, setugt, i1, i64, uimm21, uimm21_ext>;

multiclass CompareGreaterImm<InstBase LT, InstBase LTU, InstBase GT, InstBase GTU, ValueType Ty, Operand simmOp, Operand uimmOp>
{
  def : Pat<(i1 (setlt  simmOp:$imm, Ty:$rb)), (GT  GR:$rb, simmOp:$imm)>;
  def : Pat<(i1 (setgt  simmOp:$imm, Ty:$rb)), (LT  GR:$rb, simmOp:$imm)>;
  def : Pat<(i1 (setult uimmOp:$imm, Ty:$rb)), (GTU GR:$rb, uimmOp:$imm)>;
  def : Pat<(i1 (setugt uimmOp:$imm, Ty:$rb)), (LTU GR:$rb, uimmOp:$imm)>;
}
defm : CompareGreaterImm<CMPWLTI, CMPWLTUI, CMPWGTI, CMPWGTUI, i32, simm21i32, uimm21i32>;
defm : CompareGreaterImm<CMPDLTI, CMPDLTUI, CMPDGTI, CMPDGTUI, i64, simm21i64, uimm21i64>;

multiclass CompareGreaterImmExt<InstBaseExt LT, InstBaseExt LTU, InstBaseExt GT, InstBaseExt GTU, ValueType Ty, Operand simmOp, Operand uimmOp>
{
  def : Pat<(i1 (setlt  simmOp:$imm, Ty:$rb)), (GT  GR:$rb, simmOp:$imm)>;
  def : Pat<(i1 (setgt  simmOp:$imm, Ty:$rb)), (LT  GR:$rb, simmOp:$imm)>;
  def : Pat<(i1 (setult uimmOp:$imm, Ty:$rb)), (GTU GR:$rb, uimmOp:$imm)>;
  def : Pat<(i1 (setugt uimmOp:$imm, Ty:$rb)), (LTU GR:$rb, uimmOp:$imm)>;
}
defm : CompareGreaterImmExt<CMPWLTI_EXT, CMPWLTUI_EXT, CMPWGTI_EXT, CMPWGTUI_EXT, i32, simm21i32_ext, uimm21i32_ext>;
defm : CompareGreaterImmExt<CMPDLTI_EXT, CMPDLTUI_EXT, CMPDGTI_EXT, CMPDGTUI_EXT, i64, simm21_ext, uimm21_ext>;

//===----------------------------------------------------------------------===//
// Divide
//===----------------------------------------------------------------------===//
def pr_sdiv : PatFrag<(ops node:$src1, node:$src2), (sdiv node:$src1, node:$src2)>;
def pr_udiv : PatFrag<(ops node:$src1, node:$src2), (udiv node:$src1, node:$src2)>;
def pr_srem : PatFrag<(ops node:$src1, node:$src2), (srem node:$src1, node:$src2)>;
def pr_urem : PatFrag<(ops node:$src1, node:$src2), (urem node:$src1, node:$src2)>;

// Division can trap.
let hasSideEffects = 1 in {
  defm DIVS_W : MISC_R3<misc_opx_div_w,  pr_sdiv, i32, i32>;
  defm DIVU_W : MISC_R3<misc_opx_divu_w, pr_udiv, i32, i32>;
  defm DIVS_D : MISC_R3<misc_opx_div,    pr_sdiv, i64, i64>;
  defm DIVU_D : MISC_R3<misc_opx_divu,   pr_udiv, i64, i64>;

  defm MODS_W : MISC_R3<misc_opx_mod_w,  pr_srem, i32, i32>;
  defm MODU_W : MISC_R3<misc_opx_modu_w, pr_urem, i32, i32>;
  defm MODS_D : MISC_R3<misc_opx_mod,    pr_srem, i64, i64>;
  defm MODU_D : MISC_R3<misc_opx_modu,   pr_urem, i64, i64>;

  defm DIVI  : PRIM_R2_IMM<opcode_divi,  pr_sdiv, i64, i64, simm21, simm21_ext>;
  defm DIVUI : PRIM_R2_IMM<opcode_divui, pr_udiv, i64, i64, uimm21, uimm21_ext>;
  defm MODI  : PRIM_R2_IMM<opcode_modi,  pr_srem, i64, i64, simm21, simm21_ext>;
  defm MODUI : PRIM_R2_IMM<opcode_modui, pr_urem, i64, i64, uimm21, uimm21_ext>;
}

//===----------------------------------------------------------------------===//
// ADJCALLSTACKUP/ADJCALLSTACKDOWN pseudos
//===----------------------------------------------------------------------===//

//  These are target-independent nodes, but have target-specific formats.
def SDT_SPCallSeqStart : SDCallSeqStart<[ SDTCisVT<0, i32>, SDTCisVT<1, i32> ]>;
def SDT_SPCallSeqEnd : SDCallSeqEnd<[ SDTCisVT<0, i32>, SDTCisVT<1, i64> ]>;

def callseq_start : SDNode<"ISD::CALLSEQ_START", SDT_SPCallSeqStart,
                     [SDNPHasChain, SDNPSideEffect, SDNPOutGlue]>;
def callseq_end : SDNode<"ISD::CALLSEQ_END", SDT_SPCallSeqEnd,
                   [SDNPHasChain, SDNPSideEffect, SDNPOptInGlue, SDNPOutGlue]>;

let Defs = [sp], Uses = [sp] in {
def ADJCALLSTACKDOWN : Pseudo<
        (outs), (ins i32imm:$amt1, i32imm:$amt2),
        "!ADJCALLSTACKDOWN $amt1, $amt2",
        [(callseq_start timm:$amt1, timm:$amt2)]>;

// the $link arg for ADJCALLSTACKUP is a fake argument to force liveness
// of link out register and performing out to preferred physical register
def ADJCALLSTACKUP : Pseudo<
        (outs), (ins i32imm:$amt1, GR:$link),
        "!ADJCALLSTACKUP $amt1, $link",
        [(callseq_end timm:$amt1, GR:$link)]>;
}

//===----------------------------------------------------------------------===//
// direct jump/tail_call
//===----------------------------------------------------------------------===//
let isTerminator = 1, isBarrier = 1, isBranch = 1 in {
  def JMP     : RAOPX_Branch    <raopx_opx_jmp, (outs), (ins jump_target    :$imm), "jmp\t$imm", [(br bb:$imm)]>;
  def JMP_EXT : RAOPX_Branch_ext<raopx_opx_jmp, (outs), (ins jump_target_ext:$imm), "jmp.l\t$imm", [(br bb:$imm)]>;
}

let isTerminator = 1, isBarrier = 1, isBranch = 1, isCodeGenOnly = 1 in {
  def JMP_TAIL     : RAOPX_Branch    <raopx_opx_jmp, (outs), (ins calltarget:$imm, variable_ops), "jmp\t$imm", [], IIC_jmp_or_call>;
  def JMP_TAIL_EXT : RAOPX_Branch_ext<raopx_opx_jmp, (outs), (ins calltarget:$imm, variable_ops), "jmp.l\t$imm", [], IIC_jmp_or_call>;
}

//===----------------------------------------------------------------------===//
// Indirect jump/tail_call instructions
//===----------------------------------------------------------------------===//
let isTerminator = 1, isBarrier = 1, isBranch = 1, isIndirectBranch = 1, ra = 0 in {
  def JMP_R : MISC_RabcScale<misc_opx_jmp_r, (outs), (ins GR:$rb, GR:$rc, scale:$scale), "jmp.r\t$rb, $rc, $scale", []>;
}

def : Pat<(brind (i64 (add i64:$rb, (shl i64:$rc, scale:$scale)))), (JMP_R GR:$rb, GR:$rc, scale:$scale)>;
def : Pat<(brind (i64 (add i64:$rb,      i64:$rc               ))), (JMP_R GR:$rb, GR:$rc, 0)>;
def : Pat<(brind           i64:$rb                               ), (JMP_R GR:$rb, (i64 gz), 0)>;

//===----------------------------------------------------------------------===//
// Indirect jump table
//===----------------------------------------------------------------------===//
let isTerminator = 1, isBarrier = 1, isBranch = 1, isIndirectBranch = 1, ra = 0 in {
  def JMP_T    : MISC_Rabc<misc_opx_jmp_t,    (outs), (ins GR:$rb, GR:$rc), "jmp.t\t$rb, $rc", []>;
  def JMP_T_WS : MISC_Rabc<misc_opx_jmp_t_ws, (outs), (ins GR:$rb, GR:$rc), "jmp.t.ws\t$rb, $rc", []>;
  def JMP_T_WZ : MISC_Rabc<misc_opx_jmp_t_wz, (outs), (ins GR:$rb, GR:$rc), "jmp.t.wz\t$rb, $rc", []>;
}

def jmp_table_load_i64 : PatFrag<(ops node:$base, node:$index),
      (brind (i64 (add node:$base, (i64 (sextloadi32 (add node:$base, (shl node:$index, (i32 2))))))))>;
def : Pat<(jmp_table_load_i64 i64:$rb, i64:$rc), (JMP_T GR:$rb, GR:$rc)>;

// FIXME: switches with i32 indices use zero extension before indexing: srlwi %r,%r,0
def jmp_table_load_u32 : PatFrag<(ops node:$base, node:$index),
      (brind (i64 (add node:$base, (i64 (sextloadi32 (add (shl (i64 (zext node:$index)), (i32 2)), node:$base))))))>;

//def : Pat<(jmp_table_load_i32 i64:$rb, i32:$rc), (JMP_T_WS GR:$rb, GR:$rc)>;
def : Pat<(jmp_table_load_u32 i64:$rb, i32:$rc), (JMP_T_WZ GR:$rb, GR:$rc)>;

//===----------------------------------------------------------------------===//
// Indirect jump/tail_call after load instruction
//===----------------------------------------------------------------------===//
let isTerminator = 1, isBarrier = 1, isBranch = 1, isIndirectBranch = 1, ra = 0 in {
  def JMP_MI : MISC_RabcScale<misc_opx_jmp_mi,
        (outs), (ins GR:$rb, GR:$rc, scale:$scale),
        "jmp.mi\t$rb, $rc, $scale", []>;
}

def jmp_load_indexed_scaled_s64 : PatFrag<
      (ops node:$base, node:$index, node:$scale),
      (brind (iPTR (add node:$base,
            (i64 (sextloadi32 (add node:$base,
            (shl (i64 (sext node:$index)), node:$scale)))))))>;

def : Pat<(jmp_load_indexed_scaled_s64 iPTR:$rb, i32:$rc, scale:$scale),
          (JMP_MI GR:$rb, GR:$rc, scale:$scale)>;


def jmp_load_indexed_s64 : PatFrag<
      (ops node:$base, node:$index),
      (brind (iPTR (add node:$base,
            (i64 (sextloadi32 (add node:$base,
            (i64 (sext node:$index))))))))>;

def : Pat<(jmp_load_indexed_s64 iPTR:$rb, i32:$rc),
          (JMP_MI GR:$rb, GR:$rc, 0)>;

def jmp_load_s64 : PatFrag<
      (ops node:$base),
      (brind (iPTR (add node:$base,
            (i64 (sextloadi32 node:$base)))))>;

def : Pat<(jmp_load_s64 iPTR:$rb),
          (JMP_MI GR:$rb, (i64 gz), 0)>;

//===----------------------------------------------------------------------===//
// TailCall patterns
//===----------------------------------------------------------------------===//
def SDT_SPTailCall : SDTypeProfile<0, -1, [SDTCisVT<0, i64>]>;
def tailcall : SDNode<"PostriscISD::TAIL_CALL", SDT_SPTailCall,
                      [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue,
                       SDNPVariadic]>;

def : Pat<(tailcall  tglobaladdr:$addr), (JMP_TAIL  tglobaladdr:$addr)>;
def : Pat<(tailcall texternalsym:$addr), (JMP_TAIL texternalsym:$addr)>;

def : Pat<(tailcall (i64 (add i64:$rb, (shl i64:$rc, scale:$scale)))), (JMP_R GR:$rb, GR:$rc, scale:$scale)>;
def : Pat<(tailcall (i64 (add i64:$rb,      i64:$rc               ))), (JMP_R GR:$rb, GR:$rc, 0)>;
def : Pat<(tailcall           i64:$rb                               ), (JMP_R GR:$rb, (i64 gz), 0)>;

//===----------------------------------------------------------------------===//
// Call Instructions
//===----------------------------------------------------------------------===//
let isCall = 1 in
{
  // call ip+offset
  def CALL     : PRIMARY_RaI28    <opcode_call_r, (outs GR:$ra), (ins calltarget:$imm, variable_ops), "call.r\t$ra, $imm", [], IIC_jmp_or_call>;
  def CALL_EXT : PRIMARY_RaI28_ext<opcode_call_r, (outs GR:$ra), (ins calltarget:$imm, variable_ops), "call.r.l\t$ra, $imm", [], IIC_jmp_or_call>;

  // call base+index
  def CALL_RI : MISC_Rabc<misc_opx_call_ri, (outs GR:$ra), (ins GR:$rb, GR:$rc, variable_ops), "call.ri\t$ra, $rb, $rc", [], IIC_jmp_or_call>;

  // call mem<iPTR>[ip+offset]
  def CALL_PLT     : PRIMARY_RaI28    <opcode_call_plt, (outs GR:$ra), (ins simm28    :$imm, variable_ops), "call.plt\t$ra, $imm", [], IIC_jmp_or_call>;
  def CALL_PLT_EXT : PRIMARY_RaI28_ext<opcode_call_plt, (outs GR:$ra), (ins simm28_ext:$imm, variable_ops), "call.plt.l\t$ra, $imm", [], IIC_jmp_or_call>;

  // call mem<iPTR>[base+offset]
  def CALL_MI : MISC_RabI10<misc_opx_call_mi, (outs GR:$ra), (ins GR:$rb, stride_imm:$imm, variable_ops), "call.mi\t$ra, $rb, $imm", [], IIC_jmp_or_call>;

  // call base + mem<i32>[base + offset]
  def CALL_RVT : MISC_RabI10<misc_opx_call_rvt, (outs GR:$ra), (ins GR:$rb, stride_imm:$imm, variable_ops), "call.rvt\t$ra, $rb, $imm", [], IIC_jmp_or_call>;
}

//===----------------------------------------------------------------------===//
// Call patterns
//===----------------------------------------------------------------------===//
def SDT_SPCall : SDTypeProfile<1, -1 /*variable?*/, [SDTCisVT<0, i64>, SDTCisVT<1, i64>]>;
def call : SDNode<"PostriscISD::CALL", SDT_SPCall,
           [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue, SDNPVariadic]>;

def call_load : PatFrag<(ops node:$ptr), (call (i64 (load node:$ptr)))>;

// call ip + offset
// global/external call should be properly wrapped to corresponding PCREL wrapper
def : Pat<(call (pcrel_code_wrapper       tglobaladdr:$addr)), (CALL       tglobaladdr:$addr)>;
def : Pat<(call (pcrel_code_wrapper      texternalsym:$addr)), (CALL      texternalsym:$addr)>;
def : Pat<(call (pcrel_code_wrapper_ext   tglobaladdr:$addr)), (CALL_EXT   tglobaladdr:$addr)>;
def : Pat<(call (pcrel_code_wrapper_ext  texternalsym:$addr)), (CALL_EXT  texternalsym:$addr)>;

// call base [+dyn_offset]
def : Pat<(call (add iPTR:$rb, i64:$rc)), (CALL_RI GR:$rb, GR:$rc)>;
def : Pat<(call iPTR:$rb), (CALL_RI GR:$rb, (i64 gz))>;

// call mem8[ip+offset]
// global/external function pointers should be properly wrapped to corresponding PCREL wrapper
def : Pat<(call_load (pcrel_data_wrapper       tglobaladdr:$addr)), (CALL_PLT       tglobaladdr:$addr)>;
def : Pat<(call_load (pcrel_data_wrapper      texternalsym:$addr)), (CALL_PLT      texternalsym:$addr)>;
def : Pat<(call_load (pcrel_data_wrapper_ext   tglobaladdr:$addr)), (CALL_PLT_EXT   tglobaladdr:$addr)>;
def : Pat<(call_load (pcrel_data_wrapper_ext  texternalsym:$addr)), (CALL_PLT_EXT  texternalsym:$addr)>;

// call dword_mem[base+offset]
def : Pat<(call_load i64:$rb), (CALL_MI GR:$rb, 0)>;
def : Pat<(call_load (add i64:$rb, simm11:$imm)), (CALL_MI GR:$rb, simm11:$imm)>;

// call base + sword_mem[base + offset]
def call_rvt      : PatFrag<(ops node:$base, node:$imm), (call (add node:$base, (i64 (sextloadi32 (add node:$base, node:$imm)))))>;
def call_rvt_zero : PatFrag<(ops node:$base           ), (call (add node:$base, (i64 (sextloadi32      node:$base            ))))>;

// (brind (i64 (add node:$base, (i64 (sextloadi32 (add (shl (i64 (zext node:$index)), (i32 2)), node:$base))))))>;

def : Pat<(call_rvt      i64:$rb, simm11:$imm), (CALL_RVT GR:$rb, simm11:$imm)>;
def : Pat<(call_rvt_zero i64:$rb             ), (CALL_RVT GR:$rb, 0)>;

//===----------------------------------------------------------------------===//
// TLS Call patterns (call of `__tls_get_addr`)
//===----------------------------------------------------------------------===//
def tlscall : SDNode<"PostriscISD::TLS_CALL", SDT_SPCall,
                 [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue, SDNPVariadic]>;
def tlscall_ext : SDNode<"PostriscISD::TLS_CALL_EXT", SDT_SPCall,
                [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue, SDNPVariadic]>;

def : Pat<(tlscall     texternalsym:$addr, tglobaltlsaddr:$sym), (CALL     texternalsym:$addr, tglobaltlsaddr:$sym)>;
def : Pat<(tlscall_ext texternalsym:$addr, tglobaltlsaddr:$sym), (CALL_EXT texternalsym:$addr, tglobaltlsaddr:$sym)>;

//===----------------------------------------------------------------------===//
// returns: lowered to `RET_GLUE`
//===----------------------------------------------------------------------===//
def SDT_SPRet : SDTypeProfile<0, 1, [SDTCisVT<0, i64>]>;
def retglue : SDNode<"PostriscISD::RET_GLUE", SDT_SPRet,
                     [SDNPHasChain, SDNPOptInGlue, SDNPVariadic]>;

let isReturn = 1, isTerminator = 1, isBarrier = 1 in
{
  let Defs = [sp], Uses = [sp], rb = 0 in {
    def RETF     : RAOPX_RbI21    <raopx_opx_retf, (outs), (ins uimm21    :$imm), "ret.f\t$imm",   [(retglue uimm21    :$imm)], IIC_jmp_or_call>;
    def RETF_EXT : RAOPX_RbI21_ext<raopx_opx_retf, (outs), (ins uimm21_ext:$imm), "ret.f.l\t$imm", [(retglue uimm21_ext:$imm)], IIC_jmp_or_call>;
  }
  def RET : MISC_NoArgs<misc_opx_ret, (outs), (ins), []>;
}

// at least one alias - to not hurt about code changes
def : MnemonicAlias<"return", "ret">;

def MOV : MISC_Rab<misc_opx_mov, (outs GR:$ra), (ins GR:$rb), "mov\t$ra, $rb", []>;

def : Pat<(i64 (int_postrisc_stack_pointer)), (i64 sp)>;
def : Pat<(i64 (int_thread_pointer)), (i64 tp)>;

//===----------------------------------------------------------------------===//
// Load immediate
//===----------------------------------------------------------------------===//
let isMoveImm = 1 in {
  def LDI     : PRIMARY_RaI28    <opcode_ldi, (outs GR:$ra), (ins simm28    :$imm), "ldi\t$ra, $imm",   [(set i64:$ra, simm28    :$imm)]>;
  def LDI_EXT : PRIMARY_RaI28_ext<opcode_ldi, (outs GR:$ra), (ins simm28_ext:$imm), "ldi.l\t$ra, $imm", [(set i64:$ra, simm28_ext:$imm)]>;
}

let Constraints = "$rx = $ra" in {
  def LDIH     : PRIMARY_RaI28    <opcode_ldih, (outs GR:$ra), (ins GR:$rx, simm28    :$imm), "ldih\t$ra, $imm",   []>;
  def LDIH_EXT : PRIMARY_RaI28_ext<opcode_ldih, (outs GR:$ra), (ins GR:$rx, simm28_ext:$imm), "ldih.l\t$ra, $imm", []>;
}

// convert possible i32 to i64
def cvt64 : SDNodeXForm<imm, [{
  int64_t enc = N->getSExtValue();
  enc = (enc << 32) >> 32;
  return CurDAG->getSignedTargetConstant(enc, SDLoc(N), MVT::i64);
}]>;

def cvt128 : SDNodeXForm<imm, [{
  int64_t enc = N->getSExtValue();
  return CurDAG->getSignedTargetConstant(enc, SDLoc(N), MVT::i128);
}]>;

// zero materialization
def : Pat<(i1 0), (COPY (i1 gz))>;
def : Pat<(i32 0), (COPY (i32 gz))>;
def : Pat<(i64 0), (COPY (i64 gz))>;
def : Pat<(i128 0), (COPY (i128 gz))>;

// i32&i64 28-bit signed short immediates may be materialized by ldi
def simm28x : PatLeaf<(imm), [{ return isSextInt(N->getAPIntValue(), 28); }]>;
def : Pat<(i32 simm28x:$val), (LDI (cvt64 $val))>;
def : Pat<(i64 simm28x:$val), (LDI $val)>;
def : Pat<(i128 simm28x:$val), (LDI (cvt128 $val))>;

// i32 big signed immediates may be materialized by ldi.l
def simm32x : PatLeaf<(imm), [{ return isSextInt(N->getAPIntValue(), 32); }]>;
def : Pat<(i32 simm32x:$val), (LDI_EXT (cvt64 $val))>;

// i32 big unsigned immediates may be also materialized by ldi.l
def uimm32x : PatLeaf<(imm), [{ return isSextInt(N->getAPIntValue(), 32); }]>;
def : Pat<(i32 uimm32x:$val), (LDI_EXT (cvt64 $val))>;

// i64 big immediates may be materialized by ldi.l
def simm64x : PatLeaf<(imm), [{ return isSextInt(N->getAPIntValue(), 64); }]>;
def : Pat<(i64 simm64x:$val), (LDI_EXT $val)>;
def : Pat<(i128 simm64x:$val), (LDI_EXT (cvt128 $val))>;


// i128 big immediates may be materialized by pair ldi.l+ldih.l
def simm128x : PatLeaf<(imm), [{ return isSextInt(N->getAPIntValue(), 128); }]>;

def cvt128hi : SDNodeXForm<imm, [{
  APInt enc = N->getAPIntValue();
  enc = enc.ashr(64);
  int64_t tmp = enc.getSExtValue();
  return CurDAG->getSignedTargetConstant(tmp, SDLoc(N), MVT::i64);
}]>;
def cvt128lo : SDNodeXForm<imm, [{
  APInt enc = N->getAPIntValue();
  enc &= 0xFFFFFFFFFFFFFFFFull;
  int64_t tmp = enc.getZExtValue();
  return CurDAG->getSignedTargetConstant(tmp, SDLoc(N), MVT::i64);
}]>;

def : Pat<(i128 simm128x:$val), (LDIH_EXT (LDI_EXT (cvt128lo $val)), (cvt128hi $val))>;

//===----------------------------------------------------------------------===//
// When we need lesser value, the high bits are don't care - trunc is free.
// When we need bigger value and high bits are don't care (undefined) - anyext is free.
//===----------------------------------------------------------------------===//
def : Pat<(i32 (trunc i128:$val)), (COPY_TO_REGCLASS $val, GR)>;
def : Pat<(i64 (trunc i128:$val)), (COPY_TO_REGCLASS $val, GR)>;
def : Pat<(i32 (trunc  i64:$val)), (COPY_TO_REGCLASS $val, GR)>;

def : Pat<(i32  (anyext i1:$val)), (COPY_TO_REGCLASS $val, GR)>;
def : Pat<(i64  (anyext i1:$val)), (COPY_TO_REGCLASS $val, GR)>;
def : Pat<(i128 (anyext i1:$val)), (COPY_TO_REGCLASS $val, GR)>;
def : Pat<(i64  (anyext i32:$val)), (COPY_TO_REGCLASS $val, GR)>;
def : Pat<(i128 (anyext i32:$val)), (COPY_TO_REGCLASS $val, GR)>;
def : Pat<(i128 (anyext i64:$val)), (COPY_TO_REGCLASS $val, GR)>;

//===----------------------------------------------------------------------===//
// static/internal function addressing
//===----------------------------------------------------------------------===//
def CA_R     : PRIMARY_RaI28    <opcode_ca_r, (outs GR:$ra), (ins simm28    :$imm), "ca.r\t$ra, $imm", []>;
def CA_R_EXT : PRIMARY_RaI28_ext<opcode_ca_r, (outs GR:$ra), (ins simm28_ext:$imm), "ca.r.l\t$ra, $imm", []>;

// global/external address should be properly wrapped to corresponding PCREL wrapper
def : Pat<(i64 (pcrel_code_wrapper        tglobaladdr:$addr)), (CA_R        tglobaladdr:$addr)>;
def : Pat<(i64 (pcrel_code_wrapper         tconstpool:$addr)), (CA_R         tconstpool:$addr)>;
def : Pat<(i64 (pcrel_code_wrapper       texternalsym:$addr)), (CA_R       texternalsym:$addr)>;
def : Pat<(i64 (pcrel_code_wrapper     tglobaltlsaddr:$addr)), (CA_R     tglobaltlsaddr:$addr)>;

def : Pat<(i64 (pcrel_code_wrapper_ext    tglobaladdr:$addr)), (CA_R_EXT    tglobaladdr:$addr)>;
def : Pat<(i64 (pcrel_code_wrapper_ext     tconstpool:$addr)), (CA_R_EXT     tconstpool:$addr)>;
def : Pat<(i64 (pcrel_code_wrapper_ext   texternalsym:$addr)), (CA_R_EXT   texternalsym:$addr)>;
def : Pat<(i64 (pcrel_code_wrapper_ext tglobaltlsaddr:$addr)), (CA_R_EXT tglobaltlsaddr:$addr)>;

//===----------------------------------------------------------------------===//
// static/internal global data addresses, constant pool entries
//===----------------------------------------------------------------------===//
def CA_RF     : PRIMARY_RaI28    <opcode_ca_rf, (outs GR:$ra), (ins uimm28    :$imm), "ca.rf\t$ra, $imm", []>;
def CA_RF_EXT : PRIMARY_RaI28_ext<opcode_ca_rf, (outs GR:$ra), (ins uimm28_ext:$imm), "ca.rf.l\t$ra, $imm", []>;

def : Pat<(i64 (pcrel_data_wrapper        tglobaladdr:$addr)), (CA_RF        tglobaladdr:$addr)>;
def : Pat<(i64 (pcrel_data_wrapper         tconstpool:$addr)), (CA_RF         tconstpool:$addr)>;
def : Pat<(i64 (pcrel_data_wrapper       texternalsym:$addr)), (CA_RF       texternalsym:$addr)>;
def : Pat<(i64 (pcrel_data_wrapper     tglobaltlsaddr:$addr)), (CA_RF     tglobaltlsaddr:$addr)>;
def : Pat<(i64 (pcrel_data_wrapper         tjumptable:$addr)), (CA_RF         tjumptable:$addr)>;

def : Pat<(i64 (pcrel_data_wrapper_ext    tglobaladdr:$addr)), (CA_RF_EXT    tglobaladdr:$addr)>;
def : Pat<(i64 (pcrel_data_wrapper_ext     tconstpool:$addr)), (CA_RF_EXT     tconstpool:$addr)>;
def : Pat<(i64 (pcrel_data_wrapper_ext   texternalsym:$addr)), (CA_RF_EXT   texternalsym:$addr)>;
def : Pat<(i64 (pcrel_data_wrapper_ext tglobaltlsaddr:$addr)), (CA_RF_EXT tglobaltlsaddr:$addr)>;
def : Pat<(i64 (pcrel_data_wrapper_ext     tjumptable:$addr)), (CA_RF_EXT     tjumptable:$addr)>;

//===----------------------------------------------------------------------===//
// TLS addressing
//===----------------------------------------------------------------------===//
def : Pat<(add i64:$r, tglobaltlsaddr:$addr), (ADDI $r, tglobaltlsaddr:$addr)>;
def : Pat<(add i64:$Rs, (tls_offset_wrapper     tglobaltlsaddr:$addr)), (ADDI     i64:$Rs, tglobaltlsaddr:$addr)>;
def : Pat<(add i64:$Rs, (tls_offset_wrapper_ext tglobaltlsaddr:$addr)), (ADDI_EXT i64:$Rs, tglobaltlsaddr:$addr)>;
