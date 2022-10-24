//===----- PostriscInstrInfoShift.td - Target Description for Postrisc ----===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//


//===----------------------------------------------------------------------===//
// sign/zero extend
// SEXT_IXX/ZEXT_IXX propagate sign/zero through entire register,
// so may serve for all bigger types
//===----------------------------------------------------------------------===//
multiclass MISC_extend<misc_opx opx, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : MISC_Rab<opx, (outs GR:$ra), (ins GR:$rb),
         !strconcat(opx.mnem, " $ra, $rb"), [], itin>;
}

defm SEXT_I8  : MISC_extend<opcode_sext_i8>;
defm SEXT_I16 : MISC_extend<opcode_sext_i16>;
defm SEXT_I32 : MISC_extend<opcode_sext_i32>;
defm SEXT_I64 : MISC_extend<opcode_sext_i64>;

// sext to bigger type
def : Pat<(i64  (sext i32:$val)), (SEXT_I32 $val)>;
def : Pat<(i128 (sext i32:$val)), (SEXT_I32 $val)>;
def : Pat<(i128 (sext i64:$val)), (SEXT_I64 $val)>;

// sext in-reg to same type
def : Pat<(i32  (sext_inreg i32:$val,  i8 )), (SEXT_I8  $val)>;
def : Pat<(i32  (sext_inreg i32:$val,  i16)), (SEXT_I16 $val)>;
def : Pat<(i64  (sext_inreg i64:$val,  i8 )), (SEXT_I8  $val)>;
def : Pat<(i64  (sext_inreg i64:$val,  i16)), (SEXT_I16 $val)>;
def : Pat<(i64  (sext_inreg i64:$val,  i32)), (SEXT_I32 $val)>;
def : Pat<(i128 (sext_inreg i128:$val, i8 )), (SEXT_I8  $val)>;
def : Pat<(i128 (sext_inreg i128:$val, i16)), (SEXT_I16 $val)>;
def : Pat<(i128 (sext_inreg i128:$val, i32)), (SEXT_I32 $val)>;
def : Pat<(i128 (sext_inreg i128:$val, i64)), (SEXT_I64 $val)>;

// sext in-reg to bigger type
def : Pat<(i64  (sext (sext_inreg i32:$val,  i8 ))), (SEXT_I8  $val)>;
def : Pat<(i64  (sext (sext_inreg i32:$val,  i16))), (SEXT_I16 $val)>;
def : Pat<(i128 (sext (sext_inreg i32:$val,  i8 ))), (SEXT_I8  $val)>;
def : Pat<(i128 (sext (sext_inreg i32:$val,  i16))), (SEXT_I16 $val)>;
def : Pat<(i128 (sext (sext_inreg i64:$val,  i8 ))), (SEXT_I8  $val)>;
def : Pat<(i128 (sext (sext_inreg i64:$val,  i16))), (SEXT_I16 $val)>;
def : Pat<(i128 (sext (sext_inreg i64:$val,  i32))), (SEXT_I32 $val)>;

defm ZEXT_I8  : MISC_extend<opcode_zext_i8>;
defm ZEXT_I16 : MISC_extend<opcode_zext_i16>;
defm ZEXT_I32 : MISC_extend<opcode_zext_i32>;
defm ZEXT_I64 : MISC_extend<opcode_zext_i64>;

