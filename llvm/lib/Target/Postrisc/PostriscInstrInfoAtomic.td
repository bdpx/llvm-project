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


// Memory orderings

def MemoryOrderingArg : AsmOperandClass {
  let Name = "MemoryOrderingArg";
  let RenderMethod = "addMemoryOrderingArgOperands";
  let ParserMethod = "parseMemoryOrderingArg";
  let IsOptional = 1;
  let DefaultMethod = "defaultMemoryOrderingArgOp";
}

// Operand should be named $frm for getNamedOperandIdx
def mo_arg : Operand<i32> {
  let ParserMatchClass =  MemoryOrderingArg;
  let PrintMethod = "printMemoryOrderingArg";
  let DecoderMethod = "decodeMemoryOrderingArg";
  let OperandType = "OPERAND_MEMORY_ORDERING";
  let OperandNamespace = "PostriscOp";
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

class MISC_Fence<misc_opx opxCode, InstrItinClass itin = IIC_iu_instr>
   : MISC<opxCode, (outs), (ins mo_arg:$memory_ordering),
     !strconcat(opxCode.mnem, " $memory_ordering"), [], itin>
{
  bits<3> memory_ordering;
  let Inst{34-14} = 0;
  let Inst{2-0} = memory_ordering;
}

let hasSideEffects = 1 in {
  def FENCE : MISC_Fence<opcode_fence>;
}

def : Pat<(atomic_fence (i64 4), timm), (FENCE memory_ordering_acquire.value)>;
def : Pat<(atomic_fence (i64 5), timm), (FENCE memory_ordering_release.value)>;
def : Pat<(atomic_fence (i64 6), timm), (FENCE memory_ordering_acq_rel.value)>;
def : Pat<(atomic_fence (i64 7), timm), (FENCE memory_ordering_seq_cst.value)>;

//===----------------------------------------------------------------------===//
// tablegen fixes
// atomic_load_128
// binary_atomic_op has no i128 variant, add it here
// ternary_atomic_op has no i128 variant, add it here
//===----------------------------------------------------------------------===//

let IsAtomic = 1 in {
def atomic_load_128 : PatFrag<(ops node:$ptr), (atomic_load node:$ptr)> {
  let MemoryVT = i128;
}

class relaxed_load<PatFrags base> : PatFrag<(ops node:$ptr), (base node:$ptr)> {
  let IsAtomicOrderingAcquireOrStronger = 0;
}

class acquiring_load<PatFrags base> : PatFrag<(ops node:$ptr), (base node:$ptr)> {
  let IsAtomicOrderingAcquire = 1;
}

class seq_cst_load<PatFrags base> : PatFrag<(ops node:$ptr), (base node:$ptr)> {
  let IsAtomicOrderingSequentiallyConsistent = 1;
}

class relaxed_store<PatFrag base> : PatFrag<(ops node:$ptr, node:$val), (base node:$val, node:$ptr)> {
  let IsAtomicOrderingReleaseOrStronger = 0;
}

class releasing_store<PatFrag base> : PatFrag<(ops node:$ptr, node:$val), (base node:$val, node:$ptr)> {
  let IsAtomicOrderingRelease/*OrStronger*/ = 1;
}

class seq_cst_store<PatFrag base> : PatFrag<(ops node:$ptr, node:$val), (base node:$val, node:$ptr)> {
  let IsAtomicOrderingSequentiallyConsistent = 1;
}

def atomic_cmp_swap_i128 : PatFrag<(ops node:$ptr, node:$cmp, node:$val), (atomic_cmp_swap node:$ptr, node:$cmp, node:$val)> {
  let MemoryVT = i128;
}
} // IsAtomic = 1

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
class MISC_AtomicLoad<misc_opx opxCode, InstrItinClass itin = IIC_iu_instr>
   : MISC<opxCode, (outs GR:$ra), (ins GR:$rb, mo_arg:$memory_ordering),
          !strconcat(opxCode.mnem, " $ra, $rb, $memory_ordering"), [], itin>
{
  bits<7> ra;
  bits<7> rb;
  bits<3> memory_ordering;

  let Inst{34-28} = ra;
  let Inst{27-21} = rb;
  let Inst{20-14} = 0; // rc
  let Inst{2-0}  = memory_ordering;
}

multiclass ATOMIC_LOAD<misc_opx opx, PatFrag Op, ValueType Ty>
{
  def NAME : MISC_AtomicLoad<opx>;

  def : Pat<(Ty (relaxed_load<Op>   iPTR:$rb)), (!cast<InstBase>(NAME) GR:$rb, memory_ordering_relaxed.value)>;
  def : Pat<(Ty (acquiring_load<Op> iPTR:$rb)), (!cast<InstBase>(NAME) GR:$rb, memory_ordering_acquire.value)>;
  def : Pat<(Ty (seq_cst_load<Op>   iPTR:$rb)), (!cast<InstBase>(NAME) GR:$rb, memory_ordering_seq_cst.value)>;
}

defm AMOLDB: ATOMIC_LOAD<opcode_amoldb, atomic_load_8,   i32>;
defm AMOLDH: ATOMIC_LOAD<opcode_amoldh, atomic_load_16,  i32>;
defm AMOLDW: ATOMIC_LOAD<opcode_amoldw, atomic_load_32,  i32>;
defm AMOLDD: ATOMIC_LOAD<opcode_amoldd, atomic_load_64,  i64>;
defm AMOLDQ: ATOMIC_LOAD<opcode_amoldq, atomic_load_128, i128>;

//===----------------------------------------------------------------------===//
// atomic store instructions
//===----------------------------------------------------------------------===//
class MISC_AtomicStore<misc_opx opxCode, InstrItinClass itin = IIC_iu_instr>
   : MISC<opxCode, (outs), (ins GR:$ra, GR:$rb, mo_arg:$memory_ordering),
          !strconcat(opxCode.mnem, " $ra, $rb, $memory_ordering"), [], itin>
{
  bits<7> ra;
  bits<7> rb;
  bits<3> memory_ordering;

  let Inst{34-28} = ra;
  let Inst{27-21} = rb;
  let Inst{20-14} = 0; // rc
  let Inst{2-0}  = memory_ordering;
}

multiclass ATOMIC_STORE<misc_opx opx, PatFrag Op, ValueType Ty>
{
  def NAME : MISC_AtomicStore<opx>;

  def : Pat<(relaxed_store<Op>   iPTR:$rb, Ty:$ra), (!cast<InstBase>(NAME) GR:$ra, GR:$rb, memory_ordering_relaxed.value)>;
  def : Pat<(releasing_store<Op> iPTR:$rb, Ty:$ra), (!cast<InstBase>(NAME) GR:$ra, GR:$rb, memory_ordering_release.value)>;
  def : Pat<(seq_cst_store<Op>   iPTR:$rb, Ty:$ra), (!cast<InstBase>(NAME) GR:$ra, GR:$rb, memory_ordering_seq_cst.value)>;
}

defm AMOSTB: ATOMIC_STORE<opcode_amostb, atomic_store_8,   i32>;
defm AMOSTH: ATOMIC_STORE<opcode_amosth, atomic_store_16,  i32>;
defm AMOSTW: ATOMIC_STORE<opcode_amostw, atomic_store_32,  i32>;
defm AMOSTD: ATOMIC_STORE<opcode_amostd, atomic_store_64,  i64>;
defm AMOSTQ: ATOMIC_STORE<opcode_amostq, atomic_store_128, i128>;

//===----------------------------------------------------------------------===//
// CAS instructions (in the FMAQ main opcode)
//===----------------------------------------------------------------------===//
class FMAQ_CAS<fmaq_opx opxCode, InstrItinClass itin = IIC_iu_instr>
   : InstBase<opcode_fmaq, (outs GR:$ra), (ins GR:$rb, GR:$rc, GR:$rd, mo_arg:$memory_ordering),
          !strconcat(opxCode.mnem, " $ra, $rb, $rc, $rd, $memory_ordering"), [], itin>
{
  bits<4> opx;
  let opx = opxCode.value;

  bits<7> ra;
  bits<7> rb;
  bits<7> rc;
  bits<7> rd;
  bits<3> memory_ordering;

  let Inst{34-28} = ra;
  let Inst{27-21} = rb;
  let Inst{20-14} = rc;
  let Inst{13-7}  = rd;
  let Inst{6-3}   = opx;
  let Inst{2-0}   = memory_ordering;
}

multiclass ATOMIC_CAS<fmaq_opx Opx,  string PatFragName, ValueType Ty>
{
  def NAME : FMAQ_CAS<Opx>;

  def : Pat<(Ty (!cast<PatFrag>(PatFragName # "_monotonic") iPTR:$rb, Ty:$rc, Ty:$rd)), (!cast<InstBase>(NAME) GR:$rb, GR:$rc, GR:$rd, memory_ordering_relaxed.value)>;
  def : Pat<(Ty (!cast<PatFrag>(PatFragName # "_acquire"  ) iPTR:$rb, Ty:$rc, Ty:$rd)), (!cast<InstBase>(NAME) GR:$rb, GR:$rc, GR:$rd, memory_ordering_acquire.value)>;
  def : Pat<(Ty (!cast<PatFrag>(PatFragName # "_release"  ) iPTR:$rb, Ty:$rc, Ty:$rd)), (!cast<InstBase>(NAME) GR:$rb, GR:$rc, GR:$rd, memory_ordering_release.value)>;
  def : Pat<(Ty (!cast<PatFrag>(PatFragName # "_acq_rel"  ) iPTR:$rb, Ty:$rc, Ty:$rd)), (!cast<InstBase>(NAME) GR:$rb, GR:$rc, GR:$rd, memory_ordering_acq_rel.value)>;
  def : Pat<(Ty (!cast<PatFrag>(PatFragName # "_seq_cst"  ) iPTR:$rb, Ty:$rc, Ty:$rd)), (!cast<InstBase>(NAME) GR:$rb, GR:$rc, GR:$rd, memory_ordering_seq_cst.value)>;
}

defm AMOCASB : ATOMIC_CAS<opcode_amocasb, "atomic_cmp_swap_i8",   i32>;
defm AMOCASH : ATOMIC_CAS<opcode_amocash, "atomic_cmp_swap_i16",  i32>;
defm AMOCASW : ATOMIC_CAS<opcode_amocasw, "atomic_cmp_swap_i32",  i32>;
defm AMOCASD : ATOMIC_CAS<opcode_amocasd, "atomic_cmp_swap_i64",  i64>;
defm AMOCASQ : ATOMIC_CAS<opcode_amocasq, "atomic_cmp_swap_i128", i128>;

//===----------------------------------------------------------------------===//
// swap instructions
//===----------------------------------------------------------------------===//
class MISC_AtomicSwap<misc_opx opxCode, InstrItinClass itin = IIC_iu_instr>
   : MISC<opxCode, (outs GR:$ra), (ins GR:$rb, GR:$rc, mo_arg:$memory_ordering),
          !strconcat(opxCode.mnem, " $ra, $rb, $rc, $memory_ordering"), [], itin>
{
  bits<7> ra;
  bits<7> rb;
  bits<7> rc;
  bits<3> memory_ordering;

  let Inst{34-28} = ra;
  let Inst{27-21} = rb;
  let Inst{20-14} = rc;
  let Inst{2-0}  = memory_ordering;
}

multiclass ATOMIC_SWAP<misc_opx Opc, string PatFragName, ValueType Ty>
{
  def NAME : MISC_AtomicSwap<Opc>;

  def : Pat<(Ty (!cast<PatFrag>(PatFragName # "_monotonic") iPTR:$rb, Ty:$rc)), (!cast<InstBase>(NAME) GR:$rb, GR:$rc, memory_ordering_relaxed.value)>;
  def : Pat<(Ty (!cast<PatFrag>(PatFragName # "_acquire"  ) iPTR:$rb, Ty:$rc)), (!cast<InstBase>(NAME) GR:$rb, GR:$rc, memory_ordering_acquire.value)>;
  def : Pat<(Ty (!cast<PatFrag>(PatFragName # "_release"  ) iPTR:$rb, Ty:$rc)), (!cast<InstBase>(NAME) GR:$rb, GR:$rc, memory_ordering_release.value)>;
  def : Pat<(Ty (!cast<PatFrag>(PatFragName # "_acq_rel"  ) iPTR:$rb, Ty:$rc)), (!cast<InstBase>(NAME) GR:$rb, GR:$rc, memory_ordering_acq_rel.value)>;
  def : Pat<(Ty (!cast<PatFrag>(PatFragName # "_seq_cst"  ) iPTR:$rb, Ty:$rc)), (!cast<InstBase>(NAME) GR:$rb, GR:$rc, memory_ordering_seq_cst.value)>;
}

defm AMOSWAPB : ATOMIC_SWAP<opcode_amoswapb, "atomic_swap_i8",   i32>;
defm AMOSWAPH : ATOMIC_SWAP<opcode_amoswaph, "atomic_swap_i16",  i32>;
defm AMOSWAPW : ATOMIC_SWAP<opcode_amoswapw, "atomic_swap_i32",  i32>;
defm AMOSWAPD : ATOMIC_SWAP<opcode_amoswapd, "atomic_swap_i64",  i64>;
defm AMOSWAPQ : ATOMIC_SWAP<opcode_amoswapq, "atomic_swap_i128", i128>;

//===----------------------------------------------------------------------===//
// load-op zero extend
//===----------------------------------------------------------------------===//
defm AMOADDB  : ATOMIC_SWAP<opcode_amoaddb,  "atomic_load_add_i8",  i32>;
defm AMOSUBB  : ATOMIC_SWAP<opcode_amosubb,  "atomic_load_sub_i8",  i32>;
defm AMOANDB  : ATOMIC_SWAP<opcode_amoandb,  "atomic_load_and_i8",  i32>;
defm AMOORB   : ATOMIC_SWAP<opcode_amoorb,   "atomic_load_or_i8",   i32>;
defm AMOXORB  : ATOMIC_SWAP<opcode_amoxorb,  "atomic_load_xor_i8",  i32>;
defm AMOMINUB : ATOMIC_SWAP<opcode_amominub, "atomic_load_umin_i8", i32>;
defm AMOMAXUB : ATOMIC_SWAP<opcode_amomaxub, "atomic_load_umax_i8", i32>;
defm AMOMINSB : ATOMIC_SWAP<opcode_amominsb, "atomic_load_min_i8",  i32>;
defm AMOMAXSB : ATOMIC_SWAP<opcode_amomaxsb, "atomic_load_max_i8",  i32>;

defm AMOADDH  : ATOMIC_SWAP<opcode_amoaddh,  "atomic_load_add_i16",  i32>;
defm AMOSUBH  : ATOMIC_SWAP<opcode_amosubh,  "atomic_load_sub_i16",  i32>;
defm AMOANDH  : ATOMIC_SWAP<opcode_amoandh,  "atomic_load_and_i16",  i32>;
defm AMOORH   : ATOMIC_SWAP<opcode_amoorh,   "atomic_load_or_i16",   i32>;
defm AMOXORH  : ATOMIC_SWAP<opcode_amoxorh,  "atomic_load_xor_i16",  i32>;
defm AMOMINUH : ATOMIC_SWAP<opcode_amominuh, "atomic_load_umin_i16", i32>;
defm AMOMAXUH : ATOMIC_SWAP<opcode_amomaxuh, "atomic_load_umax_i16", i32>;
defm AMOMINSH : ATOMIC_SWAP<opcode_amominsh, "atomic_load_min_i16",  i32>;
defm AMOMAXSH : ATOMIC_SWAP<opcode_amomaxsh, "atomic_load_max_i16",  i32>;

defm AMOADDW  : ATOMIC_SWAP<opcode_amoaddw,  "atomic_load_add_i32",  i32>;
defm AMOSUBW  : ATOMIC_SWAP<opcode_amosubw,  "atomic_load_sub_i32",  i32>;
defm AMOANDW  : ATOMIC_SWAP<opcode_amoandw,  "atomic_load_and_i32",  i32>;
defm AMOORW   : ATOMIC_SWAP<opcode_amoorw,   "atomic_load_or_i32",   i32>;
defm AMOXORW  : ATOMIC_SWAP<opcode_amoxorw,  "atomic_load_xor_i32",  i32>;
defm AMOMINUW : ATOMIC_SWAP<opcode_amominuw, "atomic_load_umin_i32", i32>;
defm AMOMAXUW : ATOMIC_SWAP<opcode_amomaxuw, "atomic_load_umax_i32", i32>;
defm AMOMINSW : ATOMIC_SWAP<opcode_amominsw, "atomic_load_min_i32",  i32>;
defm AMOMAXSW : ATOMIC_SWAP<opcode_amomaxsw, "atomic_load_max_i32",  i32>;

defm AMOADDD  : ATOMIC_SWAP<opcode_amoaddd,  "atomic_load_add_i64",  i64>;
defm AMOSUBD  : ATOMIC_SWAP<opcode_amosubd,  "atomic_load_sub_i64",  i64>;
defm AMOANDD  : ATOMIC_SWAP<opcode_amoandd,  "atomic_load_and_i64",  i64>;
defm AMOORD   : ATOMIC_SWAP<opcode_amoord,   "atomic_load_or_i64",   i64>;
defm AMOXORD  : ATOMIC_SWAP<opcode_amoxord,  "atomic_load_xor_i64",  i64>;
defm AMOMINUD : ATOMIC_SWAP<opcode_amominud, "atomic_load_umin_i64", i64>;
defm AMOMAXUD : ATOMIC_SWAP<opcode_amomaxud, "atomic_load_umax_i64", i64>;
defm AMOMINSD : ATOMIC_SWAP<opcode_amominsd, "atomic_load_min_i64",  i64>;
defm AMOMAXSD : ATOMIC_SWAP<opcode_amomaxsd, "atomic_load_max_i64",  i64>;

defm AMOADDQ  : ATOMIC_SWAP<opcode_amoaddq,  "atomic_load_add_i128",  i128>;
defm AMOSUBQ  : ATOMIC_SWAP<opcode_amosubq,  "atomic_load_sub_i128",  i128>;
defm AMOANDQ  : ATOMIC_SWAP<opcode_amoandq,  "atomic_load_and_i128",  i128>;
defm AMOORQ   : ATOMIC_SWAP<opcode_amoorq,   "atomic_load_or_i128",   i128>;
defm AMOXORQ  : ATOMIC_SWAP<opcode_amoxorq,  "atomic_load_xor_i128",  i128>;
defm AMOMINUQ : ATOMIC_SWAP<opcode_amominuq, "atomic_load_umin_i128", i128>;
defm AMOMAXUQ : ATOMIC_SWAP<opcode_amomaxuq, "atomic_load_umax_i128", i128>;
defm AMOMINSQ : ATOMIC_SWAP<opcode_amominsq, "atomic_load_min_i128",  i128>;
defm AMOMAXSQ : ATOMIC_SWAP<opcode_amomaxsq, "atomic_load_max_i128",  i128>;
