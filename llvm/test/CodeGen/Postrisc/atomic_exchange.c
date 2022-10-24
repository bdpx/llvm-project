// RUN: clang %cflags %s | FileCheck %s
// REQUIRES: postrisc-registered-target

#include "common.h"

/*
Built-in Function: type __atomic_exchange_n (type *ptr, type val, int memorder)
  This built-in function implements an atomic exchange operation.
  It writes val into *ptr, and returns the previous contents of *ptr.
  All memory order variants are valid.

Built-in Function: void __atomic_exchange (type *ptr, type *val, type *ret, int memorder)
  This is the generic version of an atomic exchange. It stores the contents of *val into *ptr.
  The original value of *ptr is copied into *ret.
*/

// CHECK-LABEL: @test_atomic_exchange_i8
i8 test_atomic_exchange_i8(i8 value,
  i8 *a, i8 *b, i8 *c, i8 *d, i8 *e, i8 *f) {
  // CHECK: amx_swap_u8 %r1, %r2, %r1
  value = __atomic_exchange_n(a, value, __ATOMIC_RELAXED);
  // CHECK: amq_swap_u8 %r1, %r2, %r1
  value = __atomic_exchange_n(a, value, __ATOMIC_CONSUME);
  // CHECK: amq_swap_u8 %r1, %r2, %r1
  value = __atomic_exchange_n(a, value, __ATOMIC_ACQUIRE);
  // CHECK: amr_swap_u8 %r1, %r2, %r1
  value = __atomic_exchange_n(a, value, __ATOMIC_RELEASE);
  // CHECK: amz_swap_u8 %r1, %r2, %r1
  value = __atomic_exchange_n(a, value, __ATOMIC_ACQ_REL);
  // CHECK: fence_sc
  // CHECK: amx_swap_u8 %r1, %r2, %r1
  value = __atomic_exchange_n(a, value, __ATOMIC_SEQ_CST);
  return value;
}

// CHECK-LABEL: @test_atomic_exchange_i16
i16 test_atomic_exchange_i16(i16 value,
  i16 *a, i16 *b, i16 *c, i16 *d, i16 *e, i16 *f) {
  // CHECK: amx_swap_u16 %r1, %r2, %r1
  value = __atomic_exchange_n(a, value, __ATOMIC_RELAXED);
  // CHECK: amq_swap_u16 %r1, %r2, %r1
  value = __atomic_exchange_n(a, value, __ATOMIC_CONSUME);
  // CHECK: amq_swap_u16 %r1, %r2, %r1
  value = __atomic_exchange_n(a, value, __ATOMIC_ACQUIRE);
  // CHECK: amr_swap_u16 %r1, %r2, %r1
  value = __atomic_exchange_n(a, value, __ATOMIC_RELEASE);
  // CHECK: amz_swap_u16 %r1, %r2, %r1
  value = __atomic_exchange_n(a, value, __ATOMIC_ACQ_REL);
  // CHECK: fence_sc
  // CHECK: amx_swap_u16 %r1, %r2, %r1
  value = __atomic_exchange_n(a, value, __ATOMIC_SEQ_CST);
  return value;
}

// CHECK-LABEL: @test_atomic_exchange_i32
i32 test_atomic_exchange_i32(i32 value,
  i32 *a, i32 *b, i32 *c, i32 *d, i32 *e, i32 *f) {
  // CHECK: amx_swap_u32 %r1, %r2, %r1
  value = __atomic_exchange_n(a, value, __ATOMIC_RELAXED);
  // CHECK: amq_swap_u32 %r1, %r2, %r1
  value = __atomic_exchange_n(a, value, __ATOMIC_CONSUME);
  // CHECK: amq_swap_u32 %r1, %r2, %r1
  value = __atomic_exchange_n(a, value, __ATOMIC_ACQUIRE);
  // CHECK: amr_swap_u32 %r1, %r2, %r1
  value = __atomic_exchange_n(a, value, __ATOMIC_RELEASE);
  // CHECK: amz_swap_u32 %r1, %r2, %r1
  value = __atomic_exchange_n(a, value, __ATOMIC_ACQ_REL);
  // CHECK: fence_sc
  // CHECK: amx_swap_u32 %r1, %r2, %r1
  value = __atomic_exchange_n(a, value, __ATOMIC_SEQ_CST);
  return value;
}

// CHECK-LABEL: @test_atomic_exchange_i64
i64 test_atomic_exchange_i64(i64 value,
  i64 *a, i64 *b, i64 *c, i64 *d, i64 *e, i64 *f) {
  // CHECK: amx_swap_u64 %r1, %r2, %r1
  value = __atomic_exchange_n(a, value, __ATOMIC_RELAXED);
  // CHECK: amq_swap_u64 %r1, %r2, %r1
  value = __atomic_exchange_n(a, value, __ATOMIC_CONSUME);
  // CHECK: amq_swap_u64 %r1, %r2, %r1
  value = __atomic_exchange_n(a, value, __ATOMIC_ACQUIRE);
  // CHECK: amr_swap_u64 %r1, %r2, %r1
  value = __atomic_exchange_n(a, value, __ATOMIC_RELEASE);
  // CHECK: amz_swap_u64 %r1, %r2, %r1
  value = __atomic_exchange_n(a, value, __ATOMIC_ACQ_REL);
  // CHECK: fence_sc
  // CHECK: amx_swap_u64 %r1, %r2, %r1
  value = __atomic_exchange_n(a, value, __ATOMIC_SEQ_CST);
  return value;
}

// CHECK-LABEL: @test_atomic_exchange_i128
i128 test_atomic_exchange_i128(i128 value,
  i128 *a, i128 *b, i128 *c, i128 *d, i128 *e, i128 *f) {
  // CHECK: amx_swap_u128 %r1, %r2, %r1
  value = __atomic_exchange_n(a, value, __ATOMIC_RELAXED);
  // CHECK: amq_swap_u128 %r1, %r2, %r1
  value = __atomic_exchange_n(a, value, __ATOMIC_CONSUME);
  // CHECK: amq_swap_u128 %r1, %r2, %r1
  value = __atomic_exchange_n(a, value, __ATOMIC_ACQUIRE);
  // CHECK: amr_swap_u128 %r1, %r2, %r1
  value = __atomic_exchange_n(a, value, __ATOMIC_RELEASE);
  // CHECK: amz_swap_u128 %r1, %r2, %r1
  value = __atomic_exchange_n(a, value, __ATOMIC_ACQ_REL);
  // CHECK: fence_sc
  // CHECK: amx_swap_u128 %r1, %r2, %r1
  value = __atomic_exchange_n(a, value, __ATOMIC_SEQ_CST);
  return value;
}
