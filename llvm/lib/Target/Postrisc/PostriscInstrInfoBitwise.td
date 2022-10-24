//===---- PostriscInstrInfoBitwise.td - Target Description for Postrisc ---===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains instruction formats, definitions and patterns needed for
// bitwise instructions on POSTRISC.
// bitwise ops are same for i1/i32/i64/i128/vector
//
//===----------------------------------------------------------------------===//

def pr_and  : PatFrag<(ops node:$src1, node:$src2), (and node:$src1, node:$src2)>;
def pr_or   : PatFrag<(ops node:$src1, node:$src2), (or  node:$src1, node:$src2)>;
def pr_xor  : PatFrag<(ops node:$src1, node:$src2), (xor node:$src1, node:$src2)>;
def pr_nand : PatFrag<(ops node:$src1, node:$src2), (not (and node:$src1, node:$src2))>;
def pr_nor  : PatFrag<(ops node:$src1, node:$src2), (not (or  node:$src1, node:$src2))>;
def pr_xnor : PatFrag<(ops node:$src1, node:$src2), (not (xor node:$src1, node:$src2))>;
def pr_andn : PatFrag<(ops node:$src1, node:$src2), (and (not node:$src1), node:$src2)>;
def pr_orn  : PatFrag<(ops node:$src1, node:$src2), (or  (not node:$src1), node:$src2)>;

multiclass MISC_R3_BITWISE<misc_opx opx, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : MISC_Rabc<opx, (outs GR:$ra), (ins GR:$rb, GR:$rc), !strconcat(opx.mnem, "\t$ra, $rb, $rc"), [], itin>;
}

defm AND  : MISC_R3_BITWISE<misc_opx_and>;
defm OR   : MISC_R3_BITWISE<misc_opx_or>;
defm XOR  : MISC_R3_BITWISE<misc_opx_xor>;
defm NAND : MISC_R3_BITWISE<misc_opx_nand>;
defm NOR  : MISC_R3_BITWISE<misc_opx_nor>;
defm XNOR : MISC_R3_BITWISE<misc_opx_xnor>;
defm ANDN : MISC_R3_BITWISE<misc_opx_andn>;
defm ORN  : MISC_R3_BITWISE<misc_opx_orn>;

// not rd -> xnor rd, %rd, rd
//def : InstAlias<"not\t$ra", (XNOR GR:$ra, GR:$ra, gz), 0>;
// not reg, rd -> xnor reg, %g0, rd
//def : InstAlias<"not\t$ra, $rb", (XNOR GR:$ra, GR:$rb, gz), 0>;
// clr rd -> or %g0, %g0, rd
//def : InstAlias<"clr\t$rd", (XOR GR:$rd, GR:$rd, GR:$rd), 0>;

multiclass R3_BITWISE_PATS<ValueType Ty>
{
  def : Pat<(pr_and  Ty:$rb, Ty:$rc), (AND  GR:$rb, GR:$rc)>;
  def : Pat<(pr_or   Ty:$rb, Ty:$rc), (OR   GR:$rb, GR:$rc)>;
  def : Pat<(pr_xor  Ty:$rb, Ty:$rc), (XOR  GR:$rb, GR:$rc)>;
  def : Pat<(pr_nand Ty:$rb, Ty:$rc), (NAND GR:$rb, GR:$rc)>;
  def : Pat<(pr_nor  Ty:$rb, Ty:$rc), (NOR  GR:$rb, GR:$rc)>;
  def : Pat<(pr_xnor Ty:$rb, Ty:$rc), (XNOR GR:$rb, GR:$rc)>;
  def : Pat<(pr_andn Ty:$rb, Ty:$rc), (ANDN GR:$rb, GR:$rc)>;
  def : Pat<(pr_orn  Ty:$rb, Ty:$rc), (ORN  GR:$rb, GR:$rc)>;
}

defm : R3_BITWISE_PATS<i32>;
defm : R3_BITWISE_PATS<i64>;
defm : R3_BITWISE_PATS<i128>;
defm : R3_BITWISE_PATS<v16i8>;
defm : R3_BITWISE_PATS<v8i16>;
defm : R3_BITWISE_PATS<v4i32>;
defm : R3_BITWISE_PATS<v2i64>;

// nand, nor, xnor, andn, orn - aren't used for i1, because extend ones outside first bit
def : Pat<(pr_and  i1:$rb, i1:$rc), (AND  GR:$rb, GR:$rc)>;
def : Pat<(pr_or   i1:$rb, i1:$rc), (OR   GR:$rb, GR:$rc)>;
def : Pat<(pr_xor  i1:$rb, i1:$rc), (XOR  GR:$rb, GR:$rc)>;

