//===-- PostriscInstrInfoFloat.td - Target Description for Postrisc FP ----===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file describes the Postrisc floating-point instructions.
//
//===----------------------------------------------------------------------===//

def fpimm0 : PatLeaf<(fpimm), [{ return N->isExactlyValue(+0.0); }]>;

def : Pat<(f16 fpimm0), (COPY (f16 gz))>;
def : Pat<(f32 fpimm0), (COPY (f32 gz))>;
def : Pat<(f64 fpimm0), (COPY (f64 gz))>;
def : Pat<(f128 fpimm0), (COPY (f128 gz))>;

// Materialize FP constants via MOVi32imm/MOVi64imm (MachO large code model).
def bitcast_fpimm_to_i32 : SDNodeXForm<fpimm, [{
return CurDAG->getSignedTargetConstant(
  N->getValueAPF().bitcastToAPInt().getSExtValue(), SDLoc(N), MVT::i32);
}]>;

def bitcast_fpimm_to_i64 : SDNodeXForm<fpimm, [{
return CurDAG->getSignedTargetConstant(
  N->getValueAPF().bitcastToAPInt().getSExtValue(), SDLoc(N), MVT::i64);
}]>;

def : Pat<(f16 fpimm:$in), (LD_IMM     (bitcast_fpimm_to_i32 $in))>;
def : Pat<(f32 fpimm:$in), (LD_IMM_EXT (bitcast_fpimm_to_i32 $in))>;
def : Pat<(f64 fpimm:$in), (LD_IMM_EXT (bitcast_fpimm_to_i64 $in))>;

def fcvt128hi : SDNodeXForm<fpimm, [{
  APInt enc = N->getValueAPF().bitcastToAPInt();
  enc = enc.ashr(64);
  int64_t tmp = enc.getSExtValue();
  return CurDAG->getSignedTargetConstant(tmp, SDLoc(N), MVT::i64);
}]>;
def fcvt128lo : SDNodeXForm<fpimm, [{
  APInt enc = N->getValueAPF().bitcastToAPInt();
  enc &= 0xFFFFFFFFFFFFFFFFull;
  int64_t tmp = enc.getZExtValue();
  return CurDAG->getSignedTargetConstant(tmp, SDLoc(N), MVT::i64);
}]>;

// f128 materialization: ext+simple (special values, integers like 2.0)

def fpimm_2_1 : FPImmLeaf<f128, [{
  APInt enc = Imm.bitcastToAPInt();
  enc &= 0xFFFFFFFFFFFFFFFFull;
  int64_t tmp = enc.getZExtValue();
  return isInt<28>(tmp);
}]>;

def : Pat<(fpimm_2_1:$val), (LD_IMM_HIGH_EXT (LD_IMM (fcvt128lo $val)), (fcvt128hi $val))>;

// f128 materialization: simple+ext (negative denormals?)
def fpimm_1_2 : FPImmLeaf<f128, [{
  APInt enc = Imm.bitcastToAPInt();
  enc = enc.ashr(64);
  int64_t tmp = enc.getSExtValue();
  return isInt<28>(tmp);
}]>;

def : Pat<(fpimm_1_2:$val), (LD_IMM_HIGH (LD_IMM_EXT (fcvt128lo $val)), (fcvt128hi $val))>;

// universal f128 materialization: ext+ext
def : Pat<(f128 fpimm:$val), (LD_IMM_HIGH_EXT (LD_IMM_EXT (fcvt128lo $val)), (fcvt128hi $val))>;

//===----------------------------------------------------------------------===//
// float <=> float conversions
//===----------------------------------------------------------------------===//

multiclass MISC_FP_EXTEND<misc_opx opx, ValueType Tdst, ValueType Tsrc, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : MISC_Rab<opx, (outs GR:$ra), (ins GR:$rb),
     !strconcat(opx.mnem, " $ra, $rb"), [(set Tdst:$ra, (any_fpextend Tsrc:$rb))], itin>;
}

