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

def MemoryOrder_xform : SDNodeXForm<imm, [{
  return getImm(N, N->getZExtValue());
}]>;
def MemoryOrder : Operand<i32>, IntImmLeaf<i32,
  [{ return isUInt<3>(Imm.getZExtValue()); }], MemoryOrder_xform> {
  let DecoderMethod = "DecodeUIMM<3>";
}

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
    def insn_fence : MISC_Fence<misc_opx_fence,
        (outs), (ins MemoryOrder:$memory_order), "fence\t$memory_order", []>;
}

def : Pat<(atomic_fence (i64 4), timm), (insn_fence memory_order_acquire.value)>;
def : Pat<(atomic_fence (i64 5), timm), (insn_fence memory_order_release.value)>;
def : Pat<(atomic_fence (i64 6), timm), (insn_fence memory_order_acq_rel.value)>;
def : Pat<(atomic_fence (i64 7), timm), (insn_fence memory_order_seq_cst.value)>;

def : InstAlias<"fence.acquire", (insn_fence memory_order_acquire.value)>;
def : InstAlias<"fence.release", (insn_fence memory_order_release.value)>;
def : InstAlias<"fence.acq_rel", (insn_fence memory_order_acq_rel.value)>;
def : InstAlias<"fence.seq_cst", (insn_fence memory_order_seq_cst.value)>;

//===----------------------------------------------------------------------===//
// atomic load instructions
//===----------------------------------------------------------------------===//

// llvm hasn't atomic_load_128 variant, add it here
def atomic_load_128 : PatFrag<(ops node:$ptr), (atomic_load node:$ptr)> {
  let IsAtomic = true;
  let MemoryVT = i128;
}

class relaxed_load<PatFrags base>
  : PatFrag<(ops node:$ptr), (base node:$ptr)> {
  let IsAtomic = 1;
  let IsAtomicOrderingAcquireOrStronger = 0;
}

class acquiring_load<PatFrags base>
  : PatFrag<(ops node:$ptr), (base node:$ptr)> {
  let IsAtomic = 1;
  let IsAtomicOrderingAcquire = 1;
}

class seq_cst_load<PatFrags base>
  : PatFrag<(ops node:$ptr), (base node:$ptr)> {
  let IsAtomic = 1;
  let IsAtomicOrderingSequentiallyConsistent = 1;
}

multiclass
ATOMIC_LOAD<misc_opx opx, string OpcStr, PatFrag OpNode, ValueType Ty>
{
  def NAME : MISC_atomic_loadstore<opx,
                 (outs GR:$ra), (ins GR:$rb, MemoryOrder:$memory_order),
                 !strconcat(OpcStr, "\t$ra, $rb, $memory_order"),
                 [], IIC_iu_instr>;

  // FIXME: can't use NAME as Insn
  def : Pat<(Ty (relaxed_load  <OpNode> iPTR:$rb)),
            (!cast<InstBase>(NAME) GR:$rb, memory_order_relaxed.value)>;
  def : Pat<(Ty (acquiring_load<OpNode> iPTR:$rb)),
            (!cast<InstBase>(NAME) GR:$rb, memory_order_acquire.value)>;
  def : Pat<(Ty (seq_cst_load  <OpNode> iPTR:$rb)),
            (!cast<InstBase>(NAME) GR:$rb, memory_order_seq_cst.value)>;

  def : InstAlias<!strconcat(OpcStr, ".relaxed\t$ra, $rb"),
        (!cast<InstBase>(NAME) GR:$ra, GR:$rb, memory_order_relaxed.value)>;
  def : InstAlias<!strconcat(OpcStr, ".acquire\t$ra, $rb"),
        (!cast<InstBase>(NAME) GR:$ra, GR:$rb, memory_order_acquire.value)>;
  def : InstAlias<!strconcat(OpcStr, ".sec_cst\t$ra, $rb"),
        (!cast<InstBase>(NAME) GR:$ra, GR:$rb, memory_order_seq_cst.value)>;
}

