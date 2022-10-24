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
                      !strconcat(opxCode.mnem,   "\t$ra, $rb, $offset"),
                      [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;
    def NAME # _EXT : BRR_RabBranch_ext<opcode_brr, opxCode.value, (outs), (ins GR:$ra, GR:$rb, brtarget_ext:$offset),
                      !strconcat(opxCode.mnem, ".l\t$ra, $rb, $offset"),
                      [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;
  }
}

defm B_EQ_D  : CompareAndBranch<brr_opx_b_eq_d,  seteq,   i64>;
defm B_NE_D  : CompareAndBranch<brr_opx_b_ne_d,  setne,   i64>;
defm BS_LT_D : CompareAndBranch<brr_opx_bs_lt_d, setlt,   i64>;
defm BS_LE_D : CompareAndBranch<brr_opx_bs_le_d, setle,   i64>;
defm BU_LT_D : CompareAndBranch<brr_opx_bu_lt_d, setult,  i64>;
defm BU_LE_D : CompareAndBranch<brr_opx_bu_le_d, setule,  i64>;

defm B_EQ_W  : CompareAndBranch<brr_opx_b_eq_w,  seteq,   i32>;
defm B_NE_W  : CompareAndBranch<brr_opx_b_ne_w,  setne,   i32>;
defm BS_LT_W : CompareAndBranch<brr_opx_bs_lt_w, setlt,   i32>;
defm BS_LE_W : CompareAndBranch<brr_opx_bs_le_w, setle,   i32>;
defm BU_LT_W : CompareAndBranch<brr_opx_bu_lt_w, setult,  i32>;
defm BU_LE_W : CompareAndBranch<brr_opx_bu_le_w, setule,  i32>;

//===----------------------------------------------------------------------===//
// Compare greater: use less
//===----------------------------------------------------------------------===//
def : Pat<(brcond (i1 (setgt  i64:$a, i64:$b)), bb:$dst), (BS_LT_D GR:$b, GR:$a, bb:$dst)>;
def : Pat<(brcond (i1 (setge  i64:$a, i64:$b)), bb:$dst), (BS_LE_D GR:$b, GR:$a, bb:$dst)>;
def : Pat<(brcond (i1 (setugt i64:$a, i64:$b)), bb:$dst), (BU_LT_D GR:$b, GR:$a, bb:$dst)>;
def : Pat<(brcond (i1 (setuge i64:$a, i64:$b)), bb:$dst), (BU_LE_D GR:$b, GR:$a, bb:$dst)>;

def : Pat<(brcond (i1 (setgt  i32:$a, i32:$b)), bb:$dst), (BS_LT_W GR:$b, GR:$a, bb:$dst)>;
def : Pat<(brcond (i1 (setge  i32:$a, i32:$b)), bb:$dst), (BS_LE_W GR:$b, GR:$a, bb:$dst)>;
def : Pat<(brcond (i1 (setugt i32:$a, i32:$b)), bb:$dst), (BU_LT_W GR:$b, GR:$a, bb:$dst)>;
def : Pat<(brcond (i1 (setuge i32:$a, i32:$b)), bb:$dst), (BU_LE_W GR:$b, GR:$a, bb:$dst)>;

//===----------------------------------------------------------------------===//
// Compare with zero and branch
//===----------------------------------------------------------------------===//
def : Pat<(brcond (i1 (seteq i64:$a, (i64 0))), bb:$dst), (B_EQ_D  GR:$a, (i64 gz), bb:$dst)>;
def : Pat<(brcond (i1 (setne i64:$a, (i64 0))), bb:$dst), (B_NE_D  GR:$a, (i64 gz), bb:$dst)>;
def : Pat<(brcond (i1 (setlt i64:$a, (i64 0))), bb:$dst), (BS_LT_D GR:$a, (i64 gz), bb:$dst)>;
def : Pat<(brcond (i1 (setle i64:$a, (i64 0))), bb:$dst), (BS_LE_D GR:$a, (i64 gz), bb:$dst)>;
def : Pat<(brcond (i1 (setgt i64:$a, (i64 0))), bb:$dst), (BS_LT_D (i64 gz), GR:$a, bb:$dst)>;
def : Pat<(brcond (i1 (setge i64:$a, (i64 0))), bb:$dst), (BS_LE_D (i64 gz), GR:$a, bb:$dst)>;

