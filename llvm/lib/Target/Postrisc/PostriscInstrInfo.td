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
  let EncoderMethod = "getCallTargetOpValue<false>";
  let DecoderMethod = "DecodeBranch<28>";
}
def calltarget_ext : Operand<i64> {
  let EncoderMethod = "getCallTargetOpValue<true>";
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
def pr_subr : PatFrag<(ops node:$src1, node:$src2), (sub node:$src2, node:$src1)>; // inverted: subtract from
def pr_neg  : PatFrag<(ops node:$src1), (ineg node:$src1)>;
def pr_abs  : PatFrag<(ops node:$src1), (abs node:$src1)>;  // absolute value
def pr_absd : PatFrag<(ops node:$src1, node:$src2), (abs (sub node:$src2, node:$src1))>;  // absolute difference: abs(a-b)
def pr_mul  : PatFrag<(ops node:$src1, node:$src2), (mul node:$src1, node:$src2)>;
def pr_shl  : PatFrag<(ops node:$src1, node:$src2), (shl node:$src1, node:$src2)>;
def pr_srl  : PatFrag<(ops node:$src1, node:$src2), (srl node:$src1, node:$src2)>;
def pr_sra  : PatFrag<(ops node:$src1, node:$src2), (sra node:$src1, node:$src2)>;

def cmp_all    : PatFrag<(ops node:$x, node:$y), (seteq (and node:$x, node:$y), node:$y)>;
def cmp_notall : PatFrag<(ops node:$x, node:$y), (setne (and node:$x, node:$y), node:$y)>;

def cmp_all_swapped    : PatFrag<(ops node:$x, node:$y), (seteq (and node:$x, node:$y), node:$x)>;
def cmp_notall_swapped : PatFrag<(ops node:$x, node:$y), (setne (and node:$x, node:$y), node:$x)>;

def cmp_none   : PatFrag<(ops node:$x, node:$y), (seteq (and node:$x, node:$y), 0)>;
def cmp_any    : PatFrag<(ops node:$x, node:$y), (setne (and node:$x, node:$y), 0)>;

def imm_pow2 : PatLeaf<(imm), [{ return N->getAPIntValue().isPowerOf2(); }]>;
def imm_pow2_xform : SDNodeXForm<imm, [{ return getU32Imm(N->getAPIntValue().countTrailingZeros(), SDLoc(N)); }]>;

def imm_inv_pow2 : PatLeaf<(imm), [{ return (~N->getAPIntValue()).isPowerOf2(); }]>;
def imm_inv_pow2_xform : SDNodeXForm<imm, [{ return getU32Imm((~N->getAPIntValue()).countTrailingZeros(), SDLoc(N)); }]>;

defm ADDD  : MISC_R3<opcode_addd,   pr_add,  i64, i64>;
defm ADDWS : MISC_R3<opcode_addws,  pr_add,  i32, i32>;
defm ADDWZ : MISC_R3<opcode_addwz,  pr_add,  i32, i32>;
defm SUBD  : MISC_R3<opcode_subd,   pr_sub,  i64, i64>;
defm SUBWS : MISC_R3<opcode_subws,  pr_sub,  i32, i32>;
defm SUBWZ : MISC_R3<opcode_subwz,  pr_sub,  i32, i32>;
defm MULD  : MISC_R3<opcode_muld,   pr_mul,  i64, i64>;
defm MULWS : MISC_R3<opcode_mulws,  pr_mul,  i32, i32>;
defm MULWZ : MISC_R3<opcode_mulwz,  pr_mul,  i32, i32>;

defm ADDQ : MISC_R3<opcode_addq, pr_add,  i128, i128>;
defm SUBQ : MISC_R3<opcode_subq, pr_sub,  i128, i128>;
defm MULQ : MISC_R3<opcode_mulq, pr_mul,  i128, i128>;

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

// absolute value
defm ABSW : MISC_R2<opcode_absw, pr_abs, i32,  i32>;
defm ABSD : MISC_R2<opcode_absd, pr_abs, i64,  i64>;
defm ABSQ : MISC_R2<opcode_absq, pr_abs, i128, i128>;

// absolute difference
defm ABDW : MISC_R3<opcode_abdw, pr_absd, i32,  i32>;
defm ABDD : MISC_R3<opcode_abdd, pr_absd, i64,  i64>;
defm ABDQ : MISC_R3<opcode_abdq, pr_absd, i128, i128>;

defm ADDIWS : PRIM_R2_IMM<opcode_addiws, pr_add,  i32,  i32,  simm21i32,  simm21i32_ext>;
defm ADDID  : PRIM_R2_IMM<opcode_addid,  pr_add,  i64,  i64,  simm21,     simm21_ext>;
defm ADDIQ  : PRIM_R2_IMM<opcode_addiq,  pr_add,  i128, i128, simm21i128, simm21i128_ext>;

defm SUBRIWS : PRIM_R2_IMM<opcode_subriws, pr_subr, i32, i32, simm21i32, simm21i32_ext>;
defm SUBRID  : PRIM_R2_IMM<opcode_subrid,  pr_subr, i64, i64, simm21,    simm21_ext>;

defm MULIWS : PRIM_R2_IMM<opcode_muliws, pr_mul,  i32, i32, simm21i32, simm21i32_ext>;
defm MULID  : PRIM_R2_IMM<opcode_mulid,  pr_mul,  i64, i64, simm21,    simm21_ext>;

defm ADDIWZ  : PRIM_R2_IMM<opcode_addiwz,  pr_add,  i32, i32, simm21i32, simm21i32_ext>;
defm SUBRIWZ : PRIM_R2_IMM<opcode_subriwz, pr_subr, i32, i32, simm21i32, simm21i32_ext>;
defm MULIWZ  : PRIM_R2_IMM<opcode_muliwz,  pr_mul,  i32, i32, uimm21i32, uimm21i32_ext>;

//===----------------------------------------------------------------------===//
// neg
//===----------------------------------------------------------------------===//
defm NEGW : MISC_R2<opcode_negw, pr_neg, i32,  i32>;
defm NEGD : MISC_R2<opcode_negd, pr_neg, i64,  i64>;
defm NEGQ : MISC_R2<opcode_negq, pr_neg, i128, i128>;

// negation is also sext to a bigger types
def : Pat<(i64  (sext (pr_neg i32:$val))), (NEGW i32:$val)>;
def : Pat<(i128 (sext (pr_neg i32:$val))), (NEGW i32:$val)>;
def : Pat<(i128 (sext (pr_neg i64:$val))), (NEGD i64:$val)>;

//===----------------------------------------------------------------------===//
// FrameIndex calculations
//===----------------------------------------------------------------------===//
def : Pat<(i64 AddrFI:$Rs), (ADDID (i64 AddrFI:$Rs), 0)>;
def : Pat<(add (i64 AddrFI:$Rs), simm21:$imm), (ADDID (i64 AddrFI:$Rs), simm21:$imm)>;
def : Pat<(add (i64 AddrFI:$Rs), simm21_ext:$imm), (ADDID_EXT (i64 AddrFI:$Rs), simm21_ext:$imm)>;

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
defm : OP_SEXT_IMM<SUBRIWS, SUBRIWS_EXT, pr_subr>;
defm : OP_SEXT_IMM<MULIWS,  MULIWS_EXT,  pr_mul>;

// i32 with unsigned immediate, post-zero-extension, pre-trunc
multiclass OP_ZEXT_IMM<InstBase INSN, InstBaseExt INSN_ext, PatFrag OpNode> {
  // i32 with post-zero-extension
  def : Pat<(i64 (zext (OpNode i32:$rb, uimm21i32    :$imm))), (INSN     GR:$rb, uimm21i32    :$imm)>;
  def : Pat<(i64 (zext (OpNode i32:$rb, uimm21i32_ext:$imm))), (INSN_ext GR:$rb, uimm21i32_ext:$imm)>;
  // i32 with pre-trunc and post-zero-extension
  def : Pat<(i64 (zext (OpNode (i32 (trunc i64:$rb)), uimm21i32    :$imm))), (INSN     GR:$rb, uimm21i32    :$imm)>;
  def : Pat<(i64 (zext (OpNode (i32 (trunc i64:$rb)), uimm21i32_ext:$imm))), (INSN_ext GR:$rb, uimm21i32_ext:$imm)>;
}
defm : OP_ZEXT_IMM<MULIWZ,  MULIWZ_EXT,  pr_mul>;

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
defm : OP_ZEXT_SEXT_IMM<SUBRIWZ, SUBRIWZ_EXT, pr_subr>;

//===----------------------------------------------------------------------===//
// carry/borrow
//===----------------------------------------------------------------------===//
def ADDCD : MISC_Rabc<opcode_addcd, (outs GR:$ra), (ins GR:$rb, GR:$rc),
         !strconcat(opcode_addcd.mnem, " $ra, $rb, $rc"),
         [(set i128:$ra, (i128 (add (i128 (zext i64:$rb)), (i128 (zext i64:$rc)))))], IIC_iu_instr>;

def SUBCD : MISC_Rabc<opcode_subcd, (outs GR:$ra), (ins GR:$rb, GR:$rc),
         !strconcat(opcode_subcd.mnem, " $ra, $rb, $rc"),
         [(set i128:$ra, (i128 (sub (i128 (zext i64:$rb)), (i128 (zext i64:$rc)))))], IIC_iu_instr>;

// (u128)rb + (u128)rc + ((u128)rd >> 64)
def ADDC3D : FUSED_Rabcd<opcode_addc3d, (outs GR:$ra), (ins GR:$rb, GR:$rc, GR:$rd),
         !strconcat(opcode_addc3d.mnem, " $ra, $rb, $rc, $rd"),
         [(set i128:$ra, (i128 (add (add (i128 (zext i64:$rb)), (i128 (zext i64:$rc))), (srl i128:$rd, (i32 64)))))],
         IIC_iu_instr>;

// (u128)rb - (u128)rc + ((i128)rd >> 64)
def SUBC3D : FUSED_Rabcd<opcode_subc3d, (outs GR:$ra), (ins GR:$rb, GR:$rc, GR:$rd),
         !strconcat(opcode_subc3d.mnem, " $ra, $rb, $rc, $rd"),
         [(set i128:$ra, (i128 (add (sub (i128 (zext i64:$rb)), (i128 (zext i64:$rc))), (sra i128:$rd, (i32 64)))))],
         IIC_iu_instr>;

//===----------------------------------------------------------------------===//
// min/max
//===----------------------------------------------------------------------===//
def pr_smin : PatFrag<(ops node:$src1, node:$src2), (smin node:$src1, node:$src2)>;
def pr_umin : PatFrag<(ops node:$src1, node:$src2), (umin node:$src1, node:$src2)>;
def pr_smax : PatFrag<(ops node:$src1, node:$src2), (smax node:$src1, node:$src2)>;
def pr_umax : PatFrag<(ops node:$src1, node:$src2), (umax node:$src1, node:$src2)>;

defm MINSD : MISC_R3<opcode_minsd, pr_smin, i64, i64>;
defm MINUD : MISC_R3<opcode_minud, pr_umin, i64, i64>;
defm MAXSD : MISC_R3<opcode_maxsd, pr_smax, i64, i64>;
defm MAXUD : MISC_R3<opcode_maxud, pr_umax, i64, i64>;

defm MINSW : MISC_R3<opcode_minsw, pr_smin, i32, i32>;
defm MINUW : MISC_R3<opcode_minuw, pr_umin, i32, i32>;
defm MAXSW : MISC_R3<opcode_maxsw, pr_smax, i32, i32>;
defm MAXUW : MISC_R3<opcode_maxuw, pr_umax, i32, i32>;

defm MINSQ : MISC_R3<opcode_minsq, pr_smin, i128, i128>;
defm MINUQ : MISC_R3<opcode_minuq, pr_umin, i128, i128>;
defm MAXSQ : MISC_R3<opcode_maxsq, pr_smax, i128, i128>;
defm MAXUQ : MISC_R3<opcode_maxuq, pr_umax, i128, i128>;

defm MINSID : PRIM_R2_IMM<opcode_minsid, pr_smin, i64, i64, simm21, simm21_ext>;
defm MAXSID : PRIM_R2_IMM<opcode_maxsid, pr_smax, i64, i64, simm21, simm21_ext>;
defm MINUID : PRIM_R2_IMM<opcode_minuid, pr_umin, i64, i64, uimm21, uimm21_ext>;
defm MAXUID : PRIM_R2_IMM<opcode_maxuid, pr_umax, i64, i64, uimm21, uimm21_ext>;

defm MINSIW : PRIM_R2_IMM<opcode_minsiw, pr_smin, i32, i32, simm21i32, simm21i32_ext>;
defm MAXSIW : PRIM_R2_IMM<opcode_maxsiw, pr_smax, i32, i32, simm21i32, simm21i32_ext>;
defm MINUIW : PRIM_R2_IMM<opcode_minuiw, pr_umin, i32, i32, uimm21i32, uimm21i32_ext>;
defm MAXUIW : PRIM_R2_IMM<opcode_maxuiw, pr_umax, i32, i32, uimm21i32, uimm21i32_ext>;

//===----------------------------------------------------------------------===//
// fused ALU operations
//===----------------------------------------------------------------------===//
def pr_addadd  : PatFrag<(ops node:$src1, node:$src2, node:$src3), (add (add node:$src1, node:$src2), node:$src3)>;
def pr_addsub  : PatFrag<(ops node:$src1, node:$src2, node:$src3), (sub (add node:$src1, node:$src2), node:$src3)>;
def pr_subsub  : PatFrag<(ops node:$src1, node:$src2, node:$src3), (sub node:$src1, (add node:$src2, node:$src3))>;
def pr_muladd  : PatFrag<(ops node:$src1, node:$src2, node:$src3), (add (mul node:$src1, node:$src2), node:$src3)>;
def pr_mulsub  : PatFrag<(ops node:$src1, node:$src2, node:$src3), (sub (mul node:$src1, node:$src2), node:$src3)>;
def pr_mulsubr : PatFrag<(ops node:$src1, node:$src2, node:$src3), (sub node:$src3, (mul node:$src1, node:$src2))>;

defm ADDADDD  : FUSED_R4<opcode_addaddd,  pr_addadd,  i64, i64, i64, i64>;
defm ADDSUBD  : FUSED_R4<opcode_addsubd,  pr_addsub,  i64, i64, i64, i64>;
defm SUBSUBD  : FUSED_R4<opcode_subsubd,  pr_subsub,  i64, i64, i64, i64>;
defm MULADDD  : FUSED_R4<opcode_muladdd,  pr_muladd,  i64, i64, i64, i64>;
defm MULSUBD  : FUSED_R4<opcode_mulsubd,  pr_mulsub,  i64, i64, i64, i64>;
defm MULSUBRD : FUSED_R4<opcode_mulsubrd, pr_mulsubr, i64, i64, i64, i64>;

//===----------------------------------------------------------------------===//
/// Compare reg-reg instructions
//===----------------------------------------------------------------------===//
defm CMPEQW : MISC_R3<opcode_cmpeqw, seteq,  i1, i32>;
defm CMPNEW : MISC_R3<opcode_cmpnew, setne,  i1, i32>;
defm CMPEQD : MISC_R3<opcode_cmpeqd, seteq,  i1, i64>;
defm CMPNED : MISC_R3<opcode_cmpned, setne,  i1, i64>;
defm CMPEQQ : MISC_R3<opcode_cmpeqq, seteq,  i1, i128>;
defm CMPNEQ : MISC_R3<opcode_cmpneq, setne,  i1, i128>;

defm CMPLTSW : MISC_R3<opcode_cmpltsw, setlt,  i1, i32>;
defm CMPGESW : MISC_R3<opcode_cmpgesw, setge,  i1, i32>;
defm CMPLTUW : MISC_R3<opcode_cmpltuw, setult, i1, i32>;
defm CMPGEUW : MISC_R3<opcode_cmpgeuw, setuge, i1, i32>;

defm CMPLTSD : MISC_R3<opcode_cmpltsd, setlt,  i1, i64>;
defm CMPGESD : MISC_R3<opcode_cmpgesd, setge,  i1, i64>;
defm CMPLTUD : MISC_R3<opcode_cmpltud, setult, i1, i64>;
defm CMPGEUD : MISC_R3<opcode_cmpgeud, setuge, i1, i64>;

defm CMPLTSQ : MISC_R3<opcode_cmpltsq, setlt,  i1, i128>;
defm CMPGESQ : MISC_R3<opcode_cmpgesq, setge,  i1, i128>;
defm CMPLTUQ : MISC_R3<opcode_cmpltuq, setult, i1, i128>;
defm CMPGEUQ : MISC_R3<opcode_cmpgeuq, setuge, i1, i128>;

multiclass CompareSwappedArgs<InstBase LT, InstBase GE, InstBase LTU, InstBase GEU, ValueType Ty>
{
  // GT(c,b) via LT(b,c)
  def : Pat<(i1 (setgt  Ty:$rc, Ty:$rb)), (LT  GR:$rb, GR:$rc)>;
  def : Pat<(i1 (setugt Ty:$rc, Ty:$rb)), (LTU GR:$rb, GR:$rc)>;
  // LE(c,b) via GE(b,c)
  def : Pat<(i1 (setle  Ty:$rc, Ty:$rb)), (GE  GR:$rb, GR:$rc)>;
  def : Pat<(i1 (setule Ty:$rc, Ty:$rb)), (GEU GR:$rb, GR:$rc)>;
}
defm : CompareSwappedArgs<CMPLTSW, CMPGESW, CMPLTUW, CMPGEUW, i32>;
defm : CompareSwappedArgs<CMPLTSD, CMPGESD, CMPLTUD, CMPGEUD, i64>;
defm : CompareSwappedArgs<CMPLTSQ, CMPGESQ, CMPLTUQ, CMPGEUQ, i128>;

//===----------------------------------------------------------------------===//
/// Compare reg-imm instructions
//===----------------------------------------------------------------------===//
defm CMPEQIW : PRIM_R2_IMM<opcode_cmpeqiw, seteq, i1, i32, simm21i32, simm21i32_ext>;
defm CMPNEIW : PRIM_R2_IMM<opcode_cmpneiw, setne, i1, i32, simm21i32, simm21i32_ext>;
defm CMPEQID : PRIM_R2_IMM<opcode_cmpeqid, seteq, i1, i64, simm21, simm21_ext>;
defm CMPNEID : PRIM_R2_IMM<opcode_cmpneid, setne, i1, i64, simm21, simm21_ext>;
defm CMPEQIQ : PRIM_R2_IMM<opcode_cmpeqiq, seteq, i1, i128, simm21i128, simm21i128_ext>;
defm CMPNEIQ : PRIM_R2_IMM<opcode_cmpneiq, setne, i1, i128, simm21i128, simm21i128_ext>;

defm CMPLTSIW : PRIM_R2_IMM<opcode_cmpltsiw, setlt,  i1, i32, simm21i32, simm21i32_ext>;
defm CMPGESIW : PRIM_R2_IMM<opcode_cmpgesiw, setge,  i1, i32, simm21i32, simm21i32_ext>;
defm CMPLTUIW : PRIM_R2_IMM<opcode_cmpltuiw, setult, i1, i32, uimm21i32, uimm21i32_ext>;
defm CMPGEUIW : PRIM_R2_IMM<opcode_cmpgeuiw, setuge, i1, i32, uimm21i32, uimm21i32_ext>;

defm CMPLTSID : PRIM_R2_IMM<opcode_cmpltsid, setlt,  i1, i64, simm21, simm21_ext>;
defm CMPGESID : PRIM_R2_IMM<opcode_cmpgesid, setge,  i1, i64, simm21, simm21_ext>;
defm CMPLTUID : PRIM_R2_IMM<opcode_cmpltuid, setult, i1, i64, uimm21, uimm21_ext>;
defm CMPGEUID : PRIM_R2_IMM<opcode_cmpgeuid, setuge, i1, i64, uimm21, uimm21_ext>;

defm CMPLTSIQ : PRIM_R2_IMM<opcode_cmpltsiq, setlt,  i1, i128, simm21i128, simm21i128_ext>;
defm CMPGESIQ : PRIM_R2_IMM<opcode_cmpgesiq, setge,  i1, i128, simm21i128, simm21i128_ext>;
defm CMPLTUIQ : PRIM_R2_IMM<opcode_cmpltuiq, setult, i1, i128, uimm21i128, uimm21i128_ext>;
defm CMPGEUIQ : PRIM_R2_IMM<opcode_cmpgeuiq, setuge, i1, i128, uimm21i128, uimm21i128_ext>;

multiclass CompareSwappedArgsImm<InstBase LT, InstBase LTU, InstBase GE, InstBase GEU, ValueType Ty, Operand simmOp, Operand uimmOp>
{
  // GT(imm,r) via LT(r,imm)
  def : Pat<(i1 (setgt  simmOp:$imm, Ty:$rb)), (LT  GR:$rb, simmOp:$imm)>;
  def : Pat<(i1 (setugt uimmOp:$imm, Ty:$rb)), (LTU GR:$rb, uimmOp:$imm)>;
  // LT(imm,r) via GE(r,imm)
  def : Pat<(i1 (setle  simmOp:$imm, Ty:$rb)), (GE  GR:$rb, simmOp:$imm)>;
  def : Pat<(i1 (setule uimmOp:$imm, Ty:$rb)), (GEU GR:$rb, uimmOp:$imm)>;
}
defm : CompareSwappedArgsImm<CMPLTSIW, CMPLTUIW, CMPGESIW, CMPGEUIW, i32,  simm21i32,  uimm21i32>;
defm : CompareSwappedArgsImm<CMPLTSID, CMPLTUID, CMPGESID, CMPGEUID, i64,  simm21,  uimm21>;
defm : CompareSwappedArgsImm<CMPLTSIQ, CMPLTUIQ, CMPGESIQ, CMPGEUIQ, i128, simm21i128, uimm21i128>;

multiclass CompareSwappedArgsImmExt<InstBaseExt LT, InstBaseExt LTU, InstBaseExt GE, InstBaseExt GEU, ValueType Ty, Operand simmOp, Operand uimmOp>
{
  // GT(imm,r) via LT(r,imm)
  def : Pat<(i1 (setgt  simmOp:$imm, Ty:$rb)), (LT  GR:$rb, simmOp:$imm)>;
  def : Pat<(i1 (setugt uimmOp:$imm, Ty:$rb)), (LTU GR:$rb, uimmOp:$imm)>;
  // LT(imm,r) via GE(r,imm)
  def : Pat<(i1 (setlt  simmOp:$imm, Ty:$rb)), (GE  GR:$rb, simmOp:$imm)>;
  def : Pat<(i1 (setult uimmOp:$imm, Ty:$rb)), (GEU GR:$rb, uimmOp:$imm)>;
}
defm : CompareSwappedArgsImmExt<CMPLTSIW_EXT, CMPLTUIW_EXT, CMPGESIW_EXT, CMPGEUIW_EXT, i32,  simm21i32_ext,   uimm21i32_ext>;
defm : CompareSwappedArgsImmExt<CMPLTSID_EXT, CMPLTUID_EXT, CMPGESID_EXT, CMPGEUID_EXT, i64,  simm21_ext,      uimm21_ext>;
defm : CompareSwappedArgsImmExt<CMPLTSIQ_EXT, CMPLTUIQ_EXT, CMPGESIQ_EXT, CMPGEUIQ_EXT, i128, simm21i128_ext,  uimm21i128_ext>;

//===----------------------------------------------------------------------===//
/// Compare reg-(imm+1)
//===----------------------------------------------------------------------===//
multiclass CompareSimmPlus64<InstBase Inst, InstBaseExt InstExt, PatFrag OpNode, ValueType Ty, PatLeaf immOp, PatLeaf immOpEx>
{
  def : Pat<(i1 (OpNode Ty:$ra, immOp  :$imm)), (Inst    GR:$ra, (Plus1_SEXT imm:$imm))>;
  def : Pat<(i1 (OpNode Ty:$ra, immOpEx:$imm)), (InstExt GR:$ra, (Plus1_SEXT imm:$imm))>;
}

multiclass CompareSimmPlus32<InstBase Inst, InstBaseExt InstExt, PatFrag OpNode, ValueType Ty, PatLeaf immOp, PatLeaf immOpEx>
{
  def : Pat<(i1 (OpNode Ty:$ra, immOp  :$imm)), (Inst    GR:$ra, (Plus1_SEXT_32 imm:$imm))>;
  def : Pat<(i1 (OpNode Ty:$ra, immOpEx:$imm)), (InstExt GR:$ra, (Plus1_SEXT_32 imm:$imm))>;
}

multiclass CompareUimmPlus64<InstBase Inst, InstBaseExt InstExt, PatFrag OpNode, ValueType Ty, PatLeaf immOp, PatLeaf immOpEx>
{
  def : Pat<(i1 (OpNode Ty:$ra, immOp  :$imm)), (Inst    GR:$ra, (Plus1_ZEXT imm:$imm))>;
  def : Pat<(i1 (OpNode Ty:$ra, immOpEx:$imm)), (InstExt GR:$ra, (Plus1_ZEXT imm:$imm))>;
}

multiclass CompareUimmPlus32<InstBase Inst, InstBaseExt InstExt, PatFrag OpNode, ValueType Ty, PatLeaf immOp, PatLeaf immOpEx>
{
  def : Pat<(i1 (OpNode Ty:$ra, immOp  :$imm)), (Inst    GR:$ra, (Plus1_ZEXT_32 imm:$imm))>;
  def : Pat<(i1 (OpNode Ty:$ra, immOpEx:$imm)), (InstExt GR:$ra, (Plus1_ZEXT_32 imm:$imm))>;
}

// "<= 15" ==> "< 16"
defm : CompareSimmPlus32<CMPLTSIW, CMPLTSIW_EXT,  setle, i32,  simm21_plus1, simm21_ext_plus1>;
defm : CompareSimmPlus64<CMPLTSID, CMPLTSID_EXT,  setle, i64,  simm21_plus1, simm21_ext_plus1>;
defm : CompareSimmPlus64<CMPLTSIQ, CMPLTSIQ_EXT,  setle, i128, simm21_plus1, simm21_ext_plus1>;

defm : CompareUimmPlus32<CMPLTUIW, CMPLTUIW_EXT, setule, i32,  uimm21_plus1, uimm21_ext_plus1>;
defm : CompareUimmPlus64<CMPLTUID, CMPLTUID_EXT, setule, i64,  uimm21_plus1, uimm21_ext_plus1>;
defm : CompareUimmPlus64<CMPLTUIQ, CMPLTUIQ_EXT, setule, i128, uimm21_plus1, uimm21_ext_plus1>;

// "> 15" ==> ">= 16"
defm : CompareSimmPlus32<CMPGESIW, CMPGESIW_EXT,  setgt, i32,  simm21_plus1, simm21_ext_plus1>;
defm : CompareSimmPlus64<CMPGESID, CMPGESID_EXT,  setgt, i64,  simm21_plus1, simm21_ext_plus1>;
defm : CompareSimmPlus64<CMPGESIQ, CMPGESIQ_EXT,  setgt, i128, simm21_plus1, simm21_ext_plus1>;

defm : CompareUimmPlus32<CMPGEUIW, CMPGEUIW_EXT, setugt, i32,  uimm21_plus1, uimm21_ext_plus1>;
defm : CompareUimmPlus64<CMPGEUID, CMPGEUID_EXT, setugt, i64,  uimm21_plus1, uimm21_ext_plus1>;
defm : CompareUimmPlus64<CMPGEUIQ, CMPGEUIQ_EXT, setugt, i128, uimm21_plus1, uimm21_ext_plus1>;

//===----------------------------------------------------------------------===//
// Divide
//===----------------------------------------------------------------------===//
def pr_sdiv : PatFrag<(ops node:$src1, node:$src2), (sdiv node:$src1, node:$src2)>;
def pr_udiv : PatFrag<(ops node:$src1, node:$src2), (udiv node:$src1, node:$src2)>;
def pr_srem : PatFrag<(ops node:$src1, node:$src2), (srem node:$src1, node:$src2)>;
def pr_urem : PatFrag<(ops node:$src1, node:$src2), (urem node:$src1, node:$src2)>;

// Division can trap.
let hasSideEffects = 1 in {
  defm DIVSD : MISC_R3<opcode_divsd, pr_sdiv, i64, i64>;
  defm DIVUD : MISC_R3<opcode_divud, pr_udiv, i64, i64>;
  defm REMSD : MISC_R3<opcode_remsd, pr_srem, i64, i64>;
  defm REMUD : MISC_R3<opcode_remud, pr_urem, i64, i64>;

  defm DIVSW : MISC_R3<opcode_divsw, pr_sdiv, i32, i32>;
  defm DIVUW : MISC_R3<opcode_divuw, pr_udiv, i32, i32>;
  defm REMSW : MISC_R3<opcode_remsw, pr_srem, i32, i32>;
  defm REMUW : MISC_R3<opcode_remuw, pr_urem, i32, i32>;

  defm DIVSQ : MISC_R3<opcode_divsq, pr_sdiv, i128, i128>;
  defm DIVUQ : MISC_R3<opcode_divuq, pr_udiv, i128, i128>;
  defm REMSQ : MISC_R3<opcode_remsq, pr_srem, i128, i128>;
  defm REMUQ : MISC_R3<opcode_remuq, pr_urem, i128, i128>;

  defm DIVSID : PRIM_R2_IMM<opcode_divsid, pr_sdiv, i64, i64, simm21, simm21_ext>;
  defm DIVUID : PRIM_R2_IMM<opcode_divuid, pr_udiv, i64, i64, uimm21, uimm21_ext>;
  defm REMSID : PRIM_R2_IMM<opcode_remsid, pr_srem, i64, i64, simm21, simm21_ext>;
  defm REMUID : PRIM_R2_IMM<opcode_remuid, pr_urem, i64, i64, uimm21, uimm21_ext>;

  defm DIVSIW : PRIM_R2_IMM<opcode_divsiw, pr_sdiv, i32, i32, simm21i32, simm21i32_ext>;
  defm DIVUIW : PRIM_R2_IMM<opcode_divuiw, pr_udiv, i32, i32, uimm21i32, uimm21i32_ext>;
  defm REMSIW : PRIM_R2_IMM<opcode_remsiw, pr_srem, i32, i32, simm21i32, simm21i32_ext>;
  defm REMUIW : PRIM_R2_IMM<opcode_remuiw, pr_urem, i32, i32, uimm21i32, uimm21i32_ext>;
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
  def JMP     : RAOPX_Branch    <opcode_jmp, (outs), (ins jump_target    :$imm), !strconcat(opcode_jmp.mnem,   " $imm"), [(br bb:$imm)]>;
  def JMP_EXT : RAOPX_Branch_ext<opcode_jmp, (outs), (ins jump_target_ext:$imm), !strconcat(opcode_jmp.mnem, ".l $imm"), [(br bb:$imm)]>;
}

let isTerminator = 1, isBarrier = 1, isBranch = 1, isCodeGenOnly = 1 in {
  def JMP_TAIL     : RAOPX_Branch    <opcode_jmp, (outs), (ins calltarget:$imm, variable_ops), !strconcat(opcode_jmp.mnem,   " $imm"), [], IIC_jmp_or_call>;
  def JMP_TAIL_EXT : RAOPX_Branch_ext<opcode_jmp, (outs), (ins calltarget:$imm, variable_ops), !strconcat(opcode_jmp.mnem, ".l $imm"), [], IIC_jmp_or_call>;
}

//===----------------------------------------------------------------------===//
// Indirect jump/tail_call instructions
//===----------------------------------------------------------------------===//
let isTerminator = 1, isBarrier = 1, isBranch = 1, isIndirectBranch = 1, ra = 0 in {
  def JMPR : MISC_RabcScale<opcode_jmpr, (outs), (ins GR:$rb, GR:$rc, scale:$scale),
                             !strconcat(opcode_jmpr.mnem, " $rb, $rc, $scale"), []>;
}

def : Pat<(brind (i64 (add i64:$rb, (shl i64:$rc, scale:$scale)))), (JMPR GR:$rb, GR:$rc, scale:$scale)>;
def : Pat<(brind (i64 (add i64:$rb,      i64:$rc               ))), (JMPR GR:$rb, GR:$rc, 0)>;
def : Pat<(brind           i64:$rb                               ), (JMPR GR:$rb, (i64 gz), 0)>;

//===----------------------------------------------------------------------===//
// Indirect jump table
//===----------------------------------------------------------------------===//
let isTerminator = 1, isBarrier = 1, isBranch = 1, isIndirectBranch = 1, ra = 0 in {
  def JMPT   : MISC_Rabc<opcode_jmpt,   (outs), (ins GR:$rb, GR:$rc), !strconcat(opcode_jmpt.mnem,   " $rb, $rc"), []>;
  def JMPTSW : MISC_Rabc<opcode_jmptsw, (outs), (ins GR:$rb, GR:$rc), !strconcat(opcode_jmptsw.mnem, " $rb, $rc"), []>;
  def JMPTUW : MISC_Rabc<opcode_jmptuw, (outs), (ins GR:$rb, GR:$rc), !strconcat(opcode_jmptuw.mnem, " $rb, $rc"), []>;
}

def jmp_table_load_i64 : PatFrag<(ops node:$base, node:$index),
      (brind (i64 (add node:$base, (i64 (sextloadi32 (add node:$base, (shl node:$index, (i32 2))))))))>;
def : Pat<(jmp_table_load_i64 i64:$rb, i64:$rc), (JMPT GR:$rb, GR:$rc)>;

// FIXME: switches with i32 indices use zero extension before indexing (not matched)
def jmp_table_load_u32 : PatFrag<(ops node:$base, node:$index),
      (brind (i64 (add node:$base, (i64 (sextloadi32 (add node:$base, (shl (i64 (zext node:$index)), (i32 2))))))))>;

//def : Pat<(jmp_table_load_i32 i64:$rb, i32:$rc), (JMPTSW GR:$rb, GR:$rc)>;
def : Pat<(jmp_table_load_u32 i64:$rb, i32:$rc), (JMPTUW GR:$rb, GR:$rc)>;

//===----------------------------------------------------------------------===//
// Indirect jump/tail_call after load instruction
//===----------------------------------------------------------------------===//
let isTerminator = 1, isBarrier = 1, isBranch = 1, isIndirectBranch = 1, ra = 0 in {
  def JMPMI : MISC_RabcScale<opcode_jmpmi,
        (outs), (ins GR:$rb, GR:$rc, scale:$scale),
        !strconcat(opcode_jmpmi.mnem, " $rb, $rc, $scale"), []>;
}

def jmp_load_indexed_scaled_s64 : PatFrag<(ops node:$base, node:$index, node:$scale),
    (brind (iPTR (add node:$base, (i64 (sextloadi32 (add node:$base, (shl (i64 (sext node:$index)), node:$scale)))))))>;

def jmp_load_indexed_s64 : PatFrag<(ops node:$base, node:$index),
    (brind (iPTR (add node:$base, (i64 (sextloadi32 (add node:$base, (i64 (sext node:$index))))))))>;

def jmp_load_s64 : PatFrag<(ops node:$base),
    (brind (iPTR (add node:$base, (i64 (sextloadi32 node:$base)))))>;

def : Pat<(jmp_load_indexed_scaled_s64 iPTR:$rb, i32:$rc, scale:$scale), (JMPMI GR:$rb, GR:$rc, scale:$scale)>;
def : Pat<(jmp_load_indexed_s64        iPTR:$rb, i32:$rc              ), (JMPMI GR:$rb, GR:$rc, 0)>;
def : Pat<(jmp_load_s64                iPTR:$rb                       ), (JMPMI GR:$rb, (i64 gz), 0)>;

//===----------------------------------------------------------------------===//
// TailCall patterns
//===----------------------------------------------------------------------===//
def SDT_SPTailCall : SDTypeProfile<0, -1, [SDTCisVT<0, i64>]>;
def tailcall : SDNode<"PostriscISD::TAIL_CALL", SDT_SPTailCall,
                      [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue,
                       SDNPVariadic]>;

def : Pat<(tailcall  tglobaladdr:$addr), (JMP_TAIL  tglobaladdr:$addr)>;
def : Pat<(tailcall texternalsym:$addr), (JMP_TAIL texternalsym:$addr)>;

def : Pat<(tailcall (i64 (add i64:$rb, (shl i64:$rc, scale:$scale)))), (JMPR GR:$rb, GR:$rc, scale:$scale)>;
def : Pat<(tailcall (i64 (add i64:$rb,      i64:$rc               ))), (JMPR GR:$rb, GR:$rc, 0)>;
def : Pat<(tailcall           i64:$rb                               ), (JMPR GR:$rb, (i64 gz), 0)>;

//===----------------------------------------------------------------------===//
// Call Instructions
//===----------------------------------------------------------------------===//
let isCall = 1 in
{
  // call ip+offset
  def CALL     : PRIMARY_RaI28    <opcode_call, (outs GR:$ra), (ins calltarget:$imm, variable_ops), !strconcat(opcode_call.mnem,   " $ra, $imm"), [], IIC_jmp_or_call>;
  def CALL_EXT : PRIMARY_RaI28_ext<opcode_call, (outs GR:$ra), (ins calltarget:$imm, variable_ops), !strconcat(opcode_call.mnem, ".l $ra, $imm"), [], IIC_jmp_or_call>;

  // call base+index
  def CALLRI : MISC_Rabc<opcode_callri, (outs GR:$ra), (ins GR:$rb, GR:$rc, variable_ops), !strconcat(opcode_callri.mnem, " $ra, $rb, $rc"), [], IIC_jmp_or_call>;

  // call mem_iprel<iPTR>[ip+offset]
  def CALLPLT     : PRIMARY_RaI28    <opcode_callplt, (outs GR:$ra), (ins uimm28    :$imm, variable_ops), !strconcat(opcode_callplt.mnem,   " $ra, $imm"), [], IIC_jmp_or_call>;
  def CALLPLT_EXT : PRIMARY_RaI28_ext<opcode_callplt, (outs GR:$ra), (ins uimm28_ext:$imm, variable_ops), !strconcat(opcode_callplt.mnem, ".l $ra, $imm"), [], IIC_jmp_or_call>;

  // call mem<iPTR>[base+offset]
  def CALLMI : FUSED_Mid_Simm<opcode_callmi, (outs GR:$ra), (ins GR:$rb, mid_bin_imm:$imm, variable_ops), !strconcat(opcode_callmi.mnem, " $ra, $rb, $imm"), [], IIC_jmp_or_call>;

  // call base + mem<i32>[base + offset]
  def CALLRVT : FUSED_Mid_Simm<opcode_callrvt, (outs GR:$ra), (ins GR:$rb, mid_bin_imm:$imm, variable_ops), !strconcat(opcode_callrvt.mnem, " $ra, $rb, $imm"), [], IIC_jmp_or_call>;
}

//===----------------------------------------------------------------------===//
// Call patterns
//===----------------------------------------------------------------------===//
def SDT_SPCall : SDTypeProfile<1, -1 /*variable?*/, [SDTCisVT<0, i128 /*result*/>, SDTCisVT<1, i64>]>;
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
    def RETF     : RAOPX_RbI21    <opcode_retf, (outs), (ins uimm21    :$imm), !strconcat(opcode_retf.mnem,   " $imm"), [(retglue uimm21    :$imm)], IIC_jmp_or_call>;
    def RETF_EXT : RAOPX_RbI21_ext<opcode_retf, (outs), (ins uimm21_ext:$imm), !strconcat(opcode_retf.mnem, ".l $imm"), [(retglue uimm21_ext:$imm)], IIC_jmp_or_call>;
  }
  def RET : MISC_NoArgs<opcode_ret, (outs), (ins), []>;
}