//===----------------------------------------------------------------------===//
// bitwise reg-imm
//===----------------------------------------------------------------------===//
def simm21i128_xform : SDNodeXForm<imm, [{
  return getI64Imm(N->getSExtValue(), SDLoc(N));
}]>;
def simm21i128 : Operand<i128>, IntImmLeaf<i128, [{ return isSextInt(Imm, 21); }], simm21i128_xform> {
  let DecoderMethod = "DecodeSIMM<21>";
}
def simm21i128_ext_xform : SDNodeXForm<imm, [{
  return getI64Imm(N->getSExtValue(), SDLoc(N));
}]>;
def simm21i128_ext : Operand<i128>, IntImmLeaf<i128, [{ return isSextInt(Imm, 63); }], simm21i128_ext_xform> {
  let DecoderMethod = "DecodeSIMM<63>";
}

defm ANDI : PRIM_R2_IMM<opcode_andi,  pr_and,  i64, i64, simm21, simm21_ext>;
defm ORI  : PRIM_R2_IMM<opcode_ori,   pr_or,   i64, i64, simm21, simm21_ext>;
defm XORI : PRIM_R2_IMM<opcode_xori,  pr_xor,  i64, i64, simm21, simm21_ext>;
defm ANDNI: PRIM_R2_IMM<opcode_andni, pr_andn, i64, i64, simm21, simm21_ext>;
defm ORNI : PRIM_R2_IMM<opcode_orni,  pr_orn,  i64, i64, simm21, simm21_ext>;

// FIXME: can model different type immediates only via codegen
let isCodeGenOnly = 1 in {
  defm ANDIW  : PRIM_R2_IMM<opcode_andi,  pr_and,  i32, i32, simm21i32, simm21i32_ext>;
  defm ORIW   : PRIM_R2_IMM<opcode_ori,   pr_or,   i32, i32, simm21i32, simm21i32_ext>;
  defm XORIW  : PRIM_R2_IMM<opcode_xori,  pr_xor,  i32, i32, simm21i32, simm21i32_ext>;
  defm ANDNIW : PRIM_R2_IMM<opcode_andni, pr_andn, i32, i32, simm21i32, simm21i32_ext>;
  defm ORNIW  : PRIM_R2_IMM<opcode_orni,  pr_orn,  i32, i32, simm21i32, simm21i32_ext>;

  defm ANDIQ  : PRIM_R2_IMM<opcode_andi,  pr_and,  i128, i128, simm21i128, simm21i128_ext>;
  defm ORIQ   : PRIM_R2_IMM<opcode_ori,   pr_or,   i128, i128, simm21i128, simm21i128_ext>;
  defm XORIQ  : PRIM_R2_IMM<opcode_xori,  pr_xor,  i128, i128, simm21i128, simm21i128_ext>;
  defm ANDNIQ : PRIM_R2_IMM<opcode_andni, pr_andn, i128, i128, simm21i128, simm21i128_ext>;
  defm ORNIQ  : PRIM_R2_IMM<opcode_orni,  pr_orn,  i128, i128, simm21i128, simm21i128_ext>;
}

//===----------------------------------------------------------------------===//
// birwise instructions are 128-bit long.
// so bitwise-and with positive immediate is post-zero extension.
// and bitwise-or with negative immediate is post-sign extension.
//===----------------------------------------------------------------------===//
def simm21_positive : Operand<i64>, IntImmLeaf<i64,
  [{ return isSextInt(Imm, 21) && Imm.getSExtValue() >= 0; }], simm21_xform> {
  let DecoderMethod = "DecodeSIMM<21>";
}
def simm21_positive_ext : Operand<i64>, IntImmLeaf<i64,
  [{ return isSextInt(Imm, 63) && Imm.getSExtValue() >= 0; }], simm21_ext_xform> {
  let DecoderMethod = "DecodeSIMM<63>";
}
def simm21_negative : Operand<i64>, IntImmLeaf<i64,
  [{ return isSextInt(Imm, 21) && Imm.getSExtValue() < 0; }], simm21_xform> {
  let DecoderMethod = "DecodeSIMM<21>";
}
def simm21_negative_ext : Operand<i64>, IntImmLeaf<i64,
  [{ return isSextInt(Imm, 63) && Imm.getSExtValue() < 0; }], simm21_ext_xform> {
  let DecoderMethod = "DecodeSIMM<63>";
}

