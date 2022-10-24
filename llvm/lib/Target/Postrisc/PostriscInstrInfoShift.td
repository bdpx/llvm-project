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

defm SEXTB : MISC_extend<opcode_sextb>;
defm SEXTH : MISC_extend<opcode_sexth>;
defm SEXTW : MISC_extend<opcode_sextw>;
defm SEXTD : MISC_extend<opcode_sextd>;

defm ZEXTB : MISC_extend<opcode_zextb>;
defm ZEXTH : MISC_extend<opcode_zexth>;
defm ZEXTW : MISC_extend<opcode_zextw>;
defm ZEXTD : MISC_extend<opcode_zextd>;

// sext to bigger type
def : Pat<(i64  (sext i32:$val)), (SEXTW $val)>;
def : Pat<(i128 (sext i32:$val)), (SEXTW $val)>;
def : Pat<(i128 (sext i64:$val)), (SEXTD $val)>;

// sext in-reg to same type
def : Pat<(i32  (sext_inreg i32:$val,  i8 )), (SEXTB $val)>;
def : Pat<(i32  (sext_inreg i32:$val,  i16)), (SEXTH $val)>;
def : Pat<(i64  (sext_inreg i64:$val,  i8 )), (SEXTB $val)>;
def : Pat<(i64  (sext_inreg i64:$val,  i16)), (SEXTH $val)>;
def : Pat<(i64  (sext_inreg i64:$val,  i32)), (SEXTW $val)>;
def : Pat<(i128 (sext_inreg i128:$val, i8 )), (SEXTB $val)>;
def : Pat<(i128 (sext_inreg i128:$val, i16)), (SEXTH $val)>;
def : Pat<(i128 (sext_inreg i128:$val, i32)), (SEXTW $val)>;
def : Pat<(i128 (sext_inreg i128:$val, i64)), (SEXTD $val)>;

// sext in-reg to bigger type
def : Pat<(i64  (sext (sext_inreg i32:$val,  i8 ))), (SEXTB $val)>;
def : Pat<(i64  (sext (sext_inreg i32:$val,  i16))), (SEXTH $val)>;
def : Pat<(i128 (sext (sext_inreg i32:$val,  i8 ))), (SEXTB $val)>;
def : Pat<(i128 (sext (sext_inreg i32:$val,  i16))), (SEXTH $val)>;
def : Pat<(i128 (sext (sext_inreg i64:$val,  i8 ))), (SEXTB $val)>;
def : Pat<(i128 (sext (sext_inreg i64:$val,  i16))), (SEXTH $val)>;
def : Pat<(i128 (sext (sext_inreg i64:$val,  i32))), (SEXTW $val)>;

