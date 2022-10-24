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

// Branch targets have OtherVT type.
def jump_target : Operand<OtherVT> {
  let EncoderMethod = "getJumpTargetOpValue<false>";
  let DecoderMethod = "DecodeBranch<28>";
}
def jump_target_ext : Operand<OtherVT> {
  let EncoderMethod = "getJumpTargetOpValue<true>";
  let DecoderMethod = "DecodeBranch<64>";
}

def brtarget : Operand<OtherVT> {
  let EncoderMethod = "getBranchTargetOpValue<false>";
  let DecoderMethod = "DecodeBranch<16>";
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
  let DecoderMethod = "DecodeBranch<64>";
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
def pr_and  : PatFrag<(ops node:$src1, node:$src2), (and node:$src1, node:$src2)>;
def pr_or   : PatFrag<(ops node:$src1, node:$src2), (or  node:$src1, node:$src2)>;
def pr_xor  : PatFrag<(ops node:$src1, node:$src2), (xor node:$src1, node:$src2)>;

def pr_nand : PatFrag<(ops node:$src1, node:$src2), (not (and node:$src1, node:$src2))>;
def pr_nor  : PatFrag<(ops node:$src1, node:$src2), (not (or  node:$src1, node:$src2))>;
def pr_xnor : PatFrag<(ops node:$src1, node:$src2), (not (xor node:$src1, node:$src2))>;
def pr_andn : PatFrag<(ops node:$src1, node:$src2), (and (not node:$src1), node:$src2)>;
def pr_orn  : PatFrag<(ops node:$src1, node:$src2), (or  (not node:$src1), node:$src2)>;

//===----------------------------------------------------------------------===//
// Pseudo instructions.
//===----------------------------------------------------------------------===//
class Pseudo<dag outs, dag ins, string asmstr, list<dag> pattern>
   : InstBase<opcode_misc, outs, ins, asmstr, pattern> {
  let isCodeGenOnly = 1;
  let isPseudo = 1;
}

//===----------------------------------------------------------------------===//
// Instruction Class Templates
//===----------------------------------------------------------------------===//
multiclass MISC_R3<misc_opx opx, string OpcStr, PatFrag OpNode, ValueType Tdst, ValueType Tsrc, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : MISC_Rabc<opx, (outs GR:$ra), (ins GR:$rb, GR:$rc),
         !strconcat(OpcStr, "\t$ra, $rb, $rc"),
         [(set Tdst:$ra, (OpNode Tsrc:$rb, Tsrc:$rc))], itin>;
}

multiclass MISC_R2<misc_opx opx, string OpcStr, PatFrag OpNode, ValueType Tdst, ValueType Tsrc, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : MISC_Rab<opx, (outs GR:$ra), (ins GR:$rb),
         !strconcat(OpcStr, "\t$ra, $rb"),
         [(set Tdst:$ra, (OpNode Tsrc:$rb))], itin>;
}

multiclass PRIM_R2_IMM<opcode_opx opcode, string OpcStr, PatFrag OpNode, ValueType Tdst, ValueType Tsrc,
  Operand immOp, Operand immOpExt, InstrItinClass itin = IIC_iu_instr>
{
  // Ra = Rb Op imm21
  def NAME : PRIMARY_RabI21<opcode, (outs GR:$ra), (ins GR:$rb, immOp:$imm),
                 !strconcat(OpcStr, "\t$ra, $rb, $imm"),
                 [(set Tdst:$ra, (OpNode Tsrc:$rb, immOp:$imm))],
                 itin>;

  // Ra = Rb Op imm21_ext
  def NAME # _EXT : PRIMARY_RabI21_ext<opcode, (outs GR:$ra), (ins GR:$rb, immOpExt:$imm),
                 !strconcat(OpcStr, ".l\t$ra, $rb, $imm"),
                 [(set Tdst:$ra, (OpNode Tsrc:$rb, immOpExt:$imm))],
                 itin>;
}

defm ADD   : MISC_R3<misc_opx_add,    "add",    pr_add,  i64, i64>;
defm ADDW  : MISC_R3<misc_opx_addw,   "addw",   pr_add,  i32, i32>;
defm SUB   : MISC_R3<misc_opx_sub,    "sub",    pr_sub,  i64, i64>;
defm SUBW  : MISC_R3<misc_opx_subw,   "subw",   pr_sub,  i32, i32>;
defm MULWS : MISC_R3<misc_opx_mulws,  "mulws",  pr_mul,  i32, i32>;
defm MULWZ : MISC_R3<misc_opx_mulwz,  "mulwz",  pr_mul,  i32, i32>;
defm MUL   : MISC_R3<misc_opx_mul,    "mul",    pr_mul,  i64, i64>;
defm ADDQ  : MISC_R3<misc_opx_addq,   "addq",   pr_add,  i128, i128>;
defm SUBQ  : MISC_R3<misc_opx_subq,   "subq",   pr_sub,  i128, i128>;

////////////////////////////////////////////////////////////////////////////////////////////////////
// extend add/sub/mul instructions for pre-trunc and post-(sign/zero) extension
////////////////////////////////////////////////////////////////////////////////////////////////////
multiclass OP_SEXT<InstBase INSN, PatFrag OpNode> {
  def : Pat<(i64 (sext (OpNode i32:$rb, i32:$rc))), (INSN GR:$rb, GR:$rc)>;
  def : Pat<(i64 (sext (OpNode i32:$rb, (i32 (trunc i64:$rc))))), (INSN GR:$rb, GR:$rc)>;
  def : Pat<(i64 (sext (OpNode (i32 (trunc i64:$rb)), i32:$rc))), (INSN GR:$rb, GR:$rc)>;
}
defm : OP_SEXT<ADDW, pr_add>;
defm : OP_SEXT<SUBW, pr_sub>;
defm : OP_SEXT<MULWS, pr_mul>;

multiclass OP_ZEXT<InstBase INSN, PatFrag OpNode> {
  def : Pat<(i64 (zext (OpNode i32:$rb, i32:$rc))), (INSN GR:$rb, GR:$rc)>;
  def : Pat<(i64 (zext (OpNode i32:$rb, (i32 (trunc i64:$rc))))), (INSN GR:$rb, GR:$rc)>;
  def : Pat<(i64 (zext (OpNode (i32 (trunc i64:$rb)), i32:$rc))), (INSN GR:$rb, GR:$rc)>;
}
defm : OP_ZEXT<MULWZ, pr_mul>;

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
defm AND  : MISC_R3<misc_opx_and,  "and",  pr_and,  i64, i64>;
defm OR   : MISC_R3<misc_opx_or,   "or",   pr_or,   i64, i64>;
defm XOR  : MISC_R3<misc_opx_xor,  "xor",  pr_xor,  i64, i64>;
defm NAND : MISC_R3<misc_opx_nand, "nand", pr_nand, i64, i64>;
defm NOR  : MISC_R3<misc_opx_nor,  "nor",  pr_nor,  i64, i64>;
defm XNOR : MISC_R3<misc_opx_xnor, "xnor", pr_xnor, i64, i64>;
defm ANDN : MISC_R3<misc_opx_andn, "andn", pr_andn, i64, i64>;
defm ORN  : MISC_R3<misc_opx_orn,  "orn",  pr_orn,  i64, i64>;

// absolute difference i32/i64
defm ABSD  : MISC_R3<misc_opx_absd,  "absd",  pr_absd,  i64, i64>;
defm ABSDW : MISC_R3<misc_opx_absdw, "absdw", pr_absd,  i32, i32>;
// abs(v) => abs(v-0)
def : Pat<(i64 (abs i64:$src)), (ABSD  GR:$src, (i64 gz))>;
def : Pat<(i32 (abs i32:$src)), (ABSDW GR:$src, (i32 gz))>;

defm ADDI    : PRIM_R2_IMM<opcode_addi,    "addi",    pr_add,  i64, i64, simm21,    simm21_ext>;
defm SUBFI   : PRIM_R2_IMM<opcode_subfi,   "subfi",   pr_subf, i64, i64, simm21,    simm21_ext>;
defm ADDIWS  : PRIM_R2_IMM<opcode_addiws,  "addiws",  pr_add,  i32, i32, simm21i32, simm21i32_ext>;
defm ADDIWZ  : PRIM_R2_IMM<opcode_addiwz,  "addiwz",  pr_add,  i32, i32, simm21i32, simm21i32_ext>;
defm SUBFIWS : PRIM_R2_IMM<opcode_subfiws, "subfiws", pr_subf, i32, i32, simm21i32, simm21i32_ext>;
defm SUBFIWZ : PRIM_R2_IMM<opcode_subfiwz, "subfiwz", pr_subf, i32, i32, simm21i32, simm21i32_ext>;
defm MULI    : PRIM_R2_IMM<opcode_muli,    "muli",    pr_mul,  i64, i64, simm21,    simm21_ext>;
defm MULWSI  : PRIM_R2_IMM<opcode_mulwsi,  "mulwsi",  pr_mul,  i32, i32, simm21i32, simm21i32_ext>;
defm MULWZI  : PRIM_R2_IMM<opcode_mulwzi,  "mulwzi",  pr_mul,  i32, i32, uimm21i32, uimm21i32_ext>;
defm ANDI    : PRIM_R2_IMM<opcode_andi,    "andi",    pr_and,  i64, i64, simm21,    simm21_ext>;
defm ORI     : PRIM_R2_IMM<opcode_ori,     "ori",     pr_or,   i64, i64, simm21,    simm21_ext>;
defm XORI    : PRIM_R2_IMM<opcode_xori,    "xori",    pr_xor,  i64, i64, simm21,    simm21_ext>;
defm ANDNI   : PRIM_R2_IMM<opcode_andni,   "andni",   pr_andn, i64, i64, simm21,    simm21_ext>;

////////////////////////////////////////////////////////////////////////////////////////////////////
// extend multiply-immediate instructions for pre-trunc and post-(sign/zero) extension
////////////////////////////////////////////////////////////////////////////////////////////////////

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

////////////////////////////////////////////////////////////////////////////////////////////////////
// binary ops is same for i1/i32/i64/i128 bit
////////////////////////////////////////////////////////////////////////////////////////////////////
let isCodeGenOnly = 1 in {
  defm ANDW  : MISC_R3<misc_opx_and,  "and",  pr_and,  i32, i32>;
  defm ORW   : MISC_R3<misc_opx_or,   "or",   pr_or,   i32, i32>;
  defm XORW  : MISC_R3<misc_opx_xor,  "xor",  pr_xor,  i32, i32>;
  defm NANDW : MISC_R3<misc_opx_nand, "nand", pr_nand, i32, i32>;
  defm NORW  : MISC_R3<misc_opx_nor,  "nor",  pr_nor,  i32, i32>;
  defm XNORW : MISC_R3<misc_opx_xnor, "xnor", pr_xnor, i32, i32>;
  defm ANDNW : MISC_R3<misc_opx_andn, "andn", pr_andn, i32, i32>;
  defm ORNW  : MISC_R3<misc_opx_orn,  "orn",  pr_orn,  i32, i32>;

  // nand, nor, xnor, andn, orn aren't used for i1, because extend ones outside first bit
  defm ANDB  : MISC_R3<misc_opx_and,  "and",  pr_and,  i1, i1>;
  defm ORB   : MISC_R3<misc_opx_or,   "or",   pr_or,   i1, i1>;
  defm XORB  : MISC_R3<misc_opx_xor,  "xor",  pr_xor,  i1, i1>;

  defm ANDIW  : PRIM_R2_IMM<opcode_andi,  "andi",  pr_and,  i32, i32, simm21i32, simm21i32_ext>;
  defm ORIW   : PRIM_R2_IMM<opcode_ori,   "ori",   pr_or,   i32, i32, simm21i32, simm21i32_ext>;
  defm XORIW  : PRIM_R2_IMM<opcode_xori,  "xori",  pr_xor,  i32, i32, simm21i32, simm21i32_ext>;
  defm ANDNIW : PRIM_R2_IMM<opcode_andni, "andni", pr_andn, i32, i32, simm21i32, simm21i32_ext>;

  defm ANDQ  : MISC_R3<misc_opx_and,  "and",  pr_and,  i128, i128>;
  defm ORQ   : MISC_R3<misc_opx_or,   "or",   pr_or,   i128, i128>;
  defm XORQ  : MISC_R3<misc_opx_xor,  "xor",  pr_xor,  i128, i128>;
  defm NANDQ : MISC_R3<misc_opx_nand, "nand", pr_nand, i128, i128>;
  defm NORQ  : MISC_R3<misc_opx_nor,  "nor",  pr_nor,  i128, i128>;
  defm XNORQ : MISC_R3<misc_opx_xnor, "xnor", pr_xnor, i128, i128>;
  defm ANDNQ : MISC_R3<misc_opx_andn, "andn", pr_andn, i128, i128>;
  defm ORNQ  : MISC_R3<misc_opx_orn,  "orn",  pr_orn,  i128, i128>;
}

