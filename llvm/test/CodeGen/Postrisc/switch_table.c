// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_switch_table
// jumptable usage
int test_switch_table(int c)
{
// CHECK: ldafr	%r2, %pcfwd(.LJTI0_0)
// CHECK: ldwsx	%r1, %r2, %r1, 2, 0
// CHECK: jmpr	%r1, %r2, 0
  switch(c) {
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
