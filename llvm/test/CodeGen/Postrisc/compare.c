// RUN: clang %cflags %s | FileCheck %s
// REQUIRES: postrisc-registered-target

#include "common.h"

//////////////////////////////////////////////////////////////////
// compare booleans
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_bool_eq
// CHECK: xor %r1, %r1, %r2
// CHECK-NEXT: xori %r1, %r1, 1
bool test_bool_eq(bool a, bool b) { return a == b; }

// CHECK-LABEL: @test_bool_ne
// CHECK: xor %r1, %r1, %r2
bool test_bool_ne(bool a, bool b) { return a != b; }

// CHECK-LABEL: @test_bool_lt
// CHECK: xori %r1, %r1, 1
// CHECK-NEXT: and %r1, %r2, %r1
bool test_bool_lt(bool a, bool b) {  return a < b; }

// CHECK-LABEL: @test_bool_le
// CHECK: xori %r1, %r1, 1
// CHECK-NEXT: or %r1, %r2, %r1
bool test_bool_le(bool a, bool b) {  return a <= b; }

// swap args

// CHECK-LABEL: @test_bool_gt
// CHECK: xori %r2, %r2, 1
// CHECK-NEXT: and %r1, %r1, %r2
bool test_bool_gt(bool a, bool b) {  return a > b; }

// CHECK-LABEL: @test_bool_ge
// CHECK: xori %r2, %r2, 1
// CHECK-NEXT: or %r1, %r1, %r2
bool test_bool_ge(bool a, bool b) {  return a >= b; }

//////////////////////////////////////////////////////////////////
// compare pointers (64 bit, unsigned)
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_ptr_eq
// CHECK: cmp.eq.d %r1, %r1, %r2
bool test_ptr_eq(void *a, void *b) { return a == b; }

// CHECK-LABEL: @test_ptr_ne
// CHECK: cmp.ne.d %r1, %r1, %r2
bool test_ptr_ne(void *a, void *b) { return a != b; }

// CHECK-LABEL: @test_ptr_lt
// CHECK: cmpu.lt.d %r1, %r1, %r2
bool test_ptr_lt(void *a, void *b) {  return a < b; }

// CHECK-LABEL: @test_ptr_le
// CHECK: cmpu.le.d %r1, %r1, %r2
bool test_ptr_le(void *a, void *b) {  return a <= b; }

// swap args

// CHECK-LABEL: @test_ptr_gt
// CHECK: cmpu.lt.d %r1, %r2, %r1
bool test_ptr_gt(void *a, void *b) {  return a > b; }

// CHECK-LABEL: @test_ptr_ge
// CHECK: cmpu.le.d %r1, %r2, %r1
bool test_ptr_ge(void *a, void *b) {  return a >= b; }


//////////////////////////////////////////////////////////////////
// compare 64 bit reg-reg
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_i64_eq
// CHECK: cmp.eq.d %r1, %r1, %r2
bool test_i64_eq(i64 a, i64 b) { return a == b; }

// CHECK-LABEL: @test_i64_ne
// CHECK: cmp.ne.d %r1, %r1, %r2
bool test_i64_ne(i64 a, i64 b) { return a != b; }

// CHECK-LABEL: @test_i64_lt
// CHECK: cmps.lt.d %r1, %r1, %r2
bool test_i64_lt(i64 a, i64 b) {  return a < b; }

// CHECK-LABEL: @test_i64_le
// CHECK: cmps.le.d %r1, %r1, %r2
bool test_i64_le(i64 a, i64 b) {  return a <= b; }

// swap args

// CHECK-LABEL: @test_i64_gt
// CHECK: cmps.lt.d %r1, %r2, %r1
bool test_i64_gt(i64 a, i64 b) {  return a > b; }

// CHECK-LABEL: @test_i64_ge
// CHECK: cmps.le.d %r1, %r2, %r1
bool test_i64_ge(i64 a, i64 b) {  return a >= b; }

//////////////////////////////////////////////////////////////////
// compare 64 bit reg-reg unsigned
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_u64_lt
// CHECK: cmpu.lt.d %r1, %r1, %r2
bool test_u64_lt(u64 a, u64 b) { return a < b; }

// CHECK-LABEL: @test_u64_le
// CHECK: cmpu.le.d %r1, %r1, %r2
bool test_u64_le(u64 a, u64 b) { return a <= b; }

// swap args

// CHECK-LABEL: @test_u64_gt
// CHECK: cmpu.lt.d %r1, %r2, %r1
bool test_u64_gt(u64 a, u64 b) { return a > b; }

// CHECK-LABEL: @test_u64_ge
// CHECK: cmpu.le.d %r1, %r2, %r1
bool test_u64_ge(u64 a, u64 b) { return a >= b; }

//////////////////////////////////////////////////////////////////
// compare 64 bit reg-imm
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_i64_eq_imm
// CHECK: cmpi.eq.d %r1, %r1, 1234
bool test_i64_eq_imm(i64 a) {  return a == 1234; }

// CHECK-LABEL: @test_i64_ne_imm
// CHECK: cmpi.ne.d %r1, %r1, 1234
bool test_i64_ne_imm(i64 a) {   return a != 1234LL; }

// CHECK-LABEL: @test_i64_lt_imm
// CHECK: cmpsi.lt.d %r1, %r1, 1234
bool test_i64_lt_imm(i64 a) {  return a < 1234LL; }

// CHECK-LABEL: @test_i64_gt_imm
// CHECK: cmpsi.gt.d %r1, %r1, 1234
bool test_i64_gt_imm(i64 a) {   return a > 1234LL; }

