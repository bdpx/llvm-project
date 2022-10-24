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
def pr_not  : PatFrag<(ops node:$src1), (not node:$src1)>;

multiclass MISC_R3_BITWISE<misc_opx opx, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : MISC_Rabc<opx, (outs GR:$ra), (ins GR:$rb, GR:$rc),
                      !strconcat(opx.mnem, " $ra, $rb, $rc"), [], itin>;
}

defm AND  : MISC_R3_BITWISE<opcode_and>;
defm OR   : MISC_R3_BITWISE<opcode_or>;
defm XOR  : MISC_R3_BITWISE<opcode_xor>;
defm NAND : MISC_R3_BITWISE<opcode_nand>;
defm NOR  : MISC_R3_BITWISE<opcode_nor>;
defm XNOR : MISC_R3_BITWISE<opcode_xnor>;
defm ANDN : MISC_R3_BITWISE<opcode_andn>;
defm ORN  : MISC_R3_BITWISE<opcode_orn>;

multiclass MISC_R2_BITWISE<misc_opx opx, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : MISC_Rab<opx, (outs GR:$ra), (ins GR:$rb),
                      !strconcat(opx.mnem, " $ra, $rb"), [], itin>;
}

defm NOT : MISC_R2_BITWISE<opcode_not>;

multiclass BITWISE_PATS<ValueType Ty>
{
  def : Pat<(pr_and  Ty:$rb, Ty:$rc), (AND  GR:$rb, GR:$rc)>;
  def : Pat<(pr_or   Ty:$rb, Ty:$rc), (OR   GR:$rb, GR:$rc)>;
  def : Pat<(pr_xor  Ty:$rb, Ty:$rc), (XOR  GR:$rb, GR:$rc)>;
  def : Pat<(pr_nand Ty:$rb, Ty:$rc), (NAND GR:$rb, GR:$rc)>;
  def : Pat<(pr_nor  Ty:$rb, Ty:$rc), (NOR  GR:$rb, GR:$rc)>;
  def : Pat<(pr_xnor Ty:$rb, Ty:$rc), (XNOR GR:$rb, GR:$rc)>;
  def : Pat<(pr_andn Ty:$rb, Ty:$rc), (ANDN GR:$rb, GR:$rc)>;
  def : Pat<(pr_orn  Ty:$rb, Ty:$rc), (ORN  GR:$rb, GR:$rc)>;
  def : Pat<(pr_not  Ty:$rb        ), (NOT GR:$rb)>;
}

defm : BITWISE_PATS<i32>;
defm : BITWISE_PATS<i64>;
defm : BITWISE_PATS<i128>;
defm : BITWISE_PATS<v16i8>;
defm : BITWISE_PATS<v8i16>;
defm : BITWISE_PATS<v4i32>;
defm : BITWISE_PATS<v2i64>;

// nand, nor, xnor, andn, orn - aren't used for i1, because extend ones outside first bit
def : Pat<(pr_and  i1:$rb, i1:$rc), (AND  GR:$rb, GR:$rc)>;
def : Pat<(pr_or   i1:$rb, i1:$rc), (OR   GR:$rb, GR:$rc)>;
def : Pat<(pr_xor  i1:$rb, i1:$rc), (XOR  GR:$rb, GR:$rc)>;

//===----------------------------------------------------------------------===//
// bitwise reg-imm
//===----------------------------------------------------------------------===//
defm AND_IMM : PRIM_R2_IMM<opcode_and_imm,  pr_and,  i64, i64, simm21, simm21_ext>;
defm OR_IMM  : PRIM_R2_IMM<opcode_or_imm,   pr_or,   i64, i64, simm21, simm21_ext>;
defm XOR_IMM : PRIM_R2_IMM<opcode_xor_imm,  pr_xor,  i64, i64, simm21, simm21_ext>;
defm ANDN_IMM: PRIM_R2_IMM<opcode_andn_imm, pr_andn, i64, i64, simm21, simm21_ext>;
defm ORN_IMM : PRIM_R2_IMM<opcode_orn_imm,  pr_orn,  i64, i64, simm21, simm21_ext>;

