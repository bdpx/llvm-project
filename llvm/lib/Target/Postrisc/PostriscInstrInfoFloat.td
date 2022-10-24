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

def : Pat<(f16 fpimm:$in), (LDI     (bitcast_fpimm_to_i32 $in))>;
def : Pat<(f32 fpimm:$in), (LDI_EXT (bitcast_fpimm_to_i32 $in))>;
def : Pat<(f64 fpimm:$in), (LDI_EXT (bitcast_fpimm_to_i64 $in))>;

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

def : Pat<(fpimm_2_1:$val), (LDIH_EXT (LDI (fcvt128lo $val)), (fcvt128hi $val))>;

// f128 materialization: simple+ext (negative denormals?)
def fpimm_1_2 : FPImmLeaf<f128, [{
  APInt enc = Imm.bitcastToAPInt();
  enc = enc.ashr(64);
  int64_t tmp = enc.getSExtValue();
  return isInt<28>(tmp);
}]>;

def : Pat<(fpimm_1_2:$val), (LDIH (LDI_EXT (fcvt128lo $val)), (fcvt128hi $val))>;

// universal f128 materialization: ext+ext
def : Pat<(f128 fpimm:$val), (LDIH_EXT (LDI_EXT (fcvt128lo $val)), (fcvt128hi $val))>;

//===----------------------------------------------------------------------===//
// float <=> float conversions
//===----------------------------------------------------------------------===//

multiclass MISC_FP_EXTEND<misc_opx opx, ValueType Tdst, ValueType Tsrc, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : MISC_Rab<opx, (outs GR:$ra), (ins GR:$rb),
     !strconcat(opx.mnem, "\t$ra, $rb"), [(set Tdst:$ra, (any_fpextend Tsrc:$rb))], itin>;
}

defm FEXT_SH_SS : MISC_FP_EXTEND<misc_opx_fext_sh_ss, f32, f16>;
defm FEXT_SH_SD : MISC_FP_EXTEND<misc_opx_fext_sh_sd, f64, f16>;
defm FEXT_SH_SQ : MISC_FP_EXTEND<misc_opx_fext_sh_sq, f128, f16>;
defm FEXT_SS_SD : MISC_FP_EXTEND<misc_opx_fext_ss_sd, f64, f32>;
defm FEXT_SS_SQ : MISC_FP_EXTEND<misc_opx_fext_ss_sq, f128, f32>;
defm FEXT_SD_SQ : MISC_FP_EXTEND<misc_opx_fext_sd_sq, f128, f64>;

def FCVT_SS_SH : MISC_RabRM<misc_opx_fcvt_ss_sh>;
def FCVT_SD_SH : MISC_RabRM<misc_opx_fcvt_sd_sh>;
def FCVT_SQ_SH : MISC_RabRM<misc_opx_fcvt_sq_sh>;
def FCVT_SD_SS : MISC_RabRM<misc_opx_fcvt_sd_ss>;
def FCVT_SQ_SS : MISC_RabRM<misc_opx_fcvt_sq_ss>;
def FCVT_SQ_SD : MISC_RabRM<misc_opx_fcvt_sq_sd>;

def : Pat<(f16 (any_fpround  f32:$src)), (FCVT_SS_SH GR:$src, rounding_mode_nearesteven.value)>;
def : Pat<(f16 (any_fpround  f64:$src)), (FCVT_SD_SH GR:$src, rounding_mode_nearesteven.value)>;
def : Pat<(f16 (any_fpround f128:$src)), (FCVT_SQ_SH GR:$src, rounding_mode_nearesteven.value)>;
def : Pat<(f32 (any_fpround  f64:$src)), (FCVT_SD_SS GR:$src, rounding_mode_nearesteven.value)>;
def : Pat<(f32 (any_fpround f128:$src)), (FCVT_SQ_SS GR:$src, rounding_mode_nearesteven.value)>;
def : Pat<(f64 (any_fpround f128:$src)), (FCVT_SQ_SD GR:$src, rounding_mode_nearesteven.value)>;

