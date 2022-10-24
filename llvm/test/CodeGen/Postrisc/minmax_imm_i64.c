// RUN: clang %cflags %s | FileCheck %s
// REQUIRES: postrisc-registered-target

#include "common.h"

//////////////////////////////////////////////////////////////////
// 64 bit reg-imm min
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_i64_min_lt_imm
// CHECK: min_imm_i64 %r1, %r1, 1000
i64 test_i64_min_lt_imm(i64 a) { return a < 1000 ? a : 1000; }

// CHECK-LABEL: @test_u64_min_lt_imm
// CHECK: min_imm_u64 %r1, %r1, 1000
u64 test_u64_min_lt_imm(u64 a) { return a < 1000 ? a : 1000; }

// CHECK-LABEL: @test_i64_min_le_imm
// CHECK: min_imm_i64 %r1, %r1, 1000
i64 test_i64_min_le_imm(i64 a) { return a <= 1000 ? a : 1000; }

// CHECK-LABEL: @test_u64_min_le_imm
// CHECK: min_imm_u64 %r1, %r1, 1000
u64 test_u64_min_le_imm(u64 a) { return a <= 1000 ? a : 1000; }

// CHECK-LABEL: @test_i64_min_gt_imm
// CHECK: min_imm_i64 %r1, %r1, 1000
i64 test_i64_min_gt_imm(i64 a) { return 1000 > a ? a : 1000; }

// CHECK-LABEL: @test_u64_min_gt_imm
// CHECK: min_imm_u64 %r1, %r1, 1000
u64 test_u64_min_gt_imm(u64 a) { return 1000 > a ? a : 1000; }

// CHECK-LABEL: @test_i64_min_ge_imm
// CHECK: min_imm_i64 %r1, %r1, 1000
i64 test_i64_min_ge_imm(i64 a) { return 1000 >= a ? a : 1000; }

// CHECK-LABEL: @test_u64_min_ge_imm
// CHECK: min_imm_u64 %r1, %r1, 1000
u64 test_u64_min_ge_imm(u64 a) { return 1000 >= a ? a : 1000; }

//////////////////////////////////////////////////////////////////
// 64 bit reg-long_imm min
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_i64_min_lt_imm_ext
// CHECK: min_imm_i64.l %r1, %r1, 1000000000
i64 test_i64_min_lt_imm_ext(i64 a) { return a < 1000000000 ? a : 1000000000; }

// CHECK-LABEL: @test_u64_min_lt_imm_ext
// CHECK: min_imm_u64.l %r1, %r1, 1000000000
u64 test_u64_min_lt_imm_ext(u64 a) { return a < 1000000000 ? a : 1000000000; }

// CHECK-LABEL: @test_i64_min_le_imm_ext
// CHECK: min_imm_i64.l %r1, %r1, 1000000000
i64 test_i64_min_le_imm_ext(i64 a) { return a <= 1000000000 ? a : 1000000000; }

// CHECK-LABEL: @test_u64_min_le_imm_ext
// CHECK: min_imm_u64.l %r1, %r1, 1000000000
u64 test_u64_min_le_imm_ext(u64 a) { return a <= 1000000000 ? a : 1000000000; }

// CHECK-LABEL: @test_i64_min_gt_imm_ext
// CHECK: min_imm_i64.l %r1, %r1, 1000000000
i64 test_i64_min_gt_imm_ext(i64 a) { return 1000000000 > a ? a : 1000000000; }

// CHECK-LABEL: @test_u64_min_gt_imm_ext
// CHECK: min_imm_u64.l %r1, %r1, 1000000000
u64 test_u64_min_gt_imm_ext(u64 a) { return 1000000000 > a ? a : 1000000000; }

// CHECK-LABEL: @test_i64_min_ge_imm_ext
// CHECK: min_imm_i64.l %r1, %r1, 1000000000
i64 test_i64_min_ge_imm_ext(i64 a) { return 1000000000 >= a ? a : 1000000000; }

// CHECK-LABEL: @test_u64_min_ge_imm_ext
// CHECK: min_imm_u64.l %r1, %r1, 1000000000
u64 test_u64_min_ge_imm_ext(u64 a) { return 1000000000 >= a ? a : 1000000000; }