def : Pat<(brcond (i1 (seteq i32:$a, (i32 0))), bb:$dst), (B_EQ_W  GR:$a, (i32 gz), bb:$dst)>;
def : Pat<(brcond (i1 (setne i32:$a, (i32 0))), bb:$dst), (B_NE_W  GR:$a, (i32 gz), bb:$dst)>;
def : Pat<(brcond (i1 (setlt i32:$a, (i32 0))), bb:$dst), (BS_LT_W GR:$a, (i32 gz), bb:$dst)>;
def : Pat<(brcond (i1 (setle i32:$a, (i32 0))), bb:$dst), (BS_LE_W GR:$a, (i32 gz), bb:$dst)>;
def : Pat<(brcond (i1 (setgt i32:$a, (i32 0))), bb:$dst), (BS_LT_W (i32 gz), GR:$a, bb:$dst)>;
def : Pat<(brcond (i1 (setge i32:$a, (i32 0))), bb:$dst), (BS_LE_W (i32 gz), GR:$a, bb:$dst)>;

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
defm BBS : CompareAndBranch<brr_opx_b_bs, cmp_bitset,   i64>;
defm BBC : CompareAndBranch<brr_opx_b_bc, cmp_bitclear, i64>;

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
multiclass CompareBitAndBranch<brr_opx opxCode, PatFrag OpNode, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  let isBranch = 1, isTerminator = 1 in {
    def NAME        : BRR_RabBranch    <opcode_brr, opxCode.value, (outs), (ins GR:$ra, uimm7:$rb, brtarget    :$offset),
                      !strconcat(opxCode.mnem,   "\t$ra, $rb, $offset"), [(brcond (i1 (OpNode Ty:$ra, uimm7:$rb)), bb:$offset)], itin>;
    def NAME # _EXT : BRR_RabBranch_ext<opcode_brr, opxCode.value, (outs), (ins GR:$ra, uimm7:$rb, brtarget_ext:$offset),
                      !strconcat(opxCode.mnem, ".l\t$ra, $rb, $offset"), [(brcond (i1 (OpNode Ty:$ra, uimm7:$rb)), bb:$offset)], itin>;
  }
}

defm BBSI : CompareBitAndBranch<brr_opx_b_bsi, cmp_bitset,   i64>;
defm BBCI : CompareBitAndBranch<brr_opx_b_bci, cmp_bitclear, i64>;

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
multiclass CompareAndBranchImm<opcode_opx opcode, PatFrag OpNode, ValueType Ty,
   Operand immOp, Operand immOpEx, InstrItinClass itin = IIC_iu_instr>
{
  let isBranch = 1, isTerminator = 1 in {
    def NAME        : PRIMARY_RaImmBranch    <opcode, (outs), (ins GR:$ra, immOp  :$imm, brtarget    :$offset),
                      !strconcat(opcode.mnem,   "\t$ra, $imm, $offset"), [(brcond (i1 (OpNode Ty:$ra, immOp  :$imm)), bb:$offset)], itin>;
    def NAME # _EXT : PRIMARY_RaImmBranch_ext<opcode, (outs), (ins GR:$ra, immOpEx:$imm, brtarget_ext:$offset),
                      !strconcat(opcode.mnem, ".l\t$ra, $imm, $offset"), [(brcond (i1 (OpNode Ty:$ra, immOpEx:$imm)), bb:$offset)], itin>;
  }
}

defm BI_EQ_D   : CompareAndBranchImm<opcode_bi_eq_d,  seteq,  i64, simm11, simm11_ext>;
defm BI_NE_D   : CompareAndBranchImm<opcode_bi_ne_d,  setne,  i64, simm11, simm11_ext>;
defm BSI_LT_D  : CompareAndBranchImm<opcode_bsi_lt_d, setlt,  i64, simm11, simm11_ext>;
defm BSI_GE_D  : CompareAndBranchImm<opcode_bsi_ge_d, setge,  i64, simm11, simm11_ext>;
defm BUI_LT_D  : CompareAndBranchImm<opcode_bui_lt_d, setult, i64, uimm11, uimm11_ext>;
defm BUI_GE_D  : CompareAndBranchImm<opcode_bui_ge_d, setuge, i64, uimm11, uimm11_ext>;

defm BI_EQ_W   : CompareAndBranchImm<opcode_bi_eq_w,  seteq,  i32, simm11i32, simm11i32_ext>;
defm BI_NE_W   : CompareAndBranchImm<opcode_bi_ne_w,  setne,  i32, simm11i32, simm11i32_ext>;
defm BSI_LT_W  : CompareAndBranchImm<opcode_bsi_lt_w, setlt,  i32, simm11i32, simm11i32_ext>;
defm BSI_GE_W  : CompareAndBranchImm<opcode_bsi_ge_w, setge,  i32, simm11i32, simm11i32_ext>;
defm BUI_LT_W  : CompareAndBranchImm<opcode_bui_lt_w, setult, i32, uimm11i32, uimm11i32_ext>;
defm BUI_GE_W  : CompareAndBranchImm<opcode_bui_ge_w, setuge, i32, uimm11i32, uimm11i32_ext>;

