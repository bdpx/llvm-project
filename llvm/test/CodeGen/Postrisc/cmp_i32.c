// RUN: clang %cflags %s | FileCheck %s
// REQUIRES: postrisc-registered-target

#include "common.h"

//////////////////////////////////////////////////////////////////
// compare 32 bit reg-reg
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_i32_eq
// CHECK: cmp_eq_i32 %r1, %r1, %r2
bool test_i32_eq(i32 a, i32 b) { return a == b; }

// CHECK-LABEL: @test_i32_ne
// CHECK: cmp_ne_i32 %r1, %r1, %r2
bool test_i32_ne(i32 a, i32 b) { return a != b; }

// CHECK-LABEL: @test_i32_lt
// CHECK: cmp_lt_i32 %r1, %r1, %r2
bool test_i32_lt(i32 a, i32 b) { return a < b; }

// CHECK-LABEL: @test_i32_le
// CHECK: cmp_le_i32 %r1, %r1, %r2
bool test_i32_le(i32 a, i32 b) { return a <= b; }

// swap args

// CHECK-LABEL: @test_i32_gt
// CHECK: cmp_lt_i32 %r1, %r2, %r1
bool test_i32_gt(i32 a, i32 b) { return a > b; }

// CHECK-LABEL: @test_i32_ge
// CHECK: cmp_le_i32 %r1, %r2, %r1
bool test_i32_ge(i32 a, i32 b) { return a >= b; }

//////////////////////////////////////////////////////////////////
// compare 32 bit reg-reg unsigned
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_u32_lt
// CHECK: cmp_lt_u32 %r1, %r1, %r2
bool test_u32_lt(u32 a, u32 b) { return a < b; }

// CHECK-LABEL: @test_u32_le
// CHECK: cmp_le_u32 %r1, %r1, %r2
bool test_u32_le(u32 a, u32 b) { return a <= b; }

// swap args

// CHECK-LABEL: @test_u32_gt
// CHECK: cmp_lt_u32 %r1, %r2, %r1
bool test_u32_gt(u32 a, u32 b) { return a > b; }

// CHECK-LABEL: @test_u32_ge
// CHECK: cmp_le_u32 %r1, %r2, %r1
bool test_u32_ge(u32 a, u32 b) { return a >= b; }

//////////////////////////////////////////////////////////////////
// compare 32 bit reg-imm
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_i32_eq_imm
// CHECK: cmp_eq_imm_i32 %r1, %r1, 1234
bool test_i32_eq_imm(i32 a) { return a == 1234; }

// CHECK-LABEL: @test_i32_ne_imm
// CHECK: cmp_ne_imm_i32 %r1, %r1, 1234
bool test_i32_ne_imm(i32 a) { return a != 1234; }

// CHECK-LABEL: @test_i32_lt_imm
// CHECK: cmp_lt_imm_i32 %r1, %r1, 1234
bool test_i32_lt_imm(i32 a) { return a < 1234; }

// CHECK-LABEL: @test_i32_gt_imm
// CHECK: cmp_gt_imm_i32 %r1, %r1, 1234
bool test_i32_gt_imm(i32 a) { return a > 1234; }

// adjust immediate

// CHECK-LABEL: @test_i32_le_imm
// CHECK: cmp_lt_imm_i32 %r1, %r1, 1235
bool test_i32_le_imm(i32 a) { return a <= 1234; }

// CHECK-LABEL: @test_i32_ge_imm
// CHECK: cmp_gt_imm_i32 %r1, %r1, 1233
bool test_i32_ge_imm(i32 a) { return a >= 1234; }

//////////////////////////////////////////////////////////////////
// compare 32 bit reg-imm unsigned
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_u32_lt_imm
// CHECK: cmp_lt_imm_u32 %r1, %r1, 1234
bool test_u32_lt_imm(u32 a) { return a < 1234U; }

// CHECK-LABEL: @test_u32_gt_imm
// CHECK: cmp_gt_imm_u32 %r1, %r1, 1234
bool test_u32_gt_imm(u32 a) { return a > 1234U; }

// adjust immediate

// CHECK-LABEL: @test_u32_le_imm
// CHECK: cmp_lt_imm_u32 %r1, %r1, 1235
bool test_u32_le_imm(u32 a) { return a <= 1234U; }

// CHECK-LABEL: @test_u32_ge_imm
// CHECK: cmp_gt_imm_u32 %r1, %r1, 1233
bool test_u32_ge_imm(u32 a) { return a >= 1234U; }
