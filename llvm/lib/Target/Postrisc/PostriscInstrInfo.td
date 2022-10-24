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

//===----------------------------------------------------------------------===//
// Instruction Class Templates
//===----------------------------------------------------------------------===//
multiclass MISC_R3<misc_opx opx, PatFrag OpNode, ValueType Tdst, ValueType Tsrc, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : MISC_Rabc<opx, (outs GR:$ra), (ins GR:$rb, GR:$rc),
         !strconcat(opx.mnem, " $ra, $rb, $rc"),
         [(set Tdst:$ra, (OpNode Tsrc:$rb, Tsrc:$rc))], itin>;
}

multiclass MISC_R2<misc_opx opx, PatFrags OpNode, ValueType Tdst, ValueType Tsrc, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : MISC_Rab<opx, (outs GR:$ra), (ins GR:$rb),
         !strconcat(opx.mnem, " $ra, $rb"),
         [(set Tdst:$ra, (OpNode Tsrc:$rb))], itin>;
}

multiclass PRIM_R2_IMM<opcode_opx opcode, PatFrag OpNode, ValueType Tdst, ValueType Tsrc,
  Operand immOp, Operand immOpExt, InstrItinClass itin = IIC_iu_instr>
{
  // Ra = Rb Op imm21
  def NAME : PRIMARY_RabI21<opcode, (outs GR:$ra), (ins GR:$rb, immOp:$imm),
                 !strconcat(opcode.mnem, " $ra, $rb, $imm"),
                 [(set Tdst:$ra, (OpNode Tsrc:$rb, immOp:$imm))],
                 itin>;

  // Ra = Rb Op imm21_ext
  def NAME # _EXT : PRIMARY_RabI21_ext<opcode, (outs GR:$ra), (ins GR:$rb, immOpExt:$imm),
                 !strconcat(opcode.mnem, ".l $ra, $rb, $imm"),
                 [(set Tdst:$ra, (OpNode Tsrc:$rb, immOpExt:$imm))],
                 itin>;
}

defm ADD_I64 : MISC_R3<opcode_add_i64,  pr_add,  i64, i64>;
defm ADD_I32 : MISC_R3<opcode_add_i32,  pr_add,  i32, i32>;
defm ADD_U32 : MISC_R3<opcode_add_u32,  pr_add,  i32, i32>;
defm SUB_I64 : MISC_R3<opcode_sub_i64,  pr_sub,  i64, i64>;
defm SUB_I32 : MISC_R3<opcode_sub_i32,  pr_sub,  i32, i32>;
defm SUB_U32 : MISC_R3<opcode_sub_u32,  pr_sub,  i32, i32>;
defm MUL_I64 : MISC_R3<opcode_mul_i64,  pr_mul,  i64, i64>;
defm MUL_I32 : MISC_R3<opcode_mul_i32,  pr_mul,  i32, i32>;
defm MUL_U32 : MISC_R3<opcode_mul_u32,  pr_mul,  i32, i32>;

defm ADD_I128 : MISC_R3<opcode_add_i128, pr_add,  i128, i128>;
defm SUB_I128 : MISC_R3<opcode_sub_i128, pr_sub,  i128, i128>;
defm MUL_I128 : MISC_R3<opcode_mul_i128, pr_mul,  i128, i128>;

//===----------------------------------------------------------------------===//
// extend add/sub/mul instructions for pre-trunc and post-(sign/zero) extension
//===----------------------------------------------------------------------===//
multiclass OP_SEXT<InstBase INSN, PatFrag OpNode> {
  def : Pat<(i64 (sext (OpNode i32:$rb, i32:$rc))), (INSN GR:$rb, GR:$rc)>;
  def : Pat<(i64 (sext (OpNode i32:$rb, (i32 (trunc i64:$rc))))), (INSN GR:$rb, GR:$rc)>;
  def : Pat<(i64 (sext (OpNode (i32 (trunc i64:$rb)), i32:$rc))), (INSN GR:$rb, GR:$rc)>;
}
defm : OP_SEXT<ADD_I32, pr_add>;
defm : OP_SEXT<SUB_I32, pr_sub>;
defm : OP_SEXT<MUL_I32, pr_mul>;

multiclass OP_ZEXT<InstBase INSN, PatFrag OpNode> {
  def : Pat<(i64 (zext (OpNode i32:$rb, i32:$rc))), (INSN GR:$rb, GR:$rc)>;
  def : Pat<(i64 (zext (OpNode i32:$rb, (i32 (trunc i64:$rc))))), (INSN GR:$rb, GR:$rc)>;
  def : Pat<(i64 (zext (OpNode (i32 (trunc i64:$rb)), i32:$rc))), (INSN GR:$rb, GR:$rc)>;
}
defm : OP_ZEXT<ADD_U32, pr_add>;
defm : OP_ZEXT<SUB_U32, pr_sub>;
defm : OP_ZEXT<MUL_U32, pr_mul>;

// absolute value
defm ABS_I32  : MISC_R2<opcode_abs_i32,  pr_abs, i32,  i32>;
defm ABS_I64  : MISC_R2<opcode_abs_i64,  pr_abs, i64,  i64>;
defm ABS_I128 : MISC_R2<opcode_abs_i128, pr_abs, i128, i128>;