// adjust immediate

// CHECK-LABEL: @test_i64_le_imm
// CHECK: cmpsi.lt.d %r1, %r1, 1235
bool test_i64_le_imm(i64 a) { return a <= 1234LL; }

// CHECK-LABEL: @test_i64_ge_imm
// CHECK: cmpsi.gt.d %r1, %r1, 1233
bool test_i64_ge_imm(i64 a) { return a >= 1234LL; }

//////////////////////////////////////////////////////////////////
// compare 64 bit reg-imm unsigned
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_u64_lt_imm
// CHECK: cmpui.lt.d %r1, %r1, 1234
bool test_u64_lt_imm(u64 a) { return a < 1234U; }

// CHECK-LABEL: @test_u64_gt_imm
// CHECK: cmpui.gt.d %r1, %r1, 1234
bool test_u64_gt_imm(u64 a) { return a > 1234U; }

// adjust immediate

// CHECK-LABEL: @test_u64_le_imm
// CHECK: cmpui.lt.d %r1, %r1, 1235
bool test_u64_le_imm(u64 a) { return a <= 1234ULL; }

// CHECK-LABEL: @test_u64_ge_imm
// CHECK: cmpui.gt.d %r1, %r1, 1233
bool test_u64_ge_imm(u64 a) { return a >= 1234ULL; }

//////////////////////////////////////////////////////////////////
// compare 32 bit reg-reg
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_i32_eq
// CHECK: cmp.eq.w %r1, %r1, %r2
bool test_i32_eq(i32 a, i32 b) { return a == b; }

// CHECK-LABEL: @test_i32_ne
// CHECK: cmp.ne.w %r1, %r1, %r2
bool test_i32_ne(i32 a, i32 b) { return a != b; }

// CHECK-LABEL: @test_i32_lt
// CHECK: cmps.lt.w %r1, %r1, %r2
bool test_i32_lt(i32 a, i32 b) { return a < b; }

// CHECK-LABEL: @test_i32_le
// CHECK: cmps.le.w %r1, %r1, %r2
bool test_i32_le(i32 a, i32 b) { return a <= b; }

// swap args

// CHECK-LABEL: @test_i32_gt
// CHECK: cmps.lt.w %r1, %r2, %r1
bool test_i32_gt(i32 a, i32 b) { return a > b; }

// CHECK-LABEL: @test_i32_ge
// CHECK: cmps.le.w %r1, %r2, %r1
bool test_i32_ge(i32 a, i32 b) { return a >= b; }

//////////////////////////////////////////////////////////////////
// compare 32 bit reg-reg unsigned
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_u32_lt
// CHECK: cmpu.lt.w %r1, %r1, %r2
bool test_u32_lt(u32 a, u32 b) { return a < b; }

// CHECK-LABEL: @test_u32_le
// CHECK: cmpu.le.w %r1, %r1, %r2
bool test_u32_le(u32 a, u32 b) { return a <= b; }

// swap args

// CHECK-LABEL: @test_u32_gt
// CHECK: cmpu.lt.w %r1, %r2, %r1
bool test_u32_gt(u32 a, u32 b) { return a > b; }

// CHECK-LABEL: @test_u32_ge
// CHECK: cmpu.le.w %r1, %r2, %r1
bool test_u32_ge(u32 a, u32 b) { return a >= b; }

//////////////////////////////////////////////////////////////////
// compare 32 bit reg-imm
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_i32_eq_imm
// CHECK: cmpi.eq.w %r1, %r1, 1234
bool test_i32_eq_imm(i32 a) { return a == 1234; }

// CHECK-LABEL: @test_i32_ne_imm
// CHECK: cmpi.ne.w %r1, %r1, 1234
bool test_i32_ne_imm(i32 a) { return a != 1234; }

// CHECK-LABEL: @test_i32_lt_imm
// CHECK: cmpsi.lt.w %r1, %r1, 1234
bool test_i32_lt_imm(i32 a) { return a < 1234; }

// CHECK-LABEL: @test_i32_gt_imm
// CHECK: cmpsi.gt.w %r1, %r1, 1234
bool test_i32_gt_imm(i32 a) { return a > 1234; }

// adjust immediate

// CHECK-LABEL: @test_i32_le_imm
// CHECK: cmpsi.lt.w %r1, %r1, 1235
bool test_i32_le_imm(i32 a) { return a <= 1234; }

// CHECK-LABEL: @test_i32_ge_imm
// CHECK: cmpsi.gt.w %r1, %r1, 1233
bool test_i32_ge_imm(i32 a) { return a >= 1234; }

//////////////////////////////////////////////////////////////////
// compare 32 bit reg-imm unsigned
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_u32_lt_imm
// CHECK: cmpui.lt.w %r1, %r1, 1234
bool test_u32_lt_imm(u32 a) { return a < 1234U; }

// CHECK-LABEL: @test_u32_gt_imm
// CHECK: cmpui.gt.w %r1, %r1, 1234
bool test_u32_gt_imm(u32 a) { return a > 1234U; }

// adjust immediate

// CHECK-LABEL: @test_u32_le_imm
// CHECK: cmpui.lt.w %r1, %r1, 1235
bool test_u32_le_imm(u32 a) { return a <= 1234U; }

// CHECK-LABEL: @test_u32_ge_imm
// CHECK: cmpui.gt.w %r1, %r1, 1233
bool test_u32_ge_imm(u32 a) { return a >= 1234U; }
