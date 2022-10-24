// RUN: clang %cflags %s | FileCheck %s
// REQUIRES: postrisc-registered-target

#include "common.h"

//////////////////////////////////////////////////////////////////
// compare 64 bit reg-reg
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_i64_eq
// CHECK: cmpdeq %r1, %r1, %r2
bool test_i64_eq(i64 a, i64 b) { return a == b; }

// CHECK-LABEL: @test_i64_ne
// CHECK: cmpdne %r1, %r1, %r2
bool test_i64_ne(i64 a, i64 b) { return a != b; }

// CHECK-LABEL: @test_i64_lt
// CHECK: cmpdlt %r1, %r1, %r2
bool test_i64_lt(i64 a, i64 b) {  return a < b; }

// CHECK-LABEL: @test_i64_le
// CHECK: cmpdle %r1, %r1, %r2
bool test_i64_le(i64 a, i64 b) {  return a <= b; }

// swap args

// CHECK-LABEL: @test_i64_gt
// CHECK: cmpdlt %r1, %r2, %r1
bool test_i64_gt(i64 a, i64 b) {  return a > b; }

// CHECK-LABEL: @test_i64_ge
// CHECK: cmpdle %r1, %r2, %r1
bool test_i64_ge(i64 a, i64 b) {  return a >= b; }

//////////////////////////////////////////////////////////////////
// compare 64 bit reg-reg unsigned
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_u64_lt
// CHECK: cmpdltu %r1, %r1, %r2
bool test_u64_lt(u64 a, u64 b) { return a < b; }

// CHECK-LABEL: @test_u64_le
// CHECK: cmpdleu %r1, %r1, %r2
bool test_u64_le(u64 a, u64 b) { return a <= b; }

// swap args

// CHECK-LABEL: @test_u64_gt
// CHECK: cmpdltu %r1, %r2, %r1
bool test_u64_gt(u64 a, u64 b) { return a > b; }

// CHECK-LABEL: @test_u64_ge
// CHECK: cmpdleu %r1, %r2, %r1
bool test_u64_ge(u64 a, u64 b) { return a >= b; }

//////////////////////////////////////////////////////////////////
// compare 64 bit reg-imm
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_i64_eq_imm
// CHECK: cmpdeqi %r1, %r1, 1234
bool test_i64_eq_imm(i64 a) {  return a == 1234; }

// CHECK-LABEL: @test_i64_ne_imm
// CHECK: cmpdnei %r1, %r1, 1234
bool test_i64_ne_imm(i64 a) {   return a != 1234LL; }

// CHECK-LABEL: @test_i64_lt_imm
// CHECK: cmpdlti %r1, %r1, 1234
bool test_i64_lt_imm(i64 a) {  return a < 1234LL; }

// CHECK-LABEL: @test_i64_gt_imm
// CHECK: cmpdgti %r1, %r1, 1234
bool test_i64_gt_imm(i64 a) {   return a > 1234LL; }

// adjust immediate

// CHECK-LABEL: @test_i64_le_imm
// CHECK: cmpdlti %r1, %r1, 1235
bool test_i64_le_imm(i64 a) { return a <= 1234LL; }

// CHECK-LABEL: @test_i64_ge_imm
// CHECK: cmpdgti %r1, %r1, 1233
bool test_i64_ge_imm(i64 a) { return a >= 1234LL; }

//////////////////////////////////////////////////////////////////
// compare 64 bit reg-imm unsigned
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_u64_lt_imm
// CHECK: cmpdltui %r1, %r1, 1234
bool test_u64_lt_imm(u64 a) { return a < 1234U; }

// CHECK-LABEL: @test_u64_gt_imm
// CHECK: cmpdgtui %r1, %r1, 1234
bool test_u64_gt_imm(u64 a) { return a > 1234U; }

// adjust immediate

// CHECK-LABEL: @test_u64_le_imm
// CHECK: cmpdltui %r1, %r1, 1235
bool test_u64_le_imm(u64 a) { return a <= 1234ULL; }