def simm21i32_positive : Operand<i32>, IntImmLeaf<i32,
  [{ return isSextInt(Imm, 21) && Imm.getSExtValue() >= 0; }], simm21i32_xform> {
  let DecoderMethod = "DecodeSIMM<21>";
}
def simm21i32_positive_ext : Operand<i32>, IntImmLeaf<i32,
  [{ return isSextInt(Imm, 63) && Imm.getSExtValue() >= 0; }], simm21i32_ext_xform> {
  let DecoderMethod = "DecodeSIMM<63>";
}
def simm21i32_negative : Operand<i32>, IntImmLeaf<i32,
  [{ return isSextInt(Imm, 21) && Imm.getSExtValue() < 0; }], simm21i32_xform> {
  let DecoderMethod = "DecodeSIMM<21>";
}
def simm21i32_negative_ext : Operand<i32>, IntImmLeaf<i32,
  [{ return isSextInt(Imm, 63) && Imm.getSExtValue() < 0; }], simm21i32_ext_xform> {
  let DecoderMethod = "DecodeSIMM<63>";
}

def : Pat<(i64  (zext (pr_and i32:$rb, simm21i32_positive    :$imm))), (ANDIW     GR:$rb, simm21i32    :$imm)>;
def : Pat<(i64  (zext (pr_and i32:$rb, simm21i32_positive_ext:$imm))), (ANDIW_EXT GR:$rb, simm21i32_ext:$imm)>;
def : Pat<(i128 (zext (pr_and i32:$rb, simm21i32_positive    :$imm))), (ANDIW     GR:$rb, simm21i32    :$imm)>;
def : Pat<(i128 (zext (pr_and i32:$rb, simm21i32_positive_ext:$imm))), (ANDIW_EXT GR:$rb, simm21i32_ext:$imm)>;
def : Pat<(i128 (zext (pr_and i64:$rb, simm21_positive    :$imm))), (ANDI     GR:$rb, simm21    :$imm)>;
def : Pat<(i128 (zext (pr_and i64:$rb, simm21_positive_ext:$imm))), (ANDI_EXT GR:$rb, simm21_ext:$imm)>;

def : Pat<(i64  (zext (pr_andn i32:$rb, simm21i32_positive    :$imm))), (ANDNIW     GR:$rb, simm21i32    :$imm)>;
def : Pat<(i64  (zext (pr_andn i32:$rb, simm21i32_positive_ext:$imm))), (ANDNIW_EXT GR:$rb, simm21i32_ext:$imm)>;
def : Pat<(i128 (zext (pr_andn i32:$rb, simm21i32_positive    :$imm))), (ANDNIW     GR:$rb, simm21i32    :$imm)>;
def : Pat<(i128 (zext (pr_andn i32:$rb, simm21i32_positive_ext:$imm))), (ANDNIW_EXT GR:$rb, simm21i32_ext:$imm)>;
def : Pat<(i128 (zext (pr_andn i64:$rb, simm21_positive    :$imm))), (ANDNI     GR:$rb, simm21    :$imm)>;
def : Pat<(i128 (zext (pr_andn i64:$rb, simm21_positive_ext:$imm))), (ANDNI_EXT GR:$rb, simm21_ext:$imm)>;

def : Pat<(i64  (sext (pr_or i32:$rb, simm21i32_negative    :$imm))), (ORIW     GR:$rb, simm21i32    :$imm)>;
def : Pat<(i64  (sext (pr_or i32:$rb, simm21i32_negative_ext:$imm))), (ORIW_EXT GR:$rb, simm21i32_ext:$imm)>;
def : Pat<(i128 (sext (pr_or i32:$rb, simm21i32_negative    :$imm))), (ORIW     GR:$rb, simm21i32    :$imm)>;
def : Pat<(i128 (sext (pr_or i32:$rb, simm21i32_negative_ext:$imm))), (ORIW_EXT GR:$rb, simm21i32_ext:$imm)>;
def : Pat<(i128 (sext (pr_or i64:$rb, simm21_negative    :$imm))), (ORI     GR:$rb, simm21    :$imm)>;
def : Pat<(i128 (sext (pr_or i64:$rb, simm21_negative_ext:$imm))), (ORI_EXT GR:$rb, simm21_ext:$imm)>;

def : Pat<(i64  (sext (pr_orn i32:$rb, simm21i32_negative    :$imm))), (ORNIW     GR:$rb, simm21i32    :$imm)>;
def : Pat<(i64  (sext (pr_orn i32:$rb, simm21i32_negative_ext:$imm))), (ORNIW_EXT GR:$rb, simm21i32_ext:$imm)>;
def : Pat<(i128 (sext (pr_orn i32:$rb, simm21i32_negative    :$imm))), (ORNIW     GR:$rb, simm21i32    :$imm)>;
def : Pat<(i128 (sext (pr_orn i32:$rb, simm21i32_negative_ext:$imm))), (ORNIW_EXT GR:$rb, simm21i32_ext:$imm)>;
def : Pat<(i128 (sext (pr_orn i64:$rb, simm21_negative    :$imm))), (ORNI     GR:$rb, simm21    :$imm)>;
def : Pat<(i128 (sext (pr_orn i64:$rb, simm21_negative_ext:$imm))), (ORNI_EXT GR:$rb, simm21_ext:$imm)>;
