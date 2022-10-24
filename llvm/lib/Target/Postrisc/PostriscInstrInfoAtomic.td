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
  return getUnsignedConstant(N, N->getZExtValue());
}]>;
def MemoryOrder : Operand<i32>, IntImmLeaf<i32,
  [{ return isZextInt(Imm, 3); }], MemoryOrder_xform> {
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
    def FENCE : MISC_Fence<misc_opx_fence,
        (outs), (ins MemoryOrder:$memory_order), "fence\t$memory_order", []>;
}

def : Pat<(atomic_fence (i64 4), timm), (FENCE memory_order_acquire.value)>;
def : Pat<(atomic_fence (i64 5), timm), (FENCE memory_order_release.value)>;
def : Pat<(atomic_fence (i64 6), timm), (FENCE memory_order_acq_rel.value)>;
def : Pat<(atomic_fence (i64 7), timm), (FENCE memory_order_seq_cst.value)>;

def : InstAlias<"fence.acquire", (FENCE memory_order_acquire.value)>;
def : InstAlias<"fence.release", (FENCE memory_order_release.value)>;
def : InstAlias<"fence.acq_rel", (FENCE memory_order_acq_rel.value)>;
def : InstAlias<"fence.seq_cst", (FENCE memory_order_seq_cst.value)>;

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

  def : Pat<(Ty (relaxed_load  <OpNode> iPTR:$rb)), (!cast<InstBase>(NAME) GR:$rb, memory_order_relaxed.value)>;
  def : Pat<(Ty (acquiring_load<OpNode> iPTR:$rb)), (!cast<InstBase>(NAME) GR:$rb, memory_order_acquire.value)>;
  def : Pat<(Ty (seq_cst_load  <OpNode> iPTR:$rb)), (!cast<InstBase>(NAME) GR:$rb, memory_order_seq_cst.value)>;

  def : InstAlias<!strconcat(OpcStr, ".relaxed\t$ra, $rb"), (!cast<InstBase>(NAME) GR:$ra, GR:$rb, memory_order_relaxed.value)>;
  def : InstAlias<!strconcat(OpcStr, ".acquire\t$ra, $rb"), (!cast<InstBase>(NAME) GR:$ra, GR:$rb, memory_order_acquire.value)>;
  def : InstAlias<!strconcat(OpcStr, ".sec_cst\t$ra, $rb"), (!cast<InstBase>(NAME) GR:$ra, GR:$rb, memory_order_seq_cst.value)>;
}

// atomic load monotonic (relaxed)
defm LDAB: ATOMIC_LOAD<misc_opx_ldab, "ldab", atomic_load_8,   i32>;
defm LDAH: ATOMIC_LOAD<misc_opx_ldah, "ldah", atomic_load_16,  i32>;
defm LDAW: ATOMIC_LOAD<misc_opx_ldaw, "ldaw", atomic_load_32,  i32>;
defm LDAD: ATOMIC_LOAD<misc_opx_ldad, "ldad", atomic_load_64,  i64>;
defm LDAQ: ATOMIC_LOAD<misc_opx_ldaq, "ldaq", atomic_load_128, i128>;

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

  def : Pat<(relaxed_store<OpNode>   iPTR:$rb, Ty:$ra), (!cast<InstBase>(NAME) GR:$ra, GR:$rb, memory_order_relaxed.value)>;
  def : Pat<(releasing_store<OpNode> iPTR:$rb, Ty:$ra), (!cast<InstBase>(NAME) GR:$ra, GR:$rb, memory_order_release.value)>;
  def : Pat<(seq_cst_store<OpNode>   iPTR:$rb, Ty:$ra), (!cast<InstBase>(NAME) GR:$ra, GR:$rb, memory_order_seq_cst.value)>;

  def : InstAlias<!strconcat(OpcStr, ".relaxed\t$ra, $rb"), (!cast<InstBase>(NAME) GR:$ra, GR:$rb, memory_order_relaxed.value)>;
  def : InstAlias<!strconcat(OpcStr, ".release\t$ra, $rb"), (!cast<InstBase>(NAME) GR:$ra, GR:$rb, memory_order_release.value)>;
  def : InstAlias<!strconcat(OpcStr, ".sec_cst\t$ra, $rb"), (!cast<InstBase>(NAME) GR:$ra, GR:$rb, memory_order_seq_cst.value)>;
}

