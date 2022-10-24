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
ATOMIC_LOAD<misc_opx Opc, PatFrag OpNode, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : MISC_Rab<Opc, (outs GR:$ra), (ins GR:$rb),
                      !strconcat(Opc.mnem, " $ra, $rb"), [], itin>;

  def : Pat<(Ty (OpNode iPTR:$rb)), (!cast<InstBase>(NAME) GR:$rb)>;
}

multiclass
ATOMIC_LOAD_MODELS<string misc_opx_name, PatFrag PatFragName, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  defm AMX_ # NAME : ATOMIC_LOAD<!cast<misc_opx>("opcode_amx_" # misc_opx_name), relaxed_load  <PatFragName>, Ty, itin>;
  defm AMQ_ # NAME : ATOMIC_LOAD<!cast<misc_opx>("opcode_amq_" # misc_opx_name), acquiring_load<PatFragName>, Ty, itin>;
}

defm LD_U8:   ATOMIC_LOAD_MODELS<"ld_u8",    atomic_load_8,   i32>;
defm LD_U16:  ATOMIC_LOAD_MODELS<"ld_u16",   atomic_load_16,  i32>;
defm LD_U32:  ATOMIC_LOAD_MODELS<"ld_u32",   atomic_load_32,  i32>;
defm LD_U64:  ATOMIC_LOAD_MODELS<"ld_u64",   atomic_load_64,  i64>;
defm LD_U128: ATOMIC_LOAD_MODELS<"ld_u128",  atomic_load_128, i128>;

//===----------------------------------------------------------------------===//
// atomic store instructions
//===----------------------------------------------------------------------===//
multiclass
ATOMIC_STORE<misc_opx Opc, PatFrag OpNode, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : MISC_Rab<Opc, (outs), (ins GR:$ra, GR:$rb),
                      !strconcat(Opc.mnem, " $ra, $rb"), [], itin>;

  def : Pat<(OpNode iPTR:$rb, Ty:$ra), (!cast<InstBase>(NAME) GR:$ra, GR:$rb)>;
}

multiclass
ATOMIC_STORE_MODELS<string misc_opx_name, PatFrag PatFragName, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  defm AMX_ # NAME : ATOMIC_STORE<!cast<misc_opx>("opcode_amx_" # misc_opx_name), relaxed_store  <PatFragName>, Ty, itin>;
  defm AMR_ # NAME : ATOMIC_STORE<!cast<misc_opx>("opcode_amr_" # misc_opx_name), releasing_store<PatFragName>, Ty, itin>;
}

defm ST_U8:   ATOMIC_STORE_MODELS<"st_u8",   atomic_store_8,    i32>;
defm ST_U16:  ATOMIC_STORE_MODELS<"st_u16",  atomic_store_16,   i32>;
defm ST_U32:  ATOMIC_STORE_MODELS<"st_u32",  atomic_store_32,   i32>;
defm ST_U64:  ATOMIC_STORE_MODELS<"st_u64",  atomic_store_64,   i64>;
defm ST_U128: ATOMIC_STORE_MODELS<"st_u128", atomic_store_128,  i128>;

//===----------------------------------------------------------------------===//
// CAS instructions
//===----------------------------------------------------------------------===//
multiclass
ATOMIC_CAS<fma_opx Opx, PatFrag OpNode, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : FMA_Rabcd<Opx, (outs GR:$ra), (ins GR:$rb, GR:$rc, GR:$rd),
     !strconcat(Opx.mnem, " $ra, $rb, $rc, $rd"),
     [(set Ty:$ra, (OpNode iPTR:$rb, Ty:$rc, Ty:$rd))], itin>;
}

multiclass
ATOMIC_CAS_MODELS<string fma_opx_name, string PatFragName, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  defm AMX_ # NAME : ATOMIC_CAS<!cast<fma_opx>("opcode_amx_" # fma_opx_name), !cast<PatFrag>(PatFragName # "_monotonic"), Ty, itin>;
  defm AMQ_ # NAME : ATOMIC_CAS<!cast<fma_opx>("opcode_amq_" # fma_opx_name), !cast<PatFrag>(PatFragName # "_acquire"  ), Ty, itin>;
  defm AMR_ # NAME : ATOMIC_CAS<!cast<fma_opx>("opcode_amr_" # fma_opx_name), !cast<PatFrag>(PatFragName # "_release"  ), Ty, itin>;
  defm AMZ_ # NAME : ATOMIC_CAS<!cast<fma_opx>("opcode_amz_" # fma_opx_name), !cast<PatFrag>(PatFragName # "_acq_rel"  ), Ty, itin>;
}

