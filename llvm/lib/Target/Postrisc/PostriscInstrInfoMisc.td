//===----- PostriscInstrInfoMisc.td - Target Description for Postrisc -----===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
//===----------------------------------------------------------------------===//

def MOV2 : FUSED_Rabcd<fused_opx_mov2,
        (outs GR:$ra, GR:$rb), (ins GR:$rc, GR:$rd),
        !strconcat(fused_opx_mov2.mnem, "\t$ra, $rb, $rc, $rd"), []>;

//===----------------------------------------------------------------------===//
// ALIGNED_UP(N, NBITS) = (N + (2^NBITS-1)) & (~(2^NBITS-1))
//===----------------------------------------------------------------------===//
def pr_algnup : PatFrag<(ops node:$src1, node:$nbits),
  (and (add node:$src1, (sub (shl 1, node:$nbits), 1)), (sub 0, (shl 1, node:$nbits)))>;

def ALGNUP : FUSED_Rabcd<fused_opx_algnup, (outs GR:$ra), (ins GR:$rb, uimm6:$rc, uimm6:$rd),
         !strconcat(fused_opx_algnup.mnem, "\t$ra, $rb, $rc, $rd"),
         [(set i64:$ra, (pr_algnup (shl i64:$rb, uimm6:$rc), uimm6:$rd))], IIC_iu_instr>;

// it's ugly but works
foreach III = 0-63 in {
  defvar BIT = !shl(1,III);
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
  def NAME : MISC_RabSc<opx, (outs GR:$ra), (ins GR:$rb, uimm6:$shcnt), !strconcat(opx.mnem, "\t$ra, $rb, $shcnt"), []>;
}

defm POPC : POPULATION<misc_opx_cnt_pop>;
defm CTTZ : POPULATION<misc_opx_cnt_tz>;
defm CTLZ : POPULATION<misc_opx_cnt_lz>;
defm PERM : POPULATION<misc_opx_permb>;

def : Pat<(i32 (ctpop i32:$src)), (POPC $src, 31)>;
def : Pat<(i64 (ctpop i64:$src)), (POPC $src, 63)>;
def : Pat<(i32 (cttz i32:$src)), (CTTZ $src, 31)>;
def : Pat<(i64 (cttz i64:$src)), (CTTZ $src, 63)>;
def : Pat<(i32 (ctlz i32:$src)), (CTLZ $src, 31)>;
def : Pat<(i64 (ctlz i64:$src)), (CTLZ $src, 63)>;

def : Pat<(i32 (bitreverse i32:$src)), (PERM $src, 31)>;
def : Pat<(i64 (bitreverse i64:$src)), (PERM $src, 63)>;

//===----------------------------------------------------------------------===//
// booleans
//===----------------------------------------------------------------------===//
multiclass BooleanIntPat<ValueType Ty> {
  // trunc to i1 modeled as 0-bit
  def : Pat<(i1 (trunc Ty:$val)), (ANDI Ty:$val, 1)>;

  // i1 should be always 0/1, zero extending to wider types is trivial remarking
  def : Pat<(Ty (  zext i1:$val)), (Ty (COPY i1:$val))>;
  def : Pat<(Ty (anyext i1:$val)), (Ty (COPY i1:$val))>;
  def : Pat<(Ty (  sext i1:$val)), (SLSRAI  $val, 63, 63)>;
}
defm : BooleanIntPat<i32>;
defm : BooleanIntPat<i64>;
defm : BooleanIntPat<i128>;

// i1 is signed (0 or -1)
def : Pat<(i1 -1), (LDI 1)>;
def : Pat<(i1  0), (LDI 0)>;

// i1 sign extension is double shift
def : Pat<(i32 (sext_inreg i32:$val, i1)), (SLSRAI i32:$val, 63, 63)>;
def : Pat<(i64 (sext_inreg i64:$val, i1)), (SLSRAI i64:$val, 63, 63)>;

// FIXME: unused?
//def : Pat<(i1 (seteq i1:$rb, i1:$rc)), (CMPWEQ   GR:$rb, GR:$rc)>;
//def : Pat<(i1 (setne i1:$rb, i1:$rc)), (CMPWNE   GR:$rb, GR:$rc)>;
//def : Pat<(i1 (seteq i1:$rb, (i1 0))), (CMPWEQI  GR:$rb, 0)>;
//def : Pat<(i1 (seteq i1:$rb, (i1 -1))), (CMPWEQI GR:$rb, 1)>;
//def : Pat<(i1 (setne i1:$rb, (i1 0))), (CMPWNEI  GR:$rb, 0)>;
//def : Pat<(i1 (setne i1:$rb, (i1 -1))), (CMPWNEI GR:$rb, 1)>;

def : Pat<(i1 (not i1:$src)), (XORI GR:$src, 1)>;

// TODO: (a cmp b)
// ((xor a, b) xor -1)
// ((xor a, -1) and b)
// ((xor a, -1) or b)