// zext to bigger type
let AddedComplexity = Complexity_Zext.value in {
  def : Pat<(i64  (zext i32:$val)), (ZEXTW $val)>;
  def : Pat<(i128 (zext i32:$val)), (ZEXTW $val)>;
  def : Pat<(i128 (zext i64:$val)), (ZEXTD $val)>;

  // special ANDs with same type
  def : Pat<(i32  (and i32 :$val, 0xff              )), (ZEXTB $val)>;
  def : Pat<(i32  (and i32 :$val, 0xffff            )), (ZEXTH $val)>;
  def : Pat<(i64  (and i64 :$val, 0xff              )), (ZEXTB $val)>;
  def : Pat<(i64  (and i64 :$val, 0xffff            )), (ZEXTH $val)>;
  def : Pat<(i64  (and i64 :$val, 0xffffffff        )), (ZEXTW $val)>;
  def : Pat<(i128 (and i128:$val, 0xff              )), (ZEXTB $val)>;
  def : Pat<(i128 (and i128:$val, 0xffff            )), (ZEXTH $val)>;
  def : Pat<(i128 (and i128:$val, 0xffffffff        )), (ZEXTW $val)>;
  def : Pat<(i128 (and i128:$val, 0xffffffffffffffff)), (ZEXTD $val)>;

  // special ANDs and zext to bigger type
  def : Pat<(i64  (zext (and i32:$val, 0xff      ))), (ZEXTB $val)>;
  def : Pat<(i64  (zext (and i32:$val, 0xffff    ))), (ZEXTH $val)>;
  def : Pat<(i128 (zext (and i32:$val, 0xff      ))), (ZEXTB $val)>;
  def : Pat<(i128 (zext (and i32:$val, 0xffff    ))), (ZEXTH $val)>;
  def : Pat<(i128 (zext (and i64:$val, 0xff      ))), (ZEXTB $val)>;
  def : Pat<(i128 (zext (and i64:$val, 0xffff    ))), (ZEXTH $val)>;
  def : Pat<(i128 (zext (and i64:$val, 0xffffffff))), (ZEXTW $val)>;
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

defm SLLW : MC_SHIFT_S32<opcode_sllw, pr_shl, i32>;
defm SRLW : MC_SHIFT_S32<opcode_srlw, pr_srl, i32>;
defm SRAW : MC_SHIFT_S32<opcode_sraw, pr_sra, i32>;

defm SLLD : MC_SHIFT_S32<opcode_slld, pr_shl, i64>;
defm SRLD : MC_SHIFT_S32<opcode_srld, pr_srl, i64>;
defm SRAD : MC_SHIFT_S32<opcode_srad, pr_sra, i64>;

defm SLLQ : MC_SHIFT_S32<opcode_sllq, pr_shl, i128>;
defm SRLQ : MC_SHIFT_S32<opcode_srlq, pr_srl, i128>;
defm SRAQ : MC_SHIFT_S32<opcode_sraq, pr_sra, i128>;

class pr_divp2<ValueType Ty> : PatFrag<(ops node:$src1, node:$src2), (sdiv node:$src1, (shl (Ty 1), node:$src2))>;

defm DIVP2W : MC_SHIFT_S32<opcode_divp2w, pr_divp2<i32>,  i32>;
defm DIVP2D : MC_SHIFT_S32<opcode_divp2d, pr_divp2<i64>,  i64>;
defm DIVP2Q : MC_SHIFT_S32<opcode_divp2q, pr_divp2<i128>, i128>;

// signx rd -> sra rd, %g0, rd
def : InstAlias<"signx $ra", (SRAW GR:$ra, GR:$ra, gz), 0>;
// signx reg, rd -> sra reg, %g0, rd
def : InstAlias<"signx $ra, $rb", (SRAW GR:$ra, GR:$rb, gz), 0>;

// shift amount may be also i64
def : Pat<(i64 (shl i64:$rb, i64:$rc)), (SLLD GR:$rb, GR:$rc)>;
def : Pat<(i64 (sra i64:$rb, i64:$rc)), (SRAD GR:$rb, GR:$rc)>;
def : Pat<(i64 (srl i64:$rb, i64:$rc)), (SRLD GR:$rb, GR:$rc)>;

def : Pat<(i32  (pr_divp2<i32>   i32:$rb, i64:$rc)), (DIVP2W GR:$rb, GR:$rc)>;
def : Pat<(i64  (pr_divp2<i64>   i64:$rb, i64:$rc)), (DIVP2D GR:$rb, GR:$rc)>;
def : Pat<(i128 (pr_divp2<i128> i128:$rb, i64:$rc)), (DIVP2Q GR:$rb, GR:$rc)>;


//===----------------------------------------------------------------------===//
//
// Shift-immediate Instructions
//
//===----------------------------------------------------------------------===//

defm SLLIW : MC_SHIFT_IMM<opcode_slliw>;
defm SRLIW : MC_SHIFT_IMM<opcode_srliw>;
defm SRAIW : MC_SHIFT_IMM<opcode_sraiw>;

def : Pat<(i32 (shl i32:$rb, uimm7:$shcnt)), (SLLIW GR:$rb, uimm7:$shcnt)>;
def : Pat<(i32 (srl i32:$rb, uimm7:$shcnt)), (SRLIW GR:$rb, uimm7:$shcnt)>;
def : Pat<(i32 (sra i32:$rb, uimm7:$shcnt)), (SRAIW GR:$rb, uimm7:$shcnt)>;

defm SLLID : MC_SHIFT_IMM<opcode_sllid>;
defm SRLID : MC_SHIFT_IMM<opcode_srlid>;
defm SRAID : MC_SHIFT_IMM<opcode_sraid>;

def : Pat<(i64 (shl i64:$rb, uimm7:$shcnt)), (SLLID GR:$rb, uimm7:$shcnt)>;
def : Pat<(i64 (srl i64:$rb, uimm7:$shcnt)), (SRLID GR:$rb, uimm7:$shcnt)>;
def : Pat<(i64 (sra i64:$rb, uimm7:$shcnt)), (SRAID GR:$rb, uimm7:$shcnt)>;

defm SLLIQ : MC_SHIFT_IMM<opcode_slliq>;
defm SRLIQ : MC_SHIFT_IMM<opcode_srliq>;
defm SRAIQ : MC_SHIFT_IMM<opcode_sraiq>;

def : Pat<(i128 (shl i128:$rb, uimm7:$shcnt)), (SLLIQ GR:$rb, uimm7:$shcnt)>;
def : Pat<(i128 (srl i128:$rb, uimm7:$shcnt)), (SRLIQ GR:$rb, uimm7:$shcnt)>;
def : Pat<(i128 (sra i128:$rb, uimm7:$shcnt)), (SRAIQ GR:$rb, uimm7:$shcnt)>;

defm DIVP2IW : MC_SHIFT_IMM<opcode_divp2iw>;
defm DIVP2ID : MC_SHIFT_IMM<opcode_divp2id>;
defm DIVP2IQ : MC_SHIFT_IMM<opcode_divp2iq>;

def : Pat<(i32  (pr_divp2<i32>  i32 :$rb, uimm7:$shcnt)), (DIVP2IW GR:$rb, uimm7:$shcnt)>;
def : Pat<(i64  (pr_divp2<i64>  i64 :$rb, uimm7:$shcnt)), (DIVP2ID GR:$rb, uimm7:$shcnt)>;
def : Pat<(i128 (pr_divp2<i128> i128:$rb, uimm7:$shcnt)), (DIVP2IQ GR:$rb, uimm7:$shcnt)>;

let AddedComplexity = Complexity_DivP2.value in {
  def : Pat<(sdiv i32 :$a, (i32  imm_pow2:$imm)), (DIVP2IW GR:$a, (imm_pow2_xform imm:$imm))>;
  def : Pat<(sdiv i64 :$a, (i64  imm_pow2:$imm)), (DIVP2ID GR:$a, (imm_pow2_xform imm:$imm))>;
  def : Pat<(sdiv i128:$a, (i128 imm_pow2:$imm)), (DIVP2IQ GR:$a, (imm_pow2_xform imm:$imm))>;
}

// logical shifts are zero extension into bigger types
def : Pat<(i64  (zext (shl i32:$rb, uimm7:$shamt))), (SLLIW GR:$rb, uimm7:$shamt)>;
def : Pat<(i128 (zext (shl i32:$rb, uimm7:$shamt))), (SLLIW GR:$rb, uimm7:$shamt)>;
def : Pat<(i64  (zext (srl i32:$rb, uimm7:$shamt))), (SRLIW GR:$rb, uimm7:$shamt)>;
def : Pat<(i128 (zext (srl i32:$rb, uimm7:$shamt))), (SRLIW GR:$rb, uimm7:$shamt)>;
def : Pat<(i128 (zext (shl i64:$rb, uimm7:$shamt))), (SLLID GR:$rb, uimm7:$shamt)>;
def : Pat<(i128 (zext (srl i64:$rb, uimm7:$shamt))), (SRLID GR:$rb, uimm7:$shamt)>;

// algebraic shifts are sign extension into bigger types
def : Pat<(i64  (sext (sra i32:$rb, uimm7:$shamt))), (SRAIW GR:$rb, uimm7:$shamt)>;
def : Pat<(i128 (sext (sra i32:$rb, uimm7:$shamt))), (SRAIW GR:$rb, uimm7:$shamt)>;
def : Pat<(i128 (sext (sra i64:$rb, uimm7:$shamt))), (SRAID GR:$rb, uimm7:$shamt)>;

//===----------------------------------------------------------------------===//
// funnel shifts
// fshl(X,Y,Z): (X << (Z % BW)) | (Y >> (BW - (Z % BW)))
// fshr(X,Y,Z): (X << (BW - (Z % BW))) | (Y >> (Z % BW))
//===----------------------------------------------------------------------===//
defm SLPW : FORMAT_R4<opcode_slpw>;
defm SRPW : FORMAT_R4<opcode_srpw>;
defm SLPD : FORMAT_R4<opcode_slpd>;
defm SRPD : FORMAT_R4<opcode_srpd>;
defm SLPQ : FORMAT_R4<opcode_slpq>;
defm SRPQ : FORMAT_R4<opcode_srpq>;

multiclass SHIFT_R3I<fused_opx opx, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : FUSED_Rabcd<opx,
          (outs GR:$ra), (ins GR:$rb, GR:$rc, uimm7:$rd),
          !strconcat(opx.mnem, " $ra, $rb, $rc, $rd"),
          [], itin>;
}

