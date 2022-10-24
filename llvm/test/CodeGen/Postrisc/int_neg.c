// RUN: clang %cflags %s | FileCheck %s
// REQUIRES: postrisc-registered-target

#include "common.h"

//////////////////////////////////////////////////////////////////
// i32/i64 absolute value, absolute difference
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_neg_i32
// CHECK: neg_i32 %r1, %r1
i32 test_neg_i32(i32 a) { return -a; }

// CHECK-LABEL: @test_neg_i64
// CHECK: neg_i64 %r1, %r1
i64 test_neg_i64(i64 a) {  return -a; }

// CHECK-LABEL: @test_neg_i128
// CHECK: neg_i128 %r1, %r1
i128 test_neg_i128(i128 a) {  return -a; }