// zext to bigger type
let AddedComplexity = Complexity_Zext.value in {
  def : Pat<(i64  (zext i32:$val)), (ZEXT_I32 $val)>;
  def : Pat<(i128 (zext i32:$val)), (ZEXT_I32 $val)>;
  def : Pat<(i128 (zext i64:$val)), (ZEXT_I64 $val)>;

  // special ANDs with same type
  def : Pat<(i32  (and i32 :$val, 0xff              )), (ZEXT_I8  $val)>;
  def : Pat<(i32  (and i32 :$val, 0xffff            )), (ZEXT_I16 $val)>;
  def : Pat<(i64  (and i64 :$val, 0xff              )), (ZEXT_I8  $val)>;
  def : Pat<(i64  (and i64 :$val, 0xffff            )), (ZEXT_I16 $val)>;
  def : Pat<(i64  (and i64 :$val, 0xffffffff        )), (ZEXT_I32 $val)>;
  def : Pat<(i128 (and i128:$val, 0xff              )), (ZEXT_I8  $val)>;
  def : Pat<(i128 (and i128:$val, 0xffff            )), (ZEXT_I16 $val)>;
  def : Pat<(i128 (and i128:$val, 0xffffffff        )), (ZEXT_I32 $val)>;
  def : Pat<(i128 (and i128:$val, 0xffffffffffffffff)), (ZEXT_I64 $val)>;

  // special ANDs and zext to bigger type
  def : Pat<(i64  (zext (and i32:$val, 0xff      ))), (ZEXT_I8  $val)>;
  def : Pat<(i64  (zext (and i32:$val, 0xffff    ))), (ZEXT_I16 $val)>;
  def : Pat<(i128 (zext (and i32:$val, 0xff      ))), (ZEXT_I8  $val)>;
  def : Pat<(i128 (zext (and i32:$val, 0xffff    ))), (ZEXT_I16 $val)>;
  def : Pat<(i128 (zext (and i64:$val, 0xff      ))), (ZEXT_I8  $val)>;
  def : Pat<(i128 (zext (and i64:$val, 0xffff    ))), (ZEXT_I16 $val)>;
  def : Pat<(i128 (zext (and i64:$val, 0xffffffff))), (ZEXT_I32 $val)>;
}

//===----------------------------------------------------------------------===//
//
// Shift Instructions
//
//===----------------------------------------------------------------------===//
multiclass MC_SHIFT_S32<misc_opx Opc, PatFrag Op, ValueType VT, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : MISC_Rabc<Opc, (outs GR:$ra), (ins GR:$rb, GR:$rc),
                 !strconcat(Opc.mnem, " $ra, $rb, $rc"),
                 [(set VT:$ra, (Op VT:$rb, i32:$rc))], itin>;
}

defm SLL_U32 : MC_SHIFT_S32<opcode_sll_u32, pr_shl, i32>;
defm SRL_U32 : MC_SHIFT_S32<opcode_srl_u32, pr_srl, i32>;
defm SRA_I32 : MC_SHIFT_S32<opcode_sra_i32, pr_sra, i32>;

defm SLL_U64 : MC_SHIFT_S32<opcode_sll_u64, pr_shl, i64>;
defm SRL_U64 : MC_SHIFT_S32<opcode_srl_u64, pr_srl, i64>;
defm SRA_I64 : MC_SHIFT_S32<opcode_sra_i64, pr_sra, i64>;

defm SLL_U128 : MC_SHIFT_S32<opcode_sll_u128, pr_shl, i128>;
defm SRL_U128 : MC_SHIFT_S32<opcode_srl_u128, pr_srl, i128>;
defm SRA_I128 : MC_SHIFT_S32<opcode_sra_i128, pr_sra, i128>;

class pr_divp2<ValueType Ty> : PatFrag<(ops node:$src1, node:$src2), (sdiv node:$src1, (shl (Ty 1), node:$src2))>;

defm DIVP2_I32  : MC_SHIFT_S32<opcode_divp2_i32,  pr_divp2<i32>,  i32>;
defm DIVP2_I64  : MC_SHIFT_S32<opcode_divp2_i64,  pr_divp2<i64>,  i64>;
defm DIVP2_I128 : MC_SHIFT_S32<opcode_divp2_i128, pr_divp2<i128>, i128>;

