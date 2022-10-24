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
  def FENCE_A  : MISC_NoArgs<opcode_fence_a,  (outs), (ins), [(atomic_fence (i64 4), timm)]>;
  def FENCE_R  : MISC_NoArgs<opcode_fence_r,  (outs), (ins), [(atomic_fence (i64 5), timm)]>;
  def FENCE_AR : MISC_NoArgs<opcode_fence_ar, (outs), (ins), [(atomic_fence (i64 6), timm)]>;
  def FENCE_SC : MISC_NoArgs<opcode_fence_sc, (outs), (ins), [(atomic_fence (i64 7), timm)]>;
}

//===----------------------------------------------------------------------===//
// tablegen fixes
// atomic_load_128
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
ATOMIC_LOAD<misc_opx Opc, PatFrag OpNode, ValueType Ty>
{
  def NAME : MISC_Rab<Opc, (outs GR:$ra), (ins GR:$rb),
                      !strconcat(Opc.mnem, " $ra, $rb"), [], IIC_iu_instr>;

  def : Pat<(Ty (OpNode iPTR:$rb)), (!cast<InstBase>(NAME) GR:$rb)>;
}

defm AMX_LD_I8:   ATOMIC_LOAD<opcode_amx_ld_i8,   relaxed_load<atomic_load_8>,   i32>;
defm AMX_LD_I16:  ATOMIC_LOAD<opcode_amx_ld_i16,  relaxed_load<atomic_load_16>,  i32>;
defm AMX_LD_I32:  ATOMIC_LOAD<opcode_amx_ld_i32,  relaxed_load<atomic_load_32>,  i32>;
defm AMX_LD_I64:  ATOMIC_LOAD<opcode_amx_ld_i64,  relaxed_load<atomic_load_64>,  i64>;
defm AMX_LD_I128: ATOMIC_LOAD<opcode_amx_ld_i128, relaxed_load<atomic_load_128>, i128>;

defm AMQ_LD_I8:   ATOMIC_LOAD<opcode_amq_ld_i8,   acquiring_load<atomic_load_8>,   i32>;
defm AMQ_LD_I16:  ATOMIC_LOAD<opcode_amq_ld_i16,  acquiring_load<atomic_load_16>,  i32>;
defm AMQ_LD_I32:  ATOMIC_LOAD<opcode_amq_ld_i32,  acquiring_load<atomic_load_32>,  i32>;
defm AMQ_LD_I64:  ATOMIC_LOAD<opcode_amq_ld_i64,  acquiring_load<atomic_load_64>,  i64>;
defm AMQ_LD_I128: ATOMIC_LOAD<opcode_amq_ld_i128, acquiring_load<atomic_load_128>, i128>;

//===----------------------------------------------------------------------===//
// atomic store instructions
//===----------------------------------------------------------------------===//
multiclass
ATOMIC_STORE<misc_opx Opc, PatFrag OpNode, ValueType Ty>
{
  def NAME : MISC_Rab<Opc, (outs), (ins GR:$ra, GR:$rb),
                      !strconcat(Opc.mnem, " $ra, $rb"), [], IIC_iu_instr>;

  def : Pat<(OpNode iPTR:$rb, Ty:$ra), (!cast<InstBase>(NAME) GR:$ra, GR:$rb)>;
}

defm AMX_ST_I8:   ATOMIC_STORE<opcode_amx_st_i8,   relaxed_store<atomic_store_8>,   i32>;
defm AMX_ST_I16:  ATOMIC_STORE<opcode_amx_st_i16,  relaxed_store<atomic_store_16>,  i32>;
defm AMX_ST_I32:  ATOMIC_STORE<opcode_amx_st_i32,  relaxed_store<atomic_store_32>,  i32>;
defm AMX_ST_I64:  ATOMIC_STORE<opcode_amx_st_i64,  relaxed_store<atomic_store_64>,  i64>;
defm AMX_ST_I128: ATOMIC_STORE<opcode_amx_st_i128, relaxed_store<atomic_store_128>, i128>;

defm AMR_ST_I8:   ATOMIC_STORE<opcode_amr_st_i8,   releasing_store<atomic_store_8>,   i32>;
defm AMR_ST_I16:  ATOMIC_STORE<opcode_amr_st_i16,  releasing_store<atomic_store_16>,  i32>;
defm AMR_ST_I32:  ATOMIC_STORE<opcode_amr_st_i32,  releasing_store<atomic_store_32>,  i32>;
defm AMR_ST_I64:  ATOMIC_STORE<opcode_amr_st_i64,  releasing_store<atomic_store_64>,  i64>;
defm AMR_ST_I128: ATOMIC_STORE<opcode_amr_st_i128, releasing_store<atomic_store_128>, i128>;

//===----------------------------------------------------------------------===//
// CAS instructions
//===----------------------------------------------------------------------===//
multiclass
ATOMIC_CAS<misc_opx Opc, PatFrag OpNode, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  let Constraints = "$swap = $ra" in {
    def NAME : MISC_Rabc<Opc, (outs GR:$ra), (ins GR:$rb, GR:$rc, GR:$swap),
                         !strconcat(Opc.mnem, " $ra, $rb, $rc"), [], itin>;
  }

  def : Pat<(OpNode iPTR:$rb, Ty:$rc, Ty:$swap), (!cast<InstBase>(NAME) $rb, $rc, Ty:$swap)>;
}

defm AMX_CAS_I8   : ATOMIC_CAS<opcode_amx_cas_i8,   atomic_cmp_swap_i8_monotonic,   i32>;
defm AMQ_CAS_I8   : ATOMIC_CAS<opcode_amq_cas_i8,   atomic_cmp_swap_i8_acquire,     i32>;
defm AMR_CAS_I8   : ATOMIC_CAS<opcode_amr_cas_i8,   atomic_cmp_swap_i8_release,     i32>;
defm AMZ_CAS_I8   : ATOMIC_CAS<opcode_amz_cas_i8,   atomic_cmp_swap_i8_acq_rel,     i32>;

defm AMX_CAS_I16  : ATOMIC_CAS<opcode_amx_cas_i16,  atomic_cmp_swap_i16_monotonic,  i32>;
defm AMQ_CAS_I16  : ATOMIC_CAS<opcode_amq_cas_i16,  atomic_cmp_swap_i16_acquire,    i32>;
defm AMR_CAS_I16  : ATOMIC_CAS<opcode_amr_cas_i16,  atomic_cmp_swap_i16_release,    i32>;
defm AMZ_CAS_I16  : ATOMIC_CAS<opcode_amz_cas_i16,  atomic_cmp_swap_i16_acq_rel,    i32>;

defm AMX_CAS_I32  : ATOMIC_CAS<opcode_amx_cas_i32,  atomic_cmp_swap_i32_monotonic,  i32>;
defm AMQ_CAS_I32  : ATOMIC_CAS<opcode_amq_cas_i32,  atomic_cmp_swap_i32_acquire,    i32>;
defm AMR_CAS_I32  : ATOMIC_CAS<opcode_amr_cas_i32,  atomic_cmp_swap_i32_release,    i32>;
defm AMZ_CAS_I32  : ATOMIC_CAS<opcode_amz_cas_i32,  atomic_cmp_swap_i32_acq_rel,    i32>;

