// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

typedef struct {
    i32 padding[8];
    i64 p[3];
    i32 padding2[3];
    i32 ctr;
} anim_t;

// CHECK-LABEL: @load_test_struct_array
// CHECK: alloc 3
// CHECK-NEXT: ld_i32 %r2, %r1, 68
// CHECK-NEXT: ld_xi64_u64 %r1, %r1, %r2, 3, 32
// CHECK: retf 0
i64 load_test_struct_array(anim_t *ptr)
{
    return ptr->p[ptr->ctr];
}

// CHECK-LABEL: @load_test_unsigned
// CHECK: alloc 3
// CHECK-NEXT: ld_xu32_u32 %r1, %r1, %r2, 2, 3
// CHECK-NEXT: retf 0
i32 load_test_unsigned(i32 *ptr, u32 index)
{
    return ptr[index + 3];
}

// CHECK-LABEL: @load_test_signed
// CHECK: alloc 3
// CHECK-NEXT: ld_xi32_u32 %r1, %r1, %r2, 2, 12
// CHECK-NEXT: retf 0
i32 load_test_signed(i32 *ptr, i32 index)
{
    return ptr[index + 3];
}
