// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_immediate_i32
// CHECK: ld_imm %r1, -123456789
i32 test_immediate_i32(void) {
  return -123456789;
}

// CHECK-LABEL: @test_immediate_u32
// CHECK: ld_imm %r1, 123456789
u32 test_immediate_u32(void) {
  return 123456789;
}

// CHECK-LABEL: @test_immediate_i32_long
// CHECK: ld_imm.l %r1, -1234567890
i32 test_immediate_i32_long(void) {
  return -1234567890;
}

// CHECK-LABEL: @test_immediate_u32_long
// CHECK: ld_imm.l %r1, 1234567890
u32 test_immediate_u32_long(void) {
  return 1234567890;
}






// CHECK-LABEL: @test_immediate_i64
// CHECK: ld_imm %r1, -12345678
i64 test_immediate_i64(void) {
  return -12345678;
}

// CHECK-LABEL: @test_immediate_u64
// CHECK: ld_imm %r1, 12345678
u64 test_immediate_u64(void) {
  return 12345678;
}

// CHECK-LABEL: @test_immediate_i64_long
// CHECK: ld_imm.l %r1, -1234567890123
i64 test_immediate_i64_long(void) {
  return -1234567890123;
}

// CHECK-LABEL: @test_immediate_u64_long
// CHECK: ld_imm.l %r1, 1234567890123
u64 test_immediate_u64_long(void) {
  return 1234567890123;
}

// CHECK-LABEL: @test_immediate_size_max
// CHECK: ld_imm.l %r1, 9223372036854775807
u64 test_immediate_size_max(void) {
  return 0xffffffffffffffffu / 2;
}
