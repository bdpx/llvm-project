// RUN: clang %cflags %s | FileCheck %s
// REQUIRES: postrisc-registered-target

#include "common.h"

//////////////////////////////////////////////////////////////////
// compare 128 bit reg-reg
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_i128_eq
// CHECK: cmp_eq_i128 %r1, %r1, %r2
bool test_i128_eq(i128 a, i128 b) { return a == b; }

// CHECK-LABEL: @test_i128_ne
// CHECK: cmp_ne_i128 %r1, %r1, %r2
bool test_i128_ne(i128 a, i128 b) { return a != b; }

// CHECK-LABEL: @test_i128_lt
// CHECK: cmp_lt_i128 %r1, %r1, %r2
bool test_i128_lt(i128 a, i128 b) { return a < b; }

// CHECK-LABEL: @test_i128_le
// CHECK: cmp_le_i128 %r1, %r1, %r2
bool test_i128_le(i128 a, i128 b) { return a <= b; }

// swap args

// CHECK-LABEL: @test_i128_gt
// CHECK: cmp_lt_i128 %r1, %r2, %r1
bool test_i128_gt(i128 a, i128 b) { return a > b; }

// CHECK-LABEL: @test_i128_ge
// CHECK: cmp_le_i128 %r1, %r2, %r1
bool test_i128_ge(i128 a, i128 b) { return a >= b; }

//////////////////////////////////////////////////////////////////
// compare 128 bit reg-reg unsigned
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_u128_lt
// CHECK: cmp_lt_u128 %r1, %r1, %r2
bool test_u128_lt(u128 a, u128 b) { return a < b; }

// CHECK-LABEL: @test_u128_le
// CHECK: cmp_le_u128 %r1, %r1, %r2
bool test_u128_le(u128 a, u128 b) { return a <= b; }

// swap args

// CHECK-LABEL: @test_u128_gt
// CHECK: cmp_lt_u128 %r1, %r2, %r1
bool test_u128_gt(u128 a, u128 b) { return a > b; }

// CHECK-LABEL: @test_u128_ge
// CHECK: cmp_le_u128 %r1, %r2, %r1
bool test_u128_ge(u128 a, u128 b) { return a >= b; }

//////////////////////////////////////////////////////////////////
// compare 128 bit reg-imm
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_i128_eq_imm
// CHECK: cmp_eq_imm_i128 %r1, %r1, 1234
bool test_i128_eq_imm(i128 a) { return a == 1234; }

// CHECK-LABEL: @test_i128_ne_imm
// CHECK: cmp_ne_imm_i128 %r1, %r1, 1234
bool test_i128_ne_imm(i128 a) { return a != 1234; }

// CHECK-LABEL: @test_i128_lt_imm
// CHECK: cmp_lt_imm_i128 %r1, %r1, 1234
bool test_i128_lt_imm(i128 a) { return a < 1234; }

// CHECK-LABEL: @test_i128_gt_imm
// CHECK: cmp_gt_imm_i128 %r1, %r1, 1234
bool test_i128_gt_imm(i128 a) { return a > 1234; }

// adjust immediate

// CHECK-LABEL: @test_i128_le_imm
// CHECK: cmp_lt_imm_i128 %r1, %r1, 1235
bool test_i128_le_imm(i128 a) { return a <= 1234; }

// CHECK-LABEL: @test_i128_ge_imm
// CHECK: cmp_gt_imm_i128 %r1, %r1, 1233
bool test_i128_ge_imm(i128 a) { return a >= 1234; }

//////////////////////////////////////////////////////////////////
// compare 128 bit reg-imm unsigned
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_u128_lt_imm
// CHECK: cmp_lt_imm_u128 %r1, %r1, 1234
bool test_u128_lt_imm(u128 a) { return a < 1234U; }

// CHECK-LABEL: @test_u128_gt_imm
// CHECK: cmp_gt_imm_u128 %r1, %r1, 1234
bool test_u128_gt_imm(u128 a) { return a > 1234U; }

// adjust immediate

// CHECK-LABEL: @test_u128_le_imm
// CHECK: cmp_lt_imm_u128 %r1, %r1, 1235
bool test_u128_le_imm(u128 a) { return a <= 1234U; }

// CHECK-LABEL: @test_u128_ge_imm
// CHECK: cmp_gt_imm_u128 %r1, %r1, 1233
bool test_u128_ge_imm(u128 a) { return a >= 1234U; }
