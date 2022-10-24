// RUN: clang %cflags %s | FileCheck %s
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_i32_inv
// CHECK: xori %r1, %r1, -1
i32 test_i32_inv(i32 a) {  return ~a; }

// CHECK-LABEL: @test_i64_inv
// CHECK: xori %r1, %r1, -1
i32 test_i64_inv(i64 a) {  return ~a; }

// CHECK-LABEL: @test_i32_and
// CHECK: and %r1, %r2, %r1
i32 test_i32_and(i32 a, i32 b) {  return a & b; }

// CHECK-LABEL: @test_i64_and
// CHECK: and %r1, %r2, %r1
i64 test_i64_and(i64 a, i64 b) {  return a & b; }

// CHECK-LABEL: @test_i32_andi
// CHECK: andi %r1, %r1, 12345
i32 test_i32_andi(i32 a) {  return a & 12345; }

// CHECK-LABEL: @test_i64_andi
// CHECK: andi %r1, %r1, 12345
i64 test_i64_andi(i64 a) {  return a & 12345; }


// CHECK-LABEL: @test_i32_or
// CHECK: or %r1, %r2, %r1
i32 test_i32_or(i32 a, i32 b) {  return a | b; }

// CHECK-LABEL: @test_i64_or
// CHECK: or %r1, %r2, %r1
i64 test_i64_or(i64 a, i64 b) {  return a | b; }

// CHECK-LABEL: @test_i32_ori
// CHECK: ori %r1, %r1, 12345
i32 test_i32_ori(i32 a) {  return a | 12345; }

// CHECK-LABEL: @test_i64_ori
// CHECK: ori %r1, %r1, 12345
i64 test_i64_ori(i64 a) {  return a | 12345; }


// CHECK-LABEL: @test_i32_xor
// CHECK: xor %r1, %r2, %r1
i32 test_i32_xor(i32 a, i32 b) {  return a ^ b; }

// CHECK-LABEL: @test_i64_xor
// CHECK: xor %r1, %r2, %r1
i64 test_i64_xor(i64 a, i64 b) {  return a ^ b; }

// CHECK-LABEL: @test_i32_xori
// CHECK: xori %r1, %r1, 12345
i32 test_i32_xori(i32 a) {  return a ^ 12345; }

// CHECK-LABEL: @test_i32_xori_ext
// CHECK: xori.l %r1, %r1, 123456789
i32 test_i32_xori_ext(i32 a) {  return a ^ 123456789; }

// CHECK-LABEL: @test_i64_xori_ext
// CHECK: xori.l %r1, %r1, 123456789
i64 test_i64_xori_ext(i64 a) {  return a ^ 123456789; }