defm CAS_U8   : ATOMIC_CAS_MODELS<"cas_u8",    "atomic_cmp_swap_i8",    i32>;
defm CAS_U16  : ATOMIC_CAS_MODELS<"cas_u16",   "atomic_cmp_swap_i16",   i32>;
defm CAS_U32  : ATOMIC_CAS_MODELS<"cas_u32",   "atomic_cmp_swap_i32",   i32>;
defm CAS_U64  : ATOMIC_CAS_MODELS<"cas_u64",   "atomic_cmp_swap_i64",   i64>;
defm CAS_U128 : ATOMIC_CAS_MODELS<"cas_u128",  "atomic_cmp_swap_i128",  i128>;

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

multiclass
ATOMIC_SWAP_MODELS<string misc_opx_name, string PatFragName, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  defm AMX_ # NAME : ATOMIC_SWAP<!cast<misc_opx>("opcode_amx_" # misc_opx_name), !cast<PatFrag>(PatFragName # "_monotonic"), Ty, itin>;
  defm AMQ_ # NAME : ATOMIC_SWAP<!cast<misc_opx>("opcode_amq_" # misc_opx_name), !cast<PatFrag>(PatFragName # "_acquire"  ), Ty, itin>;
  defm AMR_ # NAME : ATOMIC_SWAP<!cast<misc_opx>("opcode_amr_" # misc_opx_name), !cast<PatFrag>(PatFragName # "_release"  ), Ty, itin>;
  defm AMZ_ # NAME : ATOMIC_SWAP<!cast<misc_opx>("opcode_amz_" # misc_opx_name), !cast<PatFrag>(PatFragName # "_acq_rel"  ), Ty, itin>;
}

defm SWAP_U8   : ATOMIC_SWAP_MODELS<"swap_u8",   "atomic_swap_i8",   i32>;
defm SWAP_U16  : ATOMIC_SWAP_MODELS<"swap_u16",  "atomic_swap_i16",  i32>;
defm SWAP_U32  : ATOMIC_SWAP_MODELS<"swap_u32",  "atomic_swap_i32",  i32>;
defm SWAP_U64  : ATOMIC_SWAP_MODELS<"swap_u64",  "atomic_swap_i64",  i64>;
defm SWAP_U128 : ATOMIC_SWAP_MODELS<"swap_u128", "atomic_swap_i128", i128>;

//===----------------------------------------------------------------------===//
// load-op, sign extend
//===----------------------------------------------------------------------===//
multiclass
ATOMIC_LOAD_OP_SEXT<misc_opx Opc, PatFrag OpNode,
  ValueType Ty, list<ValueType> MemoryTypes, list<ValueType> BiggerTypes, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : MISC_Rabc<Opc, (outs GR:$ra), (ins GR:$rb, GR:$rc),
                       !strconcat(Opc.mnem, " $ra, $rb, $rc"), [], itin>;

  def : Pat<(Ty (OpNode iPTR:$rb, Ty:$rc)), (!cast<InstBase>(NAME) $rb, $rc)>;

  foreach Bt = BiggerTypes in {
    // free sext from base to bigger type
    def : Pat<(Bt (sext (OpNode iPTR:$rb, Ty:$rc))), (!cast<InstBase>(NAME) $rb, $rc)>;
    // free sext from smaller to bigger type
    foreach Mt = MemoryTypes in {
      def : Pat<(Bt (sext (sext_inreg (OpNode iPTR:$rb, Ty:$rc), Mt))), (!cast<InstBase>(NAME) $rb, $rc)>;
    }
  }
  // free sext from smaller to base type
  foreach Mt = MemoryTypes in {
    def : Pat<(Ty (sext_inreg (OpNode iPTR:$rb, Ty:$rc), Mt)), (!cast<InstBase>(NAME) $rb, $rc)>;
  }
}