defm EXTEND_F16_F32  : MISC_FP_EXTEND<opcode_extend_f16_f32,  f32,  f16>;
defm EXTEND_F16_F64  : MISC_FP_EXTEND<opcode_extend_f16_f64,  f64,  f16>;
defm EXTEND_F16_F128 : MISC_FP_EXTEND<opcode_extend_f16_f128, f128, f16>;
defm EXTEND_F32_F64  : MISC_FP_EXTEND<opcode_extend_f32_f64,  f64,  f32>;
defm EXTEND_F32_F128 : MISC_FP_EXTEND<opcode_extend_f32_f128, f128, f32>;
defm EXTEND_F64_F128 : MISC_FP_EXTEND<opcode_extend_f64_f128, f128, f64>;

// FXX to FX (lesser) conversion - via dynamic rounding settings
defm CVT_F32_F16  : MISC_R2<opcode_cvt_f32_f16,  any_fpround, f16, f32>;
defm CVT_F64_F16  : MISC_R2<opcode_cvt_f64_f16,  any_fpround, f16, f64>;
defm CVT_F128_F16 : MISC_R2<opcode_cvt_f128_f16, any_fpround, f16, f128>;
defm CVT_F64_F32  : MISC_R2<opcode_cvt_f64_f32,  any_fpround, f32, f64>;
defm CVT_F128_F32 : MISC_R2<opcode_cvt_f128_f32, any_fpround, f32, f128>;
defm CVT_F128_F64 : MISC_R2<opcode_cvt_f128_f64, any_fpround, f64, f128>;

