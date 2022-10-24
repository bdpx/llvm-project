// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_fneg_f32
// CHECK: fnegss %r1, %r1
f32 test_fneg_f32(f32 value) { return -value; }

// CHECK-LABEL: @test_fabs_f32
// CHECK: fabsss %r1, %r1
f32 test_fabs_f32(f32 value) { return __builtin_fabsf(value); }

// CHECK-LABEL: @test_fnabs_f32
// CHECK: fnabsss %r1, %r1
f32 test_fnabs_f32(f32 value) { return - __builtin_fabsf(value); }

// CHECK-LABEL: @test_fabsd_f32
// CHECK: fabsdss %r1, %r1
f32 test_fabsd_f32(f32 a, f32 b) { return __builtin_fabsf(a - b); }

// CHECK-LABEL: @test_fnabsd_f32
// CHECK: fnabsdss %r1, %r1
f32 test_fnabsd_f32(f32 a, f32 b) { return - __builtin_fabsf(a - b); }


// CHECK-LABEL: @test_fneg_f64
// CHECK: fnegsd %r1, %r1
f64 test_fneg_f64(f64 value) { return -value; }

// CHECK-LABEL: @test_fabs_f64
// CHECK: fabssd %r1, %r1
f64 test_fabs_f64(f64 value) { return __builtin_fabs(value); }

// CHECK-LABEL: @test_fnabs_f64
// CHECK: fnabssd %r1, %r1
f64 test_fnabs_f64(f64 value) { return - __builtin_fabs(value); }

// CHECK-LABEL: @test_fabsd_f64
// CHECK: fabsdsd %r1, %r1
f64 test_fabsd_f64(f64 a, f64 b) { return __builtin_fabs(a - b); }

// CHECK-LABEL: @test_fnabsd_f64
// CHECK: fnabsdsd %r1, %r1
f64 test_fnabsd_f64(f64 a, f64 b) { return - __builtin_fabs(a - b); }


// CHECK-LABEL: @test_fneg_f128
// CHECK: fnegsq %r1, %r1
f128 test_fneg_f128(f128 value) { return -value; }

// CHECK-LABEL: @test_fabs_f128
// CHECK: fabssq %r1, %r1
f128 test_fabs_f128(f128 value) { return __builtin_fabsl(value); }

// CHECK-LABEL: @test_fnabs_f128
// CHECK: fnabssq %r1, %r1
f128 test_fnabs_f128(f128 value) { return - __builtin_fabsl(value); }

// CHECK-LABEL: @test_fabsd_f128
// CHECK: fabsdsq %r1, %r1
f128 test_fabsd_f128(f128 a, f128 b) { return __builtin_fabsl(a - b); }

// CHECK-LABEL: @test_fnabsd_f128
// CHECK: fnabsdsq %r1, %r1
f128 test_fnabsd_f128(f128 a, f128 b) { return - __builtin_fabsl(a - b); }