defm AMX_CAS_I64  : ATOMIC_CAS<opcode_amx_cas_i64,  atomic_cmp_swap_i64_monotonic,  i64>;
defm AMQ_CAS_I64  : ATOMIC_CAS<opcode_amq_cas_i64,  atomic_cmp_swap_i64_acquire,    i64>;
defm AMR_CAS_I64  : ATOMIC_CAS<opcode_amr_cas_i64,  atomic_cmp_swap_i64_release,    i64>;
defm AMZ_CAS_I64  : ATOMIC_CAS<opcode_amz_cas_i64,  atomic_cmp_swap_i64_acq_rel,    i64>;

defm AMX_CAS_I128 : ATOMIC_CAS<opcode_amx_cas_i128, atomic_cmp_swap_i128_monotonic, i128>;
defm AMQ_CAS_I128 : ATOMIC_CAS<opcode_amq_cas_i128, atomic_cmp_swap_i128_acquire,   i128>;
defm AMR_CAS_I128 : ATOMIC_CAS<opcode_amr_cas_i128, atomic_cmp_swap_i128_release,   i128>;
defm AMZ_CAS_I128 : ATOMIC_CAS<opcode_amz_cas_i128, atomic_cmp_swap_i128_acq_rel,   i128>;

//===----------------------------------------------------------------------===//
// swap instructions
//===----------------------------------------------------------------------===//
multiclass
ATOMIC_SWAP<misc_opx Opc, PatFrag OpNode, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : MISC_Rabc<Opc, (outs GR:$ra), (ins GR:$rb, GR:$rc),
                       !strconcat(Opc.mnem, " $ra, $rb, $rc"), [], itin>;

  def : Pat<(OpNode iPTR:$rb, Ty:$rc), (!cast<InstBase>(NAME) $rb, $rc)>;
}

defm AMX_SWAP_I8   : ATOMIC_SWAP<opcode_amx_swap_u8,   atomic_swap_i8_monotonic,   i32>;
defm AMQ_SWAP_I8   : ATOMIC_SWAP<opcode_amq_swap_u8,   atomic_swap_i8_acquire,     i32>;
defm AMR_SWAP_I8   : ATOMIC_SWAP<opcode_amr_swap_u8,   atomic_swap_i8_release,     i32>;
defm AMZ_SWAP_I8   : ATOMIC_SWAP<opcode_amz_swap_u8,   atomic_swap_i8_acq_rel,     i32>;

defm AMX_SWAP_I16  : ATOMIC_SWAP<opcode_amx_swap_u16,  atomic_swap_i16_monotonic,  i32>;
defm AMQ_SWAP_I16  : ATOMIC_SWAP<opcode_amq_swap_u16,  atomic_swap_i16_acquire,    i32>;
defm AMR_SWAP_I16  : ATOMIC_SWAP<opcode_amr_swap_u16,  atomic_swap_i16_release,    i32>;
defm AMZ_SWAP_I16  : ATOMIC_SWAP<opcode_amz_swap_u16,  atomic_swap_i16_acq_rel,    i32>;

defm AMX_SWAP_I32  : ATOMIC_SWAP<opcode_amx_swap_u32,  atomic_swap_i32_monotonic,  i32>;
defm AMQ_SWAP_I32  : ATOMIC_SWAP<opcode_amq_swap_u32,  atomic_swap_i32_acquire,    i32>;
defm AMR_SWAP_I32  : ATOMIC_SWAP<opcode_amr_swap_u32,  atomic_swap_i32_release,    i32>;
defm AMZ_SWAP_I32  : ATOMIC_SWAP<opcode_amz_swap_u32,  atomic_swap_i32_acq_rel,    i32>;

defm AMX_SWAP_I64  : ATOMIC_SWAP<opcode_amx_swap_u64,  atomic_swap_i64_monotonic,  i64>;
defm AMQ_SWAP_I64  : ATOMIC_SWAP<opcode_amq_swap_u64,  atomic_swap_i64_acquire,    i64>;
defm AMR_SWAP_I64  : ATOMIC_SWAP<opcode_amr_swap_u64,  atomic_swap_i64_release,    i64>;
defm AMZ_SWAP_I64  : ATOMIC_SWAP<opcode_amz_swap_u64,  atomic_swap_i64_acq_rel,    i64>;

defm AMX_SWAP_I128 : ATOMIC_SWAP<opcode_amx_swap_u128, atomic_swap_i128_monotonic, i128>;
defm AMQ_SWAP_I128 : ATOMIC_SWAP<opcode_amq_swap_u128, atomic_swap_i128_acquire,   i128>;
defm AMR_SWAP_I128 : ATOMIC_SWAP<opcode_amr_swap_u128, atomic_swap_i128_release,   i128>;
defm AMZ_SWAP_I128 : ATOMIC_SWAP<opcode_amz_swap_u128, atomic_swap_i128_acq_rel,   i128>;

//===----------------------------------------------------------------------===//
// LOAD-OP instructions
//===----------------------------------------------------------------------===//
multiclass
ATOMIC_LOAD_OP<misc_opx Opc, PatFrag OpNode, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : MISC_Rabc<Opc, (outs GR:$ra), (ins GR:$rb, GR:$rc),
                       !strconcat(Opc.mnem, " $ra, $rb, $rc"), [], itin>;

  def : Pat<(OpNode iPTR:$rb, Ty:$rc), (!cast<InstBase>(NAME) $rb, $rc)>;
}

// load-add
defm AMX_LD_ADD_I8   : ATOMIC_LOAD_OP<opcode_amx_ld_add_u8,   atomic_load_add_i8_monotonic,   i32>;
defm AMQ_LD_ADD_I8   : ATOMIC_LOAD_OP<opcode_amq_ld_add_u8,   atomic_load_add_i8_acquire,     i32>;
defm AMR_LD_ADD_I8   : ATOMIC_LOAD_OP<opcode_amr_ld_add_u8,   atomic_load_add_i8_release,     i32>;
defm AMZ_LD_ADD_I8   : ATOMIC_LOAD_OP<opcode_amz_ld_add_u8,   atomic_load_add_i8_acq_rel,     i32>;

defm AMX_LD_ADD_I16  : ATOMIC_LOAD_OP<opcode_amx_ld_add_u16,  atomic_load_add_i16_monotonic,  i32>;
defm AMQ_LD_ADD_I16  : ATOMIC_LOAD_OP<opcode_amq_ld_add_u16,  atomic_load_add_i16_acquire,    i32>;
defm AMR_LD_ADD_I16  : ATOMIC_LOAD_OP<opcode_amr_ld_add_u16,  atomic_load_add_i16_release,    i32>;
defm AMZ_LD_ADD_I16  : ATOMIC_LOAD_OP<opcode_amz_ld_add_u16,  atomic_load_add_i16_acq_rel,    i32>;

defm AMX_LD_ADD_I32  : ATOMIC_LOAD_OP<opcode_amx_ld_add_u32,  atomic_load_add_i32_monotonic,  i32>;
defm AMQ_LD_ADD_I32  : ATOMIC_LOAD_OP<opcode_amq_ld_add_u32,  atomic_load_add_i32_acquire,    i32>;
defm AMR_LD_ADD_I32  : ATOMIC_LOAD_OP<opcode_amr_ld_add_u32,  atomic_load_add_i32_release,    i32>;
defm AMZ_LD_ADD_I32  : ATOMIC_LOAD_OP<opcode_amz_ld_add_u32,  atomic_load_add_i32_acq_rel,    i32>;