// atomic load monotonic (relaxed)
defm insn_atomic_load_8:   ATOMIC_LOAD<misc_opx_ldab, "ldab", atomic_load_8,   i32>;
defm insn_atomic_load_16:  ATOMIC_LOAD<misc_opx_ldah, "ldah", atomic_load_16,  i32>;
defm insn_atomic_load_32:  ATOMIC_LOAD<misc_opx_ldaw, "ldaw", atomic_load_32,  i32>;
defm insn_atomic_load_64:  ATOMIC_LOAD<misc_opx_ldad, "ldad", atomic_load_64,  i64>;
defm insn_atomic_load_128: ATOMIC_LOAD<misc_opx_ldaq, "ldaq", atomic_load_128, i128>;

//===----------------------------------------------------------------------===//
// atomic store instructions
//===----------------------------------------------------------------------===//

// llvm hasn't atomic_store_128 variant, add it here
def atomic_store_128 : PatFrag<(ops node:$val, node:$ptr),
                               (atomic_store node:$val, node:$ptr)> {
  let IsAtomic = true;
  let MemoryVT = i128;
}

class relaxed_store<PatFrag base>
  : PatFrag<(ops node:$ptr, node:$val), (base node:$val, node:$ptr)> {
  let IsAtomic = 1;
  let IsAtomicOrderingReleaseOrStronger = 0;
}

class releasing_store<PatFrag base>
  : PatFrag<(ops node:$ptr, node:$val), (base node:$val, node:$ptr)> {
  let IsAtomic = 1;
  let IsAtomicOrderingRelease/*OrStronger*/ = 1;
}

class seq_cst_store<PatFrags base>
  : PatFrag<(ops node:$ptr, node:$val), (base node:$val, node:$ptr)> {
  let IsAtomic = 1;
  let IsAtomicOrderingSequentiallyConsistent = 1;
}

multiclass
ATOMIC_STORE<misc_opx opx, string OpcStr, PatFrag OpNode, ValueType Ty>
{
  def NAME : MISC_atomic_loadstore<opx,
                 (outs), (ins GR:$ra, GR:$rb, MemoryOrder:$memory_order),
                 !strconcat(OpcStr, "\t$ra, $rb, $memory_order"),
                 [], IIC_iu_instr>;

  def : Pat<(relaxed_store<OpNode>   iPTR:$rb, Ty:$ra),
            (!cast<InstBase>(NAME) GR:$ra, GR:$rb, memory_order_relaxed.value)>;
  def : Pat<(releasing_store<OpNode> iPTR:$rb, Ty:$ra),
            (!cast<InstBase>(NAME) GR:$ra, GR:$rb, memory_order_release.value)>;
  def : Pat<(seq_cst_store<OpNode>   iPTR:$rb, Ty:$ra),
            (!cast<InstBase>(NAME) GR:$ra, GR:$rb, memory_order_seq_cst.value)>;

  def : InstAlias<!strconcat(OpcStr, ".relaxed\t$ra, $rb"),
        (!cast<InstBase>(NAME) GR:$ra, GR:$rb, memory_order_relaxed.value)>;
  def : InstAlias<!strconcat(OpcStr, ".release\t$ra, $rb"),
        (!cast<InstBase>(NAME) GR:$ra, GR:$rb, memory_order_release.value)>;
  def : InstAlias<!strconcat(OpcStr, ".sec_cst\t$ra, $rb"),
        (!cast<InstBase>(NAME) GR:$ra, GR:$rb, memory_order_seq_cst.value)>;
}