multiclass
ATOMIC_LOAD_OP_SEXT_MODELS<string misc_opx_name, string PatFragName,
  ValueType Ty, list<ValueType> MemoryTypes, list<ValueType> BiggerTypes, InstrItinClass itin = IIC_iu_instr>
{
  defm AMX_ # NAME : ATOMIC_LOAD_OP_SEXT<!cast<misc_opx>("opcode_amx_" # misc_opx_name), !cast<PatFrag>(PatFragName # "_monotonic"), Ty, MemoryTypes, BiggerTypes, itin>;
  defm AMQ_ # NAME : ATOMIC_LOAD_OP_SEXT<!cast<misc_opx>("opcode_amq_" # misc_opx_name), !cast<PatFrag>(PatFragName # "_acquire"  ), Ty, MemoryTypes, BiggerTypes, itin>;
  defm AMR_ # NAME : ATOMIC_LOAD_OP_SEXT<!cast<misc_opx>("opcode_amr_" # misc_opx_name), !cast<PatFrag>(PatFragName # "_release"  ), Ty, MemoryTypes, BiggerTypes, itin>;
  defm AMZ_ # NAME : ATOMIC_LOAD_OP_SEXT<!cast<misc_opx>("opcode_amz_" # misc_opx_name), !cast<PatFrag>(PatFragName # "_acq_rel"  ), Ty, MemoryTypes, BiggerTypes, itin>;
}

multiclass ATOMIC_LOAD_OP_SEXT_TYPES<string misc_op_name, string PatFragName>
{
  defm NAME # 8   : ATOMIC_LOAD_OP_SEXT_MODELS<!strconcat(misc_op_name, "8"  ), !strconcat(PatFragName, "8"  ), i32,  [i8],   [i64, i128]>;
  defm NAME # 16  : ATOMIC_LOAD_OP_SEXT_MODELS<!strconcat(misc_op_name, "16" ), !strconcat(PatFragName, "16" ), i32,  [i16],  [i64, i128]>;
  defm NAME # 32  : ATOMIC_LOAD_OP_SEXT_MODELS<!strconcat(misc_op_name, "32" ), !strconcat(PatFragName, "32" ), i32,  [],     [i64, i128]>;
  defm NAME # 64  : ATOMIC_LOAD_OP_SEXT_MODELS<!strconcat(misc_op_name, "64" ), !strconcat(PatFragName, "64" ), i64,  [],     [i128]>;
  defm NAME # 128 : ATOMIC_LOAD_OP_SEXT_MODELS<!strconcat(misc_op_name, "128"), !strconcat(PatFragName, "128"), i128, [],     []>;
}

defm LD_MIN_I : ATOMIC_LOAD_OP_SEXT_TYPES<"ld_min_i", "atomic_load_min_i">;
defm LD_MAX_I : ATOMIC_LOAD_OP_SEXT_TYPES<"ld_max_i", "atomic_load_max_i">;

//===----------------------------------------------------------------------===//
// load-op zero extend
//===----------------------------------------------------------------------===//
multiclass
ATOMIC_LOAD_OP_ZEXT<misc_opx Opc, PatFrag OpNode,
  ValueType Ty, list<int> MemoryTypes, list<ValueType> BiggerTypes, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : MISC_Rabc<Opc, (outs GR:$ra), (ins GR:$rb, GR:$rc),
                       !strconcat(Opc.mnem, " $ra, $rb, $rc"), [], itin>;

  def : Pat<(Ty (OpNode iPTR:$rb, Ty:$rc)), (!cast<InstBase>(NAME) $rb, $rc)>;

  foreach Bt = BiggerTypes in {
    // free zext from base to bigger type
    def : Pat<(Bt (zext (OpNode iPTR:$rb, Ty:$rc))), (!cast<InstBase>(NAME) $rb, $rc)>;
    // free zext from smaller to bigger type
    foreach Mt = MemoryTypes in {
       def : Pat<(Bt (zext (Ty (and (OpNode iPTR:$rb, Ty:$rc), Mt)))), (!cast<InstBase>(NAME) $rb, $rc)>;
    }
  }
  // free zext from smaller to base type
  //foreach Mt = MemoryTypes in {
  //  def : Pat<(Ty (and (OpNode iPTR:$rb, Ty:$rc), Mt)), (!cast<InstBase>(NAME) $rb, $rc)>;
  //}
}

