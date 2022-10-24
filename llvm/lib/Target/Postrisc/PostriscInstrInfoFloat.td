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

//===----------------------------------------------------------------------===//
// FMA instructions
//===----------------------------------------------------------------------===//
def FMADDH  : FORMAT_FMAH_RM<opcode_fmaddh,   int_postrisc_fmaddh,   f16, f16, f16, f16>;
def FMSUBH  : FORMAT_FMAH_RM<opcode_fmsubh,   int_postrisc_fmsubh,   f16, f16, f16, f16>;
def FNMADDH : FORMAT_FMAH_RM<opcode_fnmaddh,  int_postrisc_fnmaddh,  f16, f16, f16, f16>;
def FNMSUBH : FORMAT_FMAH_RM<opcode_fnmsubh,  int_postrisc_fnmsubh,  f16, f16, f16, f16>;

def FMADDS  : FORMAT_FMAS_RM<opcode_fmadds,   int_postrisc_fmadds,   f32, f32, f32, f32>;
def FMSUBS  : FORMAT_FMAS_RM<opcode_fmsubs,   int_postrisc_fmsubs,   f32, f32, f32, f32>;
def FNMADDS : FORMAT_FMAS_RM<opcode_fnmadds,  int_postrisc_fnmadds,  f32, f32, f32, f32>;
def FNMSUBS : FORMAT_FMAS_RM<opcode_fnmsubs,  int_postrisc_fnmsubs,  f32, f32, f32, f32>;

def FMADDD  : FORMAT_FMAD_RM<opcode_fmaddd,   int_postrisc_fmaddd,   f64, f64, f64, f64>;
def FMSUBD  : FORMAT_FMAD_RM<opcode_fmsubd,   int_postrisc_fmsubd,   f64, f64, f64, f64>;
def FNMADDD : FORMAT_FMAD_RM<opcode_fnmaddd,  int_postrisc_fnmaddd,  f64, f64, f64, f64>;
def FNMSUBD : FORMAT_FMAD_RM<opcode_fnmsubd,  int_postrisc_fnmsubd,  f64, f64, f64, f64>;

def FMADDQ  : FORMAT_FMAQ_RM<opcode_fmaddq,  int_postrisc_fmaddq,   f128, f128, f128, f128>;
def FMSUBQ  : FORMAT_FMAQ_RM<opcode_fmsubq,  int_postrisc_fmsubq,   f128, f128, f128, f128>;
def FNMADDQ : FORMAT_FMAQ_RM<opcode_fnmaddq, int_postrisc_fnmaddq,  f128, f128, f128, f128>;
def FNMSUBQ : FORMAT_FMAQ_RM<opcode_fnmsubq, int_postrisc_fnmsubq,  f128, f128, f128, f128>;

def VFMADDH     : FORMAT_FMAH_RM<opcode_vfmaddh,    int_postrisc_vfmaddh,    v8f16, v8f16, v8f16, v8f16>;
def VFMSUBH     : FORMAT_FMAH_RM<opcode_vfmsubh,    int_postrisc_vfmsubh,    v8f16, v8f16, v8f16, v8f16>;
def VFNMADDH    : FORMAT_FMAH_RM<opcode_vfnmaddh,   int_postrisc_vfnmaddh,   v8f16, v8f16, v8f16, v8f16>;
def VFNMSUBH    : FORMAT_FMAH_RM<opcode_vfnmsubh,   int_postrisc_vfnmsubh,   v8f16, v8f16, v8f16, v8f16>;
def VFMADD_ALTH : FORMAT_FMAH_RM<opcode_vfmaddsubh, int_postrisc_vfmaddsubh, v8f16, v8f16, v8f16, v8f16>;
def VFMSUB_ALTH : FORMAT_FMAH_RM<opcode_vfmsubaddh, int_postrisc_vfmsubaddh, v8f16, v8f16, v8f16, v8f16>;

def VFMADDS     : FORMAT_FMAS_RM<opcode_vfmadds,    int_postrisc_vfmadds,    v4f32, v4f32, v4f32, v4f32>;
def VFMSUBS     : FORMAT_FMAS_RM<opcode_vfmsubs,    int_postrisc_vfmsubs,    v4f32, v4f32, v4f32, v4f32>;
def VFNMADDS    : FORMAT_FMAS_RM<opcode_vfnmadds,   int_postrisc_vfnmadds,   v4f32, v4f32, v4f32, v4f32>;
def VFNMSUBS    : FORMAT_FMAS_RM<opcode_vfnmsubs,   int_postrisc_vfnmsubs,   v4f32, v4f32, v4f32, v4f32>;
def VFMADD_ALTS : FORMAT_FMAS_RM<opcode_vfmaddsubs, int_postrisc_vfmaddsubs, v4f32, v4f32, v4f32, v4f32>;
def VFMSUB_ALTS : FORMAT_FMAS_RM<opcode_vfmsubadds, int_postrisc_vfmsubadds, v4f32, v4f32, v4f32, v4f32>;

def VFMADDD     : FORMAT_FMAD_RM<opcode_vfmaddd,    int_postrisc_vfmaddd,    v2f64, v2f64, v2f64, v2f64>;
def VFMSUBD     : FORMAT_FMAD_RM<opcode_vfmsubd,    int_postrisc_vfmsubd,    v2f64, v2f64, v2f64, v2f64>;
def VFNMADDD    : FORMAT_FMAD_RM<opcode_vfnmaddd,   int_postrisc_vfnmaddd,   v2f64, v2f64, v2f64, v2f64>;
def VFNMSUBD    : FORMAT_FMAD_RM<opcode_vfnmsubd,   int_postrisc_vfnmsubd,   v2f64, v2f64, v2f64, v2f64>;
def VFMADD_ALTD : FORMAT_FMAD_RM<opcode_vfmaddsubd, int_postrisc_vfmaddsubd, v2f64, v2f64, v2f64, v2f64>;
def VFMSUB_ALTD : FORMAT_FMAD_RM<opcode_vfmsubaddd, int_postrisc_vfmsubaddd, v2f64, v2f64, v2f64, v2f64>;

multiclass FusedPatterns<InstBase MADD, InstBase MSUB, InstBase NMADD, InstBase NMSUB, ValueType Ty>
{
  def : Pat<(      any_fma       Ty:$rb,       Ty:$rc,        Ty:$rd ), (MADD  GR:$rb, GR:$rc, GR:$rd, rounding_mode_dyn.value)>; //    x  *  y  +  z
  def : Pat<(      any_fma       Ty:$rb,       Ty:$rc,  (fneg Ty:$rd)), (MSUB  GR:$rb, GR:$rc, GR:$rd, rounding_mode_dyn.value)>; //    x  *  y  -  z
  def : Pat<(      any_fma (fneg Ty:$rb),      Ty:$rc,        Ty:$rd ), (NMADD GR:$rb, GR:$rc, GR:$rd, rounding_mode_dyn.value)>; //   -x  *  y  +  z
  def : Pat<(      any_fma       Ty:$rb, (fneg Ty:$rc),       Ty:$rd ), (NMADD GR:$rb, GR:$rc, GR:$rd, rounding_mode_dyn.value)>; //    x  * -y  +  z
  def : Pat<(      any_fma (fneg Ty:$rb),      Ty:$rc,  (fneg Ty:$rd)), (NMSUB GR:$rb, GR:$rc, GR:$rd, rounding_mode_dyn.value)>; //   -x  *  y  -  z
  def : Pat<(      any_fma       Ty:$rb, (fneg Ty:$rc), (fneg Ty:$rd)), (NMSUB GR:$rb, GR:$rc, GR:$rd, rounding_mode_dyn.value)>; //   -x  *  y  -  z
  def : Pat<(fneg (any_fma       Ty:$rb,       Ty:$rc,        Ty:$rd)), (NMSUB GR:$rb, GR:$rc, GR:$rd, rounding_mode_dyn.value)>; // -( x  *  y  +  z)
}

defm : FusedPatterns<FMADDH, FMSUBH, FNMADDH, FNMSUBH, f16>;
defm : FusedPatterns<FMADDS, FMSUBS, FNMADDS, FNMSUBS, f32>;
defm : FusedPatterns<FMADDD, FMSUBD, FNMADDD, FNMSUBD, f64>;
defm : FusedPatterns<FMADDQ, FMSUBQ, FNMADDQ, FNMSUBQ, f128>;

defm : FusedPatterns<VFMADDH, VFMSUBH, VFNMADDH, VFNMSUBH, v8f16>;
defm : FusedPatterns<VFMADDS, VFMSUBS, VFNMADDS, VFNMSUBS, v4f32>;
defm : FusedPatterns<VFMADDD, VFMSUBD, VFNMADDD, VFNMSUBD, v2f64>;

//===----------------------------------------------------------------------===//
// fp immediates
//===----------------------------------------------------------------------===//

def fpimm0 : PatLeaf<(fpimm), [{ return N->isPosZero(); }]>;

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
     !strconcat(opx.mnem, " $ra, $rb"), [(set Tdst:$ra, (any_fpextend Tsrc:$rb))], itin>;
}

defm FHTOS : MISC_FP_EXTEND<opcode_fhtos, f32,  f16>;
defm FHTOD : MISC_FP_EXTEND<opcode_fhtod, f64,  f16>;
defm FHTOQ : MISC_FP_EXTEND<opcode_fhtoq, f128, f16>;
defm FSTOD : MISC_FP_EXTEND<opcode_fstod, f64,  f32>;
defm FSTOQ : MISC_FP_EXTEND<opcode_fstoq, f128, f32>;
defm FDTOQ : MISC_FP_EXTEND<opcode_fdtoq, f128, f64>;

