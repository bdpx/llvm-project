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
def MADD_F16      : FORMAT_R4_RM_f16<opcode_madd_f16,      int_postrisc_madd_f16,      f16, f16, f16, f16>;
def MSUB_F16      : FORMAT_R4_RM_f16<opcode_msub_f16,      int_postrisc_msub_f16,      f16, f16, f16, f16>;
def NMADD_F16     : FORMAT_R4_RM_f16<opcode_nmadd_f16,     int_postrisc_nmadd_f16,     f16, f16, f16, f16>;
def NMSUB_F16     : FORMAT_R4_RM_f16<opcode_nmsub_f16,     int_postrisc_nmsub_f16,     f16, f16, f16, f16>;

def MADD_VF16     : FORMAT_R4_RM_f16<opcode_madd_vf16,     int_postrisc_madd_vf16,     v8f16, v8f16, v8f16, v8f16>;
def MSUB_VF16     : FORMAT_R4_RM_f16<opcode_msub_vf16,     int_postrisc_msub_vf16,     v8f16, v8f16, v8f16, v8f16>;
def NMADD_VF16    : FORMAT_R4_RM_f16<opcode_nmadd_vf16,    int_postrisc_nmadd_vf16,    v8f16, v8f16, v8f16, v8f16>;
def NMSUB_VF16    : FORMAT_R4_RM_f16<opcode_nmsub_vf16,    int_postrisc_nmsub_vf16,    v8f16, v8f16, v8f16, v8f16>;
def MADD_ALT_VF16 : FORMAT_R4_RM_f16<opcode_madd_alt_vf16, int_postrisc_madd_alt_vf16, v8f16, v8f16, v8f16, v8f16>;
def MSUB_ALT_VF16 : FORMAT_R4_RM_f16<opcode_msub_alt_vf16, int_postrisc_msub_alt_vf16, v8f16, v8f16, v8f16, v8f16>;

def MADD_F32      : FORMAT_R4_RM_f32<opcode_madd_f32,      int_postrisc_madd_f32,      f32, f32, f32, f32>;
def MSUB_F32      : FORMAT_R4_RM_f32<opcode_msub_f32,      int_postrisc_msub_f32,      f32, f32, f32, f32>;
def NMADD_F32     : FORMAT_R4_RM_f32<opcode_nmadd_f32,     int_postrisc_nmadd_f32,     f32, f32, f32, f32>;
def NMSUB_F32     : FORMAT_R4_RM_f32<opcode_nmsub_f32,     int_postrisc_nmsub_f32,     f32, f32, f32, f32>;

def MADD_VF32     : FORMAT_R4_RM_f32<opcode_madd_vf32,     int_postrisc_madd_vf32,     v4f32, v4f32, v4f32, v4f32>;
def MSUB_VF32     : FORMAT_R4_RM_f32<opcode_msub_vf32,     int_postrisc_msub_vf32,     v4f32, v4f32, v4f32, v4f32>;
def NMADD_VF32    : FORMAT_R4_RM_f32<opcode_nmadd_vf32,    int_postrisc_nmadd_vf32,    v4f32, v4f32, v4f32, v4f32>;
def NMSUB_VF32    : FORMAT_R4_RM_f32<opcode_nmsub_vf32,    int_postrisc_nmsub_vf32,    v4f32, v4f32, v4f32, v4f32>;
def MADD_ALT_VF32 : FORMAT_R4_RM_f32<opcode_madd_alt_vf32, int_postrisc_madd_alt_vf32, v4f32, v4f32, v4f32, v4f32>;
def MSUB_ALT_VF32 : FORMAT_R4_RM_f32<opcode_msub_alt_vf32, int_postrisc_msub_alt_vf32, v4f32, v4f32, v4f32, v4f32>;

def MADD_F64      : FORMAT_R4_RM_f64<opcode_madd_f64,      int_postrisc_madd_f64,     f64, f64, f64, f64>;
def MSUB_F64      : FORMAT_R4_RM_f64<opcode_msub_f64,      int_postrisc_msub_f64,     f64, f64, f64, f64>;
def NMADD_F64     : FORMAT_R4_RM_f64<opcode_nmadd_f64,     int_postrisc_nmadd_f64,    f64, f64, f64, f64>;
def NMSUB_F64     : FORMAT_R4_RM_f64<opcode_nmsub_f64,     int_postrisc_nmsub_f64,    f64, f64, f64, f64>;

def MADD_VF64     : FORMAT_R4_RM_f64<opcode_madd_vf64,     int_postrisc_madd_vf64,     v2f64, v2f64, v2f64, v2f64>;
def MSUB_VF64     : FORMAT_R4_RM_f64<opcode_msub_vf64,     int_postrisc_msub_vf64,     v2f64, v2f64, v2f64, v2f64>;
def NMADD_VF64    : FORMAT_R4_RM_f64<opcode_nmadd_vf64,    int_postrisc_nmadd_vf64,    v2f64, v2f64, v2f64, v2f64>;
def NMSUB_VF64    : FORMAT_R4_RM_f64<opcode_nmsub_vf64,    int_postrisc_nmsub_vf64,    v2f64, v2f64, v2f64, v2f64>;
def MADD_ALT_VF64 : FORMAT_R4_RM_f64<opcode_madd_alt_vf64, int_postrisc_madd_alt_vf64, v2f64, v2f64, v2f64, v2f64>;
def MSUB_ALT_VF64 : FORMAT_R4_RM_f64<opcode_msub_alt_vf64, int_postrisc_msub_alt_vf64, v2f64, v2f64, v2f64, v2f64>;

def MADD_F128     : FORMAT_R4_RM_f128<opcode_madd_f128,    int_postrisc_madd_f128,      f128, f128, f128, f128>;
def MSUB_F128     : FORMAT_R4_RM_f128<opcode_msub_f128,    int_postrisc_msub_f128,      f128, f128, f128, f128>;
def NMADD_F128    : FORMAT_R4_RM_f128<opcode_nmadd_f128,   int_postrisc_nmadd_f128,     f128, f128, f128, f128>;
def NMSUB_F128    : FORMAT_R4_RM_f128<opcode_nmsub_f128,   int_postrisc_nmsub_f128,     f128, f128, f128, f128>;

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

defm : FusedPatterns<MADD_F16,  MSUB_F16,  NMADD_F16,  NMSUB_F16,  f16  >;
defm : FusedPatterns<MADD_F32,  MSUB_F32,  NMADD_F32,  NMSUB_F32,  f32  >;
defm : FusedPatterns<MADD_F64,  MSUB_F64,  NMADD_F64,  NMSUB_F64,  f64  >;
defm : FusedPatterns<MADD_F128, MSUB_F128, NMADD_F128, NMSUB_F128, f128 >;
defm : FusedPatterns<MADD_VF16, MSUB_VF16, NMADD_VF16, NMSUB_VF16, v8f16>;
defm : FusedPatterns<MADD_VF32, MSUB_VF32, NMADD_VF32, NMSUB_VF32, v4f32>;
defm : FusedPatterns<MADD_VF64, MSUB_VF64, NMADD_VF64, NMSUB_VF64, v2f64>;

