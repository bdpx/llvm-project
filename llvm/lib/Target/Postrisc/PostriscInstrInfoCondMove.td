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
  def NAME : FUSED_Rabcd<opx, (outs GR:$ra), (ins GR:$rb, GR:$rc, GR:$rd),
                         !strconcat(opx.mnem, " $ra, $rb, $rc, $rd"), []>;
}

defm CMOVLSB : COND_MOVE<opcode_cmovlsb>;
defm CMOVEQW : COND_MOVE<opcode_cmoveqw>;
defm CMOVLTW : COND_MOVE<opcode_cmovltw>;
defm CMOVLEW : COND_MOVE<opcode_cmovlew>;
defm CMOVEQD : COND_MOVE<opcode_cmoveqd>;
defm CMOVLTD : COND_MOVE<opcode_cmovltd>;
defm CMOVLED : COND_MOVE<opcode_cmovled>;
defm CMOVEQQ : COND_MOVE<opcode_cmoveqq>;
defm CMOVLTQ : COND_MOVE<opcode_cmovltq>;
defm CMOVLEQ : COND_MOVE<opcode_cmovleq>;

multiclass CondMoveBitwiseAnd<InstBase Inst, ValueType Ty, ValueType Tc>
{
  def : Pat<(Ty (select (i1 (trunc Tc:$rb)), Ty:$rd, Ty:$rc)), (Inst GR:$rb, GR:$rc, GR:$rd)>;
  def : Pat<(Ty (select (i1 (trunc (and Tc:$rb, (Tc 1)))), Ty:$rd, Ty:$rc)), (Inst GR:$rb, GR:$rc, GR:$rd)>;

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
  defm : CondMovePat<CMOVEQW, seteq, 0, Ty, i32>;
  defm : CondMovePat<CMOVLTW, setlt, 0, Ty, i32>;
  defm : CondMovePat<CMOVLEW, setle, 0, Ty, i32>;

  defm : CondMovePat<CMOVEQD, seteq, 0, Ty, i64>;
  defm : CondMovePat<CMOVLTD, setlt, 0, Ty, i64>;
  defm : CondMovePat<CMOVLED, setle, 0, Ty, i64>;

  defm : CondMovePat<CMOVEQQ, seteq, 0, Ty, i128>;
  defm : CondMovePat<CMOVLTQ, setlt, 0, Ty, i128>;
  defm : CondMovePat<CMOVLEQ, setle, 0, Ty, i128>;


  // (x != value) => inverted(x == value)
  defm : CondMoveSwappedPat<CMOVEQW, setne, 0, Ty, i32>;
  defm : CondMoveSwappedPat<CMOVLTW, setge, 0, Ty, i32>;
  defm : CondMoveSwappedPat<CMOVLEW, setgt, 0, Ty, i32>;

  defm : CondMoveSwappedPat<CMOVEQD, setne, 0, Ty, i64>;
  defm : CondMoveSwappedPat<CMOVLTD, setge, 0, Ty, i64>;
  defm : CondMoveSwappedPat<CMOVLED, setgt, 0, Ty, i64>;

  defm : CondMoveSwappedPat<CMOVEQQ, setne, 0, Ty, i128>;
  defm : CondMoveSwappedPat<CMOVLTQ, setge, 0, Ty, i128>;
  defm : CondMoveSwappedPat<CMOVLEQ, setgt, 0, Ty, i128>;

  // (x < 1) => (x <= 0)
  defm : CondMovePat<CMOVLEW, setlt, 1, Ty, i32>;
  defm : CondMovePat<CMOVLED, setlt, 1, Ty, i64>;
  defm : CondMovePat<CMOVLEQ, setlt, 1, Ty, i128>;

  // (x > -1) => (x >= 0) => inverted(x < 0)
  defm : CondMoveSwappedPat<CMOVLTW, setgt, -1, Ty, i32>;
  defm : CondMoveSwappedPat<CMOVLTD, setgt, -1, Ty, i64>;
  defm : CondMoveSwappedPat<CMOVLTQ, setgt, -1, Ty, i128>;
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

//===----------------------------------------------------------------------===//
// bitwise select
//===----------------------------------------------------------------------===//
defm BITSLCT : COND_MOVE<opcode_bitslct>;

foreach Vt = [ i32, i64, i128 ] in {
  // Bitselect is equivalent to (c & v1) | (~c & v2)
  def : Pat<(Vt (or (and Vt:$c, Vt:$v1), (and (not Vt:$c), Vt:$v2))), (BITSLCT $v1, $v2, $c)>;

  // Bitselect is also equivalent to ((v1 ^ v2) & c) ^ v2
  def : Pat<(Vt (xor (and (xor Vt:$v1, Vt:$v2), Vt:$c), Vt:$v2)), (BITSLCT $v1, $v2, $c)>;

  // Same pattern with `c` negated so `a` and `b` get swapped.
  // ((v1 ^ v2) & ~c) ^ v2
  def : Pat<(Vt (xor (and (xor Vt:$v1, Vt:$v2), (not Vt:$c)), Vt:$v2)), (BITSLCT $v2, $v1, $c)>;
}

// same for vectors, using not => vnot, plus vselect
foreach Vt = [ v16i8, v8i16, v4i32, v2i64 ] in {
  def : Pat<(Vt (vselect Vt:$rb, Vt:$rc, Vt:$rd)), (BITSLCT GR:$rb, GR:$rc, GR:$rd)>;

  // Bitselect is equivalent to (c & v1) | (~c & v2)
  def : Pat<(Vt (or (and Vt:$c, Vt:$v1), (and (vnot Vt:$c), Vt:$v2))), (BITSLCT $v1, $v2, $c)>;

  // Bitselect is also equivalent to ((v1 ^ v2) & c) ^ v2
  def : Pat<(Vt (xor (and (xor Vt:$v1, Vt:$v2), Vt:$c), Vt:$v2)), (BITSLCT $v1, $v2, $c)>;

  // Same pattern with `c` negated so `a` and `b` get swapped.
  // ((v1 ^ v2) & ~c) ^ v2
  def : Pat<(Vt (xor (and (xor Vt:$v1, Vt:$v2), (vnot Vt:$c)), Vt:$v2)), (BITSLCT $v2, $v1, $c)>;
}