// FXX (wider) to FX (narrow) conversion
def FSTOH : FORMAT_R2_RM<opcode_fstoh, int_postrisc_fstoh, f16, f32>;
def FDTOH : FORMAT_R2_RM<opcode_fdtoh, int_postrisc_fdtoh, f16, f64>;
def FDTOS : FORMAT_R2_RM<opcode_fdtos, int_postrisc_fdtos, f32, f64>;
def FQTOH : FORMAT_R2_RM<opcode_fqtoh, int_postrisc_fqtoh, f16, f128>;
def FQTOS : FORMAT_R2_RM<opcode_fqtos, int_postrisc_fqtos, f32, f128>;
def FQTOD : FORMAT_R2_RM<opcode_fqtod, int_postrisc_fqtod, f64, f128>;

// shrink-conversion by default - using dynamic rounding
def : Pat<(f16 (any_fpround  f32:$rb)), (FSTOH GR:$rb, rounding_mode_dyn.value)>;
def : Pat<(f16 (any_fpround  f64:$rb)), (FDTOH GR:$rb, rounding_mode_dyn.value)>;
def : Pat<(f32 (any_fpround  f64:$rb)), (FDTOS GR:$rb, rounding_mode_dyn.value)>;
def : Pat<(f16 (any_fpround f128:$rb)), (FQTOH GR:$rb, rounding_mode_dyn.value)>;
def : Pat<(f32 (any_fpround f128:$rb)), (FQTOS GR:$rb, rounding_mode_dyn.value)>;
def : Pat<(f64 (any_fpround f128:$rb)), (FQTOD GR:$rb, rounding_mode_dyn.value)>;

// TODO: fptrunc_round

//===----------------------------------------------------------------------===//
// unary (RM)
//===----------------------------------------------------------------------===//
def FSQRTH  : FORMAT_R2_RM<opcode_fsqrth,  int_postrisc_fsqrth,  f16, f16>;
def FSQRTS  : FORMAT_R2_RM<opcode_fsqrts,  int_postrisc_fsqrts,  f32, f32>;
def FSQRTD  : FORMAT_R2_RM<opcode_fsqrtd,  int_postrisc_fsqrtd,  f64, f64>;
def FSQRTQ  : FORMAT_R2_RM<opcode_fsqrtq,  int_postrisc_fsqrtq,  f128, f128>;

def FRSQRTH : FORMAT_R2_RM<opcode_frsqrth, int_postrisc_frsqrth, f16, f16>;
def FRSQRTS : FORMAT_R2_RM<opcode_frsqrts, int_postrisc_frsqrts, f32, f32>;
def FRSQRTD : FORMAT_R2_RM<opcode_frsqrtd, int_postrisc_frsqrtd, f64, f64>;
def FRSQRTQ : FORMAT_R2_RM<opcode_frsqrtq, int_postrisc_frsqrtq, f128, f128>;

def VFSQRTH  : FORMAT_R2_RM<opcode_vfsqrth,  int_postrisc_vfsqrth,  v8f16, v8f16>;
def VFSQRTS  : FORMAT_R2_RM<opcode_vfsqrts,  int_postrisc_vfsqrts,  v4f32, v4f32>;
def VFSQRTD  : FORMAT_R2_RM<opcode_vfsqrtd,  int_postrisc_vfsqrtd,  v2f64, v2f64>;

def VFRSQRTH : FORMAT_R2_RM<opcode_vfrsqrth, int_postrisc_vfrsqrth, v8f16, v8f16>;
def VFRSQRTS : FORMAT_R2_RM<opcode_vfrsqrts, int_postrisc_vfrsqrts, v4f32, v4f32>;
def VFRSQRTD : FORMAT_R2_RM<opcode_vfrsqrtd, int_postrisc_vfrsqrtd, v2f64, v2f64>;

//===----------------------------------------------------------------------===//
// __builtin_signbit: right shift for all except f16 (double shift)
// FIXME: clang never produces fgetsign
//===----------------------------------------------------------------------===//
def : Pat<(i32 (fgetsign f16:$rb)), (SLSRLW GR:$rb, (i32 16), (i32 31))>;
def : Pat<(i32 (fgetsign f32:$rb)), (SRLIW GR:$rb, (i32 31))>;
def : Pat<(i32 (fgetsign f64:$rb)), (SRLID GR:$rb, (i32 63))>;
def : Pat<(i32 (fgetsign f64:$rb)), (SRLIQ GR:$rb, (i32 127))>;

//===----------------------------------------------------------------------===//
// rounding
//===----------------------------------------------------------------------===//
def FRNDH : FORMAT_R2_RM<opcode_frndh,  int_postrisc_frndh, f16,  f16>;
def FRNDS : FORMAT_R2_RM<opcode_frnds,  int_postrisc_frnds, f32,  f32>;
def FRNDD : FORMAT_R2_RM<opcode_frndd,  int_postrisc_frndd, f64,  f64>;
def FRNDQ : FORMAT_R2_RM<opcode_frndq,  int_postrisc_frndq, f128, f128>;

def VFRNDH : FORMAT_R2_RM<opcode_vfrndh, int_postrisc_vfrndh, v8f16, v8f16>;
def VFRNDS : FORMAT_R2_RM<opcode_vfrnds, int_postrisc_vfrnds, v4f32, v4f32>;
def VFRNDD : FORMAT_R2_RM<opcode_vfrndd, int_postrisc_vfrndd, v2f64, v2f64>;

def FRNDXH : FORMAT_R2_RM<opcode_frndxh,  int_postrisc_frndxh, f16,  f16>;
def FRNDXS : FORMAT_R2_RM<opcode_frndxs,  int_postrisc_frndxs, f32,  f32>;
def FRNDXD : FORMAT_R2_RM<opcode_frndxd,  int_postrisc_frndxd, f64,  f64>;
def FRNDXQ : FORMAT_R2_RM<opcode_frndxq,  int_postrisc_frndxq, f128, f128>;

def VFRNDXH : FORMAT_R2_RM<opcode_vfrndxh, int_postrisc_vfrndxh, v8f16, v8f16>;
def VFRNDXS : FORMAT_R2_RM<opcode_vfrndxs, int_postrisc_vfrndxs, v4f32, v4f32>;
def VFRNDXD : FORMAT_R2_RM<opcode_vfrndxd, int_postrisc_vfrndxd, v2f64, v2f64>;

multiclass RoundingPatterns<InstBase Inst, InstBase InstX, ValueType Ty>
{
  def : Pat<(Ty (any_froundeven Ty:$rb)), (Inst GR:$rb, rounding_mode_rne.value)>; // to nearest even
  def : Pat<(Ty (any_ffloor     Ty:$rb)), (Inst GR:$rb, rounding_mode_rdn.value)>; // towards -inf.
  def : Pat<(Ty (any_fceil      Ty:$rb)), (Inst GR:$rb, rounding_mode_rup.value)>; // upward towards +inf
  def : Pat<(Ty (any_ftrunc     Ty:$rb)), (Inst GR:$rb, rounding_mode_rtz.value)>; // to zero
  def : Pat<(Ty (any_fround     Ty:$rb)), (Inst GR:$rb, rounding_mode_rmm.value)>; // to nearest with ties away from zero.
  def : Pat<(Ty (any_fnearbyint Ty:$rb)), (Inst GR:$rb, rounding_mode_dyn.value)>; // dynamic

  def : Pat<(Ty (any_frint Ty:$rb)), (InstX GR:$rb, rounding_mode_dyn.value)>;  // frint rounds according to the current mode
}

defm : RoundingPatterns<FRNDH, FRNDXH, f16>;
defm : RoundingPatterns<FRNDS, FRNDXS, f32>;
defm : RoundingPatterns<FRNDD, FRNDXD, f64>;
defm : RoundingPatterns<FRNDQ, FRNDXQ, f128>;

defm : RoundingPatterns<VFRNDH, VFRNDXH, v8f16>;
defm : RoundingPatterns<VFRNDS, VFRNDXS, v4f32>;
defm : RoundingPatterns<VFRNDD, VFRNDXD, v2f64>;

//===----------------------------------------------------------------------===//
// binary (RM)
//===----------------------------------------------------------------------===//
def FABDH   : FORMAT_R3_RM<opcode_fabdh,   int_postrisc_fabdh,  f16, f16, f16>;
def FNABDH  : FORMAT_R3_RM<opcode_fnabdh,  int_postrisc_fnabdh, f16, f16, f16>;
def FADDH   : FORMAT_R3_RM<opcode_faddh,   int_postrisc_faddh,  f16, f16, f16>;
def FNADDH  : FORMAT_R3_RM<opcode_fnaddh,  int_postrisc_fnaddh, f16, f16, f16>;
def FSUBH   : FORMAT_R3_RM<opcode_fsubh,   int_postrisc_fsubh,  f16, f16, f16>;
def FMULH   : FORMAT_R3_RM<opcode_fmulh,   int_postrisc_fmulh,  f16, f16, f16>;
def FNMULH  : FORMAT_R3_RM<opcode_fnmulh,  int_postrisc_fnmulh, f16, f16, f16>;
def FDIVH   : FORMAT_R3_RM<opcode_fdivh,   int_postrisc_fdivh,  f16, f16, f16>;