defm SRPIW : SHIFT_R3I<opcode_srpiw>;
defm SRPID : SHIFT_R3I<opcode_srpid>;
defm SRPIQ : SHIFT_R3I<opcode_srpiq>;

multiclass OP_FUNNEL_SHIFT<InstBase SLP, InstBase SRP, InstBase SRPI, ValueType Ty, int mask, SDNodeXForm CastLeftShiftToRight>
{
  foreach Ts = [ i32, i64 ] in {
    def : Pat<(fshl Ty:$rb, Ty:$rc, Ts:$rd), (SLP GR:$rb, GR:$rc, GR:$rd)>;
    def : Pat<(fshr Ty:$rb, Ty:$rc, Ts:$rd), (SRP GR:$rb, GR:$rc, GR:$rd)>;

    // Double "funnel" shift amount is implicitly masked.
    // (fshl/fshr x (and y, 63)) ==> (fshl/fshr x, y)
    def : Pat<(fshr Ty:$rb, Ty:$rc, (and Ts:$rd, mask)), (SRP GR:$rb, GR:$rc, GR:$rd)>;
    def : Pat<(fshl Ty:$rb, Ty:$rc, (and Ts:$rd, mask)), (SLP GR:$rb, GR:$rc, GR:$rd)>;
  }

  def : Pat<(fshr Ty:$rb, Ty:$rc, uimm7:$rd), (SRPI GR:$rb, GR:$rc, uimm7:$rd)>;
  def : Pat<(fshl Ty:$rb, Ty:$rc, uimm7:$rd), (SRPI GR:$rb, GR:$rc, (CastLeftShiftToRight $rd))>;
}

