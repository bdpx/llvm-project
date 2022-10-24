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
// floating-point loads are lduXXX
//===----------------------------------------------------------------------===//
defm : LdPat<"LDHZ", load, f16>;
defm : LdPat<"LDWZ", load, f32>;
defm : LdPat<"LDDZ", load, f64>;
defm : LdPat<"LDQ", load, f128>;

//===----------------------------------------------------------------------===//
// floating-point stores are stXXX
//===----------------------------------------------------------------------===//
defm : StPat<"STH", store, f16>;
defm : StPat<"STW", store, f32>;
defm : StPat<"STD", store, f64>;
defm : StPat<"STQ", store, f128>;

//===----------------------------------------------------------------------===//
// floating-point select are SELECT
//===----------------------------------------------------------------------===//
def : Pat<(f16  (select i1:$rb,  f16:$rc,  f16:$rd)), (SELECT GR:$rb, GR:$rc, GR:$rd)>;
def : Pat<(f32  (select i1:$rb,  f32:$rc,  f32:$rd)), (SELECT GR:$rb, GR:$rc, GR:$rd)>;
def : Pat<(f64  (select i1:$rb,  f64:$rc,  f64:$rd)), (SELECT GR:$rb, GR:$rc, GR:$rd)>;
def : Pat<(f128 (select i1:$rb, f128:$rc, f128:$rd)), (SELECT GR:$rb, GR:$rc, GR:$rd)>;

//===----------------------------------------------------------------------===//
// float <=> float conversions
//===----------------------------------------------------------------------===//

multiclass
MISC_FP_EXTEND<misc_opx opx, string OpcStr,
        ValueType Tdst, ValueType Tsrc,
        InstrItinClass itin = IIC_iu_instr>
{
  def NAME : MISC_Rab<opx,
                 (outs GR:$ra), (ins GR:$rb),
                 !strconcat(OpcStr, "\t$ra, $rb"),
                 [(set Tdst:$ra, (any_fpextend Tsrc:$rb))],
                 itin>;
}

defm insn_cvtsh2ss : MISC_FP_EXTEND<misc_opx_fextsh2ss, "fextsh2ss",  f32, f16>;
defm insn_cvtsh2sd : MISC_FP_EXTEND<misc_opx_fextsh2sd, "fextsh2sd",  f64, f16>;
defm insn_cvtsh2sq : MISC_FP_EXTEND<misc_opx_fextsh2sq, "fextsh2sq", f128, f16>;
defm insn_cvtss2sd : MISC_FP_EXTEND<misc_opx_fextss2sd, "fextss2sd",  f64, f32>;
defm insn_cvtss2sq : MISC_FP_EXTEND<misc_opx_fextss2sq, "fextss2sq", f128, f32>;
defm insn_cvtsd2sq : MISC_FP_EXTEND<misc_opx_fextsd2sq, "fextsd2sq", f128, f64>;

def insn_cvtss2sh : MISC_RabRM<misc_opx_fcvtss2sh, "fcvtss2sh">;
def insn_cvtsd2sh : MISC_RabRM<misc_opx_fcvtsd2sh, "fcvtsd2sh">;
def insn_cvtsq2sh : MISC_RabRM<misc_opx_fcvtsq2sh, "fcvtsq2sh">;
def insn_cvtsd2ss : MISC_RabRM<misc_opx_fcvtsd2ss, "fcvtsd2ss">;
def insn_cvtsq2ss : MISC_RabRM<misc_opx_fcvtsq2ss, "fcvtsq2ss">;
def insn_cvtsq2sd : MISC_RabRM<misc_opx_fcvtsq2sd, "fcvtsq2sd">;

def : Pat<(f16  (any_fpround   f32:$src)),  (insn_cvtss2sh GR:$src, rounding_mode_nearesteven.value)>;
def : Pat<(f16  (any_fpround   f64:$src)),  (insn_cvtsd2sh GR:$src, rounding_mode_nearesteven.value)>;
def : Pat<(f16  (any_fpround  f128:$src)),  (insn_cvtsq2sh GR:$src, rounding_mode_nearesteven.value)>;
def : Pat<(f32  (any_fpround   f64:$src)),  (insn_cvtsd2ss GR:$src, rounding_mode_nearesteven.value)>;
def : Pat<(f32  (any_fpround  f128:$src)),  (insn_cvtsq2ss GR:$src, rounding_mode_nearesteven.value)>;
def : Pat<(f64  (any_fpround  f128:$src)),  (insn_cvtsq2sd GR:$src, rounding_mode_nearesteven.value)>;