// signx rd -> sra rd, %g0, rd
def : InstAlias<"signx $ra", (SRA_I32 GR:$ra, GR:$ra, gz), 0>;
// signx reg, rd -> sra reg, %g0, rd
def : InstAlias<"signx $ra, $rb", (SRA_I32 GR:$ra, GR:$rb, gz), 0>;

// shift amount may be also i64
def : Pat<(i64 (shl i64:$rb, i64:$rc)), (SLL_U64 GR:$rb, GR:$rc)>;
def : Pat<(i64 (sra i64:$rb, i64:$rc)), (SRA_I64 GR:$rb, GR:$rc)>;
def : Pat<(i64 (srl i64:$rb, i64:$rc)), (SRL_U64 GR:$rb, GR:$rc)>;

def : Pat<(i32  (pr_divp2<i32>   i32:$rb, i64:$rc)), (DIVP2_I32  GR:$rb, GR:$rc)>;
def : Pat<(i64  (pr_divp2<i64>   i64:$rb, i64:$rc)), (DIVP2_I64  GR:$rb, GR:$rc)>;
def : Pat<(i128 (pr_divp2<i128> i128:$rb, i64:$rc)), (DIVP2_I128 GR:$rb, GR:$rc)>;


//===----------------------------------------------------------------------===//
//
// Shift-immediate Instructions
//
//===----------------------------------------------------------------------===//

defm SLL_IMM_U32 : MC_SHIFT_IMM<opcode_sll_imm_u32>;
defm SRL_IMM_U32 : MC_SHIFT_IMM<opcode_srl_imm_u32>;
defm SRA_IMM_I32 : MC_SHIFT_IMM<opcode_sra_imm_i32>;

def : Pat<(i32 (shl i32:$rb, uimm7:$shcnt)), (SLL_IMM_U32 GR:$rb, uimm7:$shcnt)>;
def : Pat<(i32 (srl i32:$rb, uimm7:$shcnt)), (SRL_IMM_U32 GR:$rb, uimm7:$shcnt)>;
def : Pat<(i32 (sra i32:$rb, uimm7:$shcnt)), (SRA_IMM_I32 GR:$rb, uimm7:$shcnt)>;

defm SLL_IMM_U64 : MC_SHIFT_IMM<opcode_sll_imm_u64>;
defm SRL_IMM_U64 : MC_SHIFT_IMM<opcode_srl_imm_u64>;
defm SRA_IMM_I64 : MC_SHIFT_IMM<opcode_sra_imm_i64>;

def : Pat<(i64 (shl i64:$rb, uimm7:$shcnt)), (SLL_IMM_U64 GR:$rb, uimm7:$shcnt)>;
def : Pat<(i64 (srl i64:$rb, uimm7:$shcnt)), (SRL_IMM_U64 GR:$rb, uimm7:$shcnt)>;
def : Pat<(i64 (sra i64:$rb, uimm7:$shcnt)), (SRA_IMM_I64 GR:$rb, uimm7:$shcnt)>;

defm SLL_IMM_U128 : MC_SHIFT_IMM<opcode_sll_imm_u128>;
defm SRL_IMM_U128 : MC_SHIFT_IMM<opcode_srl_imm_u128>;
defm SRA_IMM_I128 : MC_SHIFT_IMM<opcode_sra_imm_i128>;

def : Pat<(i128 (shl i128:$rb, uimm7:$shcnt)), (SLL_IMM_U128 GR:$rb, uimm7:$shcnt)>;
def : Pat<(i128 (srl i128:$rb, uimm7:$shcnt)), (SRL_IMM_U128 GR:$rb, uimm7:$shcnt)>;
def : Pat<(i128 (sra i128:$rb, uimm7:$shcnt)), (SRA_IMM_I128 GR:$rb, uimm7:$shcnt)>;

defm DIVP2_IMM_I32  : MC_SHIFT_IMM<opcode_divp2_imm_i32>;
defm DIVP2_IMM_I64  : MC_SHIFT_IMM<opcode_divp2_imm_i64>;
defm DIVP2_IMM_I128 : MC_SHIFT_IMM<opcode_divp2_imm_i128>;

