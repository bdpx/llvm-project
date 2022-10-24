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

class seq_cst_store<PatFrag base> : PatFrag<(ops node:$val, node:$ptr), (base node:$val, node:$ptr)> {
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

  def : Pat<(Ty (relaxed_load  <Op> iPTR:$rb)), (!cast<InstBase>(NAME) GR:$rb, memory_ordering_relaxed.value)>;
  def : Pat<(Ty (acquiring_load<Op> iPTR:$rb)), (!cast<InstBase>(NAME) GR:$rb, memory_ordering_acquire.value)>;
  def : Pat<(Ty (seq_cst_load<Op>   iPTR:$rb)), (!cast<InstBase>(NAME) GR:$rb, memory_ordering_seq_cst.value)>;
}

defm AMO_LD_U8:   ATOMIC_LOAD<opcode_amo_ld_u8,   atomic_load_8,   i32>;
defm AMO_LD_U16:  ATOMIC_LOAD<opcode_amo_ld_u16,  atomic_load_16,  i32>;
defm AMO_LD_U32:  ATOMIC_LOAD<opcode_amo_ld_u32,  atomic_load_32,  i32>;
defm AMO_LD_U64:  ATOMIC_LOAD<opcode_amo_ld_u64,  atomic_load_64,  i64>;
defm AMO_LD_U128: ATOMIC_LOAD<opcode_amo_ld_u128, atomic_load_128, i128>;

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

  def : Pat<(relaxed_store  <Op> iPTR:$rb, Ty:$ra), (!cast<InstBase>(NAME) GR:$ra, GR:$rb, memory_ordering_relaxed.value)>;
  def : Pat<(releasing_store<Op> iPTR:$rb, Ty:$ra), (!cast<InstBase>(NAME) GR:$ra, GR:$rb, memory_ordering_release.value)>;
  def : Pat<(seq_cst_store<Op>   iPTR:$rb, Ty:$ra), (!cast<InstBase>(NAME) GR:$ra, GR:$rb, memory_ordering_seq_cst.value)>;
}

defm AMO_ST_U8:   ATOMIC_STORE<opcode_amo_st_u8,   atomic_store_8,    i32>;
defm AMO_ST_U16:  ATOMIC_STORE<opcode_amo_st_u16,  atomic_store_16,   i32>;
defm AMO_ST_U32:  ATOMIC_STORE<opcode_amo_st_u32,  atomic_store_32,   i32>;
defm AMO_ST_U64:  ATOMIC_STORE<opcode_amo_st_u64,  atomic_store_64,   i64>;
defm AMO_ST_U128: ATOMIC_STORE<opcode_amo_st_u128, atomic_store_128,  i128>;

//===----------------------------------------------------------------------===//
// CAS instructions (in the FMA_F128 main opcode)
//===----------------------------------------------------------------------===//
class FMA_F128_CAS<fma_f128_opx opxCode, InstrItinClass itin = IIC_iu_instr>
   : InstBase<opcode_fma_f128, (outs GR:$ra), (ins GR:$rb, GR:$rc, GR:$rd, mo_arg:$memory_ordering),
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

