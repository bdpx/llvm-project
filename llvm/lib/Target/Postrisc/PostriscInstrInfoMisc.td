//===----- PostriscInstrInfoMisc.td - Target Description for Postrisc -----===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
//===----------------------------------------------------------------------===//

def MOV2 : FUSED_Rabcd<opcode_mov2,
        (outs GR:$ra, GR:$rb), (ins GR:$rc, GR:$rd),
        !strconcat(opcode_mov2.mnem, " $ra, $rb, $rc, $rd"), []>;

//===----------------------------------------------------------------------===//
// ALIGNED_UP(N, NBITS) = (N + (2^NBITS-1)) & (~(2^NBITS-1))
//===----------------------------------------------------------------------===//
def pr_alignup : PatFrag<(ops node:$src1, node:$nbits),
  (and (add node:$src1, (sub (shl (i64 1), node:$nbits), 1)), (sub 0, (shl 1, node:$nbits)))>;

def ALGNUP : FUSED_Rabcd<opcode_alignup_u64, (outs GR:$ra), (ins GR:$rb, uimm7:$rc, uimm7:$rd),
         !strconcat(opcode_alignup_u64.mnem, " $ra, $rb, $rc, $rd"),
         [(set i64:$ra, (pr_alignup (shl i64:$rb, uimm7:$rc), uimm7:$rd))], IIC_iu_instr>;

// it's ugly but works
foreach III = 0-63 in {
  defvar BIT = !shl(1, III);
  defvar MASK = !sub(BIT, 1);
  def : Pat<(and (add i64:$rb, MASK), !sub(0, BIT) ), (ALGNUP GR:$rb, 0, III)>;
  foreach KKK = 1-63 in {
    def : Pat<(and (add (shl i64:$rb, (i32 KKK)), MASK), !sub(0, BIT)), (ALGNUP GR:$rb, KKK, III)>;
  }
}

//===----------------------------------------------------------------------===//
// population, trailing/leading zeros bit count
//===----------------------------------------------------------------------===//
multiclass POPULATION<misc_opx opx>
{
  def NAME : MISC_RabSc<opx, (outs GR:$ra), (ins GR:$rb, uimm7:$shcnt),
                        !strconcat(opx.mnem, " $ra, $rb, $shcnt"), []>;
}

defm CNT_POP : POPULATION<opcode_cnt_pop>;
defm CNT_TZ  : POPULATION<opcode_cnt_tz>;
defm CNT_LZ  : POPULATION<opcode_cnt_lz>;
defm PERMB   : POPULATION<opcode_permb>;

def : Pat<(i32 (ctpop i32:$src)), (CNT_POP $src, 31)>;
def : Pat<(i64 (ctpop i64:$src)), (CNT_POP $src, 63)>;
def : Pat<(i32 (cttz i32:$src)), (CNT_TZ $src, 31)>;
def : Pat<(i64 (cttz i64:$src)), (CNT_TZ $src, 63)>;
def : Pat<(i32 (ctlz i32:$src)), (CNT_LZ $src, 31)>;
def : Pat<(i64 (ctlz i64:$src)), (CNT_LZ $src, 63)>;

def : Pat<(i32 (bitreverse i32:$src)), (PERMB $src, 31)>;
def : Pat<(i64 (bitreverse i64:$src)), (PERMB $src, 63)>;

//===----------------------------------------------------------------------===//
// booleans
//===----------------------------------------------------------------------===//
multiclass BooleanIntPat<ValueType Ty> {
  // trunc to i1 modeled as 0-bit
  def : Pat<(i1 (trunc Ty:$val)), (AND_IMM Ty:$val, 1)>;

  // i1 should be always 0/1, zero extending to wider types is trivial remarking
  def : Pat<(Ty (  zext i1:$val)), (Ty (COPY i1:$val))>;
  def : Pat<(Ty (anyext i1:$val)), (Ty (COPY i1:$val))>;
  def : Pat<(Ty (  sext i1:$val)), (SLSRA_IMM_I64  $val, 63, 63)>;
}
defm : BooleanIntPat<i32>;
defm : BooleanIntPat<i64>;
defm : BooleanIntPat<i128>;

// i1 is signed (0 or -1)
def : Pat<(i1 -1), (LD_IMM 1)>;
def : Pat<(i1  0), (LD_IMM 0)>;

// i1 sign extension is double shift
def : Pat<(i32 (sext_inreg i32:$val, i1)), (SLSRA_IMM_I64 i32:$val, 63, 63)>;
def : Pat<(i64 (sext_inreg i64:$val, i1)), (SLSRA_IMM_I64 i64:$val, 63, 63)>;

// FIXME: unused?
//def : Pat<(i1 (seteq i1:$rb, i1:$rc)), (CMP_EQ_I32 GR:$rb, GR:$rc)>;
//def : Pat<(i1 (setne i1:$rb, i1:$rc)), (CMP_NE_I32 GR:$rb, GR:$rc)>;
//def : Pat<(i1 (seteq i1:$rb, (i1  0))), (CMP_EQ_IMM_I32 GR:$rb, 0)>;
//def : Pat<(i1 (seteq i1:$rb, (i1 -1))), (CMP_EQ_IMM_I32 GR:$rb, 1)>;
//def : Pat<(i1 (setne i1:$rb, (i1  0))), (CMP_NE_IMM_I32 GR:$rb, 0)>;
//def : Pat<(i1 (setne i1:$rb, (i1 -1))), (CMP_NE_IMM_I32 GR:$rb, 1)>;

def : Pat<(i1 (not i1:$src)), (XOR_IMM GR:$src, 1)>;

// TODO: (a cmp b)
// ((xor a, b) xor -1)
// ((xor a, -1) and b)
// ((xor a, -1) or b)
