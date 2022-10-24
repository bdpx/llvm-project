// RUN: clang %cflags %s | FileCheck %s
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @for_loop
i64 for_loop(i64 len, i64 final, i64 x[]) {
  i64 sum = 0;
  for(i64 i = 0; i < len; ++i) {
    sum += x[i+10];
  }
  return sum + x[final+21];
}

// CHECK-LABEL: @for_loop_32
i32 for_loop_32(i32 len, i32 final, i32 x[]) {
  i32 sum = 0;
  for(i32 i = 0; i < len; ++i) {
    sum += x[i+10];
  }
  return sum + x[final+21];
}


// CHECK-LABEL: @test_rep_lt_i64
void test_rep_lt_i64(int n) {
  for (int i=0; i<n; i++) {
    printf("%d\n", i);
  }
}
