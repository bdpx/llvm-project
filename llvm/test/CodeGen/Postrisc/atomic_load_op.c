// RUN: clang %cflags %s | FileCheck %s
// REQUIRES: postrisc-registered-target

#include "common.h"

/*
Built-in Function: type __atomic_add_fetch (type *ptr, type val, int memorder)
Built-in Function: type __atomic_sub_fetch (type *ptr, type val, int memorder)
Built-in Function: type __atomic_and_fetch (type *ptr, type val, int memorder)
Built-in Function: type __atomic_xor_fetch (type *ptr, type val, int memorder)
Built-in Function: type __atomic_or_fetch (type *ptr, type val, int memorder)
Built-in Function: type __atomic_nand_fetch (type *ptr, type val, int memorder)
	These built-in functions perform the operation suggested by the name, and return the result of the operation.
	Operations on pointer arguments are performed as if the operands were of the uintptr_t type.
	That is, they are not scaled by the size of the type to which the pointer points.

	{ *ptr op= val; return *ptr; }
	{ *ptr = ~(*ptr & val); return *ptr; } // nand
	The object pointed to by the first argument must be of integer or pointer type.
	It must not be a boolean type. All memory orders are valid.

Built-in Function: type __atomic_fetch_add (type *ptr, type val, int memorder)
Built-in Function: type __atomic_fetch_sub (type *ptr, type val, int memorder)
Built-in Function: type __atomic_fetch_and (type *ptr, type val, int memorder)
Built-in Function: type __atomic_fetch_xor (type *ptr, type val, int memorder)
Built-in Function: type __atomic_fetch_or (type *ptr, type val, int memorder)
Built-in Function: type __atomic_fetch_nand (type *ptr, type val, int memorder)
	These built-in functions perform the operation suggested by the name,
	and return the value that had previously been in *ptr.
	Operations on pointer arguments are performed as if the operands were of the uintptr_t type.
	That is, they are not scaled by the size of the type to which the pointer points.

	{ tmp = *ptr; *ptr op= val; return tmp; }
	{ tmp = *ptr; *ptr = ~(*ptr & val); return tmp; } // nand
	The same constraints on arguments apply as for the corresponding __atomic_op_fetch built-in functions. All memory orders are valid.
*/

// CHECK-LABEL: @test_atomic_load_op_i8
i8 test_atomic_load_op_i8(i8 value,
  i8 *a, i8 *b, i8 *c, i8 *d, i8 *e, i8 *f) {

  // CHECK: ldaddb.relaxed %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELAXED);
  // CHECK: subfiws %r1, %r1, 0
  // CHECK: ldaddb.relaxed %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELAXED);
  // CHECK: ldandb.relaxed %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELAXED);
  // CHECK: ldorb.relaxed %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELAXED);
  // CHECK: ldxorb.relaxed %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELAXED);
  // CHECK: ldsminb.relaxed %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELAXED);
  // CHECK: ldsmaxb.relaxed %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELAXED);


  // CHECK: ldaddb.acquire %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_CONSUME);
  // CHECK: subfiws %r1, %r1, 0
  // CHECK: ldaddb.acquire %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_CONSUME);
  // CHECK: ldandb.acquire %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_CONSUME);
  // CHECK: ldorb.acquire %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_CONSUME);
  // CHECK: ldxorb.acquire %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_CONSUME);
  // CHECK: ldsminb.acquire %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_CONSUME);
  // CHECK: ldsmaxb.acquire %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_CONSUME);

  // CHECK: ldaddb.acquire %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQUIRE);
  // CHECK: subfiws %r1, %r1, 0
  // CHECK: ldaddb.acquire %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ldandb.acquire %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ldorb.acquire %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ldxorb.acquire %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ldsminb.acquire %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ldsmaxb.acquire %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQUIRE);


  // CHECK: ldaddb.release %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELEASE);
  // CHECK: subfiws %r1, %r1, 0
  // CHECK: ldaddb.release %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELEASE);
  // CHECK: ldandb.release %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELEASE);
  // CHECK: ldorb.release %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELEASE);
  // CHECK: ldxorb.release %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELEASE);
  // CHECK: ldsminb.release %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELEASE);
  // CHECK: ldsmaxb.release %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELEASE);


  // CHECK: ldaddb.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQ_REL);
  // CHECK: subfiws %r1, %r1, 0
  // CHECK: ldaddb.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ldandb.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ldorb.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ldxorb.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ldsminb.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ldsmaxb.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQ_REL);


  // CHECK: fence.seq_cst
  // CHECK: ldaddb.relaxed %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: subfiws %r1, %r1, 0
  // CHECK: ldaddb.relaxed %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: ldandb.relaxed %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: ldorb.relaxed %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: ldxorb.relaxed %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: ldsminb.relaxed %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: ldsmaxb.relaxed %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_SEQ_CST);

  return value;
}

