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

def pr_shl     : PatFrag<(ops node:$src1, node:$src2), (shl  node:$src1, node:$src2)>;
def pr_srl     : PatFrag<(ops node:$src1, node:$src2), (srl  node:$src1, node:$src2)>;
def pr_sra     : PatFrag<(ops node:$src1, node:$src2), (sra  node:$src1, node:$src2)>;
def pr_srd_i32 : PatFrag<(ops node:$src1, node:$src2), (sdiv node:$src1, (shl (i32 1), node:$src2))>;
def pr_srd_i64 : PatFrag<(ops node:$src1, node:$src2), (sdiv node:$src1, (shl (i64 1), node:$src2))>;

multiclass MC_SHIFT_S32<misc_opx Opc, PatFrag Op, ValueType VT, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : MISC_Rabc<Opc, (outs GR:$ra), (ins GR:$rb, GR:$rc),
                 !strconcat(Opc.mnem, " $ra, $rb, $rc"),
                 [(set VT:$ra, (Op VT:$rb, i32:$rc))], itin>;
}

defm SLL_U32 : MC_SHIFT_S32<opcode_sll_u32, pr_shl,     i32>;
defm SRL_U32 : MC_SHIFT_S32<opcode_srl_u32, pr_srl,     i32>;
defm SRA_I32 : MC_SHIFT_S32<opcode_sra_i32, pr_sra,     i32>;
defm SRD_I32 : MC_SHIFT_S32<opcode_srd_i32, pr_srd_i32, i32>;

multiclass MC_SHIFT_IMM_S32<misc_opx Opc, PatFrag Op, ValueType VT, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : MISC_RabSc<Opc, (outs GR:$ra), (ins GR:$rb, uimm5:$shcnt),
        !strconcat(Opc.mnem, " $ra, $rb, $shcnt"),
        [(set VT:$ra, (Op VT:$rb, uimm5:$shcnt))], itin>;
}

defm SLL_IMM_U32 : MC_SHIFT_IMM_S32<opcode_sll_imm_u32, pr_shl,     i32>;
defm SRL_IMM_U32 : MC_SHIFT_IMM_S32<opcode_srl_imm_u32, pr_srl,     i32>;
defm SRA_IMM_I32 : MC_SHIFT_IMM_S32<opcode_sra_imm_i32, pr_sra,     i32>;
defm SRD_IMM_I32 : MC_SHIFT_IMM_S32<opcode_srd_imm_i32, pr_srd_i32, i32>;

foreach LEFT_SHIFT = {1 ... 30} in {
    defvar POW2 = !shl(1, LEFT_SHIFT);
    def : Pat<(sdiv i32:$ra, POW2), (SRD_IMM_I32 GR:$ra, LEFT_SHIFT)>;
}

multiclass MC_SHIFT_128<misc_opx opxImm, SDNode OpNode, ValueType VT, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : MISC_RabSc<opxImm, (outs GR:$ra), (ins GR:$rb, uimm7:$shcnt),
                 !strconcat(opxImm.mnem, " $ra, $rb, $shcnt"),
                 [(set VT:$ra, (OpNode VT:$rb, uimm7:$shcnt))],
                 itin>;
}

defm SLL_IMM_U128 : MC_SHIFT_128<opcode_sll_imm_u128, shl, i128>;
defm SRL_IMM_U128 : MC_SHIFT_128<opcode_srl_imm_u128, srl, i128>;
defm SRA_IMM_I128 : MC_SHIFT_128<opcode_sra_imm_i128, sra, i128>;

// signx rd -> sra rd, %g0, rd
def : InstAlias<"signx $ra", (SRA_I32 GR:$ra, GR:$ra, gz), 0>;
// signx reg, rd -> sra reg, %g0, rd
def : InstAlias<"signx $ra, $rb", (SRA_I32 GR:$ra, GR:$rb, gz), 0>;

def : Pat<(i128 (zext i32:$val)), (SRL_IMM_U128 (SLL_IMM_U128 $val, 96), 96)>;
def : Pat<(i128 (sext i32:$val)), (SRA_IMM_I128 (SLL_IMM_U128 $val, 96), 96)>;
def : Pat<(i128 (zext i64:$val)), (SRL_IMM_U128 (SLL_IMM_U128 $val, 64), 64)>;
def : Pat<(i128 (sext i64:$val)), (SRA_IMM_I128 (SLL_IMM_U128 $val, 64), 64)>;