def FABDS   : FORMAT_R3_RM<opcode_fabds,   int_postrisc_fabds,  f32, f32, f32>;
def FNABDS  : FORMAT_R3_RM<opcode_fnabds,  int_postrisc_fnabds, f32, f32, f32>;
def FADDS   : FORMAT_R3_RM<opcode_fadds,   int_postrisc_fadds,  f32, f32, f32>;
def FNADDS  : FORMAT_R3_RM<opcode_fnadds,  int_postrisc_fnadds, f32, f32, f32>;
def FSUBS   : FORMAT_R3_RM<opcode_fsubs,   int_postrisc_fsubs,  f32, f32, f32>;
def FMULS   : FORMAT_R3_RM<opcode_fmuls,   int_postrisc_fmuls,  f32, f32, f32>;
def FNMULS  : FORMAT_R3_RM<opcode_fnmuls,  int_postrisc_fnmuls, f32, f32, f32>;
def FDIVS   : FORMAT_R3_RM<opcode_fdivs,   int_postrisc_fdivs,  f32, f32, f32>;

def FABDD   : FORMAT_R3_RM<opcode_fabdd,   int_postrisc_fabdd,  f64, f64, f64>;
def FNABDD  : FORMAT_R3_RM<opcode_fnabdd,  int_postrisc_fnabdd, f64, f64, f64>;
def FADDD   : FORMAT_R3_RM<opcode_faddd,   int_postrisc_faddd,  f64, f64, f64>;
def FNADDD  : FORMAT_R3_RM<opcode_fnaddd,  int_postrisc_fnaddd, f64, f64, f64>;
def FSUBD   : FORMAT_R3_RM<opcode_fsubd,   int_postrisc_fsubd,  f64, f64, f64>;
def FMULD   : FORMAT_R3_RM<opcode_fmuld,   int_postrisc_fmuld,  f64, f64, f64>;
def FNMULD  : FORMAT_R3_RM<opcode_fnmuld,  int_postrisc_fnmuld, f64, f64, f64>;
def FDIVD   : FORMAT_R3_RM<opcode_fdivd,   int_postrisc_fdivd,  f64, f64, f64>;

def FABDQ  : FORMAT_R3_RM<opcode_fabdq,  int_postrisc_fabdq,  f128, f128, f128>;
def FNABDQ : FORMAT_R3_RM<opcode_fnabdq, int_postrisc_fnabdq, f128, f128, f128>;
def FADDQ  : FORMAT_R3_RM<opcode_faddq,  int_postrisc_faddq,  f128, f128, f128>;
def FNADDQ : FORMAT_R3_RM<opcode_fnaddq, int_postrisc_fnaddq, f128, f128, f128>;
def FSUBQ  : FORMAT_R3_RM<opcode_fsubq,  int_postrisc_fsubq,  f128, f128, f128>;
def FMULQ  : FORMAT_R3_RM<opcode_fmulq,  int_postrisc_fmulq,  f128, f128, f128>;
def FNMULQ : FORMAT_R3_RM<opcode_fnmulq, int_postrisc_fnmulq, f128, f128, f128>;
def FDIVQ  : FORMAT_R3_RM<opcode_fdivq,  int_postrisc_fdivq,  f128, f128, f128>;

def VFABDH    : FORMAT_R3_RM<opcode_vfabdh,    int_postrisc_vfabdh,    v8f16, v8f16, v8f16>;
def VFNABDH   : FORMAT_R3_RM<opcode_vfnabdh,   int_postrisc_vfnabdh,   v8f16, v8f16, v8f16>;
def VFADDH    : FORMAT_R3_RM<opcode_vfaddh,    int_postrisc_vfaddh,    v8f16, v8f16, v8f16>;
def VFNADDH   : FORMAT_R3_RM<opcode_vfnaddh,   int_postrisc_vfnaddh,   v8f16, v8f16, v8f16>;
def VFSUBH    : FORMAT_R3_RM<opcode_vfsubh,    int_postrisc_vfsubh,    v8f16, v8f16, v8f16>;
def VFMULH    : FORMAT_R3_RM<opcode_vfmulh,    int_postrisc_vfmulh,    v8f16, v8f16, v8f16>;
def VFNMULH   : FORMAT_R3_RM<opcode_vfnmulh,   int_postrisc_vfnmulh,   v8f16, v8f16, v8f16>;
def VFDIVH    : FORMAT_R3_RM<opcode_vfdivh,    int_postrisc_vfdivh,    v8f16, v8f16, v8f16>;
def VFADDSUBH : FORMAT_R3_RM<opcode_vfaddsubh, int_postrisc_vfaddsubh, v8f16, v8f16, v8f16>;
def VFSUBADDH : FORMAT_R3_RM<opcode_vfsubaddh, int_postrisc_vfsubaddh, v8f16, v8f16, v8f16>;
def VFHADDH   : FORMAT_R3_RM<opcode_vfhaddh,   int_postrisc_vfhaddh,   v8f16, v8f16, v8f16>;
def VFHSUBH   : FORMAT_R3_RM<opcode_vfhsubh,   int_postrisc_vfhsubh,   v8f16, v8f16, v8f16>;
def VFHMULH   : FORMAT_R3_RM<opcode_vfhmulh,   int_postrisc_vfhmulh,   v8f16, v8f16, v8f16>;
def VFDOTH    : FORMAT_R3_RM<opcode_vfdoth,    int_postrisc_vfdoth,    v8f16, v8f16, v8f16>;

def VFABDS    : FORMAT_R3_RM<opcode_vfabds,    int_postrisc_vfabds,    v4f32, v4f32, v4f32>;
def VFNABDS   : FORMAT_R3_RM<opcode_vfnabds,   int_postrisc_vfnabds,   v4f32, v4f32, v4f32>;
def VFADDS    : FORMAT_R3_RM<opcode_vfadds,    int_postrisc_vfadds,    v4f32, v4f32, v4f32>;
def VFNADDS   : FORMAT_R3_RM<opcode_vfnadds,   int_postrisc_vfnadds,   v4f32, v4f32, v4f32>;
def VFSUBS    : FORMAT_R3_RM<opcode_vfsubs,    int_postrisc_vfsubs,    v4f32, v4f32, v4f32>;
def VFMULS    : FORMAT_R3_RM<opcode_vfmuls,    int_postrisc_vfmuls,    v4f32, v4f32, v4f32>;
def VFNMULS   : FORMAT_R3_RM<opcode_vfnmuls,   int_postrisc_vfnmuls,   v4f32, v4f32, v4f32>;
def VFDIVS    : FORMAT_R3_RM<opcode_vfdivs,    int_postrisc_vfdivs,    v4f32, v4f32, v4f32>;
def VFADDSUBS : FORMAT_R3_RM<opcode_vfaddsubs, int_postrisc_vfaddsubs, v4f32, v4f32, v4f32>;
def VFSUBADDS : FORMAT_R3_RM<opcode_vfsubadds, int_postrisc_vfsubadds, v4f32, v4f32, v4f32>;
def VFHADDS   : FORMAT_R3_RM<opcode_vfhadds,   int_postrisc_vfhadds,   v4f32, v4f32, v4f32>;
def VFHSUBS   : FORMAT_R3_RM<opcode_vfhsubs,   int_postrisc_vfhsubs,   v4f32, v4f32, v4f32>;
def VFHMULS   : FORMAT_R3_RM<opcode_vfhmuls,   int_postrisc_vfhmuls,   v4f32, v4f32, v4f32>;
def VFDOTS    : FORMAT_R3_RM<opcode_vfdots,    int_postrisc_vfdots,    v4f32, v4f32, v4f32>;

def VFABDD    : FORMAT_R3_RM<opcode_vfabdd,    int_postrisc_vfabdd,    v2f64, v2f64, v2f64>;
def VFNABDD   : FORMAT_R3_RM<opcode_vfnabdd,   int_postrisc_vfnabdd,   v2f64, v2f64, v2f64>;
def VFADDD    : FORMAT_R3_RM<opcode_vfaddd,    int_postrisc_vfaddd,    v2f64, v2f64, v2f64>;
def VFNADDD   : FORMAT_R3_RM<opcode_vfnaddd,   int_postrisc_vfnaddd,   v2f64, v2f64, v2f64>;
def VFSUBD    : FORMAT_R3_RM<opcode_vfsubd,    int_postrisc_vfsubd,    v2f64, v2f64, v2f64>;
def VFMULD    : FORMAT_R3_RM<opcode_vfmuld,    int_postrisc_vfmuld,    v2f64, v2f64, v2f64>;
def VFNMULD   : FORMAT_R3_RM<opcode_vfnmuld,   int_postrisc_vfnmuld,   v2f64, v2f64, v2f64>;
def VFDIVD    : FORMAT_R3_RM<opcode_vfdivd,    int_postrisc_vfdivd,    v2f64, v2f64, v2f64>;
def VFADDSUBD : FORMAT_R3_RM<opcode_vfaddsubd, int_postrisc_vfaddsubd, v2f64, v2f64, v2f64>;
def VFSUBADDD : FORMAT_R3_RM<opcode_vfsubaddd, int_postrisc_vfsubaddd, v2f64, v2f64, v2f64>;
def VFHADDD   : FORMAT_R3_RM<opcode_vfhaddd,   int_postrisc_vfhaddd,   v2f64, v2f64, v2f64>;
def VFHSUBD   : FORMAT_R3_RM<opcode_vfhsubd,   int_postrisc_vfhsubd,   v2f64, v2f64, v2f64>;
def VFHMULD   : FORMAT_R3_RM<opcode_vfhmuld,   int_postrisc_vfhmuld,   v2f64, v2f64, v2f64>;
def VFDOTD    : FORMAT_R3_RM<opcode_vfdotd,    int_postrisc_vfdotd,    v2f64, v2f64, v2f64>;