// CHECK-LABEL: @test_atomic_load_op_u8
u8 test_atomic_load_op_u8(u8 value,
  u8 *a, u8 *b, u8 *c, u8 *d, u8 *e, u8 *f) {
  // CHECK: ldaddb.relaxed %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELAXED);
  // CHECK: subfiws %r1, %r1, 0
  // CHECK: ldaddb.relaxed %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELAXED);
  // CHECK: ldandb.relaxed %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELAXED);
  // CHECK: ldorb.relaxed %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELAXED);
  // CHECK: ldxorb.relaxed %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELAXED);
  // CHECK: lduminb.relaxed %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELAXED);
  // CHECK: ldumaxb.relaxed %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELAXED);


  // CHECK: ldaddb.acquire %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_CONSUME);
  // CHECK: subfiws %r1, %r1, 0
  // CHECK: ldaddb.acquire %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_CONSUME);
  // CHECK: ldandb.acquire %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_CONSUME);
  // CHECK: ldorb.acquire %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_CONSUME);
  // CHECK: ldxorb.acquire %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_CONSUME);
  // CHECK: lduminb.acquire %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_CONSUME);
  // CHECK: ldumaxb.acquire %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_CONSUME);

  // CHECK: ldaddb.acquire %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQUIRE);
  // CHECK: subfiws %r1, %r1, 0
  // CHECK: ldaddb.acquire %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ldandb.acquire %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ldorb.acquire %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ldxorb.acquire %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQUIRE);
  // CHECK: lduminb.acquire %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ldumaxb.acquire %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQUIRE);


  // CHECK: ldaddb.release %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELEASE);
  // CHECK: subfiws %r1, %r1, 0
  // CHECK: ldaddb.release %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELEASE);
  // CHECK: ldandb.release %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELEASE);
  // CHECK: ldorb.release %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELEASE);
  // CHECK: ldxorb.release %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELEASE);
  // CHECK: lduminb.release %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELEASE);
  // CHECK: ldumaxb.release %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELEASE);


  // CHECK: ldaddb.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQ_REL);
  // CHECK: subfiws %r1, %r1, 0
  // CHECK: ldaddb.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ldandb.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ldorb.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ldxorb.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQ_REL);
  // CHECK: lduminb.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ldumaxb.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQ_REL);


  // CHECK: fence.seq_cst
  // CHECK: ldaddb.relaxed %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: subfiws %r1, %r1, 0
  // CHECK: ldaddb.relaxed %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: ldandb.relaxed %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: ldorb.relaxed %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: ldxorb.relaxed %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: lduminb.relaxed %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: ldumaxb.relaxed %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_SEQ_CST);

  return value;
}

