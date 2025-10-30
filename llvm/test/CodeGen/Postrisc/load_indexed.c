// RUN: clang %cflags %s | FileCheck %s
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_base_index_u32_u32
// CHECK: divu.w %r2, %r2, %r3
// CHECK-NEXT: ldz.d.xuw %r1, %r1, %r2, 3, 0
i64 test_base_index_u32_u32(i64 *a, u32 index, u32 dive)
{
   u32 temp = index / dive;
   return a[temp];
}

// CHECK-LABEL: @test_base_address
i64 test_base_address(i64 *a, i64 index, complex *cc, i64 jndex)
{
   return a[100000000000] + a[1000] + a[index+100000000] + a[jndex+10] + cc[index+10].re + cc[jndex+100].im;
}

void MemoryIndexed(i64 c[], i64 d[], i64 len)
{
    for (i64 i=0; i<len; i++) {
        i64 x = c[i];
        c[i] = d[2U*x+5];
    }
}

// CHECK-LABEL: @test_base_index_i32
// CHECK: ldz.d.xw %r1, %r1, %r2, 3, 0
i64 test_base_index_i32(i64 *a, i32 index)
{
   return a[index];
}

// CHECK-LABEL: @test_base_index_i32_offset
// CHECK: ldz.d.xw %r1, %r1, %r2, 3, 40
i64 test_base_index_i32_offset(i64 *a, i32 index)
{
   return a[index+5];
}

// CHECK-LABEL: @test_base_index_u32
// CHECK: ldz.d.xuw %r1, %r1, %r2, 3, 0
i64 test_base_index_u32(i64 *a, u32 index)
{
   return a[index];
}

// CHECK-LABEL: @test_base_index_u32_offset
// CHECK: addi.ws %r2, %r2, 20
// CHECK: ldz.d.xuw %r1, %r1, %r2, 3, 0
i64 test_base_index_u32_offset(i64 *a, u32 index)
{
   return a[index+20];
}

// CHECK-LABEL: @test_base_index_i64
// CHECK: ldz.d.xd %r1, %r1, %r2, 3, 40
i64 test_base_index_i64(i64 *a, i64 index)
{
   return a[index+5];
}

// FIXME:
// base + ext(i32 + off32) * scale + off64
// base + ext(i32) + off32 * scale + off64

// CHECK-LABEL: @test_base_index_i32_struct
// CHECK: ldz.d.xw.l %r1, %r1, %r2, 4, 328
i64 test_base_index_i32_struct(complex *a, i32 index)
{
   return a[index+20].im;
}

// CHECK-LABEL: @test_base_index_u32_struct
// CHECK: addi.ws %r2, %r2, 20
// CHECK-NEXT: ldz.d.xuw %r1, %r1, %r2, 4, 8
i64 test_base_index_u32_struct(complex *a, u32 index)
{
   return a[index+20].im;
}
