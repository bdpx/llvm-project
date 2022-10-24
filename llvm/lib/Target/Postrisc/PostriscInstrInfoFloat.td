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
return CurDAG->getTargetConstant(
  N->getValueAPF().bitcastToAPInt().getZExtValue(), SDLoc(N), MVT::i32);
}]>;

def bitcast_fpimm_to_i64 : SDNodeXForm<fpimm, [{
return CurDAG->getTargetConstant(
  N->getValueAPF().bitcastToAPInt().getZExtValue(), SDLoc(N), MVT::i64);
}]>;

def : Pat<(f16 fpimm:$in), (LDI (bitcast_fpimm_to_i32 $in))>;
def : Pat<(f32 fpimm:$in), (LDI_EXT (bitcast_fpimm_to_i32 $in))>;
def : Pat<(f64 fpimm:$in), (LDI_EXT (bitcast_fpimm_to_i64 $in))>;

//===----------------------------------------------------------------------===//
// float <=> float conversions
//===----------------------------------------------------------------------===//

multiclass MISC_FP_EXTEND<misc_opx opx, string OpcStr, ValueType Tdst, ValueType Tsrc, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : MISC_Rab<opx, (outs GR:$ra), (ins GR:$rb),
     !strconcat(OpcStr, "\t$ra, $rb"), [(set Tdst:$ra, (any_fpextend Tsrc:$rb))], itin>;
}

defm FEXTSH2SS : MISC_FP_EXTEND<misc_opx_fextsh2ss, "fextsh2ss",  f32, f16>;
defm FEXTSH2SD : MISC_FP_EXTEND<misc_opx_fextsh2sd, "fextsh2sd",  f64, f16>;
defm FEXTSH2SQ : MISC_FP_EXTEND<misc_opx_fextsh2sq, "fextsh2sq", f128, f16>;
defm FEXTSS2SD : MISC_FP_EXTEND<misc_opx_fextss2sd, "fextss2sd",  f64, f32>;
defm FEXTSS2SQ : MISC_FP_EXTEND<misc_opx_fextss2sq, "fextss2sq", f128, f32>;
defm FEXTSD2SQ : MISC_FP_EXTEND<misc_opx_fextsd2sq, "fextsd2sq", f128, f64>;

def FCVTSS2SH : MISC_RabRM<misc_opx_fcvtss2sh, "fcvtss2sh">;
def FCVTSD2SH : MISC_RabRM<misc_opx_fcvtsd2sh, "fcvtsd2sh">;
def FCVTSQ2SH : MISC_RabRM<misc_opx_fcvtsq2sh, "fcvtsq2sh">;
def FCVTSD2SS : MISC_RabRM<misc_opx_fcvtsd2ss, "fcvtsd2ss">;
def FCVTSQ2SS : MISC_RabRM<misc_opx_fcvtsq2ss, "fcvtsq2ss">;
def FCVTSQ2SD : MISC_RabRM<misc_opx_fcvtsq2sd, "fcvtsq2sd">;

def : Pat<(f16 (any_fpround  f32:$src)), (FCVTSS2SH GR:$src, rounding_mode_nearesteven.value)>;
def : Pat<(f16 (any_fpround  f64:$src)), (FCVTSD2SH GR:$src, rounding_mode_nearesteven.value)>;
def : Pat<(f16 (any_fpround f128:$src)), (FCVTSQ2SH GR:$src, rounding_mode_nearesteven.value)>;
def : Pat<(f32 (any_fpround  f64:$src)), (FCVTSD2SS GR:$src, rounding_mode_nearesteven.value)>;
def : Pat<(f32 (any_fpround f128:$src)), (FCVTSQ2SS GR:$src, rounding_mode_nearesteven.value)>;
def : Pat<(f64 (any_fpround f128:$src)), (FCVTSQ2SD GR:$src, rounding_mode_nearesteven.value)>;