// CHECK-LABEL: @test_atomic_load_op_i16
i16 test_atomic_load_op_i16(i16 value,
  i16 *a, i16 *b, i16 *c, i16 *d, i16 *e, i16 *f) {

  // CHECK: ldaddh.relaxed %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELAXED);
  // CHECK: subfiws %r1, %r1, 0
  // CHECK: ldaddh.relaxed %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELAXED);
  // CHECK: ldandh.relaxed %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELAXED);
  // CHECK: ldorh.relaxed %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELAXED);
  // CHECK: ldxorh.relaxed %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELAXED);
  // CHECK: ldsminh.relaxed %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELAXED);
  // CHECK: ldsmaxh.relaxed %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELAXED);


  // CHECK: ldaddh.acquire %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_CONSUME);
  // CHECK: subfiws %r1, %r1, 0
  // CHECK: ldaddh.acquire %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_CONSUME);
  // CHECK: ldandh.acquire %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_CONSUME);
  // CHECK: ldorh.acquire %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_CONSUME);
  // CHECK: ldxorh.acquire %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_CONSUME);
  // CHECK: ldsminh.acquire %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_CONSUME);
  // CHECK: ldsmaxh.acquire %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_CONSUME);

  // CHECK: ldaddh.acquire %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQUIRE);
  // CHECK: subfiws %r1, %r1, 0
  // CHECK: ldaddh.acquire %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ldandh.acquire %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ldorh.acquire %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ldxorh.acquire %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ldsminh.acquire %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ldsmaxh.acquire %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQUIRE);


  // CHECK: ldaddh.release %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELEASE);
  // CHECK: subfiws %r1, %r1, 0
  // CHECK: ldaddh.release %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELEASE);
  // CHECK: ldandh.release %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELEASE);
  // CHECK: ldorh.release %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELEASE);
  // CHECK: ldxorh.release %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELEASE);
  // CHECK: ldsminh.release %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELEASE);
  // CHECK: ldsmaxh.release %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELEASE);


  // CHECK: ldaddh.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQ_REL);
  // CHECK: subfiws %r1, %r1, 0
  // CHECK: ldaddh.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ldandh.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ldorh.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ldxorh.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ldsminh.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ldsmaxh.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQ_REL);


  // CHECK: fence.seq_cst
  // CHECK: ldaddh.relaxed %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: subfiws %r1, %r1, 0
  // CHECK: ldaddh.relaxed %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: ldandh.relaxed %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: ldorh.relaxed %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: ldxorh.relaxed %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: ldsminh.relaxed %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: ldsmaxh.relaxed %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_SEQ_CST);

  return value;
}

// CHECK-LABEL: @test_atomic_load_op_u16
u16 test_atomic_load_op_u16(u16 value,
  u16 *a, u16 *b, u16 *c, u16 *d, u16 *e, u16 *f) {
  // CHECK: ldaddh.relaxed %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELAXED);
  // CHECK: subfiws %r1, %r1, 0
  // CHECK: ldaddh.relaxed %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELAXED);
  // CHECK: ldandh.relaxed %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELAXED);
  // CHECK: ldorh.relaxed %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELAXED);
  // CHECK: ldxorh.relaxed %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELAXED);
  // CHECK: lduminh.relaxed %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELAXED);
  // CHECK: ldumaxh.relaxed %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELAXED);


  // CHECK: ldaddh.acquire %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_CONSUME);
  // CHECK: subfiws %r1, %r1, 0
  // CHECK: ldaddh.acquire %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_CONSUME);
  // CHECK: ldandh.acquire %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_CONSUME);
  // CHECK: ldorh.acquire %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_CONSUME);
  // CHECK: ldxorh.acquire %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_CONSUME);
  // CHECK: lduminh.acquire %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_CONSUME);
  // CHECK: ldumaxh.acquire %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_CONSUME);

  // CHECK: ldaddh.acquire %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQUIRE);
  // CHECK: subfiws %r1, %r1, 0
  // CHECK: ldaddh.acquire %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ldandh.acquire %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ldorh.acquire %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ldxorh.acquire %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQUIRE);
  // CHECK: lduminh.acquire %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ldumaxh.acquire %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQUIRE);


  // CHECK: ldaddh.release %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELEASE);
  // CHECK: subfiws %r1, %r1, 0
  // CHECK: ldaddh.release %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELEASE);
  // CHECK: ldandh.release %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELEASE);
  // CHECK: ldorh.release %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELEASE);
  // CHECK: ldxorh.release %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELEASE);
  // CHECK: lduminh.release %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELEASE);
  // CHECK: ldumaxh.release %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELEASE);


  // CHECK: ldaddh.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQ_REL);
  // CHECK: subfiws %r1, %r1, 0
  // CHECK: ldaddh.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ldandh.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ldorh.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ldxorh.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQ_REL);
  // CHECK: lduminh.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ldumaxh.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQ_REL);


  // CHECK: fence.seq_cst
  // CHECK: ldaddh.relaxed %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: subfiws %r1, %r1, 0
  // CHECK: ldaddh.relaxed %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: ldandh.relaxed %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: ldorh.relaxed %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: ldxorh.relaxed %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: lduminh.relaxed %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: ldumaxh.relaxed %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_SEQ_CST);

  return value;
}