// absolute difference
defm ABS_DIFF_I32  : MISC_R3<opcode_abs_diff_i32,  pr_absd,  i32,  i32>;
defm ABS_DIFF_I64  : MISC_R3<opcode_abs_diff_i64,  pr_absd,  i64,  i64>;
defm ABS_DIFF_I128 : MISC_R3<opcode_abs_diff_i128, pr_absd,  i128, i128>;

defm ADD_IMM_I64  : PRIM_R2_IMM<opcode_add_imm_i64,  pr_add,  i64, i64, simm21,    simm21_ext>;
defm SUBR_IMM_I64 : PRIM_R2_IMM<opcode_subr_imm_i64, pr_subr, i64, i64, simm21,    simm21_ext>;
defm ADD_IMM_I32  : PRIM_R2_IMM<opcode_add_imm_i32,  pr_add,  i32, i32, simm21i32, simm21i32_ext>;
defm ADD_IMM_U32  : PRIM_R2_IMM<opcode_add_imm_u32,  pr_add,  i32, i32, simm21i32, simm21i32_ext>;
defm SUBR_IMM_I32 : PRIM_R2_IMM<opcode_subr_imm_i32, pr_subr, i32, i32, simm21i32, simm21i32_ext>;
defm SUBR_IMM_U32 : PRIM_R2_IMM<opcode_subr_imm_u32, pr_subr, i32, i32, simm21i32, simm21i32_ext>;
defm MUL_IMM_I64  : PRIM_R2_IMM<opcode_mul_imm_i64,  pr_mul,  i64, i64, simm21,    simm21_ext>;
defm MUL_IMM_I32  : PRIM_R2_IMM<opcode_mul_imm_i32,  pr_mul,  i32, i32, simm21i32, simm21i32_ext>;
defm MUL_IMM_U32  : PRIM_R2_IMM<opcode_mul_imm_u32,  pr_mul,  i32, i32, uimm21i32, uimm21i32_ext>;

//===----------------------------------------------------------------------===//
// neg
//===----------------------------------------------------------------------===//
defm NEG_I32  : MISC_R2<opcode_neg_i32,  pr_neg, i32,  i32>;
defm NEG_I64  : MISC_R2<opcode_neg_i64,  pr_neg, i64,  i64>;
defm NEG_I128 : MISC_R2<opcode_neg_i128, pr_neg, i128, i128>;

// negation is also sext to a bigger types
def : Pat<(i64  (sext (pr_neg i32:$val))), (NEG_I32 i32:$val)>;
def : Pat<(i128 (sext (pr_neg i32:$val))), (NEG_I32 i32:$val)>;
def : Pat<(i128 (sext (pr_neg i64:$val))), (NEG_I64 i64:$val)>;

//===----------------------------------------------------------------------===//
// FrameIndex calculations
//===----------------------------------------------------------------------===//
def : Pat<(i64 AddrFI:$Rs), (ADD_IMM_I64 (i64 AddrFI:$Rs), 0)>;
def : Pat<(add (i64 AddrFI:$Rs), simm21:$imm), (ADD_IMM_I64 (i64 AddrFI:$Rs), simm21:$imm)>;
def : Pat<(add (i64 AddrFI:$Rs), simm21_ext:$imm), (ADD_IMM_I64_EXT (i64 AddrFI:$Rs), simm21_ext:$imm)>;

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
defm : OP_SEXT_IMM<ADD_IMM_I32,  ADD_IMM_I32_EXT,  pr_add>;
defm : OP_SEXT_IMM<SUBR_IMM_I32, SUBR_IMM_I32_EXT, pr_subr>;
defm : OP_SEXT_IMM<MUL_IMM_I32,  MUL_IMM_I32_EXT,  pr_mul>;

// i32 with unsigned immediate, post-zero-extension, pre-trunc
multiclass OP_ZEXT_IMM<InstBase INSN, InstBaseExt INSN_ext, PatFrag OpNode> {
  // i32 with post-zero-extension
  def : Pat<(i64 (zext (OpNode i32:$rb, uimm21i32    :$imm))), (INSN     GR:$rb, uimm21i32    :$imm)>;
  def : Pat<(i64 (zext (OpNode i32:$rb, uimm21i32_ext:$imm))), (INSN_ext GR:$rb, uimm21i32_ext:$imm)>;
  // i32 with pre-trunc and post-zero-extension
  def : Pat<(i64 (zext (OpNode (i32 (trunc i64:$rb)), uimm21i32    :$imm))), (INSN     GR:$rb, uimm21i32    :$imm)>;
  def : Pat<(i64 (zext (OpNode (i32 (trunc i64:$rb)), uimm21i32_ext:$imm))), (INSN_ext GR:$rb, uimm21i32_ext:$imm)>;
}
defm : OP_ZEXT_IMM<MUL_IMM_U32,  MUL_IMM_U32_EXT,  pr_mul>;

// i32 with signed immediate, post-zero-extension, pre-trunc
multiclass OP_ZEXT_SEXT_IMM<InstBase INSN, InstBaseExt INSN_ext, PatFrag OpNode> {
  // i32 with post-zero-extension
  def : Pat<(i64 (zext (OpNode i32:$rb, simm21i32    :$imm))), (INSN     GR:$rb, simm21i32    :$imm)>;
  def : Pat<(i64 (zext (OpNode i32:$rb, simm21i32_ext:$imm))), (INSN_ext GR:$rb, simm21i32_ext:$imm)>;
  // i32 with pre-trunc and post-zero-extension
  def : Pat<(i64 (zext (OpNode (i32 (trunc i64:$rb)), simm21i32    :$imm))), (INSN     GR:$rb, simm21i32    :$imm)>;
  def : Pat<(i64 (zext (OpNode (i32 (trunc i64:$rb)), simm21i32_ext:$imm))), (INSN_ext GR:$rb, simm21i32_ext:$imm)>;
}
defm : OP_ZEXT_SEXT_IMM<ADD_IMM_U32,  ADD_IMM_U32_EXT,  pr_add>;
defm : OP_ZEXT_SEXT_IMM<SUBR_IMM_U32, SUBR_IMM_U32_EXT, pr_subr>;

