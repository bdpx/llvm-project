// RUN: clang %cflags %s | FileCheck %s
// REQUIRES: postrisc-registered-target

#include "common.h"

//////////////////////////////////////////////////////////////////
// 32 bit reg-imm min
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_i32_min_lt_imm
// CHECK: min_imm_i32 %r1, %r1, 1000
i32 test_i32_min_lt_imm(i32 a) { return a < 1000 ? a : 1000; }

// CHECK-LABEL: @test_u32_min_lt_imm
// CHECK: min_imm_u32 %r1, %r1, 1000
u32 test_u32_min_lt_imm(u32 a) { return a < 1000 ? a : 1000; }

// CHECK-LABEL: @test_i32_min_le_imm
// CHECK: min_imm_i32 %r1, %r1, 1000
i32 test_i32_min_le_imm(i32 a) { return a <= 1000 ? a : 1000; }

// CHECK-LABEL: @test_u32_min_le_imm
// CHECK: min_imm_u32 %r1, %r1, 1000
u32 test_u32_min_le_imm(u32 a) { return a <= 1000 ? a : 1000; }

// CHECK-LABEL: @test_i32_min_gt_imm
// CHECK: min_imm_i32 %r1, %r1, 1000
i32 test_i32_min_gt_imm(i32 a) { return 1000 > a ? a : 1000; }

// CHECK-LABEL: @test_u32_min_gt_imm
// CHECK: min_imm_u32 %r1, %r1, 1000
u32 test_u32_min_gt_imm(u32 a) { return 1000 > a ? a : 1000; }

// CHECK-LABEL: @test_i32_min_ge_imm
// CHECK: min_imm_i32 %r1, %r1, 1000
i32 test_i32_min_ge_imm(i32 a) { return 1000 >= a ? a : 1000; }

// CHECK-LABEL: @test_u32_min_ge_imm
// CHECK: min_imm_u32 %r1, %r1, 1000
u32 test_u32_min_ge_imm(u32 a) { return 1000 >= a ? a : 1000; }

//////////////////////////////////////////////////////////////////
// 32 bit reg-long_imm min
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_i32_min_lt_imm_ext
// CHECK: min_imm_i32.l %r1, %r1, 1000000000
i32 test_i32_min_lt_imm_ext(i32 a) { return a < 1000000000 ? a : 1000000000; }

// CHECK-LABEL: @test_u32_min_lt_imm_ext
// CHECK: min_imm_u32.l %r1, %r1, 1000000000
u32 test_u32_min_lt_imm_ext(u32 a) { return a < 1000000000 ? a : 1000000000; }

// CHECK-LABEL: @test_i32_min_le_imm_ext
// CHECK: min_imm_i32.l %r1, %r1, 1000000000
i32 test_i32_min_le_imm_ext(i32 a) { return a <= 1000000000 ? a : 1000000000; }

// CHECK-LABEL: @test_u32_min_le_imm_ext
// CHECK: min_imm_u32.l %r1, %r1, 1000000000
u32 test_u32_min_le_imm_ext(u32 a) { return a <= 1000000000 ? a : 1000000000; }

// CHECK-LABEL: @test_i32_min_gt_imm_ext
// CHECK: min_imm_i32.l %r1, %r1, 1000000000
i32 test_i32_min_gt_imm_ext(i32 a) { return 1000000000 > a ? a : 1000000000; }

// CHECK-LABEL: @test_u32_min_gt_imm_ext
// CHECK: min_imm_u32.l %r1, %r1, 1000000000
u32 test_u32_min_gt_imm_ext(u32 a) { return 1000000000 > a ? a : 1000000000; }

// CHECK-LABEL: @test_i32_min_ge_imm_ext
// CHECK: min_imm_i32.l %r1, %r1, 1000000000
i32 test_i32_min_ge_imm_ext(i32 a) { return 1000000000 >= a ? a : 1000000000; }

// CHECK-LABEL: @test_u32_min_ge_imm_ext
// CHECK: min_imm_u32.l %r1, %r1, 1000000000
u32 test_u32_min_ge_imm_ext(u32 a) { return 1000000000 >= a ? a : 1000000000; }