// FIXME: can model different type immediates only via codegen
let isCodeGenOnly = 1 in {
  defm AND_IMM_I32   : PRIM_R2_IMM<opcode_and_imm,  pr_and,  i32, i32, simm21i32, simm21i32_ext>;
  defm OR_IMM_I32    : PRIM_R2_IMM<opcode_or_imm,   pr_or,   i32, i32, simm21i32, simm21i32_ext>;
  defm XOR_IMM_I32   : PRIM_R2_IMM<opcode_xor_imm,  pr_xor,  i32, i32, simm21i32, simm21i32_ext>;
  defm ANDN_IMM_I32  : PRIM_R2_IMM<opcode_andn_imm, pr_andn, i32, i32, simm21i32, simm21i32_ext>;
  defm ORN_IMM_I32   : PRIM_R2_IMM<opcode_orn_imm,  pr_orn,  i32, i32, simm21i32, simm21i32_ext>;

  defm AND_IMM_I128  : PRIM_R2_IMM<opcode_and_imm,  pr_and,  i128, i128, simm21i128, simm21i128_ext>;
  defm OR_IMM_I128   : PRIM_R2_IMM<opcode_or_imm,   pr_or,   i128, i128, simm21i128, simm21i128_ext>;
  defm XOR_IMM_I128  : PRIM_R2_IMM<opcode_xor_imm,  pr_xor,  i128, i128, simm21i128, simm21i128_ext>;
  defm ANDN_IMM_I128 : PRIM_R2_IMM<opcode_andn_imm, pr_andn, i128, i128, simm21i128, simm21i128_ext>;
  defm ORN_IMM_I128  : PRIM_R2_IMM<opcode_orn_imm,  pr_orn,  i128, i128, simm21i128, simm21i128_ext>;
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
  [{ return isSextInt(Imm, 21+42) && Imm.getSExtValue() >= 0; }], simm21_ext_xform> {
  let DecoderMethod = "DecodeSIMM<21+42>";
}
def simm21_negative : Operand<i64>, IntImmLeaf<i64,
  [{ return isSextInt(Imm, 21) && Imm.getSExtValue() < 0; }], simm21_xform> {
  let DecoderMethod = "DecodeSIMM<21>";
}
def simm21_negative_ext : Operand<i64>, IntImmLeaf<i64,
  [{ return isSextInt(Imm, 21+42) && Imm.getSExtValue() < 0; }], simm21_ext_xform> {
  let DecoderMethod = "DecodeSIMM<21+42>";
}

def simm21i32_positive : Operand<i32>, IntImmLeaf<i32,
  [{ return isSextInt(Imm, 21) && Imm.getSExtValue() >= 0; }], simm21i32_xform> {
  let DecoderMethod = "DecodeSIMM<21>";
}
def simm21i32_positive_ext : Operand<i32>, IntImmLeaf<i32,
  [{ return isSextInt(Imm, 21+42) && Imm.getSExtValue() >= 0; }], simm21i32_ext_xform> {
  let DecoderMethod = "DecodeSIMM<21+42>";
}
def simm21i32_negative : Operand<i32>, IntImmLeaf<i32,
  [{ return isSextInt(Imm, 21) && Imm.getSExtValue() < 0; }], simm21i32_xform> {
  let DecoderMethod = "DecodeSIMM<21>";
}
def simm21i32_negative_ext : Operand<i32>, IntImmLeaf<i32,
  [{ return isSextInt(Imm, 21+42) && Imm.getSExtValue() < 0; }], simm21i32_ext_xform> {
  let DecoderMethod = "DecodeSIMM<21+42>";
}

def : Pat<(i64  (zext (pr_and i32:$rb, simm21i32_positive    :$imm))), (AND_IMM_I32     GR:$rb, simm21i32    :$imm)>;
def : Pat<(i64  (zext (pr_and i32:$rb, simm21i32_positive_ext:$imm))), (AND_IMM_I32_EXT GR:$rb, simm21i32_ext:$imm)>;
def : Pat<(i128 (zext (pr_and i32:$rb, simm21i32_positive    :$imm))), (AND_IMM_I32     GR:$rb, simm21i32    :$imm)>;
def : Pat<(i128 (zext (pr_and i32:$rb, simm21i32_positive_ext:$imm))), (AND_IMM_I32_EXT GR:$rb, simm21i32_ext:$imm)>;
def : Pat<(i128 (zext (pr_and i64:$rb, simm21_positive       :$imm))), (AND_IMM         GR:$rb, simm21       :$imm)>;
def : Pat<(i128 (zext (pr_and i64:$rb, simm21_positive_ext   :$imm))), (AND_IMM_EXT     GR:$rb, simm21_ext   :$imm)>;

def : Pat<(i64  (zext (pr_andn i32:$rb, simm21i32_positive    :$imm))), (ANDN_IMM_I32     GR:$rb, simm21i32    :$imm)>;
def : Pat<(i64  (zext (pr_andn i32:$rb, simm21i32_positive_ext:$imm))), (ANDN_IMM_I32_EXT GR:$rb, simm21i32_ext:$imm)>;
def : Pat<(i128 (zext (pr_andn i32:$rb, simm21i32_positive    :$imm))), (ANDN_IMM_I32     GR:$rb, simm21i32    :$imm)>;
def : Pat<(i128 (zext (pr_andn i32:$rb, simm21i32_positive_ext:$imm))), (ANDN_IMM_I32_EXT GR:$rb, simm21i32_ext:$imm)>;
def : Pat<(i128 (zext (pr_andn i64:$rb, simm21_positive       :$imm))), (ANDN_IMM         GR:$rb, simm21       :$imm)>;
def : Pat<(i128 (zext (pr_andn i64:$rb, simm21_positive_ext   :$imm))), (ANDN_IMM_EXT     GR:$rb, simm21_ext   :$imm)>;

def : Pat<(i64  (sext (pr_or i32:$rb, simm21i32_negative    :$imm))), (OR_IMM_I32     GR:$rb, simm21i32    :$imm)>;
def : Pat<(i64  (sext (pr_or i32:$rb, simm21i32_negative_ext:$imm))), (OR_IMM_I32_EXT GR:$rb, simm21i32_ext:$imm)>;
def : Pat<(i128 (sext (pr_or i32:$rb, simm21i32_negative    :$imm))), (OR_IMM_I32     GR:$rb, simm21i32    :$imm)>;
def : Pat<(i128 (sext (pr_or i32:$rb, simm21i32_negative_ext:$imm))), (OR_IMM_I32_EXT GR:$rb, simm21i32_ext:$imm)>;
def : Pat<(i128 (sext (pr_or i64:$rb, simm21_negative       :$imm))), (OR_IMM         GR:$rb, simm21       :$imm)>;
def : Pat<(i128 (sext (pr_or i64:$rb, simm21_negative_ext   :$imm))), (OR_IMM_EXT     GR:$rb, simm21_ext   :$imm)>;

def : Pat<(i64  (sext (pr_orn i32:$rb, simm21i32_negative    :$imm))), (ORN_IMM_I32     GR:$rb, simm21i32    :$imm)>;
def : Pat<(i64  (sext (pr_orn i32:$rb, simm21i32_negative_ext:$imm))), (ORN_IMM_I32_EXT GR:$rb, simm21i32_ext:$imm)>;
def : Pat<(i128 (sext (pr_orn i32:$rb, simm21i32_negative    :$imm))), (ORN_IMM_I32     GR:$rb, simm21i32    :$imm)>;
def : Pat<(i128 (sext (pr_orn i32:$rb, simm21i32_negative_ext:$imm))), (ORN_IMM_I32_EXT GR:$rb, simm21i32_ext:$imm)>;
def : Pat<(i128 (sext (pr_orn i64:$rb, simm21_negative       :$imm))), (ORN_IMM         GR:$rb, simm21       :$imm)>;
def : Pat<(i128 (sext (pr_orn i64:$rb, simm21_negative_ext   :$imm))), (ORN_IMM_EXT     GR:$rb, simm21_ext   :$imm)>;



//===----------------------------------------------------------------------===//
//
// one bit set/clear/flip
//
//===----------------------------------------------------------------------===//

class bit_set  <ValueType Ty> : PatFrag<(ops node:$src1, node:$src2), (or  node:$src1,      (shl (Ty 1), node:$src2) )> {}
class bit_clear<ValueType Ty> : PatFrag<(ops node:$src1, node:$src2), (and node:$src1, (not (shl (Ty 1), node:$src2)))> {}
class bit_flip <ValueType Ty> : PatFrag<(ops node:$src1, node:$src2), (xor node:$src1,      (shl (Ty 1), node:$src2) )> {}

defm BIT_SET   : MISC_R3_BITWISE<opcode_bit_set>;
defm BIT_CLEAR : MISC_R3_BITWISE<opcode_bit_clear>;
defm BIT_FLIP  : MISC_R3_BITWISE<opcode_bit_flip>;

multiclass BITSET_PATS<ValueType Ty>
{
  def : Pat<(bit_set<Ty>   Ty:$rb, Ty:$rc), (BIT_SET   GR:$rb, GR:$rc)>;
  def : Pat<(bit_clear<Ty> Ty:$rb, Ty:$rc), (BIT_CLEAR GR:$rb, GR:$rc)>;
  def : Pat<(bit_flip<Ty>  Ty:$rb, Ty:$rc), (BIT_FLIP  GR:$rb, GR:$rc)>;

  def : Pat<(bit_set<Ty>   Ty:$rb, i32:$rc), (BIT_SET   GR:$rb, GR:$rc)>;
  def : Pat<(bit_clear<Ty> Ty:$rb, i32:$rc), (BIT_CLEAR GR:$rb, GR:$rc)>;
  def : Pat<(bit_flip<Ty>  Ty:$rb, i32:$rc), (BIT_FLIP  GR:$rb, GR:$rc)>;

  def : Pat<(bit_set<Ty>   Ty:$rb, i64:$rc), (BIT_SET   GR:$rb, GR:$rc)>;
  def : Pat<(bit_clear<Ty> Ty:$rb, i64:$rc), (BIT_CLEAR GR:$rb, GR:$rc)>;
  def : Pat<(bit_flip<Ty>  Ty:$rb, i64:$rc), (BIT_FLIP  GR:$rb, GR:$rc)>;
}

defm : BITSET_PATS<i32>;
defm : BITSET_PATS<i64>;
defm : BITSET_PATS<i128>;

multiclass BITSET_IMM<misc_opx Opc, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : MISC_RabSc<Opc, (outs GR:$ra), (ins GR:$rb, uimm7:$shcnt),
        !strconcat(Opc.mnem, " $ra, $rb, $shcnt"),
        [], itin>;
}

