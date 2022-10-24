//===----- PostriscInstrInfoShift.td - Target Description for Postrisc ----===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Shift Instructions
//
//===----------------------------------------------------------------------===//

multiclass MC_SHIFT_S32<misc_opx opxReg, misc_opx opxImm, SDNode OpNode, ValueType VT, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : MISC_Rabc<opxReg, (outs GR:$ra), (ins GR:$rb, GR:$rc),
                 !strconcat(opxReg.mnem, "\t$ra, $rb, $rc"),
                 [(set VT:$ra, (OpNode VT:$rb, i32:$rc))],
                 itin>;

  def NAME # I : MISC_RabSc<opxImm, (outs GR:$ra), (ins GR:$rb, uimm5:$shcnt),
                 !strconcat(opxImm.mnem, "\t$ra, $rb, $shcnt"),
                 [(set VT:$ra, (OpNode VT:$rb, uimm5:$shcnt))],
                 itin>;
}

defm SLLW : MC_SHIFT_S32<misc_opx_sll_w, misc_opx_slli_w, shl, i32>;
defm SRLW : MC_SHIFT_S32<misc_opx_srl_w, misc_opx_srli_w, srl, i32>;
defm SRAW : MC_SHIFT_S32<misc_opx_sra_w, misc_opx_srai_w, sra, i32>;

multiclass MC_SHIFT_128<misc_opx opxImm, SDNode OpNode, ValueType VT, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : MISC_RabSc<opxImm, (outs GR:$ra), (ins GR:$rb, uimm7:$shcnt),
                 !strconcat(opxImm.mnem, "\t$ra, $rb, $shcnt"),
                 [(set VT:$ra, (OpNode VT:$rb, uimm7:$shcnt))],
                 itin>;
}

defm SLLQI : MC_SHIFT_128<misc_opx_slli_q, shl, i128>;
defm SRLQI : MC_SHIFT_128<misc_opx_srli_q, srl, i128>;
defm SRAQI : MC_SHIFT_128<misc_opx_srai_q, sra, i128>;

// signx rd -> sra rd, %g0, rd
def : InstAlias<"signx\t$ra", (SRAW GR:$ra, GR:$ra, gz), 0>;
// signx reg, rd -> sra reg, %g0, rd
def : InstAlias<"signx\t$ra, $rb", (SRAW GR:$ra, GR:$rb, gz), 0>;

multiclass
MC_SHIFT_S64<misc_opx opxReg, misc_opx opxImm, SDNode OpNode, ValueType VT, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : MISC_Rabc<opxReg, (outs GR:$ra), (ins GR:$rb, GR:$rc),
                 !strconcat(opxReg.mnem, "\t$ra, $rb, $rc"),
                 [(set VT:$ra, (OpNode VT:$rb, i64:$rc))],
                 itin>;

  def NAME # I : MISC_RabSc<opxImm, (outs GR:$ra), (ins GR:$rb, uimm6:$shcnt),
                 !strconcat(opxImm.mnem, "\t$ra, $rb, $shcnt"),
                 [(set VT:$ra, (OpNode VT:$rb, uimm6:$shcnt))],
                 itin>;
}

defm SLLD : MC_SHIFT_S64<misc_opx_sll, misc_opx_slli, shl, i64>;
defm SRLD : MC_SHIFT_S64<misc_opx_srl, misc_opx_srli, srl, i64>;
defm SRAD : MC_SHIFT_S64<misc_opx_sra, misc_opx_srai, sra, i64>;

// shift amount may be also i32
def : Pat<(i64 (shl i64:$rb, i32:$rc)), (SLLD GR:$rb, GR:$rc)>;
def : Pat<(i64 (sra i64:$rb, i32:$rc)), (SRAD GR:$rb, GR:$rc)>;
def : Pat<(i64 (srl i64:$rb, i32:$rc)), (SRLD GR:$rb, GR:$rc)>;


def : Pat<(i128 (zext i32:$val)), (SRLWI $val, 0)>;
def : Pat<(i128 (zext i64:$val)), (SRLDI $val, 0)>;


// logical shifts are zero extension into bigger types
def : Pat<(i64  (zext (shl i32:$rb, uimm5:$shamt))), (SLLWI GR:$rb, uimm5:$shamt)>;
def : Pat<(i128 (zext (shl i32:$rb, uimm5:$shamt))), (SLLWI GR:$rb, uimm5:$shamt)>;
def : Pat<(i64  (zext (srl i32:$rb, uimm5:$shamt))), (SRLWI GR:$rb, uimm5:$shamt)>;
def : Pat<(i128 (zext (srl i32:$rb, uimm5:$shamt))), (SRLWI GR:$rb, uimm5:$shamt)>;
def : Pat<(i128 (zext (shl i64:$rb, uimm6:$shamt))), (SLLDI GR:$rb, uimm6:$shamt)>;
def : Pat<(i128 (zext (srl i64:$rb, uimm6:$shamt))), (SRLDI GR:$rb, uimm6:$shamt)>;