// neg rd -> sub %g0, rd, rd
def : InstAlias<"neg\t$ra", (SUBFI GR:$ra, GR:$ra, 0), 0>;
// neg reg, rd -> sub %g0, reg, rd
def : InstAlias<"neg\t$ra, $rb", (SUBFI GR:$ra, GR:$rb, 0), 0>;

// not rd -> xnor rd, %rd, rd
//def : InstAlias<"not\t$ra", (XNOR GR:$ra, GR:$ra, gz), 0>;
// not reg, rd -> xnor reg, %g0, rd
//def : InstAlias<"not\t$ra, $rb", (XNOR GR:$ra, GR:$rb, gz), 0>;
// clr rd -> or %g0, %g0, rd
//def : InstAlias<"clr\t$rd", (XOR GR:$rd, GR:$rd, GR:$rd), 0>;

//===----------------------------------------------------------------------===//
// min/max
//===----------------------------------------------------------------------===//
def pr_smin : PatFrag<(ops node:$src1, node:$src2), (smin node:$src1, node:$src2)>;
def pr_umin : PatFrag<(ops node:$src1, node:$src2), (umin node:$src1, node:$src2)>;
def pr_smax : PatFrag<(ops node:$src1, node:$src2), (smax node:$src1, node:$src2)>;
def pr_umax : PatFrag<(ops node:$src1, node:$src2), (umax node:$src1, node:$src2)>;

defm MINSD : MISC_R3<misc_opx_mins, "mins", pr_smin, i64, i64>;
defm MINUD : MISC_R3<misc_opx_minu, "minu", pr_umin, i64, i64>;
defm MAXSD : MISC_R3<misc_opx_maxs, "maxs", pr_smax, i64, i64>;
defm MAXUD : MISC_R3<misc_opx_maxu, "maxu", pr_umax, i64, i64>;

defm MINSW : MISC_R3<misc_opx_minsw, "minsw", pr_smin, i32, i32>;
defm MINUW : MISC_R3<misc_opx_minuw, "minuw", pr_umin, i32, i32>;
defm MAXSW : MISC_R3<misc_opx_maxsw, "maxsw", pr_smax, i32, i32>;
defm MAXUW : MISC_R3<misc_opx_maxuw, "maxuw", pr_umax, i32, i32>;

defm MINSDI : PRIM_R2_IMM<opcode_minsi, "minsi", pr_smin, i64, i64, simm21, simm21_ext>;
defm MAXSDI : PRIM_R2_IMM<opcode_maxsi, "maxsi", pr_smax, i64, i64, simm21, simm21_ext>;
defm MINUDI : PRIM_R2_IMM<opcode_minui, "minui", pr_umin, i64, i64, uimm21, uimm21_ext>;
defm MAXUDI : PRIM_R2_IMM<opcode_maxui, "maxui", pr_umax, i64, i64, uimm21, uimm21_ext>;

//===----------------------------------------------------------------------===//
// ALU operations
//===----------------------------------------------------------------------===//

/// FrameIndex calculations
def : Pat<(i64 AddrFI:$Rs), (ADDI (i64 AddrFI:$Rs), 0)>;
def : Pat<(add (i64 AddrFI:$Rs), simm21:$imm), (ADDI (i64 AddrFI:$Rs), simm21:$imm)>;

/// Fused
def pr_addadd   : PatFrag<(ops node:$src1, node:$src2, node:$src3), (add (add node:$src1, node:$src2), node:$src3)>;
def pr_addsub   : PatFrag<(ops node:$src1, node:$src2, node:$src3), (sub (add node:$src1, node:$src2), node:$src3)>;
def pr_subsub   : PatFrag<(ops node:$src1, node:$src2, node:$src3), (sub node:$src1, (add node:$src2, node:$src3))>;
def pr_slsrl    : PatFrag<(ops node:$src1, node:$src2, node:$src3), (srl (shl node:$src1, node:$src2), node:$src3)>;
def pr_slsra    : PatFrag<(ops node:$src1, node:$src2, node:$src3), (sra (shl node:$src1, node:$src2), node:$src3)>;
def pr_muladd   : PatFrag<(ops node:$src1, node:$src2, node:$src3), (add (mul node:$src1, node:$src2), node:$src3)>;
def pr_mulsub   : PatFrag<(ops node:$src1, node:$src2, node:$src3), (sub (mul node:$src1, node:$src2), node:$src3)>;
def pr_mulsubf  : PatFrag<(ops node:$src1, node:$src2, node:$src3), (sub node:$src3, (mul node:$src1, node:$src2))>;

defm ADDADD  : FUSED_R4<fused_opx_addadd,  "addadd",   pr_addadd,  i64>;
defm ADDSUB  : FUSED_R4<fused_opx_addsub,  "addsub",   pr_addsub,  i64>;
defm SUBSUB  : FUSED_R4<fused_opx_subsub,  "subsub",   pr_subsub,  i64>;
defm SLSRL   : FUSED_R4<fused_opx_slsrl,   "slsrl",    pr_slsrl,   i64>;
defm SLSRA   : FUSED_R4<fused_opx_slsra,   "slsra",    pr_slsra,   i64>;
defm SLSRLW  : FUSED_R4<fused_opx_slsrlw,  "slsrlw",   pr_slsrl,   i32>;
defm SLSRAW  : FUSED_R4<fused_opx_slsraw,  "slsraw",   pr_slsra,   i32>;
defm MULADD  : FUSED_R4<fused_opx_muladd,  "muladd",   pr_muladd,  i64>;
defm MULSUB  : FUSED_R4<fused_opx_mulsub,  "mulsub",   pr_mulsub,  i64>;
defm MULSUBF : FUSED_R4<fused_opx_mulsubf, "mulsubf",  pr_mulsubf, i64>;

//===----------------------------------------------------------------------===//
// double shift (extract bitfield)
//===----------------------------------------------------------------------===//
defm SLSRLI : FUSED_R4rrii<fused_opx_slsrli, "slsrli", pr_slsrl, i64>;
defm SLSRAI : FUSED_R4rrii<fused_opx_slsrai, "slsrai", pr_slsra, i64>;

// (x >> offset) & mask<nbits> => (x << (64 - offset - nbits)) >> (64 - nbits)
// both srl/sra is identical because zero/sign extension will be masked

foreach NBITS = {1 ... 63} in {
    defvar MASK = !sub(!shl(1, NBITS), 1); // NBITS ones
    foreach OFFSET = {1 ... 63} in {
        defvar COMBINED = !add(NBITS, OFFSET);
        if !lt(COMBINED, 64) then {
            defvar LEFT_SHIFT  = !sub(64, COMBINED);
            defvar RIGHT_SHIFT = !add(LEFT_SHIFT, OFFSET);
            def : Pat<(and (srl i64:$rb, (i32 OFFSET)), MASK), (SLSRLI GR:$rb, LEFT_SHIFT, RIGHT_SHIFT)>;
            def : Pat<(and (sra i64:$rb, (i32 OFFSET)), MASK), (SLSRLI GR:$rb, LEFT_SHIFT, RIGHT_SHIFT)>;
        }
    }
}
foreach NBITS = {1 ... 31} in {
    defvar MASK = !sub(!shl(1, NBITS), 1); // NBITS ones
    foreach OFFSET = {1 ... 31} in {
        defvar COMBINED = !add(NBITS, OFFSET);
        if !lt(COMBINED, 32) then {
            defvar LEFT_SHIFT  = !sub(64, COMBINED);
            defvar RIGHT_SHIFT = !add(LEFT_SHIFT, OFFSET);
            def : Pat<(and (srl i32:$rb, (i32 OFFSET)), MASK), (SLSRLI GR:$rb, LEFT_SHIFT, RIGHT_SHIFT)>;
            def : Pat<(and (sra i32:$rb, (i32 OFFSET)), MASK), (SLSRLI GR:$rb, LEFT_SHIFT, RIGHT_SHIFT)>;
        }
    }
}

//===----------------------------------------------------------------------===//
/// Compare instructions
//===----------------------------------------------------------------------===//
defm CMPWEQ  : MISC_R3<misc_opx_cmpweq,  "cmpweq",  seteq,  i1, i32>;
defm CMPWNE  : MISC_R3<misc_opx_cmpwne,  "cmpwne",  setne,  i1, i32>;
defm CMPWLT  : MISC_R3<misc_opx_cmpwlt,  "cmpwlt",  setlt,  i1, i32>;
defm CMPWLE  : MISC_R3<misc_opx_cmpwle,  "cmpwle",  setle,  i1, i32>;
defm CMPWLTU : MISC_R3<misc_opx_cmpwltu, "cmpwltu", setult, i1, i32>;
defm CMPWLEU : MISC_R3<misc_opx_cmpwleu, "cmpwleu", setule, i1, i32>;

defm CMPDEQ  : MISC_R3<misc_opx_cmpdeq,  "cmpdeq",  seteq,  i1, i64>;
defm CMPDNE  : MISC_R3<misc_opx_cmpdne,  "cmpdne",  setne,  i1, i64>;
defm CMPDLT  : MISC_R3<misc_opx_cmpdlt,  "cmpdlt",  setlt,  i1, i64>;
defm CMPDLE  : MISC_R3<misc_opx_cmpdle,  "cmpdle",  setle,  i1, i64>;
defm CMPDLTU : MISC_R3<misc_opx_cmpdltu, "cmpdltu", setult, i1, i64>;
defm CMPDLEU : MISC_R3<misc_opx_cmpdleu, "cmpdleu", setule, i1, i64>;

defm CMPQEQ  : MISC_R3<misc_opx_cmpqeq,  "cmpqeq",  seteq,  i1, i128>;
defm CMPQNE  : MISC_R3<misc_opx_cmpqne,  "cmpqne",  setne,  i1, i128>;

multiclass CompareGreater<InstBase LT, InstBase LE, InstBase LTU, InstBase LEU, ValueType Ty>
{
  def : Pat<(i1 (setgt  Ty:$rc, Ty:$rb)), (LT  GR:$rb, GR:$rc)>;
  def : Pat<(i1 (setge  Ty:$rc, Ty:$rb)), (LE  GR:$rb, GR:$rc)>;
  def : Pat<(i1 (setugt Ty:$rc, Ty:$rb)), (LTU GR:$rb, GR:$rc)>;
  def : Pat<(i1 (setuge Ty:$rc, Ty:$rb)), (LEU GR:$rb, GR:$rc)>;
}
defm : CompareGreater<CMPWLT, CMPWLE, CMPWLTU, CMPWLEU, i32>;
defm : CompareGreater<CMPDLT, CMPDLE, CMPDLTU, CMPDLEU, i64>;

defm CMPWEQI  : PRIM_R2_IMM<opcode_cmpweqi,  "cmpweqi",  seteq,  i1, i32, simm21i32, simm21i32_ext>;
defm CMPWNEI  : PRIM_R2_IMM<opcode_cmpwnei,  "cmpwnei",  setne,  i1, i32, simm21i32, simm21i32_ext>;
defm CMPWLTI  : PRIM_R2_IMM<opcode_cmpwlti,  "cmpwlti",  setlt,  i1, i32, simm21i32, simm21i32_ext>;
defm CMPWGTI  : PRIM_R2_IMM<opcode_cmpwgti,  "cmpwgti",  setgt,  i1, i32, simm21i32, simm21i32_ext>;
defm CMPWLTUI : PRIM_R2_IMM<opcode_cmpwltui, "cmpwltui", setult, i1, i32, uimm21i32, uimm21i32_ext>;
defm CMPWGTUI : PRIM_R2_IMM<opcode_cmpwgtui, "cmpwgtui", setugt, i1, i32, uimm21i32, uimm21i32_ext>;