defm AMX_LD_ADD_I64  : ATOMIC_LOAD_OP<opcode_amx_ld_add_u64,  atomic_load_add_i64_monotonic,  i64>;
defm AMQ_LD_ADD_I64  : ATOMIC_LOAD_OP<opcode_amq_ld_add_u64,  atomic_load_add_i64_acquire,    i64>;
defm AMR_LD_ADD_I64  : ATOMIC_LOAD_OP<opcode_amr_ld_add_u64,  atomic_load_add_i64_release,    i64>;
defm AMZ_LD_ADD_I64  : ATOMIC_LOAD_OP<opcode_amz_ld_add_u64,  atomic_load_add_i64_acq_rel,    i64>;

defm AMX_LD_ADD_I128 : ATOMIC_LOAD_OP<opcode_amx_ld_add_u128, atomic_load_add_i128_monotonic, i128>;
defm AMQ_LD_ADD_I128 : ATOMIC_LOAD_OP<opcode_amq_ld_add_u128, atomic_load_add_i128_acquire,   i128>;
defm AMR_LD_ADD_I128 : ATOMIC_LOAD_OP<opcode_amr_ld_add_u128, atomic_load_add_i128_release,   i128>;
defm AMZ_LD_ADD_I128 : ATOMIC_LOAD_OP<opcode_amz_ld_add_u128, atomic_load_add_i128_acq_rel,   i128>;

// load-and
defm AMX_LD_AND_I8   : ATOMIC_LOAD_OP<opcode_amx_ld_and_u8,   atomic_load_and_i8_monotonic,   i32>;
defm AMQ_LD_AND_I8   : ATOMIC_LOAD_OP<opcode_amq_ld_and_u8,   atomic_load_and_i8_acquire,     i32>;
defm AMR_LD_AND_I8   : ATOMIC_LOAD_OP<opcode_amr_ld_and_u8,   atomic_load_and_i8_release,     i32>;
defm AMZ_LD_AND_I8   : ATOMIC_LOAD_OP<opcode_amz_ld_and_u8,   atomic_load_and_i8_acq_rel,     i32>;

defm AMX_LD_AND_I16  : ATOMIC_LOAD_OP<opcode_amx_ld_and_u16,  atomic_load_and_i16_monotonic,  i32>;
defm AMQ_LD_AND_I16  : ATOMIC_LOAD_OP<opcode_amq_ld_and_u16,  atomic_load_and_i16_acquire,    i32>;
defm AMR_LD_AND_I16  : ATOMIC_LOAD_OP<opcode_amr_ld_and_u16,  atomic_load_and_i16_release,    i32>;
defm AMZ_LD_AND_I16  : ATOMIC_LOAD_OP<opcode_amz_ld_and_u16,  atomic_load_and_i16_acq_rel,    i32>;

defm AMX_LD_AND_I32  : ATOMIC_LOAD_OP<opcode_amx_ld_and_u32,  atomic_load_and_i32_monotonic,  i32>;
defm AMQ_LD_AND_I32  : ATOMIC_LOAD_OP<opcode_amq_ld_and_u32,  atomic_load_and_i32_acquire,    i32>;
defm AMR_LD_AND_I32  : ATOMIC_LOAD_OP<opcode_amr_ld_and_u32,  atomic_load_and_i32_release,    i32>;
defm AMZ_LD_AND_I32  : ATOMIC_LOAD_OP<opcode_amz_ld_and_u32,  atomic_load_and_i32_acq_rel,    i32>;

defm AMX_LD_AND_I64  : ATOMIC_LOAD_OP<opcode_amx_ld_and_u64,  atomic_load_and_i64_monotonic,  i64>;
defm AMQ_LD_AND_I64  : ATOMIC_LOAD_OP<opcode_amq_ld_and_u64,  atomic_load_and_i64_acquire,    i64>;
defm AMR_LD_AND_I64  : ATOMIC_LOAD_OP<opcode_amr_ld_and_u64,  atomic_load_and_i64_release,    i64>;
defm AMZ_LD_AND_I64  : ATOMIC_LOAD_OP<opcode_amz_ld_and_u64,  atomic_load_and_i64_acq_rel,    i64>;

defm AMX_LD_AND_I128 : ATOMIC_LOAD_OP<opcode_amx_ld_and_u128, atomic_load_and_i128_monotonic, i128>;
defm AMQ_LD_AND_I128 : ATOMIC_LOAD_OP<opcode_amq_ld_and_u128, atomic_load_and_i128_acquire,   i128>;
defm AMR_LD_AND_I128 : ATOMIC_LOAD_OP<opcode_amr_ld_and_u128, atomic_load_and_i128_release,   i128>;
defm AMZ_LD_AND_I128 : ATOMIC_LOAD_OP<opcode_amz_ld_and_u128, atomic_load_and_i128_acq_rel,   i128>;

// load-or
defm AMX_LD_OR_I8   : ATOMIC_LOAD_OP<opcode_amx_ld_or_u8,   atomic_load_or_i8_monotonic,   i32>;
defm AMQ_LD_OR_I8   : ATOMIC_LOAD_OP<opcode_amq_ld_or_u8,   atomic_load_or_i8_acquire,     i32>;
defm AMR_LD_OR_I8   : ATOMIC_LOAD_OP<opcode_amr_ld_or_u8,   atomic_load_or_i8_release,     i32>;
defm AMZ_LD_OR_I8   : ATOMIC_LOAD_OP<opcode_amz_ld_or_u8,   atomic_load_or_i8_acq_rel,     i32>;

defm AMX_LD_OR_I16  : ATOMIC_LOAD_OP<opcode_amx_ld_or_u16,  atomic_load_or_i16_monotonic,  i32>;
defm AMQ_LD_OR_I16  : ATOMIC_LOAD_OP<opcode_amq_ld_or_u16,  atomic_load_or_i16_acquire,    i32>;
defm AMR_LD_OR_I16  : ATOMIC_LOAD_OP<opcode_amr_ld_or_u16,  atomic_load_or_i16_release,    i32>;
defm AMZ_LD_OR_I16  : ATOMIC_LOAD_OP<opcode_amz_ld_or_u16,  atomic_load_or_i16_acq_rel,    i32>;

defm AMX_LD_OR_I32  : ATOMIC_LOAD_OP<opcode_amx_ld_or_u32,  atomic_load_or_i32_monotonic,  i32>;
defm AMQ_LD_OR_I32  : ATOMIC_LOAD_OP<opcode_amq_ld_or_u32,  atomic_load_or_i32_acquire,    i32>;
defm AMR_LD_OR_I32  : ATOMIC_LOAD_OP<opcode_amr_ld_or_u32,  atomic_load_or_i32_release,    i32>;
defm AMZ_LD_OR_I32  : ATOMIC_LOAD_OP<opcode_amz_ld_or_u32,  atomic_load_or_i32_acq_rel,    i32>;

