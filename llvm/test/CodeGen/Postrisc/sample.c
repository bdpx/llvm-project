// RUN: clang %cflags -fno-fast-math -ffp-model=strict %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_func
v4i32 test_func(v4i32 a, v4i32 b)
{
    return (a < b);
}
