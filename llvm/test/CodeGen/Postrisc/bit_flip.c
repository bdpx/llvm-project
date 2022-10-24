// RUN: clang %cflags %s | FileCheck %s
// REQUIRES: postrisc-registered-target

#include "common.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
// bit flip
////////////////////////////////////////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_bit_flip_i32
// CHECK: bit_flip %r1, %r1, %r2
// CHECK-NEXT: retf 0
i32 test_bit_flip_i32(i32 a, i32 b) {  return a ^ (1 << b); }

// CHECK-LABEL: @test_bit_flip_imm_i32
// CHECK: bit_flip_imm %r1, %r1, 20
// CHECK-NEXT: retf 0
i32 test_bit_flip_imm_i32(i32 a) {  return a ^ (1024*1024); }

// CHECK-LABEL: @test_bit_flip_i64_i32
// CHECK: bit_flip %r1, %r1, %r2
// CHECK-NEXT: retf 0
i64 test_bit_flip_i64_i32(i64 a, i32 b) {  return a ^ ((i64)1 << b); }

// CHECK-LABEL: @test_bit_flip_i64_i64
// CHECK: bit_flip %r1, %r1, %r2
// CHECK-NEXT: retf 0
i64 test_bit_flip_i64_i64(i64 a, i64 b) {  return a ^ ((i64)1 << b); }

// CHECK-LABEL: @test_bit_flip_imm_i64
// CHECK: bit_flip_imm %r1, %r1, 30
// CHECK-NEXT: retf 0
i64 test_bit_flip_imm_i64(i64 a) {  return a ^ (1024LL*1024*1024); }

// CHECK-LABEL: @test_bit_flip_i128_i32
// CHECK: bit_flip %r1, %r1, %r2
// CHECK-NEXT: retf 0
i128 test_bit_flip_i128_i32(i128 a, i32 b) {  return a ^ ((i128)1 << b); }

// CHECK-LABEL: @test_bit_flip_i128_i64
// CHECK: bit_flip %r1, %r1, %r2
// CHECK-NEXT: retf 0
i128 test_bit_flip_i128_i64(i128 a, i64 b) {  return a ^ ((i128)1 << b); }

// CHECK-LABEL: @test_bit_flip_imm_i128
// CHECK: bit_flip_imm %r1, %r1, 40
// CHECK-NEXT: retf 0
i128 test_bit_flip_imm_i128(i128 a) {  return a ^ (i128)(1024LL*1024*1024*1024); }