// algebraic shifts are sign extension into bigger types
def : Pat<(i64  (sext (sra i32:$rb, uimm5:$shamt))), (SRAWI GR:$rb, uimm5:$shamt)>;
def : Pat<(i128 (sext (sra i32:$rb, uimm5:$shamt))), (SRAWI GR:$rb, uimm5:$shamt)>;
def : Pat<(i128 (sext (sra i64:$rb, uimm6:$shamt))), (SRADI GR:$rb, uimm6:$shamt)>;

//===----------------------------------------------------------------------===//
// funnel shifts
// fshl(X,Y,Z): (X << (Z % BW)) | (Y >> (BW - (Z % BW)))
// fshr(X,Y,Z): (X << (BW - (Z % BW))) | (Y >> (Z % BW))
//===----------------------------------------------------------------------===//
multiclass
SHIFT_R4<fused_opx opx, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : FUSED_Rabcd<opx,
          (outs GR:$ra), (ins GR:$rb, GR:$rc, GR:$rd),
          !strconcat(opx.mnem, "\t$ra, $rb, $rc, $rd"),
          [], itin>;
}

defm SLPW  : SHIFT_R4<fused_opx_slp_w>;
defm SRPW  : SHIFT_R4<fused_opx_srp_w>;
defm SLP   : SHIFT_R4<fused_opx_slp>;
defm SRP   : SHIFT_R4<fused_opx_srp>;
defm SLPQ  : SHIFT_R4<fused_opx_slp_q>;
defm SRPQ  : SHIFT_R4<fused_opx_srp_q>;

multiclass
SHIFT_R3I<fused_opx opx, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : FUSED_Rabcd<opx,
          (outs GR:$ra), (ins GR:$rb, GR:$rc, uimm7:$rd),
          !strconcat(opx.mnem, "\t$ra, $rb, $rc, $rd"),
          [], itin>;
}

def SRPIW : FUSED_Rabcd<fused_opx_srpi_w, (outs GR:$ra), (ins GR:$rb, GR:$rc, uimm7i64:$rd), "srpi.w\t$ra, $rb, $rc, $rd", []>;
def SRPI  : FUSED_Rabcd<fused_opx_srpi,   (outs GR:$ra), (ins GR:$rb, GR:$rc, uimm7i64:$rd), "srpi\t$ra, $rb, $rc, $rd", []>;
def SRPIQ : FUSED_Rabcd<fused_opx_srpi_q, (outs GR:$ra), (ins GR:$rb, GR:$rc, uimm7i64:$rd), "srpi.q\t$ra, $rb, $rc, $rd", []>;

let isCodeGenOnly = 1 in {
  defm SRPI32W : SHIFT_R3I<fused_opx_srpi_w>;
  defm SRPI32  : SHIFT_R3I<fused_opx_srpi>;
  defm SRPI32Q : SHIFT_R3I<fused_opx_srpi_q>;
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
// double shift (extract bitfield)
//===----------------------------------------------------------------------===//
def pr_slsrl : PatFrag<(ops node:$src1, node:$src2, node:$src3), (srl (shl node:$src1, node:$src2), node:$src3)>;
def pr_slsra : PatFrag<(ops node:$src1, node:$src2, node:$src3), (sra (shl node:$src1, node:$src2), node:$src3)>;

defm SLSRL  : FUSED_R4<fused_opx_slsrl,   pr_slsrl, i64>;
defm SLSRA  : FUSED_R4<fused_opx_slsra,   pr_slsra, i64>;
defm SLSRLW : FUSED_R4<fused_opx_slsrl_w, pr_slsrl, i32>;
defm SLSRAW : FUSED_R4<fused_opx_slsra_w, pr_slsra, i32>;

defm SLSRLI : FUSED_R4rrii<fused_opx_slsrli, pr_slsrl, i64>;
defm SLSRAI : FUSED_R4rrii<fused_opx_slsrai, pr_slsra, i64>;

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

//===----------------------------------------------------------------------===//
// bit-field shift/deposits
//===----------------------------------------------------------------------===//
def DEP  : PRIMARY_Rabcde<opcode_dep,  (outs GR:$ra), (ins GR:$rb, GR:$rc, uimm7:$rd, uimm7:$re), "dep\t$ra, $rb, $rc, $rd, $re", []>;
def RLMI : PRIMARY_Rabcde<opcode_rlmi, (outs GR:$ra), (ins GR:$rb, uimm7:$rc, uimm7:$rd, uimm7:$re), "rlmi\t$ra, $rb, $rc, $rd, $re", []>;

multiclass
SHIFT_R2I2<fused_opx opx, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : FUSED_Rabcd<opx,
          (outs GR:$ra), (ins GR:$rb, uimm7:$rc, uimm7:$rd),
          !strconcat(opx.mnem, "\t$ra, $rb, $rc, $rd"),
          [], itin>;
}

defm DEPS : SHIFT_R2I2<fused_opx_dep_s>;
defm DEPC : SHIFT_R2I2<fused_opx_dep_c>;
defm DEPA : SHIFT_R2I2<fused_opx_dep_a>;

