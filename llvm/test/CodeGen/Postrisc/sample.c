// RUN: clang %cflags -fno-fast-math -ffp-model=strict %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_cmov_lsb
i32 test_cmov_lsb(i32 a, i32 b, i32 c)
{
    return (a & 1) ? b : c;
}

// CHECK-LABEL: @test_signbit_f16_bool
// CHECK: alloc_sp 2, 16
// CHECK: st_i16 %r1, %sp, 14
// CHECK: ld_u16 %r1, %sp, 14
// CHECK: srl_imm_u32 %r1, %r1, 15
// CHECK: retf 16
bool test_signbit_f16_bool(f16 x)
{
    return __builtin_signbitf16(x);
}

struct bitfield_sample {
    u32    x:12;
    u32    y:10;
    u32    z:10;
};

// CHECK-LABEL: @test_bitfield_sample
// CHECK: ld_u32 %r2, %r1, 0
// CHECK: deposit %r2, %r2, %r3, 12, 10
// CHECK: st_i32 %r2, %r1, 0
void test_bitfield_sample(struct bitfield_sample *sample, u32 x, u32 y, u32 z)
{
    //sample->x = x;
    sample->y = y;
    //sample->z = z;
}

// CHECK-LABEL: @test_deposit
// CHECK: alloc 3
// CHECK-NEXT: deposit %r1, %r1, %r2, 4, 12
// CHECK-NEXT: retf 0
u32 test_deposit(u32 a, u32 b)
{
    return (a & 0xFFFF000F) | ((b << 4) & 0xFFF0);
}

// FIXME: bug in clang/llvm (__builtin_isinf_sign is identical to __builtin_isinf)
// CHECK-LABEL: @test_classify_f64___builtin_isinf_sign
// CHECK: alloc 2
// CHECK-NEXT: class_f64 %r1, %r1, 516
// CHECK-NEXT: retf 0
bool test_classify_f64___builtin_isinf_sign(f64 a)
{
    return __builtin_isinf_sign(a);
}


// CHECK-LABEL: @test_add_wrong_rm
// CHECK: alloc 3
// CHECK-NEXT: add_f64 %r1, %r1, %r2, rne
// CHECK-NEXT: retf 0
f64 test_add_wrong_rm(f64 a, f64 b)
{
    return __builtin_postrisc_add_f64(a, b, __POSTRISC_RM_RNE);
}