//===----------------------------------------------------------------------===//
// usual binary patterns
//===----------------------------------------------------------------------===//
multiclass BinaryPatterns<InstBase ABS_DIFF, InstBase NABS_DIFF,
                          InstBase ADD, InstBase SUB, InstBase MUL, InstBase DIV,
                          InstBase NADD, InstBase NMUL, ValueType Ty>
{
  def : Pat<(fadd Ty:$rb, Ty:$rc), (ADD GR:$rb, GR:$rc, rounding_mode_dyn.value)>;
  def : Pat<(fsub Ty:$rb, Ty:$rc), (SUB GR:$rb, GR:$rc, rounding_mode_dyn.value)>;
  def : Pat<(fmul Ty:$rb, Ty:$rc), (MUL GR:$rb, GR:$rc, rounding_mode_dyn.value)>;
  def : Pat<(fdiv Ty:$rb, Ty:$rc), (DIV GR:$rb, GR:$rc, rounding_mode_dyn.value)>;

  def : Pat<(      fabs (fsub Ty:$rb, Ty:$rc )), (ABS_DIFF  GR:$rb, GR:$rc, rounding_mode_dyn.value)>; // absolute difference
  def : Pat<(fneg (fabs (fsub Ty:$rb, Ty:$rc))), (NABS_DIFF GR:$rb, GR:$rc, rounding_mode_dyn.value)>; // negated absolute difference

  def : Pat<(fneg (fadd       Ty:$rb,        Ty:$rc )), (NADD GR:$rb, GR:$rc, rounding_mode_dyn.value)>; // negated sum
  def : Pat<(      fadd (fneg Ty:$rb), (fneg Ty:$rc )), (NADD GR:$rb, GR:$rc, rounding_mode_dyn.value)>; // negated sum (as sum of negated)
  def : Pat<(fneg (fmul       Ty:$rb ,       Ty:$rc )), (NMUL GR:$rb, GR:$rc, rounding_mode_dyn.value)>; // negated mul
  def : Pat<(      fmul (fneg Ty:$rb),       Ty:$rc  ), (NMUL GR:$rb, GR:$rc, rounding_mode_dyn.value)>; // negated mul (as mul of one negated)
  def : Pat<(      fmul       Ty:$rb , (fneg Ty:$rc )), (NMUL GR:$rb, GR:$rc, rounding_mode_dyn.value)>; // negated mul (as mul of one negated)
}

defm : BinaryPatterns<FABDH, FNABDH, FADDH, FSUBH, FMULH, FDIVH, FNADDH, FNMULH, f16>;
defm : BinaryPatterns<FABDS, FNABDS, FADDS, FSUBS, FMULS, FDIVS, FNADDS, FNMULS, f32>;
defm : BinaryPatterns<FABDD, FNABDD, FADDD, FSUBD, FMULD, FDIVD, FNADDD, FNMULD, f64>;
defm : BinaryPatterns<FABDQ, FNABDQ, FADDQ, FSUBQ, FMULQ, FDIVQ, FNADDQ, FNMULQ, f128>;

defm : BinaryPatterns<VFABDH, VFNABDH, VFADDH, VFSUBH, VFMULH, VFDIVH, VFNADDH, VFNMULH, v8f16>;
defm : BinaryPatterns<VFABDS, VFNABDS, VFADDS, VFSUBS, VFMULS, VFDIVS, VFNADDS, VFNMULS, v4f32>;
defm : BinaryPatterns<VFABDD, VFNABDD, VFADDD, VFSUBD, VFMULD, VFDIVD, VFNADDD, VFNMULD, v2f64>;

//===----------------------------------------------------------------------===//
// fp compare
//===----------------------------------------------------------------------===//
defm FCMPOEQH : MISC_R3<opcode_fcmpoeqh, setoeq, i1, f16>;
defm FCMPONEH : MISC_R3<opcode_fcmponeh, setone, i1, f16>;
defm FCMPOLTH : MISC_R3<opcode_fcmpolth, setolt, i1, f16>;
defm FCMPOGEH : MISC_R3<opcode_fcmpogeh, setoge, i1, f16>;
defm FCMPOH   : MISC_R3<opcode_fcmpoh,   seto,   i1, f16>;
defm FCMPUEQH : MISC_R3<opcode_fcmpueqh, setueq, i1, f16>;
defm FCMPUNEH : MISC_R3<opcode_fcmpuneh, setune, i1, f16>;
defm FCMPULTH : MISC_R3<opcode_fcmpulth, setult, i1, f16>;
defm FCMPUGEH : MISC_R3<opcode_fcmpugeh, setuge, i1, f16>;
defm FCMPUH   : MISC_R3<opcode_fcmpuh,   setuo,  i1, f16>;

defm FCMPOEQS : MISC_R3<opcode_fcmpoeqs, setoeq, i1, f32>;
defm FCMPONES : MISC_R3<opcode_fcmpones, setone, i1, f32>;
defm FCMPOLTS : MISC_R3<opcode_fcmpolts, setolt, i1, f32>;
defm FCMPOGES : MISC_R3<opcode_fcmpoges, setoge, i1, f32>;
defm FCMPOS   : MISC_R3<opcode_fcmpos,   seto,   i1, f32>;
defm FCMPUEQS : MISC_R3<opcode_fcmpueqs, setueq, i1, f32>;
defm FCMPUNES : MISC_R3<opcode_fcmpunes, setune, i1, f32>;
defm FCMPULTS : MISC_R3<opcode_fcmpults, setult, i1, f32>;
defm FCMPUGES : MISC_R3<opcode_fcmpuges, setuge, i1, f32>;
defm FCMPUS   : MISC_R3<opcode_fcmpus,   setuo,  i1, f32>;

defm FCMPOEQD : MISC_R3<opcode_fcmpoeqd, setoeq, i1, f64>;
defm FCMPONED : MISC_R3<opcode_fcmponed, setone, i1, f64>;
defm FCMPOLTD : MISC_R3<opcode_fcmpoltd, setolt, i1, f64>;
defm FCMPOGED : MISC_R3<opcode_fcmpoged, setoge, i1, f64>;
defm FCMPOD   : MISC_R3<opcode_fcmpod,   seto,   i1, f64>;
defm FCMPUEQD : MISC_R3<opcode_fcmpueqd, setueq, i1, f64>;
defm FCMPUNED : MISC_R3<opcode_fcmpuned, setune, i1, f64>;
defm FCMPULTD : MISC_R3<opcode_fcmpultd, setult, i1, f64>;
defm FCMPUGED : MISC_R3<opcode_fcmpuged, setuge, i1, f64>;
defm FCMPUD   : MISC_R3<opcode_fcmpud,   setuo,  i1, f64>;

defm FCMPOEQQ : MISC_R3<opcode_fcmpoeqq, setoeq, i1, f128>;
defm FCMPONEQ : MISC_R3<opcode_fcmponeq, setone, i1, f128>;
defm FCMPOLTQ : MISC_R3<opcode_fcmpoltq, setolt, i1, f128>;
defm FCMPOGEQ : MISC_R3<opcode_fcmpogeq, setoge, i1, f128>;
defm FCMPOQ   : MISC_R3<opcode_fcmpoq,   seto,   i1, f128>;
defm FCMPUEQQ : MISC_R3<opcode_fcmpueqq, setueq, i1, f128>;
defm FCMPUNEQ : MISC_R3<opcode_fcmpuneq, setune, i1, f128>;
defm FCMPULTQ : MISC_R3<opcode_fcmpultq, setult, i1, f128>;
defm FCMPUGEQ : MISC_R3<opcode_fcmpugeq, setuge, i1, f128>;
defm FCMPUQ   : MISC_R3<opcode_fcmpuq,   setuo,  i1, f128>;

multiclass FpScalarComparePatterns<
   InstBase OEQ, InstBase ONE, InstBase OLT, InstBase OGE, InstBase ULT, InstBase UGE, ValueType Ty>
{
  // arg swapping
  def : Pat<(i1 (setogt Ty:$rb, Ty:$rc)), (OLT GR:$rc, GR:$rb)>;
  def : Pat<(i1 (setugt Ty:$rb, Ty:$rc)), (ULT GR:$rc, GR:$rb)>;
  def : Pat<(i1 (setole Ty:$rb, Ty:$rc)), (OGE GR:$rc, GR:$rb)>;
  def : Pat<(i1 (setule Ty:$rb, Ty:$rc)), (UGE GR:$rc, GR:$rb)>;

  // fast-math doesn't differ ordered/unordered => use ordered forms
  def : Pat<(i1 (seteq Ty:$rb, Ty:$rc)), (OEQ GR:$rb, GR:$rc)>;
  def : Pat<(i1 (setne Ty:$rb, Ty:$rc)), (ONE GR:$rb, GR:$rc)>;
  def : Pat<(i1 (setlt Ty:$rb, Ty:$rc)), (OLT GR:$rb, GR:$rc)>;
  def : Pat<(i1 (setge Ty:$rb, Ty:$rc)), (OGE GR:$rb, GR:$rc)>;
  // fast-math args swap
  def : Pat<(i1 (setgt Ty:$rb, Ty:$rc)), (OLT GR:$rc, GR:$rb)>;
  def : Pat<(i1 (setle Ty:$rb, Ty:$rc)), (OGE GR:$rc, GR:$rb)>;
}

