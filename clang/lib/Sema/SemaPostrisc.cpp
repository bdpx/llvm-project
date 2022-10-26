//===------ SemaPostrisc.cpp ---- Postrisc target-specific routines -----===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
//  This file implements semantic analysis functions specific to Postrisc.
//
//===----------------------------------------------------------------------===//

#include "clang/Sema/SemaPostrisc.h"
#include "clang/Basic/TargetBuiltins.h"
#include "clang/Sema/Sema.h"
#include "llvm/Support/MathExtras.h"

namespace clang {

SemaPostrisc::SemaPostrisc(Sema &S) : SemaBase(S) {}

bool SemaPostrisc::CheckPostriscBuiltinFunctionCall(const TargetInfo &TI,
                                            unsigned BuiltinID, CallExpr *TheCall) {
  ASTContext &Context = getASTContext();
  const FunctionDecl *FD = SemaRef.getCurFunctionDecl();
  llvm::StringMap<bool> FeatureMap;
  Context.getFunctionFeatureMap(FeatureMap, FD);

  auto CheckRoundingMode = [&](unsigned ArgNum) -> bool {
    if (SemaRef.isConstantEvaluatedContext())
      return false;

    // We can't check the value of a dependent argument.
    Expr *Arg = TheCall->getArg(ArgNum);
    if (Arg->isTypeDependent() || Arg->isValueDependent())
      return false;

    // Check constant-ness first.
    llvm::APSInt Imm;
    if (SemaRef.BuiltinConstantArg(TheCall, ArgNum, Imm))
      return true;

    if (!llvm::is_contained({0u, 1u, 2u, 3u, 4u, 7u}, Imm.getZExtValue()))
      return Diag(TheCall->getBeginLoc(), diag::err_postrisc_invalid_rounding_mode)
            << toString(Imm, 10) << Arg->getSourceRange();

    return false;
  };


  switch (BuiltinID) {
  default:
    break;

  case Postrisc::BI__builtin_postrisc_aeskeygenassist:
    // Check if 1 (second) arg (immediate) is in [0, 255].
    return SemaRef.BuiltinConstantArgRange(TheCall, 1, 0, 255);

  // __builtin_postrisc_op(a, __POSTRISC_RM_RNE);
  // Check if 1 (2nd) arg (immediate) is rounding mode.
  case Postrisc::BI__builtin_postrisc_sqrt_f16:
  case Postrisc::BI__builtin_postrisc_sqrt_f32:
  case Postrisc::BI__builtin_postrisc_sqrt_f64:
  case Postrisc::BI__builtin_postrisc_sqrt_f128:

  case Postrisc::BI__builtin_postrisc_rsqrt_f16:
  case Postrisc::BI__builtin_postrisc_rsqrt_f32:
  case Postrisc::BI__builtin_postrisc_rsqrt_f64:
  case Postrisc::BI__builtin_postrisc_rsqrt_f128:

  case Postrisc::BI__builtin_postrisc_round_f16:
  case Postrisc::BI__builtin_postrisc_round_f32:
  case Postrisc::BI__builtin_postrisc_round_f64:
  case Postrisc::BI__builtin_postrisc_round_f128:

  case Postrisc::BI__builtin_postrisc_roundnx_f16:
  case Postrisc::BI__builtin_postrisc_roundnx_f32:
  case Postrisc::BI__builtin_postrisc_roundnx_f64:
  case Postrisc::BI__builtin_postrisc_roundnx_f128:

  // scalar fp <=> int conversions
  case Postrisc::BI__builtin_postrisc_cvt_i32_f16:
  case Postrisc::BI__builtin_postrisc_cvt_i64_f16:
  case Postrisc::BI__builtin_postrisc_cvt_i128_f16:
  case Postrisc::BI__builtin_postrisc_cvt_u32_f16:
  case Postrisc::BI__builtin_postrisc_cvt_u64_f16:
  case Postrisc::BI__builtin_postrisc_cvt_u128_f16:

  case Postrisc::BI__builtin_postrisc_cvt_f16_i32:
  case Postrisc::BI__builtin_postrisc_cvt_f16_i64:
  case Postrisc::BI__builtin_postrisc_cvt_f16_i128:
  case Postrisc::BI__builtin_postrisc_cvt_f16_u32:
  case Postrisc::BI__builtin_postrisc_cvt_f16_u64:
  case Postrisc::BI__builtin_postrisc_cvt_f16_u128:

  case Postrisc::BI__builtin_postrisc_cvt_i32_f32:
  case Postrisc::BI__builtin_postrisc_cvt_i64_f32:
  case Postrisc::BI__builtin_postrisc_cvt_i128_f32:
  case Postrisc::BI__builtin_postrisc_cvt_u32_f32:
  case Postrisc::BI__builtin_postrisc_cvt_u64_f32:
  case Postrisc::BI__builtin_postrisc_cvt_u128_f32:

  case Postrisc::BI__builtin_postrisc_cvt_f32_i32:
  case Postrisc::BI__builtin_postrisc_cvt_f32_i64:
  case Postrisc::BI__builtin_postrisc_cvt_f32_i128:
  case Postrisc::BI__builtin_postrisc_cvt_f32_u32:
  case Postrisc::BI__builtin_postrisc_cvt_f32_u64:
  case Postrisc::BI__builtin_postrisc_cvt_f32_u128:

  case Postrisc::BI__builtin_postrisc_cvt_i32_f64:
  case Postrisc::BI__builtin_postrisc_cvt_i64_f64:
  case Postrisc::BI__builtin_postrisc_cvt_i128_f64:
  case Postrisc::BI__builtin_postrisc_cvt_u32_f64:
  case Postrisc::BI__builtin_postrisc_cvt_u64_f64:
  case Postrisc::BI__builtin_postrisc_cvt_u128_f64:

  case Postrisc::BI__builtin_postrisc_cvt_f64_i32:
  case Postrisc::BI__builtin_postrisc_cvt_f64_i64:
  case Postrisc::BI__builtin_postrisc_cvt_f64_i128:
  case Postrisc::BI__builtin_postrisc_cvt_f64_u32:
  case Postrisc::BI__builtin_postrisc_cvt_f64_u64:
  case Postrisc::BI__builtin_postrisc_cvt_f64_u128:

  case Postrisc::BI__builtin_postrisc_cvt_i32_f128:
  case Postrisc::BI__builtin_postrisc_cvt_i64_f128:
  case Postrisc::BI__builtin_postrisc_cvt_i128_f128:
  case Postrisc::BI__builtin_postrisc_cvt_u32_f128:
  case Postrisc::BI__builtin_postrisc_cvt_u64_f128:
  case Postrisc::BI__builtin_postrisc_cvt_u128_f128:

  case Postrisc::BI__builtin_postrisc_cvt_f128_i32:
  case Postrisc::BI__builtin_postrisc_cvt_f128_i64:
  case Postrisc::BI__builtin_postrisc_cvt_f128_i128:
  case Postrisc::BI__builtin_postrisc_cvt_f128_u32:
  case Postrisc::BI__builtin_postrisc_cvt_f128_u64:
  case Postrisc::BI__builtin_postrisc_cvt_f128_u128:

  // vector fp <=> int conversions
  case Postrisc::BI__builtin_postrisc_cvt_vi16_vf16:
  case Postrisc::BI__builtin_postrisc_cvt_vu16_vf16:
  case Postrisc::BI__builtin_postrisc_cvt_vf16_vi16:
  case Postrisc::BI__builtin_postrisc_cvt_vf16_vu16:

  case Postrisc::BI__builtin_postrisc_cvt_vi32_vf32:
  case Postrisc::BI__builtin_postrisc_cvt_vu32_vf32:
  case Postrisc::BI__builtin_postrisc_cvt_vf32_vi32:
  case Postrisc::BI__builtin_postrisc_cvt_vf32_vu32:

  case Postrisc::BI__builtin_postrisc_cvt_vi64_vf64:
  case Postrisc::BI__builtin_postrisc_cvt_vu64_vf64:
  case Postrisc::BI__builtin_postrisc_cvt_vf64_vi64:
  case Postrisc::BI__builtin_postrisc_cvt_vf64_vu64:

  // fp narrowing conversions
  case Postrisc::BI__builtin_postrisc_cvt_f32_f16:
  case Postrisc::BI__builtin_postrisc_cvt_f64_f16:
  case Postrisc::BI__builtin_postrisc_cvt_f128_f16:
  case Postrisc::BI__builtin_postrisc_cvt_f64_f32:
  case Postrisc::BI__builtin_postrisc_cvt_f128_f32:
  case Postrisc::BI__builtin_postrisc_cvt_f128_f64:
    return CheckRoundingMode(1);

  // __builtin_postrisc_op(a, b, __POSTRISC_RM_RNE);
  // Check if 2 (3rd) arg (immediate) is rounding mode.
  case Postrisc::BI__builtin_postrisc_abs_diff_f16:
  case Postrisc::BI__builtin_postrisc_abs_diff_f32:
  case Postrisc::BI__builtin_postrisc_abs_diff_f64:
  case Postrisc::BI__builtin_postrisc_abs_diff_f128:
  case Postrisc::BI__builtin_postrisc_abs_diff_vf16:
  case Postrisc::BI__builtin_postrisc_abs_diff_vf32:
  case Postrisc::BI__builtin_postrisc_abs_diff_vf64:

  case Postrisc::BI__builtin_postrisc_nabs_diff_f16:
  case Postrisc::BI__builtin_postrisc_nabs_diff_f32:
  case Postrisc::BI__builtin_postrisc_nabs_diff_f64:
  case Postrisc::BI__builtin_postrisc_nabs_diff_f128:
  case Postrisc::BI__builtin_postrisc_nabs_diff_vf16:
  case Postrisc::BI__builtin_postrisc_nabs_diff_vf32:
  case Postrisc::BI__builtin_postrisc_nabs_diff_vf64:

  case Postrisc::BI__builtin_postrisc_add_f16:
  case Postrisc::BI__builtin_postrisc_add_f32:
  case Postrisc::BI__builtin_postrisc_add_f64:
  case Postrisc::BI__builtin_postrisc_add_f128:
  case Postrisc::BI__builtin_postrisc_add_vf16:
  case Postrisc::BI__builtin_postrisc_add_vf32:
  case Postrisc::BI__builtin_postrisc_add_vf64:

  case Postrisc::BI__builtin_postrisc_nadd_f16:
  case Postrisc::BI__builtin_postrisc_nadd_f32:
  case Postrisc::BI__builtin_postrisc_nadd_f64:
  case Postrisc::BI__builtin_postrisc_nadd_f128:
  case Postrisc::BI__builtin_postrisc_nadd_vf16:
  case Postrisc::BI__builtin_postrisc_nadd_vf32:
  case Postrisc::BI__builtin_postrisc_nadd_vf64:

  case Postrisc::BI__builtin_postrisc_sub_f16:
  case Postrisc::BI__builtin_postrisc_sub_f32:
  case Postrisc::BI__builtin_postrisc_sub_f64:
  case Postrisc::BI__builtin_postrisc_sub_f128:
  case Postrisc::BI__builtin_postrisc_sub_vf16:
  case Postrisc::BI__builtin_postrisc_sub_vf32:
  case Postrisc::BI__builtin_postrisc_sub_vf64:

  case Postrisc::BI__builtin_postrisc_mul_f16:
  case Postrisc::BI__builtin_postrisc_mul_f32:
  case Postrisc::BI__builtin_postrisc_mul_f64:
  case Postrisc::BI__builtin_postrisc_mul_f128:
  case Postrisc::BI__builtin_postrisc_mul_vf16:
  case Postrisc::BI__builtin_postrisc_mul_vf32:
  case Postrisc::BI__builtin_postrisc_mul_vf64:

  case Postrisc::BI__builtin_postrisc_nmul_f16:
  case Postrisc::BI__builtin_postrisc_nmul_f32:
  case Postrisc::BI__builtin_postrisc_nmul_f64:
  case Postrisc::BI__builtin_postrisc_nmul_f128:
  case Postrisc::BI__builtin_postrisc_nmul_vf16:
  case Postrisc::BI__builtin_postrisc_nmul_vf32:
  case Postrisc::BI__builtin_postrisc_nmul_vf64:

  case Postrisc::BI__builtin_postrisc_div_f16:
  case Postrisc::BI__builtin_postrisc_div_f32:
  case Postrisc::BI__builtin_postrisc_div_f64:
  case Postrisc::BI__builtin_postrisc_div_f128:
  case Postrisc::BI__builtin_postrisc_div_vf16:
  case Postrisc::BI__builtin_postrisc_div_vf32:
  case Postrisc::BI__builtin_postrisc_div_vf64:

  case Postrisc::BI__builtin_postrisc_dot_vf16:
  case Postrisc::BI__builtin_postrisc_dot_vf32:
  case Postrisc::BI__builtin_postrisc_dot_vf64:

  case Postrisc::BI__builtin_postrisc_add_alt_vf16:
  case Postrisc::BI__builtin_postrisc_add_alt_vf32:
  case Postrisc::BI__builtin_postrisc_add_alt_vf64:

  case Postrisc::BI__builtin_postrisc_sub_alt_vf16:
  case Postrisc::BI__builtin_postrisc_sub_alt_vf32:
  case Postrisc::BI__builtin_postrisc_sub_alt_vf64:

  case Postrisc::BI__builtin_postrisc_add_horiz_vf16:
  case Postrisc::BI__builtin_postrisc_add_horiz_vf32:
  case Postrisc::BI__builtin_postrisc_add_horiz_vf64:

  case Postrisc::BI__builtin_postrisc_sub_horiz_vf16:
  case Postrisc::BI__builtin_postrisc_sub_horiz_vf32:
  case Postrisc::BI__builtin_postrisc_sub_horiz_vf64:

  case Postrisc::BI__builtin_postrisc_mul_horiz_vf16:
  case Postrisc::BI__builtin_postrisc_mul_horiz_vf32:
  case Postrisc::BI__builtin_postrisc_mul_horiz_vf64:
    return CheckRoundingMode(2);

  // __builtin_postrisc_op(a, b, c, __POSTRISC_RM_RNE);
  // Check if 3 (4th) arg (immediate) is rounding mode.
  case Postrisc::BI__builtin_postrisc_madd_f16:
  case Postrisc::BI__builtin_postrisc_madd_f32:
  case Postrisc::BI__builtin_postrisc_madd_f64:
  case Postrisc::BI__builtin_postrisc_madd_f128:
  case Postrisc::BI__builtin_postrisc_madd_vf16:
  case Postrisc::BI__builtin_postrisc_madd_vf32:
  case Postrisc::BI__builtin_postrisc_madd_vf64:

  case Postrisc::BI__builtin_postrisc_nmadd_f16:
  case Postrisc::BI__builtin_postrisc_nmadd_f32:
  case Postrisc::BI__builtin_postrisc_nmadd_f64:
  case Postrisc::BI__builtin_postrisc_nmadd_f128:
  case Postrisc::BI__builtin_postrisc_nmadd_vf16:
  case Postrisc::BI__builtin_postrisc_nmadd_vf32:
  case Postrisc::BI__builtin_postrisc_nmadd_vf64:

  case Postrisc::BI__builtin_postrisc_msub_f16:
  case Postrisc::BI__builtin_postrisc_msub_f32:
  case Postrisc::BI__builtin_postrisc_msub_f64:
  case Postrisc::BI__builtin_postrisc_msub_f128:
  case Postrisc::BI__builtin_postrisc_msub_vf16:
  case Postrisc::BI__builtin_postrisc_msub_vf32:
  case Postrisc::BI__builtin_postrisc_msub_vf64:

  case Postrisc::BI__builtin_postrisc_nmsub_f16:
  case Postrisc::BI__builtin_postrisc_nmsub_f32:
  case Postrisc::BI__builtin_postrisc_nmsub_f64:
  case Postrisc::BI__builtin_postrisc_nmsub_f128:
  case Postrisc::BI__builtin_postrisc_nmsub_vf16:
  case Postrisc::BI__builtin_postrisc_nmsub_vf32:
  case Postrisc::BI__builtin_postrisc_nmsub_vf64:

  case Postrisc::BI__builtin_postrisc_madd_alt_vf16:
  case Postrisc::BI__builtin_postrisc_madd_alt_vf32:
  case Postrisc::BI__builtin_postrisc_madd_alt_vf64:

  case Postrisc::BI__builtin_postrisc_msub_alt_vf16:
  case Postrisc::BI__builtin_postrisc_msub_alt_vf32:
  case Postrisc::BI__builtin_postrisc_msub_alt_vf64:
    return CheckRoundingMode(3);

  // __builtin_postrisc_shift_imm(a, imm);
  // Check if 1 (2nd) arg (immediate) is proper shift immediate
  case Postrisc::BI__builtin_postrisc_sll_imm_vu8:
  case Postrisc::BI__builtin_postrisc_sra_imm_vi8:
  case Postrisc::BI__builtin_postrisc_srl_imm_vu8:
    return SemaRef.BuiltinConstantArgRange(TheCall, 1, 1, 7);

  case Postrisc::BI__builtin_postrisc_sll_imm_vu16:
  case Postrisc::BI__builtin_postrisc_sra_imm_vi16:
  case Postrisc::BI__builtin_postrisc_srl_imm_vu16:
    return SemaRef.BuiltinConstantArgRange(TheCall, 1, 1, 15);

  case Postrisc::BI__builtin_postrisc_sll_imm_vu32:
  case Postrisc::BI__builtin_postrisc_sra_imm_vi32:
  case Postrisc::BI__builtin_postrisc_srl_imm_vu32:
    return SemaRef.BuiltinConstantArgRange(TheCall, 1, 1, 31);

  case Postrisc::BI__builtin_postrisc_sll_imm_vu64:
  case Postrisc::BI__builtin_postrisc_sra_imm_vi64:
  case Postrisc::BI__builtin_postrisc_srl_imm_vu64:
    return SemaRef.BuiltinConstantArgRange(TheCall, 1, 1, 63);

  case Postrisc::BI__builtin_postrisc_int:
  case Postrisc::BI__builtin_postrisc_addc_vu8:
  case Postrisc::BI__builtin_postrisc_addc_vu16:
  case Postrisc::BI__builtin_postrisc_addc_vu32:
  case Postrisc::BI__builtin_postrisc_addc_vu64:
  case Postrisc::BI__builtin_postrisc_addo_vi8:
  case Postrisc::BI__builtin_postrisc_addo_vi16:
  case Postrisc::BI__builtin_postrisc_addo_vi32:
  case Postrisc::BI__builtin_postrisc_addo_vi64:
  case Postrisc::BI__builtin_postrisc_aesdec:
  case Postrisc::BI__builtin_postrisc_aesdeclast:
  case Postrisc::BI__builtin_postrisc_aesenc:
  case Postrisc::BI__builtin_postrisc_aesenclast:
  case Postrisc::BI__builtin_postrisc_aesimc:
  case Postrisc::BI__builtin_postrisc_avg_vi8:
  case Postrisc::BI__builtin_postrisc_avg_vi16:
  case Postrisc::BI__builtin_postrisc_avg_vi32:
  case Postrisc::BI__builtin_postrisc_avg_vi64:
  case Postrisc::BI__builtin_postrisc_avg_vu8:
  case Postrisc::BI__builtin_postrisc_avg_vu16:
  case Postrisc::BI__builtin_postrisc_avg_vu32:
  case Postrisc::BI__builtin_postrisc_avg_vu64:
  case Postrisc::BI__builtin_postrisc_clmul_hh:
  case Postrisc::BI__builtin_postrisc_clmul_hl:
  case Postrisc::BI__builtin_postrisc_clmul_ll:
  case Postrisc::BI__builtin_postrisc_cmp_eq_vi8:
  case Postrisc::BI__builtin_postrisc_cmp_eq_vi16:
  case Postrisc::BI__builtin_postrisc_cmp_eq_vi32:
  case Postrisc::BI__builtin_postrisc_cmp_eq_vi64:
  case Postrisc::BI__builtin_postrisc_cmp_lt_vi8:
  case Postrisc::BI__builtin_postrisc_cmp_lt_vi16:
  case Postrisc::BI__builtin_postrisc_cmp_lt_vi32:
  case Postrisc::BI__builtin_postrisc_cmp_lt_vi64:
  case Postrisc::BI__builtin_postrisc_cmp_lt_vu8:
  case Postrisc::BI__builtin_postrisc_cmp_lt_vu16:
  case Postrisc::BI__builtin_postrisc_cmp_lt_vu32:
  case Postrisc::BI__builtin_postrisc_cmp_lt_vu64:
  case Postrisc::BI__builtin_postrisc_cmp_o_vf16:
  case Postrisc::BI__builtin_postrisc_cmp_o_vf32:
  case Postrisc::BI__builtin_postrisc_cmp_o_vf64:
  case Postrisc::BI__builtin_postrisc_cmp_oeq_vf16:
  case Postrisc::BI__builtin_postrisc_cmp_oeq_vf32:
  case Postrisc::BI__builtin_postrisc_cmp_oeq_vf64:
  case Postrisc::BI__builtin_postrisc_cmp_oge_vf16:
  case Postrisc::BI__builtin_postrisc_cmp_oge_vf32:
  case Postrisc::BI__builtin_postrisc_cmp_oge_vf64:
  case Postrisc::BI__builtin_postrisc_cmp_olt_vf16:
  case Postrisc::BI__builtin_postrisc_cmp_olt_vf32:
  case Postrisc::BI__builtin_postrisc_cmp_olt_vf64:
  case Postrisc::BI__builtin_postrisc_cmp_one_vf16:
  case Postrisc::BI__builtin_postrisc_cmp_one_vf32:
  case Postrisc::BI__builtin_postrisc_cmp_one_vf64:
  case Postrisc::BI__builtin_postrisc_cmp_u_vf16:
  case Postrisc::BI__builtin_postrisc_cmp_u_vf32:
  case Postrisc::BI__builtin_postrisc_cmp_u_vf64:
  case Postrisc::BI__builtin_postrisc_cmp_ueq_vf16:
  case Postrisc::BI__builtin_postrisc_cmp_ueq_vf32:
  case Postrisc::BI__builtin_postrisc_cmp_ueq_vf64:
  case Postrisc::BI__builtin_postrisc_cmp_uge_vf16:
  case Postrisc::BI__builtin_postrisc_cmp_uge_vf32:
  case Postrisc::BI__builtin_postrisc_cmp_uge_vf64:
  case Postrisc::BI__builtin_postrisc_cmp_ult_vf16:
  case Postrisc::BI__builtin_postrisc_cmp_ult_vf32:
  case Postrisc::BI__builtin_postrisc_cmp_ult_vf64:
  case Postrisc::BI__builtin_postrisc_cmp_une_vf16:
  case Postrisc::BI__builtin_postrisc_cmp_une_vf32:
  case Postrisc::BI__builtin_postrisc_cmp_une_vf64:
  case Postrisc::BI__builtin_postrisc_cpuid:
  case Postrisc::BI__builtin_postrisc_crc32c:
  case Postrisc::BI__builtin_postrisc_dcbf:
  case Postrisc::BI__builtin_postrisc_dcbi:
  case Postrisc::BI__builtin_postrisc_dcbt:
  case Postrisc::BI__builtin_postrisc_eh_throw:
  case Postrisc::BI__builtin_postrisc_get_bsp:
  case Postrisc::BI__builtin_postrisc_get_cause:
  case Postrisc::BI__builtin_postrisc_get_cmcv:
  case Postrisc::BI__builtin_postrisc_get_dbr:
  case Postrisc::BI__builtin_postrisc_get_eca:
  case Postrisc::BI__builtin_postrisc_get_eip:
  case Postrisc::BI__builtin_postrisc_get_fpcr:
  case Postrisc::BI__builtin_postrisc_get_ibr:
  case Postrisc::BI__builtin_postrisc_get_ifa:
  case Postrisc::BI__builtin_postrisc_get_iib:
  case Postrisc::BI__builtin_postrisc_get_iip:
  case Postrisc::BI__builtin_postrisc_get_iipa:
  case Postrisc::BI__builtin_postrisc_get_ip:
  case Postrisc::BI__builtin_postrisc_get_ipsr:
  case Postrisc::BI__builtin_postrisc_get_irr0:
  case Postrisc::BI__builtin_postrisc_get_irr1:
  case Postrisc::BI__builtin_postrisc_get_irr2:
  case Postrisc::BI__builtin_postrisc_get_irr3:
  case Postrisc::BI__builtin_postrisc_get_isr0:
  case Postrisc::BI__builtin_postrisc_get_isr1:
  case Postrisc::BI__builtin_postrisc_get_isr2:
  case Postrisc::BI__builtin_postrisc_get_isr3:
  case Postrisc::BI__builtin_postrisc_get_itc:
  case Postrisc::BI__builtin_postrisc_get_itcv:
  case Postrisc::BI__builtin_postrisc_get_itm:
  case Postrisc::BI__builtin_postrisc_get_iv:
  case Postrisc::BI__builtin_postrisc_get_iva:
  case Postrisc::BI__builtin_postrisc_get_kip:
  case Postrisc::BI__builtin_postrisc_get_krsp:
  case Postrisc::BI__builtin_postrisc_get_ksp:
  case Postrisc::BI__builtin_postrisc_get_lid:
  case Postrisc::BI__builtin_postrisc_get_mr:
  case Postrisc::BI__builtin_postrisc_get_peb:
  case Postrisc::BI__builtin_postrisc_get_pmv:
  case Postrisc::BI__builtin_postrisc_get_psr:
  case Postrisc::BI__builtin_postrisc_get_pta:
  case Postrisc::BI__builtin_postrisc_get_reip:
  case Postrisc::BI__builtin_postrisc_get_rsc:
  case Postrisc::BI__builtin_postrisc_get_rsp:
  case Postrisc::BI__builtin_postrisc_get_teb:
  case Postrisc::BI__builtin_postrisc_get_tpr:
  case Postrisc::BI__builtin_postrisc_get_tsv:
  case Postrisc::BI__builtin_postrisc_halt:
  case Postrisc::BI__builtin_postrisc_icbi:
  case Postrisc::BI__builtin_postrisc_maximum_f16:
  case Postrisc::BI__builtin_postrisc_maximum_f32:
  case Postrisc::BI__builtin_postrisc_maximum_f64:
  case Postrisc::BI__builtin_postrisc_maximum_f128:
  case Postrisc::BI__builtin_postrisc_merge_f16:
  case Postrisc::BI__builtin_postrisc_merge_f32:
  case Postrisc::BI__builtin_postrisc_merge_f64:
  case Postrisc::BI__builtin_postrisc_merge_f128:
  case Postrisc::BI__builtin_postrisc_merge_high_vf16:
  case Postrisc::BI__builtin_postrisc_merge_high_vf32:
  case Postrisc::BI__builtin_postrisc_merge_high_vf64:
  case Postrisc::BI__builtin_postrisc_merge_high_vu8:
  case Postrisc::BI__builtin_postrisc_merge_high_vu16:
  case Postrisc::BI__builtin_postrisc_merge_high_vu32:
  case Postrisc::BI__builtin_postrisc_merge_high_vu64:
  case Postrisc::BI__builtin_postrisc_merge_low_vf16:
  case Postrisc::BI__builtin_postrisc_merge_low_vf32:
  case Postrisc::BI__builtin_postrisc_merge_low_vf64:
  case Postrisc::BI__builtin_postrisc_merge_low_vu8:
  case Postrisc::BI__builtin_postrisc_merge_low_vu16:
  case Postrisc::BI__builtin_postrisc_merge_low_vu32:
  case Postrisc::BI__builtin_postrisc_merge_low_vu64:
  case Postrisc::BI__builtin_postrisc_merge_vf16:
  case Postrisc::BI__builtin_postrisc_merge_vf32:
  case Postrisc::BI__builtin_postrisc_merge_vf64:
  case Postrisc::BI__builtin_postrisc_minimum_f16:
  case Postrisc::BI__builtin_postrisc_minimum_f32:
  case Postrisc::BI__builtin_postrisc_minimum_f64:
  case Postrisc::BI__builtin_postrisc_minimum_f128:
  case Postrisc::BI__builtin_postrisc_nop:
  case Postrisc::BI__builtin_postrisc_nop_l:
  case Postrisc::BI__builtin_postrisc_nul_never:
  case Postrisc::BI__builtin_postrisc_pack_mod_vu16:
  case Postrisc::BI__builtin_postrisc_pack_mod_vu32:
  case Postrisc::BI__builtin_postrisc_pack_mod_vu64:
  case Postrisc::BI__builtin_postrisc_pack_sat_vi16:
  case Postrisc::BI__builtin_postrisc_pack_sat_vi32:
  case Postrisc::BI__builtin_postrisc_pack_sat_vi64:
  case Postrisc::BI__builtin_postrisc_pack_sat_vu16:
  case Postrisc::BI__builtin_postrisc_pack_sat_vu32:
  case Postrisc::BI__builtin_postrisc_pack_sat_vu64:
  case Postrisc::BI__builtin_postrisc_pack_usat_vi16:
  case Postrisc::BI__builtin_postrisc_pack_usat_vi32:
  case Postrisc::BI__builtin_postrisc_pack_usat_vi64:
  case Postrisc::BI__builtin_postrisc_perm_vu8:
  case Postrisc::BI__builtin_postrisc_random:
  case Postrisc::BI__builtin_postrisc_random_n:
  case Postrisc::BI__builtin_postrisc_rfi:
  case Postrisc::BI__builtin_postrisc_rol_vu8:
  case Postrisc::BI__builtin_postrisc_rol_vu16:
  case Postrisc::BI__builtin_postrisc_rol_vu32:
  case Postrisc::BI__builtin_postrisc_rol_vu64:
  case Postrisc::BI__builtin_postrisc_ror_vu8:
  case Postrisc::BI__builtin_postrisc_ror_vu16:
  case Postrisc::BI__builtin_postrisc_ror_vu32:
  case Postrisc::BI__builtin_postrisc_ror_vu64:
  case Postrisc::BI__builtin_postrisc_rscover:
  case Postrisc::BI__builtin_postrisc_rsflush:
  case Postrisc::BI__builtin_postrisc_rsload:
  case Postrisc::BI__builtin_postrisc_set_bsp:
  case Postrisc::BI__builtin_postrisc_set_cause:
  case Postrisc::BI__builtin_postrisc_set_cmcv:
  case Postrisc::BI__builtin_postrisc_set_dbr:
  case Postrisc::BI__builtin_postrisc_set_dtr:
  case Postrisc::BI__builtin_postrisc_set_eca:
  case Postrisc::BI__builtin_postrisc_set_eip:
  case Postrisc::BI__builtin_postrisc_set_fpcr:
  case Postrisc::BI__builtin_postrisc_set_ibr:
  case Postrisc::BI__builtin_postrisc_set_ifa:
  case Postrisc::BI__builtin_postrisc_set_iib:
  case Postrisc::BI__builtin_postrisc_set_iip:
  case Postrisc::BI__builtin_postrisc_set_iipa:
  case Postrisc::BI__builtin_postrisc_set_ip:
  case Postrisc::BI__builtin_postrisc_set_ipsr:
  case Postrisc::BI__builtin_postrisc_set_irr0:
  case Postrisc::BI__builtin_postrisc_set_irr1:
  case Postrisc::BI__builtin_postrisc_set_irr2:
  case Postrisc::BI__builtin_postrisc_set_irr3:
  case Postrisc::BI__builtin_postrisc_set_isr0:
  case Postrisc::BI__builtin_postrisc_set_isr1:
  case Postrisc::BI__builtin_postrisc_set_isr2:
  case Postrisc::BI__builtin_postrisc_set_isr3:
  case Postrisc::BI__builtin_postrisc_set_itc:
  case Postrisc::BI__builtin_postrisc_set_itcv:
  case Postrisc::BI__builtin_postrisc_set_itm:
  case Postrisc::BI__builtin_postrisc_set_itr:
  case Postrisc::BI__builtin_postrisc_set_iv:
  case Postrisc::BI__builtin_postrisc_set_iva:
  case Postrisc::BI__builtin_postrisc_set_kip:
  case Postrisc::BI__builtin_postrisc_set_krsp:
  case Postrisc::BI__builtin_postrisc_set_ksp:
  case Postrisc::BI__builtin_postrisc_set_lid:
  case Postrisc::BI__builtin_postrisc_set_mr:
  case Postrisc::BI__builtin_postrisc_set_peb:
  case Postrisc::BI__builtin_postrisc_set_pmv:
  case Postrisc::BI__builtin_postrisc_set_psr:
  case Postrisc::BI__builtin_postrisc_set_pta:
  case Postrisc::BI__builtin_postrisc_set_reip:
  case Postrisc::BI__builtin_postrisc_set_rsc:
  case Postrisc::BI__builtin_postrisc_set_rsp:
  case Postrisc::BI__builtin_postrisc_set_teb:
  case Postrisc::BI__builtin_postrisc_set_thread_pointer:
  case Postrisc::BI__builtin_postrisc_set_tpr:
  case Postrisc::BI__builtin_postrisc_set_tsv:
  case Postrisc::BI__builtin_postrisc_sll_vu8:
  case Postrisc::BI__builtin_postrisc_sll_vu16:
  case Postrisc::BI__builtin_postrisc_sll_vu32:
  case Postrisc::BI__builtin_postrisc_sll_vu64:
  case Postrisc::BI__builtin_postrisc_sra_vi8:
  case Postrisc::BI__builtin_postrisc_sra_vi16:
  case Postrisc::BI__builtin_postrisc_sra_vi32:
  case Postrisc::BI__builtin_postrisc_sra_vi64:
  case Postrisc::BI__builtin_postrisc_srl_vu8:
  case Postrisc::BI__builtin_postrisc_srl_vu16:
  case Postrisc::BI__builtin_postrisc_srl_vu32:
  case Postrisc::BI__builtin_postrisc_srl_vu64:
  case Postrisc::BI__builtin_postrisc_stack_pointer:
  case Postrisc::BI__builtin_postrisc_subb_vu8:
  case Postrisc::BI__builtin_postrisc_subb_vu16:
  case Postrisc::BI__builtin_postrisc_subb_vu32:
  case Postrisc::BI__builtin_postrisc_subb_vu64:
  case Postrisc::BI__builtin_postrisc_subo_vi8:
  case Postrisc::BI__builtin_postrisc_subo_vi16:
  case Postrisc::BI__builtin_postrisc_subo_vi32:
  case Postrisc::BI__builtin_postrisc_subo_vi64:
  case Postrisc::BI__builtin_postrisc_syscall:
  case Postrisc::BI__builtin_postrisc_sysret:
  case Postrisc::BI__builtin_postrisc_tlb_purge:
  case Postrisc::BI__builtin_postrisc_tpa:
  case Postrisc::BI__builtin_postrisc_undef:
  case Postrisc::BI__builtin_postrisc_unpack_high_vf16:
  case Postrisc::BI__builtin_postrisc_unpack_high_vf32:
  case Postrisc::BI__builtin_postrisc_unpack_high_vf64:
  case Postrisc::BI__builtin_postrisc_unpack_high_vi8:
  case Postrisc::BI__builtin_postrisc_unpack_high_vi16:
  case Postrisc::BI__builtin_postrisc_unpack_high_vi32:
  case Postrisc::BI__builtin_postrisc_unpack_high_vu8:
  case Postrisc::BI__builtin_postrisc_unpack_high_vu16:
  case Postrisc::BI__builtin_postrisc_unpack_high_vu32:
  case Postrisc::BI__builtin_postrisc_unpack_low_vf16:
  case Postrisc::BI__builtin_postrisc_unpack_low_vf32:
  case Postrisc::BI__builtin_postrisc_unpack_low_vf64:
  case Postrisc::BI__builtin_postrisc_unpack_low_vi8:
  case Postrisc::BI__builtin_postrisc_unpack_low_vi16:
  case Postrisc::BI__builtin_postrisc_unpack_low_vi32:
  case Postrisc::BI__builtin_postrisc_unpack_low_vu8:
  case Postrisc::BI__builtin_postrisc_unpack_low_vu16:
  case Postrisc::BI__builtin_postrisc_unpack_low_vu32:
    break;
  }
  // default: ok
  return false;
}

} // namespace clang
