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

    if (!llvm::is_contained({0u, 1u, 2u, 3u, 4u, 5u, 6u, 7u}, Imm.getZExtValue()))
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
  case Postrisc::BI__builtin_postrisc_fsqrth:
  case Postrisc::BI__builtin_postrisc_fsqrts:
  case Postrisc::BI__builtin_postrisc_fsqrtd:
  case Postrisc::BI__builtin_postrisc_fsqrtq:

  case Postrisc::BI__builtin_postrisc_frsqrth:
  case Postrisc::BI__builtin_postrisc_frsqrts:
  case Postrisc::BI__builtin_postrisc_frsqrtd:
  case Postrisc::BI__builtin_postrisc_frsqrtq:

  case Postrisc::BI__builtin_postrisc_frndh:
  case Postrisc::BI__builtin_postrisc_frnds:
  case Postrisc::BI__builtin_postrisc_frndd:
  case Postrisc::BI__builtin_postrisc_frndq:

  case Postrisc::BI__builtin_postrisc_frndxh:
  case Postrisc::BI__builtin_postrisc_frndxs:
  case Postrisc::BI__builtin_postrisc_frndxd:
  case Postrisc::BI__builtin_postrisc_frndxq:

  // scalar fp <=> int conversions
  case Postrisc::BI__builtin_postrisc_fiwtoh:
  case Postrisc::BI__builtin_postrisc_fidtoh:
  case Postrisc::BI__builtin_postrisc_fiqtoh:
  case Postrisc::BI__builtin_postrisc_fuwtoh:
  case Postrisc::BI__builtin_postrisc_fudtoh:
  case Postrisc::BI__builtin_postrisc_fuqtoh:

  case Postrisc::BI__builtin_postrisc_fhtoiw:
  case Postrisc::BI__builtin_postrisc_fhtoid:
  case Postrisc::BI__builtin_postrisc_fhtoiq:
  case Postrisc::BI__builtin_postrisc_fhtouw:
  case Postrisc::BI__builtin_postrisc_fhtoud:
  case Postrisc::BI__builtin_postrisc_fhtouq:

  case Postrisc::BI__builtin_postrisc_fiwtos:
  case Postrisc::BI__builtin_postrisc_fidtos:
  case Postrisc::BI__builtin_postrisc_fiqtos:
  case Postrisc::BI__builtin_postrisc_fuwtos:
  case Postrisc::BI__builtin_postrisc_fudtos:
  case Postrisc::BI__builtin_postrisc_fuqtos:

  case Postrisc::BI__builtin_postrisc_fstoiw:
  case Postrisc::BI__builtin_postrisc_fstoid:
  case Postrisc::BI__builtin_postrisc_fstoiq:
  case Postrisc::BI__builtin_postrisc_fstouw:
  case Postrisc::BI__builtin_postrisc_fstoud:
  case Postrisc::BI__builtin_postrisc_fstouq:

  case Postrisc::BI__builtin_postrisc_fiwtod:
  case Postrisc::BI__builtin_postrisc_fidtod:
  case Postrisc::BI__builtin_postrisc_fiqtod:
  case Postrisc::BI__builtin_postrisc_fuwtod:
  case Postrisc::BI__builtin_postrisc_fudtod:
  case Postrisc::BI__builtin_postrisc_fuqtod:

  case Postrisc::BI__builtin_postrisc_fdtoiw:
  case Postrisc::BI__builtin_postrisc_fdtoid:
  case Postrisc::BI__builtin_postrisc_fdtoiq:
  case Postrisc::BI__builtin_postrisc_fdtouw:
  case Postrisc::BI__builtin_postrisc_fdtoud:
  case Postrisc::BI__builtin_postrisc_fdtouq:

  case Postrisc::BI__builtin_postrisc_fiwtoq:
  case Postrisc::BI__builtin_postrisc_fidtoq:
  case Postrisc::BI__builtin_postrisc_fiqtoq:
  case Postrisc::BI__builtin_postrisc_fuwtoq:
  case Postrisc::BI__builtin_postrisc_fudtoq:
  case Postrisc::BI__builtin_postrisc_fuqtoq:

  case Postrisc::BI__builtin_postrisc_fqtoiw:
  case Postrisc::BI__builtin_postrisc_fqtoid:
  case Postrisc::BI__builtin_postrisc_fqtoiq:
  case Postrisc::BI__builtin_postrisc_fqtouw:
  case Postrisc::BI__builtin_postrisc_fqtoud:
  case Postrisc::BI__builtin_postrisc_fqtouq:

  // vector fp <=> int conversions
  case Postrisc::BI__builtin_postrisc_vfihtoh:
  case Postrisc::BI__builtin_postrisc_vfuhtoh:
  case Postrisc::BI__builtin_postrisc_vfhtoih:
  case Postrisc::BI__builtin_postrisc_vfhtouh:

  case Postrisc::BI__builtin_postrisc_vfiwtos:
  case Postrisc::BI__builtin_postrisc_vfuwtos:
  case Postrisc::BI__builtin_postrisc_vfstoiw:
  case Postrisc::BI__builtin_postrisc_vfstouw:

  case Postrisc::BI__builtin_postrisc_vfidtod:
  case Postrisc::BI__builtin_postrisc_vfudtod:
  case Postrisc::BI__builtin_postrisc_vfdtoid:
  case Postrisc::BI__builtin_postrisc_vfdtoud:

  // fp narrowing conversions
  case Postrisc::BI__builtin_postrisc_fstoh:
  case Postrisc::BI__builtin_postrisc_fdtoh:
  case Postrisc::BI__builtin_postrisc_fqtoh:
  case Postrisc::BI__builtin_postrisc_fdtos:
  case Postrisc::BI__builtin_postrisc_fqtos:
  case Postrisc::BI__builtin_postrisc_fqtod:
    return CheckRoundingMode(1);

  // __builtin_postrisc_op(a, b, __POSTRISC_RM_RNE);
  // Check if 2 (3rd) arg (immediate) is rounding mode.
  case Postrisc::BI__builtin_postrisc_fabdh:
  case Postrisc::BI__builtin_postrisc_fabds:
  case Postrisc::BI__builtin_postrisc_fabdd:
  case Postrisc::BI__builtin_postrisc_fabdq:

  case Postrisc::BI__builtin_postrisc_fnabdh:
  case Postrisc::BI__builtin_postrisc_fnabds:
  case Postrisc::BI__builtin_postrisc_fnabdd:
  case Postrisc::BI__builtin_postrisc_fnabdq:

  case Postrisc::BI__builtin_postrisc_faddh:
  case Postrisc::BI__builtin_postrisc_fadds:
  case Postrisc::BI__builtin_postrisc_faddd:
  case Postrisc::BI__builtin_postrisc_faddq:

  case Postrisc::BI__builtin_postrisc_fnaddh:
  case Postrisc::BI__builtin_postrisc_fnadds:
  case Postrisc::BI__builtin_postrisc_fnaddd:
  case Postrisc::BI__builtin_postrisc_fnaddq:

  case Postrisc::BI__builtin_postrisc_fsubh:
  case Postrisc::BI__builtin_postrisc_fsubs:
  case Postrisc::BI__builtin_postrisc_fsubd:
  case Postrisc::BI__builtin_postrisc_fsubq:

  case Postrisc::BI__builtin_postrisc_fmulh:
  case Postrisc::BI__builtin_postrisc_fmuls:
  case Postrisc::BI__builtin_postrisc_fmuld:
  case Postrisc::BI__builtin_postrisc_fmulq:

  case Postrisc::BI__builtin_postrisc_fnmulh:
  case Postrisc::BI__builtin_postrisc_fnmuls:
  case Postrisc::BI__builtin_postrisc_fnmuld:
  case Postrisc::BI__builtin_postrisc_fnmulq:

  case Postrisc::BI__builtin_postrisc_fdivh:
  case Postrisc::BI__builtin_postrisc_fdivs:
  case Postrisc::BI__builtin_postrisc_fdivd:
  case Postrisc::BI__builtin_postrisc_fdivq:

  case Postrisc::BI__builtin_postrisc_vfabdh:
  case Postrisc::BI__builtin_postrisc_vfabds:
  case Postrisc::BI__builtin_postrisc_vfabdd:

  case Postrisc::BI__builtin_postrisc_vfnabdh:
  case Postrisc::BI__builtin_postrisc_vfnabds:
  case Postrisc::BI__builtin_postrisc_vfnabdd:

  case Postrisc::BI__builtin_postrisc_vfaddh:
  case Postrisc::BI__builtin_postrisc_vfadds:
  case Postrisc::BI__builtin_postrisc_vfaddd:

  case Postrisc::BI__builtin_postrisc_vfnaddh:
  case Postrisc::BI__builtin_postrisc_vfnadds:
  case Postrisc::BI__builtin_postrisc_vfnaddd:

  case Postrisc::BI__builtin_postrisc_vfsubh:
  case Postrisc::BI__builtin_postrisc_vfsubs:
  case Postrisc::BI__builtin_postrisc_vfsubd:

  case Postrisc::BI__builtin_postrisc_vfmulh:
  case Postrisc::BI__builtin_postrisc_vfmuls:
  case Postrisc::BI__builtin_postrisc_vfmuld:

  case Postrisc::BI__builtin_postrisc_vfnmulh:
  case Postrisc::BI__builtin_postrisc_vfnmuls:
  case Postrisc::BI__builtin_postrisc_vfnmuld:

  case Postrisc::BI__builtin_postrisc_vfdivh:
  case Postrisc::BI__builtin_postrisc_vfdivs:
  case Postrisc::BI__builtin_postrisc_vfdivd:

  case Postrisc::BI__builtin_postrisc_vfdoth:
  case Postrisc::BI__builtin_postrisc_vfdots:
  case Postrisc::BI__builtin_postrisc_vfdotd:

  case Postrisc::BI__builtin_postrisc_vfaddsubh:
  case Postrisc::BI__builtin_postrisc_vfaddsubs:
  case Postrisc::BI__builtin_postrisc_vfaddsubd:

  case Postrisc::BI__builtin_postrisc_vfsubaddh:
  case Postrisc::BI__builtin_postrisc_vfsubadds:
  case Postrisc::BI__builtin_postrisc_vfsubaddd:

  case Postrisc::BI__builtin_postrisc_vfhaddh:
  case Postrisc::BI__builtin_postrisc_vfhadds:
  case Postrisc::BI__builtin_postrisc_vfhaddd:

  case Postrisc::BI__builtin_postrisc_vfhsubh:
  case Postrisc::BI__builtin_postrisc_vfhsubs:
  case Postrisc::BI__builtin_postrisc_vfhsubd:

  case Postrisc::BI__builtin_postrisc_vfhmulh:
  case Postrisc::BI__builtin_postrisc_vfhmuls:
  case Postrisc::BI__builtin_postrisc_vfhmuld:
    return CheckRoundingMode(2);

  // __builtin_postrisc_op(a, b, c, __POSTRISC_RM_RNE);
  // Check if 3 (4th) arg (immediate) is rounding mode.
  case Postrisc::BI__builtin_postrisc_fmaddh:
  case Postrisc::BI__builtin_postrisc_fmadds:
  case Postrisc::BI__builtin_postrisc_fmaddd:
  case Postrisc::BI__builtin_postrisc_fmaddq:

  case Postrisc::BI__builtin_postrisc_fnmaddh:
  case Postrisc::BI__builtin_postrisc_fnmadds:
  case Postrisc::BI__builtin_postrisc_fnmaddd:
  case Postrisc::BI__builtin_postrisc_fnmaddq:

  case Postrisc::BI__builtin_postrisc_fmsubh:
  case Postrisc::BI__builtin_postrisc_fmsubs:
  case Postrisc::BI__builtin_postrisc_fmsubd:
  case Postrisc::BI__builtin_postrisc_fmsubq:

  case Postrisc::BI__builtin_postrisc_fnmsubh:
  case Postrisc::BI__builtin_postrisc_fnmsubs:
  case Postrisc::BI__builtin_postrisc_fnmsubd:
  case Postrisc::BI__builtin_postrisc_fnmsubq:

  case Postrisc::BI__builtin_postrisc_vfmaddh:
  case Postrisc::BI__builtin_postrisc_vfmadds:
  case Postrisc::BI__builtin_postrisc_vfmaddd:

  case Postrisc::BI__builtin_postrisc_vfnmaddh:
  case Postrisc::BI__builtin_postrisc_vfnmadds:
  case Postrisc::BI__builtin_postrisc_vfnmaddd:

  case Postrisc::BI__builtin_postrisc_vfmsubh:
  case Postrisc::BI__builtin_postrisc_vfmsubs:
  case Postrisc::BI__builtin_postrisc_vfmsubd:

  case Postrisc::BI__builtin_postrisc_vfnmsubh:
  case Postrisc::BI__builtin_postrisc_vfnmsubs:
  case Postrisc::BI__builtin_postrisc_vfnmsubd:

  case Postrisc::BI__builtin_postrisc_vfmaddsubh:
  case Postrisc::BI__builtin_postrisc_vfmaddsubs:
  case Postrisc::BI__builtin_postrisc_vfmaddsubd:

  case Postrisc::BI__builtin_postrisc_vfmsubaddh:
  case Postrisc::BI__builtin_postrisc_vfmsubadds:
  case Postrisc::BI__builtin_postrisc_vfmsubaddd:
    return CheckRoundingMode(3);

  // __builtin_postrisc_shift_imm(a, imm);
  // Check if 1 (2nd) arg (immediate) is proper shift immediate
  case Postrisc::BI__builtin_postrisc_vsllib:
  case Postrisc::BI__builtin_postrisc_vsraib:
  case Postrisc::BI__builtin_postrisc_vsrlib:
    return SemaRef.BuiltinConstantArgRange(TheCall, 1, 1, 7);

  case Postrisc::BI__builtin_postrisc_vsllih:
  case Postrisc::BI__builtin_postrisc_vsraih:
  case Postrisc::BI__builtin_postrisc_vsrlih:
    return SemaRef.BuiltinConstantArgRange(TheCall, 1, 1, 15);

  case Postrisc::BI__builtin_postrisc_vslliw:
  case Postrisc::BI__builtin_postrisc_vsraiw:
  case Postrisc::BI__builtin_postrisc_vsrliw:
    return SemaRef.BuiltinConstantArgRange(TheCall, 1, 1, 31);

  case Postrisc::BI__builtin_postrisc_vsllid:
  case Postrisc::BI__builtin_postrisc_vsraid:
  case Postrisc::BI__builtin_postrisc_vsrlid:
    return SemaRef.BuiltinConstantArgRange(TheCall, 1, 1, 63);

  // __builtin_postrisc_vsrpiX(a, b, imm);
  // Check if 2 (3rd) arg (immediate) is proper shift immediate
  case Postrisc::BI__builtin_postrisc_vsrpib:
    return SemaRef.BuiltinConstantArgRange(TheCall, 2, 1, 7);
  case Postrisc::BI__builtin_postrisc_vsrpih:
    return SemaRef.BuiltinConstantArgRange(TheCall, 2, 1, 15);
  case Postrisc::BI__builtin_postrisc_vsrpiw:
    return SemaRef.BuiltinConstantArgRange(TheCall, 2, 1, 31);
  case Postrisc::BI__builtin_postrisc_vsrpid:
    return SemaRef.BuiltinConstantArgRange(TheCall, 2, 1, 63);

  case Postrisc::BI__builtin_postrisc_int:
  case Postrisc::BI__builtin_postrisc_aesdec:
  case Postrisc::BI__builtin_postrisc_aesdeclast:
  case Postrisc::BI__builtin_postrisc_aesenc:
  case Postrisc::BI__builtin_postrisc_aesenclast:
  case Postrisc::BI__builtin_postrisc_aesimc:
  case Postrisc::BI__builtin_postrisc_clmul_hh:
  case Postrisc::BI__builtin_postrisc_clmul_hl:
  case Postrisc::BI__builtin_postrisc_clmul_ll:
  case Postrisc::BI__builtin_postrisc_cpuid:
  case Postrisc::BI__builtin_postrisc_crc32cb:
  case Postrisc::BI__builtin_postrisc_crc32ch:
  case Postrisc::BI__builtin_postrisc_crc32cw:
  case Postrisc::BI__builtin_postrisc_crc32cd:
  case Postrisc::BI__builtin_postrisc_crc32cq:

  case Postrisc::BI__builtin_postrisc_dcbf:
  case Postrisc::BI__builtin_postrisc_dcbi:
  case Postrisc::BI__builtin_postrisc_dcbt:
  case Postrisc::BI__builtin_postrisc_eh_throw:
  case Postrisc::BI__builtin_postrisc_halt:
  case Postrisc::BI__builtin_postrisc_icbi:
  case Postrisc::BI__builtin_postrisc_nop:
  case Postrisc::BI__builtin_postrisc_nop_l:
  case Postrisc::BI__builtin_postrisc_nul_never:
  case Postrisc::BI__builtin_postrisc_random:
  case Postrisc::BI__builtin_postrisc_random_n:
  case Postrisc::BI__builtin_postrisc_rfi:
  case Postrisc::BI__builtin_postrisc_rscover:
  case Postrisc::BI__builtin_postrisc_rsflush:
  case Postrisc::BI__builtin_postrisc_rsload:
  case Postrisc::BI__builtin_postrisc_set_thread_pointer:
  case Postrisc::BI__builtin_postrisc_stack_pointer:
  case Postrisc::BI__builtin_postrisc_syscall:
  case Postrisc::BI__builtin_postrisc_sysret:
  case Postrisc::BI__builtin_postrisc_tlb_purge:
  case Postrisc::BI__builtin_postrisc_tpa:
  case Postrisc::BI__builtin_postrisc_undef:

  case Postrisc::BI__builtin_postrisc_fmaximumh:
  case Postrisc::BI__builtin_postrisc_fmaximums:
  case Postrisc::BI__builtin_postrisc_fmaximumd:
  case Postrisc::BI__builtin_postrisc_fmaximumq:
  case Postrisc::BI__builtin_postrisc_fminimumh:
  case Postrisc::BI__builtin_postrisc_fminimums:
  case Postrisc::BI__builtin_postrisc_fminimumd:
  case Postrisc::BI__builtin_postrisc_fminimumq:
  case Postrisc::BI__builtin_postrisc_fmergeh:
  case Postrisc::BI__builtin_postrisc_fmerges:
  case Postrisc::BI__builtin_postrisc_fmerged:
  case Postrisc::BI__builtin_postrisc_fmergeq:
  case Postrisc::BI__builtin_postrisc_vfmergehh:
  case Postrisc::BI__builtin_postrisc_vfmergehs:
  case Postrisc::BI__builtin_postrisc_vfmergehd:
  case Postrisc::BI__builtin_postrisc_vfmergelh:
  case Postrisc::BI__builtin_postrisc_vfmergels:
  case Postrisc::BI__builtin_postrisc_vfmergeld:
  case Postrisc::BI__builtin_postrisc_vfmergeh:
  case Postrisc::BI__builtin_postrisc_vfmerges:
  case Postrisc::BI__builtin_postrisc_vfmerged:
  case Postrisc::BI__builtin_postrisc_vfupkhh:
  case Postrisc::BI__builtin_postrisc_vfupkhs:
  case Postrisc::BI__builtin_postrisc_vfupkhd:
  case Postrisc::BI__builtin_postrisc_vfupklh:
  case Postrisc::BI__builtin_postrisc_vfupkls:
  case Postrisc::BI__builtin_postrisc_vfupkld:

  case Postrisc::BI__builtin_postrisc_vfcmpoh:
  case Postrisc::BI__builtin_postrisc_vfcmpos:
  case Postrisc::BI__builtin_postrisc_vfcmpod:
  case Postrisc::BI__builtin_postrisc_vfcmpoeqh:
  case Postrisc::BI__builtin_postrisc_vfcmpoeqs:
  case Postrisc::BI__builtin_postrisc_vfcmpoeqd:
  case Postrisc::BI__builtin_postrisc_vfcmpogeh:
  case Postrisc::BI__builtin_postrisc_vfcmpoges:
  case Postrisc::BI__builtin_postrisc_vfcmpoged:
  case Postrisc::BI__builtin_postrisc_vfcmpolth:
  case Postrisc::BI__builtin_postrisc_vfcmpolts:
  case Postrisc::BI__builtin_postrisc_vfcmpoltd:
  case Postrisc::BI__builtin_postrisc_vfcmponeh:
  case Postrisc::BI__builtin_postrisc_vfcmpones:
  case Postrisc::BI__builtin_postrisc_vfcmponed:
  case Postrisc::BI__builtin_postrisc_vfcmpuh:
  case Postrisc::BI__builtin_postrisc_vfcmpus:
  case Postrisc::BI__builtin_postrisc_vfcmpud:
  case Postrisc::BI__builtin_postrisc_vfcmpueqh:
  case Postrisc::BI__builtin_postrisc_vfcmpueqs:
  case Postrisc::BI__builtin_postrisc_vfcmpueqd:
  case Postrisc::BI__builtin_postrisc_vfcmpugeh:
  case Postrisc::BI__builtin_postrisc_vfcmpuges:
  case Postrisc::BI__builtin_postrisc_vfcmpuged:
  case Postrisc::BI__builtin_postrisc_vfcmpulth:
  case Postrisc::BI__builtin_postrisc_vfcmpults:
  case Postrisc::BI__builtin_postrisc_vfcmpultd:
  case Postrisc::BI__builtin_postrisc_vfcmpuneh:
  case Postrisc::BI__builtin_postrisc_vfcmpunes:
  case Postrisc::BI__builtin_postrisc_vfcmpuned:

  case Postrisc::BI__builtin_postrisc_vaddb:
  case Postrisc::BI__builtin_postrisc_vaddh:
  case Postrisc::BI__builtin_postrisc_vaddw:
  case Postrisc::BI__builtin_postrisc_vaddd:
  case Postrisc::BI__builtin_postrisc_vaddcb:
  case Postrisc::BI__builtin_postrisc_vaddch:
  case Postrisc::BI__builtin_postrisc_vaddcw:
  case Postrisc::BI__builtin_postrisc_vaddcd:
  case Postrisc::BI__builtin_postrisc_vaddob:
  case Postrisc::BI__builtin_postrisc_vaddoh:
  case Postrisc::BI__builtin_postrisc_vaddow:
  case Postrisc::BI__builtin_postrisc_vaddod:
  case Postrisc::BI__builtin_postrisc_vsubb:
  case Postrisc::BI__builtin_postrisc_vsubh:
  case Postrisc::BI__builtin_postrisc_vsubw:
  case Postrisc::BI__builtin_postrisc_vsubd:
  case Postrisc::BI__builtin_postrisc_vsubcb:
  case Postrisc::BI__builtin_postrisc_vsubch:
  case Postrisc::BI__builtin_postrisc_vsubcw:
  case Postrisc::BI__builtin_postrisc_vsubcd:
  case Postrisc::BI__builtin_postrisc_vsubob:
  case Postrisc::BI__builtin_postrisc_vsuboh:
  case Postrisc::BI__builtin_postrisc_vsubow:
  case Postrisc::BI__builtin_postrisc_vsubod:
  case Postrisc::BI__builtin_postrisc_vavgsb:
  case Postrisc::BI__builtin_postrisc_vavgsh:
  case Postrisc::BI__builtin_postrisc_vavgsw:
  case Postrisc::BI__builtin_postrisc_vavgsd:
  case Postrisc::BI__builtin_postrisc_vavgub:
  case Postrisc::BI__builtin_postrisc_vavguh:
  case Postrisc::BI__builtin_postrisc_vavguw:
  case Postrisc::BI__builtin_postrisc_vavgud:
  case Postrisc::BI__builtin_postrisc_vcmpeqb:
  case Postrisc::BI__builtin_postrisc_vcmpeqh:
  case Postrisc::BI__builtin_postrisc_vcmpeqw:
  case Postrisc::BI__builtin_postrisc_vcmpeqd:
  case Postrisc::BI__builtin_postrisc_vcmpltsb:
  case Postrisc::BI__builtin_postrisc_vcmpltsh:
  case Postrisc::BI__builtin_postrisc_vcmpltsw:
  case Postrisc::BI__builtin_postrisc_vcmpltsd:
  case Postrisc::BI__builtin_postrisc_vcmpltub:
  case Postrisc::BI__builtin_postrisc_vcmpltuh:
  case Postrisc::BI__builtin_postrisc_vcmpltuw:
  case Postrisc::BI__builtin_postrisc_vcmpltud:
  case Postrisc::BI__builtin_postrisc_vpermb:
  case Postrisc::BI__builtin_postrisc_vsllb:
  case Postrisc::BI__builtin_postrisc_vsllh:
  case Postrisc::BI__builtin_postrisc_vsllw:
  case Postrisc::BI__builtin_postrisc_vslld:
  case Postrisc::BI__builtin_postrisc_vsrab:
  case Postrisc::BI__builtin_postrisc_vsrah:
  case Postrisc::BI__builtin_postrisc_vsraw:
  case Postrisc::BI__builtin_postrisc_vsrad:
  case Postrisc::BI__builtin_postrisc_vsrlb:
  case Postrisc::BI__builtin_postrisc_vsrlh:
  case Postrisc::BI__builtin_postrisc_vsrlw:
  case Postrisc::BI__builtin_postrisc_vsrld:

  case Postrisc::BI__builtin_postrisc_vslpb:
  case Postrisc::BI__builtin_postrisc_vslph:
  case Postrisc::BI__builtin_postrisc_vslpw:
  case Postrisc::BI__builtin_postrisc_vslpd:
  case Postrisc::BI__builtin_postrisc_vsrpb:
  case Postrisc::BI__builtin_postrisc_vsrph:
  case Postrisc::BI__builtin_postrisc_vsrpw:
  case Postrisc::BI__builtin_postrisc_vsrpd:
  case Postrisc::BI__builtin_postrisc_vmergehb:
  case Postrisc::BI__builtin_postrisc_vmergehh:
  case Postrisc::BI__builtin_postrisc_vmergehw:
  case Postrisc::BI__builtin_postrisc_vmergehd:
  case Postrisc::BI__builtin_postrisc_vmergelb:
  case Postrisc::BI__builtin_postrisc_vmergelh:
  case Postrisc::BI__builtin_postrisc_vmergelw:
  case Postrisc::BI__builtin_postrisc_vmergeld:

  case Postrisc::BI__builtin_postrisc_vsplatb:
  case Postrisc::BI__builtin_postrisc_vsplath:
  case Postrisc::BI__builtin_postrisc_vsplatw:
  case Postrisc::BI__builtin_postrisc_vsplatd:

  case Postrisc::BI__builtin_postrisc_vpkumodh:
  case Postrisc::BI__builtin_postrisc_vpkumodw:
  case Postrisc::BI__builtin_postrisc_vpkumodd:
  case Postrisc::BI__builtin_postrisc_vpkssath:
  case Postrisc::BI__builtin_postrisc_vpkssatw:
  case Postrisc::BI__builtin_postrisc_vpkssatd:
  case Postrisc::BI__builtin_postrisc_vpkusath:
  case Postrisc::BI__builtin_postrisc_vpkusatw:
  case Postrisc::BI__builtin_postrisc_vpkusatd:
  case Postrisc::BI__builtin_postrisc_vpkusatsh:
  case Postrisc::BI__builtin_postrisc_vpkusatsw:
  case Postrisc::BI__builtin_postrisc_vpkusatsd:

  case Postrisc::BI__builtin_postrisc_vupkhsb:
  case Postrisc::BI__builtin_postrisc_vupkhsh:
  case Postrisc::BI__builtin_postrisc_vupkhsw:
  case Postrisc::BI__builtin_postrisc_vupkhub:
  case Postrisc::BI__builtin_postrisc_vupkhuh:
  case Postrisc::BI__builtin_postrisc_vupkhuw:
  case Postrisc::BI__builtin_postrisc_vupklsb:
  case Postrisc::BI__builtin_postrisc_vupklsh:
  case Postrisc::BI__builtin_postrisc_vupklsw:
  case Postrisc::BI__builtin_postrisc_vupklub:
  case Postrisc::BI__builtin_postrisc_vupkluh:
  case Postrisc::BI__builtin_postrisc_vupkluw:


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
  case Postrisc::BI__builtin_postrisc_set_tpr:
  case Postrisc::BI__builtin_postrisc_set_tsv:
    break;
  }
  // default: ok
  return false;
}

} // namespace clang