//===----------------------------------------------------------------------===//
// patterns
//===----------------------------------------------------------------------===//
multiclass FP_BASE_INTRUCTIONS<string T, ValueType Ty>
{
  defm FABS   # NAME : BUILTIN_R2<!cast<misc_opx>("misc_opx_fabs"   # T), !strconcat("fabs",   T), !cast<ClangBuiltin>("int_postrisc_fabs"   # T), Ty, Ty>;
  defm FNABS  # NAME : BUILTIN_R2<!cast<misc_opx>("misc_opx_fnabs"  # T), !strconcat("fnabs",  T), !cast<ClangBuiltin>("int_postrisc_fnabs"  # T), Ty, Ty>;
  defm FNEG   # NAME : BUILTIN_R2<!cast<misc_opx>("misc_opx_fneg"   # T), !strconcat("fneg",   T), !cast<ClangBuiltin>("int_postrisc_fneg"   # T), Ty, Ty>;
  defm FSQRT  # NAME : BUILTIN_R2<!cast<misc_opx>("misc_opx_fsqrt"  # T), !strconcat("fsqrt",  T), !cast<ClangBuiltin>("int_postrisc_fsqrt"  # T), Ty, Ty>;
  defm FRSQRT # NAME : BUILTIN_R2<!cast<misc_opx>("misc_opx_frsqrt" # T), !strconcat("frsqrt", T), !cast<ClangBuiltin>("int_postrisc_frsqrt" # T), Ty, Ty>;

  defm FABSD  # NAME : BUILTIN_R3<!cast<misc_opx>("misc_opx_fabsd"  # T), !strconcat("fabsd",  T), !cast<ClangBuiltin>("int_postrisc_fabsd"  # T), Ty, Ty, Ty>;
  defm FNABSD # NAME : BUILTIN_R3<!cast<misc_opx>("misc_opx_fnabsd" # T), !strconcat("fnabsd", T), !cast<ClangBuiltin>("int_postrisc_fnabsd" # T), Ty, Ty, Ty>;
  defm FADD   # NAME : BUILTIN_R3<!cast<misc_opx>("misc_opx_fadd"   # T), !strconcat("fadd",   T), !cast<ClangBuiltin>("int_postrisc_fadd"   # T), Ty, Ty, Ty>;
  defm FNADD  # NAME : BUILTIN_R3<!cast<misc_opx>("misc_opx_fnadd"  # T), !strconcat("fnadd",  T), !cast<ClangBuiltin>("int_postrisc_fnadd"  # T), Ty, Ty, Ty>;
  defm FSUB   # NAME : BUILTIN_R3<!cast<misc_opx>("misc_opx_fsub"   # T), !strconcat("fsub",   T), !cast<ClangBuiltin>("int_postrisc_fsub"   # T), Ty, Ty, Ty>;
  defm FMUL   # NAME : BUILTIN_R3<!cast<misc_opx>("misc_opx_fmul"   # T), !strconcat("fmul",   T), !cast<ClangBuiltin>("int_postrisc_fmul"   # T), Ty, Ty, Ty>;
  defm FNMUL  # NAME : BUILTIN_R3<!cast<misc_opx>("misc_opx_fnmul"  # T), !strconcat("fnmul",  T), !cast<ClangBuiltin>("int_postrisc_fnmul"  # T), Ty, Ty, Ty>;
  defm FDIV   # NAME : BUILTIN_R3<!cast<misc_opx>("misc_opx_fdiv"   # T), !strconcat("fdiv",   T), !cast<ClangBuiltin>("int_postrisc_fdiv"   # T), Ty, Ty, Ty>;
  defm FAMAX  # NAME : BUILTIN_R3<!cast<misc_opx>("misc_opx_famax"  # T), !strconcat("famax",  T), !cast<ClangBuiltin>("int_postrisc_famax"  # T), Ty, Ty, Ty>;
  defm FAMIN  # NAME : BUILTIN_R3<!cast<misc_opx>("misc_opx_famin"  # T), !strconcat("famin",  T), !cast<ClangBuiltin>("int_postrisc_famin"  # T), Ty, Ty, Ty>;
  defm FMAX   # NAME : BUILTIN_R3<!cast<misc_opx>("misc_opx_fmax"   # T), !strconcat("fmax",   T), !cast<ClangBuiltin>("int_postrisc_fmax"   # T), Ty, Ty, Ty>;
  defm FMIN   # NAME : BUILTIN_R3<!cast<misc_opx>("misc_opx_fmin"   # T), !strconcat("fmin",   T), !cast<ClangBuiltin>("int_postrisc_fmin"   # T), Ty, Ty, Ty>;

  def  FRND   # NAME : MISC_RabRM<!cast<misc_opx>("misc_opx_frnd"   # T), !strconcat("frnd",   T)>;

  defm FMADD  # NAME : BUILTIN_R4<!cast<fused_opx>("fused_opx_fmadd"  # T), !strconcat("fmadd",  T), !cast<ClangBuiltin>("int_postrisc_fmadd"  # T), Ty, Ty, Ty, Ty>;
  defm FMSUB  # NAME : BUILTIN_R4<!cast<fused_opx>("fused_opx_fmsub"  # T), !strconcat("fmsub",  T), !cast<ClangBuiltin>("int_postrisc_fmsub"  # T), Ty, Ty, Ty, Ty>;
  defm FNMADD # NAME : BUILTIN_R4<!cast<fused_opx>("fused_opx_fnmadd" # T), !strconcat("fnmadd", T), !cast<ClangBuiltin>("int_postrisc_fnmadd" # T), Ty, Ty, Ty, Ty>;
  defm FNMSUB # NAME : BUILTIN_R4<!cast<fused_opx>("fused_opx_fnmsub" # T), !strconcat("fnmsub", T), !cast<ClangBuiltin>("int_postrisc_fnmsub" # T), Ty, Ty, Ty, Ty>;
  defm FMERGE # NAME : BUILTIN_R4<!cast<fused_opx>("fused_opx_fmerge" # T), !strconcat("fmerge", T), !cast<ClangBuiltin>("int_postrisc_fmerge" # T), Ty, Ty, Ty, Ty>;

  defm FCMP # NAME # OEQ : MISC_R3<!cast<misc_opx>("misc_opx_fcmp" # T # "oeq"), !strconcat("fcmp", T, "oeq"), setoeq, i1, Ty>;
  defm FCMP # NAME # ONE : MISC_R3<!cast<misc_opx>("misc_opx_fcmp" # T # "one"), !strconcat("fcmp", T, "one"), setone, i1, Ty>;
  defm FCMP # NAME # OLT : MISC_R3<!cast<misc_opx>("misc_opx_fcmp" # T # "olt"), !strconcat("fcmp", T, "olt"), setolt, i1, Ty>;
  defm FCMP # NAME # OLE : MISC_R3<!cast<misc_opx>("misc_opx_fcmp" # T # "ole"), !strconcat("fcmp", T, "ole"), setole, i1, Ty>;
  defm FCMP # NAME # O   : MISC_R3<!cast<misc_opx>("misc_opx_fcmp" # T # "o"  ), !strconcat("fcmp", T, "o"  ), seto,   i1, Ty>;
  defm FCMP # NAME # UEQ : MISC_R3<!cast<misc_opx>("misc_opx_fcmp" # T # "ueq"), !strconcat("fcmp", T, "ueq"), setueq, i1, Ty>;
  defm FCMP # NAME # UNE : MISC_R3<!cast<misc_opx>("misc_opx_fcmp" # T # "une"), !strconcat("fcmp", T, "une"), setune, i1, Ty>;
  defm FCMP # NAME # ULT : MISC_R3<!cast<misc_opx>("misc_opx_fcmp" # T # "ult"), !strconcat("fcmp", T, "ult"), setult, i1, Ty>;
  defm FCMP # NAME # ULE : MISC_R3<!cast<misc_opx>("misc_opx_fcmp" # T # "ule"), !strconcat("fcmp", T, "ule"), setule, i1, Ty>;
  defm FCMP # NAME # UO  : MISC_R3<!cast<misc_opx>("misc_opx_fcmp" # T # "uo" ), !strconcat("fcmp", T, "uo" ), setuo,  i1, Ty>;
}

