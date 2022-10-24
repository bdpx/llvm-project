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
    def FENCEA  : MISC_NoArgs<misc_opx_fencea,  (outs), (ins), "fencea", []>;
    def FENCER  : MISC_NoArgs<misc_opx_fencer,  (outs), (ins), "fencer", []>;
    def FENCEAR : MISC_NoArgs<misc_opx_fencear, (outs), (ins), "fencear", []>;
    def FENCESC : MISC_NoArgs<misc_opx_fencesc, (outs), (ins), "fencesc", []>;
}

def : Pat<(atomic_fence (i64 4), timm), (FENCEA)>;
def : Pat<(atomic_fence (i64 5), timm), (FENCER)>;
def : Pat<(atomic_fence (i64 6), timm), (FENCEAR)>;
def : Pat<(atomic_fence (i64 7), timm), (FENCESC)>;

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
ATOMIC_LOAD<string INSN, PatFrag OpNode, ValueType Ty>
{
  def NAME    : MISC_Rab<!cast<misc_opx>("misc_opx_" # INSN      ), (outs GR:$ra), (ins GR:$rb), !strconcat(INSN, "\t$ra, $rb"), [], IIC_iu_instr>;
  def NAME # A: MISC_Rab<!cast<misc_opx>("misc_opx_" # INSN # "a"), (outs GR:$ra), (ins GR:$rb), !strconcat(INSN, "a\t$ra, $rb"), [], IIC_iu_instr>;

  def : Pat<(Ty (relaxed_load  <OpNode> iPTR:$rb)), (!cast<InstBase>(NAME) GR:$rb)>;
  def : Pat<(Ty (acquiring_load<OpNode> iPTR:$rb)), (!cast<InstBase>(NAME # A) GR:$rb)>;
}

// atomic load monotonic (relaxed)
defm LDAB: ATOMIC_LOAD<"ldab", atomic_load_8,   i32>;
defm LDAH: ATOMIC_LOAD<"ldah", atomic_load_16,  i32>;
defm LDAW: ATOMIC_LOAD<"ldaw", atomic_load_32,  i32>;
defm LDAD: ATOMIC_LOAD<"ldad", atomic_load_64,  i64>;
defm LDAQ: ATOMIC_LOAD<"ldaq", atomic_load_128, i128>;

//===----------------------------------------------------------------------===//
// atomic store instructions
//===----------------------------------------------------------------------===//
multiclass
ATOMIC_STORE<string INSN, PatFrag OpNode, ValueType Ty>
{
  def NAME    : MISC_Rab<!cast<misc_opx>("misc_opx_" # INSN      ), (outs), (ins GR:$ra, GR:$rb), !strconcat(INSN, "\t$ra, $rb"), [], IIC_iu_instr>;
  def NAME # R: MISC_Rab<!cast<misc_opx>("misc_opx_" # INSN # "r"), (outs), (ins GR:$ra, GR:$rb), !strconcat(INSN, "r\t$ra, $rb"), [], IIC_iu_instr>;

  def : Pat<(relaxed_store<OpNode>   iPTR:$rb, Ty:$ra), (!cast<InstBase>(NAME) GR:$ra, GR:$rb)>;
  def : Pat<(releasing_store<OpNode> iPTR:$rb, Ty:$ra), (!cast<InstBase>(NAME#R) GR:$ra, GR:$rb)>;
}

// atomic store monotonic (relaxed)
defm STAB: ATOMIC_STORE<"stab", atomic_store_8,   i32>;
defm STAH: ATOMIC_STORE<"stah", atomic_store_16,  i32>;
defm STAW: ATOMIC_STORE<"staw", atomic_store_32,  i32>;
defm STAD: ATOMIC_STORE<"stad", atomic_store_64,  i64>;
defm STAQ: ATOMIC_STORE<"staq", atomic_store_128, i128>;

//===----------------------------------------------------------------------===//
// CAS instructions
//===----------------------------------------------------------------------===//
multiclass
AMO_CAS_OP<string INSN_T, string PAT_T, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  let Constraints = "$swap = $ra" in
  def NAME     : MISC_Rabc<!cast<misc_opx>("misc_opx_cas" # INSN_T       ), (outs GR:$ra), (ins GR:$rb, GR:$rc, GR:$swap), !strconcat("cas", INSN_T, "\t$ra, $rb, $rc"), [], itin>;
  def NAME # A : MISC_Rabc<!cast<misc_opx>("misc_opx_cas" # INSN_T #  "a"), (outs GR:$ra), (ins GR:$rb, GR:$rc, GR:$swap), !strconcat("cas", INSN_T, "a\t$ra, $rb, $rc"), [], itin>;
  def NAME # R : MISC_Rabc<!cast<misc_opx>("misc_opx_cas" # INSN_T #  "r"), (outs GR:$ra), (ins GR:$rb, GR:$rc, GR:$swap), !strconcat("cas", INSN_T, "r\t$ra, $rb, $rc"), [], itin>;
  def NAME # AR: MISC_Rabc<!cast<misc_opx>("misc_opx_cas" # INSN_T # "ar"), (outs GR:$ra), (ins GR:$rb, GR:$rc, GR:$swap), !strconcat("cas", INSN_T, "ar\t$ra, $rb, $rc"), [], itin>;

  def : Pat<(!cast<PatFrag>("atomic_cmp_swap_" # PAT_T # "_monotonic") iPTR:$rb, Ty:$rc, Ty:$swap), (!cast<InstBase>(NAME    ) $rb, $rc, Ty:$swap)>;
  def : Pat<(!cast<PatFrag>("atomic_cmp_swap_" # PAT_T # "_acquire"  ) iPTR:$rb, Ty:$rc, Ty:$swap), (!cast<InstBase>(NAME # A) $rb, $rc, Ty:$swap)>;
  def : Pat<(!cast<PatFrag>("atomic_cmp_swap_" # PAT_T # "_release"  ) iPTR:$rb, Ty:$rc, Ty:$swap), (!cast<InstBase>(NAME # R) $rb, $rc, Ty:$swap)>;
  def : Pat<(!cast<PatFrag>("atomic_cmp_swap_" # PAT_T # "_acq_rel"  ) iPTR:$rb, Ty:$rc, Ty:$swap), (!cast<InstBase>(NAME #AR) $rb, $rc, Ty:$swap)>;
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
  def NAME : MISC_Rabc<opx,
                 (outs GR:$ra), (ins GR:$rb, GR:$rc),
                 !strconcat(OpcStr, "\t$ra, $rb, $rc"),
                 [(set Ty:$ra, (OpNode iPTR:$rb, Ty:$rc))], itin>;
}

//===----------------------------------------------------------------------===//
// swap instructions
//===----------------------------------------------------------------------===//
multiclass
AMO_SWAP_OP<string INSN, string PAT_T, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  def NAME     : MISC_Rabc<!cast<misc_opx>("misc_opx_" # INSN       ), (outs GR:$ra), (ins GR:$rb, GR:$rc), !strconcat(INSN, "\t$ra, $rb, $rc"), [], itin>;
  def NAME # A : MISC_Rabc<!cast<misc_opx>("misc_opx_" # INSN #  "a"), (outs GR:$ra), (ins GR:$rb, GR:$rc), !strconcat(INSN, "a\t$ra, $rb, $rc"), [], itin>;
  def NAME # R : MISC_Rabc<!cast<misc_opx>("misc_opx_" # INSN #  "r"), (outs GR:$ra), (ins GR:$rb, GR:$rc), !strconcat(INSN, "r\t$ra, $rb, $rc"), [], itin>;
  def NAME # AR: MISC_Rabc<!cast<misc_opx>("misc_opx_" # INSN # "ar"), (outs GR:$ra), (ins GR:$rb, GR:$rc), !strconcat(INSN, "ar\t$ra, $rb, $rc"), [], itin>;

  def : Pat<(!cast<PatFrag>("atomic_swap_" # PAT_T # "_monotonic") iPTR:$rb, Ty:$rc), (!cast<InstBase>(NAME   ) $rb, $rc)>;
  def : Pat<(!cast<PatFrag>("atomic_swap_" # PAT_T # "_acquire"  ) iPTR:$rb, Ty:$rc), (!cast<InstBase>(NAME# A) $rb, $rc)>;
  def : Pat<(!cast<PatFrag>("atomic_swap_" # PAT_T # "_release"  ) iPTR:$rb, Ty:$rc), (!cast<InstBase>(NAME# R) $rb, $rc)>;
  def : Pat<(!cast<PatFrag>("atomic_swap_" # PAT_T # "_acq_rel"  ) iPTR:$rb, Ty:$rc), (!cast<InstBase>(NAME#AR) $rb, $rc)>;
}

defm SWAPB : AMO_SWAP_OP<"swapb", "i8",   i32>;
defm SWAPH : AMO_SWAP_OP<"swaph", "i16",  i32>;
defm SWAPW : AMO_SWAP_OP<"swapw", "i32",  i32>;
defm SWAPD : AMO_SWAP_OP<"swapd", "i64",  i64>;
defm SWAPQ : AMO_SWAP_OP<"swapq", "i128", i128>;

//===----------------------------------------------------------------------===//
// LOAD-OP instructions
//===----------------------------------------------------------------------===//
multiclass
AMO_LOAD_OP<string INSN, string PAT_OP, string PAT_T, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  def NAME     : MISC_Rabc<!cast<misc_opx>("misc_opx_" # INSN       ), (outs GR:$ra), (ins GR:$rb, GR:$rc), !strconcat(INSN, "\t$ra, $rb, $rc"), [], itin>;
  def NAME # A : MISC_Rabc<!cast<misc_opx>("misc_opx_" # INSN #  "a"), (outs GR:$ra), (ins GR:$rb, GR:$rc), !strconcat(INSN, "a\t$ra, $rb, $rc"), [], itin>;
  def NAME # R : MISC_Rabc<!cast<misc_opx>("misc_opx_" # INSN #  "r"), (outs GR:$ra), (ins GR:$rb, GR:$rc), !strconcat(INSN, "r\t$ra, $rb, $rc"), [], itin>;
  def NAME # AR: MISC_Rabc<!cast<misc_opx>("misc_opx_" # INSN # "ar"), (outs GR:$ra), (ins GR:$rb, GR:$rc), !strconcat(INSN, "ar\t$ra, $rb, $rc"), [], itin>;

  def : Pat<(!cast<PatFrag>("atomic_load_" # PAT_OP # "_" # PAT_T # "_monotonic") iPTR:$rb, Ty:$rc), (!cast<InstBase>(NAME    ) $rb, $rc)>;
  def : Pat<(!cast<PatFrag>("atomic_load_" # PAT_OP # "_" # PAT_T # "_acquire"  ) iPTR:$rb, Ty:$rc), (!cast<InstBase>(NAME # A) $rb, $rc)>;
  def : Pat<(!cast<PatFrag>("atomic_load_" # PAT_OP # "_" # PAT_T # "_release"  ) iPTR:$rb, Ty:$rc), (!cast<InstBase>(NAME # R) $rb, $rc)>;
  def : Pat<(!cast<PatFrag>("atomic_load_" # PAT_OP # "_" # PAT_T # "_acq_rel"  ) iPTR:$rb, Ty:$rc), (!cast<InstBase>(NAME #AR) $rb, $rc)>;
}

multiclass AMO_LOAD_OPS<string INSN, string PAT_OP> {
  defm NAME # B : AMO_LOAD_OP<INSN # b, PAT_OP, "i8",  i32>;
  defm NAME # H : AMO_LOAD_OP<INSN # h, PAT_OP, "i16", i32>;
  defm NAME # W : AMO_LOAD_OP<INSN # w, PAT_OP, "i32", i32>;
  defm NAME # D : AMO_LOAD_OP<INSN # d, PAT_OP, "i64", i64>;
  defm NAME # Q : AMO_LOAD_OP<INSN # q, PAT_OP, "i128", i128>;
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
  let ra = 0 in {
    def NAME    : MISC_Rabc<!cast<misc_opx>("misc_opx_" # INSN      ), (outs), (ins GR:$rb, GR:$rc), !strconcat(INSN, "\t$rb, $rc"), [], itin>;
    def NAME # R: MISC_Rabc<!cast<misc_opx>("misc_opx_" # INSN # "r"), (outs), (ins GR:$rb, GR:$rc), !strconcat(INSN, "r\t$rb, $rc"), [], itin>;
  }

  // TODO: wait for corresponding tablegen patterns to match 'atomic_store_op'

  def : Pat<(!cast<PatFrag>("atomic_load_" # PAT_OP # "_" # PAT_T # "_monotonic") iPTR:$rb, Ty:$rc), (!cast<InstBase>(NAME    ) $rb, $rc)>;
  def : Pat<(!cast<PatFrag>("atomic_load_" # PAT_OP # "_" # PAT_T # "_release"  ) iPTR:$rb, Ty:$rc), (!cast<InstBase>(NAME # R) $rb, $rc)>;
}

multiclass AMO_STORE_OPS<string INSN, string PAT_OP> {
  defm NAME # B : AMO_STORE_OP<INSN # b, PAT_OP, "i8",  i32>;
  defm NAME # H : AMO_STORE_OP<INSN # h, PAT_OP, "i16", i32>;
  defm NAME # W : AMO_STORE_OP<INSN # w, PAT_OP, "i32", i32>;
  defm NAME # D : AMO_STORE_OP<INSN # d, PAT_OP, "i64", i64>;
  defm NAME # Q : AMO_STORE_OP<INSN # q, PAT_OP, "i128", i128>;
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
AMO_LOAD_SUB<MISC_Rabc Inst, MISC_Rabc InstA, MISC_Rabc InstR, MISC_Rabc InstAR, string OpcStr, InstBase SUB, ValueType Ty>
{
  def : Pat<(Ty (!cast<PatFrag>(OpcStr # "_monotonic") iPTR:$ptr, Ty:$val)), (Inst   GR:$ptr, (SUB (Ty gz), GR:$val))>;
  def : Pat<(Ty (!cast<PatFrag>(OpcStr # "_acquire"  ) iPTR:$ptr, Ty:$val)), (InstA  GR:$ptr, (SUB (Ty gz), GR:$val))>;
  def : Pat<(Ty (!cast<PatFrag>(OpcStr # "_release"  ) iPTR:$ptr, Ty:$val)), (InstR  GR:$ptr, (SUB (Ty gz), GR:$val))>;
  def : Pat<(Ty (!cast<PatFrag>(OpcStr # "_acq_rel"  ) iPTR:$ptr, Ty:$val)), (InstAR GR:$ptr, (SUB (Ty gz), GR:$val))>;
}

defm : AMO_LOAD_SUB<LDADDB, LDADDBA, LDADDBR, LDADDBAR, "atomic_load_sub_i8",   SUBWS, i32>;
defm : AMO_LOAD_SUB<LDADDH, LDADDHA, LDADDHR, LDADDHAR, "atomic_load_sub_i16",  SUBWS, i32>;
defm : AMO_LOAD_SUB<LDADDW, LDADDWA, LDADDWR, LDADDWAR, "atomic_load_sub_i32",  SUBWS, i32>;
defm : AMO_LOAD_SUB<LDADDD, LDADDDA, LDADDDR, LDADDDAR, "atomic_load_sub_i64",  SUB,   i64>;
defm : AMO_LOAD_SUB<LDADDQ, LDADDQA, LDADDQR, LDADDQAR, "atomic_load_sub_i128", SUBQ, i128>;
