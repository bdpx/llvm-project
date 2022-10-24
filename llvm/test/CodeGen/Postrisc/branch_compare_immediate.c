// RUN: clang %cflags -mllvm --enable-nullification=0 %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target
// NOTE: -mllvm --enable-nullification=0 is required to not convert branches to nullifications

#include "common.h"

//===----------------------------------------------------------------------===//
// i64
//===----------------------------------------------------------------------===//

// CHECK-LABEL: @test_branch_i64_eqi
void test_branch_i64_eqi(i64 a)
{
  // CHECK: br_ne_imm_i64 %r1, 534, .LBB
  if (a == 534)
    printf("branch!\n");
}

// CHECK-LABEL: @test_branch_i64_nei
void test_branch_i64_nei(i64 a)
{
  // CHECK: br_eq_imm_i64 %r1, 534, .LBB
  if (a != 534)
    printf("branch!\n");
}

// CHECK-LABEL: @test_branch_i64_lti
void test_branch_i64_lti(i64 a)
{
  // CHECK: br_ge_imm_i64 %r1, 534, .LBB
  if (a < 534)
    printf("branch!\n");
}

// CHECK-LABEL: @test_branch_i64_lei
void test_branch_i64_lei(i64 a)
{
  // CHECK: br_ge_imm_i64 %r1, 535, .LBB
  if (a <= 534)
    printf("branch!\n");
}

// CHECK-LABEL: @test_branch_i64_gti
void test_branch_i64_gti(i64 a)
{
  // CHECK: br_lt_imm_i64 %r1, 535, .LBB
  if (a > 534)
    printf("branch!\n");
}

// CHECK-LABEL: @test_branch_i64_gei
void test_branch_i64_gei(i64 a)
{
  // CHECK: br_lt_imm_i64 %r1, 534, .LBB
  if (a >= 534)
    printf("branch!\n");
}

//===----------------------------------------------------------------------===//
// i64 ext
//===----------------------------------------------------------------------===//

// CHECK-LABEL: @test_branch_ext_i64_eqi
void test_branch_ext_i64_eqi(i64 a)
{
  // CHECK: br_ne_imm_i64.l %r1, 12345678, .LBB
  if (a == 12345678)
    printf("branch!\n");
}

// CHECK-LABEL: @test_branch_ext_i64_nei
void test_branch_ext_i64_nei(i64 a)
{
  // CHECK: br_eq_imm_i64.l %r1, 12345678, .LBB
  if (a != 12345678)
    printf("branch!\n");
}

// CHECK-LABEL: @test_branch_ext_i64_lti
void test_branch_ext_i64_lti(i64 a)
{
  // CHECK: br_ge_imm_i64.l %r1, 12345678, .LBB
  if (a < 12345678)
    printf("branch!\n");
}

// CHECK-LABEL: @test_branch_ext_i64_lei
void test_branch_ext_i64_lei(i64 a)
{
  // CHECK: br_ge_imm_i64.l %r1, 12345679, .LBB
  if (a <= 12345678)
    printf("branch!\n");
}

// CHECK-LABEL: @test_branch_ext_i64_gti
void test_branch_ext_i64_gti(i64 a)
{
  // CHECK: br_lt_imm_i64.l %r1, 12345679, .LBB
  if (a > 12345678)
    printf("branch!\n");
}

// CHECK-LABEL: @test_branch_ext_i64_gei
void test_branch_ext_i64_gei(i64 a)
{
  // CHECK: br_lt_imm_i64.l %r1, 12345678, .LBB
  if (a >= 12345678)
    printf("branch!\n");
}

//===----------------------------------------------------------------------===//
// i32
//===----------------------------------------------------------------------===//

// CHECK-LABEL: @test_branch_i32_eqi
void test_branch_i32_eqi(i32 a)
{
  // CHECK: br_ne_imm_i32 %r1, 534, .LBB
  if (a == 534)
    printf("branch!\n");
}

// CHECK-LABEL: @test_branch_i32_nei
void test_branch_i32_nei(i32 a)
{
  // CHECK: br_eq_imm_i32 %r1, 534, .LBB
  if (a != 534)
    printf("branch!\n");
}

// CHECK-LABEL: @test_branch_i32_lti
void test_branch_i32_lti(i32 a)
{
  // CHECK: br_ge_imm_i32 %r1, 534, .LBB
  if (a < 534)
    printf("branch!\n");
}

// CHECK-LABEL: @test_branch_i32_lei
void test_branch_i32_lei(i32 a)
{
  // CHECK: br_ge_imm_i32 %r1, 535, .LBB
  if (a <= 534)
    printf("branch!\n");
}

// CHECK-LABEL: @test_branch_i32_gti
void test_branch_i32_gti(i32 a)
{
  // CHECK: br_lt_imm_i32 %r1, 535, .LBB
  if (a > 534)
    printf("branch!\n");
}

// CHECK-LABEL: @test_branch_i32_gei
void test_branch_i32_gei(i32 a)
{
  // CHECK: br_lt_imm_i32 %r1, 534, .LBB
  if (a >= 534)
    printf("branch!\n");
}

//===----------------------------------------------------------------------===//
// i32 ext
//===----------------------------------------------------------------------===//

// CHECK-LABEL: @test_branch_ext_i32_eqi
void test_branch_ext_i32_eqi(i32 a)
{
  // CHECK: br_ne_imm_i32.l %r1, 12345678, .LBB
  if (a == 12345678)
    printf("branch!\n");
}

// CHECK-LABEL: @test_branch_ext_i32_nei
void test_branch_ext_i32_nei(i32 a)
{
  // CHECK: br_eq_imm_i32.l %r1, 12345678, .LBB
  if (a != 12345678)
    printf("branch!\n");
}

// CHECK-LABEL: @test_branch_ext_i32_lti
void test_branch_ext_i32_lti(i32 a)
{
  // CHECK: br_ge_imm_i32.l %r1, 12345678, .LBB
  if (a < 12345678)
    printf("branch!\n");
}

// CHECK-LABEL: @test_branch_ext_i32_lei
void test_branch_ext_i32_lei(i32 a)
{
  // CHECK: br_ge_imm_i32.l %r1, 12345679, .LBB
  if (a <= 12345678)
    printf("branch!\n");
}

// CHECK-LABEL: @test_branch_ext_i32_gti
void test_branch_ext_i32_gti(i32 a)
{
  // CHECK: br_lt_imm_i32.l %r1, 12345679, .LBB
  if (a > 12345678)
    printf("branch!\n");
}

// CHECK-LABEL: @test_branch_ext_i32_gei
void test_branch_ext_i32_gei(i32 a)
{
  // CHECK: br_lt_imm_i32.l %r1, 12345678, .LBB
  if (a >= 12345678)
    printf("branch!\n");
}