defm AMX_LD_OR_I64  : ATOMIC_LOAD_OP<opcode_amx_ld_or_u64,  atomic_load_or_i64_monotonic,  i64>;
defm AMQ_LD_OR_I64  : ATOMIC_LOAD_OP<opcode_amq_ld_or_u64,  atomic_load_or_i64_acquire,    i64>;
defm AMR_LD_OR_I64  : ATOMIC_LOAD_OP<opcode_amr_ld_or_u64,  atomic_load_or_i64_release,    i64>;
defm AMZ_LD_OR_I64  : ATOMIC_LOAD_OP<opcode_amz_ld_or_u64,  atomic_load_or_i64_acq_rel,    i64>;

defm AMX_LD_OR_I128 : ATOMIC_LOAD_OP<opcode_amx_ld_or_u128, atomic_load_or_i128_monotonic, i128>;
defm AMQ_LD_OR_I128 : ATOMIC_LOAD_OP<opcode_amq_ld_or_u128, atomic_load_or_i128_acquire,   i128>;
defm AMR_LD_OR_I128 : ATOMIC_LOAD_OP<opcode_amr_ld_or_u128, atomic_load_or_i128_release,   i128>;
defm AMZ_LD_OR_I128 : ATOMIC_LOAD_OP<opcode_amz_ld_or_u128, atomic_load_or_i128_acq_rel,   i128>;

// load-xor
defm AMX_LD_XOR_I8   : ATOMIC_LOAD_OP<opcode_amx_ld_xor_u8,   atomic_load_xor_i8_monotonic,   i32>;
defm AMQ_LD_XOR_I8   : ATOMIC_LOAD_OP<opcode_amq_ld_xor_u8,   atomic_load_xor_i8_acquire,     i32>;
defm AMR_LD_XOR_I8   : ATOMIC_LOAD_OP<opcode_amr_ld_xor_u8,   atomic_load_xor_i8_release,     i32>;
defm AMZ_LD_XOR_I8   : ATOMIC_LOAD_OP<opcode_amz_ld_xor_u8,   atomic_load_xor_i8_acq_rel,     i32>;

defm AMX_LD_XOR_I16  : ATOMIC_LOAD_OP<opcode_amx_ld_xor_u16,  atomic_load_xor_i16_monotonic,  i32>;
defm AMQ_LD_XOR_I16  : ATOMIC_LOAD_OP<opcode_amq_ld_xor_u16,  atomic_load_xor_i16_acquire,    i32>;
defm AMR_LD_XOR_I16  : ATOMIC_LOAD_OP<opcode_amr_ld_xor_u16,  atomic_load_xor_i16_release,    i32>;
defm AMZ_LD_XOR_I16  : ATOMIC_LOAD_OP<opcode_amz_ld_xor_u16,  atomic_load_xor_i16_acq_rel,    i32>;

defm AMX_LD_XOR_I32  : ATOMIC_LOAD_OP<opcode_amx_ld_xor_u32,  atomic_load_xor_i32_monotonic,  i32>;
defm AMQ_LD_XOR_I32  : ATOMIC_LOAD_OP<opcode_amq_ld_xor_u32,  atomic_load_xor_i32_acquire,    i32>;
defm AMR_LD_XOR_I32  : ATOMIC_LOAD_OP<opcode_amr_ld_xor_u32,  atomic_load_xor_i32_release,    i32>;
defm AMZ_LD_XOR_I32  : ATOMIC_LOAD_OP<opcode_amz_ld_xor_u32,  atomic_load_xor_i32_acq_rel,    i32>;

defm AMX_LD_XOR_I64  : ATOMIC_LOAD_OP<opcode_amx_ld_xor_u64,  atomic_load_xor_i64_monotonic,  i64>;
defm AMQ_LD_XOR_I64  : ATOMIC_LOAD_OP<opcode_amq_ld_xor_u64,  atomic_load_xor_i64_acquire,    i64>;
defm AMR_LD_XOR_I64  : ATOMIC_LOAD_OP<opcode_amr_ld_xor_u64,  atomic_load_xor_i64_release,    i64>;
defm AMZ_LD_XOR_I64  : ATOMIC_LOAD_OP<opcode_amz_ld_xor_u64,  atomic_load_xor_i64_acq_rel,    i64>;

defm AMX_LD_XOR_I128 : ATOMIC_LOAD_OP<opcode_amx_ld_xor_u128, atomic_load_xor_i128_monotonic, i128>;
defm AMQ_LD_XOR_I128 : ATOMIC_LOAD_OP<opcode_amq_ld_xor_u128, atomic_load_xor_i128_acquire,   i128>;
defm AMR_LD_XOR_I128 : ATOMIC_LOAD_OP<opcode_amr_ld_xor_u128, atomic_load_xor_i128_release,   i128>;
defm AMZ_LD_XOR_I128 : ATOMIC_LOAD_OP<opcode_amz_ld_xor_u128, atomic_load_xor_i128_acq_rel,   i128>;

// load-smin
defm AMX_LD_MIN_I8   : ATOMIC_LOAD_OP<opcode_amx_ld_min_i8,   atomic_load_min_i8_monotonic,   i32>;
defm AMQ_LD_MIN_I8   : ATOMIC_LOAD_OP<opcode_amq_ld_min_i8,   atomic_load_min_i8_acquire,     i32>;
defm AMR_LD_MIN_I8   : ATOMIC_LOAD_OP<opcode_amr_ld_min_i8,   atomic_load_min_i8_release,     i32>;
defm AMZ_LD_MIN_I8   : ATOMIC_LOAD_OP<opcode_amz_ld_min_i8,   atomic_load_min_i8_acq_rel,     i32>;

defm AMX_LD_MIN_I16  : ATOMIC_LOAD_OP<opcode_amx_ld_min_i16,  atomic_load_min_i16_monotonic,  i32>;
defm AMQ_LD_MIN_I16  : ATOMIC_LOAD_OP<opcode_amq_ld_min_i16,  atomic_load_min_i16_acquire,    i32>;
defm AMR_LD_MIN_I16  : ATOMIC_LOAD_OP<opcode_amr_ld_min_i16,  atomic_load_min_i16_release,    i32>;
defm AMZ_LD_MIN_I16  : ATOMIC_LOAD_OP<opcode_amz_ld_min_i16,  atomic_load_min_i16_acq_rel,    i32>;

defm AMX_LD_MIN_I32  : ATOMIC_LOAD_OP<opcode_amx_ld_min_i32,  atomic_load_min_i32_monotonic,  i32>;
defm AMQ_LD_MIN_I32  : ATOMIC_LOAD_OP<opcode_amq_ld_min_i32,  atomic_load_min_i32_acquire,    i32>;
defm AMR_LD_MIN_I32  : ATOMIC_LOAD_OP<opcode_amr_ld_min_i32,  atomic_load_min_i32_release,    i32>;
defm AMZ_LD_MIN_I32  : ATOMIC_LOAD_OP<opcode_amz_ld_min_i32,  atomic_load_min_i32_acq_rel,    i32>;

defm AMX_LD_MIN_I64  : ATOMIC_LOAD_OP<opcode_amx_ld_min_i64,  atomic_load_min_i64_monotonic,  i64>;
defm AMQ_LD_MIN_I64  : ATOMIC_LOAD_OP<opcode_amq_ld_min_i64,  atomic_load_min_i64_acquire,    i64>;
defm AMR_LD_MIN_I64  : ATOMIC_LOAD_OP<opcode_amr_ld_min_i64,  atomic_load_min_i64_release,    i64>;
defm AMZ_LD_MIN_I64  : ATOMIC_LOAD_OP<opcode_amz_ld_min_i64,  atomic_load_min_i64_acq_rel,    i64>;

