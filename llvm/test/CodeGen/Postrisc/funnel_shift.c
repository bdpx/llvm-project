// RUN: clang %cflags %s | FileCheck %s
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_fshr_u32
// CHECK: srp_imm_i32 %r1, %r2, %r1, 20
// CHECK: retf 0
u32 test_fshr_u32(u32 a, u32 b) { return (a >> 20) | (b << (32 - 20)); }

// CHECK-LABEL: @test_fshr_u64
// CHECK: srp_imm_i64 %r1, %r2, %r1, 20
// CHECK: retf 0
u64 test_fshr_u64(u64 a, u64 b) { return (a >> 20) | (b << (64 - 20)); }

// CHECK-LABEL: @test_fshr_u128
// CHECK: srp_imm_i128 %r1, %r2, %r1, 20
// CHECK: retf 0
u128 test_fshr_u128(u128 a, u128 b) { return (a >> 20) | (b << (128 - 20)); }

///////////////////////////////////////////////////////////////////////////////////////////
// model rotates via funnel shifts
///////////////////////////////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_rotate_u32
// CHECK: srp_imm_i32 %r1, %r1, %r1, 20
// CHECK: retf 0
u32 test_rotate_u32(u32 a) { return (a >> 20) | (a << (32 - 20)); }

// CHECK-LABEL: @test_rotate_u64
// CHECK: srp_imm_i64 %r1, %r1, %r1, 20
// CHECK: retf 0
u64 test_rotate_u64(u64 a) { return (a >> 20) | (a << (64 - 20)); }

// CHECK-LABEL: @test_rotate_u128
// CHECK: srp_imm_i128 %r1, %r1, %r1, 20
// CHECK: retf 0
u128 test_rotate_u128(u128 a) { return (a >> 20) | (a << (128 - 20)); }