//===----------------------------------------------------------------------===//
// patterns
//===----------------------------------------------------------------------===//
multiclass FP_BASE_INTRUCTIONS<string T, ValueType Ty>
{
  defm insn_fabs   # NAME : BUILTIN_R2<!cast<misc_opx>("misc_opx_fabs"   # T),  !strconcat("fabs",   T),  !cast<ClangBuiltin>("int_postrisc_fabs"   # T),  Ty, Ty>;
  defm insn_fnabs  # NAME : BUILTIN_R2<!cast<misc_opx>("misc_opx_fnabs"  # T),  !strconcat("fnabs",  T),  !cast<ClangBuiltin>("int_postrisc_fnabs"  # T),  Ty, Ty>;
  defm insn_fneg   # NAME : BUILTIN_R2<!cast<misc_opx>("misc_opx_fneg"   # T),  !strconcat("fneg",   T),  !cast<ClangBuiltin>("int_postrisc_fneg"   # T),  Ty, Ty>;
  defm insn_fsqrt  # NAME : BUILTIN_R2<!cast<misc_opx>("misc_opx_fsqrt"  # T),  !strconcat("fsqrt",  T),  !cast<ClangBuiltin>("int_postrisc_fsqrt"  # T),  Ty, Ty>;
  defm insn_frsqrt # NAME : BUILTIN_R2<!cast<misc_opx>("misc_opx_frsqrt" # T),  !strconcat("frsqrt", T),  !cast<ClangBuiltin>("int_postrisc_frsqrt" # T),  Ty, Ty>;

  defm insn_fabsd  # NAME : BUILTIN_R3<!cast<misc_opx>("misc_opx_fabsd"  # T),  !strconcat("fabsd",  T),  !cast<ClangBuiltin>("int_postrisc_fabsd"  # T),  Ty, Ty, Ty>;
  defm insn_fnabsd # NAME : BUILTIN_R3<!cast<misc_opx>("misc_opx_fnabsd" # T),  !strconcat("fnabsd", T),  !cast<ClangBuiltin>("int_postrisc_fnabsd" # T),  Ty, Ty, Ty>;
  defm insn_fadd   # NAME : BUILTIN_R3<!cast<misc_opx>("misc_opx_fadd"   # T),  !strconcat("fadd",   T),  !cast<ClangBuiltin>("int_postrisc_fadd"   # T),  Ty, Ty, Ty>;
  defm insn_fdiv   # NAME : BUILTIN_R3<!cast<misc_opx>("misc_opx_fdiv"   # T),  !strconcat("fdiv",   T),  !cast<ClangBuiltin>("int_postrisc_fdiv"   # T),  Ty, Ty, Ty>;
  defm insn_fnadd  # NAME : BUILTIN_R3<!cast<misc_opx>("misc_opx_fnadd"  # T),  !strconcat("fnadd",  T),  !cast<ClangBuiltin>("int_postrisc_fnadd"  # T),  Ty, Ty, Ty>;
  defm insn_fmul   # NAME : BUILTIN_R3<!cast<misc_opx>("misc_opx_fmul"   # T),  !strconcat("fmul",   T),  !cast<ClangBuiltin>("int_postrisc_fmul"   # T),  Ty, Ty, Ty>;
  defm insn_fnmul  # NAME : BUILTIN_R3<!cast<misc_opx>("misc_opx_fnmul"  # T),  !strconcat("fnmul",  T),  !cast<ClangBuiltin>("int_postrisc_fnmul"  # T),  Ty, Ty, Ty>;
  defm insn_fsub   # NAME : BUILTIN_R3<!cast<misc_opx>("misc_opx_fsub"   # T),  !strconcat("fsub",   T),  !cast<ClangBuiltin>("int_postrisc_fsub"   # T),  Ty, Ty, Ty>;
  defm insn_famax  # NAME : BUILTIN_R3<!cast<misc_opx>("misc_opx_famax"  # T),  !strconcat("famax",  T),  !cast<ClangBuiltin>("int_postrisc_famax"  # T),  Ty, Ty, Ty>;
  defm insn_famin  # NAME : BUILTIN_R3<!cast<misc_opx>("misc_opx_famin"  # T),  !strconcat("famin",  T),  !cast<ClangBuiltin>("int_postrisc_famin"  # T),  Ty, Ty, Ty>;
  defm insn_fmax   # NAME : BUILTIN_R3<!cast<misc_opx>("misc_opx_fmax"   # T),  !strconcat("fmax",   T),  !cast<ClangBuiltin>("int_postrisc_fmax"   # T),  Ty, Ty, Ty>;
  defm insn_fmin   # NAME : BUILTIN_R3<!cast<misc_opx>("misc_opx_fmin"   # T),  !strconcat("fmin",   T),  !cast<ClangBuiltin>("int_postrisc_fmin"   # T),  Ty, Ty, Ty>;

  def  insn_frnd   # NAME : MISC_RabRM<!cast<misc_opx>("misc_opx_frnd"   # T),  !strconcat("frnd",   T)>;

  defm insn_fmadd  # NAME : BUILTIN_R4<!cast<fused_opx>("fused_opx_fmadd"  # T),  !strconcat("fmadd",  T),  !cast<ClangBuiltin>("int_postrisc_fmadd"  # T),  Ty, Ty, Ty, Ty>;
  defm insn_fmsub  # NAME : BUILTIN_R4<!cast<fused_opx>("fused_opx_fmsub"  # T),  !strconcat("fmsub",  T),  !cast<ClangBuiltin>("int_postrisc_fmsub"  # T),  Ty, Ty, Ty, Ty>;
  defm insn_fnmadd # NAME : BUILTIN_R4<!cast<fused_opx>("fused_opx_fnmadd" # T),  !strconcat("fnmadd", T),  !cast<ClangBuiltin>("int_postrisc_fnmadd" # T),  Ty, Ty, Ty, Ty>;
  defm insn_fnmsub # NAME : BUILTIN_R4<!cast<fused_opx>("fused_opx_fnmsub" # T),  !strconcat("fnmsub", T),  !cast<ClangBuiltin>("int_postrisc_fnmsub" # T),  Ty, Ty, Ty, Ty>;
  defm insn_fmerge # NAME : BUILTIN_R4<!cast<fused_opx>("fused_opx_fmerge" # T),  !strconcat("fmerge", T),  !cast<ClangBuiltin>("int_postrisc_fmerge" # T),  Ty, Ty, Ty, Ty>;

  defm insn_fcmp # NAME # oeq : MISC_R3<!cast<misc_opx>("misc_opx_fcmp" # T # "oeq"),  !strconcat("fcmp", T, "oeq"), setoeq, i1, Ty>;
  defm insn_fcmp # NAME # one : MISC_R3<!cast<misc_opx>("misc_opx_fcmp" # T # "one"),  !strconcat("fcmp", T, "one"), setone, i1, Ty>;
  defm insn_fcmp # NAME # olt : MISC_R3<!cast<misc_opx>("misc_opx_fcmp" # T # "olt"),  !strconcat("fcmp", T, "olt"), setolt, i1, Ty>;
  defm insn_fcmp # NAME # ole : MISC_R3<!cast<misc_opx>("misc_opx_fcmp" # T # "ole"),  !strconcat("fcmp", T, "ole"), setole, i1, Ty>;
  defm insn_fcmp # NAME # o   : MISC_R3<!cast<misc_opx>("misc_opx_fcmp" # T # "o"  ),  !strconcat("fcmp", T, "o"  ), seto,   i1, Ty>;
  defm insn_fcmp # NAME # ueq : MISC_R3<!cast<misc_opx>("misc_opx_fcmp" # T # "ueq"),  !strconcat("fcmp", T, "ueq"), setueq, i1, Ty>;
  defm insn_fcmp # NAME # une : MISC_R3<!cast<misc_opx>("misc_opx_fcmp" # T # "une"),  !strconcat("fcmp", T, "une"), setune, i1, Ty>;
  defm insn_fcmp # NAME # ult : MISC_R3<!cast<misc_opx>("misc_opx_fcmp" # T # "ult"),  !strconcat("fcmp", T, "ult"), setult, i1, Ty>;
  defm insn_fcmp # NAME # ule : MISC_R3<!cast<misc_opx>("misc_opx_fcmp" # T # "ule"),  !strconcat("fcmp", T, "ule"), setule, i1, Ty>;
  defm insn_fcmp # NAME # uo  : MISC_R3<!cast<misc_opx>("misc_opx_fcmp" # T # "uo" ),  !strconcat("fcmp", T, "uo" ), setuo,  i1, Ty>;
}