// atomic store monotonic (relaxed)
defm STAB: ATOMIC_STORE<misc_opx_stab, "stab", atomic_store_8,   i32>;
defm STAH: ATOMIC_STORE<misc_opx_stah, "stah", atomic_store_16,  i32>;
defm STAW: ATOMIC_STORE<misc_opx_staw, "staw", atomic_store_32,  i32>;
defm STAD: ATOMIC_STORE<misc_opx_stad, "stad", atomic_store_64,  i64>;
defm STAQ: ATOMIC_STORE<misc_opx_staq, "staq", atomic_store_128, i128>;

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

  def : Pat<(!cast<PatFrag>("atomic_cmp_swap_" # PAT_T # "_monotonic") iPTR:$rb, Ty:$rc, Ty:$swap), (!cast<InstBase>(NAME) $rb, $rc, Ty:$swap, memory_order_relaxed.value)>;
  def : Pat<(!cast<PatFrag>("atomic_cmp_swap_" # PAT_T # "_acquire"  ) iPTR:$rb, Ty:$rc, Ty:$swap), (!cast<InstBase>(NAME) $rb, $rc, Ty:$swap, memory_order_acquire.value)>;
  def : Pat<(!cast<PatFrag>("atomic_cmp_swap_" # PAT_T # "_release"  ) iPTR:$rb, Ty:$rc, Ty:$swap), (!cast<InstBase>(NAME) $rb, $rc, Ty:$swap, memory_order_release.value)>;
  def : Pat<(!cast<PatFrag>("atomic_cmp_swap_" # PAT_T # "_acq_rel"  ) iPTR:$rb, Ty:$rc, Ty:$swap), (!cast<InstBase>(NAME) $rb, $rc, Ty:$swap, memory_order_acq_rel.value)>;
  def : Pat<(!cast<PatFrag>("atomic_cmp_swap_" # PAT_T # "_seq_cst"  ) iPTR:$rb, Ty:$rc, Ty:$swap), (!cast<InstBase>(NAME) $rb, $rc, Ty:$swap, memory_order_seq_cst.value)>;

  def : InstAlias<!strconcat("cas", INSN_T, ".relaxed\t$ra, $rb, $rc"), (!cast<InstBase>(NAME) GR:$ra, GR:$rb, GR:$rc, memory_order_relaxed.value)>;
  def : InstAlias<!strconcat("cas", INSN_T, ".acquire\t$ra, $rb, $rc"), (!cast<InstBase>(NAME) GR:$ra, GR:$rb, GR:$rc, memory_order_acquire.value)>;
  def : InstAlias<!strconcat("cas", INSN_T, ".release\t$ra, $rb, $rc"), (!cast<InstBase>(NAME) GR:$ra, GR:$rb, GR:$rc, memory_order_release.value)>;
  def : InstAlias<!strconcat("cas", INSN_T, ".acq_rel\t$ra, $rb, $rc"), (!cast<InstBase>(NAME) GR:$ra, GR:$rb, GR:$rc, memory_order_acq_rel.value)>;
  def : InstAlias<!strconcat("cas", INSN_T, ".seq_cst\t$ra, $rb, $rc"), (!cast<InstBase>(NAME) GR:$ra, GR:$rb, GR:$rc, memory_order_seq_cst.value)>;
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

  def : Pat<(!cast<PatFrag>("atomic_swap_" # PAT_T # "_monotonic") iPTR:$rb, Ty:$rc), (!cast<InstBase>(NAME) $rb, $rc, memory_order_relaxed.value)>;
  def : Pat<(!cast<PatFrag>("atomic_swap_" # PAT_T # "_acquire"  ) iPTR:$rb, Ty:$rc), (!cast<InstBase>(NAME) $rb, $rc, memory_order_acquire.value)>;
  def : Pat<(!cast<PatFrag>("atomic_swap_" # PAT_T # "_release"  ) iPTR:$rb, Ty:$rc), (!cast<InstBase>(NAME) $rb, $rc, memory_order_release.value)>;
  def : Pat<(!cast<PatFrag>("atomic_swap_" # PAT_T # "_acq_rel"  ) iPTR:$rb, Ty:$rc), (!cast<InstBase>(NAME) $rb, $rc, memory_order_acq_rel.value)>;
  def : Pat<(!cast<PatFrag>("atomic_swap_" # PAT_T # "_seq_cst"  ) iPTR:$rb, Ty:$rc), (!cast<InstBase>(NAME) $rb, $rc, memory_order_seq_cst.value)>;

  def : InstAlias<!strconcat(OpcStr, ".relaxed\t$ra, $rb, $rc"), (!cast<InstBase>(NAME) GR:$ra, GR:$rb, GR:$rc, memory_order_relaxed.value)>;
  def : InstAlias<!strconcat(OpcStr, ".acquire\t$ra, $rb, $rc"), (!cast<InstBase>(NAME) GR:$ra, GR:$rb, GR:$rc, memory_order_acquire.value)>;
  def : InstAlias<!strconcat(OpcStr, ".release\t$ra, $rb, $rc"), (!cast<InstBase>(NAME) GR:$ra, GR:$rb, GR:$rc, memory_order_release.value)>;
  def : InstAlias<!strconcat(OpcStr, ".acq_rel\t$ra, $rb, $rc"), (!cast<InstBase>(NAME) GR:$ra, GR:$rb, GR:$rc, memory_order_acq_rel.value)>;
  def : InstAlias<!strconcat(OpcStr, ".seq_cst\t$ra, $rb, $rc"), (!cast<InstBase>(NAME) GR:$ra, GR:$rb, GR:$rc, memory_order_seq_cst.value)>;
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
AMO_LOAD_OP<string INSN, string PAT_OP, string PAT_T, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : MISC_RabcMo<!cast<misc_opx>("misc_opx_" # INSN),
                 (outs GR:$ra), (ins GR:$rb, GR:$rc, MemoryOrder:$memory_order),
                 !strconcat(INSN, "\t$ra, $rb, $rc, $memory_order"), [], itin>;

  def : Pat<(!cast<PatFrag>("atomic_load_" # PAT_OP # "_" # PAT_T # "_monotonic") iPTR:$rb, Ty:$rc), (!cast<InstBase>(NAME) $rb, $rc, memory_order_relaxed.value)>;
  def : Pat<(!cast<PatFrag>("atomic_load_" # PAT_OP # "_" # PAT_T # "_acquire"  ) iPTR:$rb, Ty:$rc), (!cast<InstBase>(NAME) $rb, $rc, memory_order_acquire.value)>;
  def : Pat<(!cast<PatFrag>("atomic_load_" # PAT_OP # "_" # PAT_T # "_release"  ) iPTR:$rb, Ty:$rc), (!cast<InstBase>(NAME) $rb, $rc, memory_order_release.value)>;
  def : Pat<(!cast<PatFrag>("atomic_load_" # PAT_OP # "_" # PAT_T # "_acq_rel"  ) iPTR:$rb, Ty:$rc), (!cast<InstBase>(NAME) $rb, $rc, memory_order_acq_rel.value)>;
  def : Pat<(!cast<PatFrag>("atomic_load_" # PAT_OP # "_" # PAT_T # "_seq_cst"  ) iPTR:$rb, Ty:$rc), (!cast<InstBase>(NAME) $rb, $rc, memory_order_seq_cst.value)>;

  def : InstAlias<!strconcat(INSN, ".relaxed\t$ra, $rb, $rc"), (!cast<InstBase>(NAME) GR:$ra, GR:$rb, GR:$rc, memory_order_relaxed.value)>;
  def : InstAlias<!strconcat(INSN, ".acquire\t$ra, $rb, $rc"), (!cast<InstBase>(NAME) GR:$ra, GR:$rb, GR:$rc, memory_order_acquire.value)>;
  def : InstAlias<!strconcat(INSN, ".release\t$ra, $rb, $rc"), (!cast<InstBase>(NAME) GR:$ra, GR:$rb, GR:$rc, memory_order_release.value)>;
  def : InstAlias<!strconcat(INSN, ".acq_rel\t$ra, $rb, $rc"), (!cast<InstBase>(NAME) GR:$ra, GR:$rb, GR:$rc, memory_order_acq_rel.value)>;
  def : InstAlias<!strconcat(INSN, ".seq_cst\t$ra, $rb, $rc"), (!cast<InstBase>(NAME) GR:$ra, GR:$rb, GR:$rc, memory_order_seq_cst.value)>;
}

multiclass AMO_LOAD_OPS<string INSN, string PAT_OP> {
  defm NAME # B : AMO_LOAD_OP<INSN # b, PAT_OP, "i8",  i32>;
  defm NAME # H : AMO_LOAD_OP<INSN # h, PAT_OP, "i16", i32>;
  defm NAME # W : AMO_LOAD_OP<INSN # w, PAT_OP, "i32", i32>;
  defm NAME # D : AMO_LOAD_OP<INSN # d, PAT_OP, "i64", i64>;
}

defm LDADD  : AMO_LOAD_OPS<"ldadd",  "add">;
defm LDAND  : AMO_LOAD_OPS<"ldand",  "and">;
defm LDOR   : AMO_LOAD_OPS<"ldor",   "or">;
defm LDXOR  : AMO_LOAD_OPS<"ldxor",  "xor">;
defm LDSMIN : AMO_LOAD_OPS<"ldsmin", "min">;
defm LDSMAX : AMO_LOAD_OPS<"ldsmax", "max">;
defm LDUMIN : AMO_LOAD_OPS<"ldumin", "umin">;
defm LDUMAX : AMO_LOAD_OPS<"ldumax", "umax">;

//===----------------------------------------------------------------------===//
// STORE-OP instructions
//===----------------------------------------------------------------------===//
multiclass
AMO_STORE_OP<string INSN, string PAT_OP, string PAT_T, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  let ra = 0 in
  def NAME : MISC_RabcMo<!cast<misc_opx>("misc_opx_" # INSN),
                 (outs), (ins GR:$rb, GR:$rc, MemoryOrder:$memory_order),
                 !strconcat(INSN, "\t$rb, $rc, $memory_order"), [], itin>;

  // TODO: wait for corresponding tablegen patterns to match 'atomic_store_op'

  def : Pat<(!cast<PatFrag>("atomic_load_" # PAT_OP # "_" # PAT_T # "_monotonic") iPTR:$rb, Ty:$rc), (!cast<InstBase>(NAME) $rb, $rc, memory_order_relaxed.value)>;
  def : Pat<(!cast<PatFrag>("atomic_load_" # PAT_OP # "_" # PAT_T # "_acquire"  ) iPTR:$rb, Ty:$rc), (!cast<InstBase>(NAME) $rb, $rc, memory_order_acquire.value)>;
  def : Pat<(!cast<PatFrag>("atomic_load_" # PAT_OP # "_" # PAT_T # "_release"  ) iPTR:$rb, Ty:$rc), (!cast<InstBase>(NAME) $rb, $rc, memory_order_release.value)>;
  def : Pat<(!cast<PatFrag>("atomic_load_" # PAT_OP # "_" # PAT_T # "_acq_rel"  ) iPTR:$rb, Ty:$rc), (!cast<InstBase>(NAME) $rb, $rc, memory_order_acq_rel.value)>;
  def : Pat<(!cast<PatFrag>("atomic_load_" # PAT_OP # "_" # PAT_T # "_seq_cst"  ) iPTR:$rb, Ty:$rc), (!cast<InstBase>(NAME) $rb, $rc, memory_order_seq_cst.value)>;

  def : InstAlias<!strconcat(INSN, ".relaxed\t$rb, $rc"), (!cast<InstBase>(NAME) GR:$rb, GR:$rc, memory_order_relaxed.value)>;
  def : InstAlias<!strconcat(INSN, ".acquire\t$rb, $rc"), (!cast<InstBase>(NAME) GR:$rb, GR:$rc, memory_order_acquire.value)>;
  def : InstAlias<!strconcat(INSN, ".release\t$rb, $rc"), (!cast<InstBase>(NAME) GR:$rb, GR:$rc, memory_order_release.value)>;
  def : InstAlias<!strconcat(INSN, ".acq_rel\t$rb, $rc"), (!cast<InstBase>(NAME) GR:$rb, GR:$rc, memory_order_acq_rel.value)>;
  def : InstAlias<!strconcat(INSN, ".seq_cst\t$rb, $rc"), (!cast<InstBase>(NAME) GR:$rb, GR:$rc, memory_order_seq_cst.value)>;
}

multiclass AMO_STORE_OPS<string INSN, string PAT_OP> {
  defm NAME # B : AMO_STORE_OP<INSN # b, PAT_OP, "i8",  i32>;
  defm NAME # H : AMO_STORE_OP<INSN # h, PAT_OP, "i16", i32>;
  defm NAME # W : AMO_STORE_OP<INSN # w, PAT_OP, "i32", i32>;
  defm NAME # D : AMO_STORE_OP<INSN # d, PAT_OP, "i64", i64>;
}

defm STADD  : AMO_STORE_OPS<"stadd",  "add">;
defm STAND  : AMO_STORE_OPS<"stand",  "and">;
defm STOR   : AMO_STORE_OPS<"stor",   "or">;
defm STXOR  : AMO_STORE_OPS<"stxor",  "xor">;
defm STSMIN : AMO_STORE_OPS<"stsmin", "min">;
defm STSMAX : AMO_STORE_OPS<"stsmax", "max">;
defm STUMIN : AMO_STORE_OPS<"stumin", "umin">;
defm STUMAX : AMO_STORE_OPS<"stumax", "umax">;

//===----------------------------------------------------------------------===//
// LOAD-SUB(V) => LOAD-ADD (0-V)
//===----------------------------------------------------------------------===//
multiclass
AMO_LOAD_SUB<MISC_RabcMo Inst, string OpcStr, InstBase SUBFI, ValueType Ty>
{
  def : Pat<(Ty (!cast<PatFrag>(OpcStr # "_monotonic") iPTR:$ptr, Ty:$val)), (Inst GR:$ptr, (SUBFI GR:$val, 0), memory_order_relaxed.value)>;
  def : Pat<(Ty (!cast<PatFrag>(OpcStr # "_acquire"  ) iPTR:$ptr, Ty:$val)), (Inst GR:$ptr, (SUBFI GR:$val, 0), memory_order_acquire.value)>;
  def : Pat<(Ty (!cast<PatFrag>(OpcStr # "_release"  ) iPTR:$ptr, Ty:$val)), (Inst GR:$ptr, (SUBFI GR:$val, 0), memory_order_release.value)>;
  def : Pat<(Ty (!cast<PatFrag>(OpcStr # "_acq_rel"  ) iPTR:$ptr, Ty:$val)), (Inst GR:$ptr, (SUBFI GR:$val, 0), memory_order_acq_rel.value)>;
  def : Pat<(Ty (!cast<PatFrag>(OpcStr # "_seq_cst"  ) iPTR:$ptr, Ty:$val)), (Inst GR:$ptr, (SUBFI GR:$val, 0), memory_order_seq_cst.value)>;
}

defm : AMO_LOAD_SUB<LDADDB, "atomic_load_sub_i8",  SUBFIWS, i32>;
defm : AMO_LOAD_SUB<LDADDH, "atomic_load_sub_i16", SUBFIWS, i32>;
defm : AMO_LOAD_SUB<LDADDW, "atomic_load_sub_i32", SUBFIWS, i32>;
defm : AMO_LOAD_SUB<LDADDD, "atomic_load_sub_i64", SUBFI,   i64>;
