// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_crc32c
u32 test_crc32c(u32 prev, i128 data, u64 len)
{
  // CHECK: crc32c %r1, %r1, %r2, %r3
  return __builtin_postrisc_crc32c(prev, data, len);
}