// CHECK-LABEL: @test_atomic_load_op_i32
i32 test_atomic_load_op_i32(i32 value,
  i32 *a, i32 *b, i32 *c, i32 *d, i32 *e, i32 *f) {

  // CHECK: ldaddw.relaxed %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELAXED);
  // CHECK: subfiws %r1, %r1, 0
  // CHECK: ldaddw.relaxed %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELAXED);
  // CHECK: ldandw.relaxed %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELAXED);
  // CHECK: ldorw.relaxed %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELAXED);
  // CHECK: ldxorw.relaxed %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELAXED);
  // CHECK: ldsminw.relaxed %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELAXED);
  // CHECK: ldsmaxw.relaxed %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELAXED);


  // CHECK: ldaddw.acquire %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_CONSUME);
  // CHECK: subfiws %r1, %r1, 0
  // CHECK: ldaddw.acquire %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_CONSUME);
  // CHECK: ldandw.acquire %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_CONSUME);
  // CHECK: ldorw.acquire %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_CONSUME);
  // CHECK: ldxorw.acquire %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_CONSUME);
  // CHECK: ldsminw.acquire %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_CONSUME);
  // CHECK: ldsmaxw.acquire %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_CONSUME);

  // CHECK: ldaddw.acquire %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQUIRE);
  // CHECK: subfiws %r1, %r1, 0
  // CHECK: ldaddw.acquire %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ldandw.acquire %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ldorw.acquire %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ldxorw.acquire %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ldsminw.acquire %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ldsmaxw.acquire %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQUIRE);


  // CHECK: ldaddw.release %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELEASE);
  // CHECK: subfiws %r1, %r1, 0
  // CHECK: ldaddw.release %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELEASE);
  // CHECK: ldandw.release %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELEASE);
  // CHECK: ldorw.release %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELEASE);
  // CHECK: ldxorw.release %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELEASE);
  // CHECK: ldsminw.release %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELEASE);
  // CHECK: ldsmaxw.release %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELEASE);


  // CHECK: ldaddw.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQ_REL);
  // CHECK: subfiws %r1, %r1, 0
  // CHECK: ldaddw.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ldandw.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ldorw.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ldxorw.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ldsminw.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ldsmaxw.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQ_REL);


  // CHECK: fence.seq_cst
  // CHECK: ldaddw.relaxed %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: subfiws %r1, %r1, 0
  // CHECK: ldaddw.relaxed %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: ldandw.relaxed %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: ldorw.relaxed %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: ldxorw.relaxed %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: ldsminw.relaxed %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: ldsmaxw.relaxed %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_SEQ_CST);

  return value;
}