defm : OP_FUNNEL_SHIFT<SLPW, SRPW, SRPIW, i32,  31,  CastLeftShiftToRight_32>;
defm : OP_FUNNEL_SHIFT<SLPD, SRPD, SRPID, i64,  63,  CastLeftShiftToRight_64>;
defm : OP_FUNNEL_SHIFT<SLPQ, SRPQ, SRPIQ, i128, 127, CastLeftShiftToRight_128>;

// model left funnel shifts by immediate via right funnel shifts
multiclass OP_FUNNEL_SHIFT_IMM<InstBase SRPI, ValueType Ty, ValueType Ts, int NBITS, int LEFT_SHIFT>
{
  def : Pat<(fshr Ty:$rb, Ty:$rc, (Ts LEFT_SHIFT)), (SRPI GR:$rb, GR:$rc, LEFT_SHIFT)>;
  def : Pat<(fshl Ty:$rb, Ty:$rc, (Ts LEFT_SHIFT)), (SRPI GR:$rb, GR:$rc, NBITS)>;

  def : Pat<(or (srl Ty:$rb, (Ts NBITS)), (shl Ty:$rc, (Ts LEFT_SHIFT))), (SRPI GR:$rb, GR:$rc, NBITS)>;
  def : Pat<(or (shl Ty:$rc, (Ts LEFT_SHIFT)), (srl Ty:$rb, (Ts NBITS))), (SRPI GR:$rb, GR:$rc, NBITS)>;

  def : Pat<(rotr Ty:$rb, (Ts NBITS     )), (SRPI GR:$rb, GR:$rb, NBITS)>;
  def : Pat<(rotl Ty:$rb, (Ts LEFT_SHIFT)), (SRPI GR:$rb, GR:$rb, NBITS)>;
}

foreach Ts = [ i32, i64 ] in {
  foreach NBITS = {1 ... 31} in {
    defm : OP_FUNNEL_SHIFT_IMM<SRPIW, i32, Ts, NBITS, !sub(32, NBITS)>;
  }
  foreach NBITS = {1 ... 63} in {
    defm : OP_FUNNEL_SHIFT_IMM<SRPID, i64, Ts, NBITS, !sub(64, NBITS)>;
  }
  foreach NBITS = {1 ... 127} in {
    defm : OP_FUNNEL_SHIFT_IMM<SRPIQ, i128, Ts, NBITS, !sub(128, NBITS)>;
  }
}