defm SH : FP_BASE_INTRUCTIONS<"sh", f16>;
defm SS : FP_BASE_INTRUCTIONS<"ss", f32>;
defm SD : FP_BASE_INTRUCTIONS<"sd", f64>;
defm SQ : FP_BASE_INTRUCTIONS<"sq", f128>;

multiclass FP_BASE_CVT_INTRUCTIONS<string T, ValueType Ty>
{
  // float <=> integer conversions
  def FCVT # NAME # 2IW : MISC_RabRM<!cast<misc_opx>("misc_opx_fcvt" # T # "2iw"), !strconcat("fcvt", T, "2iw")>;
  def FCVT # NAME # 2UW : MISC_RabRM<!cast<misc_opx>("misc_opx_fcvt" # T # "2uw"), !strconcat("fcvt", T, "2uw")>;
  def FCVT # NAME # 2ID : MISC_RabRM<!cast<misc_opx>("misc_opx_fcvt" # T # "2id"), !strconcat("fcvt", T, "2id")>;
  def FCVT # NAME # 2UD : MISC_RabRM<!cast<misc_opx>("misc_opx_fcvt" # T # "2ud"), !strconcat("fcvt", T, "2ud")>;
  def FCVT # NAME # 2IQ : MISC_RabRM<!cast<misc_opx>("misc_opx_fcvt" # T # "2iq"), !strconcat("fcvt", T, "2iq")>;
  def FCVT # NAME # 2UQ : MISC_RabRM<!cast<misc_opx>("misc_opx_fcvt" # T # "2uq"), !strconcat("fcvt", T, "2uq")>;

  def FCVTIW2 # NAME : MISC_RabRM<!cast<misc_opx>("misc_opx_fcvtiw2" # T), !strconcat("fcvtiw2", T)>;
  def FCVTUW2 # NAME : MISC_RabRM<!cast<misc_opx>("misc_opx_fcvtuw2" # T), !strconcat("fcvtuw2", T)>;
  def FCVTID2 # NAME : MISC_RabRM<!cast<misc_opx>("misc_opx_fcvtid2" # T), !strconcat("fcvtid2", T)>;
  def FCVTUD2 # NAME : MISC_RabRM<!cast<misc_opx>("misc_opx_fcvtud2" # T), !strconcat("fcvtud2", T)>;
  def FCVTIQ2 # NAME : MISC_RabRM<!cast<misc_opx>("misc_opx_fcvtiq2" # T), !strconcat("fcvtiq2", T)>;
  def FCVTUQ2 # NAME : MISC_RabRM<!cast<misc_opx>("misc_opx_fcvtuq2" # T), !strconcat("fcvtuq2", T)>;

  def : Pat<(i32  (any_fp_to_sint Ty:$src)), (!cast<InstBase>("FCVT" # NAME # "2IW") GR:$src, rounding_mode_nearesteven.value)>;
  def : Pat<(i32  (any_fp_to_uint Ty:$src)), (!cast<InstBase>("FCVT" # NAME # "2UW") GR:$src, rounding_mode_nearesteven.value)>;
  def : Pat<(i64  (any_fp_to_sint Ty:$src)), (!cast<InstBase>("FCVT" # NAME # "2ID") GR:$src, rounding_mode_nearesteven.value)>;
  def : Pat<(i64  (any_fp_to_uint Ty:$src)), (!cast<InstBase>("FCVT" # NAME # "2UD") GR:$src, rounding_mode_nearesteven.value)>;
  def : Pat<(i128 (any_fp_to_sint Ty:$src)), (!cast<InstBase>("FCVT" # NAME # "2IQ") GR:$src, rounding_mode_nearesteven.value)>;
  def : Pat<(i128 (any_fp_to_uint Ty:$src)), (!cast<InstBase>("FCVT" # NAME # "2UQ") GR:$src, rounding_mode_nearesteven.value)>;

  def : Pat<(Ty (any_sint_to_fp  i32:$src)), (!cast<InstBase>("FCVTIW2" # NAME) GR:$src, rounding_mode_nearesteven.value)>;
  def : Pat<(Ty (any_uint_to_fp  i32:$src)), (!cast<InstBase>("FCVTUW2" # NAME) GR:$src, rounding_mode_nearesteven.value)>;
  def : Pat<(Ty (any_sint_to_fp  i64:$src)), (!cast<InstBase>("FCVTID2" # NAME) GR:$src, rounding_mode_nearesteven.value)>;
  def : Pat<(Ty (any_uint_to_fp  i64:$src)), (!cast<InstBase>("FCVTUD2" # NAME) GR:$src, rounding_mode_nearesteven.value)>;
  def : Pat<(Ty (any_sint_to_fp i128:$src)), (!cast<InstBase>("FCVTIQ2" # NAME) GR:$src, rounding_mode_nearesteven.value)>;
  def : Pat<(Ty (any_uint_to_fp i128:$src)), (!cast<InstBase>("FCVTUQ2" # NAME) GR:$src, rounding_mode_nearesteven.value)>;

  // FIXME: i1 to fp => via i32 to fp
  def : Pat<(Ty (any_sint_to_fp  i1:$src)),  (!cast<InstBase>("FCVTIW2" # NAME) GR:$src, rounding_mode_nearesteven.value)>;
  def : Pat<(Ty (any_uint_to_fp  i1:$src)),  (!cast<InstBase>("FCVTUW2" # NAME) GR:$src, rounding_mode_nearesteven.value)>;
}

defm SH : FP_BASE_CVT_INTRUCTIONS<"sh", f16>;
defm SS : FP_BASE_CVT_INTRUCTIONS<"ss", f32>;
defm SD : FP_BASE_CVT_INTRUCTIONS<"sd", f64>;
defm SQ : FP_BASE_CVT_INTRUCTIONS<"sq", f128>;

multiclass FP_SCALAR_PATTERNS<string T, ValueType Ty>
{
  // arg swapping for GT/GE
  def : Pat<(i1 (setogt Ty:$rb, Ty:$rc)), (!cast<InstBase>("FCMP" # NAME # "OLT") GR:$rc, GR:$rb)>;
  def : Pat<(i1 (setoge Ty:$rb, Ty:$rc)), (!cast<InstBase>("FCMP" # NAME # "OLE") GR:$rc, GR:$rb)>;
  def : Pat<(i1 (setugt Ty:$rb, Ty:$rc)), (!cast<InstBase>("FCMP" # NAME # "ULT") GR:$rc, GR:$rb)>;
  def : Pat<(i1 (setuge Ty:$rb, Ty:$rc)), (!cast<InstBase>("FCMP" # NAME # "ULE") GR:$rc, GR:$rb)>;

  // fast-math doesn't differ ordered/unordered => use ordered forms
  def : Pat<(i1 (seteq Ty:$rb, Ty:$rc)), (!cast<InstBase>("FCMP" # NAME # "OEQ") GR:$rb, GR:$rc)>;
  def : Pat<(i1 (setne Ty:$rb, Ty:$rc)), (!cast<InstBase>("FCMP" # NAME # "ONE") GR:$rb, GR:$rc)>;
  def : Pat<(i1 (setlt Ty:$rb, Ty:$rc)), (!cast<InstBase>("FCMP" # NAME # "OLT") GR:$rb, GR:$rc)>;
  def : Pat<(i1 (setle Ty:$rb, Ty:$rc)), (!cast<InstBase>("FCMP" # NAME # "OLE") GR:$rb, GR:$rc)>;
  def : Pat<(i1 (setgt Ty:$rb, Ty:$rc)), (!cast<InstBase>("FCMP" # NAME # "OLT") GR:$rc, GR:$rb)>;
  def : Pat<(i1 (setge Ty:$rb, Ty:$rc)), (!cast<InstBase>("FCMP" # NAME # "OLE") GR:$rc, GR:$rb)>;

  def : Pat<(fneg        Ty:$rb ), (!cast<InstBase>("FNEG"  # NAME) GR:$rb)>;
  def : Pat<(       fabs Ty:$rb ), (!cast<InstBase>("FABS"  # NAME) GR:$rb)>;
  def : Pat<(fneg ( fabs Ty:$rb)), (!cast<InstBase>("FNABS" # NAME) GR:$rb)>;
  def : Pat<(      fsqrt Ty:$rb ), (!cast<InstBase>("FSQRT" # NAME) GR:$rb)>;

  def : Pat<(fadd Ty:$rb, Ty:$rc), (!cast<InstBase>("FADD" # NAME) GR:$rb, GR:$rc)>;
  def : Pat<(fsub Ty:$rb, Ty:$rc), (!cast<InstBase>("FSUB" # NAME) GR:$rb, GR:$rc)>;
  def : Pat<(fmul Ty:$rb, Ty:$rc), (!cast<InstBase>("FMUL" # NAME) GR:$rb, GR:$rc)>;
  def : Pat<(fdiv Ty:$rb, Ty:$rc), (!cast<InstBase>("FDIV" # NAME) GR:$rb, GR:$rc)>;

  def : Pat<(      fabs (fsub       Ty:$rb,        Ty:$rc )), (!cast<InstBase>("FABSD"  # NAME) GR:$rb, GR:$rc)>; // absolute difference
  def : Pat<(fneg (fabs (fsub       Ty:$rb,        Ty:$rc))), (!cast<InstBase>("FNABSD" # NAME) GR:$rb, GR:$rc)>; // negated absolute difference
  def : Pat<(fneg (      fadd       Ty:$rb,        Ty:$rc )), (!cast<InstBase>("FNADD"  # NAME) GR:$rb, GR:$rc)>; // negated sum
  def : Pat<(            fadd (fneg Ty:$rb), (fneg Ty:$rc )), (!cast<InstBase>("FNADD"  # NAME) GR:$rb, GR:$rc)>; // negated sum (as sum of negated)
  def : Pat<(fneg (      fmul       Ty:$rb ,       Ty:$rc )), (!cast<InstBase>("FNMUL"  # NAME) GR:$rb, GR:$rc)>; // negated mul
  def : Pat<(            fmul (fneg Ty:$rb),       Ty:$rc  ), (!cast<InstBase>("FNMUL"  # NAME) GR:$rb, GR:$rc)>; // negated mul (as mul of one negated)
  def : Pat<(            fmul       Ty:$rb , (fneg Ty:$rc )), (!cast<InstBase>("FNMUL"  # NAME) GR:$rb, GR:$rc)>; // negated mul (as mul of one negated)

  def : Pat<(fminnum       Ty:$rb,        Ty:$rc ), (!cast<InstBase>("FMIN"  # NAME) GR:$rb, GR:$rc)>;
  def : Pat<(fmaxnum       Ty:$rb,        Ty:$rc ), (!cast<InstBase>("FMAX"  # NAME) GR:$rb, GR:$rc)>;
  def : Pat<(fminnum (fabs Ty:$rb), (fabs Ty:$rc)), (!cast<InstBase>("FAMIN" # NAME) GR:$rb, GR:$rc)>;
  def : Pat<(fmaxnum (fabs Ty:$rb), (fabs Ty:$rc)), (!cast<InstBase>("FAMAX" # NAME) GR:$rb, GR:$rc)>;

  def : Pat<(      any_fma       Ty:$rb,       Ty:$rc,        Ty:$rd),  (!cast<InstBase>("FMADD"  # NAME) GR:$rb, GR:$rc, GR:$rd)>; //    x  *  y  +  z
  def : Pat<(      any_fma       Ty:$rb,       Ty:$rc,  (fneg Ty:$rd)), (!cast<InstBase>("FMSUB"  # NAME) GR:$rb, GR:$rc, GR:$rd)>; //    x  *  y  -  z
  def : Pat<(      any_fma (fneg Ty:$rb),      Ty:$rc,        Ty:$rd),  (!cast<InstBase>("FNMADD" # NAME) GR:$rb, GR:$rc, GR:$rd)>; //   -x  *  y  +  z
  def : Pat<(      any_fma       Ty:$rb, (fneg Ty:$rc),       Ty:$rd),  (!cast<InstBase>("FNMADD" # NAME) GR:$rb, GR:$rc, GR:$rd)>; //    x  * -y  +  z
  def : Pat<(      any_fma (fneg Ty:$rb),      Ty:$rc,  (fneg Ty:$rd)), (!cast<InstBase>("FNMSUB" # NAME) GR:$rb, GR:$rc, GR:$rd)>; //   -x  *  y  -  z
  def : Pat<(      any_fma       Ty:$rb, (fneg Ty:$rc), (fneg Ty:$rd)), (!cast<InstBase>("FNMSUB" # NAME) GR:$rb, GR:$rc, GR:$rd)>; //   -x  *  y  -  z
  def : Pat<(fneg (any_fma       Ty:$rb,       Ty:$rc,        Ty:$rd)), (!cast<InstBase>("FNMSUB" # NAME) GR:$rb, GR:$rc, GR:$rd)>; // -( x  *  y  +  z)

  def : Pat<(fcopysign Ty:$rb, Ty:$rc), (!cast<InstBase>("FMERGE" # NAME) GR:$rc, GR:$rb, GR:$rb)>;

  def : Pat<(any_frint      Ty:$rb), (!cast<InstBase>("FRND" # NAME) GR:$rb, rounding_mode_dynamic.value    )>;  // frint rounds according to the current mode
  def : Pat<(any_fnearbyint Ty:$rb), (!cast<InstBase>("FRND" # NAME) GR:$rb, rounding_mode_dynamic.value    )>;  // fnearbyint is like frint
  def : Pat<(any_fround     Ty:$rb), (!cast<InstBase>("FRND" # NAME) GR:$rb, rounding_mode_nearesteven.value)>;  // round towards nearest with ties away from zero.
  def : Pat<(any_ffloor     Ty:$rb), (!cast<InstBase>("FRND" # NAME) GR:$rb, rounding_mode_downward.value   )>;  // round towards -inf.
  def : Pat<(any_fceil      Ty:$rb), (!cast<InstBase>("FRND" # NAME) GR:$rb, rounding_mode_upward.value     )>;  // round towards +inf.
  def : Pat<(any_ftrunc     Ty:$rb), (!cast<InstBase>("FRND" # NAME) GR:$rb, rounding_mode_towardzero.value )>;  // round towards zero.

  def : InstAlias<!strconcat("frnd", T, ".dyn\t$rb, $rc"),   (!cast<InstBase>("FRND" # NAME) GR:$rb, GR:$rc, rounding_mode_dynamic.value)>;
  def : InstAlias<!strconcat("frnd", T, ".even\t$rb, $rc"),  (!cast<InstBase>("FRND" # NAME) GR:$rb, GR:$rc, rounding_mode_nearesteven.value)>;
  def : InstAlias<!strconcat("frnd", T, ".floor\t$rb, $rc"), (!cast<InstBase>("FRND" # NAME) GR:$rb, GR:$rc, rounding_mode_downward.value)>;
  def : InstAlias<!strconcat("frnd", T, ".ceil\t$rb, $rc"),  (!cast<InstBase>("FRND" # NAME) GR:$rb, GR:$rc, rounding_mode_upward.value)>;
  def : InstAlias<!strconcat("frnd", T, ".trunc\t$rb, $rc"), (!cast<InstBase>("FRND" # NAME) GR:$rb, GR:$rc, rounding_mode_towardzero.value)>;
}

defm SH : FP_SCALAR_PATTERNS<"sh", f16>;
defm SS : FP_SCALAR_PATTERNS<"ss", f32>;
defm SD : FP_SCALAR_PATTERNS<"sd", f64>;
defm SQ : FP_SCALAR_PATTERNS<"sq", f128>;

//===----------------------------------------------------------------------===//
// fp branches
//===----------------------------------------------------------------------===//
multiclass FP_CompareAndBranch<opcode_opx opcode, bits<4> opxCode, string OpcStr, PatFrag OpNode, ValueType Ty,
  InstrItinClass itin = IIC_iu_instr>
{
  let isBranch = 1, isTerminator = 1 in
  def NAME : BRR_RabBranch<opcode, opxCode,
                 (outs), (ins GR:$ra, GR:$rb, brtarget:$offset),
                 !strconcat(OpcStr, "\t$ra, $rb, $offset"),
                 [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;

  let isBranch = 1, isTerminator = 1 in
  def NAME # _EXT : BRR_RabBranch_ext<opcode, opxCode,
                 (outs), (ins GR:$ra, GR:$rb, brtarget_ext:$offset),
                 !strconcat(OpcStr, ".l\t$ra, $rb, $offset"),
                 [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;
}

defm BFSSOEQ : FP_CompareAndBranch<opcode_bfss, bfss_opx_bfssoeq.value, "bfssoeq", setoeq, f32>;
defm BFSSONE : FP_CompareAndBranch<opcode_bfss, bfss_opx_bfssone.value, "bfssone", setone, f32>;
defm BFSSOLT : FP_CompareAndBranch<opcode_bfss, bfss_opx_bfssolt.value, "bfssolt", setolt, f32>;
defm BFSSOLE : FP_CompareAndBranch<opcode_bfss, bfss_opx_bfssole.value, "bfssole", setole, f32>;
defm BFSSO   : FP_CompareAndBranch<opcode_bfss, bfss_opx_bfsso.value,   "bfsso",   seto,   f32>;
defm BFSSUEQ : FP_CompareAndBranch<opcode_bfss, bfss_opx_bfssueq.value, "bfssueq", setueq, f32>;
defm BFSSUNE : FP_CompareAndBranch<opcode_bfss, bfss_opx_bfssune.value, "bfssune", setune, f32>;
defm BFSSULT : FP_CompareAndBranch<opcode_bfss, bfss_opx_bfssult.value, "bfssult", setult, f32>;
defm BFSSULE : FP_CompareAndBranch<opcode_bfss, bfss_opx_bfssule.value, "bfssule", setule, f32>;
defm BFSSUO  : FP_CompareAndBranch<opcode_bfss, bfss_opx_bfssuo.value,  "bfssuo",  setuo,  f32>;

defm BFSDOEQ : FP_CompareAndBranch<opcode_bfsd, bfsd_opx_bfsdoeq.value, "bfsdoeq", setoeq, f64>;
defm BFSDONE : FP_CompareAndBranch<opcode_bfsd, bfsd_opx_bfsdone.value, "bfsdone", setone, f64>;
defm BFSDOLT : FP_CompareAndBranch<opcode_bfsd, bfsd_opx_bfsdolt.value, "bfsdolt", setolt, f64>;
defm BFSDOLE : FP_CompareAndBranch<opcode_bfsd, bfsd_opx_bfsdole.value, "bfsdole", setole, f64>;
defm BFSDO   : FP_CompareAndBranch<opcode_bfsd, bfsd_opx_bfsdo.value,   "bfsdo",   seto,   f64>;
defm BFSDUEQ : FP_CompareAndBranch<opcode_bfsd, bfsd_opx_bfsdueq.value, "bfsdueq", setueq, f64>;
defm BFSDUNE : FP_CompareAndBranch<opcode_bfsd, bfsd_opx_bfsdune.value, "bfsdune", setune, f64>;
defm BFSDULT : FP_CompareAndBranch<opcode_bfsd, bfsd_opx_bfsdult.value, "bfsdult", setult, f64>;
defm BFSDULE : FP_CompareAndBranch<opcode_bfsd, bfsd_opx_bfsdule.value, "bfsdule", setule, f64>;
defm BFSDUO  : FP_CompareAndBranch<opcode_bfsd, bfsd_opx_bfsduo.value,  "bfsduo",  setuo,  f64>;

defm BFSQOEQ : FP_CompareAndBranch<opcode_bfsq, bfsq_opx_bfsqoeq.value, "bfsqoeq", setoeq, f128>;
defm BFSQONE : FP_CompareAndBranch<opcode_bfsq, bfsq_opx_bfsqone.value, "bfsqone", setone, f128>;
defm BFSQOLT : FP_CompareAndBranch<opcode_bfsq, bfsq_opx_bfsqolt.value, "bfsqolt", setolt, f128>;
defm BFSQOLE : FP_CompareAndBranch<opcode_bfsq, bfsq_opx_bfsqole.value, "bfsqole", setole, f128>;
defm BFSQO   : FP_CompareAndBranch<opcode_bfsq, bfsq_opx_bfsqo.value,   "bfsqo",   seto,   f128>;
defm BFSQUEQ : FP_CompareAndBranch<opcode_bfsq, bfsq_opx_bfsqueq.value, "bfsqueq", setueq, f128>;
defm BFSQUNE : FP_CompareAndBranch<opcode_bfsq, bfsq_opx_bfsqune.value, "bfsqune", setune, f128>;
defm BFSQULT : FP_CompareAndBranch<opcode_bfsq, bfsq_opx_bfsqult.value, "bfsqult", setult, f128>;
defm BFSQULE : FP_CompareAndBranch<opcode_bfsq, bfsq_opx_bfsqule.value, "bfsqule", setule, f128>;
defm BFSQUO  : FP_CompareAndBranch<opcode_bfsq, bfsq_opx_bfsquo.value,  "bfsquo",  setuo,  f128>;

multiclass FP_SCALAR_BRANCH_PATTERNS<ValueType Ty>
{
  // greater branch: swap args
  def : Pat<(brcond (i1 (setogt Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("BF" # NAME # "OLT") GR:$rb, GR:$ra, bb:$dst)>;
  def : Pat<(brcond (i1 (setoge Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("BF" # NAME # "OLE") GR:$rb, GR:$ra, bb:$dst)>;
  def : Pat<(brcond (i1 (setugt Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("BF" # NAME # "ULT") GR:$rb, GR:$ra, bb:$dst)>;
  def : Pat<(brcond (i1 (setuge Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("BF" # NAME # "ULE") GR:$rb, GR:$ra, bb:$dst)>;

  // branch: don't care variants
  // fast-math doesn't differ ordered/unordered and uses ordered forms
  def : Pat<(brcond (i1 (seteq Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("BF" # NAME # "OEQ") GR:$ra, GR:$rb, bb:$dst)>;
  def : Pat<(brcond (i1 (setne Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("BF" # NAME # "ONE") GR:$ra, GR:$rb, bb:$dst)>;
  def : Pat<(brcond (i1 (setlt Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("BF" # NAME # "OLT") GR:$ra, GR:$rb, bb:$dst)>;
  def : Pat<(brcond (i1 (setle Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("BF" # NAME # "OLE") GR:$ra, GR:$rb, bb:$dst)>;
  // fast-math greater branch: swap args
  def : Pat<(brcond (i1 (setgt Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("BF" # NAME # "OLT") GR:$rb, GR:$ra, bb:$dst)>;
  def : Pat<(brcond (i1 (setge Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("BF" # NAME # "OLE") GR:$rb, GR:$ra, bb:$dst)>;
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