multiclass
ATOMIC_LOAD_OP_ZEXT_MODELS<string misc_opx_name, string PatFragName,
  ValueType Ty, list<int> MemoryTypes, list<ValueType> BiggerTypes, InstrItinClass itin = IIC_iu_instr>
{
  defm AMX_ # NAME : ATOMIC_LOAD_OP_ZEXT<!cast<misc_opx>("opcode_amx_" # misc_opx_name), !cast<PatFrag>(PatFragName # "_monotonic"), Ty, MemoryTypes, BiggerTypes, itin>;
  defm AMQ_ # NAME : ATOMIC_LOAD_OP_ZEXT<!cast<misc_opx>("opcode_amq_" # misc_opx_name), !cast<PatFrag>(PatFragName # "_acquire"  ), Ty, MemoryTypes, BiggerTypes, itin>;
  defm AMR_ # NAME : ATOMIC_LOAD_OP_ZEXT<!cast<misc_opx>("opcode_amr_" # misc_opx_name), !cast<PatFrag>(PatFragName # "_release"  ), Ty, MemoryTypes, BiggerTypes, itin>;
  defm AMZ_ # NAME : ATOMIC_LOAD_OP_ZEXT<!cast<misc_opx>("opcode_amz_" # misc_opx_name), !cast<PatFrag>(PatFragName # "_acq_rel"  ), Ty, MemoryTypes, BiggerTypes, itin>;
}

multiclass ATOMIC_LOAD_OP_ZEXT_TYPES<string misc_op_name, string PatFragName>
{
  defm NAME # 8   : ATOMIC_LOAD_OP_ZEXT_MODELS<!strconcat(misc_op_name, "8"  ), !strconcat(PatFragName, "8"  ), i32,  [0xff  ], [i64, i128]>;
  defm NAME # 16  : ATOMIC_LOAD_OP_ZEXT_MODELS<!strconcat(misc_op_name, "16" ), !strconcat(PatFragName, "16" ), i32,  [0xffff], [i64, i128]>;
  defm NAME # 32  : ATOMIC_LOAD_OP_ZEXT_MODELS<!strconcat(misc_op_name, "32" ), !strconcat(PatFragName, "32" ), i32,  [],       [i64, i128]>;
  defm NAME # 64  : ATOMIC_LOAD_OP_ZEXT_MODELS<!strconcat(misc_op_name, "64" ), !strconcat(PatFragName, "64" ), i64,  [],       [i128]>;
  defm NAME # 128 : ATOMIC_LOAD_OP_ZEXT_MODELS<!strconcat(misc_op_name, "128"), !strconcat(PatFragName, "128"), i128, [],       []>;
}

defm LD_ADD_U : ATOMIC_LOAD_OP_ZEXT_TYPES<"ld_add_u", "atomic_load_add_i">;
defm LD_AND_U : ATOMIC_LOAD_OP_ZEXT_TYPES<"ld_and_u", "atomic_load_and_i">;
defm LD_OR_U  : ATOMIC_LOAD_OP_ZEXT_TYPES<"ld_or_u",  "atomic_load_or_i">;
defm LD_XOR_U : ATOMIC_LOAD_OP_ZEXT_TYPES<"ld_xor_u", "atomic_load_xor_i">;
defm LD_MIN_U : ATOMIC_LOAD_OP_ZEXT_TYPES<"ld_min_u", "atomic_load_umin_i">;
defm LD_MAX_U : ATOMIC_LOAD_OP_ZEXT_TYPES<"ld_max_u", "atomic_load_umax_i">;

//===----------------------------------------------------------------------===//
// LOAD-SUB(V) => LOAD-ADD (0-V)
//===----------------------------------------------------------------------===//
multiclass ATOMIC_LOAD_SUB<PatFrag OpNode, InstBase Inst, InstBase SUB, ValueType Ty>
{
  def : Pat<(Ty (OpNode iPTR:$ptr, Ty:$val)), (Inst GR:$ptr, (SUB (Ty gz), GR:$val))>;
}