//===----------------------------------------------------------------------===//
// fp immediates
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

// FXX (wider) to FX (narrow) conversion
def CVT_F32_F16  : FORMAT_R2_RM<opcode_cvt_f32_f16,  int_postrisc_cvt_f32_f16,  f16, f32>;
def CVT_F64_F16  : FORMAT_R2_RM<opcode_cvt_f64_f16,  int_postrisc_cvt_f64_f16,  f16, f64>;
def CVT_F64_F32  : FORMAT_R2_RM<opcode_cvt_f64_f32,  int_postrisc_cvt_f64_f32,  f32, f64>;
def CVT_F128_F16 : FORMAT_R2_RM<opcode_cvt_f128_f16, int_postrisc_cvt_f128_f16, f16, f128>;
def CVT_F128_F32 : FORMAT_R2_RM<opcode_cvt_f128_f32, int_postrisc_cvt_f128_f32, f32, f128>;
def CVT_F128_F64 : FORMAT_R2_RM<opcode_cvt_f128_f64, int_postrisc_cvt_f128_f64, f64, f128>;

// shrink-conversion by default - using dynamic rounding
def : Pat<(f16 (any_fpround  f32:$rb)), (CVT_F32_F16  GR:$rb, rounding_mode_dyn.value)>;
def : Pat<(f16 (any_fpround  f64:$rb)), (CVT_F64_F16  GR:$rb, rounding_mode_dyn.value)>;
def : Pat<(f32 (any_fpround  f64:$rb)), (CVT_F64_F32  GR:$rb, rounding_mode_dyn.value)>;
def : Pat<(f16 (any_fpround f128:$rb)), (CVT_F128_F16 GR:$rb, rounding_mode_dyn.value)>;
def : Pat<(f32 (any_fpround f128:$rb)), (CVT_F128_F32 GR:$rb, rounding_mode_dyn.value)>;
def : Pat<(f64 (any_fpround f128:$rb)), (CVT_F128_F64 GR:$rb, rounding_mode_dyn.value)>;

// TODO: fptrunc_round

//===----------------------------------------------------------------------===//
// unary (RM)
//===----------------------------------------------------------------------===//
def SQRT_F16   : FORMAT_R2_RM<opcode_sqrt_f16,   int_postrisc_sqrt_f16,   f16, f16>;
def RSQRT_F16  : FORMAT_R2_RM<opcode_rsqrt_f16,  int_postrisc_rsqrt_f16,  f16, f16>;
def SQRT_VF16  : FORMAT_R2_RM<opcode_sqrt_vf16,  int_postrisc_sqrt_vf16,  v8f16, v8f16>;
def RSQRT_VF16 : FORMAT_R2_RM<opcode_rsqrt_vf16, int_postrisc_rsqrt_vf16, v8f16, v8f16>;

def SQRT_F32   : FORMAT_R2_RM<opcode_sqrt_f32,   int_postrisc_sqrt_f32,   f32, f32>;
def RSQRT_F32  : FORMAT_R2_RM<opcode_rsqrt_f32,  int_postrisc_rsqrt_f32,  f32, f32>;
def SQRT_VF32  : FORMAT_R2_RM<opcode_sqrt_vf32,  int_postrisc_sqrt_vf32,  v4f32, v4f32>;
def RSQRT_VF32 : FORMAT_R2_RM<opcode_rsqrt_vf32, int_postrisc_rsqrt_vf32, v4f32, v4f32>;

def SQRT_F64   : FORMAT_R2_RM<opcode_sqrt_f64,   int_postrisc_sqrt_f64,   f64, f64>;
def RSQRT_F64  : FORMAT_R2_RM<opcode_rsqrt_f64,  int_postrisc_rsqrt_f64,  f64, f64>;
def SQRT_VF64  : FORMAT_R2_RM<opcode_sqrt_vf64,  int_postrisc_sqrt_vf64,  v2f64, v2f64>;
def RSQRT_VF64 : FORMAT_R2_RM<opcode_rsqrt_vf64, int_postrisc_rsqrt_vf64, v2f64, v2f64>;

def SQRT_F128  : FORMAT_R2_RM<opcode_sqrt_f128,  int_postrisc_sqrt_f128,  f128, f128>;
def RSQRT_F128 : FORMAT_R2_RM<opcode_rsqrt_f128, int_postrisc_rsqrt_f128, f128, f128>;

//===----------------------------------------------------------------------===//
// __builtin_signbit: right shift for all except f16 (double shift)
// FIXME: clang never produces fgetsign
//===----------------------------------------------------------------------===//
def : Pat<(i32 (fgetsign f16:$rb)), (SLSRL_U32 GR:$rb, (i32 16), (i32 31))>;
def : Pat<(i32 (fgetsign f32:$rb)), (SRL_IMM_U32  GR:$rb, (i32 31))>;
def : Pat<(i32 (fgetsign f64:$rb)), (SRL_IMM_U64  GR:$rb, (i32 63))>;
def : Pat<(i32 (fgetsign f64:$rb)), (SRL_IMM_U128 GR:$rb, (i32 127))>;

//===----------------------------------------------------------------------===//
// rounding
//===----------------------------------------------------------------------===//
def ROUND_F16  : FORMAT_R2_RM<opcode_round_f16,   int_postrisc_round_f16,  f16,  f16>;
def ROUND_F32  : FORMAT_R2_RM<opcode_round_f32,   int_postrisc_round_f32,  f32,  f32>;
def ROUND_F64  : FORMAT_R2_RM<opcode_round_f64,   int_postrisc_round_f64,  f64,  f64>;
def ROUND_F128 : FORMAT_R2_RM<opcode_round_f128,  int_postrisc_round_f128, f128, f128>;

def ROUNDNX_F16  : FORMAT_R2_RM<opcode_roundnx_f16,   int_postrisc_roundnx_f16,  f16,  f16>;
def ROUNDNX_F32  : FORMAT_R2_RM<opcode_roundnx_f32,   int_postrisc_roundnx_f32,  f32,  f32>;
def ROUNDNX_F64  : FORMAT_R2_RM<opcode_roundnx_f64,   int_postrisc_roundnx_f64,  f64,  f64>;
def ROUNDNX_F128 : FORMAT_R2_RM<opcode_roundnx_f128,  int_postrisc_roundnx_f128, f128, f128>;

multiclass RoundingPatterns<InstBase Inst, InstBase InstNX, ValueType Ty>
{
  def : Pat<(Ty (any_froundeven Ty:$rb)), (Inst GR:$rb, rounding_mode_rne.value)>; // to nearest even
  def : Pat<(Ty (any_ffloor     Ty:$rb)), (Inst GR:$rb, rounding_mode_rdn.value)>; // towards -inf.
  def : Pat<(Ty (any_fceil      Ty:$rb)), (Inst GR:$rb, rounding_mode_rup.value)>; // upward towards +inf
  def : Pat<(Ty (any_ftrunc     Ty:$rb)), (Inst GR:$rb, rounding_mode_rtz.value)>; // to zero
  def : Pat<(Ty (any_fround     Ty:$rb)), (Inst GR:$rb, rounding_mode_rmm.value)>; // to nearest with ties away from zero.
  def : Pat<(Ty (any_fnearbyint Ty:$rb)), (Inst GR:$rb, rounding_mode_dyn.value)>; // dynamic

  def : Pat<(Ty (any_frint Ty:$rb)), (InstNX GR:$rb, rounding_mode_dyn.value)>;  // frint rounds according to the current mode
}