//////////////////////////////////////////////////////////////////
// 32 bit reg-imm max
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_i32_max_lt_imm
// CHECK: max_imm_i32 %r1, %r1, 1000
i32 test_i32_max_lt_imm(i32 a) { return a < 1000 ? 1000 : a; }

// CHECK-LABEL: @test_u32_max_lt_imm
// CHECK: max_imm_u32 %r1, %r1, 1000
u32 test_u32_max_lt_imm(u32 a) { return a < 1000 ? 1000 : a; }

// CHECK-LABEL: @test_i32_max_le_imm
// CHECK: max_imm_i32 %r1, %r1, 1000
i32 test_i32_max_le_imm(i32 a) { return a <= 1000 ? 1000 : a; }

// CHECK-LABEL: @test_u32_max_le_imm
// CHECK: max_imm_u32 %r1, %r1, 1000
u32 test_u32_max_le_imm(u32 a) { return a <= 1000 ? 1000 : a; }

// CHECK-LABEL: @test_i32_max_gt_imm
// CHECK: max_imm_i32 %r1, %r1, 1000
i32 test_i32_max_gt_imm(i32 a) { return 1000 > a ? 1000 : a; }

// CHECK-LABEL: @test_u32_max_gt_imm
// CHECK: max_imm_u32 %r1, %r1, 1000
u32 test_u32_max_gt_imm(u32 a) { return 1000 > a ? 1000 : a; }

// CHECK-LABEL: @test_i32_max_ge_imm
// CHECK: max_imm_i32 %r1, %r1, 1000
i32 test_i32_max_ge_imm(i32 a) { return 1000 >= a ? 1000 : a; }

// CHECK-LABEL: @test_u32_max_ge_imm
// CHECK: max_imm_u32 %r1, %r1, 1000
u32 test_u32_max_ge_imm(u32 a) { return 1000 >= a ? 1000 : a; }


//////////////////////////////////////////////////////////////////
// 32 bit reg-long_imm max
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_i32_max_lt_imm_ext
// CHECK: max_imm_i32.l %r1, %r1, 1000000000
i32 test_i32_max_lt_imm_ext(i32 a) { return a < 1000000000 ? 1000000000 : a; }

// CHECK-LABEL: @test_u32_max_lt_imm_ext
// CHECK: max_imm_u32.l %r1, %r1, 1000000000
u32 test_u32_max_lt_imm_ext(u32 a) { return a < 1000000000 ? 1000000000 : a; }

// CHECK-LABEL: @test_i32_max_le_imm_ext
// CHECK: max_imm_i32.l %r1, %r1, 1000000000
i32 test_i32_max_le_imm_ext(i32 a) { return a <= 1000000000 ? 1000000000 : a; }

// CHECK-LABEL: @test_u32_max_le_imm_ext
// CHECK: max_imm_u32.l %r1, %r1, 1000000000
u32 test_u32_max_le_imm_ext(u32 a) { return a <= 1000000000 ? 1000000000 : a; }

// CHECK-LABEL: @test_i32_max_gt_imm_ext
// CHECK: max_imm_i32.l %r1, %r1, 1000000000
i32 test_i32_max_gt_imm_ext(i32 a) { return 1000000000 > a ? 1000000000 : a; }

// CHECK-LABEL: @test_u32_max_gt_imm_ext
// CHECK: max_imm_u32.l %r1, %r1, 1000000000
u32 test_u32_max_gt_imm_ext(u32 a) { return 1000000000 > a ? 1000000000 : a; }

// CHECK-LABEL: @test_i32_max_ge_imm_ext
// CHECK: max_imm_i32.l %r1, %r1, 1000000000
i32 test_i32_max_ge_imm_ext(i32 a) { return 1000000000 >= a ? 1000000000 : a; }

// CHECK-LABEL: @test_u32_max_ge_imm_ext
// CHECK: max_imm_u32.l %r1, %r1, 1000000000
u32 test_u32_max_ge_imm_ext(u32 a) { return 1000000000 >= a ? 1000000000 : a; }