def : Pat<(i32  (pr_divp2<i32>  i32 :$rb, uimm7:$shcnt)), (DIVP2_IMM_I32  GR:$rb, uimm7:$shcnt)>;
def : Pat<(i64  (pr_divp2<i64>  i64 :$rb, uimm7:$shcnt)), (DIVP2_IMM_I64  GR:$rb, uimm7:$shcnt)>;
def : Pat<(i128 (pr_divp2<i128> i128:$rb, uimm7:$shcnt)), (DIVP2_IMM_I128 GR:$rb, uimm7:$shcnt)>;

let AddedComplexity = Complexity_DivP2.value in {
  def : Pat<(sdiv i32 :$a, (i32  imm_pow2:$imm)), (DIVP2_IMM_I32  GR:$a, (imm_pow2_xform imm:$imm))>;
  def : Pat<(sdiv i64 :$a, (i64  imm_pow2:$imm)), (DIVP2_IMM_I64  GR:$a, (imm_pow2_xform imm:$imm))>;
  def : Pat<(sdiv i128:$a, (i128 imm_pow2:$imm)), (DIVP2_IMM_I128 GR:$a, (imm_pow2_xform imm:$imm))>;
}

// logical shifts are zero extension into bigger types
def : Pat<(i64  (zext (shl i32:$rb, uimm7:$shamt))), (SLL_IMM_U32 GR:$rb, uimm7:$shamt)>;
def : Pat<(i128 (zext (shl i32:$rb, uimm7:$shamt))), (SLL_IMM_U32 GR:$rb, uimm7:$shamt)>;
def : Pat<(i64  (zext (srl i32:$rb, uimm7:$shamt))), (SRL_IMM_U32 GR:$rb, uimm7:$shamt)>;
def : Pat<(i128 (zext (srl i32:$rb, uimm7:$shamt))), (SRL_IMM_U32 GR:$rb, uimm7:$shamt)>;
def : Pat<(i128 (zext (shl i64:$rb, uimm7:$shamt))), (SLL_IMM_U64 GR:$rb, uimm7:$shamt)>;
def : Pat<(i128 (zext (srl i64:$rb, uimm7:$shamt))), (SRL_IMM_U64 GR:$rb, uimm7:$shamt)>;

// algebraic shifts are sign extension into bigger types
def : Pat<(i64  (sext (sra i32:$rb, uimm7:$shamt))), (SRA_IMM_I32 GR:$rb, uimm7:$shamt)>;
def : Pat<(i128 (sext (sra i32:$rb, uimm7:$shamt))), (SRA_IMM_I32 GR:$rb, uimm7:$shamt)>;
def : Pat<(i128 (sext (sra i64:$rb, uimm7:$shamt))), (SRA_IMM_I64 GR:$rb, uimm7:$shamt)>;

//===----------------------------------------------------------------------===//
// funnel shifts
// fshl(X,Y,Z): (X << (Z % BW)) | (Y >> (BW - (Z % BW)))
// fshr(X,Y,Z): (X << (BW - (Z % BW))) | (Y >> (Z % BW))
//===----------------------------------------------------------------------===//
defm SLP_I32  : FORMAT_R4<opcode_slp_i32>;
defm SRP_I32  : FORMAT_R4<opcode_srp_i32>;
defm SLP_I64  : FORMAT_R4<opcode_slp_i64>;
defm SRP_I64  : FORMAT_R4<opcode_srp_i64>;
defm SLP_I128 : FORMAT_R4<opcode_slp_i128>;
defm SRP_I128 : FORMAT_R4<opcode_srp_i128>;

multiclass
SHIFT_R3I<fused_opx opx, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : FUSED_Rabcd<opx,
          (outs GR:$ra), (ins GR:$rb, GR:$rc, uimm7:$rd),
          !strconcat(opx.mnem, " $ra, $rb, $rc, $rd"),
          [], itin>;
}