defm : RoundingPatterns<ROUND_F16,  ROUNDNX_F16,  f16>;
defm : RoundingPatterns<ROUND_F32,  ROUNDNX_F32,  f32>;
defm : RoundingPatterns<ROUND_F64,  ROUNDNX_F64,  f64>;
defm : RoundingPatterns<ROUND_F128, ROUNDNX_F128, f128>;

//===----------------------------------------------------------------------===//
// vector rounding
//===----------------------------------------------------------------------===//
def ROUND_VF16 : FORMAT_R2_RM<opcode_round_vf16, int_postrisc_round_vf16, v8f16, v8f16>;
def ROUND_VF32 : FORMAT_R2_RM<opcode_round_vf32, int_postrisc_round_vf32, v4f32, v4f32>;
def ROUND_VF64 : FORMAT_R2_RM<opcode_round_vf64, int_postrisc_round_vf64, v2f64, v2f64>;

def ROUNDNX_VF16 : FORMAT_R2_RM<opcode_roundnx_vf16, int_postrisc_roundnx_vf16, v8f16, v8f16>;
def ROUNDNX_VF32 : FORMAT_R2_RM<opcode_roundnx_vf32, int_postrisc_roundnx_vf32, v4f32, v4f32>;
def ROUNDNX_VF64 : FORMAT_R2_RM<opcode_roundnx_vf64, int_postrisc_roundnx_vf64, v2f64, v2f64>;

defm : RoundingPatterns<ROUND_VF16, ROUNDNX_VF16, v8f16>;
defm : RoundingPatterns<ROUND_VF32, ROUNDNX_VF32, v4f32>;
defm : RoundingPatterns<ROUND_VF64, ROUNDNX_VF64, v2f64>;

//===----------------------------------------------------------------------===//
// binary (RM)
//===----------------------------------------------------------------------===//
def ABS_DIFF_F16   : FORMAT_R3_RM<opcode_abs_diff_f16,   int_postrisc_abs_diff_f16,  f16, f16, f16>;
def NABS_DIFF_F16  : FORMAT_R3_RM<opcode_nabs_diff_f16,  int_postrisc_nabs_diff_f16, f16, f16, f16>;
def ADD_F16        : FORMAT_R3_RM<opcode_add_f16,        int_postrisc_add_f16,       f16, f16, f16>;
def NADD_F16       : FORMAT_R3_RM<opcode_nadd_f16,       int_postrisc_nadd_f16,      f16, f16, f16>;
def SUB_F16        : FORMAT_R3_RM<opcode_sub_f16,        int_postrisc_sub_f16,       f16, f16, f16>;
def MUL_F16        : FORMAT_R3_RM<opcode_mul_f16,        int_postrisc_mul_f16,       f16, f16, f16>;
def NMUL_F16       : FORMAT_R3_RM<opcode_nmul_f16,       int_postrisc_nmul_f16,      f16, f16, f16>;
def DIV_F16        : FORMAT_R3_RM<opcode_div_f16,        int_postrisc_div_f16,       f16, f16, f16>;

def ABS_DIFF_VF16  : FORMAT_R3_RM<opcode_abs_diff_vf16,  int_postrisc_abs_diff_vf16,  v8f16, v8f16, v8f16>;
def NABS_DIFF_VF16 : FORMAT_R3_RM<opcode_nabs_diff_vf16, int_postrisc_nabs_diff_vf16, v8f16, v8f16, v8f16>;
def ADD_VF16       : FORMAT_R3_RM<opcode_add_vf16,       int_postrisc_add_vf16,       v8f16, v8f16, v8f16>;
def NADD_VF16      : FORMAT_R3_RM<opcode_nadd_vf16,      int_postrisc_nadd_vf16,      v8f16, v8f16, v8f16>;
def SUB_VF16       : FORMAT_R3_RM<opcode_sub_vf16,       int_postrisc_sub_vf16,       v8f16, v8f16, v8f16>;
def MUL_VF16       : FORMAT_R3_RM<opcode_mul_vf16,       int_postrisc_mul_vf16,       v8f16, v8f16, v8f16>;
def NMUL_VF16      : FORMAT_R3_RM<opcode_nmul_vf16,      int_postrisc_nmul_vf16,      v8f16, v8f16, v8f16>;
def DIV_VF16       : FORMAT_R3_RM<opcode_div_vf16,       int_postrisc_div_vf16,       v8f16, v8f16, v8f16>;
def ADD_ALT_VF16   : FORMAT_R3_RM<opcode_add_alt_vf16,   int_postrisc_add_alt_vf16,   v8f16, v8f16, v8f16>;
def SUB_ALT_VF16   : FORMAT_R3_RM<opcode_sub_alt_vf16,   int_postrisc_sub_alt_vf16,   v8f16, v8f16, v8f16>;
def ADD_HORIZ_VF16 : FORMAT_R3_RM<opcode_add_horiz_vf16, int_postrisc_add_horiz_vf16, v8f16, v8f16, v8f16>;
def SUB_HORIZ_VF16 : FORMAT_R3_RM<opcode_sub_horiz_vf16, int_postrisc_sub_horiz_vf16, v8f16, v8f16, v8f16>;
def MUL_HORIZ_VF16 : FORMAT_R3_RM<opcode_mul_horiz_vf16, int_postrisc_mul_horiz_vf16, v8f16, v8f16, v8f16>;

def ABS_DIFF_F32   : FORMAT_R3_RM<opcode_abs_diff_f32,   int_postrisc_abs_diff_f32,  f32, f32, f32>;
def NABS_DIFF_F32  : FORMAT_R3_RM<opcode_nabs_diff_f32,  int_postrisc_nabs_diff_f32, f32, f32, f32>;
def ADD_F32        : FORMAT_R3_RM<opcode_add_f32,        int_postrisc_add_f32,       f32, f32, f32>;
def NADD_F32       : FORMAT_R3_RM<opcode_nadd_f32,       int_postrisc_nadd_f32,      f32, f32, f32>;
def SUB_F32        : FORMAT_R3_RM<opcode_sub_f32,        int_postrisc_sub_f32,       f32, f32, f32>;
def MUL_F32        : FORMAT_R3_RM<opcode_mul_f32,        int_postrisc_mul_f32,       f32, f32, f32>;
def NMUL_F32       : FORMAT_R3_RM<opcode_nmul_f32,       int_postrisc_nmul_f32,      f32, f32, f32>;
def DIV_F32        : FORMAT_R3_RM<opcode_div_f32,        int_postrisc_div_f32,       f32, f32, f32>;

