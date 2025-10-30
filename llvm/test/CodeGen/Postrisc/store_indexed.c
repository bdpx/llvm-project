// RUN: clang %cflags %s | FileCheck %s
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_store_indexed_u32_u32
// CHECK: divu.w %r2, %r2, %r3
// CHECK: st.d.xuw %r4, %r1, %r2, 3, 0 
void test_store_indexed_u32_u32(i64 *a, u32 index, u32 dive, i64 value)
{
   u32 temp = index / dive;
   a[temp] = value;
}

// CHECK-LABEL: @test_store_indexed_i32
// CHECK: st.d.xw %r3, %r1, %r2, 3, 0 
void test_store_indexed_i32(i64 *a, i32 index, i64 value)
{
   a[index] = value;
}

// CHECK-LABEL: @test_store_indexed_i32_offset
// CHECK: st.d.xw %r3, %r1, %r2, 3, 40
void test_store_indexed_i32_offset(i64 *a, i32 index, i64 value)
{
   a[index+5] = value;
}

// CHECK-LABEL: @test_store_indexed_u32
// CHECK: st.d.xuw %r3, %r1, %r2, 3, 0
void test_store_indexed_u32(i64 *a, u32 index, i64 value)
{
   a[index] = value;
}

// CHECK-LABEL: @test_store_indexed_u32_offset
// CHECK: addi.ws %r2, %r2, 20
// CHECK: st.d.xuw %r3, %r1, %r2, 3, 0
void test_store_indexed_u32_offset(i64 *a, u32 index, i64 value)
{
   a[index+20] = value;
}

// CHECK-LABEL: @test_store_indexed_i64
// CHECK: st.d.xd %r3, %r1, %r2, 3, 40
void test_store_indexed_i64(i64 *a, i64 index, i64 value)
{
   a[index+5] = value;
}

// CHECK-LABEL: @test_store_indexed_i32
// CHECK: st.d.xw.l %r3, %r1, %r2, 4, 328
void test_store_indexed_i32_struct(complex *a, i32 index, i64 value)
{
   a[index+20].im = value;
}