defm BM_ALL    : CompareAndBranchImm<opcode_bm_all,    cmp_all,    i64, uimm11, uimm11_ext>;
defm BM_NOTALL : CompareAndBranchImm<opcode_bm_notall, cmp_notall, i64, uimm11, uimm11_ext>;
defm BM_NONE   : CompareAndBranchImm<opcode_bm_none,   cmp_none,   i64, uimm11, uimm11_ext>;
defm BM_ANY    : CompareAndBranchImm<opcode_bm_any,    cmp_any,    i64, uimm11, uimm11_ext>;

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
defm : CompareImmPlus64<BSI_LT_D, BSI_LT_D_EXT,  setle, i64, simm11_plus1, simm11_ext_plus1>;
defm : CompareImmPlus64<BUI_LT_D, BUI_LT_D_EXT, setule, i64, uimm11_plus1, uimm11_ext_plus1>;
defm : CompareImmPlus32<BSI_LT_W, BSI_LT_W_EXT,  setle, i32, simm11_plus1, simm11_ext_plus1>;
defm : CompareImmPlus32<BUI_LT_W, BUI_LT_W_EXT, setule, i32, uimm11_plus1, uimm11_ext_plus1>;
// "> 15" ==> ">= 16"
defm : CompareImmPlus64<BSI_GE_D, BSI_GE_D_EXT,  setgt, i64, simm11_plus1, simm11_ext_plus1>;
defm : CompareImmPlus64<BUI_GE_D, BUI_GE_D_EXT, setugt, i64, uimm11_plus1, uimm11_ext_plus1>;
defm : CompareImmPlus32<BSI_GE_W, BSI_GE_W_EXT,  setgt, i32, simm11_plus1, simm11_ext_plus1>;
defm : CompareImmPlus32<BUI_GE_W, BUI_GE_W_EXT, setugt, i32, uimm11_plus1, uimm11_ext_plus1>;

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
def : Pat<(brcond (i1 (seteq i1:$a, i1:$b)), bb:$dst), (B_EQ_D GR:$a, GR:$b, bb:$dst)>;
def : Pat<(brcond (i1 (setne i1:$a, i1:$b)), bb:$dst), (B_NE_D GR:$a, GR:$b, bb:$dst)>;

//===----------------------------------------------------------------------===//
// branch on boolean
//===----------------------------------------------------------------------===//
multiclass BooleanBranchPat<ValueType Ty> {
  // branch on trunc to i1 modeled as 0-bit BBSI/BBCI
  def : Pat<(brcond (         i1 (trunc Ty:$val)  ), bb:$dst), (BBSI Ty:$val, 0, bb:$dst)>;
  def : Pat<(brcond (i1 (not (i1 (trunc Ty:$val)))), bb:$dst), (BBCI Ty:$val, 0, bb:$dst)>;

  def : Pat<(brcond (i1 (seteq (i1 (trunc Ty:$val)), (i1 -1))), bb:$dst), (BBSI Ty:$val, 0, bb:$dst)>;
  def : Pat<(brcond (i1 (setne (i1 (trunc Ty:$val)), (i1 0))), bb:$dst), (BBSI Ty:$val, 0, bb:$dst)>;
  def : Pat<(brcond (i1 (seteq (i1 (trunc Ty:$val)), (i1 0))), bb:$dst), (BBCI Ty:$val, 0, bb:$dst)>;
  def : Pat<(brcond (i1 (setne (i1 (trunc Ty:$val)), (i1 -1))), bb:$dst), (BBCI Ty:$val, 0, bb:$dst)>;
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
                      !strconcat(opxCode.mnem,   "\t$ra, $rb, $offset"), [], itin>;
    def NAME # _EXT : BRR_RabBranch_ext<opcode_loop, opxCode.value, (outs GR:$rx), (ins GR:$ra, GR:$rb, brtarget_ext:$offset),
                      !strconcat(opxCode.mnem, ".l\t$ra, $rb, $offset"), [], itin>;
  }
}

defm REPS_LT_D : LoopCompareAndBranch<loop_opx_reps_lt_d>;
defm REPS_GT_D : LoopCompareAndBranch<loop_opx_reps_gt_d>;
defm REPS_LE_D : LoopCompareAndBranch<loop_opx_reps_le_d>;
defm REPS_GE_D : LoopCompareAndBranch<loop_opx_reps_ge_d>;
defm REPU_LT_D : LoopCompareAndBranch<loop_opx_repu_lt_d>;
defm REPU_GT_D : LoopCompareAndBranch<loop_opx_repu_gt_d>;
defm REPU_LE_D : LoopCompareAndBranch<loop_opx_repu_le_d>;
defm REPU_GE_D : LoopCompareAndBranch<loop_opx_repu_ge_d>;