defm SRP_IMM_I32  : SHIFT_R3I<opcode_srp_imm_i32>;
defm SRP_IMM_I64  : SHIFT_R3I<opcode_srp_imm_i64>;
defm SRP_IMM_I128 : SHIFT_R3I<opcode_srp_imm_i128>;

multiclass OP_FUNNEL_SHIFT<InstBase SL, InstBase SR, InstBase SRI, ValueType Ty, int mask>
{
  foreach Ts = [ i32, i64 ] in {
    def : Pat<(fshl Ty:$rb, Ty:$rc, Ts:$rd), (SL GR:$rb, GR:$rc, GR:$rd)>;
    def : Pat<(fshr Ty:$rb, Ty:$rc, Ts:$rd), (SR GR:$rb, GR:$rc, GR:$rd)>;

    // Double "funnel" shift amount is implicitly masked.
    // (fshl/fshr x (and y, 63)) ==> (fshl/fshr x, y)
    def : Pat<(fshr Ty:$rb, Ty:$rc, (and Ts:$rd, mask)), (SR GR:$rb, GR:$rc, GR:$rd)>;
    def : Pat<(fshl Ty:$rb, Ty:$rc, (and Ts:$rd, mask)), (SL GR:$rb, GR:$rc, GR:$rd)>;
  }

  def : Pat<(fshr Ty:$rb, Ty:$rc, uimm7:$rd), (SRI GR:$rb, GR:$rc, uimm7:$rd)>;
}

defm : OP_FUNNEL_SHIFT<SLP_I32,  SRP_I32,  SRP_IMM_I32,  i32,  31>;
defm : OP_FUNNEL_SHIFT<SLP_I64,  SRP_I64,  SRP_IMM_I64,  i64,  63>;
defm : OP_FUNNEL_SHIFT<SLP_I128, SRP_I128, SRP_IMM_I128, i128, 127>;

// model left funnel shifts by immediate via right funnel shifts
multiclass OP_FUNNEL_SHIFT_IMM<InstBase SRI, ValueType Ty, ValueType Ts, int NBITS, int LEFT_SHIFT>
{
  def : Pat<(fshl Ty:$rb, Ty:$rc, (Ts LEFT_SHIFT)), (SRI GR:$rb, GR:$rc, NBITS)>;
  def : Pat<(or (srl Ty:$rb, (Ts NBITS)), (shl Ty:$rc, (Ts LEFT_SHIFT))), (SRI GR:$rb, GR:$rc, NBITS)>;
  def : Pat<(or (shl Ty:$rc, (Ts LEFT_SHIFT)), (srl Ty:$rb, (Ts NBITS))), (SRI GR:$rb, GR:$rc, NBITS)>;
  def : Pat<(rotr Ty:$rb, (Ts NBITS     )), (SRI GR:$rb, GR:$rb, NBITS)>;
  def : Pat<(rotl Ty:$rb, (Ts LEFT_SHIFT)), (SRI GR:$rb, GR:$rb, NBITS)>;
}

foreach Ts = [ i32, i64 ] in {
  foreach NBITS = {1 ... 31} in {
    defm : OP_FUNNEL_SHIFT_IMM<SRP_IMM_I32, i32, Ts, NBITS, !sub(32, NBITS)>;
  }
  foreach NBITS = {1 ... 63} in {
    defm : OP_FUNNEL_SHIFT_IMM<SRP_IMM_I64, i64, Ts, NBITS, !sub(64, NBITS)>;
  }
  foreach NBITS = {1 ... 127} in {
    defm : OP_FUNNEL_SHIFT_IMM<SRP_IMM_I128, i128, Ts, NBITS, !sub(128, NBITS)>;
  }
}

