// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

extern i64 stack_array_consumer(i64 *array, i64 size, i64 a, i64 b, i64 c, i64 d);

// CHECK-LABEL: @test_stack_array
i64 test_stack_array(i64 c, i64 b, i64 d)
{
  // CHECK: call
  printf("ccc=%lld\n", c);
  i64 array[c];
  volatile i64 temp = stack_array_consumer(array, c + d + b + 333, c + b, c - b + 44, b + 2 * c, c + 2 * b);
  temp = b + array[0] + temp;
  printf("temp=%lld\n", temp);
  return temp + c;
}