// atomic store monotonic (relaxed)
defm insn_atomic_store_8:   ATOMIC_STORE<misc_opx_stab, "stab", atomic_store_8,   i32>;
defm insn_atomic_store_16:  ATOMIC_STORE<misc_opx_stah, "stah", atomic_store_16,  i32>;
defm insn_atomic_store_32:  ATOMIC_STORE<misc_opx_staw, "staw", atomic_store_32,  i32>;
defm insn_atomic_store_64:  ATOMIC_STORE<misc_opx_stad, "stad", atomic_store_64,  i64>;
defm insn_atomic_store_128: ATOMIC_STORE<misc_opx_staq, "staq", atomic_store_128, i128>;

//===----------------------------------------------------------------------===//
// CAS instructions
//===----------------------------------------------------------------------===//
// standard ternary_atomic_op has no 128 variant, add it here
def atomic_cmp_swap_i128 :
  PatFrag<(ops node:$ptr, node:$cmp, node:$val),
          (atomic_cmp_swap node:$ptr, node:$cmp, node:$val)> {
  let IsAtomic = true;
  let MemoryVT = i128;
}
defm atomic_cmp_swap_i128 : ternary_atomic_op_ord;

multiclass
AMO_CAS_OP<string INSN_T, string PAT_T, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  let Constraints = "$swap = $ra" in
  def NAME : MISC_RabcMo<!cast<misc_opx>("misc_opx_cas" # INSN_T),
         (outs GR:$ra), (ins GR:$rb, GR:$rc, GR:$swap, MemoryOrder:$memory_order),
         !strconcat("cas", INSN_T, "\t$ra, $rb, $rc, $memory_order"), [], itin>;

  def : Pat<(!cast<PatFrag>("atomic_cmp_swap_" # PAT_T # "_monotonic") iPTR:$rb, Ty:$rc, Ty:$swap),
            (!cast<InstBase>(NAME) $rb, $rc, Ty:$swap, memory_order_relaxed.value)>;
  def : Pat<(!cast<PatFrag>("atomic_cmp_swap_" # PAT_T # "_acquire"  ) iPTR:$rb, Ty:$rc, Ty:$swap),
            (!cast<InstBase>(NAME) $rb, $rc, Ty:$swap, memory_order_acquire.value)>;
  def : Pat<(!cast<PatFrag>("atomic_cmp_swap_" # PAT_T # "_release"  ) iPTR:$rb, Ty:$rc, Ty:$swap),
            (!cast<InstBase>(NAME) $rb, $rc, Ty:$swap, memory_order_release.value)>;
  def : Pat<(!cast<PatFrag>("atomic_cmp_swap_" # PAT_T # "_acq_rel"  ) iPTR:$rb, Ty:$rc, Ty:$swap),
            (!cast<InstBase>(NAME) $rb, $rc, Ty:$swap, memory_order_acq_rel.value)>;
  def : Pat<(!cast<PatFrag>("atomic_cmp_swap_" # PAT_T # "_seq_cst"  ) iPTR:$rb, Ty:$rc, Ty:$swap),
            (!cast<InstBase>(NAME) $rb, $rc, Ty:$swap, memory_order_seq_cst.value)>;

  def : InstAlias<!strconcat("cas", INSN_T, ".relaxed\t$ra, $rb, $rc"),
        (!cast<InstBase>(NAME) GR:$ra, GR:$rb, GR:$rc, memory_order_relaxed.value)>;
  def : InstAlias<!strconcat("cas", INSN_T, ".acquire\t$ra, $rb, $rc"),
        (!cast<InstBase>(NAME) GR:$ra, GR:$rb, GR:$rc, memory_order_acquire.value)>;
  def : InstAlias<!strconcat("cas", INSN_T, ".release\t$ra, $rb, $rc"),
        (!cast<InstBase>(NAME) GR:$ra, GR:$rb, GR:$rc, memory_order_release.value)>;
  def : InstAlias<!strconcat("cas", INSN_T, ".acq_rel\t$ra, $rb, $rc"),
        (!cast<InstBase>(NAME) GR:$ra, GR:$rb, GR:$rc, memory_order_acq_rel.value)>;
  def : InstAlias<!strconcat("cas", INSN_T, ".seq_cst\t$ra, $rb, $rc"),
        (!cast<InstBase>(NAME) GR:$ra, GR:$rb, GR:$rc, memory_order_seq_cst.value)>;
}

defm CASB : AMO_CAS_OP<"b", "i8",   i32>;
defm CASH : AMO_CAS_OP<"h", "i16",  i32>;
defm CASW : AMO_CAS_OP<"w", "i32",  i32>;
defm CASD : AMO_CAS_OP<"d", "i64",  i64>;
defm CASQ : AMO_CAS_OP<"q", "i128", i128>;

//===----------------------------------------------------------------------===//
// read-modify-write instructions
//===----------------------------------------------------------------------===//
multiclass
RMW_INSN<misc_opx opx, string OpcStr, PatFrag OpNode, ValueType Ty,
        InstrItinClass itin = IIC_iu_instr> {
  def NAME : MISC_RabcMo<opx,
                 (outs GR:$ra), (ins GR:$rb, GR:$rc, MemoryOrder:$memory_order),
                 !strconcat(OpcStr, "\t$ra, $rb, $rc, $memory_order"),
                 [(set Ty:$ra, (OpNode iPTR:$rb, Ty:$rc))], itin>;
}

//===----------------------------------------------------------------------===//
// swap instructions
//===----------------------------------------------------------------------===//
// standard binary_atomic_op has no 128 variant, add it here
def atomic_swap_i128 : PatFrag<(ops node:$ptr, node:$val),
                              (atomic_swap node:$ptr, node:$val)> {
    let IsAtomic = true;
    let MemoryVT = i128;
}
defm atomic_swap_i128 : binary_atomic_op_ord;

multiclass
AMO_SWAP_OP<misc_opx opx, string OpcStr, string PAT_T, ValueType Ty,
  InstrItinClass itin = IIC_iu_instr>
{
  def NAME : MISC_RabcMo<opx, (outs GR:$ra), (ins GR:$rb, GR:$rc, MemoryOrder:$memory_order),
                 !strconcat(OpcStr, "\t$ra, $rb, $rc, $memory_order"), [], itin>;

  def : Pat<(!cast<PatFrag>("atomic_swap_" # PAT_T # "_monotonic") iPTR:$rb, Ty:$rc),
            (!cast<InstBase>(NAME) $rb, $rc, memory_order_relaxed.value)>;
  def : Pat<(!cast<PatFrag>("atomic_swap_" # PAT_T # "_acquire"  ) iPTR:$rb, Ty:$rc),
            (!cast<InstBase>(NAME) $rb, $rc, memory_order_acquire.value)>;
  def : Pat<(!cast<PatFrag>("atomic_swap_" # PAT_T # "_release"  ) iPTR:$rb, Ty:$rc),
            (!cast<InstBase>(NAME) $rb, $rc, memory_order_release.value)>;
  def : Pat<(!cast<PatFrag>("atomic_swap_" # PAT_T # "_acq_rel"  ) iPTR:$rb, Ty:$rc),
            (!cast<InstBase>(NAME) $rb, $rc, memory_order_acq_rel.value)>;
  def : Pat<(!cast<PatFrag>("atomic_swap_" # PAT_T # "_seq_cst"  ) iPTR:$rb, Ty:$rc),
            (!cast<InstBase>(NAME) $rb, $rc, memory_order_seq_cst.value)>;

  def : InstAlias<!strconcat(OpcStr, ".relaxed\t$ra, $rb, $rc"),
        (!cast<InstBase>(NAME) GR:$ra, GR:$rb, GR:$rc, memory_order_relaxed.value)>;
  def : InstAlias<!strconcat(OpcStr, ".acquire\t$ra, $rb, $rc"),
        (!cast<InstBase>(NAME) GR:$ra, GR:$rb, GR:$rc, memory_order_acquire.value)>;
  def : InstAlias<!strconcat(OpcStr, ".release\t$ra, $rb, $rc"),
        (!cast<InstBase>(NAME) GR:$ra, GR:$rb, GR:$rc, memory_order_release.value)>;
  def : InstAlias<!strconcat(OpcStr, ".acq_rel\t$ra, $rb, $rc"),
        (!cast<InstBase>(NAME) GR:$ra, GR:$rb, GR:$rc, memory_order_acq_rel.value)>;
  def : InstAlias<!strconcat(OpcStr, ".seq_cst\t$ra, $rb, $rc"),
        (!cast<InstBase>(NAME) GR:$ra, GR:$rb, GR:$rc, memory_order_seq_cst.value)>;
}

defm SWAPB : AMO_SWAP_OP<misc_opx_swapb, "swapb", "i8",   i32>;
defm SWAPH : AMO_SWAP_OP<misc_opx_swaph, "swaph", "i16",  i32>;
defm SWAPW : AMO_SWAP_OP<misc_opx_swapw, "swapw", "i32",  i32>;
defm SWAPD : AMO_SWAP_OP<misc_opx_swapd, "swapd", "i64",  i64>;
defm SWAPQ : AMO_SWAP_OP<misc_opx_swapq, "swapq", "i128", i128>;

//===----------------------------------------------------------------------===//
// LOAD-OP instructions
//===----------------------------------------------------------------------===//
multiclass
AMO_LOAD_OP<string PAT_OP, string PAT_T, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  def insn_ # NAME : MISC_RabcMo<!cast<misc_opx>("misc_opx_" # NAME),
                 (outs GR:$ra), (ins GR:$rb, GR:$rc, MemoryOrder:$memory_order),
                 !strconcat(NAME, "\t$ra, $rb, $rc, $memory_order"), [], itin>;

  def : Pat<(!cast<PatFrag>("atomic_load_" # PAT_OP # "_" # PAT_T # "_monotonic") iPTR:$rb, Ty:$rc),
            (!cast<InstBase>("insn_" # NAME) $rb, $rc, memory_order_relaxed.value)>;
  def : Pat<(!cast<PatFrag>("atomic_load_" # PAT_OP # "_" # PAT_T # "_acquire"  ) iPTR:$rb, Ty:$rc),
            (!cast<InstBase>("insn_" # NAME) $rb, $rc, memory_order_acquire.value)>;
  def : Pat<(!cast<PatFrag>("atomic_load_" # PAT_OP # "_" # PAT_T # "_release"  ) iPTR:$rb, Ty:$rc),
            (!cast<InstBase>("insn_" # NAME) $rb, $rc, memory_order_release.value)>;
  def : Pat<(!cast<PatFrag>("atomic_load_" # PAT_OP # "_" # PAT_T # "_acq_rel"  ) iPTR:$rb, Ty:$rc),
            (!cast<InstBase>("insn_" # NAME) $rb, $rc, memory_order_acq_rel.value)>;
  def : Pat<(!cast<PatFrag>("atomic_load_" # PAT_OP # "_" # PAT_T # "_seq_cst"  ) iPTR:$rb, Ty:$rc),
            (!cast<InstBase>("insn_" # NAME) $rb, $rc, memory_order_seq_cst.value)>;

  def : InstAlias<!strconcat(NAME, ".relaxed\t$ra, $rb, $rc"),
        (!cast<InstBase>("insn_" # NAME) GR:$ra, GR:$rb, GR:$rc, memory_order_relaxed.value)>;
  def : InstAlias<!strconcat(NAME, ".acquire\t$ra, $rb, $rc"),
        (!cast<InstBase>("insn_" # NAME) GR:$ra, GR:$rb, GR:$rc, memory_order_acquire.value)>;
  def : InstAlias<!strconcat(NAME, ".release\t$ra, $rb, $rc"),
        (!cast<InstBase>("insn_" # NAME) GR:$ra, GR:$rb, GR:$rc, memory_order_release.value)>;
  def : InstAlias<!strconcat(NAME, ".acq_rel\t$ra, $rb, $rc"),
        (!cast<InstBase>("insn_" # NAME) GR:$ra, GR:$rb, GR:$rc, memory_order_acq_rel.value)>;
  def : InstAlias<!strconcat(NAME, ".seq_cst\t$ra, $rb, $rc"),
        (!cast<InstBase>("insn_" # NAME) GR:$ra, GR:$rb, GR:$rc, memory_order_seq_cst.value)>;
}

multiclass AMO_LOAD_OPS<string PAT_OP> {
  defm NAME # b : AMO_LOAD_OP<PAT_OP, "i8",  i32>;
  defm NAME # h : AMO_LOAD_OP<PAT_OP, "i16", i32>;
  defm NAME # w : AMO_LOAD_OP<PAT_OP, "i32", i32>;
  defm NAME # d : AMO_LOAD_OP<PAT_OP, "i64", i64>;
}

defm ldadd  : AMO_LOAD_OPS<"add">;
defm ldand  : AMO_LOAD_OPS<"and">;
defm ldor   : AMO_LOAD_OPS<"or">;
defm ldxor  : AMO_LOAD_OPS<"xor">;
defm ldsmin : AMO_LOAD_OPS<"min">;
defm ldsmax : AMO_LOAD_OPS<"max">;
defm ldumin : AMO_LOAD_OPS<"umin">;
defm ldumax : AMO_LOAD_OPS<"umax">;

//===----------------------------------------------------------------------===//
// STORE-OP instructions
//===----------------------------------------------------------------------===//
multiclass
AMO_STORE_OP<string PAT_OP, string PAT_T, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  let ra = 0 in
  def insn_ # NAME : MISC_RabcMo<!cast<misc_opx>("misc_opx_" # NAME),
                 (outs), (ins GR:$rb, GR:$rc, MemoryOrder:$memory_order),
                 !strconcat(NAME, "\t$rb, $rc, $memory_order"), [], itin>;

  // FIXME: find corresponding patterns to match st*op
  def : Pat<(!cast<PatFrag>("atomic_load_" # PAT_OP # "_" # PAT_T # "_monotonic") iPTR:$rb, Ty:$rc),
            (!cast<InstBase>("insn_" # NAME) $rb, $rc, memory_order_relaxed.value)>;
  def : Pat<(!cast<PatFrag>("atomic_load_" # PAT_OP # "_" # PAT_T # "_acquire"  ) iPTR:$rb, Ty:$rc),
            (!cast<InstBase>("insn_" # NAME) $rb, $rc, memory_order_acquire.value)>;
  def : Pat<(!cast<PatFrag>("atomic_load_" # PAT_OP # "_" # PAT_T # "_release"  ) iPTR:$rb, Ty:$rc),
            (!cast<InstBase>("insn_" # NAME) $rb, $rc, memory_order_release.value)>;
  def : Pat<(!cast<PatFrag>("atomic_load_" # PAT_OP # "_" # PAT_T # "_acq_rel"  ) iPTR:$rb, Ty:$rc),
            (!cast<InstBase>("insn_" # NAME) $rb, $rc, memory_order_acq_rel.value)>;
  def : Pat<(!cast<PatFrag>("atomic_load_" # PAT_OP # "_" # PAT_T # "_seq_cst"  ) iPTR:$rb, Ty:$rc),
            (!cast<InstBase>("insn_" # NAME) $rb, $rc, memory_order_seq_cst.value)>;

  def : InstAlias<!strconcat(NAME, ".relaxed\t$rb, $rc"),
        (!cast<InstBase>("insn_" # NAME) GR:$rb, GR:$rc, memory_order_relaxed.value)>;
  def : InstAlias<!strconcat(NAME, ".acquire\t$rb, $rc"),
        (!cast<InstBase>("insn_" # NAME) GR:$rb, GR:$rc, memory_order_acquire.value)>;
  def : InstAlias<!strconcat(NAME, ".release\t$rb, $rc"),
        (!cast<InstBase>("insn_" # NAME) GR:$rb, GR:$rc, memory_order_release.value)>;
  def : InstAlias<!strconcat(NAME, ".acq_rel\t$rb, $rc"),
        (!cast<InstBase>("insn_" # NAME) GR:$rb, GR:$rc, memory_order_acq_rel.value)>;
  def : InstAlias<!strconcat(NAME, ".seq_cst\t$rb, $rc"),
        (!cast<InstBase>("insn_" # NAME) GR:$rb, GR:$rc, memory_order_seq_cst.value)>;
}

multiclass AMO_STORE_OPS<string PAT_OP> {
  defm NAME # b : AMO_STORE_OP<PAT_OP, "i8",  i32>;
  defm NAME # h : AMO_STORE_OP<PAT_OP, "i16", i32>;
  defm NAME # w : AMO_STORE_OP<PAT_OP, "i32", i32>;
  defm NAME # d : AMO_STORE_OP<PAT_OP, "i64", i64>;
}

defm stadd  : AMO_STORE_OPS<"add">;
defm stand  : AMO_STORE_OPS<"and">;
defm stor   : AMO_STORE_OPS<"or">;
defm stxor  : AMO_STORE_OPS<"xor">;
defm stsmin : AMO_STORE_OPS<"min">;
defm stsmax : AMO_STORE_OPS<"max">;
defm stumin : AMO_STORE_OPS<"umin">;
defm stumax : AMO_STORE_OPS<"umax">;

//===----------------------------------------------------------------------===//
// LOAD-SUB(V) => LOAD-ADD (0-V)
//===----------------------------------------------------------------------===//
multiclass
AMO_LOAD_SUB<MISC_RabcMo Inst, string OpcStr, InstBase SUBFI, ValueType Ty>
{
  def : Pat<(Ty (!cast<PatFrag>(OpcStr # "_monotonic") iPTR:$ptr, Ty:$val)),
            (Inst GR:$ptr, (SUBFI GR:$val, 0), memory_order_relaxed.value)>;
  def : Pat<(Ty (!cast<PatFrag>(OpcStr # "_acquire"  ) iPTR:$ptr, Ty:$val)),
            (Inst GR:$ptr, (SUBFI GR:$val, 0), memory_order_acquire.value)>;
  def : Pat<(Ty (!cast<PatFrag>(OpcStr # "_release"  ) iPTR:$ptr, Ty:$val)),
            (Inst GR:$ptr, (SUBFI GR:$val, 0), memory_order_release.value)>;
  def : Pat<(Ty (!cast<PatFrag>(OpcStr # "_acq_rel"  ) iPTR:$ptr, Ty:$val)),
            (Inst GR:$ptr, (SUBFI GR:$val, 0), memory_order_acq_rel.value)>;
  def : Pat<(Ty (!cast<PatFrag>(OpcStr # "_seq_cst"  ) iPTR:$ptr, Ty:$val)),
            (Inst GR:$ptr, (SUBFI GR:$val, 0), memory_order_seq_cst.value)>;
}

defm : AMO_LOAD_SUB<insn_ldaddb, "atomic_load_sub_i8",  SUBFIWSri, i32>;
defm : AMO_LOAD_SUB<insn_ldaddh, "atomic_load_sub_i16", SUBFIWSri, i32>;
defm : AMO_LOAD_SUB<insn_ldaddw, "atomic_load_sub_i32", SUBFIWSri, i32>;
defm : AMO_LOAD_SUB<insn_ldaddd, "atomic_load_sub_i64", SUBFIri,   i64>;