//===----------------------------------------------------------------------===//
// double shift (extract bitfield)
//===----------------------------------------------------------------------===//
def pr_slsrl : PatFrag<(ops node:$src1, node:$src2, node:$src3), (srl (shl node:$src1, node:$src2), node:$src3)>;
def pr_slsra : PatFrag<(ops node:$src1, node:$src2, node:$src3), (sra (shl node:$src1, node:$src2), node:$src3)>;

defm SLSRL_U64 : FUSED_R4<opcode_slsrl_u64, pr_slsrl, i64, i64, i32, i32>;
defm SLSRA_I64 : FUSED_R4<opcode_slsra_i64, pr_slsra, i64, i64, i32, i32>;
defm SLSRL_U32 : FUSED_R4<opcode_slsrl_u32, pr_slsrl, i32, i32, i32, i32>;
defm SLSRA_I32 : FUSED_R4<opcode_slsra_i32, pr_slsra, i32, i32, i32, i32>;

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
// bit-field shift/deposits
//===----------------------------------------------------------------------===//
def DEPOSIT : PRIMARY_Rabcde<opcode_deposit,  (outs GR:$ra), (ins GR:$rb, GR:$rc, uimm7:$rd, uimm7:$re),
                      !strconcat(opcode_deposit.mnem, " $ra, $rb, $rc, $rd, $re"), []>;

multiclass
SHIFT_R2I2<fused_opx opx, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : FUSED_Rabcd<opx,
          (outs GR:$ra), (ins GR:$rb, uimm7:$rc, uimm7:$rd),
          !strconcat(opx.mnem, " $ra, $rb, $rc, $rd"),
          [], itin>;
}

