// RUN: clang %cflags %s | FileCheck %s
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_atomic_load_op_i16
i16 test_atomic_load_op_i16(i16 value,
  i16 *a, i16 *b, i16 *c, i16 *d, i16 *e, i16 *f) {

  // CHECK: amx_ld_add_u16 %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELAXED);
  // CHECK: sub_i32 %r1, %gz, %r1
  // CHECK: amx_ld_add_u16 %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELAXED);
  // CHECK: amx_ld_and_u16 %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELAXED);
  // CHECK: amx_ld_or_u16 %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELAXED);
  // CHECK: amx_ld_xor_u16 %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELAXED);
  // CHECK: amx_ld_min_i16 %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELAXED);
  // CHECK: amx_ld_max_i16 %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELAXED);


  // CHECK: amq_ld_add_u16 %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_CONSUME);
  // CHECK: sub_i32 %r1, %gz, %r1
  // CHECK: amq_ld_add_u16 %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_CONSUME);
  // CHECK: amq_ld_and_u16 %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_CONSUME);
  // CHECK: amq_ld_or_u16 %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_CONSUME);
  // CHECK: amq_ld_xor_u16 %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_CONSUME);
  // CHECK: amq_ld_min_i16 %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_CONSUME);
  // CHECK: amq_ld_max_i16 %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_CONSUME);

  // CHECK: amq_ld_add_u16 %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQUIRE);
  // CHECK: sub_i32 %r1, %gz, %r1
  // CHECK: amq_ld_add_u16 %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQUIRE);
  // CHECK: amq_ld_and_u16 %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQUIRE);
  // CHECK: amq_ld_or_u16 %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQUIRE);
  // CHECK: amq_ld_xor_u16 %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQUIRE);
  // CHECK: amq_ld_min_i16 %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQUIRE);
  // CHECK: amq_ld_max_i16 %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQUIRE);


  // CHECK: amr_ld_add_u16 %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELEASE);
  // CHECK: sub_i32 %r1, %gz, %r1
  // CHECK: amr_ld_add_u16 %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELEASE);
  // CHECK: amr_ld_and_u16 %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELEASE);
  // CHECK: amr_ld_or_u16 %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELEASE);
  // CHECK: amr_ld_xor_u16 %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELEASE);
  // CHECK: amr_ld_min_i16 %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELEASE);
  // CHECK: amr_ld_max_i16 %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELEASE);


  // CHECK: amz_ld_add_u16 %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQ_REL);
  // CHECK: sub_i32 %r1, %gz, %r1
  // CHECK: amz_ld_add_u16 %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQ_REL);
  // CHECK: amz_ld_and_u16 %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQ_REL);
  // CHECK: amz_ld_or_u16 %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQ_REL);
  // CHECK: amz_ld_xor_u16 %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQ_REL);
  // CHECK: amz_ld_min_i16 %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQ_REL);
  // CHECK: amz_ld_max_i16 %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQ_REL);


  // CHECK: fence_sc
  // CHECK: amx_ld_add_u16 %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence_sc
  // CHECK: sub_i32 %r1, %gz, %r1
  // CHECK: amx_ld_add_u16 %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence_sc
  // CHECK: amx_ld_and_u16 %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence_sc
  // CHECK: amx_ld_or_u16 %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence_sc
  // CHECK: amx_ld_xor_u16 %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence_sc
  // CHECK: amx_ld_min_i16 %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence_sc
  // CHECK: amx_ld_max_i16 %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_SEQ_CST);

  return value;
}

// CHECK-LABEL: @test_atomic_load_op_u16
u16 test_atomic_load_op_u16(u16 value,
  u16 *a, u16 *b, u16 *c, u16 *d, u16 *e, u16 *f) {
  // CHECK: amx_ld_add_u16 %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELAXED);
  // CHECK: sub_i32 %r1, %gz, %r1
  // CHECK: amx_ld_add_u16 %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELAXED);
  // CHECK: amx_ld_and_u16 %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELAXED);
  // CHECK: amx_ld_or_u16 %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELAXED);
  // CHECK: amx_ld_xor_u16 %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELAXED);
  // CHECK: amx_ld_min_u16 %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELAXED);
  // CHECK: amx_ld_max_u16 %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELAXED);


  // CHECK: amq_ld_add_u16 %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_CONSUME);
  // CHECK: sub_i32 %r1, %gz, %r1
  // CHECK: amq_ld_add_u16 %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_CONSUME);
  // CHECK: amq_ld_and_u16 %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_CONSUME);
  // CHECK: amq_ld_or_u16 %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_CONSUME);
  // CHECK: amq_ld_xor_u16 %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_CONSUME);
  // CHECK: amq_ld_min_u16 %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_CONSUME);
  // CHECK: amq_ld_max_u16 %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_CONSUME);

  // CHECK: amq_ld_add_u16 %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQUIRE);
  // CHECK: sub_i32 %r1, %gz, %r1
  // CHECK: amq_ld_add_u16 %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQUIRE);
  // CHECK: amq_ld_and_u16 %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQUIRE);
  // CHECK: amq_ld_or_u16 %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQUIRE);
  // CHECK: amq_ld_xor_u16 %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQUIRE);
  // CHECK: amq_ld_min_u16 %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQUIRE);
  // CHECK: amq_ld_max_u16 %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQUIRE);


  // CHECK: amr_ld_add_u16 %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELEASE);
  // CHECK: sub_i32 %r1, %gz, %r1
  // CHECK: amr_ld_add_u16 %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELEASE);
  // CHECK: amr_ld_and_u16 %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELEASE);
  // CHECK: amr_ld_or_u16 %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELEASE);
  // CHECK: amr_ld_xor_u16 %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELEASE);
  // CHECK: amr_ld_min_u16 %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELEASE);
  // CHECK: amr_ld_max_u16 %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELEASE);


  // CHECK: amz_ld_add_u16 %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQ_REL);
  // CHECK: sub_i32 %r1, %gz, %r1
  // CHECK: amz_ld_add_u16 %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQ_REL);
  // CHECK: amz_ld_and_u16 %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQ_REL);
  // CHECK: amz_ld_or_u16 %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQ_REL);
  // CHECK: amz_ld_xor_u16 %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQ_REL);
  // CHECK: amz_ld_min_u16 %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQ_REL);
  // CHECK: amz_ld_max_u16 %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQ_REL);


  // CHECK: fence_sc
  // CHECK: amx_ld_add_u16 %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence_sc
  // CHECK: sub_i32 %r1, %gz, %r1
  // CHECK: amx_ld_add_u16 %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence_sc
  // CHECK: amx_ld_and_u16 %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence_sc
  // CHECK: amx_ld_or_u16 %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence_sc
  // CHECK: amx_ld_xor_u16 %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence_sc
  // CHECK: amx_ld_min_u16 %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence_sc
  // CHECK: amx_ld_max_u16 %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_SEQ_CST);

  return value;
}