defm : FpScalarComparePatterns<FCMPOEQH, FCMPONEH, FCMPOLTH, FCMPOGEH, FCMPULTH, FCMPUGEH, f16>;
defm : FpScalarComparePatterns<FCMPOEQS, FCMPONES, FCMPOLTS, FCMPOGES, FCMPULTS, FCMPUGES, f32>;
defm : FpScalarComparePatterns<FCMPOEQD, FCMPONED, FCMPOLTD, FCMPOGED, FCMPULTD, FCMPUGED, f64>;
defm : FpScalarComparePatterns<FCMPOEQQ, FCMPONEQ, FCMPOLTQ, FCMPOGEQ, FCMPULTQ, FCMPUGEQ, f128>;

defm VFCMPOEQH : BUILTIN_R3<opcode_vfcmpoeqh, int_postrisc_vfcmpoeqh, v8i16, v8f16, v8f16>;
defm VFCMPONEH : BUILTIN_R3<opcode_vfcmponeh, int_postrisc_vfcmponeh, v8i16, v8f16, v8f16>;
defm VFCMPOLTH : BUILTIN_R3<opcode_vfcmpolth, int_postrisc_vfcmpolth, v8i16, v8f16, v8f16>;
defm VFCMPOGEH : BUILTIN_R3<opcode_vfcmpogeh, int_postrisc_vfcmpogeh, v8i16, v8f16, v8f16>;
defm VFCMPOH   : BUILTIN_R3<opcode_vfcmpoh,   int_postrisc_vfcmpoh,   v8i16, v8f16, v8f16>;
defm VFCMPUEQH : BUILTIN_R3<opcode_vfcmpueqh, int_postrisc_vfcmpueqh, v8i16, v8f16, v8f16>;
defm VFCMPUNEH : BUILTIN_R3<opcode_vfcmpuneh, int_postrisc_vfcmpuneh, v8i16, v8f16, v8f16>;
defm VFCMPULTH : BUILTIN_R3<opcode_vfcmpulth, int_postrisc_vfcmpulth, v8i16, v8f16, v8f16>;
defm VFCMPUGEH : BUILTIN_R3<opcode_vfcmpugeh, int_postrisc_vfcmpugeh, v8i16, v8f16, v8f16>;
defm VFCMPUH   : BUILTIN_R3<opcode_vfcmpuh,   int_postrisc_vfcmpuh,   v8i16, v8f16, v8f16>;

defm VFCMPOEQS : BUILTIN_R3<opcode_vfcmpoeqs, int_postrisc_vfcmpoeqs, v4i32, v4f32, v4f32>;
defm VFCMPONES : BUILTIN_R3<opcode_vfcmpones, int_postrisc_vfcmpones, v4i32, v4f32, v4f32>;
defm VFCMPOLTS : BUILTIN_R3<opcode_vfcmpolts, int_postrisc_vfcmpolts, v4i32, v4f32, v4f32>;
defm VFCMPOGES : BUILTIN_R3<opcode_vfcmpoges, int_postrisc_vfcmpoges, v4i32, v4f32, v4f32>;
defm VFCMPOS   : BUILTIN_R3<opcode_vfcmpos,   int_postrisc_vfcmpos,   v4i32, v4f32, v4f32>;
defm VFCMPUEQS : BUILTIN_R3<opcode_vfcmpueqs, int_postrisc_vfcmpueqs, v4i32, v4f32, v4f32>;
defm VFCMPUNES : BUILTIN_R3<opcode_vfcmpunes, int_postrisc_vfcmpunes, v4i32, v4f32, v4f32>;
defm VFCMPULTS : BUILTIN_R3<opcode_vfcmpults, int_postrisc_vfcmpults, v4i32, v4f32, v4f32>;
defm VFCMPUGES : BUILTIN_R3<opcode_vfcmpuges, int_postrisc_vfcmpuges, v4i32, v4f32, v4f32>;
defm VFCMPUS   : BUILTIN_R3<opcode_vfcmpus,   int_postrisc_vfcmpus,   v4i32, v4f32, v4f32>;

defm VFCMPOEQD : BUILTIN_R3<opcode_vfcmpoeqd, int_postrisc_vfcmpoeqd, v2i64, v2f64, v2f64>;
defm VFCMPONED : BUILTIN_R3<opcode_vfcmponed, int_postrisc_vfcmponed, v2i64, v2f64, v2f64>;
defm VFCMPOLTD : BUILTIN_R3<opcode_vfcmpoltd, int_postrisc_vfcmpoltd, v2i64, v2f64, v2f64>;
defm VFCMPOGED : BUILTIN_R3<opcode_vfcmpoged, int_postrisc_vfcmpoged, v2i64, v2f64, v2f64>;
defm VFCMPOD   : BUILTIN_R3<opcode_vfcmpod,   int_postrisc_vfcmpod,   v2i64, v2f64, v2f64>;
defm VFCMPUEQD : BUILTIN_R3<opcode_vfcmpueqd, int_postrisc_vfcmpueqd, v2i64, v2f64, v2f64>;
defm VFCMPUNED : BUILTIN_R3<opcode_vfcmpuned, int_postrisc_vfcmpuned, v2i64, v2f64, v2f64>;
defm VFCMPULTD : BUILTIN_R3<opcode_vfcmpultd, int_postrisc_vfcmpultd, v2i64, v2f64, v2f64>;
defm VFCMPUGED : BUILTIN_R3<opcode_vfcmpuged, int_postrisc_vfcmpuged, v2i64, v2f64, v2f64>;
defm VFCMPUD   : BUILTIN_R3<opcode_vfcmpud,   int_postrisc_vfcmpud,   v2i64, v2f64, v2f64>;

//===----------------------------------------------------------------------===//
// conversions
//===----------------------------------------------------------------------===//
def FHTOIW : FORMAT_R2_RM<opcode_fhtoiw, int_postrisc_fhtoiw, i32,  f16>;
def FHTOUW : FORMAT_R2_RM<opcode_fhtouw, int_postrisc_fhtouw, i32,  f16>;
def FHTOID : FORMAT_R2_RM<opcode_fhtoid, int_postrisc_fhtoid, i64,  f16>;
def FHTOUD : FORMAT_R2_RM<opcode_fhtoud, int_postrisc_fhtoud, i64,  f16>;
def FHTOIQ : FORMAT_R2_RM<opcode_fhtoiq, int_postrisc_fhtoiq, i128, f16>;
def FHTOUQ : FORMAT_R2_RM<opcode_fhtouq, int_postrisc_fhtouq, i128, f16>;

def FIWTOH : FORMAT_R2_RM<opcode_fiwtoh, int_postrisc_fiwtoh, f16, i32>;
def FUWTOH : FORMAT_R2_RM<opcode_fuwtoh, int_postrisc_fuwtoh, f16, i32>;
def FIDTOH : FORMAT_R2_RM<opcode_fidtoh, int_postrisc_fidtoh, f16, i64>;
def FUDTOH : FORMAT_R2_RM<opcode_fudtoh, int_postrisc_fudtoh, f16, i64>;
def FIQTOH : FORMAT_R2_RM<opcode_fiqtoh, int_postrisc_fiqtoh, f16, i128>;
def FUQTOH : FORMAT_R2_RM<opcode_fuqtoh, int_postrisc_fuqtoh, f16, i128>;

def FSTOIW : FORMAT_R2_RM<opcode_fstoiw, int_postrisc_fstoiw, i32,  f32>;
def FSTOUW : FORMAT_R2_RM<opcode_fstouw, int_postrisc_fstouw, i32,  f32>;
def FSTOID : FORMAT_R2_RM<opcode_fstoid, int_postrisc_fstoid, i64,  f32>;
def FSTOUD : FORMAT_R2_RM<opcode_fstoud, int_postrisc_fstoud, i64,  f32>;
def FSTOIQ : FORMAT_R2_RM<opcode_fstoiq, int_postrisc_fstoiq, i128, f32>;
def FSTOUQ : FORMAT_R2_RM<opcode_fstouq, int_postrisc_fstouq, i128, f32>;

def FIWTOS : FORMAT_R2_RM<opcode_fiwtos, int_postrisc_fiwtos, f32, i32>;
def FUWTOS : FORMAT_R2_RM<opcode_fuwtos, int_postrisc_fuwtos, f32, i32>;
def FIDTOS : FORMAT_R2_RM<opcode_fidtos, int_postrisc_fidtos, f32, i64>;
def FUDTOS : FORMAT_R2_RM<opcode_fudtos, int_postrisc_fudtos, f32, i64>;
def FIQTOS : FORMAT_R2_RM<opcode_fiqtos, int_postrisc_fiqtos, f32, i128>;
def FUQTOS : FORMAT_R2_RM<opcode_fuqtos, int_postrisc_fuqtos, f32, i128>;

def FDTOIW : FORMAT_R2_RM<opcode_fdtoiw, int_postrisc_fdtoiw, i32,  f64>;
def FDTOUW : FORMAT_R2_RM<opcode_fdtouw, int_postrisc_fdtouw, i32,  f64>;
def FDTOID : FORMAT_R2_RM<opcode_fdtoid, int_postrisc_fdtoid, i64,  f64>;
def FDTOUD : FORMAT_R2_RM<opcode_fdtoud, int_postrisc_fdtoud, i64,  f64>;
def FDTOIQ : FORMAT_R2_RM<opcode_fdtoiq, int_postrisc_fdtoiq, i128, f64>;
def FDTOUQ : FORMAT_R2_RM<opcode_fdtouq, int_postrisc_fdtouq, i128, f64>;