def ABS_DIFF_VF32  : FORMAT_R3_RM<opcode_abs_diff_vf32,  int_postrisc_abs_diff_vf32,  v4f32, v4f32, v4f32>;
def NABS_DIFF_VF32 : FORMAT_R3_RM<opcode_nabs_diff_vf32, int_postrisc_nabs_diff_vf32, v4f32, v4f32, v4f32>;
def ADD_VF32       : FORMAT_R3_RM<opcode_add_vf32,       int_postrisc_add_vf32,       v4f32, v4f32, v4f32>;
def NADD_VF32      : FORMAT_R3_RM<opcode_nadd_vf32,      int_postrisc_nadd_vf32,      v4f32, v4f32, v4f32>;
def SUB_VF32       : FORMAT_R3_RM<opcode_sub_vf32,       int_postrisc_sub_vf32,       v4f32, v4f32, v4f32>;
def MUL_VF32       : FORMAT_R3_RM<opcode_mul_vf32,       int_postrisc_mul_vf32,       v4f32, v4f32, v4f32>;
def NMUL_VF32      : FORMAT_R3_RM<opcode_nmul_vf32,      int_postrisc_nmul_vf32,      v4f32, v4f32, v4f32>;
def DIV_VF32       : FORMAT_R3_RM<opcode_div_vf32,       int_postrisc_div_vf32,       v4f32, v4f32, v4f32>;
def ADD_ALT_VF32   : FORMAT_R3_RM<opcode_add_alt_vf32,   int_postrisc_add_alt_vf32,   v4f32, v4f32, v4f32>;
def SUB_ALT_VF32   : FORMAT_R3_RM<opcode_sub_alt_vf32,   int_postrisc_sub_alt_vf32,   v4f32, v4f32, v4f32>;
def ADD_HORIZ_VF32 : FORMAT_R3_RM<opcode_add_horiz_vf32, int_postrisc_add_horiz_vf32, v4f32, v4f32, v4f32>;
def SUB_HORIZ_VF32 : FORMAT_R3_RM<opcode_sub_horiz_vf32, int_postrisc_sub_horiz_vf32, v4f32, v4f32, v4f32>;
def MUL_HORIZ_VF32 : FORMAT_R3_RM<opcode_mul_horiz_vf32, int_postrisc_mul_horiz_vf32, v4f32, v4f32, v4f32>;

def ABS_DIFF_F64   : FORMAT_R3_RM<opcode_abs_diff_f64,   int_postrisc_abs_diff_f64,  f64, f64, f64>;
def NABS_DIFF_F64  : FORMAT_R3_RM<opcode_nabs_diff_f64,  int_postrisc_nabs_diff_f64, f64, f64, f64>;
def ADD_F64        : FORMAT_R3_RM<opcode_add_f64,        int_postrisc_add_f64,       f64, f64, f64>;
def NADD_F64       : FORMAT_R3_RM<opcode_nadd_f64,       int_postrisc_nadd_f64,      f64, f64, f64>;
def SUB_F64        : FORMAT_R3_RM<opcode_sub_f64,        int_postrisc_sub_f64,       f64, f64, f64>;
def MUL_F64        : FORMAT_R3_RM<opcode_mul_f64,        int_postrisc_mul_f64,       f64, f64, f64>;
def NMUL_F64       : FORMAT_R3_RM<opcode_nmul_f64,       int_postrisc_nmul_f64,      f64, f64, f64>;
def DIV_F64        : FORMAT_R3_RM<opcode_div_f64,        int_postrisc_div_f64,       f64, f64, f64>;

def ABS_DIFF_VF64  : FORMAT_R3_RM<opcode_abs_diff_vf64,  int_postrisc_abs_diff_vf64,  v2f64, v2f64, v2f64>;
def NABS_DIFF_VF64 : FORMAT_R3_RM<opcode_nabs_diff_vf64, int_postrisc_nabs_diff_vf64, v2f64, v2f64, v2f64>;
def ADD_VF64       : FORMAT_R3_RM<opcode_add_vf64,       int_postrisc_add_vf64,       v2f64, v2f64, v2f64>;
def NADD_VF64      : FORMAT_R3_RM<opcode_nadd_vf64,      int_postrisc_nadd_vf64,      v2f64, v2f64, v2f64>;
def SUB_VF64       : FORMAT_R3_RM<opcode_sub_vf64,       int_postrisc_sub_vf64,       v2f64, v2f64, v2f64>;
def MUL_VF64       : FORMAT_R3_RM<opcode_mul_vf64,       int_postrisc_mul_vf64,       v2f64, v2f64, v2f64>;
def NMUL_VF64      : FORMAT_R3_RM<opcode_nmul_vf64,      int_postrisc_nmul_vf64,      v2f64, v2f64, v2f64>;
def DIV_VF64       : FORMAT_R3_RM<opcode_div_vf64,       int_postrisc_div_vf64,       v2f64, v2f64, v2f64>;
def ADD_ALT_VF64   : FORMAT_R3_RM<opcode_add_alt_vf64,   int_postrisc_add_alt_vf64,   v2f64, v2f64, v2f64>;
def SUB_ALT_VF64   : FORMAT_R3_RM<opcode_sub_alt_vf64,   int_postrisc_sub_alt_vf64,   v2f64, v2f64, v2f64>;
def ADD_HORIZ_VF64 : FORMAT_R3_RM<opcode_add_horiz_vf64, int_postrisc_add_horiz_vf64, v2f64, v2f64, v2f64>;
def SUB_HORIZ_VF64 : FORMAT_R3_RM<opcode_sub_horiz_vf64, int_postrisc_sub_horiz_vf64, v2f64, v2f64, v2f64>;
def MUL_HORIZ_VF64 : FORMAT_R3_RM<opcode_mul_horiz_vf64, int_postrisc_mul_horiz_vf64, v2f64, v2f64, v2f64>;

def ABS_DIFF_F128  : FORMAT_R3_RM<opcode_abs_diff_f128,  int_postrisc_abs_diff_f128,  f128, f128, f128>;
def NABS_DIFF_F128 : FORMAT_R3_RM<opcode_nabs_diff_f128, int_postrisc_nabs_diff_f128, f128, f128, f128>;
def ADD_F128       : FORMAT_R3_RM<opcode_add_f128,       int_postrisc_add_f128,       f128, f128, f128>;
def NADD_F128      : FORMAT_R3_RM<opcode_nadd_f128,      int_postrisc_nadd_f128,      f128, f128, f128>;
def SUB_F128       : FORMAT_R3_RM<opcode_sub_f128,       int_postrisc_sub_f128,       f128, f128, f128>;
def MUL_F128       : FORMAT_R3_RM<opcode_mul_f128,       int_postrisc_mul_f128,       f128, f128, f128>;
def NMUL_F128      : FORMAT_R3_RM<opcode_nmul_f128,      int_postrisc_nmul_f128,      f128, f128, f128>;
def DIV_F128       : FORMAT_R3_RM<opcode_div_f128,       int_postrisc_div_f128,       f128, f128, f128>;

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

