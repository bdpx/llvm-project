// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_divide_pow2_32
// CHECK: srd_i32 %r1, %r1, %r2
i32 test_divide_pow2_32(i32 a, i32 b) { return a / (1 << b); }

// CHECK-LABEL: @test_divide_pow2_imm_32
// CHECK: srd_imm_i32 %r1, %r1, 10
i32 test_divide_pow2_imm_32(i32 a) { return a / 1024; }


// CHECK-LABEL: @test_divide_pow2_64
// CHECK: srd_i64 %r1, %r1, %r2
i64 test_divide_pow2_64(i64 a, i64 b) { return a / (1LL << b); }

// CHECK-LABEL: @test_divide_pow2_imm_64
// CHECK: srd_imm_i64 %r1, %r1, 10
i64 test_divide_pow2_imm_64(i64 a) { return a / 1024; }