def FIWTOD : FORMAT_R2_RM<opcode_fiwtod, int_postrisc_fiwtod, f64,  i32>;
def FUWTOD : FORMAT_R2_RM<opcode_fuwtod, int_postrisc_fuwtod, f64,  i32>;
def FIDTOD : FORMAT_R2_RM<opcode_fidtod, int_postrisc_fidtod, f64,  i64>;
def FUDTOD : FORMAT_R2_RM<opcode_fudtod, int_postrisc_fudtod, f64,  i64>;
def FIQTOD : FORMAT_R2_RM<opcode_fiqtod, int_postrisc_fiqtod, f64,  i128>;
def FUQTOD : FORMAT_R2_RM<opcode_fuqtod, int_postrisc_fuqtod, f64,  i128>;

def FQTOIW : FORMAT_R2_RM<opcode_fqtoiw, int_postrisc_fqtoiw, i32,  f128>;
def FQTOUW : FORMAT_R2_RM<opcode_fqtouw, int_postrisc_fqtouw, i32,  f128>;
def FQTOID : FORMAT_R2_RM<opcode_fqtoid, int_postrisc_fqtoid, i64,  f128>;
def FQTOUD : FORMAT_R2_RM<opcode_fqtoud, int_postrisc_fqtoud, i64,  f128>;
def FQTOIQ : FORMAT_R2_RM<opcode_fqtoiq, int_postrisc_fqtoiq, i128, f128>;
def FQTOUQ : FORMAT_R2_RM<opcode_fqtouq, int_postrisc_fqtouq, i128, f128>;

def FIWTOQ : FORMAT_R2_RM<opcode_fiwtoq, int_postrisc_fiwtoq, f128, i32>;
def FUWTOQ : FORMAT_R2_RM<opcode_fuwtoq, int_postrisc_fuwtoq, f128, i32>;
def FIDTOQ : FORMAT_R2_RM<opcode_fidtoq, int_postrisc_fidtoq, f128, i64>;
def FUDTOQ : FORMAT_R2_RM<opcode_fudtoq, int_postrisc_fudtoq, f128, i64>;
def FIQTOQ : FORMAT_R2_RM<opcode_fiqtoq, int_postrisc_fiqtoq, f128, i128>;
def FUQTOQ : FORMAT_R2_RM<opcode_fuqtoq, int_postrisc_fuqtoq, f128, i128>;

//===----------------------------------------------------------------------===//
// any_fp_to_[u|s]int | any_[u|s]int_to_fp patterns
//===----------------------------------------------------------------------===//
multiclass ConversionPatterns<
  InstBase TO_SINT, InstBase FROM_SINT, InstBase TO_UINT, InstBase FROM_UINT,
  ValueType Ty, ValueType Int>
{
  // float => integer conversions (via trunc)
  def : Pat<(Int (any_fp_to_sint Ty:$rb)), (TO_SINT GR:$rb, rounding_mode_rtz.value)>;
  def : Pat<(Int (any_fp_to_uint Ty:$rb)), (TO_UINT GR:$rb, rounding_mode_rtz.value)>;

  // integer => float conversions
  def : Pat<(Ty (any_sint_to_fp Int:$rb)), (FROM_SINT GR:$rb, rounding_mode_rmm.value)>;
  def : Pat<(Ty (any_uint_to_fp Int:$rb)), (FROM_UINT GR:$rb, rounding_mode_rmm.value)>;

  def : Pat<(Int (any_fp_to_sint (any_froundeven Ty:$rb))), (TO_SINT GR:$rb, rounding_mode_rne.value)>; // to nearest even
  def : Pat<(Int (any_fp_to_sint (any_ffloor     Ty:$rb))), (TO_SINT GR:$rb, rounding_mode_rdn.value)>; // towards -inf.
  def : Pat<(Int (any_fp_to_sint (any_fceil      Ty:$rb))), (TO_SINT GR:$rb, rounding_mode_rup.value)>; // upward towards +inf
  def : Pat<(Int (any_fp_to_sint (any_ftrunc     Ty:$rb))), (TO_SINT GR:$rb, rounding_mode_rtz.value)>; // to zero
  def : Pat<(Int (any_fp_to_sint (any_fround     Ty:$rb))), (TO_SINT GR:$rb, rounding_mode_rmm.value)>; // to nearest with ties away from zero.
  def : Pat<(Int (any_fp_to_sint (any_fnearbyint Ty:$rb))), (TO_SINT GR:$rb, rounding_mode_dyn.value)>; // dynamic

  def : Pat<(Int (any_fp_to_uint (any_froundeven Ty:$rb))), (TO_UINT GR:$rb, rounding_mode_rne.value)>; // to nearest even
  def : Pat<(Int (any_fp_to_uint (any_ffloor     Ty:$rb))), (TO_UINT GR:$rb, rounding_mode_rdn.value)>; // towards -inf.
  def : Pat<(Int (any_fp_to_uint (any_fceil      Ty:$rb))), (TO_UINT GR:$rb, rounding_mode_rup.value)>; // upward towards +inf
  def : Pat<(Int (any_fp_to_uint (any_ftrunc     Ty:$rb))), (TO_UINT GR:$rb, rounding_mode_rtz.value)>; // to zero
  def : Pat<(Int (any_fp_to_uint (any_fround     Ty:$rb))), (TO_UINT GR:$rb, rounding_mode_rmm.value)>; // to nearest with ties away from zero.
  def : Pat<(Int (any_fp_to_uint (any_fnearbyint Ty:$rb))), (TO_UINT GR:$rb, rounding_mode_dyn.value)>; // dynamic
}

defm : ConversionPatterns<FHTOIW, FIWTOH, FHTOUW, FUWTOH, f16, i32>;
defm : ConversionPatterns<FHTOID, FIDTOH, FHTOUD, FUDTOH, f16, i64>;
defm : ConversionPatterns<FHTOIQ, FIQTOH, FHTOUQ, FUQTOH, f16, i128>;

defm : ConversionPatterns<FSTOIW, FIWTOS, FSTOUW, FUWTOS, f32, i32>;
defm : ConversionPatterns<FSTOID, FIDTOS, FSTOUD, FUDTOS, f32, i64>;
defm : ConversionPatterns<FSTOIQ, FIQTOS, FSTOUQ, FUQTOS, f32, i128>;

defm : ConversionPatterns<FDTOIW, FIWTOD, FDTOUW, FUWTOD, f64, i32>;
defm : ConversionPatterns<FDTOID, FIDTOD, FDTOUD, FUDTOD, f64, i64>;
defm : ConversionPatterns<FDTOIQ, FIQTOD, FDTOUQ, FUQTOD, f64, i128>;

defm : ConversionPatterns<FQTOIW, FIWTOQ, FQTOUW, FUWTOQ, f128, i32>;
defm : ConversionPatterns<FQTOID, FIDTOQ, FQTOUD, FUDTOQ, f128, i64>;
defm : ConversionPatterns<FQTOIQ, FIQTOQ, FQTOUQ, FUQTOQ, f128, i128>;

//===----------------------------------------------------------------------===//
// llrin/llround patterns
//===----------------------------------------------------------------------===//
multiclass LRint_LRound<InstBase ROUND32, InstBase ROUND64, ValueType Ty>
{
  // lrint|lround: to both i32 & i64
  def : Pat<(i32 (any_lrint   Ty:$rb)), (ROUND32 $rb, rounding_mode_dyn.value)>; // Ty->int32 with current rounding mode.
  def : Pat<(i32 (any_lround  Ty:$rb)), (ROUND32 $rb, rounding_mode_rmm.value)>; // Ty->int32 rounded to nearest with ties rounded away from zero.
  def : Pat<(i64 (any_lrint   Ty:$rb)), (ROUND64 $rb, rounding_mode_dyn.value)>; // Ty->int64 with current rounding mode.
  def : Pat<(i64 (any_lround  Ty:$rb)), (ROUND64 $rb, rounding_mode_rmm.value)>; // Ty->int64 rounded to nearest with ties rounded away from zero.
  // llround: only to i64
  def : Pat<(i64 (any_llrint  Ty:$rb)), (ROUND64 $rb, rounding_mode_dyn.value)>; // Ty->int64 with current rounding mode.
  def : Pat<(i64 (any_llround Ty:$rb)), (ROUND64 $rb, rounding_mode_rmm.value)>; // Ty->int64 rounded to nearest with ties rounded away from zero.
}

defm : LRint_LRound<FHTOIW, FHTOID, f16>;
defm : LRint_LRound<FSTOIW, FSTOID, f32>;
defm : LRint_LRound<FDTOIW, FDTOID, f64>;
defm : LRint_LRound<FQTOIW, FQTOID, f128>;

//===----------------------------------------------------------------------===//
// FIXME: i1 to fp => via i32 to fp
//===----------------------------------------------------------------------===//
def : Pat<(f16  (any_sint_to_fp i1:$src)), (FIWTOH GR:$src, rounding_mode_rtz.value)>;
def : Pat<(f16  (any_uint_to_fp i1:$src)), (FUWTOH GR:$src, rounding_mode_rtz.value)>;
def : Pat<(f32  (any_sint_to_fp i1:$src)), (FIWTOS GR:$src, rounding_mode_rtz.value)>;
def : Pat<(f32  (any_uint_to_fp i1:$src)), (FUWTOS GR:$src, rounding_mode_rtz.value)>;
def : Pat<(f64  (any_sint_to_fp i1:$src)), (FIWTOD GR:$src, rounding_mode_rtz.value)>;
def : Pat<(f64  (any_uint_to_fp i1:$src)), (FUWTOD GR:$src, rounding_mode_rtz.value)>;
def : Pat<(f128 (any_sint_to_fp i1:$src)), (FIWTOQ GR:$src, rounding_mode_rtz.value)>;
def : Pat<(f128 (any_uint_to_fp i1:$src)), (FUWTOQ GR:$src, rounding_mode_rtz.value)>;