//===----------------------------------------------------------------------===//
// shift-left + op
//===----------------------------------------------------------------------===//
defm SL_ADD     : SHIFT_R3I<fused_opx_sl_add>;
defm SL_ADD_WS  : SHIFT_R3I<fused_opx_sl_add_ws>;
defm SL_ADD_WZ  : SHIFT_R3I<fused_opx_sl_add_wz>;
defm SL_SUB     : SHIFT_R3I<fused_opx_sl_sub>;
defm SL_SUB_WS  : SHIFT_R3I<fused_opx_sl_sub_ws>;
defm SL_SUB_WZ  : SHIFT_R3I<fused_opx_sl_sub_wz>;
defm SL_SUBF    : SHIFT_R3I<fused_opx_sl_subf>;
defm SL_SUBF_WS : SHIFT_R3I<fused_opx_sl_subf_ws>;
defm SL_SUBF_WZ : SHIFT_R3I<fused_opx_sl_subf_wz>;
defm SL_OR      : SHIFT_R3I<fused_opx_sl_or>;
defm SL_XOR     : SHIFT_R3I<fused_opx_sl_xor>;

def : Pat<(i64 (pr_add  i64:$rb, (shl i64:$rc, uimm7:$imm))), (SL_ADD     GR:$rb, GR:$rc, uimm7:$imm)>;
def : Pat<(i32 (pr_add  i32:$rb, (shl i32:$rc, uimm7:$imm))), (SL_ADD_WS  GR:$rb, GR:$rc, uimm7:$imm)>;
def : Pat<(i32 (pr_add  i32:$rb, (shl i32:$rc, uimm7:$imm))), (SL_ADD_WZ  GR:$rb, GR:$rc, uimm7:$imm)>;
def : Pat<(i64 (pr_sub  i64:$rb, (shl i64:$rc, uimm7:$imm))), (SL_SUB     GR:$rb, GR:$rc, uimm7:$imm)>;
def : Pat<(i32 (pr_sub  i32:$rb, (shl i32:$rc, uimm7:$imm))), (SL_SUB_WS  GR:$rb, GR:$rc, uimm7:$imm)>;
def : Pat<(i32 (pr_sub  i32:$rb, (shl i32:$rc, uimm7:$imm))), (SL_SUB_WZ  GR:$rb, GR:$rc, uimm7:$imm)>;
def : Pat<(i64 (pr_subf i64:$rb, (shl i64:$rc, uimm7:$imm))), (SL_SUBF    GR:$rb, GR:$rc, uimm7:$imm)>;
def : Pat<(i32 (pr_subf i32:$rb, (shl i32:$rc, uimm7:$imm))), (SL_SUBF_WS GR:$rb, GR:$rc, uimm7:$imm)>;
def : Pat<(i32 (pr_subf i32:$rb, (shl i32:$rc, uimm7:$imm))), (SL_SUBF_WZ GR:$rb, GR:$rc, uimm7:$imm)>;
def : Pat<(i64 (pr_or   i64:$rb, (shl i64:$rc, uimm7:$imm))), (SL_OR      GR:$rb, GR:$rc, uimm7:$imm)>;
def : Pat<(i32 (pr_or   i32:$rb, (shl i32:$rc, uimm7:$imm))), (SL_OR      GR:$rb, GR:$rc, uimm7:$imm)>;
def : Pat<(i64 (pr_xor  i64:$rb, (shl i64:$rc, uimm7:$imm))), (SL_XOR     GR:$rb, GR:$rc, uimm7:$imm)>;
def : Pat<(i32 (pr_xor  i32:$rb, (shl i32:$rc, uimm7:$imm))), (SL_XOR     GR:$rb, GR:$rc, uimm7:$imm)>;

// 32-bit instructions are free sext/zext to 64-bit
def : Pat<(i64 (sext (pr_add  i32:$rb, (shl i32:$rc, uimm7:$imm)))), (SL_ADD_WS  GR:$rb, GR:$rc, uimm7:$imm)>;
def : Pat<(i64 (zext (pr_add  i32:$rb, (shl i32:$rc, uimm7:$imm)))), (SL_ADD_WZ  GR:$rb, GR:$rc, uimm7:$imm)>;
def : Pat<(i64 (sext (pr_sub  i32:$rb, (shl i32:$rc, uimm7:$imm)))), (SL_SUB_WS  GR:$rb, GR:$rc, uimm7:$imm)>;
def : Pat<(i64 (zext (pr_sub  i32:$rb, (shl i32:$rc, uimm7:$imm)))), (SL_SUB_WZ  GR:$rb, GR:$rc, uimm7:$imm)>;
def : Pat<(i64 (sext (pr_subf i32:$rb, (shl i32:$rc, uimm7:$imm)))), (SL_SUBF_WS GR:$rb, GR:$rc, uimm7:$imm)>;
def : Pat<(i64 (zext (pr_subf i32:$rb, (shl i32:$rc, uimm7:$imm)))), (SL_SUBF_WZ GR:$rb, GR:$rc, uimm7:$imm)>;