def : Pat<(i128 (sext_inreg i128:$val, i8 )), (SRA_IMM_I128 (SLL_IMM_U128 $val, 120), 120)>;
def : Pat<(i128 (sext_inreg i128:$val, i16)), (SRA_IMM_I128 (SLL_IMM_U128 $val, 112), 112)>;
def : Pat<(i128 (sext_inreg i128:$val, i32)), (SRA_IMM_I128 (SLL_IMM_U128 $val,  96),  96)>;
def : Pat<(i128 (sext_inreg i128:$val, i64)), (SRA_IMM_I128 (SLL_IMM_U128 $val,  64),  64)>;

multiclass
MC_SHIFT_S64<misc_opx Opc, PatFrag Op, ValueType VT, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : MISC_Rabc<Opc, (outs GR:$ra), (ins GR:$rb, GR:$rc),
                 !strconcat(Opc.mnem, " $ra, $rb, $rc"),
                 [(set VT:$ra, (Op VT:$rb, i64:$rc))],
                 itin>;
}

defm SLL_U64 : MC_SHIFT_S64<opcode_sll_u64, pr_shl,     i64>;
defm SRL_U64 : MC_SHIFT_S64<opcode_srl_u64, pr_srl,     i64>;
defm SRA_I64 : MC_SHIFT_S64<opcode_sra_i64, pr_sra,     i64>;
defm SRD_I64 : MC_SHIFT_S64<opcode_srd_i64, pr_srd_i64, i64>;

multiclass
MC_SHIFT_IMM_64<misc_opx Opc, PatFrag Op, ValueType VT, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : MISC_RabSc<Opc, (outs GR:$ra), (ins GR:$rb, uimm6:$shcnt),
             !strconcat(Opc.mnem, " $ra, $rb, $shcnt"),
             [(set VT:$ra, (Op VT:$rb, uimm6:$shcnt))],
             itin>;
}

defm SLL_IMM_U64 : MC_SHIFT_IMM_64<opcode_sll_imm_u64, pr_shl,     i64>;
defm SRL_IMM_U64 : MC_SHIFT_IMM_64<opcode_srl_imm_u64, pr_srl,     i64>;
defm SRA_IMM_I64 : MC_SHIFT_IMM_64<opcode_sra_imm_i64, pr_sra,     i64>;
defm SRD_IMM_I64 : MC_SHIFT_IMM_64<opcode_srd_imm_i64, pr_srd_i64, i64>;

foreach LEFT_SHIFT = {1 ... 62} in {
    defvar POW2 = !shl(1, LEFT_SHIFT);
    def : Pat<(sdiv i64:$ra, (i64 POW2)), (SRD_IMM_I64 GR:$ra, LEFT_SHIFT)>;
}

// shift amount may be also i32
def : Pat<(i64 (shl        i64:$rb, i32:$rc)), (SLL_U64 GR:$rb, GR:$rc)>;
def : Pat<(i64 (sra        i64:$rb, i32:$rc)), (SRA_I64 GR:$rb, GR:$rc)>;
def : Pat<(i64 (srl        i64:$rb, i32:$rc)), (SRL_U64 GR:$rb, GR:$rc)>;
def : Pat<(i64 (pr_srd_i64 i64:$rb, i32:$rc)), (SRD_I64 GR:$rb, GR:$rc)>;

def : Pat<(i128 (zext i32:$val)), (SRL_IMM_U32 $val, 0)>;
def : Pat<(i128 (zext i64:$val)), (SRL_IMM_U64 $val, 0)>;


// logical shifts are zero extension into bigger types
def : Pat<(i64  (zext (shl i32:$rb, uimm5:$shamt))), (SLL_IMM_U32 GR:$rb, uimm5:$shamt)>;
def : Pat<(i128 (zext (shl i32:$rb, uimm5:$shamt))), (SLL_IMM_U32 GR:$rb, uimm5:$shamt)>;
def : Pat<(i64  (zext (srl i32:$rb, uimm5:$shamt))), (SRL_IMM_U32 GR:$rb, uimm5:$shamt)>;
def : Pat<(i128 (zext (srl i32:$rb, uimm5:$shamt))), (SRL_IMM_U32 GR:$rb, uimm5:$shamt)>;
def : Pat<(i128 (zext (shl i64:$rb, uimm6:$shamt))), (SLL_IMM_U64 GR:$rb, uimm6:$shamt)>;
def : Pat<(i128 (zext (srl i64:$rb, uimm6:$shamt))), (SRL_IMM_U64 GR:$rb, uimm6:$shamt)>;