defm AMX_LD_MIN_I128 : ATOMIC_LOAD_OP<opcode_amx_ld_min_i128, atomic_load_min_i128_monotonic, i128>;
defm AMQ_LD_MIN_I128 : ATOMIC_LOAD_OP<opcode_amq_ld_min_i128, atomic_load_min_i128_acquire,   i128>;
defm AMR_LD_MIN_I128 : ATOMIC_LOAD_OP<opcode_amr_ld_min_i128, atomic_load_min_i128_release,   i128>;
defm AMZ_LD_MIN_I128 : ATOMIC_LOAD_OP<opcode_amz_ld_min_i128, atomic_load_min_i128_acq_rel,   i128>;

// load-umin
defm AMX_LD_MIN_U8   : ATOMIC_LOAD_OP<opcode_amx_ld_min_u8,   atomic_load_umin_i8_monotonic,   i32>;
defm AMQ_LD_MIN_U8   : ATOMIC_LOAD_OP<opcode_amq_ld_min_u8,   atomic_load_umin_i8_acquire,     i32>;
defm AMR_LD_MIN_U8   : ATOMIC_LOAD_OP<opcode_amr_ld_min_u8,   atomic_load_umin_i8_release,     i32>;
defm AMZ_LD_MIN_U8   : ATOMIC_LOAD_OP<opcode_amz_ld_min_u8,   atomic_load_umin_i8_acq_rel,     i32>;

defm AMX_LD_MIN_U16  : ATOMIC_LOAD_OP<opcode_amx_ld_min_u16,  atomic_load_umin_i16_monotonic,  i32>;
defm AMQ_LD_MIN_U16  : ATOMIC_LOAD_OP<opcode_amq_ld_min_u16,  atomic_load_umin_i16_acquire,    i32>;
defm AMR_LD_MIN_U16  : ATOMIC_LOAD_OP<opcode_amr_ld_min_u16,  atomic_load_umin_i16_release,    i32>;
defm AMZ_LD_MIN_U16  : ATOMIC_LOAD_OP<opcode_amz_ld_min_u16,  atomic_load_umin_i16_acq_rel,    i32>;

defm AMX_LD_MIN_U32  : ATOMIC_LOAD_OP<opcode_amx_ld_min_u32,  atomic_load_umin_i32_monotonic,  i32>;
defm AMQ_LD_MIN_U32  : ATOMIC_LOAD_OP<opcode_amq_ld_min_u32,  atomic_load_umin_i32_acquire,    i32>;
defm AMR_LD_MIN_U32  : ATOMIC_LOAD_OP<opcode_amr_ld_min_u32,  atomic_load_umin_i32_release,    i32>;
defm AMZ_LD_MIN_U32  : ATOMIC_LOAD_OP<opcode_amz_ld_min_u32,  atomic_load_umin_i32_acq_rel,    i32>;

defm AMX_LD_MIN_U64  : ATOMIC_LOAD_OP<opcode_amx_ld_min_u64,  atomic_load_umin_i64_monotonic,  i64>;
defm AMQ_LD_MIN_U64  : ATOMIC_LOAD_OP<opcode_amq_ld_min_u64,  atomic_load_umin_i64_acquire,    i64>;
defm AMR_LD_MIN_U64  : ATOMIC_LOAD_OP<opcode_amr_ld_min_u64,  atomic_load_umin_i64_release,    i64>;
defm AMZ_LD_MIN_U64  : ATOMIC_LOAD_OP<opcode_amz_ld_min_u64,  atomic_load_umin_i64_acq_rel,    i64>;

defm AMX_LD_MIN_U128 : ATOMIC_LOAD_OP<opcode_amx_ld_min_u128, atomic_load_umin_i128_monotonic, i128>;
defm AMQ_LD_MIN_U128 : ATOMIC_LOAD_OP<opcode_amq_ld_min_u128, atomic_load_umin_i128_acquire,   i128>;
defm AMR_LD_MIN_U128 : ATOMIC_LOAD_OP<opcode_amr_ld_min_u128, atomic_load_umin_i128_release,   i128>;
defm AMZ_LD_MIN_U128 : ATOMIC_LOAD_OP<opcode_amz_ld_min_u128, atomic_load_umin_i128_acq_rel,   i128>;

// load-smax
defm AMX_LD_MAX_I8   : ATOMIC_LOAD_OP<opcode_amx_ld_max_i8,   atomic_load_max_i8_monotonic,   i32>;
defm AMQ_LD_MAX_I8   : ATOMIC_LOAD_OP<opcode_amq_ld_max_i8,   atomic_load_max_i8_acquire,     i32>;
defm AMR_LD_MAX_I8   : ATOMIC_LOAD_OP<opcode_amr_ld_max_i8,   atomic_load_max_i8_release,     i32>;
defm AMZ_LD_MAX_I8   : ATOMIC_LOAD_OP<opcode_amz_ld_max_i8,   atomic_load_max_i8_acq_rel,     i32>;

defm AMX_LD_MAX_I16  : ATOMIC_LOAD_OP<opcode_amx_ld_max_i16,  atomic_load_max_i16_monotonic,  i32>;
defm AMQ_LD_MAX_I16  : ATOMIC_LOAD_OP<opcode_amq_ld_max_i16,  atomic_load_max_i16_acquire,    i32>;
defm AMR_LD_MAX_I16  : ATOMIC_LOAD_OP<opcode_amr_ld_max_i16,  atomic_load_max_i16_release,    i32>;
defm AMZ_LD_MAX_I16  : ATOMIC_LOAD_OP<opcode_amz_ld_max_i16,  atomic_load_max_i16_acq_rel,    i32>;

defm AMX_LD_MAX_I32  : ATOMIC_LOAD_OP<opcode_amx_ld_max_i32,  atomic_load_max_i32_monotonic,  i32>;
defm AMQ_LD_MAX_I32  : ATOMIC_LOAD_OP<opcode_amq_ld_max_i32,  atomic_load_max_i32_acquire,    i32>;
defm AMR_LD_MAX_I32  : ATOMIC_LOAD_OP<opcode_amr_ld_max_i32,  atomic_load_max_i32_release,    i32>;
defm AMZ_LD_MAX_I32  : ATOMIC_LOAD_OP<opcode_amz_ld_max_i32,  atomic_load_max_i32_acq_rel,    i32>;

defm AMX_LD_MAX_I64  : ATOMIC_LOAD_OP<opcode_amx_ld_max_i64,  atomic_load_max_i64_monotonic,  i64>;
defm AMQ_LD_MAX_I64  : ATOMIC_LOAD_OP<opcode_amq_ld_max_i64,  atomic_load_max_i64_acquire,    i64>;
defm AMR_LD_MAX_I64  : ATOMIC_LOAD_OP<opcode_amr_ld_max_i64,  atomic_load_max_i64_release,    i64>;
defm AMZ_LD_MAX_I64  : ATOMIC_LOAD_OP<opcode_amz_ld_max_i64,  atomic_load_max_i64_acq_rel,    i64>;