//===----------------------------------------------------------------------===//
// min/max
//===----------------------------------------------------------------------===//
def pr_smin : PatFrag<(ops node:$src1, node:$src2), (smin node:$src1, node:$src2)>;
def pr_umin : PatFrag<(ops node:$src1, node:$src2), (umin node:$src1, node:$src2)>;
def pr_smax : PatFrag<(ops node:$src1, node:$src2), (smax node:$src1, node:$src2)>;
def pr_umax : PatFrag<(ops node:$src1, node:$src2), (umax node:$src1, node:$src2)>;

defm MIN_I64 : MISC_R3<opcode_min_i64, pr_smin, i64, i64>;
defm MIN_U64 : MISC_R3<opcode_min_u64, pr_umin, i64, i64>;
defm MAX_I64 : MISC_R3<opcode_max_i64, pr_smax, i64, i64>;
defm MAX_U64 : MISC_R3<opcode_max_u64, pr_umax, i64, i64>;

defm MIN_I32 : MISC_R3<opcode_min_i32, pr_smin, i32, i32>;
defm MIN_U32 : MISC_R3<opcode_min_u32, pr_umin, i32, i32>;
defm MAX_I32 : MISC_R3<opcode_max_i32, pr_smax, i32, i32>;
defm MAX_U32 : MISC_R3<opcode_max_u32, pr_umax, i32, i32>;

defm MIN_I128 : MISC_R3<opcode_min_i128, pr_smin, i128, i128>;
defm MIN_U128 : MISC_R3<opcode_min_u128, pr_umin, i128, i128>;
defm MAX_I128 : MISC_R3<opcode_max_i128, pr_smax, i128, i128>;
defm MAX_U128 : MISC_R3<opcode_max_u128, pr_umax, i128, i128>;

defm MIN_IMM_I64 : PRIM_R2_IMM<opcode_min_imm_i64, pr_smin, i64, i64, simm21, simm21_ext>;
defm MAX_IMM_I64 : PRIM_R2_IMM<opcode_max_imm_i64, pr_smax, i64, i64, simm21, simm21_ext>;
defm MIN_IMM_U64 : PRIM_R2_IMM<opcode_min_imm_u64, pr_umin, i64, i64, uimm21, uimm21_ext>;
defm MAX_IMM_U64 : PRIM_R2_IMM<opcode_max_imm_u64, pr_umax, i64, i64, uimm21, uimm21_ext>;

defm MIN_IMM_I32 : PRIM_R2_IMM<opcode_min_imm_i32, pr_smin, i32, i32, simm21i32, simm21i32_ext>;
defm MAX_IMM_I32 : PRIM_R2_IMM<opcode_max_imm_i32, pr_smax, i32, i32, simm21i32, simm21i32_ext>;
defm MIN_IMM_U32 : PRIM_R2_IMM<opcode_min_imm_u32, pr_umin, i32, i32, uimm21i32, uimm21i32_ext>;
defm MAX_IMM_U32 : PRIM_R2_IMM<opcode_max_imm_u32, pr_umax, i32, i32, uimm21i32, uimm21i32_ext>;

//===----------------------------------------------------------------------===//
// fused ALU operations
//===----------------------------------------------------------------------===//
def pr_addadd  : PatFrag<(ops node:$src1, node:$src2, node:$src3), (add (add node:$src1, node:$src2), node:$src3)>;
def pr_addsub  : PatFrag<(ops node:$src1, node:$src2, node:$src3), (sub (add node:$src1, node:$src2), node:$src3)>;
def pr_subsub  : PatFrag<(ops node:$src1, node:$src2, node:$src3), (sub node:$src1, (add node:$src2, node:$src3))>;
def pr_muladd  : PatFrag<(ops node:$src1, node:$src2, node:$src3), (add (mul node:$src1, node:$src2), node:$src3)>;
def pr_mulsub  : PatFrag<(ops node:$src1, node:$src2, node:$src3), (sub (mul node:$src1, node:$src2), node:$src3)>;
def pr_mulsubr : PatFrag<(ops node:$src1, node:$src2, node:$src3), (sub node:$src3, (mul node:$src1, node:$src2))>;

defm ADD_ADD_I64 : FUSED_R4<opcode_add_add_i64,  pr_addadd,  i64>;
defm ADD_SUB_I64 : FUSED_R4<opcode_add_sub_i64,  pr_addsub,  i64>;
defm SUB_SUB_I64 : FUSED_R4<opcode_sub_sub_i64,  pr_subsub,  i64>;

defm MULADD  : FMA_R4<opcode_mul_add,  pr_muladd,  i64>;
defm MULSUB  : FMA_R4<opcode_mul_sub,  pr_mulsub,  i64>;
defm MULSUBR : FMA_R4<opcode_mul_subr, pr_mulsubr, i64>;