multiclass ATOMIC_CAS<fma_f128_opx Opx,  string PatFragName, ValueType Ty>
{
  def NAME : FMA_F128_CAS<Opx>;

  def : Pat<(Ty (!cast<PatFrag>(PatFragName # "_monotonic") iPTR:$rb, Ty:$rc, Ty:$rd)), (!cast<InstBase>(NAME) GR:$rb, GR:$rc, GR:$rd, memory_ordering_relaxed.value)>;
  def : Pat<(Ty (!cast<PatFrag>(PatFragName # "_acquire"  ) iPTR:$rb, Ty:$rc, Ty:$rd)), (!cast<InstBase>(NAME) GR:$rb, GR:$rc, GR:$rd, memory_ordering_acquire.value)>;
  def : Pat<(Ty (!cast<PatFrag>(PatFragName # "_release"  ) iPTR:$rb, Ty:$rc, Ty:$rd)), (!cast<InstBase>(NAME) GR:$rb, GR:$rc, GR:$rd, memory_ordering_release.value)>;
  def : Pat<(Ty (!cast<PatFrag>(PatFragName # "_acq_rel"  ) iPTR:$rb, Ty:$rc, Ty:$rd)), (!cast<InstBase>(NAME) GR:$rb, GR:$rc, GR:$rd, memory_ordering_acq_rel.value)>;
  def : Pat<(Ty (!cast<PatFrag>(PatFragName # "_seq_cst"  ) iPTR:$rb, Ty:$rc, Ty:$rd)), (!cast<InstBase>(NAME) GR:$rb, GR:$rc, GR:$rd, memory_ordering_seq_cst.value)>;
}

defm AMO_CAS_U8   : ATOMIC_CAS<opcode_amo_cas_u8,    "atomic_cmp_swap_i8",    i32>;
defm AMO_CAS_U16  : ATOMIC_CAS<opcode_amo_cas_u16,   "atomic_cmp_swap_i16",   i32>;
defm AMO_CAS_U32  : ATOMIC_CAS<opcode_amo_cas_u32,   "atomic_cmp_swap_i32",   i32>;
defm AMO_CAS_U64  : ATOMIC_CAS<opcode_amo_cas_u64,   "atomic_cmp_swap_i64",   i64>;
defm AMO_CAS_U128 : ATOMIC_CAS<opcode_amo_cas_u128,  "atomic_cmp_swap_i128",  i128>;

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

defm AMO_SWAP_U8   : ATOMIC_SWAP<opcode_amo_swap_u8,   "atomic_swap_i8",   i32>;
defm AMO_SWAP_U16  : ATOMIC_SWAP<opcode_amo_swap_u16,  "atomic_swap_i16",  i32>;
defm AMO_SWAP_U32  : ATOMIC_SWAP<opcode_amo_swap_u32,  "atomic_swap_i32",  i32>;
defm AMO_SWAP_U64  : ATOMIC_SWAP<opcode_amo_swap_u64,  "atomic_swap_i64",  i64>;
defm AMO_SWAP_U128 : ATOMIC_SWAP<opcode_amo_swap_u128, "atomic_swap_i128", i128>;

//===----------------------------------------------------------------------===//
// load-op zero extend
//===----------------------------------------------------------------------===//
defm AMO_ADD_U8 : ATOMIC_SWAP<opcode_amo_add_u8, "atomic_load_add_i8", i32>;
defm AMO_SUB_U8 : ATOMIC_SWAP<opcode_amo_sub_u8, "atomic_load_sub_i8", i32>;
defm AMO_AND_U8 : ATOMIC_SWAP<opcode_amo_and_u8, "atomic_load_and_i8", i32>;
defm AMO_OR_U8  : ATOMIC_SWAP<opcode_amo_or_u8,  "atomic_load_or_i8", i32>;
defm AMO_XOR_U8 : ATOMIC_SWAP<opcode_amo_xor_u8, "atomic_load_xor_i8", i32>;
defm AMO_MIN_U8 : ATOMIC_SWAP<opcode_amo_min_u8, "atomic_load_umin_i8", i32>;
defm AMO_MAX_U8 : ATOMIC_SWAP<opcode_amo_max_u8, "atomic_load_umax_i8", i32>;
defm AMO_MIN_I8 : ATOMIC_SWAP<opcode_amo_min_i8, "atomic_load_min_i8", i32>;
defm AMO_MAX_I8 : ATOMIC_SWAP<opcode_amo_max_i8, "atomic_load_max_i8", i32>;

defm AMO_ADD_U16 : ATOMIC_SWAP<opcode_amo_add_u16, "atomic_load_add_i16", i32>;
defm AMO_SUB_U16 : ATOMIC_SWAP<opcode_amo_sub_u16, "atomic_load_sub_i16", i32>;
defm AMO_AND_U16 : ATOMIC_SWAP<opcode_amo_and_u16, "atomic_load_and_i16", i32>;
defm AMO_OR_U16  : ATOMIC_SWAP<opcode_amo_or_u16,  "atomic_load_or_i16", i32>;
defm AMO_XOR_U16 : ATOMIC_SWAP<opcode_amo_xor_u16, "atomic_load_xor_i16", i32>;
defm AMO_MIN_U16 : ATOMIC_SWAP<opcode_amo_min_u16, "atomic_load_umin_i16", i32>;
defm AMO_MAX_U16 : ATOMIC_SWAP<opcode_amo_max_u16, "atomic_load_umax_i16", i32>;
defm AMO_MIN_I16 : ATOMIC_SWAP<opcode_amo_min_i16, "atomic_load_min_i16", i32>;
defm AMO_MAX_I16 : ATOMIC_SWAP<opcode_amo_max_i16, "atomic_load_max_i16", i32>;

defm AMO_ADD_U32 : ATOMIC_SWAP<opcode_amo_add_u32, "atomic_load_add_i32", i32>;
defm AMO_SUB_U32 : ATOMIC_SWAP<opcode_amo_sub_u32, "atomic_load_sub_i32", i32>;
defm AMO_AND_U32 : ATOMIC_SWAP<opcode_amo_and_u32, "atomic_load_and_i32", i32>;
defm AMO_OR_U32  : ATOMIC_SWAP<opcode_amo_or_u32,  "atomic_load_or_i32", i32>;
defm AMO_XOR_U32 : ATOMIC_SWAP<opcode_amo_xor_u32, "atomic_load_xor_i32", i32>;
defm AMO_MIN_U32 : ATOMIC_SWAP<opcode_amo_min_u32, "atomic_load_umin_i32", i32>;
defm AMO_MAX_U32 : ATOMIC_SWAP<opcode_amo_max_u32, "atomic_load_umax_i32", i32>;
defm AMO_MIN_I32 : ATOMIC_SWAP<opcode_amo_min_i32, "atomic_load_min_i32", i32>;
defm AMO_MAX_I32 : ATOMIC_SWAP<opcode_amo_max_i32, "atomic_load_max_i32", i32>;

defm AMO_ADD_U64 : ATOMIC_SWAP<opcode_amo_add_u64, "atomic_load_add_i64", i64>;
defm AMO_SUB_U64 : ATOMIC_SWAP<opcode_amo_sub_u64, "atomic_load_sub_i64", i64>;
defm AMO_AND_U64 : ATOMIC_SWAP<opcode_amo_and_u64, "atomic_load_and_i64", i64>;
defm AMO_OR_U64  : ATOMIC_SWAP<opcode_amo_or_u64,  "atomic_load_or_i64", i64>;
defm AMO_XOR_U64 : ATOMIC_SWAP<opcode_amo_xor_u64, "atomic_load_xor_i64", i64>;
defm AMO_MIN_U64 : ATOMIC_SWAP<opcode_amo_min_u64, "atomic_load_umin_i64", i64>;
defm AMO_MAX_U64 : ATOMIC_SWAP<opcode_amo_max_u64, "atomic_load_umax_i64", i64>;
defm AMO_MIN_I64 : ATOMIC_SWAP<opcode_amo_min_i64, "atomic_load_min_i64", i64>;
defm AMO_MAX_I64 : ATOMIC_SWAP<opcode_amo_max_i64, "atomic_load_max_i64", i64>;

defm AMO_ADD_U128 : ATOMIC_SWAP<opcode_amo_add_u128, "atomic_load_add_i128", i128>;
defm AMO_SUB_U128 : ATOMIC_SWAP<opcode_amo_sub_u128, "atomic_load_sub_i128", i128>;
defm AMO_AND_U128 : ATOMIC_SWAP<opcode_amo_and_u128, "atomic_load_and_i128", i128>;
defm AMO_OR_U128  : ATOMIC_SWAP<opcode_amo_or_u128,  "atomic_load_or_i128", i128>;
defm AMO_XOR_U128 : ATOMIC_SWAP<opcode_amo_xor_u128, "atomic_load_xor_i128", i128>;
defm AMO_MIN_U128 : ATOMIC_SWAP<opcode_amo_min_u128, "atomic_load_umin_i128", i128>;
defm AMO_MAX_U128 : ATOMIC_SWAP<opcode_amo_max_u128, "atomic_load_umax_i128", i128>;
defm AMO_MIN_I128 : ATOMIC_SWAP<opcode_amo_min_i128, "atomic_load_min_i128", i128>;
defm AMO_MAX_I128 : ATOMIC_SWAP<opcode_amo_max_i128, "atomic_load_max_i128", i128>;
