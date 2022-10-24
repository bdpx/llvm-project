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

multiclass COND_MOVE<fused_opx opx>
{
  def NAME : FUSED_Rabcd<opx, (outs GR:$ra), (ins GR:$rb, GR:$rc, GR:$rd), !strconcat(opx.mnem, "\t$ra, $rb, $rc, $rd"), []>;
}

defm CMOV_LSB  : COND_MOVE<fused_opx_cmov_lsb>;
defm CMOV_EQ_W : COND_MOVE<fused_opx_cmov_eq_w>;
defm CMOV_LT_W : COND_MOVE<fused_opx_cmov_lt_w>;
defm CMOV_LE_W : COND_MOVE<fused_opx_cmov_le_w>;
defm CMOV_EQ_D : COND_MOVE<fused_opx_cmov_eq_d>;
defm CMOV_LT_D : COND_MOVE<fused_opx_cmov_lt_d>;
defm CMOV_LE_D : COND_MOVE<fused_opx_cmov_le_d>;

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
  defm : SelectPat<CMOV_LSB, Ty>;

  // direct usage
  defm : CondMovePat<CMOV_EQ_W, seteq, 0, Ty, i32>;
  defm : CondMovePat<CMOV_LT_W, setlt, 0, Ty, i32>;
  defm : CondMovePat<CMOV_LE_W, setle, 0, Ty, i32>;
  defm : CondMovePat<CMOV_EQ_D, seteq, 0, Ty, i64>;
  defm : CondMovePat<CMOV_LT_D, setlt, 0, Ty, i64>;
  defm : CondMovePat<CMOV_LE_D, setle, 0, Ty, i64>;

  // (x != value) => inverted(x == value)
  defm : CondMoveSwappedPat<CMOV_EQ_W, setne, 0, Ty, i32>;
  defm : CondMoveSwappedPat<CMOV_LT_W, setge, 0, Ty, i32>;
  defm : CondMoveSwappedPat<CMOV_LE_W, setgt, 0, Ty, i32>;
  defm : CondMoveSwappedPat<CMOV_EQ_D, setne, 0, Ty, i64>;
  defm : CondMoveSwappedPat<CMOV_LT_D, setge, 0, Ty, i64>;
  defm : CondMoveSwappedPat<CMOV_LE_D, setgt, 0, Ty, i64>;

  // (x < 1) => (x <= 0)
  defm : CondMovePat<CMOV_LE_W, setlt, 1, Ty, i32>;
  defm : CondMovePat<CMOV_LE_D, setlt, 1, Ty, i64>;

  // (x > -1) => (x >= 0) => inverted(x < 0)
  defm : CondMoveSwappedPat<CMOV_LT_W, setgt, -1, Ty, i32>;
  defm : CondMoveSwappedPat<CMOV_LT_D, setgt, -1, Ty, i64>;
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