//===----------------------------------------------------------------------===//
/// Compare reg-reg instructions
//===----------------------------------------------------------------------===//
defm CMP_EQ_I32 : MISC_R3<opcode_cmp_eq_i32, seteq,  i1, i32>;
defm CMP_NE_I32 : MISC_R3<opcode_cmp_ne_i32, setne,  i1, i32>;
defm CMP_LT_I32 : MISC_R3<opcode_cmp_lt_i32, setlt,  i1, i32>;
defm CMP_LT_U32 : MISC_R3<opcode_cmp_lt_u32, setult, i1, i32>;
defm CMP_GE_I32 : MISC_R3<opcode_cmp_ge_i32, setge,  i1, i32>;
defm CMP_GE_U32 : MISC_R3<opcode_cmp_ge_u32, setuge, i1, i32>;

defm CMP_EQ_I64 : MISC_R3<opcode_cmp_eq_i64, seteq,  i1, i64>;
defm CMP_NE_I64 : MISC_R3<opcode_cmp_ne_i64, setne,  i1, i64>;
defm CMP_LT_I64 : MISC_R3<opcode_cmp_lt_i64, setlt,  i1, i64>;
defm CMP_LT_U64 : MISC_R3<opcode_cmp_lt_u64, setult, i1, i64>;
defm CMP_GE_I64 : MISC_R3<opcode_cmp_ge_i64, setge,  i1, i64>;
defm CMP_GE_U64 : MISC_R3<opcode_cmp_ge_u64, setuge, i1, i64>;

defm CMP_EQ_I128 : MISC_R3<opcode_cmp_eq_i128, seteq,  i1, i128>;
defm CMP_NE_I128 : MISC_R3<opcode_cmp_ne_i128, setne,  i1, i128>;
defm CMP_LT_I128 : MISC_R3<opcode_cmp_lt_i128, setlt,  i1, i128>;
defm CMP_LT_U128 : MISC_R3<opcode_cmp_lt_u128, setult, i1, i128>;
defm CMP_GE_I128 : MISC_R3<opcode_cmp_ge_i128, setge,  i1, i128>;
defm CMP_GE_U128 : MISC_R3<opcode_cmp_ge_u128, setuge, i1, i128>;

multiclass CompareSwappedArgs<InstBase LT, InstBase GE, InstBase LTU, InstBase GEU, ValueType Ty>
{
  // GT(c,b) via LT(b,c)
  def : Pat<(i1 (setgt  Ty:$rc, Ty:$rb)), (LT  GR:$rb, GR:$rc)>;
  def : Pat<(i1 (setugt Ty:$rc, Ty:$rb)), (LTU GR:$rb, GR:$rc)>;
  // LE(c,b) via GE(b,c)
  def : Pat<(i1 (setle  Ty:$rc, Ty:$rb)), (GE  GR:$rb, GR:$rc)>;
  def : Pat<(i1 (setule Ty:$rc, Ty:$rb)), (GEU GR:$rb, GR:$rc)>;
}
defm : CompareSwappedArgs<CMP_LT_I32,  CMP_GE_I32,  CMP_LT_U32,  CMP_GE_U32,  i32>;
defm : CompareSwappedArgs<CMP_LT_I64,  CMP_GE_I64,  CMP_LT_U64,  CMP_GE_U64,  i64>;
defm : CompareSwappedArgs<CMP_LT_I128, CMP_GE_I128, CMP_LT_U128, CMP_GE_U128, i128>;

//===----------------------------------------------------------------------===//
/// Compare reg-imm instructions
//===----------------------------------------------------------------------===//
defm CMP_EQ_IMM_I32 : PRIM_R2_IMM<opcode_cmp_eq_imm_i32, seteq,  i1, i32, simm21i32, simm21i32_ext>;
defm CMP_NE_IMM_I32 : PRIM_R2_IMM<opcode_cmp_ne_imm_i32, setne,  i1, i32, simm21i32, simm21i32_ext>;
defm CMP_LT_IMM_I32 : PRIM_R2_IMM<opcode_cmp_lt_imm_i32, setlt,  i1, i32, simm21i32, simm21i32_ext>;
defm CMP_LT_IMM_U32 : PRIM_R2_IMM<opcode_cmp_lt_imm_u32, setult, i1, i32, uimm21i32, uimm21i32_ext>;
defm CMP_GE_IMM_I32 : PRIM_R2_IMM<opcode_cmp_ge_imm_i32, setge,  i1, i32, simm21i32, simm21i32_ext>;
defm CMP_GE_IMM_U32 : PRIM_R2_IMM<opcode_cmp_ge_imm_u32, setuge, i1, i32, uimm21i32, uimm21i32_ext>;

defm CMP_EQ_IMM_I64 : PRIM_R2_IMM<opcode_cmp_eq_imm_i64, seteq,  i1, i64, simm21, simm21_ext>;
defm CMP_NE_IMM_I64 : PRIM_R2_IMM<opcode_cmp_ne_imm_i64, setne,  i1, i64, simm21, simm21_ext>;
defm CMP_LT_IMM_I64 : PRIM_R2_IMM<opcode_cmp_lt_imm_i64, setlt,  i1, i64, simm21, simm21_ext>;
defm CMP_LT_IMM_U64 : PRIM_R2_IMM<opcode_cmp_lt_imm_u64, setult, i1, i64, uimm21, uimm21_ext>;
defm CMP_GE_IMM_I64 : PRIM_R2_IMM<opcode_cmp_ge_imm_i64, setge,  i1, i64, simm21, simm21_ext>;
defm CMP_GE_IMM_U64 : PRIM_R2_IMM<opcode_cmp_ge_imm_u64, setuge, i1, i64, uimm21, uimm21_ext>;