//===----------------------------------------------------------------------===//
// double shift (extract bitfield)
//===----------------------------------------------------------------------===//
def pr_slsrl : PatFrag<(ops node:$src1, node:$src2, node:$src3), (srl (shl node:$src1, node:$src2), node:$src3)>;
def pr_slsra : PatFrag<(ops node:$src1, node:$src2, node:$src3), (sra (shl node:$src1, node:$src2), node:$src3)>;

defm SLSRLD : FUSED_R4<opcode_slsrld, pr_slsrl, i64, i64, i32, i32>;
defm SLSRAD : FUSED_R4<opcode_slsrad, pr_slsra, i64, i64, i32, i32>;
defm SLSRLW : FUSED_R4<opcode_slsrlw, pr_slsrl, i32, i32, i32, i32>;
defm SLSRAW : FUSED_R4<opcode_slsraw, pr_slsra, i32, i32, i32, i32>;

defm SLSRLID : FUSED_R4rrii<opcode_slsrlid, pr_slsrl, i64>;
defm SLSRAID : FUSED_R4rrii<opcode_slsraid, pr_slsra, i64>;

// (x >> offset) & mask<nbits> => (x << (64 - offset - nbits)) >> (64 - nbits)
// both srl/sra is identical because zero/sign extension will be masked