defm : BinaryPatterns<ABS_DIFF_F16,  NABS_DIFF_F16,  ADD_F16,  SUB_F16,  MUL_F16,  DIV_F16,  NADD_F16,  NMUL_F16,  f16>;
defm : BinaryPatterns<ABS_DIFF_F32,  NABS_DIFF_F32,  ADD_F32,  SUB_F32,  MUL_F32,  DIV_F32,  NADD_F32,  NMUL_F32,  f32>;
defm : BinaryPatterns<ABS_DIFF_F64,  NABS_DIFF_F64,  ADD_F64,  SUB_F64,  MUL_F64,  DIV_F64,  NADD_F64,  NMUL_F64,  f64>;
defm : BinaryPatterns<ABS_DIFF_F128, NABS_DIFF_F128, ADD_F128, SUB_F128, MUL_F128, DIV_F128, NADD_F128, NMUL_F128, f128>;

defm : BinaryPatterns<ABS_DIFF_VF16, NABS_DIFF_VF16, ADD_VF16, SUB_VF16, MUL_VF16, DIV_VF16, NADD_VF16, NMUL_VF16, v8f16>;
defm : BinaryPatterns<ABS_DIFF_VF32, NABS_DIFF_VF32, ADD_VF32, SUB_VF32, MUL_VF32, DIV_VF32, NADD_VF32, NMUL_VF32, v4f32>;
defm : BinaryPatterns<ABS_DIFF_VF64, NABS_DIFF_VF64, ADD_VF64, SUB_VF64, MUL_VF64, DIV_VF64, NADD_VF64, NMUL_VF64, v2f64>;

//===----------------------------------------------------------------------===//
// conversions
//===----------------------------------------------------------------------===//
def CVT_F16_I32  : FORMAT_R2_RM<opcode_cvt_f16_i32,   int_postrisc_cvt_f16_i32,  i32,  f16>;
def CVT_F16_U32  : FORMAT_R2_RM<opcode_cvt_f16_u32,   int_postrisc_cvt_f16_u32,  i32,  f16>;
def CVT_F16_I64  : FORMAT_R2_RM<opcode_cvt_f16_i64,   int_postrisc_cvt_f16_i64,  i64,  f16>;
def CVT_F16_U64  : FORMAT_R2_RM<opcode_cvt_f16_u64,   int_postrisc_cvt_f16_u64,  i64,  f16>;
def CVT_F16_I128 : FORMAT_R2_RM<opcode_cvt_f16_i128,  int_postrisc_cvt_f16_i128, i128, f16>;
def CVT_F16_U128 : FORMAT_R2_RM<opcode_cvt_f16_u128,  int_postrisc_cvt_f16_u128, i128, f16>;

def CVT_I32_F16  : FORMAT_R2_RM<opcode_cvt_i32_f16,   int_postrisc_cvt_i32_f16,  f16,  i32>;
def CVT_U32_F16  : FORMAT_R2_RM<opcode_cvt_u32_f16,   int_postrisc_cvt_u32_f16,  f16,  i32>;
def CVT_I64_F16  : FORMAT_R2_RM<opcode_cvt_i64_f16,   int_postrisc_cvt_i64_f16,  f16,  i64>;
def CVT_U64_F16  : FORMAT_R2_RM<opcode_cvt_u64_f16,   int_postrisc_cvt_u64_f16,  f16,  i64>;
def CVT_I128_F16 : FORMAT_R2_RM<opcode_cvt_i128_f16,  int_postrisc_cvt_i128_f16, f16,  i128>;
def CVT_U128_F16 : FORMAT_R2_RM<opcode_cvt_u128_f16,  int_postrisc_cvt_u128_f16, f16,  i128>;

def CVT_F32_I32  : FORMAT_R2_RM<opcode_cvt_f32_i32,   int_postrisc_cvt_f32_i32,  i32,  f32>;
def CVT_F32_U32  : FORMAT_R2_RM<opcode_cvt_f32_u32,   int_postrisc_cvt_f32_u32,  i32,  f32>;
def CVT_F32_I64  : FORMAT_R2_RM<opcode_cvt_f32_i64,   int_postrisc_cvt_f32_i64,  i64,  f32>;
def CVT_F32_U64  : FORMAT_R2_RM<opcode_cvt_f32_u64,   int_postrisc_cvt_f32_u64,  i64,  f32>;
def CVT_F32_I128 : FORMAT_R2_RM<opcode_cvt_f32_i128,  int_postrisc_cvt_f32_i128, i128, f32>;
def CVT_F32_U128 : FORMAT_R2_RM<opcode_cvt_f32_u128,  int_postrisc_cvt_f32_u128, i128, f32>;

def CVT_I32_F32  : FORMAT_R2_RM<opcode_cvt_i32_f32,   int_postrisc_cvt_i32_f32,  f32,  i32>;
def CVT_U32_F32  : FORMAT_R2_RM<opcode_cvt_u32_f32,   int_postrisc_cvt_u32_f32,  f32,  i32>;
def CVT_I64_F32  : FORMAT_R2_RM<opcode_cvt_i64_f32,   int_postrisc_cvt_i64_f32,  f32,  i64>;
def CVT_U64_F32  : FORMAT_R2_RM<opcode_cvt_u64_f32,   int_postrisc_cvt_u64_f32,  f32,  i64>;
def CVT_I128_F32 : FORMAT_R2_RM<opcode_cvt_i128_f32,  int_postrisc_cvt_i128_f32, f32,  i128>;
def CVT_U128_F32 : FORMAT_R2_RM<opcode_cvt_u128_f32,  int_postrisc_cvt_u128_f32, f32,  i128>;

def CVT_F64_I32  : FORMAT_R2_RM<opcode_cvt_f64_i32,   int_postrisc_cvt_f64_i32,  i32,  f64>;
def CVT_F64_U32  : FORMAT_R2_RM<opcode_cvt_f64_u32,   int_postrisc_cvt_f64_u32,  i32,  f64>;
def CVT_F64_I64  : FORMAT_R2_RM<opcode_cvt_f64_i64,   int_postrisc_cvt_f64_i64,  i64,  f64>;
def CVT_F64_U64  : FORMAT_R2_RM<opcode_cvt_f64_u64,   int_postrisc_cvt_f64_u64,  i64,  f64>;
def CVT_F64_I128 : FORMAT_R2_RM<opcode_cvt_f64_i128,  int_postrisc_cvt_f64_i128, i128, f64>;
def CVT_F64_U128 : FORMAT_R2_RM<opcode_cvt_f64_u128,  int_postrisc_cvt_f64_u128, i128, f64>;

def CVT_I32_F64  : FORMAT_R2_RM<opcode_cvt_i32_f64,   int_postrisc_cvt_i32_f64,  f64,  i32>;
def CVT_U32_F64  : FORMAT_R2_RM<opcode_cvt_u32_f64,   int_postrisc_cvt_u32_f64,  f64,  i32>;
def CVT_I64_F64  : FORMAT_R2_RM<opcode_cvt_i64_f64,   int_postrisc_cvt_i64_f64,  f64,  i64>;
def CVT_U64_F64  : FORMAT_R2_RM<opcode_cvt_u64_f64,   int_postrisc_cvt_u64_f64,  f64,  i64>;
def CVT_I128_F64 : FORMAT_R2_RM<opcode_cvt_i128_f64,  int_postrisc_cvt_i128_f64, f64,  i128>;
def CVT_U128_F64 : FORMAT_R2_RM<opcode_cvt_u128_f64,  int_postrisc_cvt_u128_f64, f64,  i128>;

