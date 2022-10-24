// RUN: clang %cflags %s | FileCheck %s
// REQUIRES: postrisc-registered-target

#include "common.h"

//////////////////////////////////////////////////////////////////
// 64 bit reg-reg min
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_i64_min_lt
// CHECK: min_i64 %r1, %r1, %r2
i64 test_i64_min_lt(i64 a, i64 b) { return a < b ? a : b; }

// CHECK-LABEL: @test_u64_min_lt
// CHECK: min_u64 %r1, %r1, %r2
u64 test_u64_min_lt(u64 a, u64 b) { return a < b ? a : b; }

// CHECK-LABEL: @test_i64_min_le
// CHECK: min_i64 %r1, %r1, %r2
i64 test_i64_min_le(i64 a, i64 b) { return a <= b ? a : b; }

// CHECK-LABEL: @test_u64_min_le
// CHECK: min_u64 %r1, %r1, %r2
u64 test_u64_min_le(u64 a, u64 b) { return a <= b ? a : b; }

// CHECK-LABEL: @test_i64_min_gt
// CHECK: min_i64 %r1, %r2, %r1
i64 test_i64_min_gt(i64 a, i64 b) { return b > a ? a : b; }

// CHECK-LABEL: @test_u64_min_gt
// CHECK: min_u64 %r1, %r2, %r1
u64 test_u64_min_gt(u64 a, u64 b) { return b > a ? a : b; }

// CHECK-LABEL: @test_i64_min_ge
// CHECK: min_i64 %r1, %r2, %r1
i64 test_i64_min_ge(i64 a, i64 b) { return b >= a ? a : b; }

// CHECK-LABEL: @test_u64_min_ge
// CHECK: min_u64 %r1, %r2, %r1
u64 test_u64_min_ge(u64 a, u64 b) { return b >= a ? a : b; }

//////////////////////////////////////////////////////////////////
// 64 bit reg-reg max
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_i64_max_lt
// CHECK: max_i64 %r1, %r1, %r2
i64 test_i64_max_lt(i64 a, i64 b) { return a < b ? b : a; }

// CHECK-LABEL: @test_u64_max_lt
// CHECK: max_u64 %r1, %r1, %r2
u64 test_u64_max_lt(u64 a, u64 b) { return a < b ? b : a; }

// CHECK-LABEL: @test_i64_max_le
// CHECK: max_i64 %r1, %r1, %r2
i64 test_i64_max_le(i64 a, i64 b) { return a <= b ? b : a; }

// CHECK-LABEL: @test_u64_max_le
// CHECK: max_u64 %r1, %r1, %r2
u64 test_u64_max_le(u64 a, u64 b) { return a <= b ? b : a; }

// CHECK-LABEL: @test_i64_max_gt
// CHECK: max_i64 %r1, %r2, %r1
i64 test_i64_max_gt(i64 a, i64 b) { return b > a ? b : a; }

// CHECK-LABEL: @test_u64_max_gt
// CHECK: max_u64 %r1, %r2, %r1
u64 test_u64_max_gt(u64 a, u64 b) { return b > a ? b : a; }

// CHECK-LABEL: @test_i64_max_ge
// CHECK: max_i64 %r1, %r2, %r1
i64 test_i64_max_ge(i64 a, i64 b) { return b >= a ? b : a; }

// CHECK-LABEL: @test_u64_max_ge
// CHECK: max_u64 %r1, %r2, %r1
u64 test_u64_max_ge(u64 a, u64 b) { return b >= a ? b : a; }

//////////////////////////////////////////////////////////////////
// 32 bit reg-reg min
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_i32_min_lt
// CHECK: min_i32 %r1, %r1, %r2
i32 test_i32_min_lt(i32 a, i32 b) { return a < b ? a : b; }

// CHECK-LABEL: @test_u32_min_lt
// CHECK: min_u32 %r1, %r1, %r2
u32 test_u32_min_lt(u32 a, u32 b) { return a < b ? a : b; }

// CHECK-LABEL: @test_i32_min_le
// CHECK: min_i32 %r1, %r1, %r2
i32 test_i32_min_le(i32 a, i32 b) { return a <= b ? a : b; }

// CHECK-LABEL: @test_u32_min_le
// CHECK: min_u32 %r1, %r1, %r2
u32 test_u32_min_le(u32 a, u32 b) { return a <= b ? a : b; }

// CHECK-LABEL: @test_i32_min_gt
// CHECK: min_i32 %r1, %r2, %r1
i32 test_i32_min_gt(i32 a, i32 b) { return b > a ? a : b; }

// CHECK-LABEL: @test_u32_min_gt
// CHECK: min_u32 %r1, %r2, %r1
u32 test_u32_min_gt(u32 a, u32 b) { return b > a ? a : b; }

// CHECK-LABEL: @test_i32_min_ge
// CHECK: min_i32 %r1, %r2, %r1
i32 test_i32_min_ge(i32 a, i32 b) { return b >= a ? a : b; }

// CHECK-LABEL: @test_u32_min_ge
// CHECK: min_u32 %r1, %r2, %r1
u32 test_u32_min_ge(u32 a, u32 b) { return b >= a ? a : b; }

//////////////////////////////////////////////////////////////////
// 32 bit reg-reg max
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_i32_max_lt
// CHECK: max_i32 %r1, %r1, %r2
i32 test_i32_max_lt(i32 a, i32 b) { return a < b ? b : a; }

// CHECK-LABEL: @test_u32_max_lt
// CHECK: max_u32 %r1, %r1, %r2
u32 test_u32_max_lt(u32 a, u32 b) { return a < b ? b : a; }

// CHECK-LABEL: @test_i32_max_le
// CHECK: max_i32 %r1, %r1, %r2
i32 test_i32_max_le(i32 a, i32 b) { return a <= b ? b : a; }

// CHECK-LABEL: @test_u32_max_le
// CHECK: max_u32 %r1, %r1, %r2
u32 test_u32_max_le(u32 a, u32 b) { return a <= b ? b : a; }

// CHECK-LABEL: @test_i32_max_gt
// CHECK: max_i32 %r1, %r2, %r1
i32 test_i32_max_gt(i32 a, i32 b) { return b > a ? b : a; }

// CHECK-LABEL: @test_u32_max_gt
// CHECK: max_u32 %r1, %r2, %r1
u32 test_u32_max_gt(u32 a, u32 b) { return b > a ? b : a; }

// CHECK-LABEL: @test_i32_max_ge
// CHECK: max_i32 %r1, %r2, %r1
i32 test_i32_max_ge(i32 a, i32 b) { return b >= a ? b : a; }

// CHECK-LABEL: @test_u32_max_ge
// CHECK: max_u32 %r1, %r2, %r1
u32 test_u32_max_ge(u32 a, u32 b) { return b >= a ? b : a; }