//===----------------------------------------------------------------------===//
// patterns
//===----------------------------------------------------------------------===//
multiclass FP_BASE_INTRUCTIONS<string T, ValueType Ty>
{
  defm FABS_   # NAME : BUILTIN_R2<!cast<misc_opx>("misc_opx_fabs_"   # T), !cast<ClangBuiltin>("int_postrisc_fabs"   # T), Ty, Ty>;
  defm FNABS_  # NAME : BUILTIN_R2<!cast<misc_opx>("misc_opx_fnabs_"  # T), !cast<ClangBuiltin>("int_postrisc_fnabs"  # T), Ty, Ty>;
  defm FNEG_   # NAME : BUILTIN_R2<!cast<misc_opx>("misc_opx_fneg_"   # T), !cast<ClangBuiltin>("int_postrisc_fneg"   # T), Ty, Ty>;
  defm FSQRT_  # NAME : BUILTIN_R2<!cast<misc_opx>("misc_opx_fsqrt_"  # T), !cast<ClangBuiltin>("int_postrisc_fsqrt"  # T), Ty, Ty>;
  defm FRSQRT_ # NAME : BUILTIN_R2<!cast<misc_opx>("misc_opx_frsqrt_" # T), !cast<ClangBuiltin>("int_postrisc_frsqrt" # T), Ty, Ty>;

  defm FABSD_  # NAME : BUILTIN_R3<!cast<misc_opx>("misc_opx_fabsd_"  # T), !cast<ClangBuiltin>("int_postrisc_fabsd"  # T), Ty, Ty, Ty>;
  defm FNABSD_ # NAME : BUILTIN_R3<!cast<misc_opx>("misc_opx_fnabsd_" # T), !cast<ClangBuiltin>("int_postrisc_fnabsd" # T), Ty, Ty, Ty>;
  defm FADD_   # NAME : BUILTIN_R3<!cast<misc_opx>("misc_opx_fadd_"   # T), !cast<ClangBuiltin>("int_postrisc_fadd"   # T), Ty, Ty, Ty>;
  defm FNADD_  # NAME : BUILTIN_R3<!cast<misc_opx>("misc_opx_fnadd_"  # T), !cast<ClangBuiltin>("int_postrisc_fnadd"  # T), Ty, Ty, Ty>;
  defm FSUB_   # NAME : BUILTIN_R3<!cast<misc_opx>("misc_opx_fsub_"   # T), !cast<ClangBuiltin>("int_postrisc_fsub"   # T), Ty, Ty, Ty>;
  defm FMUL_   # NAME : BUILTIN_R3<!cast<misc_opx>("misc_opx_fmul_"   # T), !cast<ClangBuiltin>("int_postrisc_fmul"   # T), Ty, Ty, Ty>;
  defm FNMUL_  # NAME : BUILTIN_R3<!cast<misc_opx>("misc_opx_fnmul_"  # T), !cast<ClangBuiltin>("int_postrisc_fnmul"  # T), Ty, Ty, Ty>;
  defm FDIV_   # NAME : BUILTIN_R3<!cast<misc_opx>("misc_opx_fdiv_"   # T), !cast<ClangBuiltin>("int_postrisc_fdiv"   # T), Ty, Ty, Ty>;
  defm FAMAX_  # NAME : BUILTIN_R3<!cast<misc_opx>("misc_opx_famax_"  # T), !cast<ClangBuiltin>("int_postrisc_famax"  # T), Ty, Ty, Ty>;
  defm FAMIN_  # NAME : BUILTIN_R3<!cast<misc_opx>("misc_opx_famin_"  # T), !cast<ClangBuiltin>("int_postrisc_famin"  # T), Ty, Ty, Ty>;
  defm FMAX_   # NAME : BUILTIN_R3<!cast<misc_opx>("misc_opx_fmax_"   # T), !cast<ClangBuiltin>("int_postrisc_fmax"   # T), Ty, Ty, Ty>;
  defm FMIN_   # NAME : BUILTIN_R3<!cast<misc_opx>("misc_opx_fmin_"   # T), !cast<ClangBuiltin>("int_postrisc_fmin"   # T), Ty, Ty, Ty>;

  def  FRND_   # NAME : MISC_RabRM<!cast<misc_opx>("misc_opx_frnd_"   # T)>;

  defm FMADD_  # NAME : BUILTIN_R4<!cast<fused_opx>("fused_opx_fmadd_"  # T), !cast<ClangBuiltin>("int_postrisc_fmadd"  # T), Ty, Ty, Ty, Ty>;
  defm FMSUB_  # NAME : BUILTIN_R4<!cast<fused_opx>("fused_opx_fmsub_"  # T), !cast<ClangBuiltin>("int_postrisc_fmsub"  # T), Ty, Ty, Ty, Ty>;
  defm FNMADD_ # NAME : BUILTIN_R4<!cast<fused_opx>("fused_opx_fnmadd_" # T), !cast<ClangBuiltin>("int_postrisc_fnmadd" # T), Ty, Ty, Ty, Ty>;
  defm FNMSUB_ # NAME : BUILTIN_R4<!cast<fused_opx>("fused_opx_fnmsub_" # T), !cast<ClangBuiltin>("int_postrisc_fnmsub" # T), Ty, Ty, Ty, Ty>;
  defm FMERGE_ # NAME : BUILTIN_R4<!cast<fused_opx>("fused_opx_fmerge_" # T), !cast<ClangBuiltin>("int_postrisc_fmerge" # T), Ty, Ty, Ty, Ty>;

  defm FCMPO_EQ_ # NAME : MISC_R3<!cast<misc_opx>("misc_opx_fcmpo_eq_" # T), setoeq, i1, Ty>;
  defm FCMPO_NE_ # NAME : MISC_R3<!cast<misc_opx>("misc_opx_fcmpo_ne_" # T), setone, i1, Ty>;
  defm FCMPO_LT_ # NAME : MISC_R3<!cast<misc_opx>("misc_opx_fcmpo_lt_" # T), setolt, i1, Ty>;
  defm FCMPO_LE_ # NAME : MISC_R3<!cast<misc_opx>("misc_opx_fcmpo_le_" # T), setole, i1, Ty>;
  defm FCMPO_O_  # NAME : MISC_R3<!cast<misc_opx>("misc_opx_fcmpo_"    # T), seto,   i1, Ty>;
  defm FCMPU_EQ_ # NAME : MISC_R3<!cast<misc_opx>("misc_opx_fcmpu_eq_" # T), setueq, i1, Ty>;
  defm FCMPU_NE_ # NAME : MISC_R3<!cast<misc_opx>("misc_opx_fcmpu_ne_" # T), setune, i1, Ty>;
  defm FCMPU_LT_ # NAME : MISC_R3<!cast<misc_opx>("misc_opx_fcmpu_lt_" # T), setult, i1, Ty>;
  defm FCMPU_LE_ # NAME : MISC_R3<!cast<misc_opx>("misc_opx_fcmpu_le_" # T), setule, i1, Ty>;
  defm FCMPU_O_  # NAME : MISC_R3<!cast<misc_opx>("misc_opx_fcmpu_"    # T), setuo,  i1, Ty>;
}