defm sh : FP_BASE_INTRUCTIONS<"sh", f16>;
defm ss : FP_BASE_INTRUCTIONS<"ss", f32>;
defm sd : FP_BASE_INTRUCTIONS<"sd", f64>;
defm sq : FP_BASE_INTRUCTIONS<"sq", f128>;

multiclass FP_BASE_CVT_INTRUCTIONS<string T, ValueType Ty>
{
  // float <=> integer conversions
  def insn_fcvt # NAME # 2iw : MISC_RabRM<!cast<misc_opx>("misc_opx_fcvt" # T # "2iw"),  !strconcat("fcvt", T, "2iw")>;
  def insn_fcvt # NAME # 2uw : MISC_RabRM<!cast<misc_opx>("misc_opx_fcvt" # T # "2uw"),  !strconcat("fcvt", T, "2uw")>;
  def insn_fcvt # NAME # 2id : MISC_RabRM<!cast<misc_opx>("misc_opx_fcvt" # T # "2id"),  !strconcat("fcvt", T, "2id")>;
  def insn_fcvt # NAME # 2ud : MISC_RabRM<!cast<misc_opx>("misc_opx_fcvt" # T # "2ud"),  !strconcat("fcvt", T, "2ud")>;
  def insn_fcvt # NAME # 2iq : MISC_RabRM<!cast<misc_opx>("misc_opx_fcvt" # T # "2iq"),  !strconcat("fcvt", T, "2iq")>;
  def insn_fcvt # NAME # 2uq : MISC_RabRM<!cast<misc_opx>("misc_opx_fcvt" # T # "2uq"),  !strconcat("fcvt", T, "2uq")>;

  def insn_fcvtiw2 # NAME : MISC_RabRM<!cast<misc_opx>("misc_opx_fcvtiw2" # T),  !strconcat("fcvtiw2", T)>;
  def insn_fcvtuw2 # NAME : MISC_RabRM<!cast<misc_opx>("misc_opx_fcvtuw2" # T),  !strconcat("fcvtuw2", T)>;
  def insn_fcvtid2 # NAME : MISC_RabRM<!cast<misc_opx>("misc_opx_fcvtid2" # T),  !strconcat("fcvtid2", T)>;
  def insn_fcvtud2 # NAME : MISC_RabRM<!cast<misc_opx>("misc_opx_fcvtud2" # T),  !strconcat("fcvtud2", T)>;
  def insn_fcvtiq2 # NAME : MISC_RabRM<!cast<misc_opx>("misc_opx_fcvtiq2" # T),  !strconcat("fcvtiq2", T)>;
  def insn_fcvtuq2 # NAME : MISC_RabRM<!cast<misc_opx>("misc_opx_fcvtuq2" # T),  !strconcat("fcvtuq2", T)>;

  def : Pat<(i32  (any_fp_to_sint Ty:$src)), (!cast<InstBase>("insn_fcvt" # T # "2iw") GR:$src, rounding_mode_nearesteven.value)>;
  def : Pat<(i32  (any_fp_to_uint Ty:$src)), (!cast<InstBase>("insn_fcvt" # T # "2uw") GR:$src, rounding_mode_nearesteven.value)>;
  def : Pat<(i64  (any_fp_to_sint Ty:$src)), (!cast<InstBase>("insn_fcvt" # T # "2id") GR:$src, rounding_mode_nearesteven.value)>;
  def : Pat<(i64  (any_fp_to_uint Ty:$src)), (!cast<InstBase>("insn_fcvt" # T # "2ud") GR:$src, rounding_mode_nearesteven.value)>;
  def : Pat<(i128 (any_fp_to_sint Ty:$src)), (!cast<InstBase>("insn_fcvt" # T # "2iq") GR:$src, rounding_mode_nearesteven.value)>;
  def : Pat<(i128 (any_fp_to_uint Ty:$src)), (!cast<InstBase>("insn_fcvt" # T # "2uq") GR:$src, rounding_mode_nearesteven.value)>;

  def : Pat<(Ty (any_sint_to_fp  i32:$src)), (!cast<InstBase>("insn_fcvtiw2" # T) GR:$src, rounding_mode_nearesteven.value)>;
  def : Pat<(Ty (any_uint_to_fp  i32:$src)), (!cast<InstBase>("insn_fcvtuw2" # T) GR:$src, rounding_mode_nearesteven.value)>;
  def : Pat<(Ty (any_sint_to_fp  i64:$src)), (!cast<InstBase>("insn_fcvtid2" # T) GR:$src, rounding_mode_nearesteven.value)>;
  def : Pat<(Ty (any_uint_to_fp  i64:$src)), (!cast<InstBase>("insn_fcvtud2" # T) GR:$src, rounding_mode_nearesteven.value)>;
  def : Pat<(Ty (any_sint_to_fp i128:$src)), (!cast<InstBase>("insn_fcvtiq2" # T) GR:$src, rounding_mode_nearesteven.value)>;
  def : Pat<(Ty (any_uint_to_fp i128:$src)), (!cast<InstBase>("insn_fcvtuq2" # T) GR:$src, rounding_mode_nearesteven.value)>;

  // FIXME: i1 to fp => via i32 to fp
  def : Pat<(Ty (any_sint_to_fp  i1:$src)),  (!cast<InstBase>("insn_fcvtiw2" # T) GR:$src, rounding_mode_nearesteven.value)>;
  def : Pat<(Ty (any_uint_to_fp  i1:$src)),  (!cast<InstBase>("insn_fcvtuw2" # T) GR:$src, rounding_mode_nearesteven.value)>;
}

defm sh : FP_BASE_CVT_INTRUCTIONS<"sh", f16>;
defm ss : FP_BASE_CVT_INTRUCTIONS<"ss", f32>;
defm sd : FP_BASE_CVT_INTRUCTIONS<"sd", f64>;
defm sq : FP_BASE_CVT_INTRUCTIONS<"sq", f128>;

//===----------------------------------------------------------------------===//
// fp32 branches
// subcodes of BFSS primary opcode
//===----------------------------------------------------------------------===//
multiclass CompareAndBranchF32<
  bfss_opx opxCode, string OpcStr, PatFrag OpNode, ValueType Ty,
  InstrItinClass itin = IIC_iu_instr>
{
  let isBranch = 1, isTerminator = 1 in
  def NAME : BRR_RabBranch<opcode_bfss, opxCode.value,
                 (outs), (ins GR:$ra, GR:$rb, brtarget:$offset),
                 !strconcat(OpcStr, "\t$ra, $rb, $offset"),
                 [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;

  let isBranch = 1, isTerminator = 1 in
  def NAME # _ext : BRR_RabBranch_ext<opcode_bfss, opxCode.value,
                 (outs), (ins GR:$ra, GR:$rb, brtarget_ext:$offset),
                 !strconcat(OpcStr, ".l\t$ra, $rb, $offset"),
                 [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;
}

defm insn_bfssoeq : CompareAndBranchF32<bfss_opx_bfssoeq,  "bfssoeq",   setoeq,   f32>;
defm insn_bfssone : CompareAndBranchF32<bfss_opx_bfssone,  "bfssone",   setone,   f32>;
defm insn_bfssolt : CompareAndBranchF32<bfss_opx_bfssolt,  "bfssolt",   setolt,   f32>;
defm insn_bfssole : CompareAndBranchF32<bfss_opx_bfssole,  "bfssole",   setole,   f32>;
defm insn_bfsso   : CompareAndBranchF32<bfss_opx_bfsso,    "bfsso",     seto,     f32>;
defm insn_bfssueq : CompareAndBranchF32<bfss_opx_bfssueq,  "bfssueq",   setueq,   f32>;
defm insn_bfssune : CompareAndBranchF32<bfss_opx_bfssune,  "bfssune",   setune,   f32>;
defm insn_bfssult : CompareAndBranchF32<bfss_opx_bfssult,  "bfssult",   setult,   f32>;
defm insn_bfssule : CompareAndBranchF32<bfss_opx_bfssule,  "bfssule",   setule,   f32>;
defm insn_bfssuo  : CompareAndBranchF32<bfss_opx_bfssuo,   "bfssuo",    setuo,    f32>;

//===----------------------------------------------------------------------===//
// fp64 branches
// subcodes of BFSD primary opcode
//===----------------------------------------------------------------------===//
multiclass CompareAndBranchF64<
  bfsd_opx opxCode, string OpcStr, PatFrag OpNode, ValueType Ty,
  InstrItinClass itin = IIC_iu_instr>
{
  let isBranch = 1, isTerminator = 1 in
  def NAME : BRR_RabBranch<opcode_bfsd, opxCode.value,
                 (outs), (ins GR:$ra, GR:$rb, brtarget:$offset),
                 !strconcat(OpcStr, "\t$ra, $rb, $offset"),
                 [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;

  let isBranch = 1, isTerminator = 1 in
  def NAME # _ext : BRR_RabBranch_ext<opcode_bfsd, opxCode.value,
                 (outs), (ins GR:$ra, GR:$rb, brtarget_ext:$offset),
                 !strconcat(OpcStr, ".l\t$ra, $rb, $offset"),
                 [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;
}

defm insn_bfsdoeq : CompareAndBranchF64<bfsd_opx_bfsdoeq,  "bfsdoeq",   setoeq,   f64>;
defm insn_bfsdone : CompareAndBranchF64<bfsd_opx_bfsdone,  "bfsdone",   setone,   f64>;
defm insn_bfsdolt : CompareAndBranchF64<bfsd_opx_bfsdolt,  "bfsdolt",   setolt,   f64>;
defm insn_bfsdole : CompareAndBranchF64<bfsd_opx_bfsdole,  "bfsdole",   setole,   f64>;
defm insn_bfsdo   : CompareAndBranchF64<bfsd_opx_bfsdo,    "bfsdo",     seto,     f64>;
defm insn_bfsdueq : CompareAndBranchF64<bfsd_opx_bfsdueq,  "bfsdueq",   setueq,   f64>;
defm insn_bfsdune : CompareAndBranchF64<bfsd_opx_bfsdune,  "bfsdune",   setune,   f64>;
defm insn_bfsdult : CompareAndBranchF64<bfsd_opx_bfsdult,  "bfsdult",   setult,   f64>;
defm insn_bfsdule : CompareAndBranchF64<bfsd_opx_bfsdule,  "bfsdule",   setule,   f64>;
defm insn_bfsduo  : CompareAndBranchF64<bfsd_opx_bfsduo,   "bfsduo",    setuo,    f64>;

//===----------------------------------------------------------------------===//
// fp128 branches
// subcodes of BFSQ primary opcode
//===----------------------------------------------------------------------===//
multiclass CompareAndBranchF128<
  bfsq_opx opxCode, string OpcStr, PatFrag OpNode, ValueType Ty,
  InstrItinClass itin = IIC_iu_instr>
{
  let isBranch = 1, isTerminator = 1 in
  def NAME : BRR_RabBranch<opcode_bfsq, opxCode.value,
                 (outs), (ins GR:$ra, GR:$rb, brtarget:$offset),
                 !strconcat(OpcStr, "\t$ra, $rb, $offset"),
                 [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;

  let isBranch = 1, isTerminator = 1 in
  def NAME # _ext : BRR_RabBranch_ext<opcode_bfsq, opxCode.value,
                 (outs), (ins GR:$ra, GR:$rb, brtarget_ext:$offset),
                 !strconcat(OpcStr, ".l\t$ra, $rb, $offset"),
                 [(brcond (i1 (OpNode Ty:$ra, Ty:$rb)), bb:$offset)], itin>;
}

defm insn_bfsqoeq : CompareAndBranchF128<bfsq_opx_bfsqoeq,  "bfsqoeq",   setoeq,   f128>;
defm insn_bfsqone : CompareAndBranchF128<bfsq_opx_bfsqone,  "bfsqone",   setone,   f128>;
defm insn_bfsqolt : CompareAndBranchF128<bfsq_opx_bfsqolt,  "bfsqolt",   setolt,   f128>;
defm insn_bfsqole : CompareAndBranchF128<bfsq_opx_bfsqole,  "bfsqole",   setole,   f128>;
defm insn_bfsqo   : CompareAndBranchF128<bfsq_opx_bfsqo,    "bfsqo",     seto,     f128>;
defm insn_bfsqueq : CompareAndBranchF128<bfsq_opx_bfsqueq,  "bfsqueq",   setueq,   f128>;
defm insn_bfsqune : CompareAndBranchF128<bfsq_opx_bfsqune,  "bfsqune",   setune,   f128>;
defm insn_bfsqult : CompareAndBranchF128<bfsq_opx_bfsqult,  "bfsqult",   setult,   f128>;
defm insn_bfsqule : CompareAndBranchF128<bfsq_opx_bfsqule,  "bfsqule",   setule,   f128>;
defm insn_bfsquo  : CompareAndBranchF128<bfsq_opx_bfsquo,   "bfsquo",    setuo,    f128>;

multiclass FP_SCALAR_PATTERNS<string T, ValueType Ty>
{
  // arg swapping for GT/GE
  def : Pat<(i1 (setogt Ty:$rb, Ty:$rc)), (!cast<InstBase>("insn_fcmp" # T # "olt")  GR:$rc, GR:$rb)>;
  def : Pat<(i1 (setoge Ty:$rb, Ty:$rc)), (!cast<InstBase>("insn_fcmp" # T # "ole")  GR:$rc, GR:$rb)>;
  def : Pat<(i1 (setugt Ty:$rb, Ty:$rc)), (!cast<InstBase>("insn_fcmp" # T # "ult")  GR:$rc, GR:$rb)>;
  def : Pat<(i1 (setuge Ty:$rb, Ty:$rc)), (!cast<InstBase>("insn_fcmp" # T # "ule")  GR:$rc, GR:$rb)>;

  // fast-math doesn't differ ordered/unordered => use ordered forms
  def : Pat<(i1 (seteq Ty:$rb, Ty:$rc)), (!cast<InstBase>("insn_fcmp" # T # "oeq")  GR:$rb, GR:$rc)>;
  def : Pat<(i1 (setne Ty:$rb, Ty:$rc)), (!cast<InstBase>("insn_fcmp" # T # "one")  GR:$rb, GR:$rc)>;
  def : Pat<(i1 (setlt Ty:$rb, Ty:$rc)), (!cast<InstBase>("insn_fcmp" # T # "olt")  GR:$rb, GR:$rc)>;
  def : Pat<(i1 (setle Ty:$rb, Ty:$rc)), (!cast<InstBase>("insn_fcmp" # T # "ole")  GR:$rb, GR:$rc)>;
  def : Pat<(i1 (setgt Ty:$rb, Ty:$rc)), (!cast<InstBase>("insn_fcmp" # T # "olt")  GR:$rc, GR:$rb)>;
  def : Pat<(i1 (setge Ty:$rb, Ty:$rc)), (!cast<InstBase>("insn_fcmp" # T # "ole")  GR:$rc, GR:$rb)>;

  def : Pat<(fneg        Ty:$rb ),  (!cast<InstBase>("insn_fneg"  # T)  GR:$rb)>;
  def : Pat<(       fabs Ty:$rb ),  (!cast<InstBase>("insn_fabs"  # T)  GR:$rb)>;
  def : Pat<(fneg ( fabs Ty:$rb)),  (!cast<InstBase>("insn_fnabs" # T)  GR:$rb)>;
  def : Pat<(      fsqrt Ty:$rb ),  (!cast<InstBase>("insn_fsqrt" # T)  GR:$rb)>;

  def : Pat<(fadd Ty:$rb, Ty:$rc),  (!cast<InstBase>("insn_fadd"  # T)  GR:$rb, GR:$rc)>;
  def : Pat<(fsub Ty:$rb, Ty:$rc),  (!cast<InstBase>("insn_fsub"  # T)  GR:$rb, GR:$rc)>;
  def : Pat<(fmul Ty:$rb, Ty:$rc),  (!cast<InstBase>("insn_fmul"  # T)  GR:$rb, GR:$rc)>;
  def : Pat<(fdiv Ty:$rb, Ty:$rc),  (!cast<InstBase>("insn_fdiv"  # T)  GR:$rb, GR:$rc)>;

  def : Pat<(      fabs (fsub       Ty:$rb,        Ty:$rc )),  (!cast<InstBase>("insn_fabsd"  # T)  GR:$rb, GR:$rc)>; // absolute difference
  def : Pat<(fneg (fabs (fsub       Ty:$rb,        Ty:$rc))),  (!cast<InstBase>("insn_fnabsd" # T)  GR:$rb, GR:$rc)>; // negated absolute difference
  def : Pat<(fneg (      fadd       Ty:$rb,        Ty:$rc )),  (!cast<InstBase>("insn_fnadd"  # T)  GR:$rb, GR:$rc)>; // negated sum
  def : Pat<(            fadd (fneg Ty:$rb), (fneg Ty:$rc )),  (!cast<InstBase>("insn_fnadd"  # T)  GR:$rb, GR:$rc)>; // negated sum (as sum of negated)
  def : Pat<(fneg (      fmul       Ty:$rb ,       Ty:$rc )),  (!cast<InstBase>("insn_fnmul"  # T)  GR:$rb, GR:$rc)>; // negated mul
  def : Pat<(            fmul (fneg Ty:$rb),       Ty:$rc  ),  (!cast<InstBase>("insn_fnmul"  # T)  GR:$rb, GR:$rc)>; // negated mul (as mul of one negated)
  def : Pat<(            fmul       Ty:$rb , (fneg Ty:$rc )),  (!cast<InstBase>("insn_fnmul"  # T)  GR:$rb, GR:$rc)>; // negated mul (as mul of one negated)

  def : Pat<(fminnum       Ty:$rb,        Ty:$rc ), (!cast<InstBase>("insn_fmin"  # T)  GR:$rb, GR:$rc)>;
  def : Pat<(fmaxnum       Ty:$rb,        Ty:$rc ), (!cast<InstBase>("insn_fmax"  # T)  GR:$rb, GR:$rc)>;
  def : Pat<(fminnum (fabs Ty:$rb), (fabs Ty:$rc)), (!cast<InstBase>("insn_famin" # T)  GR:$rb, GR:$rc)>;
  def : Pat<(fmaxnum (fabs Ty:$rb), (fabs Ty:$rc)), (!cast<InstBase>("insn_famax" # T)  GR:$rb, GR:$rc)>;

  def : Pat<(      any_fma       Ty:$rb,       Ty:$rc,        Ty:$rd),  (!cast<InstBase>("insn_fmadd"  # T)  GR:$rb, GR:$rc, GR:$rd)>; //    x  *  y  +  z
  def : Pat<(      any_fma       Ty:$rb,       Ty:$rc,  (fneg Ty:$rd)), (!cast<InstBase>("insn_fmsub"  # T)  GR:$rb, GR:$rc, GR:$rd)>; //    x  *  y  -  z
  def : Pat<(      any_fma (fneg Ty:$rb),      Ty:$rc,        Ty:$rd),  (!cast<InstBase>("insn_fnmadd" # T)  GR:$rb, GR:$rc, GR:$rd)>; //   -x  *  y  +  z
  def : Pat<(      any_fma       Ty:$rb, (fneg Ty:$rc),       Ty:$rd),  (!cast<InstBase>("insn_fnmadd" # T)  GR:$rb, GR:$rc, GR:$rd)>; //    x  * -y  +  z
  def : Pat<(      any_fma (fneg Ty:$rb),      Ty:$rc,  (fneg Ty:$rd)), (!cast<InstBase>("insn_fnmsub" # T)  GR:$rb, GR:$rc, GR:$rd)>; //   -x  *  y  -  z
  def : Pat<(      any_fma       Ty:$rb, (fneg Ty:$rc), (fneg Ty:$rd)), (!cast<InstBase>("insn_fnmsub" # T)  GR:$rb, GR:$rc, GR:$rd)>; //   -x  *  y  -  z
  def : Pat<(fneg (any_fma       Ty:$rb,       Ty:$rc,        Ty:$rd)), (!cast<InstBase>("insn_fnmsub" # T)  GR:$rb, GR:$rc, GR:$rd)>; // -( x  *  y  +  z)

  def : Pat<(fcopysign Ty:$rb, Ty:$rc), (!cast<InstBase>("insn_fmerge" # T) GR:$rc, GR:$rb, GR:$rb)>;

  def : Pat<(any_frint      Ty:$rb),  (!cast<InstBase>("insn_frnd" # T) GR:$rb, rounding_mode_dynamic.value    )>;  // frint rounds according to the current mode
  def : Pat<(any_fnearbyint Ty:$rb),  (!cast<InstBase>("insn_frnd" # T) GR:$rb, rounding_mode_dynamic.value    )>;  // fnearbyint is like frint
  def : Pat<(any_fround     Ty:$rb),  (!cast<InstBase>("insn_frnd" # T) GR:$rb, rounding_mode_nearesteven.value)>;  // round towards nearest with ties away from zero.
  def : Pat<(any_ffloor     Ty:$rb),  (!cast<InstBase>("insn_frnd" # T) GR:$rb, rounding_mode_downward.value   )>;  // round towards -inf.
  def : Pat<(any_fceil      Ty:$rb),  (!cast<InstBase>("insn_frnd" # T) GR:$rb, rounding_mode_upward.value     )>;  // round towards +inf.
  def : Pat<(any_ftrunc     Ty:$rb),  (!cast<InstBase>("insn_frnd" # T) GR:$rb, rounding_mode_towardzero.value )>;  // round towards zero.

  def : InstAlias<!strconcat("frnd", T, ".dyn\t$rb, $rc"),    (!cast<InstBase>("insn_frnd" # T) GR:$rb, GR:$rc, rounding_mode_dynamic.value)>;
  def : InstAlias<!strconcat("frnd", T, ".even\t$rb, $rc"),   (!cast<InstBase>("insn_frnd" # T) GR:$rb, GR:$rc, rounding_mode_nearesteven.value)>;
  def : InstAlias<!strconcat("frnd", T, ".floor\t$rb, $rc"),  (!cast<InstBase>("insn_frnd" # T) GR:$rb, GR:$rc, rounding_mode_downward.value)>;
  def : InstAlias<!strconcat("frnd", T, ".ceil\t$rb, $rc"),   (!cast<InstBase>("insn_frnd" # T) GR:$rb, GR:$rc, rounding_mode_upward.value)>;
  def : InstAlias<!strconcat("frnd", T, ".trunc\t$rb, $rc"),  (!cast<InstBase>("insn_frnd" # T) GR:$rb, GR:$rc, rounding_mode_towardzero.value)>;
}

defm : FP_SCALAR_PATTERNS<"sh", f16>;
defm : FP_SCALAR_PATTERNS<"ss", f32>;
defm : FP_SCALAR_PATTERNS<"sd", f64>;
defm : FP_SCALAR_PATTERNS<"sq", f128>;

multiclass
FP_SCALAR_BRANCH_PATTERNS<string T, ValueType Ty>
{
  // greater branch: swap args
  def : Pat<(brcond (i1 (setogt Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("insn_bf" # T # "olt") GR:$rb, GR:$ra, bb:$dst)>;
  def : Pat<(brcond (i1 (setoge Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("insn_bf" # T # "ole") GR:$rb, GR:$ra, bb:$dst)>;
  def : Pat<(brcond (i1 (setugt Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("insn_bf" # T # "ult") GR:$rb, GR:$ra, bb:$dst)>;
  def : Pat<(brcond (i1 (setuge Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("insn_bf" # T # "ule") GR:$rb, GR:$ra, bb:$dst)>;

  // branch: don't care variants
  // fast-math doesn't differ ordered/unordered and uses ordered forms
  def : Pat<(brcond (i1 (seteq Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("insn_bf" # T # "oeq") GR:$ra, GR:$rb, bb:$dst)>;
  def : Pat<(brcond (i1 (setne Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("insn_bf" # T # "one") GR:$ra, GR:$rb, bb:$dst)>;
  def : Pat<(brcond (i1 (setlt Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("insn_bf" # T # "olt") GR:$ra, GR:$rb, bb:$dst)>;
  def : Pat<(brcond (i1 (setle Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("insn_bf" # T # "ole") GR:$ra, GR:$rb, bb:$dst)>;
  // fast-math greater branch: swap args
  def : Pat<(brcond (i1 (setgt Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("insn_bf" # T # "olt") GR:$rb, GR:$ra, bb:$dst)>;
  def : Pat<(brcond (i1 (setge Ty:$ra, Ty:$rb)), bb:$dst), (!cast<InstBase>("insn_bf" # T # "ole") GR:$rb, GR:$ra, bb:$dst)>;
}

defm : FP_SCALAR_BRANCH_PATTERNS<"ss", f32>;
defm : FP_SCALAR_BRANCH_PATTERNS<"sd", f64>;
defm : FP_SCALAR_BRANCH_PATTERNS<"sq", f128>;

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