defm BIT_SET_IMM   : BITSET_IMM<opcode_bit_set_imm>;
defm BIT_CLEAR_IMM : BITSET_IMM<opcode_bit_clear_imm>;
defm BIT_FLIP_IMM  : BITSET_IMM<opcode_bit_flip_imm>;

multiclass BITSET_IMM_PATS<ValueType Ty>
{
  def : Pat<(bit_set<Ty>   Ty:$rb, uimm7:$rc), (BIT_SET_IMM   GR:$rb, uimm7:$rc)>;
  def : Pat<(bit_clear<Ty> Ty:$rb, uimm7:$rc), (BIT_CLEAR_IMM GR:$rb, uimm7:$rc)>;
  def : Pat<(bit_flip<Ty>  Ty:$rb, uimm7:$rc), (BIT_FLIP_IMM  GR:$rb, uimm7:$rc)>;
}

defm : BITSET_IMM_PATS<i32>;
defm : BITSET_IMM_PATS<i64>;
defm : BITSET_IMM_PATS<i128>;

foreach LEFT_SHIFT = {0 ... 31} in {
    defvar POW2 = !shl(1, LEFT_SHIFT);
    defvar MASK = !xor(0xFFFFFFFF, POW2);

    def : Pat<(or   i32:$ra, POW2), (BIT_SET_IMM   GR:$ra, LEFT_SHIFT)>;
    def : Pat<(xor  i32:$ra, POW2), (BIT_FLIP_IMM  GR:$ra, LEFT_SHIFT)>;
    def : Pat<(and  i32:$ra, MASK), (BIT_CLEAR_IMM GR:$ra, LEFT_SHIFT)>;
}