defm CMPDEQI  : PRIM_R2_IMM<opcode_cmpdeqi,  "cmpdeqi",  seteq,  i1, i64, simm21, simm21_ext>;
defm CMPDNEI  : PRIM_R2_IMM<opcode_cmpdnei,  "cmpdnei",  setne,  i1, i64, simm21, simm21_ext>;
defm CMPDLTI  : PRIM_R2_IMM<opcode_cmpdlti,  "cmpdlti",  setlt,  i1, i64, simm21, simm21_ext>;
defm CMPDGTI  : PRIM_R2_IMM<opcode_cmpdgti,  "cmpdgti",  setgt,  i1, i64, simm21, simm21_ext>;
defm CMPDLTUI : PRIM_R2_IMM<opcode_cmpdltui, "cmpdltui", setult, i1, i64, uimm21, uimm21_ext>;
defm CMPDGTUI : PRIM_R2_IMM<opcode_cmpdgtui, "cmpdgtui", setugt, i1, i64, uimm21, uimm21_ext>;

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
// conditional moves: Ra = (Rb op 0) ? Rc : Rd
//===----------------------------------------------------------------------===//
def CMOVLSB : FUSED_Rabcd<fused_opx_cmovlsb, (outs GR:$ra), (ins GR:$rb, GR:$rc, GR:$rd), "cmovlsb\t$ra, $rb, $rc, $rd", []>;
def CMOVWEQ : FUSED_Rabcd<fused_opx_cmovweq, (outs GR:$ra), (ins GR:$rb, GR:$rc, GR:$rd), "cmovweq\t$ra, $rb, $rc, $rd", []>;
def CMOVWLT : FUSED_Rabcd<fused_opx_cmovwlt, (outs GR:$ra), (ins GR:$rb, GR:$rc, GR:$rd), "cmovwlt\t$ra, $rb, $rc, $rd", []>;
def CMOVWLE : FUSED_Rabcd<fused_opx_cmovwle, (outs GR:$ra), (ins GR:$rb, GR:$rc, GR:$rd), "cmovwle\t$ra, $rb, $rc, $rd", []>;
def CMOVDEQ : FUSED_Rabcd<fused_opx_cmovdeq, (outs GR:$ra), (ins GR:$rb, GR:$rc, GR:$rd), "cmovdeq\t$ra, $rb, $rc, $rd", []>;
def CMOVDLT : FUSED_Rabcd<fused_opx_cmovdlt, (outs GR:$ra), (ins GR:$rb, GR:$rc, GR:$rd), "cmovdlt\t$ra, $rb, $rc, $rd", []>;
def CMOVDLE : FUSED_Rabcd<fused_opx_cmovdle, (outs GR:$ra), (ins GR:$rb, GR:$rc, GR:$rd), "cmovdle\t$ra, $rb, $rc, $rd", []>;

multiclass CondMoveBitwiseAnd<InstBase Inst, ValueType Ty, ValueType Tc>
{
  def : Pat<(Ty (select (i1 (seteq (and Tc:$rb, (Tc 1)), (Tc 1))), Ty:$rd, Ty:$rc)), (Inst GR:$rb, GR:$rc, GR:$rd)>;
  def : Pat<(Ty (select (i1 (setne (and Tc:$rb, (Tc 1)), (Tc 0))), Ty:$rd, Ty:$rc)), (Inst GR:$rb, GR:$rc, GR:$rd)>;
  // swapped
  def : Pat<(Ty (select (i1 (seteq (and Tc:$rb, (Tc 1)), (Tc 0))), Ty:$rc, Ty:$rd)), (Inst GR:$rb, GR:$rc, GR:$rd)>;
  def : Pat<(Ty (select (i1 (setne (and Tc:$rb, (Tc 1)), (Tc 1))), Ty:$rc, Ty:$rd)), (Inst GR:$rb, GR:$rc, GR:$rd)>;
}

// conditional move: select: Ra = Rb ? Rc : Rd
multiclass SelectPat<InstBase Inst, ValueType Ty>
{
  // is true
  def : Pat<(Ty (select i1:$rb, Ty:$rc, Ty:$rd)), (Inst GR:$rb, GR:$rc, GR:$rd)>;
  // equal true
  def : Pat<(Ty (select (i1 (seteq i1:$rb, (i1 -1))), Ty:$rc, Ty:$rd)), (Inst GR:$rb, GR:$rc, GR:$rd)>;
  // equal false (swapped args)
  def : Pat<(Ty (select (i1 (seteq i1:$rb, (i1 0))), Ty:$rd, Ty:$rc)), (Inst GR:$rb, GR:$rc, GR:$rd)>;
  //  (a & 1) ? b : c
  // defm : CondMoveBitwiseAnd<Inst, Ty, i1>;
  defm : CondMoveBitwiseAnd<Inst, Ty, i32>;
  defm : CondMoveBitwiseAnd<Inst, Ty, i64>;
  defm : CondMoveBitwiseAnd<Inst, Ty, i128>;
}

multiclass CondMovePat<InstBase Inst, PatFrag OpNode, int value, ValueType Ty, ValueType Tc>
{
  def : Pat<(Ty (select (i1 (OpNode Tc:$rb, (Tc value))), Ty:$rc, Ty:$rd)), (Inst GR:$rb, GR:$rc, GR:$rd)>;
}

multiclass CondMoveSwappedPat<InstBase Inst, PatFrag OpNode, int value, ValueType Ty, ValueType Tc>
{
  def : Pat<(Ty (select (i1 (OpNode Tc:$rb, (Tc value))), Ty:$rd, Ty:$rc)), (Inst GR:$rb, GR:$rc, GR:$rd)>;
}

multiclass ConditionalMoves<ValueType Ty>
{
  defm : SelectPat<CMOVLSB, Ty>;

  // direct usage
  defm : CondMovePat<CMOVWEQ, seteq, 0, Ty, i32>;
  defm : CondMovePat<CMOVWLT, setlt, 0, Ty, i32>;
  defm : CondMovePat<CMOVWLE, setle, 0, Ty, i32>;
  defm : CondMovePat<CMOVDEQ, seteq, 0, Ty, i64>;
  defm : CondMovePat<CMOVDLT, setlt, 0, Ty, i64>;
  defm : CondMovePat<CMOVDLE, setle, 0, Ty, i64>;

  // (x != value) => inverted(x == value)
  defm : CondMoveSwappedPat<CMOVWEQ, setne, 0, Ty, i32>;
  defm : CondMoveSwappedPat<CMOVWLT, setge, 0, Ty, i32>;
  defm : CondMoveSwappedPat<CMOVWLE, setgt, 0, Ty, i32>;
  defm : CondMoveSwappedPat<CMOVDEQ, setne, 0, Ty, i64>;
  defm : CondMoveSwappedPat<CMOVDLT, setge, 0, Ty, i64>;
  defm : CondMoveSwappedPat<CMOVDLE, setgt, 0, Ty, i64>;

  // (x < 1) => (x <= 0)
  defm : CondMovePat<CMOVWLE, setlt, 1, Ty, i32>;
  defm : CondMovePat<CMOVDLE, setlt, 1, Ty, i64>;

  // (x > -1) => (x >= 0) => inverted(x < 0)
  defm : CondMoveSwappedPat<CMOVWLT, setgt, -1, Ty, i32>;
  defm : CondMoveSwappedPat<CMOVDLT, setgt, -1, Ty, i64>;
}

defm : ConditionalMoves<i1>;
defm : ConditionalMoves<i32>;
defm : ConditionalMoves<i64>;
defm : ConditionalMoves<i128>;
defm : ConditionalMoves<f16>;
defm : ConditionalMoves<f32>;
defm : ConditionalMoves<f64>;
defm : ConditionalMoves<f128>;
defm : ConditionalMoves<v16i8>;
defm : ConditionalMoves<v8i16>;
defm : ConditionalMoves<v4i32>;
defm : ConditionalMoves<v2i64>;
defm : ConditionalMoves<v8f16>;
defm : ConditionalMoves<v4f32>;
defm : ConditionalMoves<v2f64>;

//===----------------------------------------------------------------------===//
// ADJCALLSTACKUP/ADJCALLSTACKDOWN pseudos
//===----------------------------------------------------------------------===//

//  These are target-independent nodes, but have target-specific formats.
def SDT_SPCallSeqStart : SDCallSeqStart<[ SDTCisVT<0, i32>, SDTCisVT<1, i32> ]>;
def SDT_SPCallSeqEnd : SDCallSeqEnd<[ SDTCisVT<0, i32>, SDTCisVT<1, i64> ]>;

def callseq_start : SDNode<"ISD::CALLSEQ_START", SDT_SPCallSeqStart,
                     [SDNPHasChain, SDNPSideEffect, SDNPOutGlue]>;
def callseq_end : SDNode<"ISD::CALLSEQ_END",   SDT_SPCallSeqEnd,
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

//------------------------------------------------------------------------------
// Shift Instructions
//------------------------------------------------------------------------------
multiclass
MC_SHIFT_S32<string OpcStr, misc_opx opxReg, misc_opx opxImm,
    SDNode OpNode, ValueType VT,
    InstrItinClass itin = IIC_iu_instr>
{
  def NAME : MISC_Rabc<opxReg, (outs GR:$ra), (ins GR:$rb, GR:$rc),
                 !strconcat(OpcStr, "\t$ra, $rb, $rc"),
                 [(set VT:$ra, (OpNode VT:$rb, i32:$rc))],
                 itin>;

  def NAME # I : MISC_RabSc<opxImm, (outs GR:$ra), (ins GR:$rb, uimm5:$shcnt),
                 !strconcat(OpcStr, "i\t$ra, $rb, $shcnt"),
                 [(set VT:$ra, (OpNode VT:$rb, uimm5:$shcnt))],
                 itin>;
}

defm SLLW : MC_SHIFT_S32<"sllw", misc_opx_sllw, misc_opx_slliw, shl, i32>;
defm SRLW : MC_SHIFT_S32<"srlw", misc_opx_srlw, misc_opx_srliw, srl, i32>;
defm SRAW : MC_SHIFT_S32<"sraw", misc_opx_sraw, misc_opx_sraiw, sra, i32>;

multiclass
MC_SHIFT_128<string OpcStr, misc_opx opxImm,
    SDNode OpNode, ValueType VT,
    InstrItinClass itin = IIC_iu_instr>
{
  def NAME : MISC_RabSc<opxImm, (outs GR:$ra), (ins GR:$rb, uimm7:$shcnt),
                 !strconcat(OpcStr, "i\t$ra, $rb, $shcnt"),
                 [(set VT:$ra, (OpNode VT:$rb, uimm7:$shcnt))],
                 itin>;
}

defm SLLQI : MC_SHIFT_128<"sllq", misc_opx_sllqi, shl, i128>;
defm SRLQI : MC_SHIFT_128<"srlq", misc_opx_srlqi, srl, i128>;
defm SRAQI : MC_SHIFT_128<"sraq", misc_opx_sraqi, sra, i128>;

// signx rd -> sra rd, %g0, rd
def : InstAlias<"signx\t$ra", (SRAW GR:$ra, GR:$ra, gz), 0>;
// signx reg, rd -> sra reg, %g0, rd
def : InstAlias<"signx\t$ra, $rb", (SRAW GR:$ra, GR:$rb, gz), 0>;

multiclass
MC_SHIFT_S64<string OpcStr, misc_opx opxReg, misc_opx opxImm,
    SDNode OpNode, ValueType VT,
    InstrItinClass itin = IIC_iu_instr>
{
  def NAME : MISC_Rabc<opxReg, (outs GR:$ra), (ins GR:$rb, GR:$rc),
                 !strconcat(OpcStr, "\t$ra, $rb, $rc"),
                 [(set VT:$ra, (OpNode VT:$rb, i64:$rc))],
                 itin>;

  def NAME # I : MISC_RabSc<opxImm, (outs GR:$ra), (ins GR:$rb, uimm6:$shcnt),
                 !strconcat(OpcStr, "i\t$ra, $rb, $shcnt"),
                 [(set VT:$ra, (OpNode VT:$rb, uimm6:$shcnt))],
                 itin>;
}

