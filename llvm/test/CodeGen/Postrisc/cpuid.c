// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_cpuid
i64 test_cpuid(i64 index)
{
  i64 res = 0;
  // CHECK: cpuid %r2, %r1, 33
  res += __builtin_postrisc_cpuid(index+33);
  // CHECK: cpuid %r3, %r1
  res += __builtin_postrisc_cpuid(index);
  // CHECK: add_imm_i64 %r1, %r1, 10000
  // CHECK: cpuid %r1, %r1, 0
  res += __builtin_postrisc_cpuid(index+10000);
  return res;
}
