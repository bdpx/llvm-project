// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_nullification
i64 test_nullification(i64 a, i64 b[], i64 c[])
{
  i64 ret = a;
  if (a < b[2]) {
    ret += 5 * b[a+1];
    ret += 2000;
  } else {
    ret += 3 * c[a+2];
    b[a] = 0;
    ret += 3000;
  }
  // printf("ret=%lld\n", ret);
  ret += c[a+5];
  return ret;
}
