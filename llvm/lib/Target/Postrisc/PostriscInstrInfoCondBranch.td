//===-- PostriscInstrInfoCondBranch.td - Target Description for Postrisc --===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains instruction formats, definitions and patterns needed for
// branch instructions on POSTRISC.
//
//===----------------------------------------------------------------------===//


//===----------------------------------------------------------------------===//
// Compare reg-reg and branch
//===----------------------------------------------------------------------===//
multiclass CompareAndBranch<brr_opx opxCode, PatFrag OpNode, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  let isBranch = 1, isTerminator = 1 in {
    def NAME        : BRR_RabBranch    <opcode_brr, opxCode.value, (outs), (ins GR:$ra, GR:$rb, brtarget    :$offset),
                      !strconcat(opxCode.mnem, " $ra, $rb, $offset"),
                      [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;
    def NAME # _EXT : BRR_RabBranch_ext<opcode_brr, opxCode.value, (outs), (ins GR:$ra, GR:$rb, brtarget_ext:$offset),
                      !strconcat(opxCode.mnem, ".l $ra, $rb, $offset"),
                      [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;
  }
}

defm BR_EQ_I64 : CompareAndBranch<opcode_br_eq_i64, seteq,  i64>;
defm BR_NE_I64 : CompareAndBranch<opcode_br_ne_i64, setne,  i64>;
defm BR_LT_I64 : CompareAndBranch<opcode_br_lt_i64, setlt,  i64>;
defm BR_LE_I64 : CompareAndBranch<opcode_br_le_i64, setle,  i64>;
defm BR_LT_U64 : CompareAndBranch<opcode_br_lt_u64, setult, i64>;
defm BR_LE_U64 : CompareAndBranch<opcode_br_le_u64, setule, i64>;

defm BR_EQ_I32 : CompareAndBranch<opcode_br_eq_i32, seteq,  i32>;
defm BR_NE_I32 : CompareAndBranch<opcode_br_ne_i32, setne,  i32>;
defm BR_LT_I32 : CompareAndBranch<opcode_br_lt_i32, setlt,  i32>;
defm BR_LE_I32 : CompareAndBranch<opcode_br_le_i32, setle,  i32>;
defm BR_LT_U32 : CompareAndBranch<opcode_br_lt_u32, setult, i32>;
defm BR_LE_U32 : CompareAndBranch<opcode_br_le_u32, setule, i32>;

multiclass CompareAndBranch_i128<br_i128_opx opxCode, PatFrag OpNode, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  let isBranch = 1, isTerminator = 1 in {
    def NAME        : BRR_RabBranch    <opcode_br_i128, opxCode.value, (outs), (ins GR:$ra, GR:$rb, brtarget    :$offset),
                      !strconcat(opxCode.mnem, " $ra, $rb, $offset"),
                      [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;
    def NAME # _EXT : BRR_RabBranch_ext<opcode_br_i128, opxCode.value, (outs), (ins GR:$ra, GR:$rb, brtarget_ext:$offset),
                      !strconcat(opxCode.mnem, ".l $ra, $rb, $offset"),
                      [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;
  }
}

defm BR_EQ_I128 : CompareAndBranch_i128<opcode_br_eq_i128, seteq,  i128>;
defm BR_NE_I128 : CompareAndBranch_i128<opcode_br_ne_i128, setne,  i128>;
defm BR_LT_I128 : CompareAndBranch_i128<opcode_br_lt_i128, setlt,  i128>;
defm BR_LE_I128 : CompareAndBranch_i128<opcode_br_le_i128, setle,  i128>;
defm BR_LT_U128 : CompareAndBranch_i128<opcode_br_lt_u128, setult, i128>;
defm BR_LE_U128 : CompareAndBranch_i128<opcode_br_le_u128, setule, i128>;

//===----------------------------------------------------------------------===//
// Compare greater: use less
//===----------------------------------------------------------------------===//
def : Pat<(brcond (i1 (setgt  i64:$a, i64:$b)), bb:$dst), (BR_LT_I64 GR:$b, GR:$a, bb:$dst)>;
def : Pat<(brcond (i1 (setge  i64:$a, i64:$b)), bb:$dst), (BR_LE_I64 GR:$b, GR:$a, bb:$dst)>;
def : Pat<(brcond (i1 (setugt i64:$a, i64:$b)), bb:$dst), (BR_LT_U64 GR:$b, GR:$a, bb:$dst)>;
def : Pat<(brcond (i1 (setuge i64:$a, i64:$b)), bb:$dst), (BR_LE_U64 GR:$b, GR:$a, bb:$dst)>;

def : Pat<(brcond (i1 (setgt  i32:$a, i32:$b)), bb:$dst), (BR_LT_I32 GR:$b, GR:$a, bb:$dst)>;
def : Pat<(brcond (i1 (setge  i32:$a, i32:$b)), bb:$dst), (BR_LE_I32 GR:$b, GR:$a, bb:$dst)>;
def : Pat<(brcond (i1 (setugt i32:$a, i32:$b)), bb:$dst), (BR_LT_U32 GR:$b, GR:$a, bb:$dst)>;
def : Pat<(brcond (i1 (setuge i32:$a, i32:$b)), bb:$dst), (BR_LE_U32 GR:$b, GR:$a, bb:$dst)>;

//===----------------------------------------------------------------------===//
// Compare with zero and branch
//===----------------------------------------------------------------------===//
def : Pat<(brcond (i1 (seteq i64:$a, (i64 0))), bb:$dst), (BR_EQ_I64 GR:$a, (i64 gz), bb:$dst)>;
def : Pat<(brcond (i1 (setne i64:$a, (i64 0))), bb:$dst), (BR_NE_I64 GR:$a, (i64 gz), bb:$dst)>;
def : Pat<(brcond (i1 (setlt i64:$a, (i64 0))), bb:$dst), (BR_LT_I64 GR:$a, (i64 gz), bb:$dst)>;
def : Pat<(brcond (i1 (setle i64:$a, (i64 0))), bb:$dst), (BR_LE_I64 GR:$a, (i64 gz), bb:$dst)>;
def : Pat<(brcond (i1 (setgt i64:$a, (i64 0))), bb:$dst), (BR_LT_I64 (i64 gz), GR:$a, bb:$dst)>;
def : Pat<(brcond (i1 (setge i64:$a, (i64 0))), bb:$dst), (BR_LE_I64 (i64 gz), GR:$a, bb:$dst)>;

def : Pat<(brcond (i1 (seteq i32:$a, (i32 0))), bb:$dst), (BR_EQ_I32 GR:$a, (i32 gz), bb:$dst)>;
def : Pat<(brcond (i1 (setne i32:$a, (i32 0))), bb:$dst), (BR_NE_I32 GR:$a, (i32 gz), bb:$dst)>;
def : Pat<(brcond (i1 (setlt i32:$a, (i32 0))), bb:$dst), (BR_LT_I32 GR:$a, (i32 gz), bb:$dst)>;
def : Pat<(brcond (i1 (setle i32:$a, (i32 0))), bb:$dst), (BR_LE_I32 GR:$a, (i32 gz), bb:$dst)>;
def : Pat<(brcond (i1 (setgt i32:$a, (i32 0))), bb:$dst), (BR_LT_I32 (i32 gz), GR:$a, bb:$dst)>;
def : Pat<(brcond (i1 (setge i32:$a, (i32 0))), bb:$dst), (BR_LE_I32 (i32 gz), GR:$a, bb:$dst)>;

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
defm BR_BS : CompareAndBranch<opcode_br_bs, cmp_bitset,   i64>;
defm BR_BC : CompareAndBranch<opcode_br_bc, cmp_bitclear, i64>;

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

defm : CompareBitPat<BR_BS, i32, 1, 0>;
defm : CompareBitPat<BR_BS, i64, 1, 0>;
defm : CompareBitPat<BR_BC, i32, 0, 1>;
defm : CompareBitPat<BR_BC, i64, 0, 1>;

//===----------------------------------------------------------------------===//
// Compare reg-bit immediate and branch
//===----------------------------------------------------------------------===//
multiclass CompareBitAndBranch<brr_opx opxCode, PatFrag OpNode, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  let isBranch = 1, isTerminator = 1 in {
    def NAME        : BRR_RabBranch    <opcode_brr, opxCode.value, (outs), (ins GR:$ra, uimm7:$rb, brtarget    :$offset),
                      !strconcat(opxCode.mnem, " $ra, $rb, $offset"), [(brcond (i1 (OpNode Ty:$ra, uimm7:$rb)), bb:$offset)], itin>;
    def NAME # _EXT : BRR_RabBranch_ext<opcode_brr, opxCode.value, (outs), (ins GR:$ra, uimm7:$rb, brtarget_ext:$offset),
                      !strconcat(opxCode.mnem, ".l $ra, $rb, $offset"), [(brcond (i1 (OpNode Ty:$ra, uimm7:$rb)), bb:$offset)], itin>;
  }
}

defm BR_BS_IMM : CompareBitAndBranch<opcode_br_bs_imm, cmp_bitset,   i64>;
defm BR_BC_IMM : CompareBitAndBranch<opcode_br_bc_imm, cmp_bitclear, i64>;

multiclass
CompareBitImmPat<InstBase Op, int direct_value, int invert_value>
{
  def : Pat<(brcond (i1 (seteq (and (srl i64:$a, uimm7:$b), 1), direct_value)), bb:$dst), (Op GR:$a, uimm7:$b, bb:$dst)>;
  def : Pat<(brcond (i1 (seteq (and (sra i64:$a, uimm7:$b), 1), direct_value)), bb:$dst), (Op GR:$a, uimm7:$b, bb:$dst)>;
  def : Pat<(brcond (i1 (setne (and (srl i64:$a, uimm7:$b), 1), invert_value)), bb:$dst), (Op GR:$a, uimm7:$b, bb:$dst)>;
  def : Pat<(brcond (i1 (setne (and (sra i64:$a, uimm7:$b), 1), invert_value)), bb:$dst), (Op GR:$a, uimm7:$b, bb:$dst)>;
}

defm : CompareBitImmPat<BR_BS_IMM, 1, 0>;
defm : CompareBitImmPat<BR_BC_IMM, 0, 1>;

// it's ugly but works
foreach III = 0-63 in {
  defvar BIT = !shl(1,III);
  def : Pat<(brcond (i1 (seteq (and i64:$a, BIT),   0)), bb:$dst), (BR_BC_IMM  GR:$a, III, bb:$dst)>;
  def : Pat<(brcond (i1 (setne (and i64:$a, BIT), BIT)), bb:$dst), (BR_BC_IMM  GR:$a, III, bb:$dst)>;
  def : Pat<(brcond (i1 (setne (and i64:$a, BIT),   0)), bb:$dst), (BR_BS_IMM  GR:$a, III, bb:$dst)>;
  def : Pat<(brcond (i1 (seteq (and i64:$a, BIT), BIT)), bb:$dst), (BR_BS_IMM  GR:$a, III, bb:$dst)>;
}
foreach III = 0-31 in {
  defvar BIT = !shl(1,III);
  def : Pat<(brcond (i1 (seteq (and i32:$a, BIT),   0)), bb:$dst), (BR_BC_IMM  GR:$a, III, bb:$dst)>;
  def : Pat<(brcond (i1 (setne (and i32:$a, BIT), BIT)), bb:$dst), (BR_BC_IMM  GR:$a, III, bb:$dst)>;
  def : Pat<(brcond (i1 (setne (and i32:$a, BIT),   0)), bb:$dst), (BR_BS_IMM  GR:$a, III, bb:$dst)>;
  def : Pat<(brcond (i1 (seteq (and i32:$a, BIT), BIT)), bb:$dst), (BR_BS_IMM  GR:$a, III, bb:$dst)>;
}

//===----------------------------------------------------------------------===//
// Compare immediate and branch (64 bit)
//===----------------------------------------------------------------------===//
multiclass CompareAndBranchImm<opcode_opx opcode, PatFrag OpNode, ValueType Ty,
   Operand immOp, Operand immOpEx, InstrItinClass itin = IIC_iu_instr>
{
  let isBranch = 1, isTerminator = 1 in {
    def NAME        : PRIMARY_RaImmBranch    <opcode, (outs), (ins GR:$ra, immOp  :$imm, brtarget    :$offset),
                      !strconcat(opcode.mnem, " $ra, $imm, $offset"), [(brcond (i1 (OpNode Ty:$ra, immOp  :$imm)), bb:$offset)], itin>;
    def NAME # _EXT : PRIMARY_RaImmBranch_ext<opcode, (outs), (ins GR:$ra, immOpEx:$imm, brtarget_ext:$offset),
                      !strconcat(opcode.mnem, ".l $ra, $imm, $offset"), [(brcond (i1 (OpNode Ty:$ra, immOpEx:$imm)), bb:$offset)], itin>;
  }
}

defm BR_EQ_IMM_I64 : CompareAndBranchImm<opcode_br_eq_imm_i64, seteq,  i64, simm11, simm11_ext>;
defm BR_NE_IMM_I64 : CompareAndBranchImm<opcode_br_ne_imm_i64, setne,  i64, simm11, simm11_ext>;
defm BR_LT_IMM_I64 : CompareAndBranchImm<opcode_br_lt_imm_i64, setlt,  i64, simm11, simm11_ext>;
defm BR_GE_IMM_I64 : CompareAndBranchImm<opcode_br_ge_imm_i64, setge,  i64, simm11, simm11_ext>;
defm BR_LT_IMM_U64 : CompareAndBranchImm<opcode_br_lt_imm_u64, setult, i64, uimm11, uimm11_ext>;
defm BR_GE_IMM_U64 : CompareAndBranchImm<opcode_br_ge_imm_u64, setuge, i64, uimm11, uimm11_ext>;

defm BR_EQ_IMM_I32 : CompareAndBranchImm<opcode_br_eq_imm_i32, seteq,  i32, simm11i32, simm11i32_ext>;
defm BR_NE_IMM_I32 : CompareAndBranchImm<opcode_br_ne_imm_i32, setne,  i32, simm11i32, simm11i32_ext>;
defm BR_LT_IMM_I32 : CompareAndBranchImm<opcode_br_lt_imm_i32, setlt,  i32, simm11i32, simm11i32_ext>;
defm BR_GE_IMM_I32 : CompareAndBranchImm<opcode_br_ge_imm_i32, setge,  i32, simm11i32, simm11i32_ext>;
defm BR_LT_IMM_U32 : CompareAndBranchImm<opcode_br_lt_imm_u32, setult, i32, uimm11i32, uimm11i32_ext>;
defm BR_GE_IMM_U32 : CompareAndBranchImm<opcode_br_ge_imm_u32, setuge, i32, uimm11i32, uimm11i32_ext>;

defm BR_EQ_IMM_I128 : CompareAndBranchImm<opcode_br_eq_imm_i128, seteq,  i128, simm11i128, simm11i128_ext>;
defm BR_NE_IMM_I128 : CompareAndBranchImm<opcode_br_ne_imm_i128, setne,  i128, simm11i128, simm11i128_ext>;
defm BR_LT_IMM_I128 : CompareAndBranchImm<opcode_br_lt_imm_i128, setlt,  i128, simm11i128, simm11i128_ext>;
defm BR_GE_IMM_I128 : CompareAndBranchImm<opcode_br_ge_imm_i128, setge,  i128, simm11i128, simm11i128_ext>;
defm BR_LT_IMM_U128 : CompareAndBranchImm<opcode_br_lt_imm_u128, setult, i128, uimm11i128, uimm11i128_ext>;
defm BR_GE_IMM_U128 : CompareAndBranchImm<opcode_br_ge_imm_u128, setuge, i128, uimm11i128, uimm11i128_ext>;

defm BR_MASK_ALL    : CompareAndBranchImm<opcode_br_mask_all,    cmp_all,    i64, uimm11, uimm11_ext>;
defm BR_MASK_NOTALL : CompareAndBranchImm<opcode_br_mask_notall, cmp_notall, i64, uimm11, uimm11_ext>;
defm BR_MASK_NONE   : CompareAndBranchImm<opcode_br_mask_none,   cmp_none,   i64, uimm11, uimm11_ext>;
defm BR_MASK_ANY    : CompareAndBranchImm<opcode_br_mask_any,    cmp_any,    i64, uimm11, uimm11_ext>;

multiclass CompareImmPlus64<InstBase Inst, InstBaseExt InstExt, PatFrag OpNode, ValueType Ty, PatLeaf immOp, PatLeaf immOpEx>
{
  def : Pat<(brcond (i1 (OpNode Ty:$ra, immOp  :$imm)), bb:$offset), (Inst    GR:$ra, (Plus1 imm:$imm), bb:$offset)>;
  def : Pat<(brcond (i1 (OpNode Ty:$ra, immOpEx:$imm)), bb:$offset), (InstExt GR:$ra, (Plus1 imm:$imm), bb:$offset)>;
}

multiclass CompareImmPlus32<InstBase Inst, InstBaseExt InstExt, PatFrag OpNode, ValueType Ty, PatLeaf immOp, PatLeaf immOpEx>
{
  def : Pat<(brcond (i1 (OpNode Ty:$ra, immOp  :$imm)), bb:$offset), (Inst    GR:$ra, (Plus1_32 imm:$imm), bb:$offset)>;
  def : Pat<(brcond (i1 (OpNode Ty:$ra, immOpEx:$imm)), bb:$offset), (InstExt GR:$ra, (Plus1_32 imm:$imm), bb:$offset)>;
}

// "<= 15" ==> "< 16"
defm : CompareImmPlus64<BR_LT_IMM_I64, BR_LT_IMM_I64_EXT,  setle, i64, simm11_plus1, simm11_ext_plus1>;
defm : CompareImmPlus64<BR_LT_IMM_U64, BR_LT_IMM_U64_EXT, setule, i64, uimm11_plus1, uimm11_ext_plus1>;
defm : CompareImmPlus32<BR_LT_IMM_I32, BR_LT_IMM_I32_EXT,  setle, i32, simm11_plus1, simm11_ext_plus1>;
defm : CompareImmPlus32<BR_LT_IMM_U32, BR_LT_IMM_U32_EXT, setule, i32, uimm11_plus1, uimm11_ext_plus1>;
// "> 15" ==> ">= 16"
defm : CompareImmPlus64<BR_GE_IMM_I64, BR_GE_IMM_I64_EXT,  setgt, i64, simm11_plus1, simm11_ext_plus1>;
defm : CompareImmPlus64<BR_GE_IMM_U64, BR_GE_IMM_U64_EXT, setugt, i64, uimm11_plus1, uimm11_ext_plus1>;
defm : CompareImmPlus32<BR_GE_IMM_I32, BR_GE_IMM_I32_EXT,  setgt, i32, simm11_plus1, simm11_ext_plus1>;
defm : CompareImmPlus32<BR_GE_IMM_U32, BR_GE_IMM_U32_EXT, setugt, i32, uimm11_plus1, uimm11_ext_plus1>;

//===----------------------------------------------------------------------===//
// i1 (branches/sext/zext/sext_inreg) and extra pattern is needed for a brcond
// without a setcc (i.e. where the condition was calculated elsewhere).
// i1 true is -1
//===----------------------------------------------------------------------===//
// if ([!] cond)
def : Pat<(brcond           i1:$cond  , bb:$dst), (BR_BS_IMM GR:$cond, 0, bb:$dst)>;
def : Pat<(brcond  (i1 (not i1:$cond)), bb:$dst), (BR_BC_IMM GR:$cond, 0, bb:$dst)>;

// if (cond [!|=]= [true|false])
def : Pat<(brcond (i1 (seteq i1:$a, (i1  0))), bb:$dst), (BR_BC_IMM GR:$a, 0, bb:$dst)>;
def : Pat<(brcond (i1 (setne i1:$a, (i1  0))), bb:$dst), (BR_BS_IMM GR:$a, 0, bb:$dst)>;
def : Pat<(brcond (i1 (seteq i1:$a, (i1 -1))), bb:$dst), (BR_BS_IMM GR:$a, 0, bb:$dst)>;
def : Pat<(brcond (i1 (setne i1:$a, (i1 -1))), bb:$dst), (BR_BC_IMM GR:$a, 0, bb:$dst)>;

// if (cond1 [!|=]= cond2)
def : Pat<(brcond (i1 (seteq i1:$a, i1:$b)), bb:$dst), (BR_EQ_I64 GR:$a, GR:$b, bb:$dst)>;
def : Pat<(brcond (i1 (setne i1:$a, i1:$b)), bb:$dst), (BR_NE_I64 GR:$a, GR:$b, bb:$dst)>;

//===----------------------------------------------------------------------===//
// branch on boolean
//===----------------------------------------------------------------------===//
multiclass BooleanBranchPat<ValueType Ty> {
  // branch on trunc to i1 modeled as 0-bit BR_BS_IMM/BR_BC_IMM
  def : Pat<(brcond (         i1 (trunc Ty:$val)  ), bb:$dst), (BR_BS_IMM Ty:$val, 0, bb:$dst)>;
  def : Pat<(brcond (i1 (not (i1 (trunc Ty:$val)))), bb:$dst), (BR_BC_IMM Ty:$val, 0, bb:$dst)>;

  def : Pat<(brcond (i1 (seteq (i1 (trunc Ty:$val)), (i1 -1))), bb:$dst), (BR_BS_IMM Ty:$val, 0, bb:$dst)>;
  def : Pat<(brcond (i1 (setne (i1 (trunc Ty:$val)), (i1  0))), bb:$dst), (BR_BS_IMM Ty:$val, 0, bb:$dst)>;
  def : Pat<(brcond (i1 (seteq (i1 (trunc Ty:$val)), (i1  0))), bb:$dst), (BR_BC_IMM Ty:$val, 0, bb:$dst)>;
  def : Pat<(brcond (i1 (setne (i1 (trunc Ty:$val)), (i1 -1))), bb:$dst), (BR_BC_IMM Ty:$val, 0, bb:$dst)>;
}
defm : BooleanBranchPat<i32>;
defm : BooleanBranchPat<i64>;
defm : BooleanBranchPat<i128>;

//===----------------------------------------------------------------------===//
// Loop: compare reg-reg and branch
//===----------------------------------------------------------------------===//
multiclass LoopCompareAndBranch<loop_opx opxCode, InstrItinClass itin = IIC_iu_instr>
{
  let isBranch = 1, isTerminator = 1, Constraints = "$rx = $ra" in {
    def NAME        : BRR_RabBranch    <opcode_loop, opxCode.value, (outs GR:$rx), (ins GR:$ra, GR:$rb, brtarget    :$offset),
                      !strconcat(opxCode.mnem, " $ra, $rb, $offset"), [], itin>;
    def NAME # _EXT : BRR_RabBranch_ext<opcode_loop, opxCode.value, (outs GR:$rx), (ins GR:$ra, GR:$rb, brtarget_ext:$offset),
                      !strconcat(opxCode.mnem, ".l $ra, $rb, $offset"), [], itin>;
  }
}

defm REP_LT_I64 : LoopCompareAndBranch<opcode_rep_lt_i64>;
defm REP_GT_I64 : LoopCompareAndBranch<opcode_rep_gt_i64>;
defm REP_LE_I64 : LoopCompareAndBranch<opcode_rep_le_i64>;
defm REP_GE_I64 : LoopCompareAndBranch<opcode_rep_ge_i64>;
defm REP_LT_U64 : LoopCompareAndBranch<opcode_rep_lt_u64>;
defm REP_GT_U64 : LoopCompareAndBranch<opcode_rep_gt_u64>;
defm REP_LE_U64 : LoopCompareAndBranch<opcode_rep_le_u64>;
defm REP_GE_U64 : LoopCompareAndBranch<opcode_rep_ge_u64>;