def CVT_F128_I32  : FORMAT_R2_RM<opcode_cvt_f128_i32,  int_postrisc_cvt_f128_i32,  i32,  f128>;
def CVT_F128_U32  : FORMAT_R2_RM<opcode_cvt_f128_u32,  int_postrisc_cvt_f128_u32,  i32,  f128>;
def CVT_F128_I64  : FORMAT_R2_RM<opcode_cvt_f128_i64,  int_postrisc_cvt_f128_i64,  i64,  f128>;
def CVT_F128_U64  : FORMAT_R2_RM<opcode_cvt_f128_u64,  int_postrisc_cvt_f128_u64,  i64,  f128>;
def CVT_F128_I128 : FORMAT_R2_RM<opcode_cvt_f128_i128, int_postrisc_cvt_f128_i128, i128, f128>;
def CVT_F128_U128 : FORMAT_R2_RM<opcode_cvt_f128_u128, int_postrisc_cvt_f128_u128, i128, f128>;

def CVT_I32_F128  : FORMAT_R2_RM<opcode_cvt_i32_f128,  int_postrisc_cvt_i32_f128,  f128,  i32>;
def CVT_U32_F128  : FORMAT_R2_RM<opcode_cvt_u32_f128,  int_postrisc_cvt_u32_f128,  f128,  i32>;
def CVT_I64_F128  : FORMAT_R2_RM<opcode_cvt_i64_f128,  int_postrisc_cvt_i64_f128,  f128,  i64>;
def CVT_U64_F128  : FORMAT_R2_RM<opcode_cvt_u64_f128,  int_postrisc_cvt_u64_f128,  f128,  i64>;
def CVT_I128_F128 : FORMAT_R2_RM<opcode_cvt_i128_f128, int_postrisc_cvt_i128_f128, f128,  i128>;
def CVT_U128_F128 : FORMAT_R2_RM<opcode_cvt_u128_f128, int_postrisc_cvt_u128_f128, f128,  i128>;

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

defm : ConversionPatterns<CVT_F16_I32,  CVT_I32_F16,  CVT_F16_U32,  CVT_U32_F16,  f16, i32>;
defm : ConversionPatterns<CVT_F16_I64,  CVT_I64_F16,  CVT_F16_U64,  CVT_U64_F16,  f16, i64>;
defm : ConversionPatterns<CVT_F16_I128, CVT_I128_F16, CVT_F16_U128, CVT_U128_F16, f16, i128>;

defm : ConversionPatterns<CVT_F32_I32,  CVT_I32_F32,  CVT_F32_U32,  CVT_U32_F32,  f32, i32>;
defm : ConversionPatterns<CVT_F32_I64,  CVT_I64_F32,  CVT_F32_U64,  CVT_U64_F32,  f32, i64>;
defm : ConversionPatterns<CVT_F32_I128, CVT_I128_F32, CVT_F32_U128, CVT_U128_F32, f32, i128>;

defm : ConversionPatterns<CVT_F64_I32,  CVT_I32_F64,  CVT_F64_U32,  CVT_U32_F64,  f64, i32>;
defm : ConversionPatterns<CVT_F64_I64,  CVT_I64_F64,  CVT_F64_U64,  CVT_U64_F64,  f64, i64>;
defm : ConversionPatterns<CVT_F64_I128, CVT_I128_F64, CVT_F64_U128, CVT_U128_F64, f64, i128>;

defm : ConversionPatterns<CVT_F128_I32,  CVT_I32_F128,  CVT_F128_U32,  CVT_U32_F128,  f128, i32>;
defm : ConversionPatterns<CVT_F128_I64,  CVT_I64_F128,  CVT_F128_U64,  CVT_U64_F128,  f128, i64>;
defm : ConversionPatterns<CVT_F128_I128, CVT_I128_F128, CVT_F128_U128, CVT_U128_F128, f128, i128>;

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

defm : LRint_LRound<CVT_F16_I32,  CVT_F16_I64,  f16>;
defm : LRint_LRound<CVT_F32_I32,  CVT_F32_I64,  f32>;
defm : LRint_LRound<CVT_F64_I32,  CVT_F64_I64,  f64>;
defm : LRint_LRound<CVT_F128_I32, CVT_F128_I64, f128>;

//===----------------------------------------------------------------------===//
// FIXME: i1 to fp => via i32 to fp
//===----------------------------------------------------------------------===//
def : Pat<(f16  (any_sint_to_fp i1:$src)), (CVT_I32_F16  GR:$src, rounding_mode_rtz.value)>;
def : Pat<(f16  (any_uint_to_fp i1:$src)), (CVT_U32_F16  GR:$src, rounding_mode_rtz.value)>;
def : Pat<(f32  (any_sint_to_fp i1:$src)), (CVT_I32_F32  GR:$src, rounding_mode_rtz.value)>;
def : Pat<(f32  (any_uint_to_fp i1:$src)), (CVT_U32_F32  GR:$src, rounding_mode_rtz.value)>;
def : Pat<(f64  (any_sint_to_fp i1:$src)), (CVT_I32_F64  GR:$src, rounding_mode_rtz.value)>;
def : Pat<(f64  (any_uint_to_fp i1:$src)), (CVT_U32_F64  GR:$src, rounding_mode_rtz.value)>;
def : Pat<(f128 (any_sint_to_fp i1:$src)), (CVT_I32_F128 GR:$src, rounding_mode_rtz.value)>;
def : Pat<(f128 (any_uint_to_fp i1:$src)), (CVT_U32_F128 GR:$src, rounding_mode_rtz.value)>;

//===----------------------------------------------------------------------===//
// vector conversions
//===----------------------------------------------------------------------===//
def CVT_VF16_VI16 : FORMAT_R2_RM<opcode_cvt_vf16_vi16, int_postrisc_cvt_vf16_vi16, v8i16, v8f16>;
def CVT_VF16_VU16 : FORMAT_R2_RM<opcode_cvt_vf16_vu16, int_postrisc_cvt_vf16_vu16, v8i16, v8f16>;
def CVT_VI16_VF16 : FORMAT_R2_RM<opcode_cvt_vi16_vf16, int_postrisc_cvt_vi16_vf16, v8f16, v8i16>;
def CVT_VU16_VF16 : FORMAT_R2_RM<opcode_cvt_vu16_vf16, int_postrisc_cvt_vu16_vf16, v8f16, v8i16>;

def CVT_VF32_VI32 : FORMAT_R2_RM<opcode_cvt_vf32_vi32, int_postrisc_cvt_vf32_vi32, v4i32, v4f32>;
def CVT_VF32_VU32 : FORMAT_R2_RM<opcode_cvt_vf32_vu32, int_postrisc_cvt_vf32_vu32, v4i32, v4f32>;
def CVT_VI32_VF32 : FORMAT_R2_RM<opcode_cvt_vi32_vf32, int_postrisc_cvt_vi32_vf32, v4f32, v4i32>;
def CVT_VU32_VF32 : FORMAT_R2_RM<opcode_cvt_vu32_vf32, int_postrisc_cvt_vu32_vf32, v4f32, v4i32>;

