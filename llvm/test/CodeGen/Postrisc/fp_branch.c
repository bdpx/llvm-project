// RUN: clang %cflags -mllvm --enable-nullification=0 %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// README:
// compiler copies ret.f for eq/ne cases and revert conditions
// it's ok to see UNE in place for EQ, and UEQ in place for NE

//////////////////////////////////////////////////////////////////
// f32 compare and branch
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_fp_branch_f32_eq
// CHECK: bfu.ne.ss %r1, %r2, .LBB0_1
void test_fp_branch_f32_eq(f32 a, f32 b) {
  if (a == b) goto skip;
  printf("test f32 eq\n");
skip: ;
}

// CHECK-LABEL: @test_fp_branch_f32_ne
// CHECK: bfu.eq.ss %r1, %r2, .LBB1_1
void test_fp_branch_f32_ne(f32 a, f32 b) {
  if (a != b) goto skip;
  printf("test f32 ne\n");
skip: ;
}

// CHECK-LABEL: @test_fp_branch_f32_lt
// CHECK: bfo.lt.ss %r1, %r2, .LBB2_2
void test_fp_branch_f32_lt(f32 a, f32 b) {
  if (a < b) goto skip;
  printf("test f32 lt\n");
skip: ;
}

// CHECK-LABEL: @test_fp_branch_f32_le
// CHECK: bfo.le.ss %r1, %r2, .LBB3_2
void test_fp_branch_f32_le(f32 a, f32 b) {
  if (a <= b) goto skip;
  printf("test f32 le\n");
skip: ;
}

// CHECK-LABEL: @test_fp_branch_f32_gt
// CHECK: bfo.lt.ss %r2, %r1, .LBB4_2
void test_fp_branch_f32_gt(f32 a, f32 b) {
  if (a > b) goto skip;
  printf("test f32 gt\n");
skip: ;
}

// CHECK-LABEL: @test_fp_branch_f32_ge
// CHECK: bfo.le.ss %r2, %r1, .LBB5_2
void test_fp_branch_f32_ge(f32 a, f32 b) {
  if (a >= b) goto skip;
  printf("test f32 ge\n");
skip: ;
}

//////////////////////////////////////////////////////////////////
// f64 compare and branch
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_fp_branch_f64_eq
// CHECK: bfu.ne.sd %r1, %r2, .LBB6_1
void test_fp_branch_f64_eq(f64 a, f64 b) {
  if (a == b) goto skip;
  printf("test f64 eq\n");
skip: ;
}

// CHECK-LABEL: @test_fp_branch_f64_ne
// CHECK: bfu.eq.sd %r1, %r2, .LBB7_1
void test_fp_branch_f64_ne(f64 a, f64 b) {
  if (a != b) goto skip;
  printf("test f64 ne\n");
skip: ;
}

// CHECK-LABEL: @test_fp_branch_f64_lt
// CHECK: bfo.lt.sd %r1, %r2, .LBB8_2
void test_fp_branch_f64_lt(f64 a, f64 b) {
  if (a < b) goto skip;
  printf("test f64 lt\n");
skip: ;
}

// CHECK-LABEL: @test_fp_branch_f64_le
// CHECK: bfo.le.sd %r1, %r2, .LBB9_2
void test_fp_branch_f64_le(f64 a, f64 b) {
  if (a <= b) goto skip;
  printf("test f64 le\n");
skip: ;
}

// CHECK-LABEL: @test_fp_branch_f64_gt
// CHECK: bfo.lt.sd %r2, %r1, .LBB10_2
void test_fp_branch_f64_gt(f64 a, f64 b) {
  if (a > b) goto skip;
  printf("test f64 gt\n");
skip: ;
}

// CHECK-LABEL: @test_fp_branch_f64_ge
// CHECK: bfo.le.sd %r2, %r1, .LBB11_2
void test_fp_branch_f64_ge(f64 a, f64 b) {
  if (a >= b) goto skip;
  printf("test f64 ge\n");
skip: ;
}

//////////////////////////////////////////////////////////////////
// f128 compare and branch
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_fp_branch_f128_eq
// CHECK: bfu.ne.sq %r1, %r2, .LBB12_1
void test_fp_branch_f128_eq(f128 a, f128 b) {
  if (a == b) goto skip;
  printf("test f128 eq\n");
skip: ;
}

// CHECK-LABEL: @test_fp_branch_f128_ne
// CHECK: bfu.eq.sq %r1, %r2, .LBB13_1
void test_fp_branch_f128_ne(f128 a, f128 b) {
  if (a != b) goto skip;
  printf("test f128 ne\n");
skip: ;
}

// CHECK-LABEL: @test_fp_branch_f128_lt
// CHECK: bfo.lt.sq %r1, %r2, .LBB14_2
void test_fp_branch_f128_lt(f128 a, f128 b) {
  if (a < b) goto skip;
  printf("test f128 lt\n");
skip: ;
}

// CHECK-LABEL: @test_fp_branch_f128_le
// CHECK: bfo.le.sq %r1, %r2, .LBB15_2
void test_fp_branch_f128_le(f128 a, f128 b) {
  if (a <= b) goto skip;
  printf("test f128 le\n");
skip: ;
}

// CHECK-LABEL: @test_fp_branch_f128_gt
// CHECK: bfo.lt.sq %r2, %r1, .LBB16_2
void test_fp_branch_f128_gt(f128 a, f128 b) {
  if (a > b) goto skip;
  printf("test f128 gt\n");
skip: ;
}

// CHECK-LABEL: @test_fp_branch_f128_ge
// CHECK: bfo.le.sq %r2, %r1, .LBB17_2
void test_fp_branch_f128_ge(f128 a, f128 b) {
  if (a >= b) goto skip;
  printf("test f128 ge\n");
skip: ;
}