multiclass
ATOMIC_LOAD_SUB_MODELS<string PatFragName, InstBase SUB, ValueType Ty>
{
  defm AMX_LOAD_SUB_ # NAME : ATOMIC_LOAD_SUB<!cast<PatFrag>(PatFragName # "_monotonic"), !cast<InstBase>("AMX_LD_ADD_" # NAME), SUB, Ty>;
  defm AMQ_LOAD_SUB_ # NAME : ATOMIC_LOAD_SUB<!cast<PatFrag>(PatFragName # "_acquire"  ), !cast<InstBase>("AMQ_LD_ADD_" # NAME), SUB, Ty>;
  defm AMR_LOAD_SUB_ # NAME : ATOMIC_LOAD_SUB<!cast<PatFrag>(PatFragName # "_release"  ), !cast<InstBase>("AMR_LD_ADD_" # NAME), SUB, Ty>;
  defm AMZ_LOAD_SUB_ # NAME : ATOMIC_LOAD_SUB<!cast<PatFrag>(PatFragName # "_acq_rel"  ), !cast<InstBase>("AMZ_LD_ADD_" # NAME), SUB, Ty>;
}

defm U8   : ATOMIC_LOAD_SUB_MODELS<"atomic_load_sub_i8",   SUB_I32,  i32>;
defm U16  : ATOMIC_LOAD_SUB_MODELS<"atomic_load_sub_i16",  SUB_I32,  i32>;
defm U32  : ATOMIC_LOAD_SUB_MODELS<"atomic_load_sub_i32",  SUB_I32,  i32>;
defm U64  : ATOMIC_LOAD_SUB_MODELS<"atomic_load_sub_i64",  SUB_I64,  i64>;
defm U128 : ATOMIC_LOAD_SUB_MODELS<"atomic_load_sub_i128", SUB_I128, i128 >;

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

multiclass
ATOMIC_STORE_OP_MODELS<string misc_opx_name, string PatFragName, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  defm AMX_ # NAME : ATOMIC_STORE_OP<!cast<misc_opx>("opcode_amx_" # misc_opx_name), !cast<PatFrag>(PatFragName # "_monotonic"), Ty, itin>;
  defm AMR_ # NAME : ATOMIC_STORE_OP<!cast<misc_opx>("opcode_amr_" # misc_opx_name), !cast<PatFrag>(PatFragName # "_release"  ), Ty, itin>;
}

multiclass ATOMIC_STORE_OP_MODELS_TYPES<string misc_op_name, string PatFragName>
{
  defm NAME # 8   : ATOMIC_STORE_OP_MODELS<!strconcat(misc_op_name, "8"  ), !strconcat(PatFragName, "8"  ), i32>;
  defm NAME # 16  : ATOMIC_STORE_OP_MODELS<!strconcat(misc_op_name, "16" ), !strconcat(PatFragName, "16" ), i32>;
  defm NAME # 32  : ATOMIC_STORE_OP_MODELS<!strconcat(misc_op_name, "32" ), !strconcat(PatFragName, "32" ), i32>;
  defm NAME # 64  : ATOMIC_STORE_OP_MODELS<!strconcat(misc_op_name, "64" ), !strconcat(PatFragName, "64" ), i64>;
  defm NAME # 128 : ATOMIC_STORE_OP_MODELS<!strconcat(misc_op_name, "128"), !strconcat(PatFragName, "128"), i128>;
}

defm ST_ADD_I : ATOMIC_STORE_OP_MODELS_TYPES<"st_add_u", "atomic_load_add_i">;
defm ST_MIN_I : ATOMIC_STORE_OP_MODELS_TYPES<"st_min_i", "atomic_load_min_i">;
defm ST_MAX_I : ATOMIC_STORE_OP_MODELS_TYPES<"st_max_i", "atomic_load_max_i">;
defm ST_AND_U : ATOMIC_STORE_OP_MODELS_TYPES<"st_and_u", "atomic_load_and_i">;
defm ST_OR_U  : ATOMIC_STORE_OP_MODELS_TYPES<"st_or_u",  "atomic_load_or_i">;
defm ST_XOR_U : ATOMIC_STORE_OP_MODELS_TYPES<"st_xor_u", "atomic_load_xor_i">;
defm ST_MIN_U : ATOMIC_STORE_OP_MODELS_TYPES<"st_min_u", "atomic_load_umin_i">;
defm ST_MAX_U : ATOMIC_STORE_OP_MODELS_TYPES<"st_max_u", "atomic_load_umax_i">;