foreach NBITS = {1 ... 63} in {
    defvar MASK = !sub(!shl(1, NBITS), 1); // NBITS ones
    foreach OFFSET = {1 ... 63} in {
        defvar COMBINED = !add(NBITS, OFFSET);
        if !lt(COMBINED, 64) then {
            defvar LEFT_SHIFT  = !sub(64, COMBINED);
            defvar RIGHT_SHIFT = !add(LEFT_SHIFT, OFFSET);
            def : Pat<(and (srl i64:$rb, (i32 OFFSET)), MASK), (SLSRLID GR:$rb, LEFT_SHIFT, RIGHT_SHIFT)>;
            def : Pat<(and (sra i64:$rb, (i32 OFFSET)), MASK), (SLSRLID GR:$rb, LEFT_SHIFT, RIGHT_SHIFT)>;
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
            def : Pat<(and (srl i32:$rb, (i32 OFFSET)), MASK), (SLSRLID GR:$rb, LEFT_SHIFT, RIGHT_SHIFT)>;
            def : Pat<(and (sra i32:$rb, (i32 OFFSET)), MASK), (SLSRLID GR:$rb, LEFT_SHIFT, RIGHT_SHIFT)>;

            def : Pat<(i64 (zext (and (srl i32:$rb, (i32 OFFSET)), (i32 MASK)))), (SLSRLID GR:$rb, LEFT_SHIFT, RIGHT_SHIFT)>;
            def : Pat<(and (i64 (zext (sra i32:$rb, (i32 OFFSET)))), (i64 MASK)), (SLSRLID GR:$rb, LEFT_SHIFT, RIGHT_SHIFT)>;

            def : Pat<(and (i64 (anyext (srl i32:$rb, (i32 OFFSET)))), (i64 MASK)), (SLSRLID GR:$rb, LEFT_SHIFT, RIGHT_SHIFT)>;
            def : Pat<(and (i64 (anyext (sra i32:$rb, (i32 OFFSET)))), (i64 MASK)), (SLSRAID GR:$rb, LEFT_SHIFT, RIGHT_SHIFT)>;

            def : Pat<(i32 (and (srl i32:$rb, (i32 OFFSET)), MASK)), (SLSRLID GR:$rb, LEFT_SHIFT, RIGHT_SHIFT)>;
            def : Pat<(i32 (and (sra i32:$rb, (i32 OFFSET)), MASK)), (SLSRLID GR:$rb, LEFT_SHIFT, RIGHT_SHIFT)>;
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
defm SLADDD   : SHIFT_R3I<opcode_sladdd>;
defm SLADDWS  : SHIFT_R3I<opcode_sladdws>;
defm SLADDWZ  : SHIFT_R3I<opcode_sladdwz>;
defm SLSUBD   : SHIFT_R3I<opcode_slsubd>;
defm SLSUBWS  : SHIFT_R3I<opcode_slsubws>;
defm SLSUBWZ  : SHIFT_R3I<opcode_slsubwz>;
defm SLSUBRD  : SHIFT_R3I<opcode_slsubrd>;
defm SLSUBRWS : SHIFT_R3I<opcode_slsubrws>;
defm SLSUBRWZ : SHIFT_R3I<opcode_slsubrwz>;
defm SLOR     : SHIFT_R3I<opcode_slor>;
defm SLXOR    : SHIFT_R3I<opcode_slxor>;

multiclass ShiftLeftAndOp<PatFrag Op, ValueType Ty, InstBase Insn>
{
  def : Pat<(Ty (Op Ty:$rb, (shl Ty:$rc, uimm7:$imm))), (Insn GR:$rb, GR:$rc, uimm7:$imm)>;
}

defm : ShiftLeftAndOp<pr_add,  i64, SLADDD>;
defm : ShiftLeftAndOp<pr_add,  i32, SLADDWS>;
defm : ShiftLeftAndOp<pr_add,  i32, SLADDWZ>;
defm : ShiftLeftAndOp<pr_sub,  i64, SLSUBD>;
defm : ShiftLeftAndOp<pr_sub,  i32, SLSUBWS>;
defm : ShiftLeftAndOp<pr_sub,  i32, SLSUBWZ>;
defm : ShiftLeftAndOp<pr_subr, i64, SLSUBRD>;
defm : ShiftLeftAndOp<pr_subr, i32, SLSUBRWS>;
defm : ShiftLeftAndOp<pr_subr, i32, SLSUBRWZ>;
defm : ShiftLeftAndOp<pr_or,   i32, SLOR>;
defm : ShiftLeftAndOp<pr_or,   i64, SLOR>;
defm : ShiftLeftAndOp<pr_xor,  i32, SLXOR>;
defm : ShiftLeftAndOp<pr_xor,  i64, SLXOR>;

multiclass SHIFT_LEFT_FUNC_ZEXT<PatFrag Op, ValueType Tdst, ValueType Tsrc, InstBase Insn>
{
  def : Pat<(Tdst (zext (Tsrc (Op Tsrc:$rb, (shl Tsrc:$rc, uimm7:$imm))))), (Insn GR:$rb, GR:$rc, uimm7:$imm)>;
}

multiclass SHIFT_LEFT_FUNC_SEXT<PatFrag Op, ValueType Tdst, ValueType Tsrc, InstBase Insn>
{
  def : Pat<(Tdst (sext (Tsrc (Op Tsrc:$rb, (shl Tsrc:$rc, uimm7:$imm))))), (Insn GR:$rb, GR:$rc, uimm7:$imm)>;
}

// 32-bit SL_ADD|SL_SUB|SL_SUBR instructions are free sext/zext to 64|128-bit
foreach Ty = [i64, i128] in {
  defm : SHIFT_LEFT_FUNC_ZEXT<pr_add,  Ty, i32, SLADDWZ>;
  defm : SHIFT_LEFT_FUNC_ZEXT<pr_sub,  Ty, i32, SLSUBWZ>;
  defm : SHIFT_LEFT_FUNC_ZEXT<pr_subr, Ty, i32, SLSUBRWZ>;

  defm : SHIFT_LEFT_FUNC_SEXT<pr_add,  Ty, i32, SLADDWS>;
  defm : SHIFT_LEFT_FUNC_SEXT<pr_sub,  Ty, i32, SLSUBWS>;
  defm : SHIFT_LEFT_FUNC_SEXT<pr_subr, Ty, i32, SLSUBRWS>;
}

// 64-bit SL_ADD|SL_SUB|SL_SUBR instructions are free sext/zext to 128-bit
foreach Ty = [i128] in {
  defm : SHIFT_LEFT_FUNC_SEXT<pr_add,  Ty, i64, SLADDD>;
  defm : SHIFT_LEFT_FUNC_SEXT<pr_sub,  Ty, i32, SLSUBD>;
  defm : SHIFT_LEFT_FUNC_SEXT<pr_subr, Ty, i32, SLSUBRD>;
}