defm SLLD : MC_SHIFT_S64<"sll", misc_opx_sll, misc_opx_slli, shl, i64>;
defm SRLD : MC_SHIFT_S64<"srl", misc_opx_srl, misc_opx_srli, srl, i64>;
defm SRAD : MC_SHIFT_S64<"sra", misc_opx_sra, misc_opx_srai, sra, i64>;

// shift amount may be also i32
def : Pat<(i64 (shl i64:$rb, i32:$rc)), (SLLD GR:$rb, GR:$rc)>;
def : Pat<(i64 (sra i64:$rb, i32:$rc)), (SRAD GR:$rb, GR:$rc)>;
def : Pat<(i64 (srl i64:$rb, i32:$rc)), (SRLD GR:$rb, GR:$rc)>;

// ALIGNED_UP(N, NBITS) = (N + (2^NBITS-1)) & (~(2^NBITS-1))
def pr_algnup : PatFrag<(ops node:$src1, node:$nbits),
  (and (add node:$src1, (sub (shl 1, node:$nbits), 1)), (sub 0, (shl 1, node:$nbits)))>;

def ALGNUP : FUSED_Rabcd<fused_opx_algnup, (outs GR:$ra), (ins GR:$rb, uimm6:$rc, uimm6:$rd),
         "algnup\t$ra, $rb, $rc, $rd",
         [(set i64:$ra, (pr_algnup (shl i64:$rb, uimm6:$rc), uimm6:$rd))], IIC_iu_instr>;

// it's ugly but works
foreach III = 0-63 in {
  defvar BIT = !shl(1,III);
  defvar MASK = !sub(BIT, 1);
  def : Pat<(and (add i64:$rb, MASK), !sub(0, BIT) ), (ALGNUP GR:$rb, 0, III)>;
  foreach KKK = 1-63 in {
    def : Pat<(and (add (shl i64:$rb, (i32 KKK)), MASK), !sub(0, BIT)), (ALGNUP GR:$rb, KKK, III)>;
  }
}

//===----------------------------------------------------------------------===//
// Divide
//===----------------------------------------------------------------------===//
def pr_sdiv : PatFrag<(ops node:$src1, node:$src2), (sdiv node:$src1, node:$src2)>;
def pr_udiv : PatFrag<(ops node:$src1, node:$src2), (udiv node:$src1, node:$src2)>;
def pr_srem : PatFrag<(ops node:$src1, node:$src2), (srem node:$src1, node:$src2)>;
def pr_urem : PatFrag<(ops node:$src1, node:$src2), (urem node:$src1, node:$src2)>;

// Division can trap.
let hasSideEffects = 1 in {
  defm DIVSW : MISC_R3<misc_opx_divw,  "divw",  pr_sdiv, i32, i32>;
  defm DIVUW : MISC_R3<misc_opx_divuw, "divuw", pr_udiv, i32, i32>;
  defm DIVSD : MISC_R3<misc_opx_div,   "div",   pr_sdiv, i64, i64>;
  defm DIVUD : MISC_R3<misc_opx_divu,  "divu",  pr_udiv, i64, i64>;

  defm MODSW : MISC_R3<misc_opx_modw,  "modw",  pr_srem, i32, i32>;
  defm MODUW : MISC_R3<misc_opx_moduw, "moduw", pr_urem, i32, i32>;
  defm MODSD : MISC_R3<misc_opx_mod,   "mod",   pr_srem, i64, i64>;
  defm MODUD : MISC_R3<misc_opx_modu,  "modu",  pr_urem, i64, i64>;

  defm DIVI  : PRIM_R2_IMM<opcode_divi,  "divi",  pr_sdiv, i64, i64, simm21, simm21_ext>;
  defm DIVUI : PRIM_R2_IMM<opcode_divui, "divui", pr_udiv, i64, i64, uimm21, uimm21_ext>;
  defm MODI  : PRIM_R2_IMM<opcode_modi,  "modi",  pr_srem, i64, i64, simm21, simm21_ext>;
  defm MODUI : PRIM_R2_IMM<opcode_modui, "modui", pr_urem, i64, i64, uimm21, uimm21_ext>;
}

//===----------------------------------------------------------------------===//
// bit-field shift/deposits
//===----------------------------------------------------------------------===//
def DEP  : PRIMARY_Rabcde<opcode_dep,  (outs GR:$ra), (ins GR:$rb, GR:$rc, uimm7:$rd, uimm7:$re), "dep\t$ra, $rb, $rc, $rd, $re", []>;
def RLMI : PRIMARY_Rabcde<opcode_rlmi, (outs GR:$ra), (ins GR:$rb, uimm7:$rc, uimm7:$rd, uimm7:$re), "rlmi\t$ra, $rb, $rc, $rd, $re", []>;

def DEPS : FUSED_Rabcd<fused_opx_deps, (outs GR:$ra), (ins GR:$rb, uimm7:$rc, uimm7:$rd), "deps\t$ra, $rb, $rc, $rd", []>;
def DEPC : FUSED_Rabcd<fused_opx_depc, (outs GR:$ra), (ins GR:$rb, uimm7:$rc, uimm7:$rd), "depc\t$ra, $rb, $rc, $rd", []>;
def DEPA : FUSED_Rabcd<fused_opx_depa, (outs GR:$ra), (ins GR:$rb, uimm7:$rc, uimm7:$rd), "depa\t$ra, $rb, $rc, $rd", []>;

//===----------------------------------------------------------------------===//
// funnel shifts
// fshl(X,Y,Z): (X << (Z % BW)) | (Y >> (BW - (Z % BW)))
// fshr(X,Y,Z): (X << (BW - (Z % BW))) | (Y >> (Z % BW))
//===----------------------------------------------------------------------===//

def SLPW  : FUSED_Rabcd<fused_opx_slpw,  (outs GR:$ra), (ins GR:$rb, GR:$rc,       GR:$rd), "slpw\t$ra, $rb, $rc, $rd", []>;
def SRPW  : FUSED_Rabcd<fused_opx_srpw,  (outs GR:$ra), (ins GR:$rb, GR:$rc,       GR:$rd), "srpw\t$ra, $rb, $rc, $rd", []>;
def SRPIW : FUSED_Rabcd<fused_opx_srpiw, (outs GR:$ra), (ins GR:$rb, GR:$rc, uimm7i64:$rd), "srpiw\t$ra, $rb, $rc, $rd", []>;
def SLP   : FUSED_Rabcd<fused_opx_slp,   (outs GR:$ra), (ins GR:$rb, GR:$rc,       GR:$rd), "slp\t$ra, $rb, $rc, $rd", []>;
def SRP   : FUSED_Rabcd<fused_opx_srp,   (outs GR:$ra), (ins GR:$rb, GR:$rc,       GR:$rd), "srp\t$ra, $rb, $rc, $rd", []>;
def SRPI  : FUSED_Rabcd<fused_opx_srpi,  (outs GR:$ra), (ins GR:$rb, GR:$rc, uimm7i64:$rd), "srpi\t$ra, $rb, $rc, $rd", []>;
def SLPQ  : FUSED_Rabcd<fused_opx_slpq,  (outs GR:$ra), (ins GR:$rb, GR:$rc,       GR:$rd), "slpq\t$ra, $rb, $rc, $rd", []>;
def SRPQ  : FUSED_Rabcd<fused_opx_srpq,  (outs GR:$ra), (ins GR:$rb, GR:$rc,       GR:$rd), "srpq\t$ra, $rb, $rc, $rd", []>;
def SRPIQ : FUSED_Rabcd<fused_opx_srpiq, (outs GR:$ra), (ins GR:$rb, GR:$rc, uimm7i64:$rd), "srpiq\t$ra, $rb, $rc, $rd", []>;

let isCodeGenOnly = 1 in {
  def SRPI32W : FUSED_Rabcd<fused_opx_srpiw, (outs GR:$ra), (ins GR:$rb, GR:$rc, uimm7:$rd), "srpiw\t$ra, $rb, $rc, $rd", []>;
  def SRPI32  : FUSED_Rabcd<fused_opx_srpi,  (outs GR:$ra), (ins GR:$rb, GR:$rc, uimm7:$rd), "srpi\t$ra, $rb, $rc, $rd", []>;
  def SRPI32Q : FUSED_Rabcd<fused_opx_srpiq, (outs GR:$ra), (ins GR:$rb, GR:$rc, uimm7:$rd), "srpiq\t$ra, $rb, $rc, $rd", []>;
}

multiclass OP_FUNNEL_SHIFT<InstBase SL, InstBase SR, InstBase SRI, ValueType Ty, ValueType Ts, Operand immOp, int mask>
{
  def : Pat<(fshl Ty:$rb, Ty:$rc, Ts:$rd), (SL GR:$rb, GR:$rc, GR:$rd)>;
  def : Pat<(fshr Ty:$rb, Ty:$rc, Ts:$rd), (SR GR:$rb, GR:$rc, GR:$rd)>;

  // Double "funnel" shift amount is implicitly masked.
  // (fshl/fshr x (and y, 63)) ==> (fshl/fshr x, y)
  def : Pat<(fshr Ty:$rb, Ty:$rc, (and Ts:$rd, mask)), (SR GR:$rb, GR:$rc, GR:$rd)>;
  def : Pat<(fshl Ty:$rb, Ty:$rc, (and Ts:$rd, mask)), (SL GR:$rb, GR:$rc, GR:$rd)>;

  def : Pat<(fshr Ty:$rb, Ty:$rc, immOp:$rd), (SRI GR:$rb, GR:$rc, immOp:$rd)>;
}

defm : OP_FUNNEL_SHIFT<SLPW, SRPW, SRPIW, i32, i64, uimm7i64, 31>;
defm : OP_FUNNEL_SHIFT<SLPW, SRPW, SRPI32W, i32, i32, uimm7, 31>;
defm : OP_FUNNEL_SHIFT<SLP, SRP, SRPI, i64, i64, uimm7i64, 63>;
defm : OP_FUNNEL_SHIFT<SLP, SRP, SRPI32, i64, i32, uimm7, 63>;
defm : OP_FUNNEL_SHIFT<SLPQ, SRPQ, SRPIQ, i128, i64, uimm7i64, 127>;
defm : OP_FUNNEL_SHIFT<SLPQ, SRPQ, SRPI32Q, i128, i32, uimm7, 127>;

// model left funnel shifts by immediate via right funnel shifts
multiclass OP_FUNNEL_SHIFT_IMM<InstBase SRI, ValueType Ty, ValueType Ts, int NBITS, int LEFT_SHIFT>
{
  def : Pat<(fshl Ty:$rb, Ty:$rc, (Ts LEFT_SHIFT)), (SRI GR:$rb, GR:$rc, NBITS)>;
  def : Pat<(or (srl Ty:$rb, (Ts NBITS)), (shl Ty:$rc, (Ts LEFT_SHIFT))), (SRI GR:$rb, GR:$rc, NBITS)>;
  def : Pat<(or (shl Ty:$rc, (Ts LEFT_SHIFT)), (srl Ty:$rb, (Ts NBITS))), (SRI GR:$rb, GR:$rc, NBITS)>;
  def : Pat<(rotr Ty:$rb, (Ts NBITS     )), (SRI GR:$rb, GR:$rb, NBITS)>;
  def : Pat<(rotl Ty:$rb, (Ts LEFT_SHIFT)), (SRI GR:$rb, GR:$rb, NBITS)>;
}