def CVT_VF64_VI64 : FORMAT_R2_RM<opcode_cvt_vf64_vi64, int_postrisc_cvt_vf64_vi64, v2i64, v2f64>;
def CVT_VF64_VU64 : FORMAT_R2_RM<opcode_cvt_vf64_vu64, int_postrisc_cvt_vf64_vu64, v2i64, v2f64>;
def CVT_VI64_VF64 : FORMAT_R2_RM<opcode_cvt_vi64_vf64, int_postrisc_cvt_vi64_vf64, v2f64, v2i64>;
def CVT_VU64_VF64 : FORMAT_R2_RM<opcode_cvt_vu64_vf64, int_postrisc_cvt_vu64_vf64, v2f64, v2i64>;

defm : ConversionPatterns<CVT_VF16_VI16, CVT_VI16_VF16, CVT_VF16_VU16, CVT_VU16_VF16, v8f16, v8i16>;
defm : ConversionPatterns<CVT_VF32_VI32, CVT_VI32_VF32, CVT_VF32_VU32, CVT_VU32_VF32, v4f32, v4i32>;
defm : ConversionPatterns<CVT_VF64_VI64, CVT_VI64_VF64, CVT_VF64_VU64, CVT_VU64_VF64, v2f64, v2i64>;

//===----------------------------------------------------------------------===//
// base patterns
//===----------------------------------------------------------------------===//
multiclass FP_BASE_INTRUCTIONS<string T, ValueType Ty>
{
  defm ABS_   # NAME : FORMAT_R2<!cast<misc_opx>("opcode_abs_"   # T)>;
  defm NABS_  # NAME : FORMAT_R2<!cast<misc_opx>("opcode_nabs_"  # T)>;
  defm NEG_   # NAME : FORMAT_R2<!cast<misc_opx>("opcode_neg_"   # T)>;

  defm MAX_     # NAME : FORMAT_R3<!cast<misc_opx>("opcode_max_"    # T)>;
  defm MIN_     # NAME : FORMAT_R3<!cast<misc_opx>("opcode_min_"    # T)>;

  defm MAXNUM_  # NAME : FORMAT_R3<!cast<misc_opx>("opcode_maxnum_" # T)>;
  defm MINNUM_  # NAME : FORMAT_R3<!cast<misc_opx>("opcode_minnum_" # T)>;

  defm ABS_MAX_ # NAME : FORMAT_R3<!cast<misc_opx>("opcode_abs_max_"   # T)>;
  defm ABS_MIN_ # NAME : FORMAT_R3<!cast<misc_opx>("opcode_abs_min_"   # T)>;

  defm MERGE_ # NAME : BUILTIN_R4<!cast<fused_opx>("opcode_merge_" # T), !cast<ClangBuiltin>("int_postrisc_merge_" # T), Ty, Ty, Ty, Ty>;
}

defm F16  : FP_BASE_INTRUCTIONS<"f16",  f16>;
defm F32  : FP_BASE_INTRUCTIONS<"f32",  f32>;
defm F64  : FP_BASE_INTRUCTIONS<"f64",  f64>;
defm F128 : FP_BASE_INTRUCTIONS<"f128", f128>;