defm CMP_EQ_IMM_I128 : PRIM_R2_IMM<opcode_cmp_eq_imm_i128, seteq,  i1, i128, simm21i128, simm21i128_ext>;
defm CMP_NE_IMM_I128 : PRIM_R2_IMM<opcode_cmp_ne_imm_i128, setne,  i1, i128, simm21i128, simm21i128_ext>;
defm CMP_LT_IMM_I128 : PRIM_R2_IMM<opcode_cmp_lt_imm_i128, setlt,  i1, i128, simm21i128, simm21i128_ext>;
defm CMP_LT_IMM_U128 : PRIM_R2_IMM<opcode_cmp_lt_imm_u128, setult, i1, i128, uimm21i128, uimm21i128_ext>;
defm CMP_GE_IMM_I128 : PRIM_R2_IMM<opcode_cmp_ge_imm_i128, setge,  i1, i128, simm21i128, simm21i128_ext>;
defm CMP_GE_IMM_U128 : PRIM_R2_IMM<opcode_cmp_ge_imm_u128, setuge, i1, i128, uimm21i128, uimm21i128_ext>;

multiclass CompareSwappedArgsImm<InstBase LT, InstBase LTU, InstBase GE, InstBase GEU, ValueType Ty, Operand simmOp, Operand uimmOp>
{
  // GT(imm,r) via LT(r,imm)
  def : Pat<(i1 (setgt  simmOp:$imm, Ty:$rb)), (LT  GR:$rb, simmOp:$imm)>;
  def : Pat<(i1 (setugt uimmOp:$imm, Ty:$rb)), (LTU GR:$rb, uimmOp:$imm)>;
  // LT(imm,r) via GE(r,imm)
  def : Pat<(i1 (setle  simmOp:$imm, Ty:$rb)), (GE  GR:$rb, simmOp:$imm)>;
  def : Pat<(i1 (setule uimmOp:$imm, Ty:$rb)), (GEU GR:$rb, uimmOp:$imm)>;
}
defm : CompareSwappedArgsImm<CMP_LT_IMM_I32,  CMP_LT_IMM_U32,  CMP_GE_IMM_I32,  CMP_GE_IMM_U32,  i32,  simm21i32,  uimm21i32>;
defm : CompareSwappedArgsImm<CMP_LT_IMM_I64,  CMP_LT_IMM_U64,  CMP_GE_IMM_I64,  CMP_GE_IMM_U64,  i64,  simm21i64,  uimm21i64>;
defm : CompareSwappedArgsImm<CMP_LT_IMM_I128, CMP_LT_IMM_U128, CMP_GE_IMM_I128, CMP_GE_IMM_U128, i128, simm21i128, uimm21i128>;

multiclass CompareSwappedArgsImmExt<InstBaseExt LT, InstBaseExt LTU, InstBaseExt GE, InstBaseExt GEU, ValueType Ty, Operand simmOp, Operand uimmOp>
{
  // GT(imm,r) via LT(r,imm)
  def : Pat<(i1 (setgt  simmOp:$imm, Ty:$rb)), (LT  GR:$rb, simmOp:$imm)>;
  def : Pat<(i1 (setugt uimmOp:$imm, Ty:$rb)), (LTU GR:$rb, uimmOp:$imm)>;
  // LT(imm,r) via GE(r,imm)
  def : Pat<(i1 (setlt  simmOp:$imm, Ty:$rb)), (GE  GR:$rb, simmOp:$imm)>;
  def : Pat<(i1 (setult uimmOp:$imm, Ty:$rb)), (GEU GR:$rb, uimmOp:$imm)>;
}
defm : CompareSwappedArgsImmExt<CMP_LT_IMM_I32_EXT,  CMP_LT_IMM_U32_EXT,  CMP_GE_IMM_I32_EXT,  CMP_GE_IMM_U32_EXT,  i32,  simm21i32_ext,   uimm21i32_ext>;
defm : CompareSwappedArgsImmExt<CMP_LT_IMM_I64_EXT,  CMP_LT_IMM_U64_EXT,  CMP_GE_IMM_I64_EXT,  CMP_GE_IMM_U64_EXT,  i64,  simm21_ext,      uimm21_ext>;
defm : CompareSwappedArgsImmExt<CMP_LT_IMM_I128_EXT, CMP_LT_IMM_U128_EXT, CMP_GE_IMM_I128_EXT, CMP_GE_IMM_U128_EXT, i128, simm21i128_ext,  uimm21i128_ext>;

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
defm : CompareSimmPlus32<CMP_LT_IMM_I32,  CMP_LT_IMM_I32_EXT,   setle, i32,  simm21_plus1, simm21_ext_plus1>;
defm : CompareSimmPlus64<CMP_LT_IMM_I64,  CMP_LT_IMM_I64_EXT,   setle, i64,  simm21_plus1, simm21_ext_plus1>;
defm : CompareSimmPlus64<CMP_LT_IMM_I128, CMP_LT_IMM_I128_EXT,  setle, i128, simm21_plus1, simm21_ext_plus1>;