//===----------------------------------------------------------------------===//
// patterns
//===----------------------------------------------------------------------===//
multiclass FP_BASE_INTRUCTIONS<string T, ValueType Ty>
{
  defm ABS_   # NAME : BUILTIN_R2<!cast<misc_opx>("opcode_abs_"   # T), !cast<ClangBuiltin>("int_postrisc_abs_"   # T), Ty, Ty>;
  defm NABS_  # NAME : BUILTIN_R2<!cast<misc_opx>("opcode_nabs_"  # T), !cast<ClangBuiltin>("int_postrisc_nabs_"  # T), Ty, Ty>;
  defm NEG_   # NAME : BUILTIN_R2<!cast<misc_opx>("opcode_neg_"   # T), !cast<ClangBuiltin>("int_postrisc_neg_"   # T), Ty, Ty>;
  defm SQRT_  # NAME : BUILTIN_R2<!cast<misc_opx>("opcode_sqrt_"  # T), !cast<ClangBuiltin>("int_postrisc_sqrt_"  # T), Ty, Ty>;
  defm RSQRT_ # NAME : BUILTIN_R2<!cast<misc_opx>("opcode_rsqrt_" # T), !cast<ClangBuiltin>("int_postrisc_rsqrt_" # T), Ty, Ty>;

  defm ABS_DIFF_  # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_abs_diff_"  # T), !cast<ClangBuiltin>("int_postrisc_abs_diff_"  # T), Ty, Ty, Ty>;
  defm NABS_DIFF_ # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_nabs_diff_" # T), !cast<ClangBuiltin>("int_postrisc_nabs_diff_" # T), Ty, Ty, Ty>;
  defm ADD_       # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_add_"       # T), !cast<ClangBuiltin>("int_postrisc_add_"       # T), Ty, Ty, Ty>;
  defm NADD_      # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_nadd_"      # T), !cast<ClangBuiltin>("int_postrisc_nadd_"      # T), Ty, Ty, Ty>;
  defm SUB_       # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_sub_"       # T), !cast<ClangBuiltin>("int_postrisc_sub_"       # T), Ty, Ty, Ty>;
  defm MUL_       # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_mul_"       # T), !cast<ClangBuiltin>("int_postrisc_mul_"       # T), Ty, Ty, Ty>;
  defm NMUL_      # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_nmul_"      # T), !cast<ClangBuiltin>("int_postrisc_nmul_"      # T), Ty, Ty, Ty>;
  defm DIV_       # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_div_"       # T), !cast<ClangBuiltin>("int_postrisc_div_"       # T), Ty, Ty, Ty>;
  defm ABS_MAX_   # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_abs_max_"   # T), !cast<ClangBuiltin>("int_postrisc_abs_max_"   # T), Ty, Ty, Ty>;
  defm ABS_MIN_   # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_abs_min_"   # T), !cast<ClangBuiltin>("int_postrisc_abs_min_"   # T), Ty, Ty, Ty>;
  defm MAX_       # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_max_"       # T), !cast<ClangBuiltin>("int_postrisc_max_"       # T), Ty, Ty, Ty>;
  defm MIN_       # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_min_"       # T), !cast<ClangBuiltin>("int_postrisc_min_"       # T), Ty, Ty, Ty>;
  defm MAXNUM_    # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_maxnum_"    # T), !cast<ClangBuiltin>("int_postrisc_maxnum_"    # T), Ty, Ty, Ty>;
  defm MINNUM_    # NAME : BUILTIN_R3<!cast<misc_opx>("opcode_minnum_"    # T), !cast<ClangBuiltin>("int_postrisc_minnum_"    # T), Ty, Ty, Ty>;

  // 5 base rounding modes
  defm FLOOR_        # NAME : MISC_R2<!cast<misc_opx>("opcode_floor_"        # T), any_ffloor,     Ty, Ty>; // towards -inf.
  defm CEIL_         # NAME : MISC_R2<!cast<misc_opx>("opcode_ceil_"         # T), any_fceil,      Ty, Ty>; // upward towards +inf
  defm TRUNK_        # NAME : MISC_R2<!cast<misc_opx>("opcode_trunk_"        # T), any_ftrunc,     Ty, Ty>; // to zero
  defm ROUNDEVEN_    # NAME : MISC_R2<!cast<misc_opx>("opcode_roundeven_"    # T), any_froundeven, Ty, Ty>; // to nearest even
  defm ROUND_        # NAME : MISC_R2<!cast<misc_opx>("opcode_round_"        # T), any_fround,     Ty, Ty>; // to nearest with ties away from zero.

  // dynamic rounding
  defm RINT_      # NAME : MISC_R2<!cast<misc_opx>("opcode_rint_"      # T), any_frint,      Ty, Ty>; // frint rounds according to the current mode
  defm NEARBYINT_ # NAME : MISC_R2<!cast<misc_opx>("opcode_nearbyint_" # T), any_fnearbyint, Ty, Ty>; // fnearbyint is like frint, without inexact

  defm MADD_  # NAME : BUILTIN_R4<!cast<fused_opx>("opcode_madd_"  # T), !cast<ClangBuiltin>("int_postrisc_madd_"  # T), Ty, Ty, Ty, Ty>;
  defm MSUB_  # NAME : BUILTIN_R4<!cast<fused_opx>("opcode_msub_"  # T), !cast<ClangBuiltin>("int_postrisc_msub_"  # T), Ty, Ty, Ty, Ty>;
  defm NMADD_ # NAME : BUILTIN_R4<!cast<fused_opx>("opcode_nmadd_" # T), !cast<ClangBuiltin>("int_postrisc_nmadd_" # T), Ty, Ty, Ty, Ty>;
  defm NMSUB_ # NAME : BUILTIN_R4<!cast<fused_opx>("opcode_nmsub_" # T), !cast<ClangBuiltin>("int_postrisc_nmsub_" # T), Ty, Ty, Ty, Ty>;
  defm MERGE_ # NAME : BUILTIN_R4<!cast<fused_opx>("opcode_merge_" # T), !cast<ClangBuiltin>("int_postrisc_merge_" # T), Ty, Ty, Ty, Ty>;

  defm CMP_OEQ_ # NAME : MISC_R3<!cast<misc_opx>("opcode_cmp_oeq_" # T), setoeq, i1, Ty>;
  defm CMP_ONE_ # NAME : MISC_R3<!cast<misc_opx>("opcode_cmp_one_" # T), setone, i1, Ty>;
  defm CMP_OLT_ # NAME : MISC_R3<!cast<misc_opx>("opcode_cmp_olt_" # T), setolt, i1, Ty>;
  defm CMP_OLE_ # NAME : MISC_R3<!cast<misc_opx>("opcode_cmp_ole_" # T), setole, i1, Ty>;
  defm CMP_O_   # NAME : MISC_R3<!cast<misc_opx>("opcode_cmp_o_"   # T), seto,   i1, Ty>;
  defm CMP_UEQ_ # NAME : MISC_R3<!cast<misc_opx>("opcode_cmp_ueq_" # T), setueq, i1, Ty>;
  defm CMP_UNE_ # NAME : MISC_R3<!cast<misc_opx>("opcode_cmp_une_" # T), setune, i1, Ty>;
  defm CMP_ULT_ # NAME : MISC_R3<!cast<misc_opx>("opcode_cmp_ult_" # T), setult, i1, Ty>;
  defm CMP_ULE_ # NAME : MISC_R3<!cast<misc_opx>("opcode_cmp_ule_" # T), setule, i1, Ty>;
  defm CMP_U_   # NAME : MISC_R3<!cast<misc_opx>("opcode_cmp_u_"   # T), setuo,  i1, Ty>;
}

