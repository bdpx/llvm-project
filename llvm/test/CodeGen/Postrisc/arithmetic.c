// RUN: clang %cflags %s | FileCheck %s
// REQUIRES: postrisc-registered-target

//  -cc1 -triple postrisc -target-cpu pv1 -S -w -o -

#include "common.h"

// CHECK-LABEL: @test_ldi32
// CHECK: ld_imm %r1, 12345778
i32 test_ldi32(void) { i32 a = 12345778; return a; }

// CHECK-LABEL: @test_ldi32_long
// CHECK: ld_imm.l %r1, 987654321
i32 test_ldi32_long(void) { i32 a = 987654321; return a; }

// CHECK-LABEL: @test_ldi64
// CHECK: ld_imm %r1, 12345778
i64 test_ldi64(void) { i64 a = 12345778ull; return a; }

// CHECK-LABEL: @test_ldi64_long
// CHECK: ld_imm.l %r1, 987654321123456789
i64 test_ldi64_long(void) { i64 a = 987654321123456789ull; return a; }

// CHECK-LABEL: @test_subr_i64
// CHECK: subr_imm_i64 %r1, %r1, 1234
i64 test_subr_i64(i64 a) { return 1234 - a; }

// CHECK-LABEL: @test_subr_i32
// CHECK: subr_imm_i32 %r1, %r1, 1234
i32 test_subr_i32(i32 a) { return 1234 - a; }

i64 test_addil(i64 a)
{
   i64 b = 9200848539817279407ull;
   a += 123456789123456789ull;
   a |= b;
   return a;
}

i64 test_andil(i64 a)
{
   a &= 123456789123456789ull;
   return a;
}

i64 test_oril(i64 a)
{
   a |= 987654321123456789ull;
   return a;
}

i64 test_addadd(i64 a, i64 b, i64 c)
{
   return a + b + c;
}

i64 test_addsub(i64 a, i64 b, i64 c)
{
   return a + b - c;
}

i64 test_subsub(i64 a, i64 b, i64 c)
{
   return a - b - c;
}


// CHECK-LABEL: @test_mul_i32_i32
// CHECK: mul_i32 %r1, %r2, %r1
// retf 0
i32 test_mul_i32_i32(i32 a, i32 b) { return a * b; }

// CHECK-LABEL: @test_mul_i32_imm
// CHECK: mul_imm_i32 %r1, %r1, 98765
i32 test_mul_i32_imm(i32 a) { return a * 98765; }

// CHECK-LABEL: @test_mul_i32_imm_ext
// CHECK: mul_imm_i32.l %r1, %r1, 98765432
i32 test_mul_i32_imm_ext(i32 a) { return a * 98765432; }

// CHECK-LABEL: @test_mul_u32_imm
// FIXME: mul_imm_u32?
// CHECK: mul_imm_i32 %r1, %r1, 98765
u32 test_mul_u32_imm(u32 a) { return a * 98765U; }

// CHECK-LABEL: @test_mul_u32_imm_ext
// FIXME: mul_imm_u32.l?
// CHECK: mul_imm_i32.l %r1, %r1, 98765432
u32 test_mul_u32_imm_ext(u32 a) { return a * 98765432U; }

// CHECK-LABEL: @test_mul_i32_i64
// CHECK: mul_i32 %r1, %r2, %r1
// retf 0
i64 test_mul_i32_i64(i32 a, i32 b) { return a * b; }

// CHECK-LABEL: @test_mul_u32_u64
// CHECK: mul_u32 %r1, %r2, %r1
// CHECK-NEXT: retf 0
u64 test_mul_u32_u64(u32 a, u32 b) { return a * b; }

// CHECK-LABEL: @test_mul_i32_u64
// FIXME: mul_u32?
// CHECK: mul_i32 %r1, %r2, %r1
// retf 0
u64 test_mul_i32_u64(i32 a, i32 b) { return a * b; }

// CHECK-LABEL: @test_mul_i32_i64_imm
// CHECK: mul_imm_i32 %r1, %r1, 98765
i64 test_mul_i32_i64_imm(i32 a) { return a * 98765; }

// CHECK-LABEL: @test_mul_i32_i64_imm_ext
// CHECK: mul_imm_i32.l %r1, %r1, 98765432
i64 test_mul_i32_i64_imm_ext(i32 a) { return a * 98765432; }

// CHECK-LABEL: @test_mul_u32_u64_imm
// CHECK: mul_imm_u32 %r1, %r1, 98765
u64 test_mul_u32_u64_imm(u32 a) { return a * 98765U; }

// CHECK-LABEL: @test_mul_u32_u64_imm_ext
// CHECK: mul_imm_u32.l %r1, %r1, 98765432
u64 test_mul_u32_u64_imm_ext(u32 a) { return a * 98765432U; }

// CHECK-LABEL: @test_mul_i64_i64
// CHECK: mul_i64 %r1, %r2, %r1
// retf 0
i64 test_mul_i64_i64(i64 a, i64 b) { return a * b; }