//===----------------------------------------------------------------------===//
// vector conversions
//===----------------------------------------------------------------------===//
def VFHTOIH : FORMAT_R2_RM<opcode_vfhtoih, int_postrisc_vfhtoih, v8i16, v8f16>;
def VFHTOUH : FORMAT_R2_RM<opcode_vfhtouh, int_postrisc_vfhtouh, v8i16, v8f16>;
def VFIHTOH : FORMAT_R2_RM<opcode_vfihtoh, int_postrisc_vfihtoh, v8f16, v8i16>;
def VFUHTOH : FORMAT_R2_RM<opcode_vfuhtoh, int_postrisc_vfuhtoh, v8f16, v8i16>;

def VFSTOIW : FORMAT_R2_RM<opcode_vfstoiw, int_postrisc_vfstoiw, v4i32, v4f32>;
def VFSTOUW : FORMAT_R2_RM<opcode_vfstouw, int_postrisc_vfstouw, v4i32, v4f32>;
def VFIWTOS : FORMAT_R2_RM<opcode_vfiwtos, int_postrisc_vfiwtos, v4f32, v4i32>;
def VFUWTOS : FORMAT_R2_RM<opcode_vfuwtos, int_postrisc_vfuwtos, v4f32, v4i32>;

def VFDTOID : FORMAT_R2_RM<opcode_vfdtoid, int_postrisc_vfdtoid, v2i64, v2f64>;
def VFDTOUD : FORMAT_R2_RM<opcode_vfdtoud, int_postrisc_vfdtoud, v2i64, v2f64>;
def VFIDTOD : FORMAT_R2_RM<opcode_vfidtod, int_postrisc_vfidtod, v2f64, v2i64>;
def VFUDTOD : FORMAT_R2_RM<opcode_vfudtod, int_postrisc_vfudtod, v2f64, v2i64>;

defm : ConversionPatterns<VFHTOIH, VFIHTOH, VFHTOUH, VFUHTOH, v8f16, v8i16>;
defm : ConversionPatterns<VFSTOIW, VFIWTOS, VFSTOUW, VFUWTOS, v4f32, v4i32>;
defm : ConversionPatterns<VFDTOID, VFIDTOD, VFDTOUD, VFUDTOD, v2f64, v2i64>;

//===----------------------------------------------------------------------===//
// sign-related
// fmax/fmin uses custom builtins while there are no __builtin_fmaximum/__builtin_fminimum
//===----------------------------------------------------------------------===//
defm FABSH    : FORMAT_R2<opcode_fabsh>;
defm FNABSH   : FORMAT_R2<opcode_fnabsh>;
defm FNEGH    : FORMAT_R2<opcode_fnegh>;
defm FMAXH    : BUILTIN_R3<opcode_fmaxh, int_postrisc_fmaximumh, f16, f16, f16>;
defm FMINH    : BUILTIN_R3<opcode_fminh, int_postrisc_fminimumh, f16, f16, f16>;
defm FMAXNMH  : FORMAT_R3<opcode_fmaxnmh>;
defm FMINNMH  : FORMAT_R3<opcode_fminnmh>;
defm FAMAXNMH : FORMAT_R3<opcode_famaxnmh>;
defm FAMINNMH : FORMAT_R3<opcode_faminnmh>;

defm FABSS    : FORMAT_R2<opcode_fabss>;
defm FNABSS   : FORMAT_R2<opcode_fnabss>;
defm FNEGS    : FORMAT_R2<opcode_fnegs>;
defm FMAXS    : BUILTIN_R3<opcode_fmaxs, int_postrisc_fmaximums, f32, f32, f32>;
defm FMINS    : BUILTIN_R3<opcode_fmins, int_postrisc_fminimums, f32, f32, f32>;
defm FMAXNMS  : FORMAT_R3<opcode_fmaxnms>;
defm FMINNMS  : FORMAT_R3<opcode_fminnms>;
defm FAMAXNMS : FORMAT_R3<opcode_famaxnms>;
defm FAMINNMS : FORMAT_R3<opcode_faminnms>;

defm FABSD    : FORMAT_R2<opcode_fabsd>;
defm FNABSD   : FORMAT_R2<opcode_fnabsd>;
defm FNEGD    : FORMAT_R2<opcode_fnegd>;
defm FMAXD    : BUILTIN_R3<opcode_fmaxd, int_postrisc_fmaximumd, f64, f64, f64>;
defm FMIND    : BUILTIN_R3<opcode_fmind, int_postrisc_fminimumd, f64, f64, f64>;
defm FMAXNMD  : FORMAT_R3<opcode_fmaxnmd>;
defm FMINNMD  : FORMAT_R3<opcode_fminnmd>;
defm FAMAXNMD : FORMAT_R3<opcode_famaxnmd>;
defm FAMINNMD : FORMAT_R3<opcode_faminnmd>;

defm FABSQ    : FORMAT_R2<opcode_fabsq>;
defm FNABSQ   : FORMAT_R2<opcode_fnabsq>;
defm FNEGQ    : FORMAT_R2<opcode_fnegq>;
defm FMAXQ    : BUILTIN_R3<opcode_fmaxq, int_postrisc_fmaximumq, f128, f128, f128>;
defm FMINQ    : BUILTIN_R3<opcode_fminq, int_postrisc_fminimumq, f128, f128, f128>;
defm FMAXNMQ  : FORMAT_R3<opcode_fmaxnmq>;
defm FMINNMQ  : FORMAT_R3<opcode_fminnmq>;
defm FAMAXNMQ : FORMAT_R3<opcode_famaxnmq>;
defm FAMINNMQ : FORMAT_R3<opcode_faminnmq>;

defm VFABSH     : FORMAT_R2<opcode_vfabsh>;
defm VFNABSH    : FORMAT_R2<opcode_vfnabsh>;
defm VFNEGH     : FORMAT_R2<opcode_vfnegh>;
defm VFMAXH     : FORMAT_R3<opcode_vfmaxh>;
defm VFMINH     : FORMAT_R3<opcode_vfminh>;
defm VFMAXNMH   : FORMAT_R3<opcode_vfmaxnmh>;
defm VFMINNMH   : FORMAT_R3<opcode_vfminnmh>;
defm VFAMAXNMH  : FORMAT_R3<opcode_vfamaxnmh>;
defm VFAMINNMH  : FORMAT_R3<opcode_vfaminnmh>;

defm VFABSS     : FORMAT_R2<opcode_vfabss>;
defm VFNABSS    : FORMAT_R2<opcode_vfnabss>;
defm VFNEGS     : FORMAT_R2<opcode_vfnegs>;
defm VFMAXS     : FORMAT_R3<opcode_vfmaxs>;
defm VFMINS     : FORMAT_R3<opcode_vfmins>;
defm VFMAXNMS   : FORMAT_R3<opcode_vfmaxnms>;
defm VFMINNMS   : FORMAT_R3<opcode_vfminnms>;
defm VFAMAXNMS  : FORMAT_R3<opcode_vfamaxnms>;
defm VFAMINNMS  : FORMAT_R3<opcode_vfaminnms>;

defm VFABSD     : FORMAT_R2<opcode_vfabsd>;
defm VFNABSD    : FORMAT_R2<opcode_vfnabsd>;
defm VFNEGD     : FORMAT_R2<opcode_vfnegd>;
defm VFMAXD     : FORMAT_R3<opcode_vfmaxd>;
defm VFMIND     : FORMAT_R3<opcode_vfmind>;
defm VFMAXNMD   : FORMAT_R3<opcode_vfmaxnmd>;
defm VFMINNMD   : FORMAT_R3<opcode_vfminnmd>;
defm VFAMAXNMD  : FORMAT_R3<opcode_vfamaxnmd>;
defm VFAMINNMD  : FORMAT_R3<opcode_vfaminnmd>;

defm FMERGEH : BUILTIN_R4<opcode_fmergeh, int_postrisc_fmergeh, f16,  f16,  f16,  f16>;
defm FMERGES : BUILTIN_R4<opcode_fmerges, int_postrisc_fmerges, f32,  f32,  f32,  f32>;
defm FMERGED : BUILTIN_R4<opcode_fmerged, int_postrisc_fmerged, f64,  f64,  f64,  f64>;
defm FMERGEQ : BUILTIN_R4<opcode_fmergeq, int_postrisc_fmergeq, f128, f128, f128, f128>;

defm VFMERGEH  : BUILTIN_R4<opcode_vfmergeh, int_postrisc_vfmergeh, v8f16, v8f16, v8f16, v8f16>;
defm VFMERGES  : BUILTIN_R4<opcode_vfmerges, int_postrisc_vfmerges, v4f32, v4f32, v4f32, v4f32>;
defm VFMERGED  : BUILTIN_R4<opcode_vfmerged, int_postrisc_vfmerged, v2f64, v2f64, v2f64, v2f64>;