defm : CompareUimmPlus32<CMP_LT_IMM_U32,  CMP_LT_IMM_U32_EXT,  setule, i32,  uimm21_plus1, uimm21_ext_plus1>;
defm : CompareUimmPlus64<CMP_LT_IMM_U64,  CMP_LT_IMM_U64_EXT,  setule, i64,  uimm21_plus1, uimm21_ext_plus1>;
defm : CompareUimmPlus64<CMP_LT_IMM_U128, CMP_LT_IMM_U128_EXT, setule, i128, uimm21_plus1, uimm21_ext_plus1>;

// "> 15" ==> ">= 16"
defm : CompareSimmPlus32<CMP_GE_IMM_I32,  CMP_GE_IMM_I32_EXT,   setgt, i32,  simm21_plus1, simm21_ext_plus1>;
defm : CompareSimmPlus64<CMP_GE_IMM_I64,  CMP_GE_IMM_I64_EXT,   setgt, i64,  simm21_plus1, simm21_ext_plus1>;
defm : CompareSimmPlus64<CMP_GE_IMM_I128, CMP_GE_IMM_I128_EXT,  setgt, i128, simm21_plus1, simm21_ext_plus1>;

defm : CompareUimmPlus32<CMP_GE_IMM_U32,  CMP_GE_IMM_U32_EXT,  setugt, i32,  uimm21_plus1, uimm21_ext_plus1>;
defm : CompareUimmPlus64<CMP_GE_IMM_U64,  CMP_GE_IMM_U64_EXT,  setugt, i64,  uimm21_plus1, uimm21_ext_plus1>;
defm : CompareUimmPlus64<CMP_GE_IMM_U128, CMP_GE_IMM_U128_EXT, setugt, i128, uimm21_plus1, uimm21_ext_plus1>;

//===----------------------------------------------------------------------===//
// Divide
//===----------------------------------------------------------------------===//
def pr_sdiv : PatFrag<(ops node:$src1, node:$src2), (sdiv node:$src1, node:$src2)>;
def pr_udiv : PatFrag<(ops node:$src1, node:$src2), (udiv node:$src1, node:$src2)>;
def pr_srem : PatFrag<(ops node:$src1, node:$src2), (srem node:$src1, node:$src2)>;
def pr_urem : PatFrag<(ops node:$src1, node:$src2), (urem node:$src1, node:$src2)>;

// Division can trap.
let hasSideEffects = 1 in {
  defm DIV_I64 : MISC_R3<opcode_div_i64, pr_sdiv, i64, i64>;
  defm DIV_U64 : MISC_R3<opcode_div_u64, pr_udiv, i64, i64>;
  defm REM_I64 : MISC_R3<opcode_rem_i64, pr_srem, i64, i64>;
  defm REM_U64 : MISC_R3<opcode_rem_u64, pr_urem, i64, i64>;

  defm DIV_I32 : MISC_R3<opcode_div_i32, pr_sdiv, i32, i32>;
  defm DIV_U32 : MISC_R3<opcode_div_u32, pr_udiv, i32, i32>;
  defm REM_I32 : MISC_R3<opcode_rem_i32, pr_srem, i32, i32>;
  defm REM_U32 : MISC_R3<opcode_rem_u32, pr_urem, i32, i32>;

  defm DIV_I128 : MISC_R3<opcode_div_i128, pr_sdiv, i128, i128>;
  defm DIV_U128 : MISC_R3<opcode_div_u128, pr_udiv, i128, i128>;
  defm REM_I128 : MISC_R3<opcode_rem_i128, pr_srem, i128, i128>;
  defm REM_U128 : MISC_R3<opcode_rem_u128, pr_urem, i128, i128>;

  defm DIV_IMM_I64 : PRIM_R2_IMM<opcode_div_imm_i64, pr_sdiv, i64, i64, simm21, simm21_ext>;
  defm DIV_IMM_U64 : PRIM_R2_IMM<opcode_div_imm_u64, pr_udiv, i64, i64, uimm21, uimm21_ext>;
  defm REM_IMM_I64 : PRIM_R2_IMM<opcode_rem_imm_i64, pr_srem, i64, i64, simm21, simm21_ext>;
  defm REM_IMM_U64 : PRIM_R2_IMM<opcode_rem_imm_u64, pr_urem, i64, i64, uimm21, uimm21_ext>;

  defm DIV_IMM_I32 : PRIM_R2_IMM<opcode_div_imm_i32, pr_sdiv, i32, i32, simm21i32, simm21i32_ext>;
  defm DIV_IMM_U32 : PRIM_R2_IMM<opcode_div_imm_u32, pr_udiv, i32, i32, uimm21i32, uimm21i32_ext>;
  defm REM_IMM_I32 : PRIM_R2_IMM<opcode_rem_imm_i32, pr_srem, i32, i32, simm21i32, simm21i32_ext>;
  defm REM_IMM_U32 : PRIM_R2_IMM<opcode_rem_imm_u32, pr_urem, i32, i32, uimm21i32, uimm21i32_ext>;
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
  def JMP_R : MISC_RabcScale<opcode_jmp_r, (outs), (ins GR:$rb, GR:$rc, scale:$scale),
                             !strconcat(opcode_jmp_r.mnem, " $rb, $rc, $scale"), []>;
}

