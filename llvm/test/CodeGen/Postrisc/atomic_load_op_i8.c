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

  // CHECK: amx_ld_add_u8 %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELAXED);
  // CHECK: sub_i32 %r1, %gz, %r1
  // CHECK: amx_ld_add_u8 %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELAXED);
  // CHECK: amx_ld_and_u8 %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELAXED);
  // CHECK: amx_ld_or_u8 %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELAXED);
  // CHECK: amx_ld_xor_u8 %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELAXED);
  // CHECK: amx_ld_min_i8 %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELAXED);
  // CHECK: amx_ld_max_i8 %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELAXED);


  // CHECK: amq_ld_add_u8 %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_CONSUME);
  // CHECK: sub_i32 %r1, %gz, %r1
  // CHECK: amq_ld_add_u8 %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_CONSUME);
  // CHECK: amq_ld_and_u8 %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_CONSUME);
  // CHECK: amq_ld_or_u8 %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_CONSUME);
  // CHECK: amq_ld_xor_u8 %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_CONSUME);
  // CHECK: amq_ld_min_i8 %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_CONSUME);
  // CHECK: amq_ld_max_i8 %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_CONSUME);

  // CHECK: amq_ld_add_u8 %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQUIRE);
  // CHECK: sub_i32 %r1, %gz, %r1
  // CHECK: amq_ld_add_u8 %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQUIRE);
  // CHECK: amq_ld_and_u8 %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQUIRE);
  // CHECK: amq_ld_or_u8 %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQUIRE);
  // CHECK: amq_ld_xor_u8 %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQUIRE);
  // CHECK: amq_ld_min_i8 %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQUIRE);
  // CHECK: amq_ld_max_i8 %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQUIRE);


  // CHECK: amr_ld_add_u8 %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELEASE);
  // CHECK: sub_i32 %r1, %gz, %r1
  // CHECK: amr_ld_add_u8 %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELEASE);
  // CHECK: amr_ld_and_u8 %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELEASE);
  // CHECK: amr_ld_or_u8 %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELEASE);
  // CHECK: amr_ld_xor_u8 %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELEASE);
  // CHECK: amr_ld_min_i8 %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELEASE);
  // CHECK: amr_ld_max_i8 %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELEASE);


  // CHECK: amz_ld_add_u8 %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQ_REL);
  // CHECK: sub_i32 %r1, %gz, %r1
  // CHECK: amz_ld_add_u8 %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQ_REL);
  // CHECK: amz_ld_and_u8 %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQ_REL);
  // CHECK: amz_ld_or_u8 %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQ_REL);
  // CHECK: amz_ld_xor_u8 %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQ_REL);
  // CHECK: amz_ld_min_i8 %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQ_REL);
  // CHECK: amz_ld_max_i8 %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQ_REL);


  // CHECK: fence_sc
  // CHECK: amx_ld_add_u8 %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence_sc
  // CHECK: sub_i32 %r1, %gz, %r1
  // CHECK: amx_ld_add_u8 %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence_sc
  // CHECK: amx_ld_and_u8 %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence_sc
  // CHECK: amx_ld_or_u8 %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence_sc
  // CHECK: amx_ld_xor_u8 %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence_sc
  // CHECK: amx_ld_min_i8 %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence_sc
  // CHECK: amx_ld_max_i8 %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_SEQ_CST);

  return value;
}

// CHECK-LABEL: @test_atomic_load_op_u8
u8 test_atomic_load_op_u8(u8 value,
  u8 *a, u8 *b, u8 *c, u8 *d, u8 *e, u8 *f) {
  // CHECK: amx_ld_add_u8 %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELAXED);
  // CHECK: sub_i32 %r1, %gz, %r1
  // CHECK: amx_ld_add_u8 %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELAXED);
  // CHECK: amx_ld_and_u8 %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELAXED);
  // CHECK: amx_ld_or_u8 %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELAXED);
  // CHECK: amx_ld_xor_u8 %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELAXED);
  // CHECK: amx_ld_min_u8 %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELAXED);
  // CHECK: amx_ld_max_u8 %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELAXED);


  // CHECK: amq_ld_add_u8 %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_CONSUME);
  // CHECK: sub_i32 %r1, %gz, %r1
  // CHECK: amq_ld_add_u8 %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_CONSUME);
  // CHECK: amq_ld_and_u8 %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_CONSUME);
  // CHECK: amq_ld_or_u8 %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_CONSUME);
  // CHECK: amq_ld_xor_u8 %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_CONSUME);
  // CHECK: amq_ld_min_u8 %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_CONSUME);
  // CHECK: amq_ld_max_u8 %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_CONSUME);

  // CHECK: amq_ld_add_u8 %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQUIRE);
  // CHECK: sub_i32 %r1, %gz, %r1
  // CHECK: amq_ld_add_u8 %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQUIRE);
  // CHECK: amq_ld_and_u8 %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQUIRE);
  // CHECK: amq_ld_or_u8 %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQUIRE);
  // CHECK: amq_ld_xor_u8 %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQUIRE);
  // CHECK: amq_ld_min_u8 %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQUIRE);
  // CHECK: amq_ld_max_u8 %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQUIRE);


  // CHECK: amr_ld_add_u8 %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELEASE);
  // CHECK: sub_i32 %r1, %gz, %r1
  // CHECK: amr_ld_add_u8 %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELEASE);
  // CHECK: amr_ld_and_u8 %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELEASE);
  // CHECK: amr_ld_or_u8 %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELEASE);
  // CHECK: amr_ld_xor_u8 %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELEASE);
  // CHECK: amr_ld_min_u8 %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELEASE);
  // CHECK: amr_ld_max_u8 %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELEASE);


  // CHECK: amz_ld_add_u8 %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQ_REL);
  // CHECK: sub_i32 %r1, %gz, %r1
  // CHECK: amz_ld_add_u8 %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQ_REL);
  // CHECK: amz_ld_and_u8 %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQ_REL);
  // CHECK: amz_ld_or_u8 %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQ_REL);
  // CHECK: amz_ld_xor_u8 %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQ_REL);
  // CHECK: amz_ld_min_u8 %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQ_REL);
  // CHECK: amz_ld_max_u8 %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQ_REL);


  // CHECK: fence_sc
  // CHECK: amx_ld_add_u8 %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence_sc
  // CHECK: sub_i32 %r1, %gz, %r1
  // CHECK: amx_ld_add_u8 %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence_sc
  // CHECK: amx_ld_and_u8 %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence_sc
  // CHECK: amx_ld_or_u8 %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence_sc
  // CHECK: amx_ld_xor_u8 %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence_sc
  // CHECK: amx_ld_min_u8 %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence_sc
  // CHECK: amx_ld_max_u8 %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_SEQ_CST);

  return value;
}
