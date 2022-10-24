// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_bit_1_i32
// CHECK: br_bs %r1, %r2, [[TARGET:.LBB[0-9]+_[0-9]+]]
void test_bit_1_i32(i32 a, i32 b) { CHECK_BRANCH(a & (1 << b)); }

// CHECK-LABEL: @test_bit_2_i32
// CHECK: br_bc %r1, %r2, [[TARGET:.LBB[0-9]+_[0-9]+]]
void test_bit_2_i32(i32 a, i32 b) { CHECK_BRANCH((a & (1 << b)) == 0); }

// CHECK-LABEL: @test_bit_3_i32
// CHECK: br_bs %r1, %r2, [[TARGET:.LBB[0-9]+_[0-9]+]]
void test_bit_3_i32(i32 a, i32 b) { CHECK_BRANCH((a >> b) & 1); }

// CHECK-LABEL: @test_bit_4_i32
// CHECK: br_bc_imm %r1, 15, [[TARGET:.LBB[0-9]+_[0-9]+]]
void test_bit_4_i32_4(i32 a) { CHECK_BRANCH(((a >> 15) & 1) == 0); }

// CHECK-LABEL: @test_bit_5_i32
// CHECK: br_bs_imm %r1, 14, [[TARGET:.LBB[0-9]+_[0-9]+]]
void test_bit_5_i32(i32 a) { CHECK_BRANCH(((a >> 14) & 1) == 1); }



// CHECK-LABEL: @test_bit_1_i64
// CHECK: br_bs %r1, %r2, [[TARGET:.LBB[0-9]+_[0-9]+]]
void test_bit_1_i64(i64 a, i64 b) { CHECK_BRANCH(a & (1LL << b)); }

// CHECK-LABEL: @test_bit_2_i64
// CHECK: br_bc %r1, %r2, [[TARGET:.LBB[0-9]+_[0-9]+]]
void test_bit_2_i64(i64 a, i64 b) { CHECK_BRANCH((a & (1LL << b)) == 0); }

// CHECK-LABEL: @test_bit_3_i64
// CHECK: br_bs %r1, %r2, [[TARGET:.LBB[0-9]+_[0-9]+]]
void test_bit_3_i64(i64 a, i64 b) { CHECK_BRANCH((a >> b) & 1); }

// CHECK-LABEL: @test_bit_4_i64
// CHECK: br_bc_imm %r1, 15, [[TARGET:.LBB[0-9]+_[0-9]+]]
void test_bit_4_i64_4(i64 a) { CHECK_BRANCH(((a >> 15) & 1) == 0); }

// CHECK-LABEL: @test_bit_5_i64
// CHECK: br_bs_imm %r1, 14, [[TARGET:.LBB[0-9]+_[0-9]+]]
void test_bit_5_i64(i64 a) { CHECK_BRANCH(((a >> 14) & 1) == 1); }



// CHECK-LABEL: @test_bit_1_i128
// CHECK: br_bs %r1, %r2, [[TARGET:.LBB[0-9]+_[0-9]+]]
void test_bit_1_i128(i128 a, i128 b) { CHECK_BRANCH(a & ((i128)1 << b)); }

// CHECK-LABEL: @test_bit_2_i128
// CHECK: br_bc %r1, %r2, [[TARGET:.LBB[0-9]+_[0-9]+]]
void test_bit_2_i128(i128 a, i128 b) { CHECK_BRANCH((a & ((i128)1 << b)) == 0); }

// CHECK-LABEL: @test_bit_3_i128
// CHECK: br_bs %r1, %r2, [[TARGET:.LBB[0-9]+_[0-9]+]]
void test_bit_3_i128(i128 a, i128 b) { CHECK_BRANCH((a >> b) & 1); }

// CHECK-LABEL: @test_bit_4_i128
// CHECK: br_bc_imm %r1, 15, [[TARGET:.LBB[0-9]+_[0-9]+]]
void test_bit_4_i128_4(i128 a) { CHECK_BRANCH(((a >> 15) & 1) == 0); }

// CHECK-LABEL: @test_bit_5_i128
// CHECK: br_bs_imm %r1, 14, [[TARGET:.LBB[0-9]+_[0-9]+]]
void test_bit_5_i128(i128 a) { CHECK_BRANCH(((a >> 14) & 1) == 1); }