def : Pat<(brind (i64 (add i64:$rb, (shl i64:$rc, scale:$scale)))), (JMP_R GR:$rb, GR:$rc, scale:$scale)>;
def : Pat<(brind (i64 (add i64:$rb,      i64:$rc               ))), (JMP_R GR:$rb, GR:$rc, 0)>;
def : Pat<(brind           i64:$rb                               ), (JMP_R GR:$rb, (i64 gz), 0)>;

//===----------------------------------------------------------------------===//
// Indirect jump table
//===----------------------------------------------------------------------===//
let isTerminator = 1, isBarrier = 1, isBranch = 1, isIndirectBranch = 1, ra = 0 in {
  def JMP_T    : MISC_Rabc<opcode_jmp_t,     (outs), (ins GR:$rb, GR:$rc), !strconcat(opcode_jmp_t.mnem, " $rb, $rc"), []>;
  def JMP_T_WS : MISC_Rabc<opcode_jmp_t_i32, (outs), (ins GR:$rb, GR:$rc), !strconcat(opcode_jmp_t_i32.mnem, " $rb, $rc"), []>;
  def JMP_T_WZ : MISC_Rabc<opcode_jmp_t_u32, (outs), (ins GR:$rb, GR:$rc), !strconcat(opcode_jmp_t_u32.mnem, " $rb, $rc"), []>;
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
  def JMP_MI : MISC_RabcScale<opcode_jmp_mi,
        (outs), (ins GR:$rb, GR:$rc, scale:$scale),
        !strconcat(opcode_jmp_mi.mnem, " $rb, $rc, $scale"), []>;
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
  def CALL     : PRIMARY_RaI28    <opcode_call, (outs GR:$ra), (ins calltarget:$imm, variable_ops), !strconcat(opcode_call.mnem,   " $ra, $imm"), [], IIC_jmp_or_call>;
  def CALL_EXT : PRIMARY_RaI28_ext<opcode_call, (outs GR:$ra), (ins calltarget:$imm, variable_ops), !strconcat(opcode_call.mnem, ".l $ra, $imm"), [], IIC_jmp_or_call>;

  // call base+index
  def CALL_RI : MISC_Rabc<opcode_call_ri, (outs GR:$ra), (ins GR:$rb, GR:$rc, variable_ops), !strconcat(opcode_call_ri.mnem, " $ra, $rb, $rc"), [], IIC_jmp_or_call>;

  // call mem<iPTR>[ip+offset]
  def CALL_PLT     : PRIMARY_RaI28    <opcode_call_plt, (outs GR:$ra), (ins simm28    :$imm, variable_ops), !strconcat(opcode_call_plt.mnem,   " $ra, $imm"), [], IIC_jmp_or_call>;
  def CALL_PLT_EXT : PRIMARY_RaI28_ext<opcode_call_plt, (outs GR:$ra), (ins simm28_ext:$imm, variable_ops), !strconcat(opcode_call_plt.mnem, ".l $ra, $imm"), [], IIC_jmp_or_call>;

  // call mem<iPTR>[base+offset]
  def CALL_MI : FUSED_Mid_Simm<opcode_call_mi, (outs GR:$ra), (ins GR:$rb, mid_bin_imm:$imm, variable_ops), !strconcat(opcode_call_mi.mnem, " $ra, $rb, $imm"), [], IIC_jmp_or_call>;

  // call base + mem<i32>[base + offset]
  def CALL_RVT : FUSED_Mid_Simm<opcode_call_rvt, (outs GR:$ra), (ins GR:$rb, mid_bin_imm:$imm, variable_ops), !strconcat(opcode_call_rvt.mnem, " $ra, $rb, $imm"), [], IIC_jmp_or_call>;
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
  def LD_IMM     : PRIMARY_RaI28    <opcode_ld_imm, (outs GR:$ra), (ins simm28    :$imm), !strconcat(opcode_ld_imm.mnem,   " $ra, $imm"), [(set i64:$ra, simm28    :$imm)]>;
  def LD_IMM_EXT : PRIMARY_RaI28_ext<opcode_ld_imm, (outs GR:$ra), (ins simm28_ext:$imm), !strconcat(opcode_ld_imm.mnem, ".l $ra, $imm"), [(set i64:$ra, simm28_ext:$imm)]>;
}