// CHECK-LABEL: @test_atomic_load_op_u32
u32 test_atomic_load_op_u32(u32 value,
  u32 *a, u32 *b, u32 *c, u32 *d, u32 *e, u32 *f) {

  // CHECK: ldaddw.relaxed %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELAXED);
  // CHECK: subfiws %r1, %r1, 0
  // CHECK: ldaddw.relaxed %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELAXED);
  // CHECK: ldandw.relaxed %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELAXED);
  // CHECK: ldorw.relaxed %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELAXED);
  // CHECK: ldxorw.relaxed %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELAXED);
  // CHECK: lduminw.relaxed %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELAXED);
  // CHECK: ldumaxw.relaxed %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELAXED);


  // CHECK: ldaddw.acquire %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_CONSUME);
  // CHECK: subfiws %r1, %r1, 0
  // CHECK: ldaddw.acquire %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_CONSUME);
  // CHECK: ldandw.acquire %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_CONSUME);
  // CHECK: ldorw.acquire %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_CONSUME);
  // CHECK: ldxorw.acquire %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_CONSUME);
  // CHECK: lduminw.acquire %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_CONSUME);
  // CHECK: ldumaxw.acquire %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_CONSUME);

  // CHECK: ldaddw.acquire %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQUIRE);
  // CHECK: subfiws %r1, %r1, 0
  // CHECK: ldaddw.acquire %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ldandw.acquire %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ldorw.acquire %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ldxorw.acquire %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQUIRE);
  // CHECK: lduminw.acquire %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ldumaxw.acquire %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQUIRE);


  // CHECK: ldaddw.release %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELEASE);
  // CHECK: subfiws %r1, %r1, 0
  // CHECK: ldaddw.release %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELEASE);
  // CHECK: ldandw.release %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELEASE);
  // CHECK: ldorw.release %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELEASE);
  // CHECK: ldxorw.release %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELEASE);
  // CHECK: lduminw.release %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELEASE);
  // CHECK: ldumaxw.release %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELEASE);


  // CHECK: ldaddw.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQ_REL);
  // CHECK: subfiws %r1, %r1, 0
  // CHECK: ldaddw.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ldandw.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ldorw.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ldxorw.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQ_REL);
  // CHECK: lduminw.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ldumaxw.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQ_REL);


  // CHECK: fence.seq_cst
  // CHECK: ldaddw.relaxed %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: subfiws %r1, %r1, 0
  // CHECK: ldaddw.relaxed %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: ldandw.relaxed %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: ldorw.relaxed %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: ldxorw.relaxed %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: lduminw.relaxed %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: ldumaxw.relaxed %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_SEQ_CST);

  return value;
}

// CHECK-LABEL: @test_atomic_load_op_i64
i64 test_atomic_load_op_i64(i64 value,
  i64 *a, i64 *b, i64 *c, i64 *d, i64 *e, i64 *f) {

  // CHECK: ldaddd.relaxed %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELAXED);
  // CHECK: subfi   %r1, %r1, 0
  // CHECK: ldaddd.relaxed %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELAXED);
  // CHECK: ldandd.relaxed %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELAXED);
  // CHECK: ldord.relaxed %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELAXED);
  // CHECK: ldxord.relaxed %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELAXED);
  // CHECK: ldsmind.relaxed %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELAXED);
  // CHECK: ldsmaxd.relaxed %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELAXED);


  // CHECK: ldaddd.acquire %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_CONSUME);
  // CHECK: subfi   %r1, %r1, 0
  // CHECK: ldaddd.acquire %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_CONSUME);
  // CHECK: ldandd.acquire %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_CONSUME);
  // CHECK: ldord.acquire %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_CONSUME);
  // CHECK: ldxord.acquire %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_CONSUME);
  // CHECK: ldsmind.acquire %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_CONSUME);
  // CHECK: ldsmaxd.acquire %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_CONSUME);

  // CHECK: ldaddd.acquire %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQUIRE);
  // CHECK: subfi   %r1, %r1, 0
  // CHECK: ldaddd.acquire %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ldandd.acquire %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ldord.acquire %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ldxord.acquire %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ldsmind.acquire %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ldsmaxd.acquire %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQUIRE);


  // CHECK: ldaddd.release %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELEASE);
  // CHECK: subfi   %r1, %r1, 0
  // CHECK: ldaddd.release %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELEASE);
  // CHECK: ldandd.release %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELEASE);
  // CHECK: ldord.release %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELEASE);
  // CHECK: ldxord.release %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELEASE);
  // CHECK: ldsmind.release %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELEASE);
  // CHECK: ldsmaxd.release %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELEASE);


  // CHECK: ldaddd.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQ_REL);
  // CHECK: subfi   %r1, %r1, 0
  // CHECK: ldaddd.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ldandd.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ldord.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ldxord.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ldsmind.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ldsmaxd.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQ_REL);


  // CHECK: fence.seq_cst
  // CHECK: ldaddd.relaxed %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: subfi   %r1, %r1, 0
  // CHECK: ldaddd.relaxed %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: ldandd.relaxed %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: ldord.relaxed %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: ldxord.relaxed %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: ldsmind.relaxed %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: ldsmaxd.relaxed %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_SEQ_CST);

  return value;
}

