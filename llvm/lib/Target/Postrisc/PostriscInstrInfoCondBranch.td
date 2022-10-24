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

// opcode_br_16|32|64|128 reg-reg branches
multiclass
CompareAndBranchH<brh_opx opx, PatFrag OpNode, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  let isBranch = 1, isTerminator = 1 in
  def NAME : BRR_RabBranch<opcode_brh, opx.value,
                 (outs), (ins GR:$ra, GR:$rb, brtarget:$offset),
                 !strconcat(opx.mnem, " $ra, $rb, $offset"),
                 [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;

  let isBranch = 1, isTerminator = 1 in
  def NAME # _EXT : BRR_RabBranch_ext<opcode_brh, opx.value,
                 (outs), (ins GR:$ra, GR:$rb, brtarget_ext:$offset),
                 !strconcat(opx.mnem, ".l $ra, $rb, $offset"),
                 [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;
}

multiclass
CompareAndBranchW<brw_opx opx, PatFrag OpNode, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  let isBranch = 1, isTerminator = 1 in
  def NAME : BRR_RabBranch<opcode_brw, opx.value,
                 (outs), (ins GR:$ra, GR:$rb, brtarget:$offset),
                 !strconcat(opx.mnem, " $ra, $rb, $offset"),
                 [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;

  let isBranch = 1, isTerminator = 1 in
  def NAME # _EXT : BRR_RabBranch_ext<opcode_brw, opx.value,
                 (outs), (ins GR:$ra, GR:$rb, brtarget_ext:$offset),
                 !strconcat(opx.mnem, ".l $ra, $rb, $offset"),
                 [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;
}

multiclass
CompareAndBranchD<brd_opx opx, PatFrag OpNode, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  let isBranch = 1, isTerminator = 1 in
  def NAME : BRR_RabBranch<opcode_brd, opx.value,
                 (outs), (ins GR:$ra, GR:$rb, brtarget:$offset),
                 !strconcat(opx.mnem, " $ra, $rb, $offset"),
                 [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;

  let isBranch = 1, isTerminator = 1 in
  def NAME # _EXT : BRR_RabBranch_ext<opcode_brd, opx.value,
                 (outs), (ins GR:$ra, GR:$rb, brtarget_ext:$offset),
                 !strconcat(opx.mnem, ".l $ra, $rb, $offset"),
                 [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;
}

multiclass
CompareAndBranchQ<brq_opx opx, PatFrag OpNode, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  let isBranch = 1, isTerminator = 1 in
  def NAME : BRR_RabBranch<opcode_brq, opx.value,
                 (outs), (ins GR:$ra, GR:$rb, brtarget:$offset),
                 !strconcat(opx.mnem, " $ra, $rb, $offset"),
                 [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;

  let isBranch = 1, isTerminator = 1 in
  def NAME # _EXT : BRR_RabBranch_ext<opcode_brq, opx.value,
                 (outs), (ins GR:$ra, GR:$rb, brtarget_ext:$offset),
                 !strconcat(opx.mnem, ".l $ra, $rb, $offset"),
                 [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;
}

//===----------------------------------------------------------------------===//
// Compare reg-reg and branch
//===----------------------------------------------------------------------===//
defm BREQD  : CompareAndBranchD<opcode_breqd,  seteq,  i64>;
defm BRNED  : CompareAndBranchD<opcode_brned,  setne,  i64>;
defm BRLTSD : CompareAndBranchD<opcode_brltsd, setlt,  i64>;
defm BRLTUD : CompareAndBranchD<opcode_brltud, setult, i64>;
defm BRGESD : CompareAndBranchD<opcode_brgesd, setge,  i64>;
defm BRGEUD : CompareAndBranchD<opcode_brgeud, setuge, i64>;

defm BREQW  : CompareAndBranchW<opcode_breqw,  seteq,  i32>;
defm BRNEW  : CompareAndBranchW<opcode_brnew,  setne,  i32>;
defm BRLTSW : CompareAndBranchW<opcode_brltsw, setlt,  i32>;
defm BRLTUW : CompareAndBranchW<opcode_brltuw, setult, i32>;
defm BRGESW : CompareAndBranchW<opcode_brgesw, setge,  i32>;
defm BRGEUW : CompareAndBranchW<opcode_brgeuw, setuge, i32>;

defm BREQQ  : CompareAndBranchQ<opcode_breqq,  seteq,  i128>;
defm BRNEQ  : CompareAndBranchQ<opcode_brneq,  setne,  i128>;
defm BRLTSQ : CompareAndBranchQ<opcode_brltsq, setlt,  i128>;
defm BRLTUQ : CompareAndBranchQ<opcode_brltuq, setult, i128>;
defm BRGESQ : CompareAndBranchQ<opcode_brgesq, setge,  i128>;
defm BRGEUQ : CompareAndBranchQ<opcode_brgeuq, setuge, i128>;

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

defm : BranchSwappedArgs<BRLTSW, BRLTUW, BRGESW, BRGEUW, i32>;
defm : BranchSwappedArgs<BRLTSD, BRLTUD, BRGESD, BRGEUD, i64>;
defm : BranchSwappedArgs<BRLTSQ, BRLTUQ, BRGESQ, BRGEUQ, i128>;

//===----------------------------------------------------------------------===//
// Compare bit and branch (variable shift)
//===----------------------------------------------------------------------===//
multiclass CompareBitAndBranch<brh_opx opxCode, InstrItinClass itin = IIC_iu_instr>
{
  let isBranch = 1, isTerminator = 1 in {
    def NAME        : BRR_RabBranch<opcode_brh, opxCode.value, (outs), (ins GR:$ra, GR:$rb, brtarget:$offset),
                      !strconcat(opxCode.mnem, " $ra, $rb, $offset"),
                      [], itin>;

    def NAME # _EXT : BRR_RabBranch_ext<opcode_brh, opxCode.value, (outs), (ins GR:$ra, GR:$rb, brtarget_ext:$offset),
                      !strconcat(opxCode.mnem, ".l $ra, $rb, $offset"),
                      [], itin>;
  }
}

defm BRBS : CompareBitAndBranch<opcode_brbs>;
defm BRBC : CompareBitAndBranch<opcode_brbc>;

foreach Ty = [ i32, i64, i128 ] in {
    foreach Sy = [ i32, i64 ] in {
        // if ((value & (1 << shift)) == 0)
        def : Pat<(brcond (i1 (seteq (and Ty:$a, (shl (Ty 1), Sy:$b)), (Ty 0))), bb:$dst), (BRBC GR:$a, GR:$b, bb:$dst)>;

        // if ((value & (1 << shift)) != 0)
        def : Pat<(brcond (i1 (setne (and Ty:$a, (shl (Ty 1), Sy:$b)), (Ty 0))), bb:$dst), (BRBS GR:$a, GR:$b, bb:$dst)>;

        // if ((value & (1 << shift)) == (1 << shift))
        def : Pat<(brcond (i1 (seteq (and Ty:$a, (shl (Ty 1), Sy:$b)), (shl (Ty 1), Sy:$b))), bb:$dst), (BRBS GR:$a, GR:$b, bb:$dst)>;

        // if ((value & (1 << shift)) != (1 << shift))
        def : Pat<(brcond (i1 (setne (and Ty:$a, (shl (Ty 1), Sy:$b)), (shl (Ty 1), Sy:$b))), bb:$dst), (BRBC GR:$a, GR:$b, bb:$dst)>;

        foreach SHIFT = [ srl, sra ] in {
            // if (((value >> shift) & 1) == 1)
            def : Pat<(brcond (i1 (seteq (and (SHIFT Ty:$a, Sy:$b), 1), 1)), bb:$dst), (BRBS GR:$a, GR:$b, bb:$dst)>;

            // if (((value >> shift) & 1) != 0)
            def : Pat<(brcond (i1 (setne (and (SHIFT Ty:$a, Sy:$b), 1), 0)), bb:$dst), (BRBS GR:$a, GR:$b, bb:$dst)>;

            // if (((value >> shift) & 1) != 1)
            def : Pat<(brcond (i1 (setne (and (SHIFT Ty:$a, Sy:$b), 1), 1)), bb:$dst), (BRBC GR:$a, GR:$b, bb:$dst)>;

            // if (((value >> shift) & 1) == 0)
            def : Pat<(brcond (i1 (seteq (and (SHIFT Ty:$a, Sy:$b), 1), 0)), bb:$dst), (BRBC GR:$a, GR:$b, bb:$dst)>;

            // if ( trunc((value >> shift) & 1) == 1)
            def : Pat<(brcond (i1 (seteq (i1 (trunc (SHIFT Ty:$a, Sy:$b))), (i1 1))), bb:$dst), (BRBS GR:$a, GR:$b, bb:$dst)>;

            // if ( trunc((value >> shift) & 1) != 0)
            def : Pat<(brcond (i1 (setne (i1 (trunc (SHIFT Ty:$a, Sy:$b))), (i1 0))), bb:$dst), (BRBS GR:$a, GR:$b, bb:$dst)>;

            // if ( trunc((value >> shift) & 1) != 1)
            def : Pat<(brcond (i1 (setne (i1 (trunc (SHIFT Ty:$a, Sy:$b))), (i1 1))), bb:$dst), (BRBC GR:$a, GR:$b, bb:$dst)>;

            // if ( trunc((value >> shift) & 1) == 0)
            def : Pat<(brcond (i1 (seteq (i1 (trunc (SHIFT Ty:$a, Sy:$b))), (i1 0))), bb:$dst), (BRBC GR:$a, GR:$b, bb:$dst)>;
        }
    }
}

//===----------------------------------------------------------------------===//
// Compare bit and branch (immediate shift)
//===----------------------------------------------------------------------===//
multiclass CompareBitAndBranchImm<brh_opx opxCode, InstrItinClass itin = IIC_iu_instr>
{
  let isBranch = 1, isTerminator = 1 in {
    def NAME        : BRR_RabBranch<opcode_brh, opxCode.value, (outs), (ins GR:$ra, uimm7:$rb, brtarget:$offset),
                      !strconcat(opxCode.mnem, " $ra, $rb, $offset"),
                      [], itin>;

    def NAME # _EXT : BRR_RabBranch_ext<opcode_brh, opxCode.value, (outs), (ins GR:$ra, uimm7:$rb, brtarget_ext:$offset),
                      !strconcat(opxCode.mnem, ".l $ra, $rb, $offset"),
                      [], itin>;
  }
}

defm BRBSI : CompareBitAndBranchImm<opcode_brbsi>;
defm BRBCI : CompareBitAndBranchImm<opcode_brbci>;

foreach Ty = [ i32, i64, i128 ] in {
    foreach SHIFT = [ srl, sra ] in {
        def : Pat<(brcond (i1 (setne (and (SHIFT Ty:$a, uimm7:$b), (Ty 1)), (Ty 0))), bb:$dst), (BRBSI GR:$a, uimm7:$b, bb:$dst)>;
        def : Pat<(brcond (i1 (seteq (and (SHIFT Ty:$a, uimm7:$b), (Ty 1)), (Ty 0))), bb:$dst), (BRBCI GR:$a, uimm7:$b, bb:$dst)>;
        def : Pat<(brcond (i1 (setne (and (SHIFT Ty:$a, uimm7:$b), (Ty 1)), (Ty 1))), bb:$dst), (BRBCI GR:$a, uimm7:$b, bb:$dst)>;
        def : Pat<(brcond (i1 (seteq (and (SHIFT Ty:$a, uimm7:$b), (Ty 1)), (Ty 1))), bb:$dst), (BRBSI GR:$a, uimm7:$b, bb:$dst)>;
    }

    // Patterns for single-one masks (0x00000100)
    def : Pat<(brcond (i1 (cmp_any    Ty:$a, (Ty imm_pow2:$imm))), bb:$dst), (BRBSI GR:$a, (imm_pow2_xform imm:$imm), bb:$dst)>;
    def : Pat<(brcond (i1 (cmp_all    Ty:$a, (Ty imm_pow2:$imm))), bb:$dst), (BRBSI GR:$a, (imm_pow2_xform imm:$imm), bb:$dst)>;
    def : Pat<(brcond (i1 (cmp_none   Ty:$a, (Ty imm_pow2:$imm))), bb:$dst), (BRBCI GR:$a, (imm_pow2_xform imm:$imm), bb:$dst)>;
    def : Pat<(brcond (i1 (cmp_notall Ty:$a, (Ty imm_pow2:$imm))), bb:$dst), (BRBCI GR:$a, (imm_pow2_xform imm:$imm), bb:$dst)>;

    // Patterns for single-zerobit masks (0xFFFF7FFF)
    // if ((value & 0xFFFF7FFF) != value) => bit set
    // if ((value & 0xFFFF7FFF) == value) => bit clear
    def : Pat<(brcond (i1 (cmp_notall_swapped Ty:$a, (Ty imm_inv_pow2:$imm))), bb:$dst), (BRBSI GR:$a, (imm_inv_pow2_xform imm:$imm), bb:$dst)>;
    def : Pat<(brcond (i1 (cmp_all_swapped    Ty:$a, (Ty imm_inv_pow2:$imm))), bb:$dst), (BRBCI GR:$a, (imm_inv_pow2_xform imm:$imm), bb:$dst)>;
}

//===----------------------------------------------------------------------===//
// Compare immediate and branch
//===----------------------------------------------------------------------===//
multiclass CompareAndBranchImm<opcode_opx opcode, PatFrag OpNode, ValueType Ty,
   Operand immOp, Operand immOpEx, InstrItinClass itin = IIC_iu_instr>
{
  let isBranch = 1, isTerminator = 1 in {
    def NAME        : PRIMARY_RaImmBranch<opcode, (outs), (ins GR:$ra, immOp:$imm, brtarget:$offset),
                      !strconcat(opcode.mnem, " $ra, $imm, $offset"), [(brcond (i1 (OpNode Ty:$ra, immOp:$imm)), bb:$offset)], itin>;

    def NAME # _EXT : PRIMARY_RaImmBranch_ext<opcode, (outs), (ins GR:$ra, immOpEx:$imm, brtarget_ext:$offset),
                      !strconcat(opcode.mnem, ".l $ra, $imm, $offset"), [(brcond (i1 (OpNode Ty:$ra, immOpEx:$imm)), bb:$offset)], itin>;
  }
}

defm BREQID  : CompareAndBranchImm<opcode_breqid,  seteq,  i64, simm11, simm11_ext>;
defm BRNEID  : CompareAndBranchImm<opcode_brneid,  setne,  i64, simm11, simm11_ext>;
defm BRLTSID : CompareAndBranchImm<opcode_brltsid, setlt,  i64, simm11, simm11_ext>;
defm BRGESID : CompareAndBranchImm<opcode_brgesid, setge,  i64, simm11, simm11_ext>;
defm BRLTUID : CompareAndBranchImm<opcode_brltuid, setult, i64, uimm11, uimm11_ext>;
defm BRGEUID : CompareAndBranchImm<opcode_brgeuid, setuge, i64, uimm11, uimm11_ext>;

defm BREQIW  : CompareAndBranchImm<opcode_breqiw,  seteq,  i32, simm11i32, simm11i32_ext>;
defm BRNEIW  : CompareAndBranchImm<opcode_brneiw,  setne,  i32, simm11i32, simm11i32_ext>;
defm BRLTSIW : CompareAndBranchImm<opcode_brltsiw, setlt,  i32, simm11i32, simm11i32_ext>;
defm BRGESIW : CompareAndBranchImm<opcode_brgesiw, setge,  i32, simm11i32, simm11i32_ext>;
defm BRLTUIW : CompareAndBranchImm<opcode_brltuiw, setult, i32, uimm11i32, uimm11i32_ext>;
defm BRGEUIW : CompareAndBranchImm<opcode_brgeuiw, setuge, i32, uimm11i32, uimm11i32_ext>;

defm BREQIQ  : CompareAndBranchImm<opcode_breqiq,  seteq,  i128, simm11i128, simm11i128_ext>;
defm BRNEIQ  : CompareAndBranchImm<opcode_brneiq,  setne,  i128, simm11i128, simm11i128_ext>;
defm BRLTSIQ : CompareAndBranchImm<opcode_brltsiq, setlt,  i128, simm11i128, simm11i128_ext>;
defm BRGESIQ : CompareAndBranchImm<opcode_brgesiq, setge,  i128, simm11i128, simm11i128_ext>;
defm BRLTUIQ : CompareAndBranchImm<opcode_brltuiq, setult, i128, uimm11i128, uimm11i128_ext>;
defm BRGEUIQ : CompareAndBranchImm<opcode_brgeuiq, setuge, i128, uimm11i128, uimm11i128_ext>;

//===----------------------------------------------------------------------===//
// Compare with zero immediate and branch
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

defm : CompareZeroAndBranch<BREQIW, BRNEIW, BRLTSIW, BRGESIW, i32>;
defm : CompareZeroAndBranch<BREQID, BRNEID, BRLTSID, BRGESID, i64>;
// FIXME: i128 failed
//defm : CompareZeroAndBranch<BREQIQ, BRNEIQ, BRLTSIQ, BRGESIQ, i128>;

//===----------------------------------------------------------------------===//
// Compare immediate+1 and branch (GT via GE, LE via LT)
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
defm : BranchSimmPlus32<BRLTSIW, BRLTSIW_EXT, setle, i32,  simm11_plus1, simm11_ext_plus1>;
defm : BranchSimmPlus64<BRLTSID, BRLTSID_EXT, setle, i64,  simm11_plus1, simm11_ext_plus1>;
defm : BranchSimmPlus64<BRLTSIQ, BRLTSIQ_EXT, setle, i128, simm11_plus1, simm11_ext_plus1>;

defm : BranchUimmPlus32<BRLTUIW, BRLTUIW_EXT, setule, i32,  uimm11_plus1, uimm11_ext_plus1>;
defm : BranchUimmPlus64<BRLTUID, BRLTUID_EXT, setule, i64,  uimm11_plus1, uimm11_ext_plus1>;
defm : BranchUimmPlus64<BRLTUIQ, BRLTUIQ_EXT, setule, i128, uimm11_plus1, uimm11_ext_plus1>;

// "> 15" ==> ">= 16"
defm : BranchSimmPlus32<BRGESIW, BRGESIW_EXT, setgt, i32,  simm11_plus1, simm11_ext_plus1>;
defm : BranchSimmPlus64<BRGESID, BRGESID_EXT, setgt, i64,  simm11_plus1, simm11_ext_plus1>;
defm : BranchSimmPlus64<BRGESIQ, BRGESIQ_EXT, setgt, i128, simm11_plus1, simm11_ext_plus1>;

defm : BranchUimmPlus32<BRGEUIW, BRGEUIW_EXT, setugt, i32,  uimm11_plus1, uimm11_ext_plus1>;
defm : BranchUimmPlus64<BRGEUID, BRGEUID_EXT, setugt, i64,  uimm11_plus1, uimm11_ext_plus1>;
defm : BranchUimmPlus64<BRGEUIQ, BRGEUIQ_EXT, setugt, i128, uimm11_plus1, uimm11_ext_plus1>;

//===----------------------------------------------------------------------===//
// Compare bitmask and branch
// same mask-based branches for all: i32, i64, i128
// FIXME: can model different type immediates only via codegen
//===----------------------------------------------------------------------===//
defm BRMALLD    : CompareAndBranchImm<opcode_brmall,    cmp_all,    i64, uimm11, uimm11_ext>;
defm BRMNOTALLD : CompareAndBranchImm<opcode_brmnotall, cmp_notall, i64, uimm11, uimm11_ext>;
defm BRMNONED   : CompareAndBranchImm<opcode_brmnone,   cmp_none,   i64, uimm11, uimm11_ext>;
defm BRMANYD    : CompareAndBranchImm<opcode_brmany,    cmp_any,    i64, uimm11, uimm11_ext>;

let isCodeGenOnly = 1 in {
  defm BRMALLW     : CompareAndBranchImm<opcode_brmall,    cmp_all,    i32, uimm11i32, uimm11i32_ext>;
  defm BRMNOTALLW  : CompareAndBranchImm<opcode_brmnotall, cmp_notall, i32, uimm11i32, uimm11i32_ext>;
  defm BRMNONEW    : CompareAndBranchImm<opcode_brmnone,   cmp_none,   i32, uimm11i32, uimm11i32_ext>;
  defm BRMANYW     : CompareAndBranchImm<opcode_brmany,    cmp_any,    i32, uimm11i32, uimm11i32_ext>;

  defm BRMALLQ    : CompareAndBranchImm<opcode_brmall,    cmp_all,    i128, uimm11i128, uimm11i128_ext>;
  defm BRMNOTALLQ : CompareAndBranchImm<opcode_brmnotall, cmp_notall, i128, uimm11i128, uimm11i128_ext>;
  defm BRMNONEQ   : CompareAndBranchImm<opcode_brmnone,   cmp_none,   i128, uimm11i128, uimm11i128_ext>;
  defm BRMANYQ    : CompareAndBranchImm<opcode_brmany,    cmp_any,    i128, uimm11i128, uimm11i128_ext>;
}

//===----------------------------------------------------------------------===//
// i1 (branches/sext/zext/sext_inreg) and extra pattern is needed for a brcond
// without a setcc (i.e. where the condition was calculated elsewhere).
// i1 true is -1
//===----------------------------------------------------------------------===//
// if ([!] cond)
def : Pat<(brcond           i1:$cond  , bb:$dst), (BRBSI GR:$cond, 0, bb:$dst)>;
def : Pat<(brcond  (i1 (not i1:$cond)), bb:$dst), (BRBCI GR:$cond, 0, bb:$dst)>;

// if (cond [!|=]= [true|false])
def : Pat<(brcond (i1 (seteq i1:$a, (i1  0))), bb:$dst), (BRBCI GR:$a, 0, bb:$dst)>;
def : Pat<(brcond (i1 (setne i1:$a, (i1  0))), bb:$dst), (BRBSI GR:$a, 0, bb:$dst)>;
def : Pat<(brcond (i1 (seteq i1:$a, (i1 -1))), bb:$dst), (BRBSI GR:$a, 0, bb:$dst)>;
def : Pat<(brcond (i1 (setne i1:$a, (i1 -1))), bb:$dst), (BRBCI GR:$a, 0, bb:$dst)>;

// if (cond1 [!|=]= cond2)
def : Pat<(brcond (i1 (seteq i1:$a, i1:$b)), bb:$dst), (BREQD GR:$a, GR:$b, bb:$dst)>;
def : Pat<(brcond (i1 (setne i1:$a, i1:$b)), bb:$dst), (BRNED GR:$a, GR:$b, bb:$dst)>;

//===----------------------------------------------------------------------===//
// branch on trunc to i1 modeled as 0-bit BRBS_IMM/BRBC_IMM
//===----------------------------------------------------------------------===//
foreach Ty = [ i32, i64, i128 ] in {
  def : Pat<(brcond (         i1 (trunc Ty:$val)  ), bb:$dst), (BRBSI Ty:$val, 0, bb:$dst)>;
  def : Pat<(brcond (i1 (not (i1 (trunc Ty:$val)))), bb:$dst), (BRBCI Ty:$val, 0, bb:$dst)>;

  def : Pat<(brcond (i1 (seteq (i1 (trunc Ty:$val)), (i1 -1))), bb:$dst), (BRBSI Ty:$val, 0, bb:$dst)>;
  def : Pat<(brcond (i1 (setne (i1 (trunc Ty:$val)), (i1  0))), bb:$dst), (BRBSI Ty:$val, 0, bb:$dst)>;
  def : Pat<(brcond (i1 (seteq (i1 (trunc Ty:$val)), (i1  0))), bb:$dst), (BRBCI Ty:$val, 0, bb:$dst)>;
  def : Pat<(brcond (i1 (setne (i1 (trunc Ty:$val)), (i1 -1))), bb:$dst), (BRBCI Ty:$val, 0, bb:$dst)>;
}

//===----------------------------------------------------------------------===//
// Loop: compare reg-reg and branch,  (uimm stride 6(+23))
//===----------------------------------------------------------------------===//
def loop_stride_xform : SDNodeXForm<imm, [{
  return getU64Imm(N->getZExtValue()+1, SDLoc(N));
}]>;
def loop_stride : Operand<i64>, IntImmLeaf<i64, [{ return isZextInt(Imm-1, 6); }], loop_stride_xform> {
  let DecoderMethod = "DecodeLoopStride<6>";
}

// simm52 extended (10+42) immediate (stride_ext)
def loop_stride_ext_xform : SDNodeXForm<imm, [{
  return getU64Imm(N->getZExtValue()+1, SDLoc(N));
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

defm REPLTD  : LoopBranch<opcode_repltd>;
defm REPGTD  : LoopBranch<opcode_repgtd>;
defm REPLED  : LoopBranch<opcode_repled>;
defm REPGED  : LoopBranch<opcode_repged>;
defm REPLTUD : LoopBranch<opcode_repltud>;
defm REPGTUD : LoopBranch<opcode_repgtud>;
defm REPLEUD : LoopBranch<opcode_repleud>;
defm REPGEUD : LoopBranch<opcode_repgeud>;

defm REPLTW  : LoopBranch<opcode_repltw>;
defm REPGTW  : LoopBranch<opcode_repgtw>;
defm REPLEW  : LoopBranch<opcode_replew>;
defm REPGEW  : LoopBranch<opcode_repgew>;
defm REPLTUW : LoopBranch<opcode_repltuw>;
defm REPGTUW : LoopBranch<opcode_repgtuw>;
defm REPLEUW : LoopBranch<opcode_repleuw>;
defm REPGEUW : LoopBranch<opcode_repgeuw>;

//===----------------------------------------------------------------------===//
// FP branches
//===----------------------------------------------------------------------===//
defm FBROEQH : CompareAndBranchH<opcode_fbroeqh, setoeq, f16>;
defm FBRONEH : CompareAndBranchH<opcode_fbroneh, setone, f16>;
defm FBROLTH : CompareAndBranchH<opcode_fbrolth, setolt, f16>;
defm FBROGEH : CompareAndBranchH<opcode_fbrogeh, setoge, f16>;
defm FBROH   : CompareAndBranchH<opcode_fbroh,   seto,   f16>;
defm FBRUEQH : CompareAndBranchH<opcode_fbrueqh, setueq, f16>;
defm FBRUNEH : CompareAndBranchH<opcode_fbruneh, setune, f16>;
defm FBRULTH : CompareAndBranchH<opcode_fbrulth, setult, f16>;
defm FBRUGEH : CompareAndBranchH<opcode_fbrugeh, setuge, f16>;
defm FBRUH   : CompareAndBranchH<opcode_fbruh,   setuo,  f16>;

defm FBROEQS : CompareAndBranchW<opcode_fbroeqs, setoeq, f32>;
defm FBRONES : CompareAndBranchW<opcode_fbrones, setone, f32>;
defm FBROLTS : CompareAndBranchW<opcode_fbrolts, setolt, f32>;
defm FBROGES : CompareAndBranchW<opcode_fbroges, setoge, f32>;
defm FBROS   : CompareAndBranchW<opcode_fbros,   seto,   f32>;
defm FBRUEQS : CompareAndBranchW<opcode_fbrueqs, setueq, f32>;
defm FBRUNES : CompareAndBranchW<opcode_fbrunes, setune, f32>;
defm FBRULTS : CompareAndBranchW<opcode_fbrults, setult, f32>;
defm FBRUGES : CompareAndBranchW<opcode_fbruges, setuge, f32>;
defm FBRUS   : CompareAndBranchW<opcode_fbrus,   setuo,  f32>;

defm FBROEQD : CompareAndBranchD<opcode_fbroeqd, setoeq, f64>;
defm FBRONED : CompareAndBranchD<opcode_fbroned, setone, f64>;
defm FBROLTD : CompareAndBranchD<opcode_fbroltd, setolt, f64>;
defm FBROGED : CompareAndBranchD<opcode_fbroged, setoge, f64>;
defm FBROD   : CompareAndBranchD<opcode_fbrod,   seto,   f64>;
defm FBRUEQD : CompareAndBranchD<opcode_fbrueqd, setueq, f64>;
defm FBRUNED : CompareAndBranchD<opcode_fbruned, setune, f64>;
defm FBRULTD : CompareAndBranchD<opcode_fbrultd, setult, f64>;
defm FBRUGED : CompareAndBranchD<opcode_fbruged, setuge, f64>;
defm FBRUD   : CompareAndBranchD<opcode_fbrud,   setuo,  f64>;

defm FBROEQQ : CompareAndBranchQ<opcode_fbroeqq, setoeq, f128>;
defm FBRONEQ : CompareAndBranchQ<opcode_fbroneq, setone, f128>;
defm FBROLTQ : CompareAndBranchQ<opcode_fbroltq, setolt, f128>;
defm FBROGEQ : CompareAndBranchQ<opcode_fbrogeq, setoge, f128>;
defm FBROQ   : CompareAndBranchQ<opcode_fbroq,   seto,   f128>;
defm FBRUEQQ : CompareAndBranchQ<opcode_fbrueqq, setueq, f128>;
defm FBRUNEQ : CompareAndBranchQ<opcode_fbruneq, setune, f128>;
defm FBRULTQ : CompareAndBranchQ<opcode_fbrultq, setult, f128>;
defm FBRUGEQ : CompareAndBranchQ<opcode_fbrugeq, setuge, f128>;
defm FBRUQ   : CompareAndBranchQ<opcode_fbruq,   setuo,  f128>;

multiclass FP_SCALAR_BRANCH_PATTERNS<InstBase OEQ, InstBase ONE, InstBase OLT, InstBase OGE,
     /*InstBase UEQ, InstBase UNE,*/ InstBase ULT, InstBase UGE, ValueType Ty>
{
  // swap args
  def : Pat<(brcond (i1 (setogt Ty:$ra, Ty:$rb)), bb:$dst), (OLT GR:$rb, GR:$ra, bb:$dst)>;
  def : Pat<(brcond (i1 (setole Ty:$ra, Ty:$rb)), bb:$dst), (OGE GR:$rb, GR:$ra, bb:$dst)>;
  def : Pat<(brcond (i1 (setugt Ty:$ra, Ty:$rb)), bb:$dst), (ULT GR:$rb, GR:$ra, bb:$dst)>;
  def : Pat<(brcond (i1 (setule Ty:$ra, Ty:$rb)), bb:$dst), (UGE GR:$rb, GR:$ra, bb:$dst)>;

  // branch: don't care variants
  // fast-math doesn't differ ordered/unordered and uses ordered forms
  def : Pat<(brcond (i1 (seteq Ty:$ra, Ty:$rb)), bb:$dst), (OEQ GR:$ra, GR:$rb, bb:$dst)>;
  def : Pat<(brcond (i1 (setne Ty:$ra, Ty:$rb)), bb:$dst), (ONE GR:$ra, GR:$rb, bb:$dst)>;
  def : Pat<(brcond (i1 (setlt Ty:$ra, Ty:$rb)), bb:$dst), (OLT GR:$ra, GR:$rb, bb:$dst)>;
  def : Pat<(brcond (i1 (setge Ty:$ra, Ty:$rb)), bb:$dst), (OGE GR:$ra, GR:$rb, bb:$dst)>;

  // fast-math: swap args
  def : Pat<(brcond (i1 (setgt Ty:$ra, Ty:$rb)), bb:$dst), (OLT GR:$rb, GR:$ra, bb:$dst)>;
  def : Pat<(brcond (i1 (setle Ty:$ra, Ty:$rb)), bb:$dst), (OGE GR:$rb, GR:$ra, bb:$dst)>;
}

defm : FP_SCALAR_BRANCH_PATTERNS<FBROEQH, FBRONEH, FBROLTH, FBROGEH, /*FBRUEQH, FBRUNEH, */ FBRULTH, FBRUGEH, f16>;
defm : FP_SCALAR_BRANCH_PATTERNS<FBROEQS, FBRONES, FBROLTS, FBROGES, /*FBRUEQS, FBRUNES, */ FBRULTS, FBRUGES, f32>;
defm : FP_SCALAR_BRANCH_PATTERNS<FBROEQD, FBRONED, FBROLTD, FBROGED, /*FBRUEQD, FBRUNED, */ FBRULTD, FBRUGED, f64>;
defm : FP_SCALAR_BRANCH_PATTERNS<FBROEQQ, FBRONEQ, FBROLTQ, FBROGEQ, /*FBRUEQQ, FBRUNEQ, */ FBRULTQ, FBRUGEQ, f128>;