multiclass MinMaxSignPatterns<
  InstBase NEG, InstBase ABS, InstBase NABS, InstBase SQRT, InstBase MERGE,
  InstBase MIN, InstBase MAX, InstBase MINNUM, InstBase MAXNUM, InstBase ABS_MIN, InstBase ABS_MAX,
  ValueType Ty>
{
  def : Pat<(fneg        Ty:$rb ), (NEG  GR:$rb)>;
  def : Pat<(       fabs Ty:$rb ), (ABS  GR:$rb)>;
  def : Pat<(fneg ( fabs Ty:$rb)), (NABS GR:$rb)>;
  def : Pat<(      fsqrt Ty:$rb ), (SQRT GR:$rb, rounding_mode_dyn.value)>;

  // NaN-propagating minimum/maximum that also treat -0.0 as less than 0.0. follow IEEE 754-2019 semantics.
  def : Pat<(any_fminimum Ty:$rb, Ty:$rc), (MIN GR:$rb, GR:$rc)>;
  def : Pat<(any_fmaximum Ty:$rb, Ty:$rc), (MAX GR:$rb, GR:$rc)>;

  // NaN-ignoring minimum/maximum that also treat -0.0 as less than 0.0. follow IEEE 754-2019 semantics.
  def : Pat<(any_fminnum Ty:$rb, Ty:$rc), (MINNUM GR:$rb, GR:$rc)>;
  def : Pat<(any_fmaxnum Ty:$rb, Ty:$rc), (MAXNUM GR:$rb, GR:$rc)>;
  def : Pat<(fminimumnum Ty:$rb, Ty:$rc), (MINNUM GR:$rb, GR:$rc)>;
  def : Pat<(fmaximumnum Ty:$rb, Ty:$rc), (MAXNUM GR:$rb, GR:$rc)>;

  // NAN??
  def : Pat<(any_fminnum (fabs Ty:$rb), (fabs Ty:$rc)), (ABS_MIN GR:$rb, GR:$rc)>;
  def : Pat<(any_fmaxnum (fabs Ty:$rb), (fabs Ty:$rc)), (ABS_MAX GR:$rb, GR:$rc)>;

  def : Pat<(fcopysign Ty:$rb, Ty:$rc), (MERGE GR:$rc, GR:$rb, GR:$rb)>;
}

defm : MinMaxSignPatterns<FNEGH, FABSH, FNABSH, FSQRTH, FMERGEH, FMINH, FMAXH, FMINNMH, FMAXNMH, FAMINNMH, FAMAXNMH, f16>;
defm : MinMaxSignPatterns<FNEGS, FABSS, FNABSS, FSQRTS, FMERGES, FMINS, FMAXS, FMINNMS, FMAXNMS, FAMINNMS, FAMAXNMS, f32>;
defm : MinMaxSignPatterns<FNEGD, FABSD, FNABSD, FSQRTD, FMERGED, FMIND, FMAXD, FMINNMD, FMAXNMD, FAMINNMD, FAMAXNMD, f64>;
defm : MinMaxSignPatterns<FNEGQ, FABSQ, FNABSQ, FSQRTQ, FMERGEQ, FMINQ, FMAXQ, FMINNMQ, FMAXNMQ, FAMINNMQ, FAMAXNMQ, f128>;

defm : MinMaxSignPatterns<VFNEGH, VFABSH, VFNABSH, VFSQRTH, VFMERGEH, VFMINH, VFMAXH, VFMINNMH, VFMAXNMH, VFAMINNMH, VFAMAXNMH, v8f16>;
defm : MinMaxSignPatterns<VFNEGS, VFABSS, VFNABSS, VFSQRTS, VFMERGES, VFMINS, VFMAXS, VFMINNMS, VFMAXNMS, VFAMINNMS, VFAMAXNMS, v4f32>;
defm : MinMaxSignPatterns<VFNEGD, VFABSD, VFNABSD, VFSQRTD, VFMERGED, VFMIND, VFMAXD, VFMINNMD, VFMAXNMD, VFAMINNMD, VFAMAXNMD, v2f64>;

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

// f16 is bit convertible to i32 and vice verse
def : Pat<(f16 (bitconvert (i16 (trunc i32:$val)))), (ZEXTH GR:$val)>;
def : Pat<(f16 (bitconvert (i16 (trunc i32:$val)))), (SEXTH GR:$val)>;

def : Pat<(i32 (zext (i16 (bitconvert f16:$val)))), (ZEXTH GR:$val)>;
def : Pat<(i32 (sext (i16 (bitconvert f16:$val)))), (SEXTH GR:$val)>;

//===----------------------------------------------------------------------===//
// is_fpclass
//===----------------------------------------------------------------------===//
def classify_xform : SDNodeXForm<imm, [{
  return getI64Imm(N->getSExtValue(), SDLoc(N));
}]>;
def classify_imm : Operand<i32>, IntImmLeaf<i32, [{ return isZextInt(Imm, 10); }], classify_xform> {
  let DecoderMethod = "DecodeUIMM<10>";
}

multiclass FpClass<misc_opx Opc, InstrItinClass itin = IIC_iu_instr>
{
    def NAME : MISC_RabI10<Opc,
        (outs GR:$ra), (ins GR:$rb, classify_imm:$imm),
        !strconcat(Opc.mnem, " $ra, $rb, $imm"), [], itin>;
}

defm FCLASSH : FpClass<opcode_fclassh>;
defm FCLASSS : FpClass<opcode_fclasss>;
defm FCLASSD : FpClass<opcode_fclassd>;
defm FCLASSQ : FpClass<opcode_fclassq>;

def to_fclass_mask: SDNodeXForm<imm, [{
  uint64_t Check = N->getZExtValue();
  unsigned Mask = 0;

  if (Check & fcSNan)            Mask |= static_cast<unsigned>(FClassMask::SignalingNaN);
  if (Check & fcQNan)            Mask |= static_cast<unsigned>(FClassMask::QuietNaN);
  if (Check & fcPosInf)          Mask |= static_cast<unsigned>(FClassMask::PositiveInfinity);
  if (Check & fcNegInf)          Mask |= static_cast<unsigned>(FClassMask::NegativeInfinity);
  if (Check & fcPosNormal)       Mask |= static_cast<unsigned>(FClassMask::PositiveNormal);
  if (Check & fcNegNormal)       Mask |= static_cast<unsigned>(FClassMask::NegativeNormal);
  if (Check & fcPosSubnormal)    Mask |= static_cast<unsigned>(FClassMask::PositiveSubnormal);
  if (Check & fcNegSubnormal)    Mask |= static_cast<unsigned>(FClassMask::NegativeSubnormal);
  if (Check & fcPosZero)         Mask |= static_cast<unsigned>(FClassMask::PositiveZero);
  if (Check & fcNegZero)         Mask |= static_cast<unsigned>(FClassMask::NegativeZero);

  return CurDAG->getTargetConstant(Mask, SDLoc(N), MVT::i32);
}]>;

let AddedComplexity = Complexity_FpClass.value in { // FIXME: doesn't work, sometime prefer fcmp
  def : Pat<(i1 (is_fpclass  f16:$rb, (i32 timm:$mask))), (FCLASSH GR:$rb, (to_fclass_mask timm:$mask))>;
  def : Pat<(i1 (is_fpclass  f32:$rb, (i32 timm:$mask))), (FCLASSS GR:$rb, (to_fclass_mask timm:$mask))>;
  def : Pat<(i1 (is_fpclass  f64:$rb, (i32 timm:$mask))), (FCLASSD GR:$rb, (to_fclass_mask timm:$mask))>;
  def : Pat<(i1 (is_fpclass f128:$rb, (i32 timm:$mask))), (FCLASSQ GR:$rb, (to_fclass_mask timm:$mask))>;
}

//===----------------------------------------------------------------------===//
// fp merge/unpack
//===----------------------------------------------------------------------===//
defm VFMERGEHH : BUILTIN_R3<opcode_vfmergehh, int_postrisc_vfmergehh, v8f16, v8f16, v8f16>;
defm VFMERGEHS : BUILTIN_R3<opcode_vfmergehs, int_postrisc_vfmergehs, v4f32, v4f32, v4f32>;
defm VFMERGEHD : BUILTIN_R3<opcode_vfmergehd, int_postrisc_vfmergehd, v2f64, v2f64, v2f64>;

defm VFMERGELH : BUILTIN_R3<opcode_vfmergelh, int_postrisc_vfmergelh, v8f16, v8f16, v8f16>;
defm VFMERGELS : BUILTIN_R3<opcode_vfmergels, int_postrisc_vfmergels, v4f32, v4f32, v4f32>;
defm VFMERGELD : BUILTIN_R3<opcode_vfmergeld, int_postrisc_vfmergeld, v2f64, v2f64, v2f64>;

defm VFUPKHH : BUILTIN_R2<opcode_vfupkhh, int_postrisc_vfupkhh, v8f16, v8f16>;
defm VFUPKHS : BUILTIN_R2<opcode_vfupkhs, int_postrisc_vfupkhs, v4f32, v4f32>;
defm VFUPKHD : BUILTIN_R2<opcode_vfupkhd, int_postrisc_vfupkhd, v2f64, v2f64>;

defm VFUPKLH : BUILTIN_R2<opcode_vfupklh, int_postrisc_vfupklh, v8f16, v8f16>;
defm VFUPKLS : BUILTIN_R2<opcode_vfupkls, int_postrisc_vfupkls, v4f32, v4f32>;
defm VFUPKLD : BUILTIN_R2<opcode_vfupkld, int_postrisc_vfupkld, v2f64, v2f64>;