// at least one alias - to not hurt about code changes
def : MnemonicAlias<"return", "ret">;

def MOV : MISC_Rab<opcode_mov, (outs GR:$ra), (ins GR:$rb), !strconcat(opcode_mov.mnem, " $ra, $rb"), []>;

def : Pat<(i64 (int_postrisc_stack_pointer)), (i64 sp)>;
def : Pat<(i64 (int_thread_pointer)), (i64 tp)>;

//===----------------------------------------------------------------------===//
// Load immediate
//===----------------------------------------------------------------------===//
let isMoveImm = 1 in {
  def LDI     : PRIMARY_RaI28    <opcode_ldi, (outs GR:$ra), (ins simm28    :$imm), !strconcat(opcode_ldi.mnem,   " $ra, $imm"), [(set i64:$ra, simm28    :$imm)]>;
  def LDI_EXT : PRIMARY_RaI28_ext<opcode_ldi, (outs GR:$ra), (ins simm28_ext:$imm), !strconcat(opcode_ldi.mnem, ".l $ra, $imm"), [(set i64:$ra, simm28_ext:$imm)]>;
}

let Constraints = "$rx = $ra" in {
  def LDIH     : PRIMARY_RaI28    <opcode_ldih, (outs GR:$ra), (ins GR:$rx, simm28    :$imm), !strconcat(opcode_ldih.mnem,   " $ra, $imm"), []>;
  def LDIH_EXT : PRIMARY_RaI28_ext<opcode_ldih, (outs GR:$ra), (ins GR:$rx, simm28_ext:$imm), !strconcat(opcode_ldih.mnem, ".l $ra, $imm"), []>;
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
// LDAN
//===----------------------------------------------------------------------===//
// def pr_lda_near : PatFrag<(ops node:$src1, node:$src2), (add node:$src1, (shl node:$src2, (i32 20)))>;

def LDAN : FUSED_Mid_Simm<opcode_ldan, (outs GR:$ra), (ins GR:$rb, mid_bin_imm:$imm, variable_ops),
                !strconcat(opcode_ldan.mnem, " $ra, $rb, $imm"), []>;

def lda_near_imm : PatLeaf<(imm), [{ return (N->getSExtValue() & 0xFFFFF) == 0 && isSextInt(N->getAPIntValue().ashr(20), 14); }]>;
def lda_near_imm_xform : SDNodeXForm<imm, [{ return getI64Imm((N->getSExtValue() >> 20), SDLoc(N)); }]>;

let AddedComplexity = 2 in { // force over ADDID
  def : Pat<(i64 (add i64:$base, lda_near_imm:$imm)), (LDAN GR:$base, (lda_near_imm_xform imm:$imm))>;
}

//===----------------------------------------------------------------------===//
// static/internal function addressing
//===----------------------------------------------------------------------===//
def LDARC     : PRIMARY_RaI28    <opcode_ldarc, (outs GR:$ra), (ins simm28    :$imm), !strconcat(opcode_ldarc.mnem,   " $ra, $imm"), []>;
def LDARC_EXT : PRIMARY_RaI28_ext<opcode_ldarc, (outs GR:$ra), (ins simm28_ext:$imm), !strconcat(opcode_ldarc.mnem, ".l $ra, $imm"), []>;

// global/external address should be properly wrapped to corresponding PCREL wrapper
def : Pat<(i64 (pcrel_code_wrapper        tglobaladdr:$addr)), (LDARC        tglobaladdr:$addr)>;
def : Pat<(i64 (pcrel_code_wrapper         tconstpool:$addr)), (LDARC         tconstpool:$addr)>;
def : Pat<(i64 (pcrel_code_wrapper       texternalsym:$addr)), (LDARC       texternalsym:$addr)>;
def : Pat<(i64 (pcrel_code_wrapper     tglobaltlsaddr:$addr)), (LDARC     tglobaltlsaddr:$addr)>;

def : Pat<(i64 (pcrel_code_wrapper_ext    tglobaladdr:$addr)), (LDARC_EXT    tglobaladdr:$addr)>;
def : Pat<(i64 (pcrel_code_wrapper_ext     tconstpool:$addr)), (LDARC_EXT     tconstpool:$addr)>;
def : Pat<(i64 (pcrel_code_wrapper_ext   texternalsym:$addr)), (LDARC_EXT   texternalsym:$addr)>;
def : Pat<(i64 (pcrel_code_wrapper_ext tglobaltlsaddr:$addr)), (LDARC_EXT tglobaltlsaddr:$addr)>;

//===----------------------------------------------------------------------===//
// static/internal global data addresses, constant pool entries
//===----------------------------------------------------------------------===//
def LDARD     : PRIMARY_RaI28    <opcode_ldard, (outs GR:$ra), (ins uimm28    :$imm), !strconcat(opcode_ldard.mnem,   " $ra, $imm"), []>;
def LDARD_EXT : PRIMARY_RaI28_ext<opcode_ldard, (outs GR:$ra), (ins uimm28_ext:$imm), !strconcat(opcode_ldard.mnem, ".l $ra, $imm"), []>;

def : Pat<(i64 (pcrel_data_wrapper        tglobaladdr:$addr)), (LDARD        tglobaladdr:$addr)>;
def : Pat<(i64 (pcrel_data_wrapper         tconstpool:$addr)), (LDARD         tconstpool:$addr)>;
def : Pat<(i64 (pcrel_data_wrapper       texternalsym:$addr)), (LDARD       texternalsym:$addr)>;
def : Pat<(i64 (pcrel_data_wrapper     tglobaltlsaddr:$addr)), (LDARD     tglobaltlsaddr:$addr)>;
def : Pat<(i64 (pcrel_data_wrapper         tjumptable:$addr)), (LDARD         tjumptable:$addr)>;

def : Pat<(i64 (pcrel_data_wrapper_ext    tglobaladdr:$addr)), (LDARD_EXT    tglobaladdr:$addr)>;
def : Pat<(i64 (pcrel_data_wrapper_ext     tconstpool:$addr)), (LDARD_EXT     tconstpool:$addr)>;
def : Pat<(i64 (pcrel_data_wrapper_ext   texternalsym:$addr)), (LDARD_EXT   texternalsym:$addr)>;
def : Pat<(i64 (pcrel_data_wrapper_ext tglobaltlsaddr:$addr)), (LDARD_EXT tglobaltlsaddr:$addr)>;
def : Pat<(i64 (pcrel_data_wrapper_ext     tjumptable:$addr)), (LDARD_EXT     tjumptable:$addr)>;

//===----------------------------------------------------------------------===//
// TLS addressing
//===----------------------------------------------------------------------===//
def : Pat<(add i64:$r, tglobaltlsaddr:$addr), (ADDID $r, tglobaltlsaddr:$addr)>;
def : Pat<(add i64:$Rs, (tls_offset_wrapper     tglobaltlsaddr:$addr)), (ADDID     i64:$Rs, tglobaltlsaddr:$addr)>;
def : Pat<(add i64:$Rs, (tls_offset_wrapper_ext tglobaltlsaddr:$addr)), (ADDID_EXT i64:$Rs, tglobaltlsaddr:$addr)>;