//===----------------------------------------------------------------------===//
// FIXME: need stdc __builtin_fminimum, __builtin_fmaximum
//===----------------------------------------------------------------------===//
multiclass NanPropagatingMinMaxBuiltins<string T, ValueType Ty>
{
  def : Pat<(!cast<ClangBuiltin>("int_postrisc_minimum_" # T) Ty:$rb, Ty:$rc), (!cast<InstBase>("MIN_" # NAME) GR:$rb, GR:$rc)>;
  def : Pat<(!cast<ClangBuiltin>("int_postrisc_maximum_" # T) Ty:$rb, Ty:$rc), (!cast<InstBase>("MAX_" # NAME) GR:$rb, GR:$rc)>;
}

defm F16  : NanPropagatingMinMaxBuiltins<"f16",  f16>;
defm F32  : NanPropagatingMinMaxBuiltins<"f32",  f32>;
defm F64  : NanPropagatingMinMaxBuiltins<"f64",  f64>;
defm F128 : NanPropagatingMinMaxBuiltins<"f128", f128>;

//===----------------------------------------------------------------------===//
// both scalar/vector patterns
//===----------------------------------------------------------------------===//
multiclass FP_COMMON_PATTERNS<ValueType Ty>
{
  def : Pat<(fneg        Ty:$rb ), (!cast<InstBase>("NEG_"  # NAME) GR:$rb)>;
  def : Pat<(       fabs Ty:$rb ), (!cast<InstBase>("ABS_"  # NAME) GR:$rb)>;
  def : Pat<(fneg ( fabs Ty:$rb)), (!cast<InstBase>("NABS_" # NAME) GR:$rb)>;
  def : Pat<(      fsqrt Ty:$rb ), (!cast<InstBase>("SQRT_" # NAME) GR:$rb, rounding_mode_dyn.value)>;

  // NaN-propagating minimum/maximum that also treat -0.0 as less than 0.0. follow IEEE 754-2019 semantics.
  def : Pat<(any_fminimum Ty:$rb, Ty:$rc), (!cast<InstBase>("MIN_" # NAME) GR:$rb, GR:$rc)>;
  def : Pat<(any_fmaximum Ty:$rb, Ty:$rc), (!cast<InstBase>("MAX_" # NAME) GR:$rb, GR:$rc)>;

  // NaN-ignoring minimum/maximum that also treat -0.0 as less than 0.0. follow IEEE 754-2019 semantics.
  def : Pat<(any_fminnum Ty:$rb, Ty:$rc), (!cast<InstBase>("MINNUM_"  # NAME) GR:$rb, GR:$rc)>;
  def : Pat<(any_fmaxnum Ty:$rb, Ty:$rc), (!cast<InstBase>("MAXNUM_"  # NAME) GR:$rb, GR:$rc)>;
  def : Pat<(fminimumnum Ty:$rb, Ty:$rc), (!cast<InstBase>("MINNUM_"  # NAME) GR:$rb, GR:$rc)>;
  def : Pat<(fmaximumnum Ty:$rb, Ty:$rc), (!cast<InstBase>("MAXNUM_"  # NAME) GR:$rb, GR:$rc)>;

  // NAN??
  def : Pat<(any_fminnum (fabs Ty:$rb), (fabs Ty:$rc)), (!cast<InstBase>("ABS_MIN_" # NAME) GR:$rb, GR:$rc)>;
  def : Pat<(any_fmaxnum (fabs Ty:$rb), (fabs Ty:$rc)), (!cast<InstBase>("ABS_MAX_" # NAME) GR:$rb, GR:$rc)>;

  def : Pat<(fcopysign Ty:$rb, Ty:$rc), (!cast<InstBase>("MERGE_" # NAME) GR:$rc, GR:$rb, GR:$rb)>;
}

//===----------------------------------------------------------------------===//
// scalar-only patterns
//===----------------------------------------------------------------------===//
multiclass FP_SCALAR_PATTERNS<string T, ValueType Ty>
{
  defm NAME : FP_COMMON_PATTERNS<Ty>;

  defm CMP_OEQ_ # NAME : MISC_R3<!cast<misc_opx>("opcode_cmp_oeq_" # T), setoeq, i1, Ty>;
  defm CMP_ONE_ # NAME : MISC_R3<!cast<misc_opx>("opcode_cmp_one_" # T), setone, i1, Ty>;
  defm CMP_OLT_ # NAME : MISC_R3<!cast<misc_opx>("opcode_cmp_olt_" # T), setolt, i1, Ty>;
  defm CMP_OGE_ # NAME : MISC_R3<!cast<misc_opx>("opcode_cmp_oge_" # T), setoge, i1, Ty>;
  defm CMP_O_   # NAME : MISC_R3<!cast<misc_opx>("opcode_cmp_o_"   # T), seto,   i1, Ty>;
  defm CMP_UEQ_ # NAME : MISC_R3<!cast<misc_opx>("opcode_cmp_ueq_" # T), setueq, i1, Ty>;
  defm CMP_UNE_ # NAME : MISC_R3<!cast<misc_opx>("opcode_cmp_une_" # T), setune, i1, Ty>;
  defm CMP_ULT_ # NAME : MISC_R3<!cast<misc_opx>("opcode_cmp_ult_" # T), setult, i1, Ty>;
  defm CMP_UGE_ # NAME : MISC_R3<!cast<misc_opx>("opcode_cmp_uge_" # T), setuge, i1, Ty>;
  defm CMP_U_   # NAME : MISC_R3<!cast<misc_opx>("opcode_cmp_u_"   # T), setuo,  i1, Ty>;

  // arg swapping
  def : Pat<(i1 (setogt Ty:$rb, Ty:$rc)), (!cast<InstBase>("CMP_OLT_" # NAME) GR:$rc, GR:$rb)>;
  def : Pat<(i1 (setugt Ty:$rb, Ty:$rc)), (!cast<InstBase>("CMP_ULT_" # NAME) GR:$rc, GR:$rb)>;
  def : Pat<(i1 (setole Ty:$rb, Ty:$rc)), (!cast<InstBase>("CMP_OGE_" # NAME) GR:$rc, GR:$rb)>;
  def : Pat<(i1 (setule Ty:$rb, Ty:$rc)), (!cast<InstBase>("CMP_UGE_" # NAME) GR:$rc, GR:$rb)>;

  // fast-math doesn't differ ordered/unordered => use ordered forms
  def : Pat<(i1 (seteq Ty:$rb, Ty:$rc)), (!cast<InstBase>("CMP_OEQ_" # NAME) GR:$rb, GR:$rc)>;
  def : Pat<(i1 (setne Ty:$rb, Ty:$rc)), (!cast<InstBase>("CMP_ONE_" # NAME) GR:$rb, GR:$rc)>;
  def : Pat<(i1 (setlt Ty:$rb, Ty:$rc)), (!cast<InstBase>("CMP_OLT_" # NAME) GR:$rb, GR:$rc)>;
  def : Pat<(i1 (setge Ty:$rb, Ty:$rc)), (!cast<InstBase>("CMP_OGE_" # NAME) GR:$rb, GR:$rc)>;
  // fast-math args swap
  def : Pat<(i1 (setgt Ty:$rb, Ty:$rc)), (!cast<InstBase>("CMP_OLT_" # NAME) GR:$rc, GR:$rb)>;
  def : Pat<(i1 (setle Ty:$rb, Ty:$rc)), (!cast<InstBase>("CMP_OGE_" # NAME) GR:$rc, GR:$rb)>;
}

defm F16  : FP_SCALAR_PATTERNS<"f16",  f16>;
defm F32  : FP_SCALAR_PATTERNS<"f32",  f32>;
defm F64  : FP_SCALAR_PATTERNS<"f64",  f64>;
defm F128 : FP_SCALAR_PATTERNS<"f128", f128>;

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
def : Pat<(f16 (bitconvert (i16 (trunc i32:$val)))), (ZEXT_I16 GR:$val)>;
def : Pat<(f16 (bitconvert (i16 (trunc i32:$val)))), (SEXT_I16 GR:$val)>;

def : Pat<(i32 (zext (i16 (bitconvert f16:$val)))), (ZEXT_I16 GR:$val)>;
def : Pat<(i32 (sext (i16 (bitconvert f16:$val)))), (SEXT_I16 GR:$val)>;

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

defm CLASS_F16  : FpClass<opcode_class_f16>;
defm CLASS_F32  : FpClass<opcode_class_f32>;
defm CLASS_F64  : FpClass<opcode_class_f64>;
defm CLASS_F128 : FpClass<opcode_class_f128>;

def to_fclass_mask: SDNodeXForm<imm, [{
  uint64_t Check = N->getZExtValue();
  unsigned Mask = 0;

  if (Check & fcSNan)            Mask |= static_cast<unsigned>(Postrisc::FClassMask::SignalingNaN);
  if (Check & fcQNan)            Mask |= static_cast<unsigned>(Postrisc::FClassMask::QuietNaN);
  if (Check & fcPosInf)          Mask |= static_cast<unsigned>(Postrisc::FClassMask::PositiveInfinity);
  if (Check & fcNegInf)          Mask |= static_cast<unsigned>(Postrisc::FClassMask::NegativeInfinity);
  if (Check & fcPosNormal)       Mask |= static_cast<unsigned>(Postrisc::FClassMask::PositiveNormal);
  if (Check & fcNegNormal)       Mask |= static_cast<unsigned>(Postrisc::FClassMask::NegativeNormal);
  if (Check & fcPosSubnormal)    Mask |= static_cast<unsigned>(Postrisc::FClassMask::PositiveSubnormal);
  if (Check & fcNegSubnormal)    Mask |= static_cast<unsigned>(Postrisc::FClassMask::NegativeSubnormal);
  if (Check & fcPosZero)         Mask |= static_cast<unsigned>(Postrisc::FClassMask::PositiveZero);
  if (Check & fcNegZero)         Mask |= static_cast<unsigned>(Postrisc::FClassMask::NegativeZero);

  return CurDAG->getTargetConstant(Mask, SDLoc(N), MVT::i32);
}]>;

let AddedComplexity = Complexity_FpClass.value in { // FIXME: doesn't work, sometime prefer fcmp
  def : Pat<(i1 (is_fpclass  f16:$rb, (i32 timm:$mask))), (CLASS_F16  GR:$rb, (to_fclass_mask timm:$mask))>;
  def : Pat<(i1 (is_fpclass  f32:$rb, (i32 timm:$mask))), (CLASS_F32  GR:$rb, (to_fclass_mask timm:$mask))>;
  def : Pat<(i1 (is_fpclass  f64:$rb, (i32 timm:$mask))), (CLASS_F64  GR:$rb, (to_fclass_mask timm:$mask))>;
  def : Pat<(i1 (is_fpclass f128:$rb, (i32 timm:$mask))), (CLASS_F128 GR:$rb, (to_fclass_mask timm:$mask))>;
}