// algebraic shifts are sign extension into bigger types
def : Pat<(i64  (sext (sra i32:$rb, uimm5:$shamt))), (SRA_IMM_I32 GR:$rb, uimm5:$shamt)>;
def : Pat<(i128 (sext (sra i32:$rb, uimm5:$shamt))), (SRA_IMM_I32 GR:$rb, uimm5:$shamt)>;
def : Pat<(i128 (sext (sra i64:$rb, uimm6:$shamt))), (SRA_IMM_I64 GR:$rb, uimm6:$shamt)>;

//===----------------------------------------------------------------------===//
// funnel shifts
// fshl(X,Y,Z): (X << (Z % BW)) | (Y >> (BW - (Z % BW)))
// fshr(X,Y,Z): (X << (BW - (Z % BW))) | (Y >> (Z % BW))
//===----------------------------------------------------------------------===//
multiclass SHIFT_R4<fused_opx opx, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : FUSED_Rabcd<opx,
          (outs GR:$ra), (ins GR:$rb, GR:$rc, GR:$rd),
          !strconcat(opx.mnem, " $ra, $rb, $rc, $rd"),
          [], itin>;
}

defm SLP_I32  : SHIFT_R4<opcode_slp_i32>;
defm SRP_I32  : SHIFT_R4<opcode_srp_i32>;
defm SLP_I64  : SHIFT_R4<opcode_slp_i64>;
defm SRP_I64  : SHIFT_R4<opcode_srp_i64>;
defm SLP_I128 : SHIFT_R4<opcode_slp_i128>;
defm SRP_I128 : SHIFT_R4<opcode_srp_i128>;

multiclass
SHIFT_R3I<fused_opx opx, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : FUSED_Rabcd<opx,
          (outs GR:$ra), (ins GR:$rb, GR:$rc, uimm7:$rd),
          !strconcat(opx.mnem, " $ra, $rb, $rc, $rd"),
          [], itin>;
}

def SRP_IMM_I32  : FUSED_Rabcd<opcode_srp_imm_i32,  (outs GR:$ra), (ins GR:$rb, GR:$rc, uimm7i64:$rd), !strconcat(opcode_srp_imm_i32.mnem,  " $ra, $rb, $rc, $rd"), []>;
def SRP_IMM_I64  : FUSED_Rabcd<opcode_srp_imm_i64,  (outs GR:$ra), (ins GR:$rb, GR:$rc, uimm7i64:$rd), !strconcat(opcode_srp_imm_i64.mnem,  " $ra, $rb, $rc, $rd"), []>;
def SRP_IMM_I128 : FUSED_Rabcd<opcode_srp_imm_i128, (outs GR:$ra), (ins GR:$rb, GR:$rc, uimm7i64:$rd), !strconcat(opcode_srp_imm_i128.mnem, " $ra, $rb, $rc, $rd"), []>;

let isCodeGenOnly = 1 in {
  defm SRPI32W : SHIFT_R3I<opcode_srp_imm_i32>;
  defm SRPI32  : SHIFT_R3I<opcode_srp_imm_i64>;
  defm SRPI32Q : SHIFT_R3I<opcode_srp_imm_i128>;
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

defm : OP_FUNNEL_SHIFT<SLP_I32,  SRP_I32,  SRP_IMM_I32,  i32,  i64, uimm7i64, 31>;
defm : OP_FUNNEL_SHIFT<SLP_I32,  SRP_I32,  SRPI32W,      i32,  i32, uimm7,    31>;
defm : OP_FUNNEL_SHIFT<SLP_I64,  SRP_I64,  SRP_IMM_I64,  i64,  i64, uimm7i64, 63>;
defm : OP_FUNNEL_SHIFT<SLP_I64,  SRP_I64,  SRPI32,       i64,  i32, uimm7,    63>;
defm : OP_FUNNEL_SHIFT<SLP_I128, SRP_I128, SRP_IMM_I128, i128, i64, uimm7i64, 127>;
defm : OP_FUNNEL_SHIFT<SLP_I128, SRP_I128, SRPI32Q,      i128, i32, uimm7,    127>;

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
  defm : OP_FUNNEL_SHIFT_IMM<SRP_IMM_I32, i32, i64, NBITS, LEFT_SHIFT>;
  defm : OP_FUNNEL_SHIFT_IMM<SRPI32W,     i32, i32, NBITS, LEFT_SHIFT>;
}
foreach NBITS = {1 ... 63} in {
  defvar LEFT_SHIFT  = !sub(64, NBITS);
  defm : OP_FUNNEL_SHIFT_IMM<SRP_IMM_I64, i64, i64, NBITS, LEFT_SHIFT>;
  defm : OP_FUNNEL_SHIFT_IMM<SRPI32,      i64, i32, NBITS, LEFT_SHIFT>;
}
foreach NBITS = {1 ... 127} in {
  defvar LEFT_SHIFT  = !sub(128, NBITS);
  defm : OP_FUNNEL_SHIFT_IMM<SRP_IMM_I128, i128, i64, NBITS, LEFT_SHIFT>;
  defm : OP_FUNNEL_SHIFT_IMM<SRPI32Q,      i128, i32, NBITS, LEFT_SHIFT>;
}