// CHECK-LABEL: @test_atomic_load_op_u64
u64 test_atomic_load_op_u64(u64 value,
  u64 *a, u64 *b, u64 *c, u64 *d, u64 *e, u64 *f) {
  // CHECK: ldaddd.relaxed %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELAXED);
  // CHECK: subfi   %r1, %r1, 0
  // CHECK: ldaddd.relaxed %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELAXED);
  // CHECK: ldandd.relaxed %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELAXED);
  // CHECK: ldord.relaxed %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELAXED);
  // CHECK: ldxord.relaxed %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELAXED);
  // CHECK: ldumind.relaxed %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELAXED);
  // CHECK: ldumaxd.relaxed %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELAXED);


  // CHECK: ldaddd.acquire %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_CONSUME);
  // CHECK: subfi   %r1, %r1, 0
  // CHECK: ldaddd.acquire %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_CONSUME);
  // CHECK: ldandd.acquire %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_CONSUME);
  // CHECK: ldord.acquire %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_CONSUME);
  // CHECK: ldxord.acquire %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_CONSUME);
  // CHECK: ldumind.acquire %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_CONSUME);
  // CHECK: ldumaxd.acquire %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_CONSUME);

  // CHECK: ldaddd.acquire %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQUIRE);
  // CHECK: subfi   %r1, %r1, 0
  // CHECK: ldaddd.acquire %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ldandd.acquire %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ldord.acquire %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ldxord.acquire %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ldumind.acquire %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ldumaxd.acquire %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQUIRE);


  // CHECK: ldaddd.release %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELEASE);
  // CHECK: subfi   %r1, %r1, 0
  // CHECK: ldaddd.release %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELEASE);
  // CHECK: ldandd.release %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELEASE);
  // CHECK: ldord.release %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELEASE);
  // CHECK: ldxord.release %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELEASE);
  // CHECK: ldumind.release %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELEASE);
  // CHECK: ldumaxd.release %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELEASE);


  // CHECK: ldaddd.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQ_REL);
  // CHECK: subfi   %r1, %r1, 0
  // CHECK: ldaddd.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ldandd.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ldord.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ldxord.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ldumind.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ldumaxd.acq_rel %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQ_REL);


  // CHECK: fence.seq_cst
  // CHECK: ldaddd.relaxed %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: subfi   %r1, %r1, 0
  // CHECK: ldaddd.relaxed %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: ldandd.relaxed %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: ldord.relaxed %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: ldxord.relaxed %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: ldumind.relaxed %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.seq_cst
  // CHECK: ldumaxd.relaxed %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_SEQ_CST);

  return value;
}
