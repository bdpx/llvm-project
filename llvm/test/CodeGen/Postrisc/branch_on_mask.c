// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_ball
i64 test_ball(i64 a)
{
  // CHECK: call.r
  i64 ret = a;
  if ((a & 2000) != 2000) {
      ret += 2000;
      printf("%lld", ret);
  }
  if ((a & (256|512|1024)) == (256|512|1024)) {
    ret += 5000;
    printf("%lld", ret);
  }
  if ((a & (1024|512)) != 0) {
    ret += 3000;
    printf("%lld", ret);
  }
  if ((a & (64|128|256)) == 0) {
    ret += 4000;
    printf("%lld", ret);
  }
  return ret;
}