//////////////////////////////////////////////////////////////////
// 64 bit reg-imm max
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_i64_max_lt_imm
// CHECK: max_imm_i64 %r1, %r1, 1000
i64 test_i64_max_lt_imm(i64 a) { return a < 1000 ? 1000 : a; }

// CHECK-LABEL: @test_u64_max_lt_imm
// CHECK: max_imm_u64 %r1, %r1, 1000
u64 test_u64_max_lt_imm(u64 a) { return a < 1000 ? 1000 : a; }

// CHECK-LABEL: @test_i64_max_le_imm
// CHECK: max_imm_i64 %r1, %r1, 1000
i64 test_i64_max_le_imm(i64 a) { return a <= 1000 ? 1000 : a; }

// CHECK-LABEL: @test_u64_max_le_imm
// CHECK: max_imm_u64 %r1, %r1, 1000
u64 test_u64_max_le_imm(u64 a) { return a <= 1000 ? 1000 : a; }

// CHECK-LABEL: @test_i64_max_gt_imm
// CHECK: max_imm_i64 %r1, %r1, 1000
i64 test_i64_max_gt_imm(i64 a) { return 1000 > a ? 1000 : a; }

// CHECK-LABEL: @test_u64_max_gt_imm
// CHECK: max_imm_u64 %r1, %r1, 1000
u64 test_u64_max_gt_imm(u64 a) { return 1000 > a ? 1000 : a; }

// CHECK-LABEL: @test_i64_max_ge_imm
// CHECK: max_imm_i64 %r1, %r1, 1000
i64 test_i64_max_ge_imm(i64 a) { return 1000 >= a ? 1000 : a; }

// CHECK-LABEL: @test_u64_max_ge_imm
// CHECK: max_imm_u64 %r1, %r1, 1000
u64 test_u64_max_ge_imm(u64 a) { return 1000 >= a ? 1000 : a; }


//////////////////////////////////////////////////////////////////
// 64 bit reg-long_imm max
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_i64_max_lt_imm_ext
// CHECK: max_imm_i64.l %r1, %r1, 1000000000
i64 test_i64_max_lt_imm_ext(i64 a) { return a < 1000000000 ? 1000000000 : a; }

// CHECK-LABEL: @test_u64_max_lt_imm_ext
// CHECK: max_imm_u64.l %r1, %r1, 1000000000
u64 test_u64_max_lt_imm_ext(u64 a) { return a < 1000000000 ? 1000000000 : a; }

// CHECK-LABEL: @test_i64_max_le_imm_ext
// CHECK: max_imm_i64.l %r1, %r1, 1000000000
i64 test_i64_max_le_imm_ext(i64 a) { return a <= 1000000000 ? 1000000000 : a; }

// CHECK-LABEL: @test_u64_max_le_imm_ext
// CHECK: max_imm_u64.l %r1, %r1, 1000000000
u64 test_u64_max_le_imm_ext(u64 a) { return a <= 1000000000 ? 1000000000 : a; }

// CHECK-LABEL: @test_i64_max_gt_imm_ext
// CHECK: max_imm_i64.l %r1, %r1, 1000000000
i64 test_i64_max_gt_imm_ext(i64 a) { return 1000000000 > a ? 1000000000 : a; }

// CHECK-LABEL: @test_u64_max_gt_imm_ext
// CHECK: max_imm_u64.l %r1, %r1, 1000000000
u64 test_u64_max_gt_imm_ext(u64 a) { return 1000000000 > a ? 1000000000 : a; }

// CHECK-LABEL: @test_i64_max_ge_imm_ext
// CHECK: max_imm_i64.l %r1, %r1, 1000000000
i64 test_i64_max_ge_imm_ext(i64 a) { return 1000000000 >= a ? 1000000000 : a; }

// CHECK-LABEL: @test_u64_max_ge_imm_ext
// CHECK: max_imm_u64.l %r1, %r1, 1000000000
u64 test_u64_max_ge_imm_ext(u64 a) { return 1000000000 >= a ? 1000000000 : a; }