foreach LEFT_SHIFT = {0 ... 63} in {
    defvar POW2 = !shl(1, LEFT_SHIFT);
    defvar MASK = !xor(0xFFFFFFFFFFFFFFFF, POW2);

    def : Pat<(or   i64:$ra, POW2), (BIT_SET_IMM   GR:$ra, LEFT_SHIFT)>;
    def : Pat<(xor  i64:$ra, POW2), (BIT_FLIP_IMM  GR:$ra, LEFT_SHIFT)>;
    def : Pat<(and  i64:$ra, MASK), (BIT_CLEAR_IMM GR:$ra, LEFT_SHIFT)>;
}

// FIXME: should be 0..127, but clang fails
foreach LEFT_SHIFT = {0 ... 63} in {
    defvar POW2 = !shl(1, LEFT_SHIFT);

    def : Pat<(or   i128:$ra, POW2), (BIT_SET_IMM   GR:$ra, LEFT_SHIFT)>;
    def : Pat<(xor  i128:$ra, POW2), (BIT_FLIP_IMM  GR:$ra, LEFT_SHIFT)>;
    def : Pat<(and  i128:$ra, (not (shl (i128 1), (i32 LEFT_SHIFT)))), (BIT_CLEAR_IMM GR:$ra, LEFT_SHIFT)>;
}
