//===-- PostriscInstrInfoAtomic.td - Target Description for Postrisc ------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file describes the Postrisc atomic instructions.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// memory fences
//===----------------------------------------------------------------------===//
/*
atomic_fence args: ordering, scope (ignored)
enum AtomicOrdering {
  Acquire = 4, Release = 5, AcquireRelease = 6, SequentiallyConsistent = 7,
}
*/
let hasSideEffects = 1 in {
  def FENCE_A  : MISC_NoArgs<misc_opx_fence_acq,     (outs), (ins), [(atomic_fence (i64 4), timm)]>;
  def FENCE_R  : MISC_NoArgs<misc_opx_fence_rel,     (outs), (ins), [(atomic_fence (i64 5), timm)]>;
  def FENCE_AR : MISC_NoArgs<misc_opx_fence_acq_rel, (outs), (ins), [(atomic_fence (i64 6), timm)]>;
  def FENCE_SC : MISC_NoArgs<misc_opx_fence_seq_cst, (outs), (ins), [(atomic_fence (i64 7), timm)]>;
}

//===----------------------------------------------------------------------===//
// tablegen fixes
// atomic_load_128, atomic_store_128
// binary_atomic_op has no i128 variant, add it here
// ternary_atomic_op has no i128 variant, add it here
//===----------------------------------------------------------------------===//
def atomic_load_128 : PatFrag<(ops node:$ptr), (atomic_load node:$ptr)> {
  let IsAtomic = true;
  let MemoryVT = i128;
}

class relaxed_load<PatFrags base> : PatFrag<(ops node:$ptr), (base node:$ptr)> {
  let IsAtomic = 1;
  let IsAtomicOrderingAcquireOrStronger = 0;
}

class acquiring_load<PatFrags base> : PatFrag<(ops node:$ptr), (base node:$ptr)> {
  let IsAtomic = 1;
  let IsAtomicOrderingAcquire = 1;
}

def atomic_store_128 : PatFrag<(ops node:$val, node:$ptr), (atomic_store node:$val, node:$ptr)> {
  let IsAtomic = true;
  let MemoryVT = i128;
}

class relaxed_store<PatFrag base> : PatFrag<(ops node:$ptr, node:$val), (base node:$val, node:$ptr)> {
  let IsAtomic = 1;
  let IsAtomicOrderingReleaseOrStronger = 0;
}

class releasing_store<PatFrag base> : PatFrag<(ops node:$ptr, node:$val), (base node:$val, node:$ptr)> {
  let IsAtomic = 1;
  let IsAtomicOrderingRelease/*OrStronger*/ = 1;
}

def atomic_cmp_swap_i128 : PatFrag<(ops node:$ptr, node:$cmp, node:$val), (atomic_cmp_swap node:$ptr, node:$cmp, node:$val)> {
  let IsAtomic = true;
  let MemoryVT = i128;
}
defm atomic_cmp_swap_i128 : ternary_atomic_op_ord;

multiclass binary_atomic_op_i128<SDNode atomic_op> {
    def NAME#_i128 : PatFrag<(ops node:$ptr, node:$val), (atomic_op node:$ptr, node:$val)> {
      let IsAtomic = true;
      let MemoryVT = i128;
    }

    defm NAME#_i128  : binary_atomic_op_ord;
}
defm atomic_swap      : binary_atomic_op_i128<atomic_swap>;
defm atomic_load_add  : binary_atomic_op_i128<atomic_load_add>;
defm atomic_load_sub  : binary_atomic_op_i128<atomic_load_sub>;
defm atomic_load_and  : binary_atomic_op_i128<atomic_load_and>;
defm atomic_load_or   : binary_atomic_op_i128<atomic_load_or>;
defm atomic_load_xor  : binary_atomic_op_i128<atomic_load_xor>;
defm atomic_load_nand : binary_atomic_op_i128<atomic_load_nand>;
defm atomic_load_min  : binary_atomic_op_i128<atomic_load_min>;
defm atomic_load_max  : binary_atomic_op_i128<atomic_load_max>;
defm atomic_load_umin : binary_atomic_op_i128<atomic_load_umin>;
defm atomic_load_umax : binary_atomic_op_i128<atomic_load_umax>;

