//===--- PostriscInstrInfoCondMove.td - Target Description for Postrisc ---===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains instruction formats, definitions and patterns needed for
// CMOVExxx instructions on POSTRISC.
// conditional moves: Ra = (Rb op 0) ? Rc : Rd
//
//===----------------------------------------------------------------------===//

def CMOVLSB : FUSED_Rabcd<fused_opx_cmovlsb, (outs GR:$ra), (ins GR:$rb, GR:$rc, GR:$rd), "cmovlsb\t$ra, $rb, $rc, $rd", []>;
def CMOVWEQ : FUSED_Rabcd<fused_opx_cmovweq, (outs GR:$ra), (ins GR:$rb, GR:$rc, GR:$rd), "cmovweq\t$ra, $rb, $rc, $rd", []>;
def CMOVWLT : FUSED_Rabcd<fused_opx_cmovwlt, (outs GR:$ra), (ins GR:$rb, GR:$rc, GR:$rd), "cmovwlt\t$ra, $rb, $rc, $rd", []>;
def CMOVWLE : FUSED_Rabcd<fused_opx_cmovwle, (outs GR:$ra), (ins GR:$rb, GR:$rc, GR:$rd), "cmovwle\t$ra, $rb, $rc, $rd", []>;
def CMOVDEQ : FUSED_Rabcd<fused_opx_cmovdeq, (outs GR:$ra), (ins GR:$rb, GR:$rc, GR:$rd), "cmovdeq\t$ra, $rb, $rc, $rd", []>;
def CMOVDLT : FUSED_Rabcd<fused_opx_cmovdlt, (outs GR:$ra), (ins GR:$rb, GR:$rc, GR:$rd), "cmovdlt\t$ra, $rb, $rc, $rd", []>;
def CMOVDLE : FUSED_Rabcd<fused_opx_cmovdle, (outs GR:$ra), (ins GR:$rb, GR:$rc, GR:$rd), "cmovdle\t$ra, $rb, $rc, $rd", []>;

multiclass CondMoveBitwiseAnd<InstBase Inst, ValueType Ty, ValueType Tc>
{
  def : Pat<(Ty (select (i1 (seteq (and Tc:$rb, (Tc 1)), (Tc 1))), Ty:$rd, Ty:$rc)), (Inst GR:$rb, GR:$rc, GR:$rd)>;
  def : Pat<(Ty (select (i1 (setne (and Tc:$rb, (Tc 1)), (Tc 0))), Ty:$rd, Ty:$rc)), (Inst GR:$rb, GR:$rc, GR:$rd)>;
  // swapped
  def : Pat<(Ty (select (i1 (seteq (and Tc:$rb, (Tc 1)), (Tc 0))), Ty:$rc, Ty:$rd)), (Inst GR:$rb, GR:$rc, GR:$rd)>;
  def : Pat<(Ty (select (i1 (setne (and Tc:$rb, (Tc 1)), (Tc 1))), Ty:$rc, Ty:$rd)), (Inst GR:$rb, GR:$rc, GR:$rd)>;
}

// conditional move: select: Ra = Rb ? Rc : Rd
multiclass SelectPat<InstBase Inst, ValueType Ty>
{
  // is true
  def : Pat<(Ty (select i1:$rb, Ty:$rc, Ty:$rd)), (Inst GR:$rb, GR:$rc, GR:$rd)>;
  // equal true
  def : Pat<(Ty (select (i1 (seteq i1:$rb, (i1 -1))), Ty:$rc, Ty:$rd)), (Inst GR:$rb, GR:$rc, GR:$rd)>;
  // equal false (swapped args)
  def : Pat<(Ty (select (i1 (seteq i1:$rb, (i1 0))), Ty:$rd, Ty:$rc)), (Inst GR:$rb, GR:$rc, GR:$rd)>;
  //  (a & 1) ? b : c
  // defm : CondMoveBitwiseAnd<Inst, Ty, i1>;
  defm : CondMoveBitwiseAnd<Inst, Ty, i32>;
  defm : CondMoveBitwiseAnd<Inst, Ty, i64>;
  defm : CondMoveBitwiseAnd<Inst, Ty, i128>;
}

multiclass CondMovePat<InstBase Inst, PatFrag OpNode, int value, ValueType Ty, ValueType Tc>
{
  def : Pat<(Ty (select (i1 (OpNode Tc:$rb, (Tc value))), Ty:$rc, Ty:$rd)), (Inst GR:$rb, GR:$rc, GR:$rd)>;
}

multiclass CondMoveSwappedPat<InstBase Inst, PatFrag OpNode, int value, ValueType Ty, ValueType Tc>
{
  def : Pat<(Ty (select (i1 (OpNode Tc:$rb, (Tc value))), Ty:$rd, Ty:$rc)), (Inst GR:$rb, GR:$rc, GR:$rd)>;
}

multiclass ConditionalMoves<ValueType Ty>
{
  defm : SelectPat<CMOVLSB, Ty>;

  // direct usage
  defm : CondMovePat<CMOVWEQ, seteq, 0, Ty, i32>;
  defm : CondMovePat<CMOVWLT, setlt, 0, Ty, i32>;
  defm : CondMovePat<CMOVWLE, setle, 0, Ty, i32>;
  defm : CondMovePat<CMOVDEQ, seteq, 0, Ty, i64>;
  defm : CondMovePat<CMOVDLT, setlt, 0, Ty, i64>;
  defm : CondMovePat<CMOVDLE, setle, 0, Ty, i64>;

  // (x != value) => inverted(x == value)
  defm : CondMoveSwappedPat<CMOVWEQ, setne, 0, Ty, i32>;
  defm : CondMoveSwappedPat<CMOVWLT, setge, 0, Ty, i32>;
  defm : CondMoveSwappedPat<CMOVWLE, setgt, 0, Ty, i32>;
  defm : CondMoveSwappedPat<CMOVDEQ, setne, 0, Ty, i64>;
  defm : CondMoveSwappedPat<CMOVDLT, setge, 0, Ty, i64>;
  defm : CondMoveSwappedPat<CMOVDLE, setgt, 0, Ty, i64>;

  // (x < 1) => (x <= 0)
  defm : CondMovePat<CMOVWLE, setlt, 1, Ty, i32>;
  defm : CondMovePat<CMOVDLE, setlt, 1, Ty, i64>;

  // (x > -1) => (x >= 0) => inverted(x < 0)
  defm : CondMoveSwappedPat<CMOVWLT, setgt, -1, Ty, i32>;
  defm : CondMoveSwappedPat<CMOVDLT, setgt, -1, Ty, i64>;
}

defm : ConditionalMoves<i1>;
defm : ConditionalMoves<i32>;
defm : ConditionalMoves<i64>;
defm : ConditionalMoves<i128>;
defm : ConditionalMoves<f16>;
defm : ConditionalMoves<f32>;
defm : ConditionalMoves<f64>;
defm : ConditionalMoves<f128>;
defm : ConditionalMoves<v16i8>;
defm : ConditionalMoves<v8i16>;
defm : ConditionalMoves<v4i32>;
defm : ConditionalMoves<v2i64>;
defm : ConditionalMoves<v8f16>;
defm : ConditionalMoves<v4f32>;
defm : ConditionalMoves<v2f64>;
