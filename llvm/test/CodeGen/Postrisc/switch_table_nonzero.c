// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target
// -print-after-all

#include "common.h"

// FIXME: currently table index is i64 only, see getJumpTableRegTy

// CHECK-LABEL: @test_switch_table_nonzero_i64
// jumptable usage
int test_switch_table_nonzero_i64(i64 c)
{
// CHECK: alloc.sp 5, 16
// CHECK: addi %r1, %r1, -10
// CHECK: bui.ge.d %r1, 6, .LBB
// CHECK: ca.rf %r2, %pcfwd(.LJTI0_0)
// CHECK: jmp.t %r2, %r1
  switch (c) {
  case 10:
    printf("case 10 %lld", c+1);
    break;
  case 11:
    printf("case 11 %lld %lld", c+1, c&122);
    break;
  case 12:
    printf("case 12 %lld %lld", c+1, c|2);
    break;
  case 13:
    printf("case 13 %lld %lld", c+1, c^2);
    break;
  case 14:
    printf("case 14 %lld %lld", c+1, c*2);
    break;
  case 15:
    printf("case 15 %lld %lld", c+1, c+22);
    break;
  default: return 0;
  }
  return 0;
}

// CHECK-LABEL: @test_switch_table_nonzero_i32
// jumptable usage
int test_switch_table_nonzero_i32(i32 c)
{
// CHECK: alloc.sp 5, 16
// CHECK: addi.ws %r2, %r1, -10
// CHECK: bui.ge.w %r2, 6, .LBB
// FIXME: addi.wz - merge or remove
// CHECK: addi.wz %r1, %r1, -10
// CHECK: ca.rf %r2, %pcfwd(.LJTI1_0)
// CHECK: jmp.t %r2, %r1
  switch (c) {
  case 10:
    printf("case 10 %d", c+1);
    break;
  case 11:
    printf("case 11 %d %d", c+1, c&122);
    break;
  case 12:
    printf("case 12 %d %d", c+1, c|2);
    break;
  case 13:
    printf("case 13 %d %d", c+1, c^2);
    break;
  case 14:
    printf("case 14 %d %d", c+1, c*2);
    break;
  case 15:
    printf("case 15 %d %d", c+1, c+22);
    break;
  default: return 0;
  }
  return 0;
}

// CHECK-LABEL: @test_switch_table_nonzero_u32
// jumptable usage
int test_switch_table_nonzero_u32(u32 c)
{
// CHECK: alloc.sp 5, 16
// CHECK: addi.ws %r2, %r1, -10
// CHECK: bui.ge.w %r2, 6, .LBB
// FIXME: addi.wz - merge or remove
// CHECK: addi.wz %r1, %r1, -10
// CHECK: ca.rf %r2, %pcfwd(.LJTI2_0)
// CHECK: jmp.t %r2, %r1
  switch (c) {
  case 10:
    printf("case 10 %u", c+1);
    break;
  case 11:
    printf("case 11 %u %u", c+1, c&122);
    break;
  case 12:
    printf("case 12 %u %u", c+1, c|2);
    break;
  case 13:
    printf("case 13 %u %du", c+1, c^2);
    break;
  case 14:
    printf("case 14 %u %u", c+1, c*2);
    break;
  case 15:
    printf("case 15 %u %u", c+1, c+22);
    break;
  default: return 0;
  }
  return 0;
}