//===----------------------------------------------------------------------===//
// atomic load instructions
//===----------------------------------------------------------------------===//
multiclass
ATOMIC_LOAD<misc_opx OpcRelaxed, misc_opx OpcAcquire, PatFrag OpNode, ValueType Ty>
{
  def NAME    : MISC_Rab<OpcRelaxed, (outs GR:$ra), (ins GR:$rb), !strconcat(OpcRelaxed.mnem, "\t$ra, $rb"), [], IIC_iu_instr>;
  def NAME # A: MISC_Rab<OpcAcquire, (outs GR:$ra), (ins GR:$rb), !strconcat(OpcAcquire.mnem, "\t$ra, $rb"), [], IIC_iu_instr>;

  def : Pat<(Ty (relaxed_load  <OpNode> iPTR:$rb)), (!cast<InstBase>(NAME) GR:$rb)>;
  def : Pat<(Ty (acquiring_load<OpNode> iPTR:$rb)), (!cast<InstBase>(NAME # A) GR:$rb)>;
}

// atomic load monotonic (relaxed)
defm LDA_B: ATOMIC_LOAD<misc_opx_lda_b, misc_opx_lda_b_a, atomic_load_8,   i32>;
defm LDA_H: ATOMIC_LOAD<misc_opx_lda_h, misc_opx_lda_h_a, atomic_load_16,  i32>;
defm LDA_W: ATOMIC_LOAD<misc_opx_lda_w, misc_opx_lda_w_a, atomic_load_32,  i32>;
defm LDA_D: ATOMIC_LOAD<misc_opx_lda_d, misc_opx_lda_d_a, atomic_load_64,  i64>;
defm LDA_Q: ATOMIC_LOAD<misc_opx_lda_q, misc_opx_lda_q_a, atomic_load_128, i128>;

//===----------------------------------------------------------------------===//
// atomic store instructions
//===----------------------------------------------------------------------===//
multiclass
ATOMIC_STORE<misc_opx OpcRelaxed, misc_opx OpcRelease, PatFrag OpNode, ValueType Ty>
{
  def NAME     : MISC_Rab<OpcRelaxed, (outs), (ins GR:$ra, GR:$rb), !strconcat(OpcRelaxed.mnem, "\t$ra, $rb"), [], IIC_iu_instr>;
  def NAME # _R: MISC_Rab<OpcRelease, (outs), (ins GR:$ra, GR:$rb), !strconcat(OpcRelease.mnem, "\t$ra, $rb"), [], IIC_iu_instr>;

  def : Pat<(relaxed_store<OpNode>   iPTR:$rb, Ty:$ra), (!cast<InstBase>(NAME     ) GR:$ra, GR:$rb)>;
  def : Pat<(releasing_store<OpNode> iPTR:$rb, Ty:$ra), (!cast<InstBase>(NAME # _R) GR:$ra, GR:$rb)>;
}

// atomic store monotonic (relaxed)
defm STA_B: ATOMIC_STORE<misc_opx_sta_b, misc_opx_sta_b_r, atomic_store_8,   i32>;
defm STA_H: ATOMIC_STORE<misc_opx_sta_h, misc_opx_sta_h_r, atomic_store_16,  i32>;
defm STA_W: ATOMIC_STORE<misc_opx_sta_w, misc_opx_sta_w_r, atomic_store_32,  i32>;
defm STA_D: ATOMIC_STORE<misc_opx_sta_d, misc_opx_sta_d_r, atomic_store_64,  i64>;
defm STA_Q: ATOMIC_STORE<misc_opx_sta_q, misc_opx_sta_q_r, atomic_store_128, i128>;

//===----------------------------------------------------------------------===//
// CAS instructions
//===----------------------------------------------------------------------===//
multiclass
AMO_CAS_OP<misc_opx OpcRelaxed, misc_opx OpcAcquire, misc_opx OpcRelease, misc_opx OpcAcq_Rel,
           string PAT_T, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  let Constraints = "$swap = $ra" in
  def NAME      : MISC_Rabc<OpcRelaxed, (outs GR:$ra), (ins GR:$rb, GR:$rc, GR:$swap), !strconcat(OpcRelaxed.mnem, "\t$ra, $rb, $rc"), [], itin>;
  def NAME # _A : MISC_Rabc<OpcAcquire, (outs GR:$ra), (ins GR:$rb, GR:$rc, GR:$swap), !strconcat(OpcAcquire.mnem, "\t$ra, $rb, $rc"), [], itin>;
  def NAME # _R : MISC_Rabc<OpcRelease, (outs GR:$ra), (ins GR:$rb, GR:$rc, GR:$swap), !strconcat(OpcRelease.mnem, "\t$ra, $rb, $rc"), [], itin>;
  def NAME # _AR: MISC_Rabc<OpcAcq_Rel, (outs GR:$ra), (ins GR:$rb, GR:$rc, GR:$swap), !strconcat(OpcAcq_Rel.mnem, "\t$ra, $rb, $rc"), [], itin>;

  def : Pat<(!cast<PatFrag>("atomic_cmp_swap_" # PAT_T # "_monotonic") iPTR:$rb, Ty:$rc, Ty:$swap), (!cast<InstBase>(NAME      ) $rb, $rc, Ty:$swap)>;
  def : Pat<(!cast<PatFrag>("atomic_cmp_swap_" # PAT_T # "_acquire"  ) iPTR:$rb, Ty:$rc, Ty:$swap), (!cast<InstBase>(NAME # _A ) $rb, $rc, Ty:$swap)>;
  def : Pat<(!cast<PatFrag>("atomic_cmp_swap_" # PAT_T # "_release"  ) iPTR:$rb, Ty:$rc, Ty:$swap), (!cast<InstBase>(NAME # _R ) $rb, $rc, Ty:$swap)>;
  def : Pat<(!cast<PatFrag>("atomic_cmp_swap_" # PAT_T # "_acq_rel"  ) iPTR:$rb, Ty:$rc, Ty:$swap), (!cast<InstBase>(NAME # _AR) $rb, $rc, Ty:$swap)>;
}

defm CAS_B : AMO_CAS_OP<misc_opx_cas_b, misc_opx_cas_b_a, misc_opx_cas_b_r, misc_opx_cas_b_ar, "i8",   i32>;
defm CAS_H : AMO_CAS_OP<misc_opx_cas_h, misc_opx_cas_h_a, misc_opx_cas_h_r, misc_opx_cas_h_ar, "i16",  i32>;
defm CAS_W : AMO_CAS_OP<misc_opx_cas_w, misc_opx_cas_w_a, misc_opx_cas_w_r, misc_opx_cas_w_ar, "i32",  i32>;
defm CAS_D : AMO_CAS_OP<misc_opx_cas_d, misc_opx_cas_d_a, misc_opx_cas_d_r, misc_opx_cas_d_ar, "i64",  i64>;
defm CAS_Q : AMO_CAS_OP<misc_opx_cas_q, misc_opx_cas_q_a, misc_opx_cas_q_r, misc_opx_cas_q_ar, "i128", i128>;

//===----------------------------------------------------------------------===//
// swap instructions
//===----------------------------------------------------------------------===//
multiclass
AMO_SWAP_OP<misc_opx OpcRelaxed, misc_opx OpcAcquire, misc_opx OpcRelease, misc_opx OpcAcq_Rel,
  string PAT_T, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  def NAME      : MISC_Rabc<OpcRelaxed, (outs GR:$ra), (ins GR:$rb, GR:$rc), !strconcat(OpcRelaxed.mnem, "\t$ra, $rb, $rc"), [], itin>;
  def NAME # _A : MISC_Rabc<OpcAcquire, (outs GR:$ra), (ins GR:$rb, GR:$rc), !strconcat(OpcAcquire.mnem, "\t$ra, $rb, $rc"), [], itin>;
  def NAME # _R : MISC_Rabc<OpcRelease, (outs GR:$ra), (ins GR:$rb, GR:$rc), !strconcat(OpcRelease.mnem, "\t$ra, $rb, $rc"), [], itin>;
  def NAME # _AR: MISC_Rabc<OpcAcq_Rel, (outs GR:$ra), (ins GR:$rb, GR:$rc), !strconcat(OpcAcq_Rel.mnem, "\t$ra, $rb, $rc"), [], itin>;

  def : Pat<(!cast<PatFrag>("atomic_swap_" # PAT_T # "_monotonic") iPTR:$rb, Ty:$rc), (!cast<InstBase>(NAME      ) $rb, $rc)>;
  def : Pat<(!cast<PatFrag>("atomic_swap_" # PAT_T # "_acquire"  ) iPTR:$rb, Ty:$rc), (!cast<InstBase>(NAME # _A ) $rb, $rc)>;
  def : Pat<(!cast<PatFrag>("atomic_swap_" # PAT_T # "_release"  ) iPTR:$rb, Ty:$rc), (!cast<InstBase>(NAME # _R ) $rb, $rc)>;
  def : Pat<(!cast<PatFrag>("atomic_swap_" # PAT_T # "_acq_rel"  ) iPTR:$rb, Ty:$rc), (!cast<InstBase>(NAME # _AR) $rb, $rc)>;
}

defm SWAP_B : AMO_SWAP_OP<misc_opx_swap_b, misc_opx_swap_b_a, misc_opx_swap_b_r, misc_opx_swap_b_ar, "i8",   i32>;
defm SWAP_H : AMO_SWAP_OP<misc_opx_swap_h, misc_opx_swap_h_a, misc_opx_swap_h_r, misc_opx_swap_h_ar, "i16",  i32>;
defm SWAP_W : AMO_SWAP_OP<misc_opx_swap_w, misc_opx_swap_w_a, misc_opx_swap_w_r, misc_opx_swap_w_ar, "i32",  i32>;
defm SWAP_D : AMO_SWAP_OP<misc_opx_swap_d, misc_opx_swap_d_a, misc_opx_swap_d_r, misc_opx_swap_d_ar, "i64",  i64>;
defm SWAP_Q : AMO_SWAP_OP<misc_opx_swap_q, misc_opx_swap_q_a, misc_opx_swap_q_r, misc_opx_swap_q_ar, "i128", i128>;

//===----------------------------------------------------------------------===//
// LOAD-OP instructions
//===----------------------------------------------------------------------===//
multiclass
AMO_LOAD_OP<misc_opx OpcRelaxed, misc_opx OpcAcquire, misc_opx OpcRelease, misc_opx OpcAcq_Rel,
  string PAT_OP, string PAT_T, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  def NAME      : MISC_Rabc<OpcRelaxed, (outs GR:$ra), (ins GR:$rb, GR:$rc), !strconcat(OpcRelaxed.mnem, "\t$ra, $rb, $rc"), [], itin>;
  def NAME # _A : MISC_Rabc<OpcAcquire, (outs GR:$ra), (ins GR:$rb, GR:$rc), !strconcat(OpcAcquire.mnem, "\t$ra, $rb, $rc"), [], itin>;
  def NAME # _R : MISC_Rabc<OpcRelease, (outs GR:$ra), (ins GR:$rb, GR:$rc), !strconcat(OpcRelease.mnem, "\t$ra, $rb, $rc"), [], itin>;
  def NAME # _AR: MISC_Rabc<OpcAcq_Rel, (outs GR:$ra), (ins GR:$rb, GR:$rc), !strconcat(OpcAcq_Rel.mnem, "\t$ra, $rb, $rc"), [], itin>;

  def : Pat<(!cast<PatFrag>("atomic_load_" # PAT_OP # "_" # PAT_T # "_monotonic") iPTR:$rb, Ty:$rc), (!cast<InstBase>(NAME      ) $rb, $rc)>;
  def : Pat<(!cast<PatFrag>("atomic_load_" # PAT_OP # "_" # PAT_T # "_acquire"  ) iPTR:$rb, Ty:$rc), (!cast<InstBase>(NAME # _A ) $rb, $rc)>;
  def : Pat<(!cast<PatFrag>("atomic_load_" # PAT_OP # "_" # PAT_T # "_release"  ) iPTR:$rb, Ty:$rc), (!cast<InstBase>(NAME # _R ) $rb, $rc)>;
  def : Pat<(!cast<PatFrag>("atomic_load_" # PAT_OP # "_" # PAT_T # "_acq_rel"  ) iPTR:$rb, Ty:$rc), (!cast<InstBase>(NAME # _AR) $rb, $rc)>;
}

multiclass AMO_LOAD_OPS<string INSN, string PAT_OP> {
  defm NAME # _B : AMO_LOAD_OP<!cast<misc_opx>("misc_opx_" # INSN # "_b"),
                               !cast<misc_opx>("misc_opx_" # INSN # "_b_a"),
                               !cast<misc_opx>("misc_opx_" # INSN # "_b_r"),
                               !cast<misc_opx>("misc_opx_" # INSN # "_b_ar"),
                               PAT_OP, "i8",  i32>;
  defm NAME # _H : AMO_LOAD_OP<!cast<misc_opx>("misc_opx_" # INSN # "_h"),
                               !cast<misc_opx>("misc_opx_" # INSN # "_h_a"),
                               !cast<misc_opx>("misc_opx_" # INSN # "_h_r"),
                               !cast<misc_opx>("misc_opx_" # INSN # "_h_ar"),
                               PAT_OP, "i16", i32>;
  defm NAME # _W : AMO_LOAD_OP<!cast<misc_opx>("misc_opx_" # INSN # "_w"),
                               !cast<misc_opx>("misc_opx_" # INSN # "_w_a"),
                               !cast<misc_opx>("misc_opx_" # INSN # "_w_r"),
                               !cast<misc_opx>("misc_opx_" # INSN # "_w_ar"),
                               PAT_OP, "i32", i32>;
  defm NAME # _D : AMO_LOAD_OP<!cast<misc_opx>("misc_opx_" # INSN # "_d"),
                               !cast<misc_opx>("misc_opx_" # INSN # "_d_a"),
                               !cast<misc_opx>("misc_opx_" # INSN # "_d_r"),
                               !cast<misc_opx>("misc_opx_" # INSN # "_d_ar"),
                               PAT_OP, "i64", i64>;
  defm NAME # _Q : AMO_LOAD_OP<!cast<misc_opx>("misc_opx_" # INSN # "_q"),
                               !cast<misc_opx>("misc_opx_" # INSN # "_q_a"),
                               !cast<misc_opx>("misc_opx_" # INSN # "_q_r"),
                               !cast<misc_opx>("misc_opx_" # INSN # "_q_ar"),
                               PAT_OP, "i128", i128>;
}

defm LD_ADD  : AMO_LOAD_OPS<"ld_add",  "add">;
defm LD_AND  : AMO_LOAD_OPS<"ld_and",  "and">;
defm LD_OR   : AMO_LOAD_OPS<"ld_or",   "or">;
defm LD_XOR  : AMO_LOAD_OPS<"ld_xor",  "xor">;
defm LD_SMIN : AMO_LOAD_OPS<"ld_smin", "min">;
defm LD_SMAX : AMO_LOAD_OPS<"ld_smax", "max">;
defm LD_UMIN : AMO_LOAD_OPS<"ld_umin", "umin">;
defm LD_UMAX : AMO_LOAD_OPS<"ld_umax", "umax">;

//===----------------------------------------------------------------------===//
// STORE-OP instructions
//===----------------------------------------------------------------------===//
multiclass
AMO_STORE_OP<misc_opx OpcRelaxed, misc_opx OpcRelease, string PAT_OP, string PAT_T, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  let ra = 0 in {
    def NAME    : MISC_Rabc<OpcRelaxed, (outs), (ins GR:$rb, GR:$rc), !strconcat(OpcRelaxed.mnem, "\t$rb, $rc"), [], itin>;
    def NAME # R: MISC_Rabc<OpcRelease, (outs), (ins GR:$rb, GR:$rc), !strconcat(OpcRelease.mnem, "\t$rb, $rc"), [], itin>;
  }

  // TODO: wait for corresponding tablegen patterns to match 'atomic_store_op'

  def : Pat<(!cast<PatFrag>("atomic_load_" # PAT_OP # "_" # PAT_T # "_monotonic") iPTR:$rb, Ty:$rc), (!cast<InstBase>(NAME    ) $rb, $rc)>;
  def : Pat<(!cast<PatFrag>("atomic_load_" # PAT_OP # "_" # PAT_T # "_release"  ) iPTR:$rb, Ty:$rc), (!cast<InstBase>(NAME # R) $rb, $rc)>;
}

multiclass AMO_STORE_OPS<string INSN, string PAT_OP> {
  defm NAME # _B : AMO_STORE_OP<!cast<misc_opx>("misc_opx_" # INSN # "_b"),
                                !cast<misc_opx>("misc_opx_" # INSN # "_b_r"),
                                PAT_OP, "i8",  i32>;
  defm NAME # _H : AMO_STORE_OP<!cast<misc_opx>("misc_opx_" # INSN # "_h"),
                                !cast<misc_opx>("misc_opx_" # INSN # "_h_r"),
                                PAT_OP, "i16", i32>;
  defm NAME # _W : AMO_STORE_OP<!cast<misc_opx>("misc_opx_" # INSN # "_w"),
                                !cast<misc_opx>("misc_opx_" # INSN # "_w_r"),
                                PAT_OP, "i32", i32>;
  defm NAME # _D : AMO_STORE_OP<!cast<misc_opx>("misc_opx_" # INSN # "_d"),
                                !cast<misc_opx>("misc_opx_" # INSN # "_d_r"),
                                PAT_OP, "i64", i64>;
  defm NAME # _Q : AMO_STORE_OP<!cast<misc_opx>("misc_opx_" # INSN # "_q"),
                                !cast<misc_opx>("misc_opx_" # INSN # "_q_r"),
                                PAT_OP, "i128", i128>;
}

defm ST_ADD  : AMO_STORE_OPS<"st_add",  "add">;
defm ST_AND  : AMO_STORE_OPS<"st_and",  "and">;
defm ST_OR   : AMO_STORE_OPS<"st_or",   "or">;
defm ST_XOR  : AMO_STORE_OPS<"st_xor",  "xor">;
defm ST_SMIN : AMO_STORE_OPS<"st_smin", "min">;
defm ST_SMAX : AMO_STORE_OPS<"st_smax", "max">;
defm ST_UMIN : AMO_STORE_OPS<"st_umin", "umin">;
defm ST_UMAX : AMO_STORE_OPS<"st_umax", "umax">;

//===----------------------------------------------------------------------===//
// LOAD-SUB(V) => LOAD-ADD (0-V)
//===----------------------------------------------------------------------===//
multiclass
AMO_LOAD_SUB<MISC_Rabc Inst, MISC_Rabc InstA, MISC_Rabc InstR, MISC_Rabc InstAR, string OpcStr, InstBase SUB, ValueType Ty>
{
  def : Pat<(Ty (!cast<PatFrag>(OpcStr # "_monotonic") iPTR:$ptr, Ty:$val)), (Inst   GR:$ptr, (SUB (Ty gz), GR:$val))>;
  def : Pat<(Ty (!cast<PatFrag>(OpcStr # "_acquire"  ) iPTR:$ptr, Ty:$val)), (InstA  GR:$ptr, (SUB (Ty gz), GR:$val))>;
  def : Pat<(Ty (!cast<PatFrag>(OpcStr # "_release"  ) iPTR:$ptr, Ty:$val)), (InstR  GR:$ptr, (SUB (Ty gz), GR:$val))>;
  def : Pat<(Ty (!cast<PatFrag>(OpcStr # "_acq_rel"  ) iPTR:$ptr, Ty:$val)), (InstAR GR:$ptr, (SUB (Ty gz), GR:$val))>;
}

defm : AMO_LOAD_SUB<LD_ADD_B, LD_ADD_B_A, LD_ADD_B_R, LD_ADD_B_AR, "atomic_load_sub_i8",   SUBWS, i32>;
defm : AMO_LOAD_SUB<LD_ADD_H, LD_ADD_H_A, LD_ADD_H_R, LD_ADD_H_AR, "atomic_load_sub_i16",  SUBWS, i32>;
defm : AMO_LOAD_SUB<LD_ADD_W, LD_ADD_W_A, LD_ADD_W_R, LD_ADD_W_AR, "atomic_load_sub_i32",  SUBWS, i32>;
defm : AMO_LOAD_SUB<LD_ADD_D, LD_ADD_D_A, LD_ADD_D_R, LD_ADD_D_AR, "atomic_load_sub_i64",  SUB,   i64>;
defm : AMO_LOAD_SUB<LD_ADD_Q, LD_ADD_Q_A, LD_ADD_Q_R, LD_ADD_Q_AR, "atomic_load_sub_i128", SUBQ, i128>;
