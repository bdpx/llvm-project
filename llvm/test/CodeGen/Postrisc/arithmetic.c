// RUN: clang %cflags %s | FileCheck %s
// REQUIRES: postrisc-registered-target

//  -cc1 -triple postrisc -target-cpu pv1 -S -w -o -

#include "common.h"

// CHECK-LABEL: @test_ldi32
// CHECK: ldi %r1, 12345778
i32 test_ldi32(void) { i32 a = 12345778; return a; }

// CHECK-LABEL: @test_ldi32_long
// CHECK: ldi.l %r1, 987654321
i32 test_ldi32_long(void) { i32 a = 987654321; return a; }

// CHECK-LABEL: @test_ldi64
// CHECK: ldi %r1, 12345778
i64 test_ldi64(void) { i64 a = 12345778ull; return a; }

// CHECK-LABEL: @test_ldi64_long
// CHECK: ldi.l %r1, 987654321123456789
i64 test_ldi64_long(void) { i64 a = 987654321123456789ull; return a; }

// CHECK-LABEL: @test_subfi_i64
// CHECK: subfi %r1, %r1, 1234
i64 test_subfi_i64(i64 a) { return 1234 - a; }

// CHECK-LABEL: @test_subfi_i32
// CHECK: subfi.ws %r1, %r1, 1234
i32 test_subfi_i32(i32 a) { return 1234 - a; }

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
// CHECK: mul.ws %r1, %r2, %r1
// ret.f 0
i32 test_mul_i32_i32(i32 a, i32 b) { return a * b; }

// CHECK-LABEL: @test_mul_i32_imm
// CHECK: muli.ws %r1, %r1, 98765
i32 test_mul_i32_imm(i32 a) { return a * 98765; }

// CHECK-LABEL: @test_mul_i32_imm_ext
// CHECK: muli.ws.l %r1, %r1, 98765432
i32 test_mul_i32_imm_ext(i32 a) { return a * 98765432; }

// CHECK-LABEL: @test_mul_u32_imm
// FIXME: muli.wz?
// CHECK: muli.ws %r1, %r1, 98765
u32 test_mul_u32_imm(u32 a) { return a * 98765U; }

// CHECK-LABEL: @test_mul_u32_imm_ext
// FIXME: muli.wz.l?
// CHECK: muli.ws.l %r1, %r1, 98765432
u32 test_mul_u32_imm_ext(u32 a) { return a * 98765432U; }

// CHECK-LABEL: @test_mul_i32_i64
// CHECK: mul.ws %r1, %r2, %r1
// ret.f 0
i64 test_mul_i32_i64(i32 a, i32 b) { return a * b; }

// CHECK-LABEL: @test_mul_u32_u64
// CHECK: mul.wz %r1, %r2, %r1
// CHECK-NEXT: ret.f 0
u64 test_mul_u32_u64(u32 a, u32 b) { return a * b; }

// CHECK-LABEL: @test_mul_i32_u64
// FIXME: mul.wz?
// CHECK: mul.ws %r1, %r2, %r1
// ret.f 0
u64 test_mul_i32_u64(i32 a, i32 b) { return a * b; }

// CHECK-LABEL: @test_mul_i32_i64_imm
// CHECK: muli.ws %r1, %r1, 98765
i64 test_mul_i32_i64_imm(i32 a) { return a * 98765; }

// CHECK-LABEL: @test_mul_i32_i64_imm_ext
// CHECK: muli.ws.l %r1, %r1, 98765432
i64 test_mul_i32_i64_imm_ext(i32 a) { return a * 98765432; }

// CHECK-LABEL: @test_mul_u32_u64_imm
// CHECK: muli.wz %r1, %r1, 98765
u64 test_mul_u32_u64_imm(u32 a) { return a * 98765U; }

// CHECK-LABEL: @test_mul_u32_u64_imm_ext
// CHECK: muli.wz.l %r1, %r1, 98765432
u64 test_mul_u32_u64_imm_ext(u32 a) { return a * 98765432U; }

// CHECK-LABEL: @test_mul_i64_i64
// CHECK: mul %r1, %r2, %r1
// ret.f 0
i64 test_mul_i64_i64(i64 a, i64 b) { return a * b; }

// CHECK-LABEL: @test_div_i32
// CHECK: div.w %r1, %r1, %r2
i32 test_div_i32(i32 a, i32 b) { return a / b; }
// CHECK-LABEL: @test_div_i64
// CHECK: div %r1, %r1, %r2
i64 test_div_i64(i64 a, i64 b) { return a / b; }
// CHECK-LABEL: @test_div_u32
// CHECK: divu.w %r1, %r1, %r2
u32 test_div_u32(u32 a, u32 b) { return a / b; }
// CHECK-LABEL: @test_div_u64
// CHECK: divu %r1, %r1, %r2
u64 test_div_u64(u64 a, u64 b) { return a / b; }

// CHECK-LABEL: @test_mod_i32
// CHECK: mod.w %r1, %r1, %r2
i32 test_mod_i32(i32 a, i32 b) { return a % b; }
// CHECK-LABEL: @test_mod_i64
// CHECK: mod %r1, %r1, %r2
i64 test_mod_i64(i64 a, i64 b) { return a % b; }
// CHECK-LABEL: @test_mod_u32
// CHECK: modu.w %r1, %r1, %r2
u32 test_mod_u32(u32 a, u32 b) { return a % b; }
// CHECK-LABEL: @test_mod_u64
// CHECK: modu %r1, %r1, %r2
u64 test_mod_u64(u64 a, u64 b) { return a % b; }

// CHECK-LABEL: @test_mod_imm_i64
// CHECK: modi %r1, %r1, 100
i64 test_mod_imm_i64(i64 a) { return a % 100; }
// CHECK-LABEL: @test_mod_imm_u64
// CHECK: modui %r1, %r1, 100
u64 test_mod_imm_u64(u64 a) { return a % 100; }
// CHECK-LABEL: @test_mod_imm_ext_i64
// CHECK: modi.l %r1, %r1, 1000000000
i64 test_mod_imm_ext_i64(i64 a) { return a % 1000000000; }
// CHECK-LABEL: @test_mod_imm_ext_u64
// CHECK: modui.l %r1, %r1, 1000000000
u64 test_mod_imm_ext_u64(u64 a) { return a % 1000000000; }