foreach NBITS = {1 ... 31} in {
  defvar LEFT_SHIFT  = !sub(32, NBITS);
  defm : OP_FUNNEL_SHIFT_IMM<SRPIW,   i32, i64, NBITS, LEFT_SHIFT>;
  defm : OP_FUNNEL_SHIFT_IMM<SRPI32W, i32, i32, NBITS, LEFT_SHIFT>;
}
foreach NBITS = {1 ... 63} in {
  defvar LEFT_SHIFT  = !sub(64, NBITS);
  defm : OP_FUNNEL_SHIFT_IMM<SRPI,   i64, i64, NBITS, LEFT_SHIFT>;
  defm : OP_FUNNEL_SHIFT_IMM<SRPI32, i64, i32, NBITS, LEFT_SHIFT>;
}
foreach NBITS = {1 ... 127} in {
  defvar LEFT_SHIFT  = !sub(128, NBITS);
  defm : OP_FUNNEL_SHIFT_IMM<SRPIQ,   i128, i64, NBITS, LEFT_SHIFT>;
  defm : OP_FUNNEL_SHIFT_IMM<SRPI32Q, i128, i32, NBITS, LEFT_SHIFT>;
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
  def JMPR : MISC_RabcScale<misc_opx_jmpr, (outs), (ins GR:$rb, GR:$rc, scale:$scale), "jmpr\t$rb, $rc, $scale", []>;
}

def : Pat<(brind (i64 (add i64:$rb, (shl i64:$rc, scale:$scale)))), (JMPR GR:$rb, GR:$rc, scale:$scale)>;
def : Pat<(brind (i64 (add i64:$rb,      i64:$rc               ))), (JMPR GR:$rb, GR:$rc, 0)>;
def : Pat<(brind           i64:$rb                               ), (JMPR GR:$rb, (i64 gz), 0)>;

//===----------------------------------------------------------------------===//
// Indirect jump table
//===----------------------------------------------------------------------===//
let isTerminator = 1, isBarrier = 1, isBranch = 1, isIndirectBranch = 1, ra = 0 in {
  def JMPT   : MISC_Rabc<misc_opx_jmpt,   (outs), (ins GR:$rb, GR:$rc), "jmpt\t$rb, $rc", []>;
  def JMPTWS : MISC_Rabc<misc_opx_jmptws, (outs), (ins GR:$rb, GR:$rc), "jmptws\t$rb, $rc", []>;
  def JMPTWZ : MISC_Rabc<misc_opx_jmptwz, (outs), (ins GR:$rb, GR:$rc), "jmptwz\t$rb, $rc", []>;
}

def jmp_table_load_i64 : PatFrag<(ops node:$base, node:$index),
      (brind (i64 (add node:$base, (i64 (sextloadi32 (add node:$base, (shl node:$index, (i32 2))))))))>;
def : Pat<(jmp_table_load_i64 i64:$rb, i64:$rc), (JMPT GR:$rb, GR:$rc)>;

// FIXME: switches with i32 indices use zero extension before indexing: srlwi %r,%r,0
def jmp_table_load_u32 : PatFrag<(ops node:$base, node:$index),
      (brind (i64 (add node:$base, (i64 (sextloadi32 (add (shl (i64 (zext node:$index)), (i32 2)), node:$base))))))>;

//def : Pat<(jmp_table_load_i32 i64:$rb, i32:$rc), (JMPTWS GR:$rb, GR:$rc)>;
def : Pat<(jmp_table_load_u32 i64:$rb, i32:$rc), (JMPTWZ GR:$rb, GR:$rc)>;

//===----------------------------------------------------------------------===//
// Indirect jump/tail_call after load instruction
//===----------------------------------------------------------------------===//
let isTerminator = 1, isBarrier = 1, isBranch = 1, isIndirectBranch = 1, ra = 0 in {
  def JMPMI : MISC_RabcScale<misc_opx_jmpmi,
        (outs), (ins GR:$rb, GR:$rc, scale:$scale),
        "jmpmi\t$rb, $rc, $scale", []>;
}

def jmp_load_indexed_scaled_s64 : PatFrag<
      (ops node:$base, node:$index, node:$scale),
      (brind (iPTR (add node:$base,
            (i64 (sextloadi32 (add node:$base,
            (shl (i64 (sext node:$index)), node:$scale)))))))>;

def : Pat<(jmp_load_indexed_scaled_s64 iPTR:$rb, i32:$rc, scale:$scale),
          (JMPMI GR:$rb, GR:$rc, scale:$scale)>;


def jmp_load_indexed_s64 : PatFrag<
      (ops node:$base, node:$index),
      (brind (iPTR (add node:$base,
            (i64 (sextloadi32 (add node:$base,
            (i64 (sext node:$index))))))))>;

def : Pat<(jmp_load_indexed_s64 iPTR:$rb, i32:$rc),
          (JMPMI GR:$rb, GR:$rc, 0)>;

def jmp_load_s64 : PatFrag<
      (ops node:$base),
      (brind (iPTR (add node:$base,
            (i64 (sextloadi32 node:$base)))))>;

def : Pat<(jmp_load_s64 iPTR:$rb),
          (JMPMI GR:$rb, (i64 gz), 0)>;

//===----------------------------------------------------------------------===//
// TailCall patterns
//===----------------------------------------------------------------------===//
def SDT_SPTailCall : SDTypeProfile<0, -1, [SDTCisVT<0, i64>]>;
def tailcall : SDNode<"PostriscISD::TAIL_CALL", SDT_SPTailCall,
                      [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue,
                       SDNPVariadic]>;

def : Pat<(tailcall   tglobaladdr:$addr), (JMP_TAIL tglobaladdr:$addr)>;
def : Pat<(tailcall  texternalsym:$addr), (JMP_TAIL texternalsym:$addr)>;

def : Pat<(tailcall (i64 (add i64:$rb, (shl i64:$rc, scale:$scale)))),
          (JMPR GR:$rb, GR:$rc, scale:$scale)>;
def : Pat<(tailcall (i64 (add i64:$rb, i64:$rc))),
          (JMPR GR:$rb, GR:$rc, 0)>;
def : Pat<(tailcall i64:$rb),
          (JMPR GR:$rb, (i64 gz), 0)>;