defm AMX_LD_MAX_I128 : ATOMIC_LOAD_OP<opcode_amx_ld_max_i128, atomic_load_max_i128_monotonic, i128>;
defm AMQ_LD_MAX_I128 : ATOMIC_LOAD_OP<opcode_amq_ld_max_i128, atomic_load_max_i128_acquire,   i128>;
defm AMR_LD_MAX_I128 : ATOMIC_LOAD_OP<opcode_amr_ld_max_i128, atomic_load_max_i128_release,   i128>;
defm AMZ_LD_MAX_I128 : ATOMIC_LOAD_OP<opcode_amz_ld_max_i128, atomic_load_max_i128_acq_rel,   i128>;

// load-umax
defm AMX_LD_MAX_U8   : ATOMIC_LOAD_OP<opcode_amx_ld_max_u8,   atomic_load_umax_i8_monotonic,   i32>;
defm AMQ_LD_MAX_U8   : ATOMIC_LOAD_OP<opcode_amq_ld_max_u8,   atomic_load_umax_i8_acquire,     i32>;
defm AMR_LD_MAX_U8   : ATOMIC_LOAD_OP<opcode_amr_ld_max_u8,   atomic_load_umax_i8_release,     i32>;
defm AMZ_LD_MAX_U8   : ATOMIC_LOAD_OP<opcode_amz_ld_max_u8,   atomic_load_umax_i8_acq_rel,     i32>;

defm AMX_LD_MAX_U16  : ATOMIC_LOAD_OP<opcode_amx_ld_max_u16,  atomic_load_umax_i16_monotonic,  i32>;
defm AMQ_LD_MAX_U16  : ATOMIC_LOAD_OP<opcode_amq_ld_max_u16,  atomic_load_umax_i16_acquire,    i32>;
defm AMR_LD_MAX_U16  : ATOMIC_LOAD_OP<opcode_amr_ld_max_u16,  atomic_load_umax_i16_release,    i32>;
defm AMZ_LD_MAX_U16  : ATOMIC_LOAD_OP<opcode_amz_ld_max_u16,  atomic_load_umax_i16_acq_rel,    i32>;

defm AMX_LD_MAX_U32  : ATOMIC_LOAD_OP<opcode_amx_ld_max_u32,  atomic_load_umax_i32_monotonic,  i32>;
defm AMQ_LD_MAX_U32  : ATOMIC_LOAD_OP<opcode_amq_ld_max_u32,  atomic_load_umax_i32_acquire,    i32>;
defm AMR_LD_MAX_U32  : ATOMIC_LOAD_OP<opcode_amr_ld_max_u32,  atomic_load_umax_i32_release,    i32>;
defm AMZ_LD_MAX_U32  : ATOMIC_LOAD_OP<opcode_amz_ld_max_u32,  atomic_load_umax_i32_acq_rel,    i32>;

defm AMX_LD_MAX_U64  : ATOMIC_LOAD_OP<opcode_amx_ld_max_u64,  atomic_load_umax_i64_monotonic,  i64>;
defm AMQ_LD_MAX_U64  : ATOMIC_LOAD_OP<opcode_amq_ld_max_u64,  atomic_load_umax_i64_acquire,    i64>;
defm AMR_LD_MAX_U64  : ATOMIC_LOAD_OP<opcode_amr_ld_max_u64,  atomic_load_umax_i64_release,    i64>;
defm AMZ_LD_MAX_U64  : ATOMIC_LOAD_OP<opcode_amz_ld_max_u64,  atomic_load_umax_i64_acq_rel,    i64>;

defm AMX_LD_MAX_U128 : ATOMIC_LOAD_OP<opcode_amx_ld_max_u128, atomic_load_umax_i128_monotonic, i128>;
defm AMQ_LD_MAX_U128 : ATOMIC_LOAD_OP<opcode_amq_ld_max_u128, atomic_load_umax_i128_acquire,   i128>;
defm AMR_LD_MAX_U128 : ATOMIC_LOAD_OP<opcode_amr_ld_max_u128, atomic_load_umax_i128_release,   i128>;
defm AMZ_LD_MAX_U128 : ATOMIC_LOAD_OP<opcode_amz_ld_max_u128, atomic_load_umax_i128_acq_rel,   i128>;

//===----------------------------------------------------------------------===//
// LOAD-SUB(V) => LOAD-ADD (0-V)
//===----------------------------------------------------------------------===//
multiclass ATOMIC_LOAD_SUB<PatFrag OpNode, MISC_Rabc Inst, InstBase SUB, ValueType Ty>
{
  def : Pat<(Ty (OpNode iPTR:$ptr, Ty:$val)), (Inst GR:$ptr, (SUB (Ty gz), GR:$val))>;
}

defm : ATOMIC_LOAD_SUB<atomic_load_sub_i8_monotonic,   AMX_LD_ADD_I8, SUB_I32, i32>;
defm : ATOMIC_LOAD_SUB<atomic_load_sub_i8_acquire,     AMQ_LD_ADD_I8, SUB_I32, i32>;
defm : ATOMIC_LOAD_SUB<atomic_load_sub_i8_release,     AMR_LD_ADD_I8, SUB_I32, i32>;
defm : ATOMIC_LOAD_SUB<atomic_load_sub_i8_acq_rel,     AMZ_LD_ADD_I8, SUB_I32, i32>;

defm : ATOMIC_LOAD_SUB<atomic_load_sub_i16_monotonic,  AMX_LD_ADD_I16, SUB_I32, i32>;
defm : ATOMIC_LOAD_SUB<atomic_load_sub_i16_acquire,    AMQ_LD_ADD_I16, SUB_I32, i32>;
defm : ATOMIC_LOAD_SUB<atomic_load_sub_i16_release,    AMR_LD_ADD_I16, SUB_I32, i32>;
defm : ATOMIC_LOAD_SUB<atomic_load_sub_i16_acq_rel,    AMZ_LD_ADD_I16, SUB_I32, i32>;

defm : ATOMIC_LOAD_SUB<atomic_load_sub_i32_monotonic,  AMX_LD_ADD_I32, SUB_I32, i32>;
defm : ATOMIC_LOAD_SUB<atomic_load_sub_i32_acquire,    AMQ_LD_ADD_I32, SUB_I32, i32>;
defm : ATOMIC_LOAD_SUB<atomic_load_sub_i32_release,    AMR_LD_ADD_I32, SUB_I32, i32>;
defm : ATOMIC_LOAD_SUB<atomic_load_sub_i32_acq_rel,    AMZ_LD_ADD_I32, SUB_I32, i32>;

defm : ATOMIC_LOAD_SUB<atomic_load_sub_i64_monotonic,  AMX_LD_ADD_I64, SUB_I64, i64>;
defm : ATOMIC_LOAD_SUB<atomic_load_sub_i64_acquire,    AMQ_LD_ADD_I64, SUB_I64, i64>;
defm : ATOMIC_LOAD_SUB<atomic_load_sub_i64_release,    AMR_LD_ADD_I64, SUB_I64, i64>;
defm : ATOMIC_LOAD_SUB<atomic_load_sub_i64_acq_rel,    AMZ_LD_ADD_I64, SUB_I64, i64>;