//===----------------------------------------------------------------------===//
// double shift (extract bitfield)
//===----------------------------------------------------------------------===//
def pr_slsrl : PatFrag<(ops node:$src1, node:$src2, node:$src3), (srl (shl node:$src1, node:$src2), node:$src3)>;
def pr_slsra : PatFrag<(ops node:$src1, node:$src2, node:$src3), (sra (shl node:$src1, node:$src2), node:$src3)>;

defm SLSRL_U64 : FUSED_R4<opcode_slsrl_u64, pr_slsrl, i64>;
defm SLSRA_I64 : FUSED_R4<opcode_slsra_i64, pr_slsra, i64>;
defm SLSRL_U32 : FUSED_R4<opcode_slsrl_u32, pr_slsrl, i32>;
defm SLSRA_I32 : FUSED_R4<opcode_slsra_i32, pr_slsra, i32>;

defm SLSRL_IMM_U64 : FUSED_R4rrii<opcode_slsrl_imm_u64, pr_slsrl, i64>;
defm SLSRA_IMM_I64 : FUSED_R4rrii<opcode_slsra_imm_i64, pr_slsra, i64>;

// (x >> offset) & mask<nbits> => (x << (64 - offset - nbits)) >> (64 - nbits)
// both srl/sra is identical because zero/sign extension will be masked