defm SH : FP_BASE_INTRUCTIONS<"sh", f16>;
defm SS : FP_BASE_INTRUCTIONS<"ss", f32>;
defm SD : FP_BASE_INTRUCTIONS<"sd", f64>;
defm SQ : FP_BASE_INTRUCTIONS<"sq", f128>;

multiclass FP_BASE_CVT_INTRUCTIONS<string T, ValueType Ty>
{
  // float => integer conversions
  def FCVT_ # NAME # _IW : MISC_RabRM<!cast<misc_opx>("misc_opx_fcvt_" # T # "_iw")>;
  def FCVT_ # NAME # _UW : MISC_RabRM<!cast<misc_opx>("misc_opx_fcvt_" # T # "_uw")>;
  def FCVT_ # NAME # _ID : MISC_RabRM<!cast<misc_opx>("misc_opx_fcvt_" # T # "_id")>;
  def FCVT_ # NAME # _UD : MISC_RabRM<!cast<misc_opx>("misc_opx_fcvt_" # T # "_ud")>;
  def FCVT_ # NAME # _IQ : MISC_RabRM<!cast<misc_opx>("misc_opx_fcvt_" # T # "_iq")>;
  def FCVT_ # NAME # _UQ : MISC_RabRM<!cast<misc_opx>("misc_opx_fcvt_" # T # "_uq")>;

  def : Pat<(i32  (any_fp_to_sint Ty:$src)), (!cast<InstBase>("FCVT_" # NAME # "_IW") GR:$src, rounding_mode_nearesteven.value)>;
  def : Pat<(i32  (any_fp_to_uint Ty:$src)), (!cast<InstBase>("FCVT_" # NAME # "_UW") GR:$src, rounding_mode_nearesteven.value)>;
  def : Pat<(i64  (any_fp_to_sint Ty:$src)), (!cast<InstBase>("FCVT_" # NAME # "_ID") GR:$src, rounding_mode_nearesteven.value)>;
  def : Pat<(i64  (any_fp_to_uint Ty:$src)), (!cast<InstBase>("FCVT_" # NAME # "_UD") GR:$src, rounding_mode_nearesteven.value)>;
  def : Pat<(i128 (any_fp_to_sint Ty:$src)), (!cast<InstBase>("FCVT_" # NAME # "_IQ") GR:$src, rounding_mode_nearesteven.value)>;
  def : Pat<(i128 (any_fp_to_uint Ty:$src)), (!cast<InstBase>("FCVT_" # NAME # "_UQ") GR:$src, rounding_mode_nearesteven.value)>;

  // integer => float conversions
  def FCVT_IW_ # NAME : MISC_RabRM<!cast<misc_opx>("misc_opx_fcvt_iw_" # T)>;
  def FCVT_UW_ # NAME : MISC_RabRM<!cast<misc_opx>("misc_opx_fcvt_uw_" # T)>;
  def FCVT_ID_ # NAME : MISC_RabRM<!cast<misc_opx>("misc_opx_fcvt_id_" # T)>;
  def FCVT_UD_ # NAME : MISC_RabRM<!cast<misc_opx>("misc_opx_fcvt_ud_" # T)>;
  def FCVT_IQ_ # NAME : MISC_RabRM<!cast<misc_opx>("misc_opx_fcvt_iq_" # T)>;
  def FCVT_UQ_ # NAME : MISC_RabRM<!cast<misc_opx>("misc_opx_fcvt_uq_" # T)>;

  def : Pat<(Ty (any_sint_to_fp  i32:$src)), (!cast<InstBase>("FCVT_IW_" # NAME) GR:$src, rounding_mode_nearesteven.value)>;
  def : Pat<(Ty (any_uint_to_fp  i32:$src)), (!cast<InstBase>("FCVT_UW_" # NAME) GR:$src, rounding_mode_nearesteven.value)>;
  def : Pat<(Ty (any_sint_to_fp  i64:$src)), (!cast<InstBase>("FCVT_ID_" # NAME) GR:$src, rounding_mode_nearesteven.value)>;
  def : Pat<(Ty (any_uint_to_fp  i64:$src)), (!cast<InstBase>("FCVT_UD_" # NAME) GR:$src, rounding_mode_nearesteven.value)>;
  def : Pat<(Ty (any_sint_to_fp i128:$src)), (!cast<InstBase>("FCVT_IQ_" # NAME) GR:$src, rounding_mode_nearesteven.value)>;
  def : Pat<(Ty (any_uint_to_fp i128:$src)), (!cast<InstBase>("FCVT_UQ_" # NAME) GR:$src, rounding_mode_nearesteven.value)>;

  // FIXME: i1 to fp => via i32 to fp
  def : Pat<(Ty (any_sint_to_fp  i1:$src)),  (!cast<InstBase>("FCVT_IW_" # NAME) GR:$src, rounding_mode_nearesteven.value)>;
  def : Pat<(Ty (any_uint_to_fp  i1:$src)),  (!cast<InstBase>("FCVT_UW_" # NAME) GR:$src, rounding_mode_nearesteven.value)>;
}

defm SH : FP_BASE_CVT_INTRUCTIONS<"sh", f16>;
defm SS : FP_BASE_CVT_INTRUCTIONS<"ss", f32>;
defm SD : FP_BASE_CVT_INTRUCTIONS<"sd", f64>;
defm SQ : FP_BASE_CVT_INTRUCTIONS<"sq", f128>;

multiclass FP_SCALAR_PATTERNS<string T, ValueType Ty>
{
  // arg swapping for GT/GE
  def : Pat<(i1 (setogt Ty:$rb, Ty:$rc)), (!cast<InstBase>("FCMPO_LT_" # NAME) GR:$rc, GR:$rb)>;
  def : Pat<(i1 (setoge Ty:$rb, Ty:$rc)), (!cast<InstBase>("FCMPO_LE_" # NAME) GR:$rc, GR:$rb)>;
  def : Pat<(i1 (setugt Ty:$rb, Ty:$rc)), (!cast<InstBase>("FCMPU_LT_" # NAME) GR:$rc, GR:$rb)>;
  def : Pat<(i1 (setuge Ty:$rb, Ty:$rc)), (!cast<InstBase>("FCMPU_LE_" # NAME) GR:$rc, GR:$rb)>;

  // fast-math doesn't differ ordered/unordered => use ordered forms
  def : Pat<(i1 (seteq Ty:$rb, Ty:$rc)), (!cast<InstBase>("FCMPO_EQ_" # NAME) GR:$rb, GR:$rc)>;
  def : Pat<(i1 (setne Ty:$rb, Ty:$rc)), (!cast<InstBase>("FCMPO_NE_" # NAME) GR:$rb, GR:$rc)>;
  def : Pat<(i1 (setlt Ty:$rb, Ty:$rc)), (!cast<InstBase>("FCMPO_LT_" # NAME) GR:$rb, GR:$rc)>;
  def : Pat<(i1 (setle Ty:$rb, Ty:$rc)), (!cast<InstBase>("FCMPO_LE_" # NAME) GR:$rb, GR:$rc)>;
  def : Pat<(i1 (setgt Ty:$rb, Ty:$rc)), (!cast<InstBase>("FCMPO_LT_" # NAME) GR:$rc, GR:$rb)>;
  def : Pat<(i1 (setge Ty:$rb, Ty:$rc)), (!cast<InstBase>("FCMPO_LE_" # NAME) GR:$rc, GR:$rb)>;

  def : Pat<(fneg        Ty:$rb ), (!cast<InstBase>("FNEG_"  # NAME) GR:$rb)>;
  def : Pat<(       fabs Ty:$rb ), (!cast<InstBase>("FABS_"  # NAME) GR:$rb)>;
  def : Pat<(fneg ( fabs Ty:$rb)), (!cast<InstBase>("FNABS_" # NAME) GR:$rb)>;
  def : Pat<(      fsqrt Ty:$rb ), (!cast<InstBase>("FSQRT_" # NAME) GR:$rb)>;

  def : Pat<(fadd Ty:$rb, Ty:$rc), (!cast<InstBase>("FADD_" # NAME) GR:$rb, GR:$rc)>;
  def : Pat<(fsub Ty:$rb, Ty:$rc), (!cast<InstBase>("FSUB_" # NAME) GR:$rb, GR:$rc)>;
  def : Pat<(fmul Ty:$rb, Ty:$rc), (!cast<InstBase>("FMUL_" # NAME) GR:$rb, GR:$rc)>;
  def : Pat<(fdiv Ty:$rb, Ty:$rc), (!cast<InstBase>("FDIV_" # NAME) GR:$rb, GR:$rc)>;

  def : Pat<(      fabs (fsub       Ty:$rb,        Ty:$rc )), (!cast<InstBase>("FABSD_"  # NAME) GR:$rb, GR:$rc)>; // absolute difference
  def : Pat<(fneg (fabs (fsub       Ty:$rb,        Ty:$rc))), (!cast<InstBase>("FNABSD_" # NAME) GR:$rb, GR:$rc)>; // negated absolute difference
  def : Pat<(fneg (      fadd       Ty:$rb,        Ty:$rc )), (!cast<InstBase>("FNADD_"  # NAME) GR:$rb, GR:$rc)>; // negated sum
  def : Pat<(            fadd (fneg Ty:$rb), (fneg Ty:$rc )), (!cast<InstBase>("FNADD_"  # NAME) GR:$rb, GR:$rc)>; // negated sum (as sum of negated)
  def : Pat<(fneg (      fmul       Ty:$rb ,       Ty:$rc )), (!cast<InstBase>("FNMUL_"  # NAME) GR:$rb, GR:$rc)>; // negated mul
  def : Pat<(            fmul (fneg Ty:$rb),       Ty:$rc  ), (!cast<InstBase>("FNMUL_"  # NAME) GR:$rb, GR:$rc)>; // negated mul (as mul of one negated)
  def : Pat<(            fmul       Ty:$rb , (fneg Ty:$rc )), (!cast<InstBase>("FNMUL_"  # NAME) GR:$rb, GR:$rc)>; // negated mul (as mul of one negated)

  def : Pat<(fminnum       Ty:$rb,        Ty:$rc ), (!cast<InstBase>("FMIN_"  # NAME) GR:$rb, GR:$rc)>;
  def : Pat<(fmaxnum       Ty:$rb,        Ty:$rc ), (!cast<InstBase>("FMAX_"  # NAME) GR:$rb, GR:$rc)>;
  def : Pat<(fminnum (fabs Ty:$rb), (fabs Ty:$rc)), (!cast<InstBase>("FAMIN_" # NAME) GR:$rb, GR:$rc)>;
  def : Pat<(fmaxnum (fabs Ty:$rb), (fabs Ty:$rc)), (!cast<InstBase>("FAMAX_" # NAME) GR:$rb, GR:$rc)>;

  def : Pat<(      any_fma       Ty:$rb,       Ty:$rc,        Ty:$rd),  (!cast<InstBase>("FMADD_"  # NAME) GR:$rb, GR:$rc, GR:$rd)>; //    x  *  y  +  z
  def : Pat<(      any_fma       Ty:$rb,       Ty:$rc,  (fneg Ty:$rd)), (!cast<InstBase>("FMSUB_"  # NAME) GR:$rb, GR:$rc, GR:$rd)>; //    x  *  y  -  z
  def : Pat<(      any_fma (fneg Ty:$rb),      Ty:$rc,        Ty:$rd),  (!cast<InstBase>("FNMADD_" # NAME) GR:$rb, GR:$rc, GR:$rd)>; //   -x  *  y  +  z
  def : Pat<(      any_fma       Ty:$rb, (fneg Ty:$rc),       Ty:$rd),  (!cast<InstBase>("FNMADD_" # NAME) GR:$rb, GR:$rc, GR:$rd)>; //    x  * -y  +  z
  def : Pat<(      any_fma (fneg Ty:$rb),      Ty:$rc,  (fneg Ty:$rd)), (!cast<InstBase>("FNMSUB_" # NAME) GR:$rb, GR:$rc, GR:$rd)>; //   -x  *  y  -  z
  def : Pat<(      any_fma       Ty:$rb, (fneg Ty:$rc), (fneg Ty:$rd)), (!cast<InstBase>("FNMSUB_" # NAME) GR:$rb, GR:$rc, GR:$rd)>; //   -x  *  y  -  z
  def : Pat<(fneg (any_fma       Ty:$rb,       Ty:$rc,        Ty:$rd)), (!cast<InstBase>("FNMSUB_" # NAME) GR:$rb, GR:$rc, GR:$rd)>; // -( x  *  y  +  z)

  def : Pat<(fcopysign Ty:$rb, Ty:$rc), (!cast<InstBase>("FMERGE_" # NAME) GR:$rc, GR:$rb, GR:$rb)>;

  def : Pat<(any_frint      Ty:$rb), (!cast<InstBase>("FRND_" # NAME) GR:$rb, rounding_mode_dynamic.value    )>;  // frint rounds according to the current mode
  def : Pat<(any_fnearbyint Ty:$rb), (!cast<InstBase>("FRND_" # NAME) GR:$rb, rounding_mode_dynamic.value    )>;  // fnearbyint is like frint
  def : Pat<(any_fround     Ty:$rb), (!cast<InstBase>("FRND_" # NAME) GR:$rb, rounding_mode_nearesteven.value)>;  // round towards nearest with ties away from zero.
  def : Pat<(any_ffloor     Ty:$rb), (!cast<InstBase>("FRND_" # NAME) GR:$rb, rounding_mode_downward.value   )>;  // round towards -inf.
  def : Pat<(any_fceil      Ty:$rb), (!cast<InstBase>("FRND_" # NAME) GR:$rb, rounding_mode_upward.value     )>;  // round towards +inf.
  def : Pat<(any_ftrunc     Ty:$rb), (!cast<InstBase>("FRND_" # NAME) GR:$rb, rounding_mode_towardzero.value )>;  // round towards zero.

  def : InstAlias<!strconcat("frnd", T, ".dyn\t$rb, $rc"),   (!cast<InstBase>("FRND_" # NAME) GR:$rb, GR:$rc, rounding_mode_dynamic.value)>;
  def : InstAlias<!strconcat("frnd", T, ".even\t$rb, $rc"),  (!cast<InstBase>("FRND_" # NAME) GR:$rb, GR:$rc, rounding_mode_nearesteven.value)>;
  def : InstAlias<!strconcat("frnd", T, ".floor\t$rb, $rc"), (!cast<InstBase>("FRND_" # NAME) GR:$rb, GR:$rc, rounding_mode_downward.value)>;
  def : InstAlias<!strconcat("frnd", T, ".ceil\t$rb, $rc"),  (!cast<InstBase>("FRND_" # NAME) GR:$rb, GR:$rc, rounding_mode_upward.value)>;
  def : InstAlias<!strconcat("frnd", T, ".trunc\t$rb, $rc"), (!cast<InstBase>("FRND_" # NAME) GR:$rb, GR:$rc, rounding_mode_towardzero.value)>;
}

defm SH : FP_SCALAR_PATTERNS<"sh", f16>;
defm SS : FP_SCALAR_PATTERNS<"ss", f32>;
defm SD : FP_SCALAR_PATTERNS<"sd", f64>;
defm SQ : FP_SCALAR_PATTERNS<"sq", f128>;

//===----------------------------------------------------------------------===//
// fp branches
//===----------------------------------------------------------------------===//
multiclass
FP_CompareAndBranch_SS<bfss_opx opx, PatFrag OpNode, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  let isBranch = 1, isTerminator = 1 in
  def NAME : BRR_RabBranch<opcode_bfss, opx.value,
                 (outs), (ins GR:$ra, GR:$rb, brtarget:$offset),
                 !strconcat(opx.mnem, "\t$ra, $rb, $offset"),
                 [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;

  let isBranch = 1, isTerminator = 1 in
  def NAME # _EXT : BRR_RabBranch_ext<opcode_bfss, opx.value,
                 (outs), (ins GR:$ra, GR:$rb, brtarget_ext:$offset),
                 !strconcat(opx.mnem, ".l\t$ra, $rb, $offset"),
                 [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;
}

defm BFO_EQ_SS : FP_CompareAndBranch_SS<bfss_opx_bfo_eq_ss, setoeq, f32>;
defm BFO_NE_SS : FP_CompareAndBranch_SS<bfss_opx_bfo_ne_ss, setone, f32>;
defm BFO_LT_SS : FP_CompareAndBranch_SS<bfss_opx_bfo_lt_ss, setolt, f32>;
defm BFO_LE_SS : FP_CompareAndBranch_SS<bfss_opx_bfo_le_ss, setole, f32>;
defm BFO_SS    : FP_CompareAndBranch_SS<bfss_opx_bfo_ss,    seto,   f32>;
defm BFU_EQ_SS : FP_CompareAndBranch_SS<bfss_opx_bfu_eq_ss, setueq, f32>;
defm BFU_NE_SS : FP_CompareAndBranch_SS<bfss_opx_bfu_ne_ss, setune, f32>;
defm BFU_LT_SS : FP_CompareAndBranch_SS<bfss_opx_bfu_lt_ss, setult, f32>;
defm BFU_LE_SS : FP_CompareAndBranch_SS<bfss_opx_bfu_le_ss, setule, f32>;
defm BFU_SS    : FP_CompareAndBranch_SS<bfss_opx_bfu_ss,    setuo,  f32>;

multiclass
FP_CompareAndBranch_SD<bfsd_opx opx, PatFrag OpNode, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  let isBranch = 1, isTerminator = 1 in
  def NAME : BRR_RabBranch<opcode_bfsd, opx.value,
                 (outs), (ins GR:$ra, GR:$rb, brtarget:$offset),
                 !strconcat(opx.mnem, "\t$ra, $rb, $offset"),
                 [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;

  let isBranch = 1, isTerminator = 1 in
  def NAME # _EXT : BRR_RabBranch_ext<opcode_bfsd, opx.value,
                 (outs), (ins GR:$ra, GR:$rb, brtarget_ext:$offset),
                 !strconcat(opx.mnem, ".l\t$ra, $rb, $offset"),
                 [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;
}

defm BFO_EQ_SD : FP_CompareAndBranch_SD<bfsd_opx_bfo_eq_sd, setoeq, f64>;
defm BFO_NE_SD : FP_CompareAndBranch_SD<bfsd_opx_bfo_ne_sd, setone, f64>;
defm BFO_LT_SD : FP_CompareAndBranch_SD<bfsd_opx_bfo_lt_sd, setolt, f64>;
defm BFO_LE_SD : FP_CompareAndBranch_SD<bfsd_opx_bfo_le_sd, setole, f64>;
defm BFO_SD    : FP_CompareAndBranch_SD<bfsd_opx_bfo_sd,    seto,   f64>;
defm BFU_EQ_SD : FP_CompareAndBranch_SD<bfsd_opx_bfu_eq_sd, setueq, f64>;
defm BFU_NE_SD : FP_CompareAndBranch_SD<bfsd_opx_bfu_ne_sd, setune, f64>;
defm BFU_LT_SD : FP_CompareAndBranch_SD<bfsd_opx_bfu_lt_sd, setult, f64>;
defm BFU_LE_SD : FP_CompareAndBranch_SD<bfsd_opx_bfu_le_sd, setule, f64>;
defm BFU_SD    : FP_CompareAndBranch_SD<bfsd_opx_bfu_sd,    setuo,  f64>;

multiclass
FP_CompareAndBranch_SQ<bfsq_opx opx, PatFrag OpNode, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  let isBranch = 1, isTerminator = 1 in
  def NAME : BRR_RabBranch<opcode_bfsq, opx.value,
                 (outs), (ins GR:$ra, GR:$rb, brtarget:$offset),
                 !strconcat(opx.mnem, "\t$ra, $rb, $offset"),
                 [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;

  let isBranch = 1, isTerminator = 1 in
  def NAME # _EXT : BRR_RabBranch_ext<opcode_bfsq, opx.value,
                 (outs), (ins GR:$ra, GR:$rb, brtarget_ext:$offset),
                 !strconcat(opx.mnem, ".l\t$ra, $rb, $offset"),
                 [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;
}

defm BFO_EQ_SQ : FP_CompareAndBranch_SQ<bfsq_opx_bfo_eq_sq, setoeq, f128>;
defm BFO_NE_SQ : FP_CompareAndBranch_SQ<bfsq_opx_bfo_ne_sq, setone, f128>;
defm BFO_LT_SQ : FP_CompareAndBranch_SQ<bfsq_opx_bfo_lt_sq, setolt, f128>;
defm BFO_LE_SQ : FP_CompareAndBranch_SQ<bfsq_opx_bfo_le_sq, setole, f128>;
defm BFO_SQ    : FP_CompareAndBranch_SQ<bfsq_opx_bfo_sq,    seto,   f128>;
defm BFU_EQ_SQ : FP_CompareAndBranch_SQ<bfsq_opx_bfu_eq_sq, setueq, f128>;
defm BFU_NE_SQ : FP_CompareAndBranch_SQ<bfsq_opx_bfu_ne_sq, setune, f128>;
defm BFU_LT_SQ : FP_CompareAndBranch_SQ<bfsq_opx_bfu_lt_sq, setult, f128>;
defm BFU_LE_SQ : FP_CompareAndBranch_SQ<bfsq_opx_bfu_le_sq, setule, f128>;
defm BFU_SQ    : FP_CompareAndBranch_SQ<bfsq_opx_bfu_sq,    setuo,  f128>;

multiclass FP_SCALAR_BRANCH_PATTERNS<ValueType Ty>
{
  // greater branch: swap args
  def : Pat<(brcond (i1 (setogt Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("BFO_LT_" # NAME) GR:$rb, GR:$ra, bb:$dst)>;
  def : Pat<(brcond (i1 (setoge Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("BFO_LE_" # NAME) GR:$rb, GR:$ra, bb:$dst)>;
  def : Pat<(brcond (i1 (setugt Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("BFU_LT_" # NAME) GR:$rb, GR:$ra, bb:$dst)>;
  def : Pat<(brcond (i1 (setuge Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("BFU_LE_" # NAME) GR:$rb, GR:$ra, bb:$dst)>;

  // branch: don't care variants
  // fast-math doesn't differ ordered/unordered and uses ordered forms
  def : Pat<(brcond (i1 (seteq Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("BFO_EQ_" # NAME) GR:$ra, GR:$rb, bb:$dst)>;
  def : Pat<(brcond (i1 (setne Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("BFO_NE_" # NAME) GR:$ra, GR:$rb, bb:$dst)>;
  def : Pat<(brcond (i1 (setlt Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("BFO_LT_" # NAME) GR:$ra, GR:$rb, bb:$dst)>;
  def : Pat<(brcond (i1 (setle Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("BFO_LE_" # NAME) GR:$ra, GR:$rb, bb:$dst)>;

  // fast-math greater branch: swap args
  def : Pat<(brcond (i1 (setgt Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("BFO_LT_" # NAME) GR:$rb, GR:$ra, bb:$dst)>;
  def : Pat<(brcond (i1 (setge Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("BFO_LE_" # NAME) GR:$rb, GR:$ra, bb:$dst)>;
}

defm SS : FP_SCALAR_BRANCH_PATTERNS<f32>;
defm SD : FP_SCALAR_BRANCH_PATTERNS<f64>;
defm SQ : FP_SCALAR_BRANCH_PATTERNS<f128>;

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