defm : ATOMIC_LOAD_SUB<atomic_load_sub_i128_monotonic, AMX_LD_ADD_I128, SUB_I128, i128>;
defm : ATOMIC_LOAD_SUB<atomic_load_sub_i128_acquire,   AMQ_LD_ADD_I128, SUB_I128, i128>;
defm : ATOMIC_LOAD_SUB<atomic_load_sub_i128_release,   AMR_LD_ADD_I128, SUB_I128, i128>;
defm : ATOMIC_LOAD_SUB<atomic_load_sub_i128_acq_rel,   AMZ_LD_ADD_I128, SUB_I128, i128>;

//===----------------------------------------------------------------------===//
// STORE-OP instructions
//===----------------------------------------------------------------------===//
multiclass
ATOMIC_STORE_OP<misc_opx Opc, PatFrag OpNode, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  let ra = 0 in {
    def NAME : MISC_Rabc<Opc, (outs), (ins GR:$rb, GR:$rc),
                         !strconcat(Opc.mnem, " $rb, $rc"), [], itin>;
  }

  // TODO: wait for corresponding tablegen patterns to match 'atomic_store_op'
  def : Pat<(OpNode iPTR:$rb, Ty:$rc), (!cast<InstBase>(NAME) $rb, $rc)>;
}

// store-add
defm AMX_ST_ADD_I8    : ATOMIC_STORE_OP<opcode_amx_st_add_u8,    atomic_load_add_i8_monotonic,   i32>;
defm AMR_ST_ADD_I8    : ATOMIC_STORE_OP<opcode_amr_st_add_u8,    atomic_load_add_i8_release,     i32>;

defm AMX_ST_ADD_I16   : ATOMIC_STORE_OP<opcode_amx_st_add_u16,   atomic_load_add_i16_monotonic,  i32>;
defm AMR_ST_ADD_I16   : ATOMIC_STORE_OP<opcode_amr_st_add_u16,   atomic_load_add_i16_release,    i32>;

defm AMX_ST_ADD_I32   : ATOMIC_STORE_OP<opcode_amx_st_add_u32,   atomic_load_add_i32_monotonic,  i32>;
defm AMR_ST_ADD_I32   : ATOMIC_STORE_OP<opcode_amr_st_add_u32,   atomic_load_add_i32_release,    i32>;

defm AMX_ST_ADD_I64   : ATOMIC_STORE_OP<opcode_amx_st_add_u64,   atomic_load_add_i64_monotonic,  i64>;
defm AMR_ST_ADD_I64   : ATOMIC_STORE_OP<opcode_amr_st_add_u64,   atomic_load_add_i64_release,    i64>;

defm AMX_ST_ADD_I128  : ATOMIC_STORE_OP<opcode_amx_st_add_u128,  atomic_load_add_i128_monotonic, i128>;
defm AMR_ST_ADD_I128  : ATOMIC_STORE_OP<opcode_amr_st_add_u128,  atomic_load_add_i128_release,   i128>;

// store-and
defm AMX_ST_AND_I8    : ATOMIC_STORE_OP<opcode_amx_st_and_u8,    atomic_load_and_i8_monotonic,   i32>;
defm AMR_ST_AND_I8    : ATOMIC_STORE_OP<opcode_amr_st_and_u8,    atomic_load_and_i8_release,     i32>;

defm AMX_ST_AND_I16   : ATOMIC_STORE_OP<opcode_amx_st_and_u16,   atomic_load_and_i16_monotonic,  i32>;
defm AMR_ST_AND_I16   : ATOMIC_STORE_OP<opcode_amr_st_and_u16,   atomic_load_and_i16_release,    i32>;

defm AMX_ST_AND_I32   : ATOMIC_STORE_OP<opcode_amx_st_and_u32,   atomic_load_and_i32_monotonic,  i32>;
defm AMR_ST_AND_I32   : ATOMIC_STORE_OP<opcode_amr_st_and_u32,   atomic_load_and_i32_release,    i32>;

defm AMX_ST_AND_I64   : ATOMIC_STORE_OP<opcode_amx_st_and_u64,   atomic_load_and_i64_monotonic,  i64>;
defm AMR_ST_AND_I64   : ATOMIC_STORE_OP<opcode_amr_st_and_u64,   atomic_load_and_i64_release,    i64>;

defm AMX_ST_AND_I128  : ATOMIC_STORE_OP<opcode_amx_st_and_u128,  atomic_load_and_i128_monotonic, i128>;
defm AMR_ST_AND_I128  : ATOMIC_STORE_OP<opcode_amr_st_and_u128,  atomic_load_and_i128_release,   i128>;

// store-or
defm AMX_ST_OR_I8    : ATOMIC_STORE_OP<opcode_amx_st_or_u8,    atomic_load_or_i8_monotonic,   i32>;
defm AMR_ST_OR_I8    : ATOMIC_STORE_OP<opcode_amr_st_or_u8,    atomic_load_or_i8_release,     i32>;

defm AMX_ST_OR_I16   : ATOMIC_STORE_OP<opcode_amx_st_or_u16,   atomic_load_or_i16_monotonic,  i32>;
defm AMR_ST_OR_I16   : ATOMIC_STORE_OP<opcode_amr_st_or_u16,   atomic_load_or_i16_release,    i32>;

defm AMX_ST_OR_I32   : ATOMIC_STORE_OP<opcode_amx_st_or_u32,   atomic_load_or_i32_monotonic,  i32>;
defm AMR_ST_OR_I32   : ATOMIC_STORE_OP<opcode_amr_st_or_u32,   atomic_load_or_i32_release,    i32>;

defm AMX_ST_OR_I64   : ATOMIC_STORE_OP<opcode_amx_st_or_u64,   atomic_load_or_i64_monotonic,  i64>;
defm AMR_ST_OR_I64   : ATOMIC_STORE_OP<opcode_amr_st_or_u64,   atomic_load_or_i64_release,    i64>;

defm AMX_ST_OR_I128  : ATOMIC_STORE_OP<opcode_amx_st_or_u128,  atomic_load_or_i128_monotonic, i128>;
defm AMR_ST_OR_I128  : ATOMIC_STORE_OP<opcode_amr_st_or_u128,  atomic_load_or_i128_release,   i128>;

// store-xor
defm AMX_ST_XOR_I8    : ATOMIC_STORE_OP<opcode_amx_st_xor_u8,    atomic_load_xor_i8_monotonic,   i32>;
defm AMR_ST_XOR_I8    : ATOMIC_STORE_OP<opcode_amr_st_xor_u8,    atomic_load_xor_i8_release,     i32>;

defm AMX_ST_XOR_I16   : ATOMIC_STORE_OP<opcode_amx_st_xor_u16,   atomic_load_xor_i16_monotonic,  i32>;
defm AMR_ST_XOR_I16   : ATOMIC_STORE_OP<opcode_amr_st_xor_u16,   atomic_load_xor_i16_release,    i32>;

defm AMX_ST_XOR_I32   : ATOMIC_STORE_OP<opcode_amx_st_xor_u32,   atomic_load_xor_i32_monotonic,  i32>;
defm AMR_ST_XOR_I32   : ATOMIC_STORE_OP<opcode_amr_st_xor_u32,   atomic_load_xor_i32_release,    i32>;