let Constraints = "$rx = $ra" in {
  def LD_IMM_HIGH     : PRIMARY_RaI28    <opcode_ld_imm_high, (outs GR:$ra), (ins GR:$rx, simm28    :$imm), !strconcat(opcode_ld_imm_high.mnem,   " $ra, $imm"), []>;
  def LD_IMM_HIGH_EXT : PRIMARY_RaI28_ext<opcode_ld_imm_high, (outs GR:$ra), (ins GR:$rx, simm28_ext:$imm), !strconcat(opcode_ld_imm_high.mnem, ".l $ra, $imm"), []>;
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
def : Pat<(i32 simm28x:$val), (LD_IMM (cvt64 $val))>;
def : Pat<(i64 simm28x:$val), (LD_IMM $val)>;
def : Pat<(i128 simm28x:$val), (LD_IMM (cvt128 $val))>;

// i32 big signed immediates may be materialized by ldi.l
def simm32x : PatLeaf<(imm), [{ return isSextInt(N->getAPIntValue(), 32); }]>;
def : Pat<(i32 simm32x:$val), (LD_IMM_EXT (cvt64 $val))>;

// i32 big unsigned immediates may be also materialized by ldi.l
def uimm32x : PatLeaf<(imm), [{ return isSextInt(N->getAPIntValue(), 32); }]>;
def : Pat<(i32 uimm32x:$val), (LD_IMM_EXT (cvt64 $val))>;

// i64 big immediates may be materialized by ldi.l
def simm64x : PatLeaf<(imm), [{ return isSextInt(N->getAPIntValue(), 64); }]>;
def : Pat<(i64 simm64x:$val), (LD_IMM_EXT $val)>;
def : Pat<(i128 simm64x:$val), (LD_IMM_EXT (cvt128 $val))>;


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

def : Pat<(i128 simm128x:$val), (LD_IMM_HIGH_EXT (LD_IMM_EXT (cvt128lo $val)), (cvt128hi $val))>;

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
def LDA_R     : PRIMARY_RaI28    <opcode_lda_r, (outs GR:$ra), (ins simm28    :$imm), !strconcat(opcode_lda_r.mnem,   " $ra, $imm"), []>;
def LDA_R_EXT : PRIMARY_RaI28_ext<opcode_lda_r, (outs GR:$ra), (ins simm28_ext:$imm), !strconcat(opcode_lda_r.mnem, ".l $ra, $imm"), []>;

// global/external address should be properly wrapped to corresponding PCREL wrapper
def : Pat<(i64 (pcrel_code_wrapper        tglobaladdr:$addr)), (LDA_R        tglobaladdr:$addr)>;
def : Pat<(i64 (pcrel_code_wrapper         tconstpool:$addr)), (LDA_R         tconstpool:$addr)>;
def : Pat<(i64 (pcrel_code_wrapper       texternalsym:$addr)), (LDA_R       texternalsym:$addr)>;
def : Pat<(i64 (pcrel_code_wrapper     tglobaltlsaddr:$addr)), (LDA_R     tglobaltlsaddr:$addr)>;

def : Pat<(i64 (pcrel_code_wrapper_ext    tglobaladdr:$addr)), (LDA_R_EXT    tglobaladdr:$addr)>;
def : Pat<(i64 (pcrel_code_wrapper_ext     tconstpool:$addr)), (LDA_R_EXT     tconstpool:$addr)>;
def : Pat<(i64 (pcrel_code_wrapper_ext   texternalsym:$addr)), (LDA_R_EXT   texternalsym:$addr)>;
def : Pat<(i64 (pcrel_code_wrapper_ext tglobaltlsaddr:$addr)), (LDA_R_EXT tglobaltlsaddr:$addr)>;

//===----------------------------------------------------------------------===//
// static/internal global data addresses, constant pool entries
//===----------------------------------------------------------------------===//
def LDA_IPREL     : PRIMARY_RaI28    <opcode_lda_iprel, (outs GR:$ra), (ins uimm28    :$imm), !strconcat(opcode_lda_iprel.mnem,   " $ra, $imm"), []>;
def LDA_IPREL_EXT : PRIMARY_RaI28_ext<opcode_lda_iprel, (outs GR:$ra), (ins uimm28_ext:$imm), !strconcat(opcode_lda_iprel.mnem, ".l $ra, $imm"), []>;

def : Pat<(i64 (pcrel_data_wrapper        tglobaladdr:$addr)), (LDA_IPREL        tglobaladdr:$addr)>;
def : Pat<(i64 (pcrel_data_wrapper         tconstpool:$addr)), (LDA_IPREL         tconstpool:$addr)>;
def : Pat<(i64 (pcrel_data_wrapper       texternalsym:$addr)), (LDA_IPREL       texternalsym:$addr)>;
def : Pat<(i64 (pcrel_data_wrapper     tglobaltlsaddr:$addr)), (LDA_IPREL     tglobaltlsaddr:$addr)>;
def : Pat<(i64 (pcrel_data_wrapper         tjumptable:$addr)), (LDA_IPREL         tjumptable:$addr)>;

def : Pat<(i64 (pcrel_data_wrapper_ext    tglobaladdr:$addr)), (LDA_IPREL_EXT    tglobaladdr:$addr)>;
def : Pat<(i64 (pcrel_data_wrapper_ext     tconstpool:$addr)), (LDA_IPREL_EXT     tconstpool:$addr)>;
def : Pat<(i64 (pcrel_data_wrapper_ext   texternalsym:$addr)), (LDA_IPREL_EXT   texternalsym:$addr)>;
def : Pat<(i64 (pcrel_data_wrapper_ext tglobaltlsaddr:$addr)), (LDA_IPREL_EXT tglobaltlsaddr:$addr)>;
def : Pat<(i64 (pcrel_data_wrapper_ext     tjumptable:$addr)), (LDA_IPREL_EXT     tjumptable:$addr)>;

//===----------------------------------------------------------------------===//
// TLS addressing
//===----------------------------------------------------------------------===//
def : Pat<(add i64:$r, tglobaltlsaddr:$addr), (ADD_IMM_I64 $r, tglobaltlsaddr:$addr)>;
def : Pat<(add i64:$Rs, (tls_offset_wrapper     tglobaltlsaddr:$addr)), (ADD_IMM_I64     i64:$Rs, tglobaltlsaddr:$addr)>;
def : Pat<(add i64:$Rs, (tls_offset_wrapper_ext tglobaltlsaddr:$addr)), (ADD_IMM_I64_EXT i64:$Rs, tglobaltlsaddr:$addr)>;
