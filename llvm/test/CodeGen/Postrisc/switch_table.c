// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target
// -print-after-all

#include "common.h"

// FIXME: currently table index is i64 only, see getJumpTableRegTy

// CHECK-LABEL: @test_switch_table_i64
// jumptable usage
int test_switch_table_i64(i64 c)
{
// check for c not in 0,1,2,3,4,5
// CHECK: alloc_sp 5, 16
// CHECK: br_ge_imm_u64 %r1, 6, .LBB
// CHECK: lda_iprel %r2, %pcfwd(.LJTI0_0)
// CHECK: jmp_t %r2, %r1
  switch (c) {
  case 0:
    printf("case 0 %lld", c+1);
    break;
  case 1:
    printf("case 1 %lld %lld", c+1, c&122);
    break;
  case 2:
    printf("case 2 %lld %lld", c+1, c|2);
    break;
  case 3:
    printf("case 3 %lld %lld", c+1, c^2);
    break;
  case 4:
    printf("case 4 %lld %lld", c+1, c*2);
    break;
  case 5:
    printf("case 5 %lld %lld", c+1, c+22);
    break;
  default: return 0;
  }
  return 0;
}

// CHECK-LABEL: @test_switch_table_i32
// jumptable usage
int test_switch_table_i32(i32 c)
{
// check for c not in 0,1,2,3,4,5
// CHECK: alloc_sp 5, 16
// CHECK: br_ge_imm_u32 %r1, 6, .LBB
// zero extend c to i64
// CHECK: zext_i32 %r1, %r1
// CHECK: lda_iprel %r2, %pcfwd(.LJTI1_0)
// CHECK: jmp_t %r2, %r1
  switch (c) {
  case 0:
    printf("case 0 %d", c+1);
    break;
  case 1:
    printf("case 1 %d %d", c+1, c&122);
    break;
  case 2:
    printf("case 2 %d %d", c+1, c|2);
    break;
  case 3:
    printf("case 3 %d %d", c+1, c^2);
    break;
  case 4:
    printf("case 4 %d %d", c+1, c*2);
    break;
  case 5:
    printf("case 5 %d %d", c+1, c+22);
    break;
  default: return 0;
  }
  return 0;
}

// CHECK-LABEL: @test_switch_table_u32
// jumptable usage
int test_switch_table_u32(u32 c)
{
// check for c not in 0,1,2,3,4,5
// CHECK: alloc_sp 5, 16
// CHECK: br_ge_imm_u32 %r1, 6, .LBB
// CHECK: zext_i32 %r1, %r1
// CHECK: lda_iprel %r2, %pcfwd(.LJTI2_0)
// CHECK: jmp_t %r2, %r1
  switch (c) {
  case 0:
    printf("case 0 %u", c+1);
    break;
  case 1:
    printf("case 1 %u %u", c+1, c&122);
    break;
  case 2:
    printf("case 2 %u %u", c+1, c|2);
    break;
  case 3:
    printf("case 3 %u %du", c+1, c^2);
    break;
  case 4:
    printf("case 4 %u %u", c+1, c*2);
    break;
  case 5:
    printf("case 5 %u %u", c+1, c+22);
    break;
  default: return 0;
  }
  return 0;
}
