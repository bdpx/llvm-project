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
multiclass CompareAndBranch<brr_opx opxCode, string OpcStr, PatFrag OpNode, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  let isBranch = 1, isTerminator = 1 in {
    def NAME        : BRR_RabBranch    <opcode_brr, opxCode.value, (outs), (ins GR:$ra, GR:$rb, brtarget    :$offset), !strconcat(OpcStr,   "\t$ra, $rb, $offset"), [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;
    def NAME # _EXT : BRR_RabBranch_ext<opcode_brr, opxCode.value, (outs), (ins GR:$ra, GR:$rb, brtarget_ext:$offset), !strconcat(OpcStr, ".l\t$ra, $rb, $offset"), [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;
  }
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
  let isBranch = 1, isTerminator = 1 in {
    def NAME        : BRR_RabBranch    <opcode_brr, opxCode.value, (outs), (ins GR:$ra, uimm7:$rb, brtarget    :$offset), !strconcat(OpcStr,   "\t$ra, $rb, $offset"), [(brcond (i1 (OpNode Ty:$ra, uimm7:$rb)), bb:$offset)], itin>;
    def NAME # _EXT : BRR_RabBranch_ext<opcode_brr, opxCode.value, (outs), (ins GR:$ra, uimm7:$rb, brtarget_ext:$offset), !strconcat(OpcStr, ".l\t$ra, $rb, $offset"), [(brcond (i1 (OpNode Ty:$ra, uimm7:$rb)), bb:$offset)], itin>;
  }
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
  let isBranch = 1, isTerminator = 1 in {
    def NAME        : PRIMARY_RaImmBranch    <opcode, (outs), (ins GR:$ra, immOp  :$imm, brtarget    :$offset), !strconcat(OpcStr,   "\t$ra, $imm, $offset"), [(brcond (i1 (OpNode Ty:$ra, immOp  :$imm)), bb:$offset)], itin>;
    def NAME # _EXT : PRIMARY_RaImmBranch_ext<opcode, (outs), (ins GR:$ra, immOpEx:$imm, brtarget_ext:$offset), !strconcat(OpcStr, ".l\t$ra, $imm, $offset"), [(brcond (i1 (OpNode Ty:$ra, immOpEx:$imm)), bb:$offset)], itin>;
  }
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
multiclass LoopCompareAndBranch<loop_opx opxCode, string OpcStr, InstrItinClass itin = IIC_iu_instr>
{
  let isBranch = 1, isTerminator = 1, Constraints = "$rx = $ra" in {
    def NAME        : BRR_RabBranch    <opcode_loop, opxCode.value, (outs GR:$rx), (ins GR:$ra, GR:$rb, brtarget    :$offset), !strconcat(OpcStr, "\t$ra, $rb, $offset"), [], itin>;
    def NAME # _EXT : BRR_RabBranch_ext<opcode_loop, opxCode.value, (outs GR:$rx), (ins GR:$ra, GR:$rb, brtarget_ext:$offset), !strconcat(OpcStr, ".l\t$ra, $rb, $offset"), [], itin>;
  }
}

defm REPDLT  : LoopCompareAndBranch<loop_opx_repdlt,  "repdlt">;
defm REPDGT  : LoopCompareAndBranch<loop_opx_repdgt,  "repdgt">;
defm REPDLE  : LoopCompareAndBranch<loop_opx_repdle,  "repdle">;
defm REPDGE  : LoopCompareAndBranch<loop_opx_repdge,  "repdge">;
defm REPDLTU : LoopCompareAndBranch<loop_opx_repdltu, "repdltu">;
defm REPDGTU : LoopCompareAndBranch<loop_opx_repdgtu, "repdgtu">;
defm REPDLEU : LoopCompareAndBranch<loop_opx_repdleu, "repdleu">;
defm REPDGEU : LoopCompareAndBranch<loop_opx_repdgeu, "repdgeu">;