//===----------------------------------------------------------------------===//
// Call Instructions
//===----------------------------------------------------------------------===//
let isCall = 1 in
{
  // call ip+offset
  def CALL       : PRIMARY_RaI28<opcode_callr,
                   (outs GR:$ra), (ins calltarget:$imm, variable_ops),
                   "callr\t$ra, $imm", [], IIC_jmp_or_call>;

  def CALL_EXT   : PRIMARY_RaI28_ext<opcode_callr,
                   (outs GR:$ra), (ins calltarget:$imm, variable_ops),
                   "callr.l\t$ra, $imm", [], IIC_jmp_or_call>;

  // call base+index
  def CALLRI : MISC_Rabc<misc_opx_callri,
                   (outs GR:$ra), (ins GR:$rb, GR:$rc, variable_ops),
                   "callri\t$ra, $rb, $rc", [], IIC_jmp_or_call>;


  // call mem<u64>[ip+offset]
  def CALLPLT     : PRIMARY_RaI28<opcode_callplt,
                   (outs GR:$ra), (ins simm28:$imm, variable_ops),
                   "callplt\t$ra, $imm", [], IIC_jmp_or_call>;

  def CALLPLT_EXT : PRIMARY_RaI28_ext<opcode_callplt,
                   (outs GR:$ra), (ins simm28_ext:$imm, variable_ops),
                   "callplt.l\t$ra, $imm", [], IIC_jmp_or_call>;

  // call mem<u64>[base+offset]
  def CALLMI     : MISC_RabI10<misc_opx_callmi,
                   (outs GR:$ra), (ins GR:$rb, stride_imm:$imm, variable_ops),
                   "callmi\t$ra, $rb, $imm", [], IIC_jmp_or_call>;

  // call base + mem<i32>[base + offset]
  def CALLRVT    : MISC_RabI10<misc_opx_callrvt,
                   (outs GR:$ra), (ins GR:$rb, stride_imm:$imm, variable_ops),
                   "callrvt\t$ra, $rb, $imm", [], IIC_jmp_or_call>;
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
def : Pat<(call (add iPTR:$rb, i64:$rc)), (CALLRI GR:$rb, GR:$rc)>;
def : Pat<(call iPTR:$rb), (CALLRI GR:$rb, (i64 gz))>;

// call mem8[ip+offset]
// global/external function pointers should be properly wrapped to corresponding PCREL wrapper
def : Pat<(call_load (pcrel_data_wrapper       tglobaladdr:$addr)), (CALLPLT       tglobaladdr:$addr)>;
def : Pat<(call_load (pcrel_data_wrapper      texternalsym:$addr)), (CALLPLT      texternalsym:$addr)>;
def : Pat<(call_load (pcrel_data_wrapper_ext   tglobaladdr:$addr)), (CALLPLT_EXT   tglobaladdr:$addr)>;
def : Pat<(call_load (pcrel_data_wrapper_ext  texternalsym:$addr)), (CALLPLT_EXT  texternalsym:$addr)>;

// call dword_mem[base+offset]
def : Pat<(call_load i64:$rb), (CALLMI GR:$rb, 0)>;
def : Pat<(call_load (add i64:$rb, simm11:$imm)), (CALLMI GR:$rb, simm11:$imm)>;

// call base + sword_mem[base + offset]
def call_rvt      : PatFrag<(ops node:$base, node:$imm), (call (add node:$base, (i64 (sextloadi32 (add node:$base, node:$imm)))))>;
def call_rvt_zero : PatFrag<(ops node:$base           ), (call (add node:$base, (i64 (sextloadi32      node:$base            ))))>;

// (brind (i64 (add node:$base, (i64 (sextloadi32 (add (shl (i64 (zext node:$index)), (i32 2)), node:$base))))))>;

def : Pat<(call_rvt      i64:$rb, simm11:$imm), (CALLRVT GR:$rb, simm11:$imm)>;
def : Pat<(call_rvt_zero i64:$rb             ), (CALLRVT GR:$rb, 0)>;

//===----------------------------------------------------------------------===//
// TLS Call patterns (call of `__tls_get_addr`)
//===----------------------------------------------------------------------===//
def tlscall : SDNode<"PostriscISD::TLS_CALL", SDT_SPCall,
                 [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue, SDNPVariadic]>;
def tlscall_ext : SDNode<"PostriscISD::TLS_CALL_EXT", SDT_SPCall,
                [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue, SDNPVariadic]>;

def : Pat<(tlscall texternalsym:$addr, tglobaltlsaddr:$sym),
          (CALL texternalsym:$addr, tglobaltlsaddr:$sym)>;
def : Pat<(tlscall_ext texternalsym:$addr, tglobaltlsaddr:$sym),
          (CALL_EXT texternalsym:$addr, tglobaltlsaddr:$sym)>;

//===----------------------------------------------------------------------===//
// returns: lowered to `RET_GLUE`
//===----------------------------------------------------------------------===//
def SDT_SPRet : SDTypeProfile<0, 1, [SDTCisVT<0, i64>]>;
def retglue : SDNode<"PostriscISD::RET_GLUE", SDT_SPRet,
                     [SDNPHasChain, SDNPOptInGlue, SDNPVariadic]>;

let isReturn = 1, isTerminator = 1, isBarrier = 1 in
{
  let Defs = [sp], Uses = [sp], rb = 0 in {
    def RETF     : RAOPX_RbI21    <raopx_opx_retf, (outs), (ins uimm21    :$imm), "retf\t$imm",   [(retglue uimm21    :$imm)], IIC_jmp_or_call>;
    def RETF_EXT : RAOPX_RbI21_ext<raopx_opx_retf, (outs), (ins uimm21_ext:$imm), "retf.l\t$imm", [(retglue uimm21_ext:$imm)], IIC_jmp_or_call>;
  }
  def RET : MISC_NoArgs<misc_opx_ret, (outs), (ins), "ret", []>;
}

// at least one alias - to not hurt about code changes
def : MnemonicAlias<"return", "ret">;

def MOV : MISC_Rab<misc_opx_mov, (outs GR:$ra), (ins GR:$rb), "mov\t$ra, $rb", []>;

def : Pat<(i64 (int_postrisc_stack_pointer)), (i64 sp)>;
def : Pat<(i64 (int_thread_pointer)), (i64 tp)>;

def MOV2 : FUSED_Rabcd<fused_opx_mov2,
        (outs GR:$ra, GR:$rb), (ins GR:$rc, GR:$rd),
        "mov2\t$ra, $rb, $rc, $rd", []>;

//===----------------------------------------------------------------------===//
// population, trailing/leading zeros bit count
//===----------------------------------------------------------------------===//
def POPC : MISC_RabSc<misc_opx_cntpop, (outs GR:$ra), (ins GR:$rb, uimm6:$shcnt), "popc\t$ra, $rb, $shcnt", []>;
def : Pat<(i32 (ctpop i32:$src)), (POPC $src, 31)>;
def : Pat<(i64 (ctpop i64:$src)), (POPC $src, 63)>;

def CTTZ : MISC_RabSc<misc_opx_cnttz, (outs GR:$ra), (ins GR:$rb, uimm6:$shcnt), "cttz\t$ra, $rb, $shcnt", []>;
def : Pat<(i32 (cttz i32:$src)), (CTTZ $src, 31)>;
def : Pat<(i64 (cttz i64:$src)), (CTTZ $src, 63)>;

def CTLZ : MISC_RabSc<misc_opx_cntlz, (outs GR:$ra), (ins GR:$rb, uimm6:$shcnt), "ctlz\t$ra, $rb, $shcnt", []>;
def : Pat<(i32 (ctlz i32:$src)), (CTLZ $src, 31)>;
def : Pat<(i64 (ctlz i64:$src)), (CTLZ $src, 63)>;

//===----------------------------------------------------------------------===//
// PERM - bit permutation
//===----------------------------------------------------------------------===//
def PERM : MISC_RabSc<misc_opx_permb,
            (outs GR:$ra), (ins GR:$rb, uimm6:$shcnt),
            "permb\t$ra, $rb, $shcnt",
            [],
            IIC_iu_instr>;

def : Pat<(i32 (bitreverse i32:$src)), (PERM $src, 31)>;
def : Pat<(i64 (bitreverse i64:$src)), (PERM $src, 63)>;

//===----------------------------------------------------------------------===//
// Load immediate
//===----------------------------------------------------------------------===//
let isMoveImm = 1 in {
  def LDI     : PRIMARY_RaI28    <opcode_ldi, (outs GR:$ra), (ins simm28    :$imm), "ldi\t$ra, $imm",   [(set i64:$ra, simm28    :$imm)]>;
  def LDI_EXT : PRIMARY_RaI28_ext<opcode_ldi, (outs GR:$ra), (ins simm28_ext:$imm), "ldi.l\t$ra, $imm", [(set i64:$ra, simm28_ext:$imm)]>;
}

// convert possible i32 to i64
def cvt64 : SDNodeXForm<imm, [{
  int64_t enc = N->getSExtValue();
  enc = (enc << 32) >> 32;
  return CurDAG->getTargetConstant(enc, SDLoc(N), MVT::i64);
}]>;

def cvt128 : SDNodeXForm<imm, [{
  int64_t enc = N->getSExtValue();
  return CurDAG->getTargetConstant(enc, SDLoc(N), MVT::i128);
}]>;

// zero materialization
def : Pat<(i1 0), (COPY (i1 gz))>;
def : Pat<(i32 0), (COPY (i32 gz))>;
def : Pat<(i64 0), (COPY (i64 gz))>;
def : Pat<(i128 0), (COPY (i128 gz))>;

// i32&i64 28-bit signed short immediates may be materialized by ldi
def simm28x : PatLeaf<(imm), [{ return isInt<28>(N->getSExtValue()); }]>;
def : Pat<(i32 simm28x:$val), (LDI (cvt64 $val))>;
def : Pat<(i64 simm28x:$val), (LDI $val)>;
def : Pat<(i128 simm28x:$val), (LDI (cvt128 $val))>;

// i32 big signed immediates may be materialized by ldi.l
def simm32x : PatLeaf<(imm), [{ return isInt<32>(N->getSExtValue()); }]>;
def : Pat<(i32 simm32x:$val), (LDI_EXT (cvt64 $val))>;

// i32 big unsigned immediates may be also materialized by ldi.l
def uimm32x : PatLeaf<(imm), [{ return isInt<32>(N->getSExtValue()); }]>;
def : Pat<(i32 uimm32x:$val), (LDI_EXT (cvt64 $val))>;

// i64 big immediates may be materialized by ldi.l
def simm64x : PatLeaf<(imm), [{ return isInt<64>(N->getSExtValue()); }]>;
def : Pat<(i64 simm64x:$val), (LDI_EXT $val)>;
def : Pat<(i128 simm64x:$val), (LDI_EXT (cvt128 $val))>;

//===----------------------------------------------------------------------===//
// Non-Instruction Patterns
//===----------------------------------------------------------------------===//

def LDAR     : PRIMARY_RaI28    <opcode_ldar, (outs GR:$ra), (ins simm28:$imm), "ldar\t$ra, $imm", []>;
def LDAR_EXT : PRIMARY_RaI28_ext<opcode_ldar, (outs GR:$ra), (ins simm28_ext:$imm), "ldar.l\t$ra, $imm", []>;

// Global addresses, constant pool entries
def LDAFR     : PRIMARY_RaI28    <opcode_ldafr, (outs GR:$ra), (ins uimm28:$imm), "ldafr\t$ra, $imm", []>;
def LDAFR_EXT : PRIMARY_RaI28_ext<opcode_ldafr, (outs GR:$ra), (ins uimm28_ext:$imm), "ldafr.l\t$ra, $imm", []>;

// global/external address should be properly wrapped to corresponding PCREL wrapper
def : Pat<(i64 (pcrel_code_wrapper        tglobaladdr:$addr)), (LDAR        tglobaladdr:$addr)>;
def : Pat<(i64 (pcrel_code_wrapper         tconstpool:$addr)), (LDAR         tconstpool:$addr)>;
def : Pat<(i64 (pcrel_code_wrapper       texternalsym:$addr)), (LDAR       texternalsym:$addr)>;
def : Pat<(i64 (pcrel_code_wrapper     tglobaltlsaddr:$addr)), (LDAR     tglobaltlsaddr:$addr)>;

def : Pat<(i64 (pcrel_code_wrapper_ext    tglobaladdr:$addr)), (LDAR_EXT    tglobaladdr:$addr)>;
def : Pat<(i64 (pcrel_code_wrapper_ext     tconstpool:$addr)), (LDAR_EXT     tconstpool:$addr)>;
def : Pat<(i64 (pcrel_code_wrapper_ext   texternalsym:$addr)), (LDAR_EXT   texternalsym:$addr)>;
def : Pat<(i64 (pcrel_code_wrapper_ext tglobaltlsaddr:$addr)), (LDAR_EXT tglobaltlsaddr:$addr)>;

def : Pat<(i64 (pcrel_data_wrapper        tglobaladdr:$addr)), (LDAFR        tglobaladdr:$addr)>;
def : Pat<(i64 (pcrel_data_wrapper         tconstpool:$addr)), (LDAFR         tconstpool:$addr)>;
def : Pat<(i64 (pcrel_data_wrapper       texternalsym:$addr)), (LDAFR       texternalsym:$addr)>;
def : Pat<(i64 (pcrel_data_wrapper     tglobaltlsaddr:$addr)), (LDAFR     tglobaltlsaddr:$addr)>;
def : Pat<(i64 (pcrel_data_wrapper         tjumptable:$addr)), (LDAFR         tjumptable:$addr)>;

def : Pat<(i64 (pcrel_data_wrapper_ext    tglobaladdr:$addr)), (LDAFR_EXT    tglobaladdr:$addr)>;
def : Pat<(i64 (pcrel_data_wrapper_ext     tconstpool:$addr)), (LDAFR_EXT     tconstpool:$addr)>;
def : Pat<(i64 (pcrel_data_wrapper_ext   texternalsym:$addr)), (LDAFR_EXT   texternalsym:$addr)>;
def : Pat<(i64 (pcrel_data_wrapper_ext tglobaltlsaddr:$addr)), (LDAFR_EXT tglobaltlsaddr:$addr)>;
def : Pat<(i64 (pcrel_data_wrapper_ext     tjumptable:$addr)), (LDAFR_EXT     tjumptable:$addr)>;

def : Pat<(add i64:$r, tglobaltlsaddr:$addr), (ADDI $r, tglobaltlsaddr:$addr)>;

//===----------------------------------------------------------------------===//
// Compare reg-reg and branch
//===----------------------------------------------------------------------===//
multiclass CompareAndBranch<brr_opx opxCode, string OpcStr, PatFrag OpNode, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  let isBranch = 1, isTerminator = 1 in
  def NAME : BRR_RabBranch<opcode_brr, opxCode.value,
                 (outs), (ins GR:$ra, GR:$rb, brtarget:$offset),
                 !strconcat(OpcStr, "\t$ra, $rb, $offset"),
                 [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;

  let isBranch = 1, isTerminator = 1 in
  def NAME # _EXT : BRR_RabBranch_ext<opcode_brr, opxCode.value,
                 (outs), (ins GR:$ra, GR:$rb, brtarget_ext:$offset),
                 !strconcat(OpcStr, ".l\t$ra, $rb, $offset"),
                 [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;
}

defm BDEQ  : CompareAndBranch<brr_opx_bdeq,  "bdeq",   seteq,   i64>;
defm BDNE  : CompareAndBranch<brr_opx_bdne,  "bdne",   setne,   i64>;
defm BDLT  : CompareAndBranch<brr_opx_bdlt,  "bdlt",   setlt,   i64>;
defm BDLE  : CompareAndBranch<brr_opx_bdle,  "bdle",   setle,   i64>;
defm BDLTU : CompareAndBranch<brr_opx_bdltu, "bdltu",  setult,  i64>;
defm BDLEU : CompareAndBranch<brr_opx_bdleu, "bdleu",  setule,  i64>;

defm BWEQ  : CompareAndBranch<brr_opx_bweq,  "bweq",   seteq,   i32>;
defm BWNE  : CompareAndBranch<brr_opx_bwne,  "bwne",   setne,   i32>;
defm BWLT  : CompareAndBranch<brr_opx_bwlt,  "bwlt",   setlt,   i32>;
defm BWLE  : CompareAndBranch<brr_opx_bwle,  "bwle",   setle,   i32>;
defm BWLTU : CompareAndBranch<brr_opx_bwltu, "bwltu",  setult,  i32>;
defm BWLEU : CompareAndBranch<brr_opx_bwleu, "bwleu",  setule,  i32>;

//===----------------------------------------------------------------------===//
// Compare greater: use less
//===----------------------------------------------------------------------===//
def : Pat<(brcond (i1 (setgt  i64:$a, i64:$b)), bb:$dst), (BDLT  GR:$b, GR:$a, bb:$dst)>;
def : Pat<(brcond (i1 (setge  i64:$a, i64:$b)), bb:$dst), (BDLE  GR:$b, GR:$a, bb:$dst)>;
def : Pat<(brcond (i1 (setugt i64:$a, i64:$b)), bb:$dst), (BDLTU GR:$b, GR:$a, bb:$dst)>;
def : Pat<(brcond (i1 (setuge i64:$a, i64:$b)), bb:$dst), (BDLEU GR:$b, GR:$a, bb:$dst)>;

def : Pat<(brcond (i1 (setgt  i32:$a, i32:$b)), bb:$dst), (BWLT  GR:$b, GR:$a, bb:$dst)>;
def : Pat<(brcond (i1 (setge  i32:$a, i32:$b)), bb:$dst), (BWLE  GR:$b, GR:$a, bb:$dst)>;
def : Pat<(brcond (i1 (setugt i32:$a, i32:$b)), bb:$dst), (BWLTU GR:$b, GR:$a, bb:$dst)>;
def : Pat<(brcond (i1 (setuge i32:$a, i32:$b)), bb:$dst), (BWLEU GR:$b, GR:$a, bb:$dst)>;

//===----------------------------------------------------------------------===//
// Compare with zero and branch
//===----------------------------------------------------------------------===//
def : Pat<(brcond (i1 (seteq i64:$a, (i64 0))), bb:$dst), (BDEQ GR:$a, (i64 gz), bb:$dst)>;
def : Pat<(brcond (i1 (setne i64:$a, (i64 0))), bb:$dst), (BDNE GR:$a, (i64 gz), bb:$dst)>;
def : Pat<(brcond (i1 (setlt i64:$a, (i64 0))), bb:$dst), (BDLT GR:$a, (i64 gz), bb:$dst)>;
def : Pat<(brcond (i1 (setle i64:$a, (i64 0))), bb:$dst), (BDLE GR:$a, (i64 gz), bb:$dst)>;
def : Pat<(brcond (i1 (setgt i64:$a, (i64 0))), bb:$dst), (BDLT (i64 gz), GR:$a, bb:$dst)>;
def : Pat<(brcond (i1 (setge i64:$a, (i64 0))), bb:$dst), (BDLE (i64 gz), GR:$a, bb:$dst)>;

def : Pat<(brcond (i1 (seteq i32:$a, (i32 0))), bb:$dst), (BWEQ GR:$a, (i32 gz), bb:$dst)>;
def : Pat<(brcond (i1 (setne i32:$a, (i32 0))), bb:$dst), (BWNE GR:$a, (i32 gz), bb:$dst)>;
def : Pat<(brcond (i1 (setlt i32:$a, (i32 0))), bb:$dst), (BWLT GR:$a, (i32 gz), bb:$dst)>;
def : Pat<(brcond (i1 (setle i32:$a, (i32 0))), bb:$dst), (BWLE GR:$a, (i32 gz), bb:$dst)>;
def : Pat<(brcond (i1 (setgt i32:$a, (i32 0))), bb:$dst), (BWLT (i32 gz), GR:$a, bb:$dst)>;
def : Pat<(brcond (i1 (setge i32:$a, (i32 0))), bb:$dst), (BWLE (i32 gz), GR:$a, bb:$dst)>;

//===----------------------------------------------------------------------===//
// Compare reg-bit-shamt and branch
//===----------------------------------------------------------------------===//
def cmp_bitset   : PatFrag<(ops node:$x, node:$y), (setne (and (srl node:$x, node:$y), 1), 0)>;
def cmp_bitclear : PatFrag<(ops node:$x, node:$y), (seteq (and (srl node:$x, node:$y), 1), 0)>;
def cmp_all      : PatFrag<(ops node:$x, node:$y), (seteq (and node:$x, node:$y), node:$y)>;
def cmp_notall   : PatFrag<(ops node:$x, node:$y), (setne (and node:$x, node:$y), node:$y)>;
def cmp_none     : PatFrag<(ops node:$x, node:$y), (seteq (and node:$x, node:$y), 0)>;
def cmp_any      : PatFrag<(ops node:$x, node:$y), (setne (and node:$x, node:$y), 0)>;

//===----------------------------------------------------------------------===//
// Compare reg-bit and branch
//===----------------------------------------------------------------------===//
defm BBS : CompareAndBranch<brr_opx_bbs, "bbs", cmp_bitset,   i64>;
defm BBC : CompareAndBranch<brr_opx_bbc, "bbc", cmp_bitclear, i64>;

multiclass
CompareBitPat<InstBase Op, ValueType Ty, int direct_value, int invert_value>
{
  def : Pat<(brcond (i1 (seteq (and (srl Ty:$a, i64:$b), 1), direct_value)), bb:$dst), (Op GR:$a, GR:$b, bb:$dst)>;
  def : Pat<(brcond (i1 (seteq (and (sra Ty:$a, i64:$b), 1), direct_value)), bb:$dst), (Op GR:$a, GR:$b, bb:$dst)>;
  def : Pat<(brcond (i1 (seteq (and (srl Ty:$a, i32:$b), 1), direct_value)), bb:$dst), (Op GR:$a, GR:$b, bb:$dst)>;
  def : Pat<(brcond (i1 (seteq (and (sra Ty:$a, i32:$b), 1), direct_value)), bb:$dst), (Op GR:$a, GR:$b, bb:$dst)>;

  def : Pat<(brcond (i1 (setne (and (srl Ty:$a, i64:$b), 1), invert_value)), bb:$dst), (Op GR:$a, GR:$b, bb:$dst)>;
  def : Pat<(brcond (i1 (setne (and (sra Ty:$a, i64:$b), 1), invert_value)), bb:$dst), (Op GR:$a, GR:$b, bb:$dst)>;
  def : Pat<(brcond (i1 (setne (and (srl Ty:$a, i32:$b), 1), invert_value)), bb:$dst), (Op GR:$a, GR:$b, bb:$dst)>;
  def : Pat<(brcond (i1 (setne (and (sra Ty:$a, i32:$b), 1), invert_value)), bb:$dst), (Op GR:$a, GR:$b, bb:$dst)>;

  def : Pat<(brcond (i1 (seteq (i1 (trunc (srl Ty:$a, i64:$b))), (i1 direct_value))), bb:$dst), (Op GR:$a, GR:$b, bb:$dst)>;
  def : Pat<(brcond (i1 (seteq (i1 (trunc (sra Ty:$a, i64:$b))), (i1 direct_value))), bb:$dst), (Op GR:$a, GR:$b, bb:$dst)>;
  def : Pat<(brcond (i1 (seteq (i1 (trunc (srl Ty:$a, i32:$b))), (i1 direct_value))), bb:$dst), (Op GR:$a, GR:$b, bb:$dst)>;
  def : Pat<(brcond (i1 (seteq (i1 (trunc (sra Ty:$a, i32:$b))), (i1 direct_value))), bb:$dst), (Op GR:$a, GR:$b, bb:$dst)>;

  def : Pat<(brcond (i1 (setne (i1 (trunc (srl Ty:$a, i64:$b))), (i1 invert_value))), bb:$dst), (Op GR:$a, GR:$b, bb:$dst)>;
  def : Pat<(brcond (i1 (setne (i1 (trunc (sra Ty:$a, i64:$b))), (i1 invert_value))), bb:$dst), (Op GR:$a, GR:$b, bb:$dst)>;
  def : Pat<(brcond (i1 (setne (i1 (trunc (srl Ty:$a, i32:$b))), (i1 invert_value))), bb:$dst), (Op GR:$a, GR:$b, bb:$dst)>;
  def : Pat<(brcond (i1 (setne (i1 (trunc (sra Ty:$a, i32:$b))), (i1 invert_value))), bb:$dst), (Op GR:$a, GR:$b, bb:$dst)>;

  //def : Pat<(brcond (i1 (seteq (and Ty:$a, (i64 (shl 1, i32:$b))), 0)), bb:$dst), (Op GR:$a, GR:$b, bb:$dst)>;
  //def : Pat<(brcond (i1 (setne (and Ty:$a, (i64 (shl 1, i32:$b))), 0)), bb:$dst), (Op GR:$a, GR:$b, bb:$dst)>;
}

defm : CompareBitPat<BBS, i32, 1, 0>;
defm : CompareBitPat<BBS, i64, 1, 0>;
defm : CompareBitPat<BBC, i32, 0, 1>;
defm : CompareBitPat<BBC, i64, 0, 1>;

//===----------------------------------------------------------------------===//
// Compare reg-bit immediate and branch
//===----------------------------------------------------------------------===//
multiclass CompareBitAndBranch<brr_opx opxCode, string OpcStr, PatFrag OpNode, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  let isBranch = 1, isTerminator = 1 in
  def NAME: BRR_RabBranch<opcode_brr, opxCode.value, (outs),
                 (ins GR:$ra, uimm7:$rb, brtarget:$offset),
                 !strconcat(OpcStr, "\t$ra, $rb, $offset"),
                 [(brcond (i1 (OpNode Ty:$ra, uimm7:$rb)), bb:$offset)], itin>;

  let isBranch = 1, isTerminator = 1 in
  def NAME # _EXT : BRR_RabBranch_ext<opcode_brr, opxCode.value,
                 (outs), (ins GR:$ra, uimm7:$rb, brtarget_ext:$offset),
                 !strconcat(OpcStr, ".l\t$ra, $rb, $offset"),
                 [(brcond (i1 (OpNode Ty:$ra, uimm7:$rb)), bb:$offset)], itin>;
}

defm BBSI : CompareBitAndBranch<brr_opx_bbsi, "bbsi", cmp_bitset,   i64>;
defm BBCI : CompareBitAndBranch<brr_opx_bbci, "bbci", cmp_bitclear, i64>;

multiclass
CompareBitImmPat<InstBase Op, int direct_value, int invert_value>
{
  def : Pat<(brcond (i1 (seteq (and (srl i64:$a, uimm7:$b), 1), direct_value)), bb:$dst), (Op GR:$a, uimm7:$b, bb:$dst)>;
  def : Pat<(brcond (i1 (seteq (and (sra i64:$a, uimm7:$b), 1), direct_value)), bb:$dst), (Op GR:$a, uimm7:$b, bb:$dst)>;
  def : Pat<(brcond (i1 (setne (and (srl i64:$a, uimm7:$b), 1), invert_value)), bb:$dst), (Op GR:$a, uimm7:$b, bb:$dst)>;
  def : Pat<(brcond (i1 (setne (and (sra i64:$a, uimm7:$b), 1), invert_value)), bb:$dst), (Op GR:$a, uimm7:$b, bb:$dst)>;
}

defm : CompareBitImmPat<BBSI, 1, 0>;
defm : CompareBitImmPat<BBCI, 0, 1>;

// it's ugly but works
foreach III = 0-63 in {
  defvar BIT = !shl(1,III);
  def : Pat<(brcond (i1 (seteq (and i64:$a, BIT),   0)), bb:$dst), (BBCI  GR:$a, III, bb:$dst)>;
  def : Pat<(brcond (i1 (setne (and i64:$a, BIT), BIT)), bb:$dst), (BBCI  GR:$a, III, bb:$dst)>;
  def : Pat<(brcond (i1 (setne (and i64:$a, BIT),   0)), bb:$dst), (BBSI  GR:$a, III, bb:$dst)>;
  def : Pat<(brcond (i1 (seteq (and i64:$a, BIT), BIT)), bb:$dst), (BBSI  GR:$a, III, bb:$dst)>;
}
foreach III = 0-31 in {
  defvar BIT = !shl(1,III);
  def : Pat<(brcond (i1 (seteq (and i32:$a, BIT),   0)), bb:$dst), (BBCI  GR:$a, III, bb:$dst)>;
  def : Pat<(brcond (i1 (setne (and i32:$a, BIT), BIT)), bb:$dst), (BBCI  GR:$a, III, bb:$dst)>;
  def : Pat<(brcond (i1 (setne (and i32:$a, BIT),   0)), bb:$dst), (BBSI  GR:$a, III, bb:$dst)>;
  def : Pat<(brcond (i1 (seteq (and i32:$a, BIT), BIT)), bb:$dst), (BBSI  GR:$a, III, bb:$dst)>;
}

//===----------------------------------------------------------------------===//
// Compare immediate and branch (64 bit)
//===----------------------------------------------------------------------===//
multiclass CompareAndBranchImm
  <opcode_opx opcode, string OpcStr, PatFrag OpNode, ValueType Ty,
   Operand immOp, Operand immOpEx, InstrItinClass itin = IIC_iu_instr>
{
  let isBranch = 1, isTerminator = 1 in
  def NAME : PRIMARY_RaImmBranch<opcode, (outs),
                 (ins GR:$ra, immOp:$imm, brtarget:$offset),
                 !strconcat(OpcStr, "\t$ra, $imm, $offset"),
                 [(brcond (i1 (OpNode Ty:$ra, immOp:$imm)), bb:$offset)], itin>;

  let isBranch = 1, isTerminator = 1 in
  def NAME # _EXT : PRIMARY_RaImmBranch_ext<opcode,
                 (outs), (ins GR:$ra, immOpEx:$imm, brtarget_ext:$offset),
                 !strconcat(OpcStr, ".l\t$ra, $imm, $offset"),
                 [(brcond (i1 (OpNode Ty:$ra, immOpEx:$imm)), bb:$offset)], itin>;
}

defm BDEQI  : CompareAndBranchImm<opcode_bdeqi,  "bdeqi",  seteq,  i64, simm11, simm11_ext>;
defm BDNEI  : CompareAndBranchImm<opcode_bdnei,  "bdnei",  setne,  i64, simm11, simm11_ext>;
defm BDLTI  : CompareAndBranchImm<opcode_bdlti,  "bdlti",  setlt,  i64, simm11, simm11_ext>;
defm BDGEI  : CompareAndBranchImm<opcode_bdgei,  "bdgei",  setge,  i64, simm11, simm11_ext>;
defm BDLTUI : CompareAndBranchImm<opcode_bdltui, "bdltui", setult, i64, uimm11, uimm11_ext>;
defm BDGEUI : CompareAndBranchImm<opcode_bdgeui, "bdgeui", setuge, i64, uimm11, uimm11_ext>;

defm BWEQI  : CompareAndBranchImm<opcode_bweqi,  "bweqi",  seteq,  i32, simm11i32, simm11i32_ext>;
defm BWNEI  : CompareAndBranchImm<opcode_bwnei,  "bwnei",  setne,  i32, simm11i32, simm11i32_ext>;
defm BWLTI  : CompareAndBranchImm<opcode_bwlti,  "bwlti",  setlt,  i32, simm11i32, simm11i32_ext>;
defm BWGEI  : CompareAndBranchImm<opcode_bwgei,  "bwgei",  setge,  i32, simm11i32, simm11i32_ext>;
defm BWLTUI : CompareAndBranchImm<opcode_bwltui, "bwltui", setult, i32, uimm11i32, uimm11i32_ext>;
defm BWGEUI : CompareAndBranchImm<opcode_bwgeui, "bwgeui", setuge, i32, uimm11i32, uimm11i32_ext>;

defm BMALL    : CompareAndBranchImm<opcode_bmall,    "bmall",    cmp_all,    i64, uimm11, uimm11_ext>;
defm BMNOTALL : CompareAndBranchImm<opcode_bmnotall, "bmnotall", cmp_notall, i64, uimm11, uimm11_ext>;
defm BMNONE   : CompareAndBranchImm<opcode_bmnone,   "bmnone",   cmp_none,   i64, uimm11, uimm11_ext>;
defm BMANY    : CompareAndBranchImm<opcode_bmany,    "bmany",    cmp_any,    i64, uimm11, uimm11_ext>;

multiclass
CompareImmPlus64<InstBase Inst, InstBaseExt InstExt, PatFrag OpNode, ValueType Ty, PatLeaf immOp, PatLeaf immOpEx>
{
  def : Pat<(brcond (i1 (OpNode Ty:$ra, immOp  :$imm)), bb:$offset), (Inst    GR:$ra, (Plus1 imm:$imm), bb:$offset)>;
  def : Pat<(brcond (i1 (OpNode Ty:$ra, immOpEx:$imm)), bb:$offset), (InstExt GR:$ra, (Plus1 imm:$imm), bb:$offset)>;
}

multiclass
CompareImmPlus32<InstBase Inst, InstBaseExt InstExt, PatFrag OpNode, ValueType Ty, PatLeaf immOp, PatLeaf immOpEx>
{
  def : Pat<(brcond (i1 (OpNode Ty:$ra, immOp  :$imm)), bb:$offset), (Inst    GR:$ra, (Plus1_32 imm:$imm), bb:$offset)>;
  def : Pat<(brcond (i1 (OpNode Ty:$ra, immOpEx:$imm)), bb:$offset), (InstExt GR:$ra, (Plus1_32 imm:$imm), bb:$offset)>;
}

// "<= 15" ==> "< 16"
defm : CompareImmPlus64<BDLTI,  BDLTI_EXT,  setle,  i64, simm11_plus1, simm11_ext_plus1>;
defm : CompareImmPlus64<BDLTUI, BDLTUI_EXT, setule, i64, uimm11_plus1, uimm11_ext_plus1>;
defm : CompareImmPlus32<BWLTI,  BWLTI_EXT,  setle,  i32, simm11_plus1, simm11_ext_plus1>;
defm : CompareImmPlus32<BWLTUI, BWLTUI_EXT, setule, i32, uimm11_plus1, uimm11_ext_plus1>;
// "> 15" ==> ">= 16"
defm : CompareImmPlus64<BDGEI,  BDGEI_EXT,  setgt,  i64, simm11_plus1, simm11_ext_plus1>;
defm : CompareImmPlus64<BDGEUI, BDGEUI_EXT, setugt, i64, uimm11_plus1, uimm11_ext_plus1>;
defm : CompareImmPlus32<BWGEI,  BWGEI_EXT,  setgt,  i32, simm11_plus1, simm11_ext_plus1>;
defm : CompareImmPlus32<BWGEUI, BWGEUI_EXT, setugt, i32, uimm11_plus1, uimm11_ext_plus1>;

//===----------------------------------------------------------------------===//
// i1 (branches/sext/zext/sext_inreg) and extra pattern is needed for a brcond
// without a setcc (i.e. where the condition was calculated elsewhere).
// i1 true is -1
//===----------------------------------------------------------------------===//
// if ([!] cond)
def : Pat<(brcond           i1:$cond  , bb:$dst), (BBSI GR:$cond, 0, bb:$dst)>;
def : Pat<(brcond  (i1 (not i1:$cond)), bb:$dst), (BBCI GR:$cond, 0, bb:$dst)>;

//def : Pat<(brcond i32:$cond, bb:$dst), (BWNE GR:$cond, (i32 gz), bb:$dst)>;
//def : Pat<(brcond i64:$cond, bb:$dst), (BDNE GR:$cond, (i64 gz), bb:$dst)>;

// if (cond [!|=]= [true|false])
def : Pat<(brcond (i1 (seteq i1:$a, (i1 0))), bb:$dst), (BBCI GR:$a, 0, bb:$dst)>;
def : Pat<(brcond (i1 (setne i1:$a, (i1 0))), bb:$dst), (BBSI GR:$a, 0, bb:$dst)>;
def : Pat<(brcond (i1 (seteq i1:$a, (i1 -1))), bb:$dst), (BBSI GR:$a, 0, bb:$dst)>;
def : Pat<(brcond (i1 (setne i1:$a, (i1 -1))), bb:$dst), (BBCI GR:$a, 0, bb:$dst)>;

// if (cond1 [!|=]= cond2)
def : Pat<(brcond (i1 (seteq i1:$a, i1:$b)), bb:$dst), (BDEQ GR:$a, GR:$b, bb:$dst)>;
def : Pat<(brcond (i1 (setne i1:$a, i1:$b)), bb:$dst), (BDNE GR:$a, GR:$b, bb:$dst)>;

multiclass BooleanIntPat<ValueType Ty> {
  // trunc to i1 modeled as 0-bit
  def : Pat<(i1 (trunc Ty:$val)), (ANDI Ty:$val, 1)>;

  // i1 should be always 0/1, zero extending to wider types is trivial remarking
  def : Pat<(Ty (  zext i1:$val)), (Ty (COPY i1:$val))>;
  def : Pat<(Ty (anyext i1:$val)), (Ty (COPY i1:$val))>;
  def : Pat<(Ty (  sext i1:$val)), (SLSRAI  $val, 63, 63)>;

  // branch on trunc to i1 modeled as 0-bit BBSI/BBCI
  def : Pat<(brcond (         i1 (trunc Ty:$val)  ), bb:$dst), (BBSI Ty:$val, 0, bb:$dst)>;
  def : Pat<(brcond (i1 (not (i1 (trunc Ty:$val)))), bb:$dst), (BBCI Ty:$val, 0, bb:$dst)>;

  def : Pat<(brcond (i1 (seteq (i1 (trunc Ty:$val)), (i1 -1))), bb:$dst), (BBSI Ty:$val, 0, bb:$dst)>;
  def : Pat<(brcond (i1 (setne (i1 (trunc Ty:$val)), (i1 0))), bb:$dst), (BBSI Ty:$val, 0, bb:$dst)>;
  def : Pat<(brcond (i1 (seteq (i1 (trunc Ty:$val)), (i1 0))), bb:$dst), (BBCI Ty:$val, 0, bb:$dst)>;
  def : Pat<(brcond (i1 (setne (i1 (trunc Ty:$val)), (i1 -1))), bb:$dst), (BBCI Ty:$val, 0, bb:$dst)>;
}

defm : BooleanIntPat<i32>;
defm : BooleanIntPat<i64>;
defm : BooleanIntPat<i128>;

// i1 is signed (0 or -1)
def : Pat<(i1 -1), (LDI 1)>;
def : Pat<(i1  0), (LDI 0)>;

// i1 sign extension is double shift
def : Pat<(i32 (sext_inreg i32:$val, i1)), (SLSRAI i32:$val, 63, 63)>;
def : Pat<(i64 (sext_inreg i64:$val, i1)), (SLSRAI i64:$val, 63, 63)>;

// FIXME: unused?
//def : Pat<(i1 (seteq i1:$rb, i1:$rc)), (CMPWEQ   GR:$rb, GR:$rc)>;
//def : Pat<(i1 (setne i1:$rb, i1:$rc)), (CMPWNE   GR:$rb, GR:$rc)>;
//def : Pat<(i1 (seteq i1:$rb, (i1 0))), (CMPWEQI  GR:$rb, 0)>;
//def : Pat<(i1 (seteq i1:$rb, (i1 -1))), (CMPWEQI GR:$rb, 1)>;
//def : Pat<(i1 (setne i1:$rb, (i1 0))), (CMPWNEI  GR:$rb, 0)>;
//def : Pat<(i1 (setne i1:$rb, (i1 -1))), (CMPWNEI GR:$rb, 1)>;

def : Pat<(i1 (not i1:$src)), (XORI GR:$src, 1)>;

// TODO: (a cmp b)
// ((xor a, b) xor -1)
// ((xor a, -1) and b)
// ((xor a, -1) or b)

//===----------------------------------------------------------------------===//
// The same integer registers are used for i32 and i64 values.
// When we need lesser value, the high bits are don't care.
// This give us free trunc.
//===----------------------------------------------------------------------===//
def : Pat<(i32 (trunc i128:$val)), (COPY_TO_REGCLASS $val, GR)>;
def : Pat<(i64 (trunc i128:$val)), (COPY_TO_REGCLASS $val, GR)>;
def : Pat<(i32 (trunc  i64:$val)), (COPY_TO_REGCLASS $val, GR)>;

def : Pat<(i64  (anyext i32:$val)), (SRLWI $val, 0)>;

def : Pat<(i128 (anyext i32:$val)), (SRLWI $val, 0)>;
def : Pat<(i128 (anyext i64:$val)), (SRLDI $val, 0)>;
def : Pat<(i128 (zext   i32:$val)), (SRLWI $val, 0)>;
def : Pat<(i128 (zext   i64:$val)), (SRLDI $val, 0)>;

//===----------------------------------------------------------------------===//
// 64-bit Shift Instructions.
//===----------------------------------------------------------------------===//
//
// The 32-bit shift instructions are still available. The left shift srl
// instructions shift all 64 bits, but it only accepts a 5-bit shift amount.
//
// The srl instructions only shift the low 32 bits and clear the high 32 bits.
// Finally, sra shifts the low 32 bits and sign-extends to 64 bits.

def : Pat<(i64 (zext i32:$val)), (SRLWI $val, 0)>;
def : Pat<(i64 (sext i32:$val)), (SRAWI $val, 0)>;

def : Pat<(i64 (and i64:$val, 0xffffffff)), (SRLWI $val, 0)>;
def : Pat<(i64 (sext_inreg i64:$val, i32)), (SRAWI $val, 0)>;

def : Pat<(i64 (sext_inreg i64:$val, i8 )), (SLSRAI i64:$val, 56, 56)>;
def : Pat<(i64 (sext_inreg i64:$val, i16)), (SLSRAI i64:$val, 48, 48)>;
def : Pat<(i64 (sext_inreg i64:$val, i32)), (SLSRAI i64:$val, 32, 32)>;

def : Pat<(i32 (sext_inreg i32:$val, i8 )), (SLSRAI i32:$val, 56, 56)>;
def : Pat<(i32 (sext_inreg i32:$val, i16)), (SLSRAI i32:$val, 48, 48)>;

def : Pat<(add i64:$Rs, (tls_offset_wrapper tglobaltlsaddr:$addr)),
          (ADDI i64:$Rs, tglobaltlsaddr:$addr)>;
def : Pat<(add i64:$Rs, (tls_offset_wrapper_ext tglobaltlsaddr:$addr)),
          (ADDI_EXT i64:$Rs, tglobaltlsaddr:$addr)>;