defm AMX_ST_XOR_I64   : ATOMIC_STORE_OP<opcode_amx_st_xor_u64,   atomic_load_xor_i64_monotonic,  i64>;
defm AMR_ST_XOR_I64   : ATOMIC_STORE_OP<opcode_amr_st_xor_u64,   atomic_load_xor_i64_release,    i64>;

defm AMX_ST_XOR_I128  : ATOMIC_STORE_OP<opcode_amx_st_xor_u128,  atomic_load_xor_i128_monotonic, i128>;
defm AMR_ST_XOR_I128  : ATOMIC_STORE_OP<opcode_amr_st_xor_u128,  atomic_load_xor_i128_release,   i128>;

// store-smin
defm AMX_ST_MIN_I8    : ATOMIC_STORE_OP<opcode_amx_st_min_i8,    atomic_load_min_i8_monotonic,   i32>;
defm AMR_ST_MIN_I8    : ATOMIC_STORE_OP<opcode_amr_st_min_i8,    atomic_load_min_i8_release,     i32>;

defm AMX_ST_MIN_I16   : ATOMIC_STORE_OP<opcode_amx_st_min_i16,   atomic_load_min_i16_monotonic,  i32>;
defm AMR_ST_MIN_I16   : ATOMIC_STORE_OP<opcode_amr_st_min_i16,   atomic_load_min_i16_release,    i32>;

defm AMX_ST_MIN_I32   : ATOMIC_STORE_OP<opcode_amx_st_min_i32,   atomic_load_min_i32_monotonic,  i32>;
defm AMR_ST_MIN_I32   : ATOMIC_STORE_OP<opcode_amr_st_min_i32,   atomic_load_min_i32_release,    i32>;

defm AMX_ST_MIN_I64   : ATOMIC_STORE_OP<opcode_amx_st_min_i64,   atomic_load_min_i64_monotonic,  i64>;
defm AMR_ST_MIN_I64   : ATOMIC_STORE_OP<opcode_amr_st_min_i64,   atomic_load_min_i64_release,    i64>;

defm AMX_ST_MIN_I128  : ATOMIC_STORE_OP<opcode_amx_st_min_i128,  atomic_load_min_i128_monotonic, i128>;
defm AMR_ST_MIN_I128  : ATOMIC_STORE_OP<opcode_amr_st_min_i128,  atomic_load_min_i128_release,   i128>;

// store-umin
defm AMX_ST_MIN_U8    : ATOMIC_STORE_OP<opcode_amx_st_min_u8,    atomic_load_umin_i8_monotonic,   i32>;
defm AMR_ST_MIN_U8    : ATOMIC_STORE_OP<opcode_amr_st_min_u8,    atomic_load_umin_i8_release,     i32>;

defm AMX_ST_MIN_U16   : ATOMIC_STORE_OP<opcode_amx_st_min_u16,   atomic_load_umin_i16_monotonic,  i32>;
defm AMR_ST_MIN_U16   : ATOMIC_STORE_OP<opcode_amr_st_min_u16,   atomic_load_umin_i16_release,    i32>;

defm AMX_ST_MIN_U32   : ATOMIC_STORE_OP<opcode_amx_st_min_u32,   atomic_load_umin_i32_monotonic,  i32>;
defm AMR_ST_MIN_U32   : ATOMIC_STORE_OP<opcode_amr_st_min_u32,   atomic_load_umin_i32_release,    i32>;

defm AMX_ST_MIN_U64   : ATOMIC_STORE_OP<opcode_amx_st_min_u64,   atomic_load_umin_i64_monotonic,  i64>;
defm AMR_ST_MIN_U64   : ATOMIC_STORE_OP<opcode_amr_st_min_u64,   atomic_load_umin_i64_release,    i64>;

defm AMX_ST_MIN_U128  : ATOMIC_STORE_OP<opcode_amx_st_min_u128,  atomic_load_umin_i128_monotonic, i128>;
defm AMR_ST_MIN_U128  : ATOMIC_STORE_OP<opcode_amr_st_min_u128,  atomic_load_umin_i128_release,   i128>;

// store-smax
defm AMX_ST_MAX_I8    : ATOMIC_STORE_OP<opcode_amx_st_max_i8,    atomic_load_max_i8_monotonic,   i32>;
defm AMR_ST_MAX_I8    : ATOMIC_STORE_OP<opcode_amr_st_max_i8,    atomic_load_max_i8_release,     i32>;

defm AMX_ST_MAX_I16   : ATOMIC_STORE_OP<opcode_amx_st_max_i16,   atomic_load_max_i16_monotonic,  i32>;
defm AMR_ST_MAX_I16   : ATOMIC_STORE_OP<opcode_amr_st_max_i16,   atomic_load_max_i16_release,    i32>;

defm AMX_ST_MAX_I32   : ATOMIC_STORE_OP<opcode_amx_st_max_i32,   atomic_load_max_i32_monotonic,  i32>;
defm AMR_ST_MAX_I32   : ATOMIC_STORE_OP<opcode_amr_st_max_i32,   atomic_load_max_i32_release,    i32>;

defm AMX_ST_MAX_I64   : ATOMIC_STORE_OP<opcode_amx_st_max_i64,   atomic_load_max_i64_monotonic,  i64>;
defm AMR_ST_MAX_I64   : ATOMIC_STORE_OP<opcode_amr_st_max_i64,   atomic_load_max_i64_release,    i64>;

defm AMX_ST_MAX_I128  : ATOMIC_STORE_OP<opcode_amx_st_max_i128,  atomic_load_max_i128_monotonic, i128>;
defm AMR_ST_MAX_I128  : ATOMIC_STORE_OP<opcode_amr_st_max_i128,  atomic_load_max_i128_release,   i128>;

// store-umax
defm AMX_ST_MAX_U8    : ATOMIC_STORE_OP<opcode_amx_st_max_u8,    atomic_load_umax_i8_monotonic,   i32>;
defm AMR_ST_MAX_U8    : ATOMIC_STORE_OP<opcode_amr_st_max_u8,    atomic_load_umax_i8_release,     i32>;

defm AMX_ST_MAX_U16   : ATOMIC_STORE_OP<opcode_amx_st_max_u16,   atomic_load_umax_i16_monotonic,  i32>;
defm AMR_ST_MAX_U16   : ATOMIC_STORE_OP<opcode_amr_st_max_u16,   atomic_load_umax_i16_release,    i32>;

defm AMX_ST_MAX_U32   : ATOMIC_STORE_OP<opcode_amx_st_max_u32,   atomic_load_umax_i32_monotonic,  i32>;
defm AMR_ST_MAX_U32   : ATOMIC_STORE_OP<opcode_amr_st_max_u32,   atomic_load_umax_i32_release,    i32>;

defm AMX_ST_MAX_U64   : ATOMIC_STORE_OP<opcode_amx_st_max_u64,   atomic_load_umax_i64_monotonic,  i64>;
defm AMR_ST_MAX_U64   : ATOMIC_STORE_OP<opcode_amr_st_max_u64,   atomic_load_umax_i64_release,    i64>;

defm AMX_ST_MAX_U128  : ATOMIC_STORE_OP<opcode_amx_st_max_u128,  atomic_load_umax_i128_monotonic, i128>;
defm AMR_ST_MAX_U128  : ATOMIC_STORE_OP<opcode_amr_st_max_u128,  atomic_load_umax_i128_release,   i128>;