multiclass
DepositDef<ValueType Ty, int sizeof, int all_ones>
{
    foreach LEFT_SHIFT = !range(0, sizeof) in { // up to [0..31|63]

        // if shift == 0, sizes are [1..31], not including last (32), to not confuse with just MOV
        // else, sizes are up to the rest of register [1..32-shift], including last (32-shift)
        defvar size_limit = !if(!eq(LEFT_SHIFT, 0), sizeof, !add(!sub(sizeof, LEFT_SHIFT), 1));

        foreach MASK_SIZE = !range(1, size_limit) in {

            defvar MASK = !sub(!shl(1, MASK_SIZE), 1);          // 0x00000FFF
            defvar MASK_SHIFTED = !shl(MASK, LEFT_SHIFT);       // 0x000FFF00
            defvar MASK_INVRTED = !xor(MASK_SHIFTED, all_ones); // 0xFFF000FF

            if !eq(LEFT_SHIFT, 0) then { // zero shift
                let AddedComplexity = Complexity_Deposit.value in {
                    def : Pat<(Ty (or (Ty (and Ty:$rb, (Ty MASK_INVRTED))),
                                      (Ty (and Ty:$rc, (Ty MASK_SHIFTED)))  )), (DEPOSIT GR:$rb, GR:$rc, LEFT_SHIFT, MASK_SIZE)>;

                    // swapped OR
                    def : Pat<(Ty (or (Ty (and Ty:$rc, (Ty MASK_SHIFTED))),
                                      (Ty (and Ty:$rb, (Ty MASK_INVRTED)))  )), (DEPOSIT GR:$rb, GR:$rc, LEFT_SHIFT, MASK_SIZE)>;
                }

                let AddedComplexity = Complexity_DepositZero.value in {
                    // clearing bits (x & 0x00000FFF) as inserting part into GZ
                    def : Pat<(Ty (and Ty:$rb, (Ty MASK_INVRTED))), (DEPOSIT GR:$rb, (Ty gz), 0, MASK_SIZE)>;

                    // clearing bits (x & 0xFFFFF000) as inserting part from GZ
                    def : Pat<(Ty (and Ty:$rc, (Ty MASK_SHIFTED))), (DEPOSIT (Ty gz), GR:$rc, 0, MASK_SIZE)>;
                }

            } else { // nonzero shift

                let AddedComplexity = Complexity_Deposit.value in {
                    // mask after shift
                    def : Pat<(Ty (or (Ty (and          Ty:$rb,                     (Ty MASK_INVRTED))),
                                      (Ty (and (Ty (shl Ty:$rc, (i32 LEFT_SHIFT))), (Ty MASK_SHIFTED)))
                              )),
                              (DEPOSIT GR:$rb, GR:$rc, LEFT_SHIFT, MASK_SIZE)>;

                    // swapped OR, mask after shift
                    def : Pat<(Ty (or (Ty (and (Ty (shl Ty:$rc, (i32 LEFT_SHIFT))), (Ty MASK_SHIFTED))),
                                      (Ty (and          Ty:$rb,                     (Ty MASK_INVRTED)))
                              )),
                              (DEPOSIT GR:$rb, GR:$rc, LEFT_SHIFT, MASK_SIZE)>;

                    // mask before shift
                    def : Pat<(Ty (or  (Ty (and Ty:$rb, (Ty MASK_INVRTED))),
                              (Ty (shl (Ty (and Ty:$rc, (Ty MASK        ))), (i32 LEFT_SHIFT)))
                              )),
                              (DEPOSIT GR:$rb, GR:$rc, LEFT_SHIFT, MASK_SIZE)>;

                    // swapped OR, mask before shift
                    def : Pat<(Ty (or (Ty (shl (Ty (and Ty:$rc, (Ty MASK        ))), (i32 LEFT_SHIFT))),
                                               (Ty (and Ty:$rb, (Ty MASK_INVRTED)))
                              )),
                              (DEPOSIT GR:$rb, GR:$rc, LEFT_SHIFT, MASK_SIZE)>;
                }

                let AddedComplexity = Complexity_DepositZero.value in {
                    // clearing bits (x & 0xFFF000FF) as inserting part from GZ
                    def : Pat<(Ty (and          Ty:$rb,                     (Ty MASK_INVRTED))), (DEPOSIT GR:$rb, (Ty gz), LEFT_SHIFT, MASK_SIZE)>;

                    // clearing bits ((x << 8) & 0x000FFF00) as inserting part into GZ
                    def : Pat<(Ty (and (Ty (shl Ty:$rc, (i32 LEFT_SHIFT))), (Ty MASK_SHIFTED))), (DEPOSIT (Ty gz), GR:$rc, LEFT_SHIFT, MASK_SIZE)>;
                }
            }
        }
    }
}

defm : DepositDef<i32, 32, 0xFFFFFFFF>;
defm : DepositDef<i64, 64, 0xFFFFFFFFFFFFFFFF>;

//===----------------------------------------------------------------------===//
// shift-left + op
//===----------------------------------------------------------------------===//
defm SL_ADD_I64  : SHIFT_R3I<opcode_sl_add_i64>;
defm SL_ADD_I32  : SHIFT_R3I<opcode_sl_add_i32>;
defm SL_ADD_U32  : SHIFT_R3I<opcode_sl_add_u32>;
defm SL_SUB_I64  : SHIFT_R3I<opcode_sl_sub_i64>;
defm SL_SUB_I32  : SHIFT_R3I<opcode_sl_sub_i32>;
defm SL_SUB_U32  : SHIFT_R3I<opcode_sl_sub_u32>;
defm SL_SUBR_I64 : SHIFT_R3I<opcode_sl_subr_i64>;
defm SL_SUBR_I32 : SHIFT_R3I<opcode_sl_subr_i32>;
defm SL_SUBR_U32 : SHIFT_R3I<opcode_sl_subr_u32>;
defm SL_OR       : SHIFT_R3I<opcode_sl_or>;
defm SL_XOR      : SHIFT_R3I<opcode_sl_xor>;