// CHECK-LABEL: @test_u64_ge_imm
// CHECK: cmpdgtui %r1, %r1, 1233
bool test_u64_ge_imm(u64 a) { return a >= 1234ULL; }

//////////////////////////////////////////////////////////////////
// compare 32 bit reg-reg
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_i32_eq
// CHECK: cmpweq %r1, %r1, %r2
bool test_i32_eq(i32 a, i32 b) { return a == b; }

// CHECK-LABEL: @test_i32_ne
// CHECK: cmpwne %r1, %r1, %r2
bool test_i32_ne(i32 a, i32 b) { return a != b; }

// CHECK-LABEL: @test_i32_lt
// CHECK: cmpwlt %r1, %r1, %r2
bool test_i32_lt(i32 a, i32 b) { return a < b; }

// CHECK-LABEL: @test_i32_le
// CHECK: cmpwle %r1, %r1, %r2
bool test_i32_le(i32 a, i32 b) { return a <= b; }

// swap args

// CHECK-LABEL: @test_i32_gt
// CHECK: cmpwlt %r1, %r2, %r1
bool test_i32_gt(i32 a, i32 b) { return a > b; }

// CHECK-LABEL: @test_i32_ge
// CHECK: cmpwle %r1, %r2, %r1
bool test_i32_ge(i32 a, i32 b) { return a >= b; }

//////////////////////////////////////////////////////////////////
// compare 32 bit reg-reg unsigned
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_u32_lt
// CHECK: cmpwltu %r1, %r1, %r2
bool test_u32_lt(u32 a, u32 b) { return a < b; }

// CHECK-LABEL: @test_u32_le
// CHECK: cmpwleu %r1, %r1, %r2
bool test_u32_le(u32 a, u32 b) { return a <= b; }

// swap args

// CHECK-LABEL: @test_u32_gt
// CHECK: cmpwltu %r1, %r2, %r1
bool test_u32_gt(u32 a, u32 b) { return a > b; }

// CHECK-LABEL: @test_u32_ge
// CHECK: cmpwleu %r1, %r2, %r1
bool test_u32_ge(u32 a, u32 b) { return a >= b; }

//////////////////////////////////////////////////////////////////
// compare 32 bit reg-imm
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_i32_eq_imm
// CHECK: cmpweqi %r1, %r1, 1234
bool test_i32_eq_imm(i32 a) { return a == 1234; }

// CHECK-LABEL: @test_i32_ne_imm
// CHECK: cmpwnei %r1, %r1, 1234
bool test_i32_ne_imm(i32 a) { return a != 1234; }

// CHECK-LABEL: @test_i32_lt_imm
// CHECK: cmpwlti %r1, %r1, 1234
bool test_i32_lt_imm(i32 a) { return a < 1234; }

// CHECK-LABEL: @test_i32_gt_imm
// CHECK: cmpwgti %r1, %r1, 1234
bool test_i32_gt_imm(i32 a) { return a > 1234; }

// adjust immediate

// CHECK-LABEL: @test_i32_le_imm
// CHECK: cmpwlti %r1, %r1, 1235
bool test_i32_le_imm(i32 a) { return a <= 1234; }

// CHECK-LABEL: @test_i32_ge_imm
// CHECK: cmpwgti %r1, %r1, 1233
bool test_i32_ge_imm(i32 a) { return a >= 1234; }

//////////////////////////////////////////////////////////////////
// compare 32 bit reg-imm unsigned
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_u32_lt_imm
// CHECK: cmpwltui %r1, %r1, 1234
bool test_u32_lt_imm(u32 a) { return a < 1234U; }

// CHECK-LABEL: @test_u32_gt_imm
// CHECK: cmpwgtui %r1, %r1, 1234
bool test_u32_gt_imm(u32 a) { return a > 1234U; }

// adjust immediate

// CHECK-LABEL: @test_u32_le_imm
// CHECK: cmpwltui %r1, %r1, 1235
bool test_u32_le_imm(u32 a) { return a <= 1234U; }

// CHECK-LABEL: @test_u32_ge_imm
// CHECK: cmpwgtui %r1, %r1, 1233
bool test_u32_ge_imm(u32 a) { return a >= 1234U; }
