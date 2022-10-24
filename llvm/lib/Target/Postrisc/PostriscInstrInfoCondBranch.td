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

// opcode_br_32|64|128 reg-reg branches
multiclass
CompareAndBranch_32<br_32_opx opx, PatFrag OpNode, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  let isBranch = 1, isTerminator = 1 in
  def NAME : BRR_RabBranch<opcode_br_32, opx.value,
                 (outs), (ins GR:$ra, GR:$rb, brtarget:$offset),
                 !strconcat(opx.mnem, " $ra, $rb, $offset"),
                 [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;

  let isBranch = 1, isTerminator = 1 in
  def NAME # _EXT : BRR_RabBranch_ext<opcode_br_32, opx.value,
                 (outs), (ins GR:$ra, GR:$rb, brtarget_ext:$offset),
                 !strconcat(opx.mnem, ".l $ra, $rb, $offset"),
                 [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;
}

multiclass
CompareAndBranch_64<br_64_opx opx, PatFrag OpNode, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  let isBranch = 1, isTerminator = 1 in
  def NAME : BRR_RabBranch<opcode_br_64, opx.value,
                 (outs), (ins GR:$ra, GR:$rb, brtarget:$offset),
                 !strconcat(opx.mnem, " $ra, $rb, $offset"),
                 [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;

  let isBranch = 1, isTerminator = 1 in
  def NAME # _EXT : BRR_RabBranch_ext<opcode_br_64, opx.value,
                 (outs), (ins GR:$ra, GR:$rb, brtarget_ext:$offset),
                 !strconcat(opx.mnem, ".l $ra, $rb, $offset"),
                 [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;
}

multiclass
CompareAndBranch_128<br_128_opx opx, PatFrag OpNode, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  let isBranch = 1, isTerminator = 1 in
  def NAME : BRR_RabBranch<opcode_br_128, opx.value,
                 (outs), (ins GR:$ra, GR:$rb, brtarget:$offset),
                 !strconcat(opx.mnem, " $ra, $rb, $offset"),
                 [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;

  let isBranch = 1, isTerminator = 1 in
  def NAME # _EXT : BRR_RabBranch_ext<opcode_br_128, opx.value,
                 (outs), (ins GR:$ra, GR:$rb, brtarget_ext:$offset),
                 !strconcat(opx.mnem, ".l $ra, $rb, $offset"),
                 [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;
}

//===----------------------------------------------------------------------===//
// Compare reg-reg and branch
//===----------------------------------------------------------------------===//
defm BR_EQ_I64 : CompareAndBranch_64<opcode_br_eq_i64, seteq,  i64>;
defm BR_NE_I64 : CompareAndBranch_64<opcode_br_ne_i64, setne,  i64>;
defm BR_LT_I64 : CompareAndBranch_64<opcode_br_lt_i64, setlt,  i64>;
defm BR_LT_U64 : CompareAndBranch_64<opcode_br_lt_u64, setult, i64>;
defm BR_GE_I64 : CompareAndBranch_64<opcode_br_ge_i64, setge,  i64>;
defm BR_GE_U64 : CompareAndBranch_64<opcode_br_ge_u64, setuge, i64>;

defm BR_EQ_I32 : CompareAndBranch_32<opcode_br_eq_i32, seteq,  i32>;
defm BR_NE_I32 : CompareAndBranch_32<opcode_br_ne_i32, setne,  i32>;
defm BR_LT_I32 : CompareAndBranch_32<opcode_br_lt_i32, setlt,  i32>;
defm BR_LT_U32 : CompareAndBranch_32<opcode_br_lt_u32, setult, i32>;
defm BR_GE_I32 : CompareAndBranch_32<opcode_br_ge_i32, setge,  i32>;
defm BR_GE_U32 : CompareAndBranch_32<opcode_br_ge_u32, setuge, i32>;

defm BR_EQ_I128 : CompareAndBranch_128<opcode_br_eq_i128, seteq,  i128>;
defm BR_NE_I128 : CompareAndBranch_128<opcode_br_ne_i128, setne,  i128>;
defm BR_LT_I128 : CompareAndBranch_128<opcode_br_lt_i128, setlt,  i128>;
defm BR_LT_U128 : CompareAndBranch_128<opcode_br_lt_u128, setult, i128>;
defm BR_GE_I128 : CompareAndBranch_128<opcode_br_ge_i128, setge,  i128>;
defm BR_GE_U128 : CompareAndBranch_128<opcode_br_ge_u128, setuge, i128>;

//===----------------------------------------------------------------------===//
// Compare reg-reg and branch: swap args
//===----------------------------------------------------------------------===//
multiclass BranchSwappedArgs<InstBase LT, InstBase LTU, InstBase GE, InstBase GEU, ValueType Ty>
{
  def : Pat<(brcond (i1 (setgt  Ty:$a, Ty:$b)), bb:$dst), (LT  GR:$b, GR:$a, bb:$dst)>;
  def : Pat<(brcond (i1 (setugt Ty:$a, Ty:$b)), bb:$dst), (LTU GR:$b, GR:$a, bb:$dst)>;
  def : Pat<(brcond (i1 (setle  Ty:$a, Ty:$b)), bb:$dst), (GE  GR:$b, GR:$a, bb:$dst)>;
  def : Pat<(brcond (i1 (setule Ty:$a, Ty:$b)), bb:$dst), (GEU GR:$b, GR:$a, bb:$dst)>;
}

defm : BranchSwappedArgs<BR_LT_I32,  BR_LT_U32,  BR_GE_I32,  BR_GE_U32,  i32>;
defm : BranchSwappedArgs<BR_LT_I64,  BR_LT_U64,  BR_GE_I64,  BR_GE_U64,  i64>;
defm : BranchSwappedArgs<BR_LT_I128, BR_LT_U128, BR_GE_I128, BR_GE_U128, i128>;

//===----------------------------------------------------------------------===//
//
// Compare one bit and branch
//
//===----------------------------------------------------------------------===//
def cmp_bitset   : PatFrag<(ops node:$x, node:$y), (setne (and (srl node:$x, node:$y), 1), 0)>;
def cmp_bitclear : PatFrag<(ops node:$x, node:$y), (seteq (and (srl node:$x, node:$y), 1), 0)>;

multiclass CompareAndBranchMisc<br_misc_opx opxCode, PatFrag OpNode, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  let isBranch = 1, isTerminator = 1 in {
    def NAME        : BRR_RabBranch    <opcode_br_misc, opxCode.value, (outs), (ins GR:$ra, GR:$rb, brtarget    :$offset),
                      !strconcat(opxCode.mnem, " $ra, $rb, $offset"),
                      [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;
    def NAME # _EXT : BRR_RabBranch_ext<opcode_br_misc, opxCode.value, (outs), (ins GR:$ra, GR:$rb, brtarget_ext:$offset),
                      !strconcat(opxCode.mnem, ".l $ra, $rb, $offset"),
                      [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;
  }
}

defm BR_BS : CompareAndBranchMisc<opcode_br_bs, cmp_bitset,   i64>;
defm BR_BC : CompareAndBranchMisc<opcode_br_bc, cmp_bitclear, i64>;

// same instructions for all types: i32,i64,i128
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

defm : CompareBitPat<BR_BS, i32,  1, 0>;
defm : CompareBitPat<BR_BC, i32,  0, 1>;
defm : CompareBitPat<BR_BS, i64,  1, 0>;
defm : CompareBitPat<BR_BC, i64,  0, 1>;
defm : CompareBitPat<BR_BS, i128, 1, 0>;
defm : CompareBitPat<BR_BC, i128, 0, 1>;

//===----------------------------------------------------------------------===//
//
// Compare one bit (immediate shift) and branch
//
//===----------------------------------------------------------------------===//
multiclass CompareBitAndBranchMisc<br_misc_opx opxCode, PatFrag OpNode, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  let isBranch = 1, isTerminator = 1 in {
    def NAME        : BRR_RabBranch    <opcode_br_misc, opxCode.value, (outs), (ins GR:$ra, uimm7:$rb, brtarget    :$offset),
                      !strconcat(opxCode.mnem, " $ra, $rb, $offset"), [(brcond (i1 (OpNode Ty:$ra, uimm7:$rb)), bb:$offset)], itin>;
    def NAME # _EXT : BRR_RabBranch_ext<opcode_br_misc, opxCode.value, (outs), (ins GR:$ra, uimm7:$rb, brtarget_ext:$offset),
                      !strconcat(opxCode.mnem, ".l $ra, $rb, $offset"), [(brcond (i1 (OpNode Ty:$ra, uimm7:$rb)), bb:$offset)], itin>;
  }
}

defm BR_BS_IMM : CompareBitAndBranchMisc<opcode_br_bs_imm, cmp_bitset,   i64>;
defm BR_BC_IMM : CompareBitAndBranchMisc<opcode_br_bc_imm, cmp_bitclear, i64>;

multiclass
CompareBitImmPat<InstBase Op, ValueType Ty, int direct_value, int invert_value>
{
  def : Pat<(brcond (i1 (seteq (and (srl Ty:$a, uimm7:$b), 1), direct_value)), bb:$dst), (Op GR:$a, uimm7:$b, bb:$dst)>;
  def : Pat<(brcond (i1 (seteq (and (sra Ty:$a, uimm7:$b), 1), direct_value)), bb:$dst), (Op GR:$a, uimm7:$b, bb:$dst)>;
  def : Pat<(brcond (i1 (setne (and (srl Ty:$a, uimm7:$b), 1), invert_value)), bb:$dst), (Op GR:$a, uimm7:$b, bb:$dst)>;
  def : Pat<(brcond (i1 (setne (and (sra Ty:$a, uimm7:$b), 1), invert_value)), bb:$dst), (Op GR:$a, uimm7:$b, bb:$dst)>;
}

defm : CompareBitImmPat<BR_BS_IMM, i64,  1, 0>;
defm : CompareBitImmPat<BR_BC_IMM, i64,  0, 1>;
defm : CompareBitImmPat<BR_BS_IMM, i32,  1, 0>;
defm : CompareBitImmPat<BR_BC_IMM, i32,  0, 1>;
defm : CompareBitImmPat<BR_BS_IMM, i128, 1, 0>;
defm : CompareBitImmPat<BR_BC_IMM, i128, 0, 1>;

// it's ugly but works
foreach III = 0-31 in {
  defvar BIT = !shl(1,III);
  def : Pat<(brcond (i1 (seteq (and i32:$a, BIT),   0)), bb:$dst), (BR_BC_IMM  GR:$a, III, bb:$dst)>;
  def : Pat<(brcond (i1 (setne (and i32:$a, BIT), BIT)), bb:$dst), (BR_BC_IMM  GR:$a, III, bb:$dst)>;
  def : Pat<(brcond (i1 (setne (and i32:$a, BIT),   0)), bb:$dst), (BR_BS_IMM  GR:$a, III, bb:$dst)>;
  def : Pat<(brcond (i1 (seteq (and i32:$a, BIT), BIT)), bb:$dst), (BR_BS_IMM  GR:$a, III, bb:$dst)>;
}
foreach III = 0-63 in {
  defvar BIT = !shl(1,III);
  def : Pat<(brcond (i1 (seteq (and i64:$a, BIT),   0)), bb:$dst), (BR_BC_IMM  GR:$a, III, bb:$dst)>;
  def : Pat<(brcond (i1 (setne (and i64:$a, BIT), BIT)), bb:$dst), (BR_BC_IMM  GR:$a, III, bb:$dst)>;
  def : Pat<(brcond (i1 (setne (and i64:$a, BIT),   0)), bb:$dst), (BR_BS_IMM  GR:$a, III, bb:$dst)>;
  def : Pat<(brcond (i1 (seteq (and i64:$a, BIT), BIT)), bb:$dst), (BR_BS_IMM  GR:$a, III, bb:$dst)>;

  def : Pat<(brcond (i1 (seteq (and i128:$a, BIT),   0)), bb:$dst), (BR_BC_IMM  GR:$a, III, bb:$dst)>;
  def : Pat<(brcond (i1 (setne (and i128:$a, BIT), BIT)), bb:$dst), (BR_BC_IMM  GR:$a, III, bb:$dst)>;
  def : Pat<(brcond (i1 (setne (and i128:$a, BIT),   0)), bb:$dst), (BR_BS_IMM  GR:$a, III, bb:$dst)>;
  def : Pat<(brcond (i1 (seteq (and i128:$a, BIT), BIT)), bb:$dst), (BR_BS_IMM  GR:$a, III, bb:$dst)>;
}

//===----------------------------------------------------------------------===//
//
// Compare immediate and branch
//
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

//===----------------------------------------------------------------------===//
//
// Compare with zero immediate and branch
//
//===----------------------------------------------------------------------===//
multiclass CompareZeroAndBranch<InstBase EQ, InstBase NE, InstBase LT, InstBase GE, ValueType Ty>
{
  // Compare with zero and branch
  def : Pat<(brcond (i1 (seteq  Ty:$a, (Ty 0))), bb:$dst), (EQ  GR:$a, (Ty 0), bb:$dst)>;
  def : Pat<(brcond (i1 (setne  Ty:$a, (Ty 0))), bb:$dst), (NE  GR:$a, (Ty 0), bb:$dst)>;
  def : Pat<(brcond (i1 (setlt  Ty:$a, (Ty 0))), bb:$dst), (LT  GR:$a, (Ty 0), bb:$dst)>;
  def : Pat<(brcond (i1 (setge  Ty:$a, (Ty 0))), bb:$dst), (GE  GR:$a, (Ty 0), bb:$dst)>;
  // GT => GE, LE => LT
  def : Pat<(brcond (i1 (setgt  Ty:$a, (Ty 0))), bb:$dst), (GE  GR:$a, (Ty 1), bb:$dst)>;
  def : Pat<(brcond (i1 (setle  Ty:$a, (Ty 0))), bb:$dst), (LT  GR:$a, (Ty 1), bb:$dst)>;
}

defm : CompareZeroAndBranch<BR_EQ_IMM_I32,  BR_NE_IMM_I32,  BR_LT_IMM_I32,  BR_GE_IMM_I32,  i32>;
defm : CompareZeroAndBranch<BR_EQ_IMM_I64,  BR_NE_IMM_I64,  BR_LT_IMM_I64,  BR_GE_IMM_I64,  i64>;
// FIXME: i128 failed
// defm : CompareZeroAndBranch<BR_EQ_IMM_I128, BR_NE_IMM_I128, BR_LT_IMM_I128, BR_GE_IMM_I128, i128>;

//===----------------------------------------------------------------------===//
//
// Compare immediate+1 and branch (GT via GE, LE via LT)
//
//===----------------------------------------------------------------------===//
multiclass BranchSimmPlus64<InstBase Inst, InstBaseExt InstExt, PatFrag OpNode, ValueType Ty, PatLeaf immOp, PatLeaf immOpEx>
{
  def : Pat<(brcond (i1 (OpNode Ty:$ra, immOp  :$imm)), bb:$offset), (Inst    GR:$ra, (Plus1_SEXT imm:$imm), bb:$offset)>;
  def : Pat<(brcond (i1 (OpNode Ty:$ra, immOpEx:$imm)), bb:$offset), (InstExt GR:$ra, (Plus1_SEXT imm:$imm), bb:$offset)>;
}

multiclass BranchSimmPlus32<InstBase Inst, InstBaseExt InstExt, PatFrag OpNode, ValueType Ty, PatLeaf immOp, PatLeaf immOpEx>
{
  def : Pat<(brcond (i1 (OpNode Ty:$ra, immOp  :$imm)), bb:$offset), (Inst    GR:$ra, (Plus1_SEXT_32 imm:$imm), bb:$offset)>;
  def : Pat<(brcond (i1 (OpNode Ty:$ra, immOpEx:$imm)), bb:$offset), (InstExt GR:$ra, (Plus1_SEXT_32 imm:$imm), bb:$offset)>;
}

multiclass BranchUimmPlus64<InstBase Inst, InstBaseExt InstExt, PatFrag OpNode, ValueType Ty, PatLeaf immOp, PatLeaf immOpEx>
{
  def : Pat<(brcond (i1 (OpNode Ty:$ra, immOp  :$imm)), bb:$offset), (Inst    GR:$ra, (Plus1_ZEXT imm:$imm), bb:$offset)>;
  def : Pat<(brcond (i1 (OpNode Ty:$ra, immOpEx:$imm)), bb:$offset), (InstExt GR:$ra, (Plus1_ZEXT imm:$imm), bb:$offset)>;
}

multiclass BranchUimmPlus32<InstBase Inst, InstBaseExt InstExt, PatFrag OpNode, ValueType Ty, PatLeaf immOp, PatLeaf immOpEx>
{
  def : Pat<(brcond (i1 (OpNode Ty:$ra, immOp  :$imm)), bb:$offset), (Inst    GR:$ra, (Plus1_ZEXT_32 imm:$imm), bb:$offset)>;
  def : Pat<(brcond (i1 (OpNode Ty:$ra, immOpEx:$imm)), bb:$offset), (InstExt GR:$ra, (Plus1_ZEXT_32 imm:$imm), bb:$offset)>;
}

// "<= 15" ==> "< 16"
defm : BranchSimmPlus32<BR_LT_IMM_I32,  BR_LT_IMM_I32_EXT,   setle, i32,  simm11_plus1, simm11_ext_plus1>;
defm : BranchSimmPlus64<BR_LT_IMM_I64,  BR_LT_IMM_I64_EXT,   setle, i64,  simm11_plus1, simm11_ext_plus1>;
defm : BranchSimmPlus64<BR_LT_IMM_I128, BR_LT_IMM_I128_EXT,  setle, i128, simm11_plus1, simm11_ext_plus1>;

defm : BranchUimmPlus32<BR_LT_IMM_U32,  BR_LT_IMM_U32_EXT,  setule, i32,  uimm11_plus1, uimm11_ext_plus1>;
defm : BranchUimmPlus64<BR_LT_IMM_U64,  BR_LT_IMM_U64_EXT,  setule, i64,  uimm11_plus1, uimm11_ext_plus1>;
defm : BranchUimmPlus64<BR_LT_IMM_U128, BR_LT_IMM_U128_EXT, setule, i128, uimm11_plus1, uimm11_ext_plus1>;

// "> 15" ==> ">= 16"
defm : BranchSimmPlus32<BR_GE_IMM_I32,  BR_GE_IMM_I32_EXT,   setgt, i32,  simm11_plus1, simm11_ext_plus1>;
defm : BranchSimmPlus64<BR_GE_IMM_I64,  BR_GE_IMM_I64_EXT,   setgt, i64,  simm11_plus1, simm11_ext_plus1>;
defm : BranchSimmPlus64<BR_GE_IMM_I128, BR_GE_IMM_I128_EXT,  setgt, i128, simm11_plus1, simm11_ext_plus1>;

defm : BranchUimmPlus32<BR_GE_IMM_U32,  BR_GE_IMM_U32_EXT,  setugt, i32,  uimm11_plus1, uimm11_ext_plus1>;
defm : BranchUimmPlus64<BR_GE_IMM_U64,  BR_GE_IMM_U64_EXT,  setugt, i64,  uimm11_plus1, uimm11_ext_plus1>;
defm : BranchUimmPlus64<BR_GE_IMM_U128, BR_GE_IMM_U128_EXT, setugt, i128, uimm11_plus1, uimm11_ext_plus1>;

//===----------------------------------------------------------------------===//
//
// Compare bitmask and branch
//
//===----------------------------------------------------------------------===//
def cmp_all      : PatFrag<(ops node:$x, node:$y), (seteq (and node:$x, node:$y), node:$y)>;
def cmp_notall   : PatFrag<(ops node:$x, node:$y), (setne (and node:$x, node:$y), node:$y)>;
def cmp_none     : PatFrag<(ops node:$x, node:$y), (seteq (and node:$x, node:$y), 0)>;
def cmp_any      : PatFrag<(ops node:$x, node:$y), (setne (and node:$x, node:$y), 0)>;

// same mask-based branches for all: i32, i64, i128
// FIXME: can model different type immediates only via codegen

defm BR_MASK_ALL_I64    : CompareAndBranchImm<opcode_br_mask_all,    cmp_all,    i64, uimm11, uimm11_ext>;
defm BR_MASK_NOTALL_I64 : CompareAndBranchImm<opcode_br_mask_notall, cmp_notall, i64, uimm11, uimm11_ext>;
defm BR_MASK_NONE_I64   : CompareAndBranchImm<opcode_br_mask_none,   cmp_none,   i64, uimm11, uimm11_ext>;
defm BR_MASK_ANY_I64    : CompareAndBranchImm<opcode_br_mask_any,    cmp_any,    i64, uimm11, uimm11_ext>;

let isCodeGenOnly = 1 in {
  defm BR_MASK_ALL_I32     : CompareAndBranchImm<opcode_br_mask_all,    cmp_all,    i32, uimm11i32, uimm11i32_ext>;
  defm BR_MASK_NOTALL_I32  : CompareAndBranchImm<opcode_br_mask_notall, cmp_notall, i32, uimm11i32, uimm11i32_ext>;
  defm BR_MASK_NONE_I32    : CompareAndBranchImm<opcode_br_mask_none,   cmp_none,   i32, uimm11i32, uimm11i32_ext>;
  defm BR_MASK_ANY_I32     : CompareAndBranchImm<opcode_br_mask_any,    cmp_any,    i32, uimm11i32, uimm11i32_ext>;

  defm BR_MASK_ALL_I128    : CompareAndBranchImm<opcode_br_mask_all,    cmp_all,    i128, uimm11i128, uimm11i128_ext>;
  defm BR_MASK_NOTALL_I128 : CompareAndBranchImm<opcode_br_mask_notall, cmp_notall, i128, uimm11i128, uimm11i128_ext>;
  defm BR_MASK_NONE_I128   : CompareAndBranchImm<opcode_br_mask_none,   cmp_none,   i128, uimm11i128, uimm11i128_ext>;
  defm BR_MASK_ANY_I128    : CompareAndBranchImm<opcode_br_mask_any,    cmp_any,    i128, uimm11i128, uimm11i128_ext>;
}

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
// Loop: compare reg-reg and branch,  (uimm stride 6(+23))
//===----------------------------------------------------------------------===//
def loop_stride_xform : SDNodeXForm<imm, [{
  return getI64Imm(N->getZExtValue()+1, SDLoc(N));
}]>;
def loop_stride : Operand<i64>, IntImmLeaf<i64, [{ return isZextInt(Imm-1, 6); }], loop_stride_xform> {
  let DecoderMethod = "DecodeLoopStride<6>";
}

// simm52 extended (10+42) immediate (stride_ext)
def loop_stride_ext_xform : SDNodeXForm<imm, [{
  return getI64Imm(N->getZExtValue()+1, SDLoc(N));
}]>;
def loop_stride_ext : Operand<i64>, IntImmLeaf<i64, [{ return isZextInt(Imm-1, 6+23); }], loop_stride_ext_xform> {
  let DecoderMethod = "DecodeLoopStride<6+23>";
}

multiclass
LoopBranch<loop_opx opx, InstrItinClass itin = IIC_iu_instr>
{
  let isBranch = 1, isTerminator = 1, Constraints = "$rt = $ra" in {
    def NAME : BRR_Loop<opcode_loop, opx.value,
                 (outs GR:$rt), (ins GR:$ra, GR:$rb, loop_stride:$stride, brtarget:$offset),
                 !strconcat(opx.mnem, " $ra, $rb, $stride, $offset"),
                 [], itin>;

    def NAME # _EXT : BRR_Loop_ext<opcode_loop, opx.value,
                 (outs GR:$rt), (ins GR:$ra, GR:$rb, loop_stride_ext:$stride, brtarget_ext:$offset),
                 !strconcat(opx.mnem, ".l $ra, $rb, $stride, $offset"),
                 [], itin>;
  }
}

defm REP_LT_I64 : LoopBranch<opcode_rep_lt_i64>;
defm REP_GT_I64 : LoopBranch<opcode_rep_gt_i64>;
defm REP_LE_I64 : LoopBranch<opcode_rep_le_i64>;
defm REP_GE_I64 : LoopBranch<opcode_rep_ge_i64>;
defm REP_LT_U64 : LoopBranch<opcode_rep_lt_u64>;
defm REP_GT_U64 : LoopBranch<opcode_rep_gt_u64>;
defm REP_LE_U64 : LoopBranch<opcode_rep_le_u64>;
defm REP_GE_U64 : LoopBranch<opcode_rep_ge_u64>;

defm REP_LT_I32 : LoopBranch<opcode_rep_lt_i32>;
defm REP_GT_I32 : LoopBranch<opcode_rep_gt_i32>;
defm REP_LE_I32 : LoopBranch<opcode_rep_le_i32>;
defm REP_GE_I32 : LoopBranch<opcode_rep_ge_i32>;
defm REP_LT_U32 : LoopBranch<opcode_rep_lt_u32>;
defm REP_GT_U32 : LoopBranch<opcode_rep_gt_u32>;
defm REP_LE_U32 : LoopBranch<opcode_rep_le_u32>;
defm REP_GE_U32 : LoopBranch<opcode_rep_ge_u32>;

//===----------------------------------------------------------------------===//
// fp branches
//===----------------------------------------------------------------------===//
defm BR_OEQ_F32 : CompareAndBranch_32<opcode_br_oeq_f32, setoeq, f32>;
defm BR_ONE_F32 : CompareAndBranch_32<opcode_br_one_f32, setone, f32>;
defm BR_OLT_F32 : CompareAndBranch_32<opcode_br_olt_f32, setolt, f32>;
defm BR_OGE_F32 : CompareAndBranch_32<opcode_br_oge_f32, setoge, f32>;
defm BR_O_F32   : CompareAndBranch_32<opcode_br_o_f32,   seto,   f32>;
defm BR_UEQ_F32 : CompareAndBranch_32<opcode_br_ueq_f32, setueq, f32>;
defm BR_UNE_F32 : CompareAndBranch_32<opcode_br_une_f32, setune, f32>;
defm BR_ULT_F32 : CompareAndBranch_32<opcode_br_ult_f32, setult, f32>;
defm BR_UGE_F32 : CompareAndBranch_32<opcode_br_uge_f32, setuge, f32>;
defm BR_U_F32   : CompareAndBranch_32<opcode_br_u_f32,   setuo,  f32>;

defm BR_OEQ_F64 : CompareAndBranch_64<opcode_br_oeq_f64, setoeq, f64>;
defm BR_ONE_F64 : CompareAndBranch_64<opcode_br_one_f64, setone, f64>;
defm BR_OLT_F64 : CompareAndBranch_64<opcode_br_olt_f64, setolt, f64>;
defm BR_OGE_F64 : CompareAndBranch_64<opcode_br_oge_f64, setoge, f64>;
defm BR_O_F64   : CompareAndBranch_64<opcode_br_o_f64,   seto,   f64>;
defm BR_UEQ_F64 : CompareAndBranch_64<opcode_br_ueq_f64, setueq, f64>;
defm BR_UNE_F64 : CompareAndBranch_64<opcode_br_une_f64, setune, f64>;
defm BR_ULT_F64 : CompareAndBranch_64<opcode_br_ult_f64, setult, f64>;
defm BR_UGE_F64 : CompareAndBranch_64<opcode_br_uge_f64, setuge, f64>;
defm BR_U_F64   : CompareAndBranch_64<opcode_br_u_f64,   setuo,  f64>;

defm BR_OEQ_F128 : CompareAndBranch_128<opcode_br_oeq_f128, setoeq, f128>;
defm BR_ONE_F128 : CompareAndBranch_128<opcode_br_one_f128, setone, f128>;
defm BR_OLT_F128 : CompareAndBranch_128<opcode_br_olt_f128, setolt, f128>;
defm BR_OGE_F128 : CompareAndBranch_128<opcode_br_oge_f128, setoge, f128>;
defm BR_O_F128   : CompareAndBranch_128<opcode_br_o_f128,   seto,   f128>;
defm BR_UEQ_F128 : CompareAndBranch_128<opcode_br_ueq_f128, setueq, f128>;
defm BR_UNE_F128 : CompareAndBranch_128<opcode_br_une_f128, setune, f128>;
defm BR_ULT_F128 : CompareAndBranch_128<opcode_br_ult_f128, setult, f128>;
defm BR_UGE_F128 : CompareAndBranch_128<opcode_br_uge_f128, setuge, f128>;
defm BR_U_F128   : CompareAndBranch_128<opcode_br_u_f128,   setuo,  f128>;

multiclass FP_SCALAR_BRANCH_PATTERNS<ValueType Ty>
{
  // swap args
  def : Pat<(brcond (i1 (setogt Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("BR_OLT_" # NAME) GR:$rb, GR:$ra, bb:$dst)>;
  def : Pat<(brcond (i1 (setole Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("BR_OGE_" # NAME) GR:$rb, GR:$ra, bb:$dst)>;
  def : Pat<(brcond (i1 (setugt Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("BR_ULT_" # NAME) GR:$rb, GR:$ra, bb:$dst)>;
  def : Pat<(brcond (i1 (setule Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("BR_UGE_" # NAME) GR:$rb, GR:$ra, bb:$dst)>;

  // branch: don't care variants
  // fast-math doesn't differ ordered/unordered and uses ordered forms
  def : Pat<(brcond (i1 (seteq Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("BR_OEQ_" # NAME) GR:$ra, GR:$rb, bb:$dst)>;
  def : Pat<(brcond (i1 (setne Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("BR_ONE_" # NAME) GR:$ra, GR:$rb, bb:$dst)>;
  def : Pat<(brcond (i1 (setlt Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("BR_OLT_" # NAME) GR:$ra, GR:$rb, bb:$dst)>;
  def : Pat<(brcond (i1 (setge Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("BR_OGE_" # NAME) GR:$ra, GR:$rb, bb:$dst)>;

  // fast-math: swap args
  def : Pat<(brcond (i1 (setgt Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("BR_OLT_" # NAME) GR:$rb, GR:$ra, bb:$dst)>;
  def : Pat<(brcond (i1 (setle Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("BR_OGE_" # NAME) GR:$rb, GR:$ra, bb:$dst)>;
}

defm F32  : FP_SCALAR_BRANCH_PATTERNS<f32>;
defm F64  : FP_SCALAR_BRANCH_PATTERNS<f64>;
defm F128 : FP_SCALAR_BRANCH_PATTERNS<f128>;