multiclass SHIFT_LEFTL_FUNC<PatFrag Op, ValueType Ty, InstBase Insn>
{
  def : Pat<(Ty (Op Ty:$rb, (shl Ty:$rc, uimm7:$imm))), (Insn GR:$rb, GR:$rc, uimm7:$imm)>;
}

defm : SHIFT_LEFTL_FUNC<pr_add,  i64, SL_ADD_I64>;
defm : SHIFT_LEFTL_FUNC<pr_add,  i32, SL_ADD_I32>;
defm : SHIFT_LEFTL_FUNC<pr_add,  i32, SL_ADD_U32>;
defm : SHIFT_LEFTL_FUNC<pr_sub,  i64, SL_SUB_I64>;
defm : SHIFT_LEFTL_FUNC<pr_sub,  i32, SL_SUB_I32>;
defm : SHIFT_LEFTL_FUNC<pr_sub,  i32, SL_SUB_U32>;
defm : SHIFT_LEFTL_FUNC<pr_subr, i64, SL_SUBR_I64>;
defm : SHIFT_LEFTL_FUNC<pr_subr, i32, SL_SUBR_I32>;
defm : SHIFT_LEFTL_FUNC<pr_subr, i32, SL_SUBR_U32>;
defm : SHIFT_LEFTL_FUNC<pr_or,   i32, SL_OR>;
defm : SHIFT_LEFTL_FUNC<pr_or,   i64, SL_OR>;
defm : SHIFT_LEFTL_FUNC<pr_xor,  i32, SL_XOR>;
defm : SHIFT_LEFTL_FUNC<pr_xor,  i64, SL_XOR>;

multiclass SHIFT_LEFTL_FUNC_ZEXT<PatFrag Op, ValueType Tdst, ValueType Tsrc, InstBase Insn>
{
  def : Pat<(Tdst (zext (Tsrc (Op Tsrc:$rb, (shl Tsrc:$rc, uimm7:$imm))))), (Insn GR:$rb, GR:$rc, uimm7:$imm)>;
}

multiclass SHIFT_LEFTL_FUNC_SEXT<PatFrag Op, ValueType Tdst, ValueType Tsrc, InstBase Insn>
{
  def : Pat<(Tdst (sext (Tsrc (Op Tsrc:$rb, (shl Tsrc:$rc, uimm7:$imm))))), (Insn GR:$rb, GR:$rc, uimm7:$imm)>;
}

// 32-bit SL_ADD|SL_SUB|SL_SUBR instructions are free sext/zext to 64|128-bit
foreach Ty = [i64, i128] in {
  defm : SHIFT_LEFTL_FUNC_ZEXT<pr_add,  Ty, i32, SL_ADD_U32>;
  defm : SHIFT_LEFTL_FUNC_ZEXT<pr_sub,  Ty, i32, SL_SUB_U32>;
  defm : SHIFT_LEFTL_FUNC_ZEXT<pr_subr, Ty, i32, SL_SUBR_U32>;

  defm : SHIFT_LEFTL_FUNC_SEXT<pr_add,  Ty, i32, SL_ADD_I32>;
  defm : SHIFT_LEFTL_FUNC_SEXT<pr_sub,  Ty, i32, SL_SUB_I32>;
  defm : SHIFT_LEFTL_FUNC_SEXT<pr_subr, Ty, i32, SL_SUBR_I32>;
}

// 64-bit SL_ADD|SL_SUB|SL_SUBR instructions are free sext/zext to 128-bit
foreach Ty = [i128] in {
  defm : SHIFT_LEFTL_FUNC_SEXT<pr_add,  Ty, i64, SL_ADD_I64>;
  defm : SHIFT_LEFTL_FUNC_SEXT<pr_sub,  Ty, i32, SL_SUB_I64>;
  defm : SHIFT_LEFTL_FUNC_SEXT<pr_subr, Ty, i32, SL_SUBR_I64>;
}