foreach NBITS = {1 ... 63} in {
    defvar MASK = !sub(!shl(1, NBITS), 1); // NBITS ones
    foreach OFFSET = {1 ... 63} in {
        defvar COMBINED = !add(NBITS, OFFSET);
        if !lt(COMBINED, 64) then {
            defvar LEFT_SHIFT  = !sub(64, COMBINED);
            defvar RIGHT_SHIFT = !add(LEFT_SHIFT, OFFSET);
            def : Pat<(and (srl i64:$rb, (i32 OFFSET)), MASK), (SLSRL_IMM_U64 GR:$rb, LEFT_SHIFT, RIGHT_SHIFT)>;
            def : Pat<(and (sra i64:$rb, (i32 OFFSET)), MASK), (SLSRL_IMM_U64 GR:$rb, LEFT_SHIFT, RIGHT_SHIFT)>;
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
            def : Pat<(and (srl i32:$rb, (i32 OFFSET)), MASK), (SLSRL_IMM_U64 GR:$rb, LEFT_SHIFT, RIGHT_SHIFT)>;
            def : Pat<(and (sra i32:$rb, (i32 OFFSET)), MASK), (SLSRL_IMM_U64 GR:$rb, LEFT_SHIFT, RIGHT_SHIFT)>;

            def : Pat<(i64 (zext (and (srl i32:$rb, (i32 OFFSET)), (i32 MASK)))), (SLSRL_IMM_U64 GR:$rb, LEFT_SHIFT, RIGHT_SHIFT)>;
            def : Pat<(and (i64 (zext (sra i32:$rb, (i32 OFFSET)))), (i64 MASK)), (SLSRL_IMM_U64 GR:$rb, LEFT_SHIFT, RIGHT_SHIFT)>;

            def : Pat<(and (i64 (anyext (srl i32:$rb, (i32 OFFSET)))), (i64 MASK)), (SLSRL_IMM_U64 GR:$rb, LEFT_SHIFT, RIGHT_SHIFT)>;
            def : Pat<(and (i64 (anyext (sra i32:$rb, (i32 OFFSET)))), (i64 MASK)), (SLSRA_IMM_I64 GR:$rb, LEFT_SHIFT, RIGHT_SHIFT)>;

            def : Pat<(i32 (and (srl i32:$rb, (i32 OFFSET)), MASK)), (SLSRL_IMM_U64 GR:$rb, LEFT_SHIFT, RIGHT_SHIFT)>;
            def : Pat<(i32 (and (sra i32:$rb, (i32 OFFSET)), MASK)), (SLSRL_IMM_U64 GR:$rb, LEFT_SHIFT, RIGHT_SHIFT)>;
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

def : Pat<(i64 (zext i32:$val)), (SRL_IMM_U32 $val, 0)>;
def : Pat<(i64 (sext i32:$val)), (SRA_IMM_I32 $val, 0)>;

def : Pat<(i64 (and i64:$val, 0xffffffff)), (SRL_IMM_U32 $val, 0)>;
def : Pat<(i64 (sext_inreg i64:$val, i32)), (SRA_IMM_I32 $val, 0)>;

def : Pat<(i64 (sext_inreg i64:$val, i8 )), (SLSRA_IMM_I64 i64:$val, 56, 56)>;
def : Pat<(i64 (sext_inreg i64:$val, i16)), (SLSRA_IMM_I64 i64:$val, 48, 48)>;
def : Pat<(i64 (sext_inreg i64:$val, i32)), (SLSRA_IMM_I64 i64:$val, 32, 32)>;

def : Pat<(i32 (sext_inreg i32:$val, i8 )), (SLSRA_IMM_I64 i32:$val, 56, 56)>;
def : Pat<(i32 (sext_inreg i32:$val, i16)), (SLSRA_IMM_I64 i32:$val, 48, 48)>;

//===----------------------------------------------------------------------===//
// bit-field shift/deposits
//===----------------------------------------------------------------------===//
def DEP  : PRIMARY_Rabcde<opcode_dep,  (outs GR:$ra), (ins GR:$rb, GR:$rc, uimm7:$rd, uimm7:$re),
                          !strconcat(opcode_dep.mnem, " $ra, $rb, $rc, $rd, $re"), []>;

multiclass
SHIFT_R2I2<fused_opx opx, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : FUSED_Rabcd<opx,
          (outs GR:$ra), (ins GR:$rb, uimm7:$rc, uimm7:$rd),
          !strconcat(opx.mnem, " $ra, $rb, $rc, $rd"),
          [], itin>;
}

defm DEPS : SHIFT_R2I2<opcode_dep_s>;
defm DEPC : SHIFT_R2I2<opcode_dep_c>;
defm DEPA : SHIFT_R2I2<opcode_dep_a>;

//===----------------------------------------------------------------------===//
// shift-left + op
//===----------------------------------------------------------------------===//
defm SL_ADD_I64  : SHIFT_R3I<opcode_sl_add_i64>;
defm SL_ADD_I32  : SHIFT_R3I<opcode_sl_add_i32>;
defm SL_ADD_U32  : SHIFT_R3I<opcode_sl_add_u32>;
defm SL_SUB_I64  : SHIFT_R3I<opcode_sl_sub_i64>;
defm SL_SUB_I32  : SHIFT_R3I<opcode_sl_sub_i32>;
defm SL_SUB_U32  : SHIFT_R3I<opcode_sl_sub_u32>;
defm SL_SUBF_I64 : SHIFT_R3I<opcode_sl_subf_i64>;
defm SL_SUBF_I32 : SHIFT_R3I<opcode_sl_subf_i32>;
defm SL_SUBF_U32 : SHIFT_R3I<opcode_sl_subf_u32>;
defm SL_OR       : SHIFT_R3I<opcode_sl_or>;
defm SL_XOR      : SHIFT_R3I<opcode_sl_xor>;

def : Pat<(i64 (pr_add  i64:$rb, (shl i64:$rc, uimm7:$imm))), (SL_ADD_I64  GR:$rb, GR:$rc, uimm7:$imm)>;
def : Pat<(i32 (pr_add  i32:$rb, (shl i32:$rc, uimm7:$imm))), (SL_ADD_I32  GR:$rb, GR:$rc, uimm7:$imm)>;
def : Pat<(i32 (pr_add  i32:$rb, (shl i32:$rc, uimm7:$imm))), (SL_ADD_U32  GR:$rb, GR:$rc, uimm7:$imm)>;
def : Pat<(i64 (pr_sub  i64:$rb, (shl i64:$rc, uimm7:$imm))), (SL_SUB_I64  GR:$rb, GR:$rc, uimm7:$imm)>;
def : Pat<(i32 (pr_sub  i32:$rb, (shl i32:$rc, uimm7:$imm))), (SL_SUB_I32  GR:$rb, GR:$rc, uimm7:$imm)>;
def : Pat<(i32 (pr_sub  i32:$rb, (shl i32:$rc, uimm7:$imm))), (SL_SUB_U32  GR:$rb, GR:$rc, uimm7:$imm)>;
def : Pat<(i64 (pr_subf i64:$rb, (shl i64:$rc, uimm7:$imm))), (SL_SUBF_I64 GR:$rb, GR:$rc, uimm7:$imm)>;
def : Pat<(i32 (pr_subf i32:$rb, (shl i32:$rc, uimm7:$imm))), (SL_SUBF_I32 GR:$rb, GR:$rc, uimm7:$imm)>;
def : Pat<(i32 (pr_subf i32:$rb, (shl i32:$rc, uimm7:$imm))), (SL_SUBF_U32 GR:$rb, GR:$rc, uimm7:$imm)>;
def : Pat<(i64 (pr_or   i64:$rb, (shl i64:$rc, uimm7:$imm))), (SL_OR       GR:$rb, GR:$rc, uimm7:$imm)>;
def : Pat<(i32 (pr_or   i32:$rb, (shl i32:$rc, uimm7:$imm))), (SL_OR       GR:$rb, GR:$rc, uimm7:$imm)>;
def : Pat<(i64 (pr_xor  i64:$rb, (shl i64:$rc, uimm7:$imm))), (SL_XOR      GR:$rb, GR:$rc, uimm7:$imm)>;
def : Pat<(i32 (pr_xor  i32:$rb, (shl i32:$rc, uimm7:$imm))), (SL_XOR      GR:$rb, GR:$rc, uimm7:$imm)>;

// 32-bit SL_ADD|SL_SUB|SL_SUBF instructions are free sext/zext to 64-bit
def : Pat<(i64 (sext (pr_add  i32:$rb, (shl i32:$rc, uimm7:$imm)))), (SL_ADD_I32  GR:$rb, GR:$rc, uimm7:$imm)>;
def : Pat<(i64 (zext (pr_add  i32:$rb, (shl i32:$rc, uimm7:$imm)))), (SL_ADD_U32  GR:$rb, GR:$rc, uimm7:$imm)>;
def : Pat<(i64 (sext (pr_sub  i32:$rb, (shl i32:$rc, uimm7:$imm)))), (SL_SUB_I32  GR:$rb, GR:$rc, uimm7:$imm)>;
def : Pat<(i64 (zext (pr_sub  i32:$rb, (shl i32:$rc, uimm7:$imm)))), (SL_SUB_U32  GR:$rb, GR:$rc, uimm7:$imm)>;
def : Pat<(i64 (sext (pr_subf i32:$rb, (shl i32:$rc, uimm7:$imm)))), (SL_SUBF_I32 GR:$rb, GR:$rc, uimm7:$imm)>;
def : Pat<(i64 (zext (pr_subf i32:$rb, (shl i32:$rc, uimm7:$imm)))), (SL_SUBF_U32 GR:$rb, GR:$rc, uimm7:$imm)>;

// 64-bit SL_ADD|SL_SUB|SL_SUBF instructions are free sext/zext to 128-bit
def : Pat<(i128 (sext (pr_add  i64:$rb, (shl i64:$rc, uimm7:$imm)))), (SL_ADD_I64  GR:$rb, GR:$rc, uimm7:$imm)>;
//def : Pat<(i128 (zext (pr_add  i64:$rb, (shl i64:$rc, uimm7:$imm)))), (SL_ADD_U64  GR:$rb, GR:$rc, uimm7:$imm)>;
def : Pat<(i128 (sext (pr_sub  i64:$rb, (shl i64:$rc, uimm7:$imm)))), (SL_SUB_I64  GR:$rb, GR:$rc, uimm7:$imm)>;
//def : Pat<(i128 (zext (pr_sub  i64:$rb, (shl i64:$rc, uimm7:$imm)))), (SL_SUB_U64  GR:$rb, GR:$rc, uimm7:$imm)>;
def : Pat<(i128 (sext (pr_subf i64:$rb, (shl i64:$rc, uimm7:$imm)))), (SL_SUBF_I64 GR:$rb, GR:$rc, uimm7:$imm)>;
//def : Pat<(i128 (zext (pr_subf i64:$rb, (shl i64:$rc, uimm7:$imm)))), (SL_SUBF_U64 GR:$rb, GR:$rc, uimm7:$imm)>;