defm F16  : FP_BASE_INTRUCTIONS<"f16",  f16>;
defm F32  : FP_BASE_INTRUCTIONS<"f32",  f32>;
defm F64  : FP_BASE_INTRUCTIONS<"f64",  f64>;
defm F128 : FP_BASE_INTRUCTIONS<"f128", f128>;

multiclass FP_BASE_CVT_INTRUCTIONS<string T, ValueType Ty>
{
  // float => integer conversions (via trunk)
  defm TRUNK_ # NAME # _I32  : MISC_R2<!cast<misc_opx>("opcode_trunk_" # T # "_i32" ), any_fp_to_sint, i32,  Ty>;
  defm TRUNK_ # NAME # _U32  : MISC_R2<!cast<misc_opx>("opcode_trunk_" # T # "_u32" ), any_fp_to_uint, i32,  Ty>;
  defm TRUNK_ # NAME # _I64  : MISC_R2<!cast<misc_opx>("opcode_trunk_" # T # "_i64" ), any_fp_to_sint, i64,  Ty>;
  defm TRUNK_ # NAME # _U64  : MISC_R2<!cast<misc_opx>("opcode_trunk_" # T # "_u64" ), any_fp_to_uint, i64,  Ty>;
  defm TRUNK_ # NAME # _I128 : MISC_R2<!cast<misc_opx>("opcode_trunk_" # T # "_i128"), any_fp_to_sint, i128, Ty>;
  defm TRUNK_ # NAME # _U128 : MISC_R2<!cast<misc_opx>("opcode_trunk_" # T # "_u128"), any_fp_to_uint, i128, Ty>;

  // integer => float conversions
  defm CVT_I32_  # NAME : MISC_R2<!cast<misc_opx>("opcode_cvt_i32_"  # T), any_sint_to_fp, Ty, i32>;
  defm CVT_U32_  # NAME : MISC_R2<!cast<misc_opx>("opcode_cvt_u32_"  # T), any_uint_to_fp, Ty, i32>;
  defm CVT_I64_  # NAME : MISC_R2<!cast<misc_opx>("opcode_cvt_i64_"  # T), any_sint_to_fp, Ty, i64>;
  defm CVT_U64_  # NAME : MISC_R2<!cast<misc_opx>("opcode_cvt_u64_"  # T), any_uint_to_fp, Ty, i64>;
  defm CVT_I128_ # NAME : MISC_R2<!cast<misc_opx>("opcode_cvt_i128_" # T), any_sint_to_fp, Ty, i128>;
  defm CVT_U128_ # NAME : MISC_R2<!cast<misc_opx>("opcode_cvt_u128_" # T), any_uint_to_fp, Ty, i128>;

  // FIXME: i1 to fp => via i32 to fp
  def : Pat<(Ty (any_sint_to_fp  i1:$src)),  (!cast<InstBase>("CVT_I32_" # NAME) GR:$src)>;
  def : Pat<(Ty (any_uint_to_fp  i1:$src)),  (!cast<InstBase>("CVT_U32_" # NAME) GR:$src)>;
}

defm F16  : FP_BASE_CVT_INTRUCTIONS<"f16", f16>;
defm F32  : FP_BASE_CVT_INTRUCTIONS<"f32", f32>;
defm F64  : FP_BASE_CVT_INTRUCTIONS<"f64", f64>;
defm F128 : FP_BASE_CVT_INTRUCTIONS<"f128", f128>;

multiclass FP_SCALAR_PATTERNS<ValueType Ty>
{
  // arg swapping for GT/GE
  def : Pat<(i1 (setogt Ty:$rb, Ty:$rc)), (!cast<InstBase>("CMP_OLT_" # NAME) GR:$rc, GR:$rb)>;
  def : Pat<(i1 (setoge Ty:$rb, Ty:$rc)), (!cast<InstBase>("CMP_OLE_" # NAME) GR:$rc, GR:$rb)>;
  def : Pat<(i1 (setugt Ty:$rb, Ty:$rc)), (!cast<InstBase>("CMP_ULT_" # NAME) GR:$rc, GR:$rb)>;
  def : Pat<(i1 (setuge Ty:$rb, Ty:$rc)), (!cast<InstBase>("CMP_ULE_" # NAME) GR:$rc, GR:$rb)>;

  // fast-math doesn't differ ordered/unordered => use ordered forms
  def : Pat<(i1 (seteq Ty:$rb, Ty:$rc)), (!cast<InstBase>("CMP_OEQ_" # NAME) GR:$rb, GR:$rc)>;
  def : Pat<(i1 (setne Ty:$rb, Ty:$rc)), (!cast<InstBase>("CMP_ONE_" # NAME) GR:$rb, GR:$rc)>;
  def : Pat<(i1 (setlt Ty:$rb, Ty:$rc)), (!cast<InstBase>("CMP_OLT_" # NAME) GR:$rb, GR:$rc)>;
  def : Pat<(i1 (setle Ty:$rb, Ty:$rc)), (!cast<InstBase>("CMP_OLE_" # NAME) GR:$rb, GR:$rc)>;
  def : Pat<(i1 (setgt Ty:$rb, Ty:$rc)), (!cast<InstBase>("CMP_OLT_" # NAME) GR:$rc, GR:$rb)>;
  def : Pat<(i1 (setge Ty:$rb, Ty:$rc)), (!cast<InstBase>("CMP_OLE_" # NAME) GR:$rc, GR:$rb)>;

  def : Pat<(fneg        Ty:$rb ), (!cast<InstBase>("NEG_"  # NAME) GR:$rb)>;
  def : Pat<(       fabs Ty:$rb ), (!cast<InstBase>("ABS_"  # NAME) GR:$rb)>;
  def : Pat<(fneg ( fabs Ty:$rb)), (!cast<InstBase>("NABS_" # NAME) GR:$rb)>;
  def : Pat<(      fsqrt Ty:$rb ), (!cast<InstBase>("SQRT_" # NAME) GR:$rb)>;

  def : Pat<(fadd Ty:$rb, Ty:$rc), (!cast<InstBase>("ADD_" # NAME) GR:$rb, GR:$rc)>;
  def : Pat<(fsub Ty:$rb, Ty:$rc), (!cast<InstBase>("SUB_" # NAME) GR:$rb, GR:$rc)>;
  def : Pat<(fmul Ty:$rb, Ty:$rc), (!cast<InstBase>("MUL_" # NAME) GR:$rb, GR:$rc)>;
  def : Pat<(fdiv Ty:$rb, Ty:$rc), (!cast<InstBase>("DIV_" # NAME) GR:$rb, GR:$rc)>;

  def : Pat<(      fabs (fsub       Ty:$rb,        Ty:$rc )), (!cast<InstBase>("ABS_DIFF_"  # NAME) GR:$rb, GR:$rc)>; // absolute difference
  def : Pat<(fneg (fabs (fsub       Ty:$rb,        Ty:$rc))), (!cast<InstBase>("NABS_DIFF_" # NAME) GR:$rb, GR:$rc)>; // negated absolute difference
  def : Pat<(fneg (      fadd       Ty:$rb,        Ty:$rc )), (!cast<InstBase>("NADD_"      # NAME) GR:$rb, GR:$rc)>; // negated sum
  def : Pat<(            fadd (fneg Ty:$rb), (fneg Ty:$rc )), (!cast<InstBase>("NADD_"      # NAME) GR:$rb, GR:$rc)>; // negated sum (as sum of negated)
  def : Pat<(fneg (      fmul       Ty:$rb ,       Ty:$rc )), (!cast<InstBase>("NMUL_"      # NAME) GR:$rb, GR:$rc)>; // negated mul
  def : Pat<(            fmul (fneg Ty:$rb),       Ty:$rc  ), (!cast<InstBase>("NMUL_"      # NAME) GR:$rb, GR:$rc)>; // negated mul (as mul of one negated)
  def : Pat<(            fmul       Ty:$rb , (fneg Ty:$rc )), (!cast<InstBase>("NMUL_"      # NAME) GR:$rb, GR:$rc)>; // negated mul (as mul of one negated)

  def : Pat<(fminimum       Ty:$rb,        Ty:$rc ), (!cast<InstBase>("MIN_"     # NAME) GR:$rb, GR:$rc)>;
  def : Pat<(fmaximum       Ty:$rb,        Ty:$rc ), (!cast<InstBase>("MAX_"     # NAME) GR:$rb, GR:$rc)>;
  def : Pat<(fminimum (fabs Ty:$rb), (fabs Ty:$rc)), (!cast<InstBase>("ABS_MIN_" # NAME) GR:$rb, GR:$rc)>;
  def : Pat<(fmaximum (fabs Ty:$rb), (fabs Ty:$rc)), (!cast<InstBase>("ABS_MAX_" # NAME) GR:$rb, GR:$rc)>;
  def : Pat<(fminnum        Ty:$rb,        Ty:$rc ), (!cast<InstBase>("MINNUM_"  # NAME) GR:$rb, GR:$rc)>;
  def : Pat<(fmaxnum        Ty:$rb,        Ty:$rc ), (!cast<InstBase>("MAXNUM_"  # NAME) GR:$rb, GR:$rc)>;

  def : Pat<(      any_fma       Ty:$rb,       Ty:$rc,        Ty:$rd),  (!cast<InstBase>("MADD_"  # NAME) GR:$rb, GR:$rc, GR:$rd)>; //    x  *  y  +  z
  def : Pat<(      any_fma       Ty:$rb,       Ty:$rc,  (fneg Ty:$rd)), (!cast<InstBase>("MSUB_"  # NAME) GR:$rb, GR:$rc, GR:$rd)>; //    x  *  y  -  z
  def : Pat<(      any_fma (fneg Ty:$rb),      Ty:$rc,        Ty:$rd),  (!cast<InstBase>("NMADD_" # NAME) GR:$rb, GR:$rc, GR:$rd)>; //   -x  *  y  +  z
  def : Pat<(      any_fma       Ty:$rb, (fneg Ty:$rc),       Ty:$rd),  (!cast<InstBase>("NMADD_" # NAME) GR:$rb, GR:$rc, GR:$rd)>; //    x  * -y  +  z
  def : Pat<(      any_fma (fneg Ty:$rb),      Ty:$rc,  (fneg Ty:$rd)), (!cast<InstBase>("NMSUB_" # NAME) GR:$rb, GR:$rc, GR:$rd)>; //   -x  *  y  -  z
  def : Pat<(      any_fma       Ty:$rb, (fneg Ty:$rc), (fneg Ty:$rd)), (!cast<InstBase>("NMSUB_" # NAME) GR:$rb, GR:$rc, GR:$rd)>; //   -x  *  y  -  z
  def : Pat<(fneg (any_fma       Ty:$rb,       Ty:$rc,        Ty:$rd)), (!cast<InstBase>("NMSUB_" # NAME) GR:$rb, GR:$rc, GR:$rd)>; // -( x  *  y  +  z)

  def : Pat<(fcopysign Ty:$rb, Ty:$rc), (!cast<InstBase>("MERGE_" # NAME) GR:$rc, GR:$rb, GR:$rb)>;
}

defm F16  : FP_SCALAR_PATTERNS<f16>;
defm F32  : FP_SCALAR_PATTERNS<f32>;
defm F64  : FP_SCALAR_PATTERNS<f64>;
defm F128 : FP_SCALAR_PATTERNS<f128>;

//===----------------------------------------------------------------------===//
// fp branches
//===----------------------------------------------------------------------===//
multiclass
FP_CompareAndBranch_F32<br_f32_opx opx, PatFrag OpNode, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  let isBranch = 1, isTerminator = 1 in
  def NAME : BRR_RabBranch<opcode_br_f32, opx.value,
                 (outs), (ins GR:$ra, GR:$rb, brtarget:$offset),
                 !strconcat(opx.mnem, " $ra, $rb, $offset"),
                 [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;

  let isBranch = 1, isTerminator = 1 in
  def NAME # _EXT : BRR_RabBranch_ext<opcode_br_f32, opx.value,
                 (outs), (ins GR:$ra, GR:$rb, brtarget_ext:$offset),
                 !strconcat(opx.mnem, ".l $ra, $rb, $offset"),
                 [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;
}

defm BR_OEQ_F32 : FP_CompareAndBranch_F32<opcode_br_oeq_f32, setoeq, f32>;
defm BR_ONE_F32 : FP_CompareAndBranch_F32<opcode_br_one_f32, setone, f32>;
defm BR_OLT_F32 : FP_CompareAndBranch_F32<opcode_br_olt_f32, setolt, f32>;
defm BR_OLE_F32 : FP_CompareAndBranch_F32<opcode_br_ole_f32, setole, f32>;
defm BR_O_F32   : FP_CompareAndBranch_F32<opcode_br_o_f32,   seto,   f32>;
defm BR_UEQ_F32 : FP_CompareAndBranch_F32<opcode_br_ueq_f32, setueq, f32>;
defm BR_UNE_F32 : FP_CompareAndBranch_F32<opcode_br_une_f32, setune, f32>;
defm BR_ULT_F32 : FP_CompareAndBranch_F32<opcode_br_ult_f32, setult, f32>;
defm BR_ULE_F32 : FP_CompareAndBranch_F32<opcode_br_ule_f32, setule, f32>;
defm BR_U_F32   : FP_CompareAndBranch_F32<opcode_br_u_f32,   setuo,  f32>;

multiclass
FP_CompareAndBranch_F64<br_f64_opx opx, PatFrag OpNode, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  let isBranch = 1, isTerminator = 1 in
  def NAME : BRR_RabBranch<opcode_br_f64, opx.value,
                 (outs), (ins GR:$ra, GR:$rb, brtarget:$offset),
                 !strconcat(opx.mnem, " $ra, $rb, $offset"),
                 [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;

  let isBranch = 1, isTerminator = 1 in
  def NAME # _EXT : BRR_RabBranch_ext<opcode_br_f64, opx.value,
                 (outs), (ins GR:$ra, GR:$rb, brtarget_ext:$offset),
                 !strconcat(opx.mnem, ".l $ra, $rb, $offset"),
                 [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;
}

defm BR_OEQ_F64 : FP_CompareAndBranch_F64<opcode_br_oeq_f64, setoeq, f64>;
defm BR_ONE_F64 : FP_CompareAndBranch_F64<opcode_br_one_f64, setone, f64>;
defm BR_OLT_F64 : FP_CompareAndBranch_F64<opcode_br_olt_f64, setolt, f64>;
defm BR_OLE_F64 : FP_CompareAndBranch_F64<opcode_br_ole_f64, setole, f64>;
defm BR_O_F64   : FP_CompareAndBranch_F64<opcode_br_o_f64,   seto,   f64>;
defm BR_UEQ_F64 : FP_CompareAndBranch_F64<opcode_br_ueq_f64, setueq, f64>;
defm BR_UNE_F64 : FP_CompareAndBranch_F64<opcode_br_une_f64, setune, f64>;
defm BR_ULT_F64 : FP_CompareAndBranch_F64<opcode_br_ult_f64, setult, f64>;
defm BR_ULE_F64 : FP_CompareAndBranch_F64<opcode_br_ule_f64, setule, f64>;
defm BR_U_F64   : FP_CompareAndBranch_F64<opcode_br_u_f64,   setuo,  f64>;

multiclass
FP_CompareAndBranch_F128<br_f128_opx opx, PatFrag OpNode, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  let isBranch = 1, isTerminator = 1 in
  def NAME : BRR_RabBranch<opcode_br_f128, opx.value,
                 (outs), (ins GR:$ra, GR:$rb, brtarget:$offset),
                 !strconcat(opx.mnem, " $ra, $rb, $offset"),
                 [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;

  let isBranch = 1, isTerminator = 1 in
  def NAME # _EXT : BRR_RabBranch_ext<opcode_br_f128, opx.value,
                 (outs), (ins GR:$ra, GR:$rb, brtarget_ext:$offset),
                 !strconcat(opx.mnem, ".l $ra, $rb, $offset"),
                 [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;
}

defm BR_OEQ_F128 : FP_CompareAndBranch_F128<opcode_br_oeq_f128, setoeq, f128>;
defm BR_ONE_F128 : FP_CompareAndBranch_F128<opcode_br_one_f128, setone, f128>;
defm BR_OLT_F128 : FP_CompareAndBranch_F128<opcode_br_olt_f128, setolt, f128>;
defm BR_OLE_F128 : FP_CompareAndBranch_F128<opcode_br_ole_f128, setole, f128>;
defm BR_O_F128   : FP_CompareAndBranch_F128<opcode_br_o_f128,   seto,   f128>;
defm BR_UEQ_F128 : FP_CompareAndBranch_F128<opcode_br_ueq_f128, setueq, f128>;
defm BR_UNE_F128 : FP_CompareAndBranch_F128<opcode_br_une_f128, setune, f128>;
defm BR_ULT_F128 : FP_CompareAndBranch_F128<opcode_br_ult_f128, setult, f128>;
defm BR_ULE_F128 : FP_CompareAndBranch_F128<opcode_br_ule_f128, setule, f128>;
defm BR_U_F128   : FP_CompareAndBranch_F128<opcode_br_u_f128,   setuo,  f128>;

multiclass FP_SCALAR_BRANCH_PATTERNS<ValueType Ty>
{
  // greater branch: swap args
  def : Pat<(brcond (i1 (setogt Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("BR_OLT_" # NAME) GR:$rb, GR:$ra, bb:$dst)>;
  def : Pat<(brcond (i1 (setoge Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("BR_OLE_" # NAME) GR:$rb, GR:$ra, bb:$dst)>;
  def : Pat<(brcond (i1 (setugt Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("BR_ULT_" # NAME) GR:$rb, GR:$ra, bb:$dst)>;
  def : Pat<(brcond (i1 (setuge Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("BR_ULE_" # NAME) GR:$rb, GR:$ra, bb:$dst)>;

  // branch: don't care variants
  // fast-math doesn't differ ordered/unordered and uses ordered forms
  def : Pat<(brcond (i1 (seteq Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("BR_OEQ_" # NAME) GR:$ra, GR:$rb, bb:$dst)>;
  def : Pat<(brcond (i1 (setne Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("BR_ONE_" # NAME) GR:$ra, GR:$rb, bb:$dst)>;
  def : Pat<(brcond (i1 (setlt Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("BR_OLT_" # NAME) GR:$ra, GR:$rb, bb:$dst)>;
  def : Pat<(brcond (i1 (setle Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("BR_OLE_" # NAME) GR:$ra, GR:$rb, bb:$dst)>;

  // fast-math greater branch: swap args
  def : Pat<(brcond (i1 (setgt Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("BR_OLT_" # NAME) GR:$rb, GR:$ra, bb:$dst)>;
  def : Pat<(brcond (i1 (setge Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("BR_OLE_" # NAME) GR:$rb, GR:$ra, bb:$dst)>;
}

defm F32  : FP_SCALAR_BRANCH_PATTERNS<f32>;
defm F64  : FP_SCALAR_BRANCH_PATTERNS<f64>;
defm F128 : FP_SCALAR_BRANCH_PATTERNS<f128>;

//===----------------------------------------------------------------------===//
// bit casts
//===----------------------------------------------------------------------===//

// f128 is bit convertible to i128 and vice verse
def : Pat<(f128 (bitconvert i128:$val)),  (COPY_TO_REGCLASS $val, GR)>;
def : Pat<(i128 (bitconvert f128:$val)),  (COPY_TO_REGCLASS $val, GR)>;

// f64 is bit convertible to i64 and vice verse
def : Pat<(f64 (bitconvert i64:$val)),  (COPY_TO_REGCLASS $val, GR)>;
def : Pat<(i64 (bitconvert f64:$val)),  (COPY_TO_REGCLASS $val, GR)>;

// f32 is bit convertible to i32 and vice verse
def : Pat<(f32 (bitconvert i32:$val)),  (COPY_TO_REGCLASS $val, GR)>;
def : Pat<(i32 (bitconvert f32:$val)),  (COPY_TO_REGCLASS $val, GR)>;

// f16 is bit convertible to i16 and vice verse
def : Pat<(f16 (bitconvert i16:$val)),  (COPY_TO_REGCLASS $val, GR)>;
def : Pat<(i16 (bitconvert f16:$val)),  (COPY_TO_REGCLASS $val, GR)>;
