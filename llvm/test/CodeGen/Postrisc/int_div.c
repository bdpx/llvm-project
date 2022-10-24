// RUN: clang %cflags %s | FileCheck %s
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_div_i32
// CHECK: div_i32 %r1, %r1, %r2
i32 test_div_i32(i32 a, i32 b) { return a / b; }

// CHECK-LABEL: @test_div_i64
// CHECK: div_i64 %r1, %r1, %r2
i64 test_div_i64(i64 a, i64 b) { return a / b; }

// CHECK-LABEL: @test_div_u32
// CHECK: div_u32 %r1, %r1, %r2
u32 test_div_u32(u32 a, u32 b) { return a / b; }

// CHECK-LABEL: @test_div_u64
// CHECK: div_u64 %r1, %r1, %r2
u64 test_div_u64(u64 a, u64 b) { return a / b; }

// CHECK-LABEL: @test_divi_i32
// CHECK: div_imm_i32 %r1, %r1, 1000
i32 test_divi_i32(i32 a) { return a / 1000; }

// CHECK-LABEL: @test_divi_i64
// CHECK: div_imm_i64 %r1, %r1, 1000
i64 test_divi_i64(i64 a) { return a / 1000; }

// CHECK-LABEL: @test_divi_u32
// CHECK: div_imm_u32 %r1, %r1, 1000
u32 test_divi_u32(u32 a) { return a / 1000; }

// CHECK-LABEL: @test_divi_u64
// CHECK: div_imm_u64 %r1, %r1, 1000
u64 test_divi_u64(u64 a) { return a / 1000; }

// CHECK-LABEL: @test_divi_ext_i32
// CHECK: div_imm_i32.l %r1, %r1, 1000000000
i32 test_divi_ext_i32(i32 a) { return a / 1000000000; }

// CHECK-LABEL: @test_divi_ext_i64
// CHECK: div_imm_i64.l %r1, %r1, 1000000000
i64 test_divi_ext_i64(i64 a) { return a / 1000000000; }

// CHECK-LABEL: @test_divi_ext_u32
// CHECK: div_imm_u32.l %r1, %r1, 1000000000
u32 test_divi_ext_u32(u32 a) { return a / 1000000000; }

// CHECK-LABEL: @test_divi_ext_u64
// CHECK: div_imm_u64.l %r1, %r1, 1000000000
u64 test_divi_ext_u64(u64 a) { return a / 1000000000; }
