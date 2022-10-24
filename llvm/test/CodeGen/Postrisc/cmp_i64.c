// RUN: clang %cflags %s | FileCheck %s
// REQUIRES: postrisc-registered-target

#include "common.h"

//////////////////////////////////////////////////////////////////
// compare booleans
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_bool_eq
// CHECK: xor %r1, %r1, %r2
// CHECK-NEXT: xor_imm %r1, %r1, 1
bool test_bool_eq(bool a, bool b) { return a == b; }

// CHECK-LABEL: @test_bool_ne
// CHECK: xor %r1, %r1, %r2
bool test_bool_ne(bool a, bool b) { return a != b; }

// CHECK-LABEL: @test_bool_lt
// CHECK: xor_imm %r1, %r1, 1
// CHECK-NEXT: and %r1, %r2, %r1
bool test_bool_lt(bool a, bool b) {  return a < b; }

// CHECK-LABEL: @test_bool_le
// CHECK: xor_imm %r1, %r1, 1
// CHECK-NEXT: or %r1, %r2, %r1
bool test_bool_le(bool a, bool b) {  return a <= b; }

// swap args

// CHECK-LABEL: @test_bool_gt
// CHECK: xor_imm %r2, %r2, 1
// CHECK-NEXT: and %r1, %r1, %r2
bool test_bool_gt(bool a, bool b) {  return a > b; }

// CHECK-LABEL: @test_bool_ge
// CHECK: xor_imm %r2, %r2, 1
// CHECK-NEXT: or %r1, %r1, %r2
bool test_bool_ge(bool a, bool b) {  return a >= b; }

//////////////////////////////////////////////////////////////////
// compare pointers (64 bit, unsigned)
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_ptr_eq
// CHECK: cmp_eq_i64 %r1, %r1, %r2
bool test_ptr_eq(void *a, void *b) { return a == b; }

// CHECK-LABEL: @test_ptr_ne
// CHECK: cmp_ne_i64 %r1, %r1, %r2
bool test_ptr_ne(void *a, void *b) { return a != b; }

// CHECK-LABEL: @test_ptr_lt
// CHECK: cmp_lt_u64 %r1, %r1, %r2
bool test_ptr_lt(void *a, void *b) {  return a < b; }

// CHECK-LABEL: @test_ptr_le
// CHECK: cmp_le_u64 %r1, %r1, %r2
bool test_ptr_le(void *a, void *b) {  return a <= b; }

// swap args

// CHECK-LABEL: @test_ptr_gt
// CHECK: cmp_lt_u64 %r1, %r2, %r1
bool test_ptr_gt(void *a, void *b) {  return a > b; }

// CHECK-LABEL: @test_ptr_ge
// CHECK: cmp_le_u64 %r1, %r2, %r1
bool test_ptr_ge(void *a, void *b) {  return a >= b; }


//////////////////////////////////////////////////////////////////
// compare 64 bit reg-reg
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_i64_eq
// CHECK: cmp_eq_i64 %r1, %r1, %r2
bool test_i64_eq(i64 a, i64 b) { return a == b; }

// CHECK-LABEL: @test_i64_ne
// CHECK: cmp_ne_i64 %r1, %r1, %r2
bool test_i64_ne(i64 a, i64 b) { return a != b; }

// CHECK-LABEL: @test_i64_lt
// CHECK: cmp_lt_i64 %r1, %r1, %r2
bool test_i64_lt(i64 a, i64 b) {  return a < b; }

// CHECK-LABEL: @test_i64_le
// CHECK: cmp_le_i64 %r1, %r1, %r2
bool test_i64_le(i64 a, i64 b) {  return a <= b; }

// swap args

// CHECK-LABEL: @test_i64_gt
// CHECK: cmp_lt_i64 %r1, %r2, %r1
bool test_i64_gt(i64 a, i64 b) {  return a > b; }

// CHECK-LABEL: @test_i64_ge
// CHECK: cmp_le_i64 %r1, %r2, %r1
bool test_i64_ge(i64 a, i64 b) {  return a >= b; }

//////////////////////////////////////////////////////////////////
// compare 64 bit reg-reg unsigned
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_u64_lt
// CHECK: cmp_lt_u64 %r1, %r1, %r2
bool test_u64_lt(u64 a, u64 b) { return a < b; }

// CHECK-LABEL: @test_u64_le
// CHECK: cmp_le_u64 %r1, %r1, %r2
bool test_u64_le(u64 a, u64 b) { return a <= b; }

// swap args

// CHECK-LABEL: @test_u64_gt
// CHECK: cmp_lt_u64 %r1, %r2, %r1
bool test_u64_gt(u64 a, u64 b) { return a > b; }

// CHECK-LABEL: @test_u64_ge
// CHECK: cmp_le_u64 %r1, %r2, %r1
bool test_u64_ge(u64 a, u64 b) { return a >= b; }

//////////////////////////////////////////////////////////////////
// compare 64 bit reg-imm
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_i64_eq_imm
// CHECK: cmp_eq_imm_i64 %r1, %r1, 1234
bool test_i64_eq_imm(i64 a) {  return a == 1234; }

// CHECK-LABEL: @test_i64_ne_imm
// CHECK: cmp_ne_imm_i64 %r1, %r1, 1234
bool test_i64_ne_imm(i64 a) {   return a != 1234LL; }

// CHECK-LABEL: @test_i64_lt_imm
// CHECK: cmp_lt_imm_i64 %r1, %r1, 1234
bool test_i64_lt_imm(i64 a) {  return a < 1234LL; }

// CHECK-LABEL: @test_i64_gt_imm
// CHECK: cmp_gt_imm_i64 %r1, %r1, 1234
bool test_i64_gt_imm(i64 a) {   return a > 1234LL; }

// adjust immediate

// CHECK-LABEL: @test_i64_le_imm
// CHECK: cmp_lt_imm_i64 %r1, %r1, 1235
bool test_i64_le_imm(i64 a) { return a <= 1234LL; }

// CHECK-LABEL: @test_i64_ge_imm
// CHECK: cmp_gt_imm_i64 %r1, %r1, 1233
bool test_i64_ge_imm(i64 a) { return a >= 1234LL; }

//////////////////////////////////////////////////////////////////
// compare 64 bit reg-imm unsigned
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_u64_lt_imm
// CHECK: cmp_lt_imm_u64 %r1, %r1, 1234
bool test_u64_lt_imm(u64 a) { return a < 1234U; }

// CHECK-LABEL: @test_u64_gt_imm
// CHECK: cmp_gt_imm_u64 %r1, %r1, 1234
bool test_u64_gt_imm(u64 a) { return a > 1234U; }

// adjust immediate

// CHECK-LABEL: @test_u64_le_imm
// CHECK: cmp_lt_imm_u64 %r1, %r1, 1235
bool test_u64_le_imm(u64 a) { return a <= 1234ULL; }

// CHECK-LABEL: @test_u64_ge_imm
// CHECK: cmp_gt_imm_u64 %r1, %r1, 1233
bool test_u64_ge_imm(u64 a) { return a >= 1234ULL; }

