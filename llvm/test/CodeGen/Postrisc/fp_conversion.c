// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

//===----------------------------------------------------------------------===//
// fp extend to wider
//===----------------------------------------------------------------------===//

// CHECK-LABEL: @test_conv_f16_to_f32
// CHECK: extend_f16_f32 %r1, %r1
f32 test_conv_f16_to_f32(f16 value) { return value; }
// CHECK-LABEL: @test_conv_f16_to_f64
// CHECK: extend_f16_f64 %r1, %r1
f64 test_conv_f16_to_f64(f16 value) { return value; }
// CHECK-LABEL: @test_conv_f16_to_f128
// CHECK: extend_f16_f128 %r1, %r1
f128 test_conv_f16_to_f128(f16 value) { return value; }
// CHECK-LABEL: @test_conv_f64_to_f128
// CHECK: extend_f64_f128 %r1, %r1
f128 test_conv_f64_to_f128(f64 value) { return value; }
// CHECK-LABEL: @test_conv_f32_to_f64
// CHECK: extend_f32_f64 %r1, %r1
f64 test_conv_f32_to_f64(f32 value) { return value; }
// CHECK-LABEL: @test_conv_f32_to_f128
// CHECK: extend_f32_f128 %r1, %r1
f128 test_conv_f32_to_f128(f32 value) { return value; }

//===----------------------------------------------------------------------===//
// fp round to narrow
//===----------------------------------------------------------------------===//

// CHECK-LABEL: @test_conv_f32_to_f16
// CHECK: cvt_f32_f16 %r1, %r1
f16 test_conv_f32_to_f16(f32 value) { return value; }
// CHECK-LABEL: @test_conv_f64_to_f16
// CHECK: cvt_f64_f16 %r1, %r1
f16 test_conv_f64_to_f16(f64 value) { return value; }
// CHECK-LABEL: @test_conv_f64_to_f32
// CHECK: cvt_f64_f32 %r1, %r1
f32 test_conv_f64_to_f32(f64 value) { return value; }
// CHECK-LABEL: @test_conv_f128_to_f16
// CHECK: cvt_f128_f16 %r1, %r1
f16 test_conv_f128_to_f16(f128 value) { return value; }
// CHECK-LABEL: @test_conv_f128_to_f32
// CHECK: cvt_f128_f32 %r1, %r1
f32 test_conv_f128_to_f32(f128 value) { return value; }
// CHECK-LABEL: @test_conv_f128_to_f64
// CHECK: cvt_f128_f64 %r1, %r1
f64 test_conv_f128_to_f64(f128 value) { return value; }

//===----------------------------------------------------------------------===//
// f16
//===----------------------------------------------------------------------===//

// CHECK-LABEL: @test_conv_f16_to_i32
// CHECK: trunk_f16_i32 %r1, %r1
i32 test_conv_f16_to_i32(f16 value) { return value; }
// CHECK-LABEL: @test_conv_f16_to_u32
// CHECK: trunk_f16_u32 %r1, %r1
u32 test_conv_f16_to_u32(f16 value) { return value; }

// CHECK-LABEL: @test_conv_f16_to_i64
// CHECK: trunk_f16_i64 %r1, %r1
i64 test_conv_f16_to_i64(f16 value) { return value; }
// CHECK-LABEL: @test_conv_f16_to_u64
// CHECK: trunk_f16_u64 %r1, %r1
u64 test_conv_f16_to_u64(f16 value) { return value; }

// CHECK-LABEL: @test_conv_f16_to_i128
// CHECK: trunk_f16_i128 %r1, %r1
i128 test_conv_f16_to_i128(f16 value) { return value; }
// CHECK-LABEL: @test_conv_f16_to_u128
// CHECK: trunk_f16_u128 %r1, %r1
u128 test_conv_f16_to_u128(f16 value) { return value; }

// CHECK-LABEL: @test_conv_i32_to_f16
// CHECK: cvt_i32_f16 %r1, %r1
f16 test_conv_i32_to_f16(i32 value) { return value; }
// CHECK-LABEL: @test_conv_u32_to_f16
// CHECK: cvt_u32_f16 %r1, %r1
f16 test_conv_u32_to_f16(u32 value) { return value; }

// CHECK-LABEL: @test_conv_i64_to_f16
// CHECK: cvt_i64_f16 %r1, %r1
f16 test_conv_i64_to_f16(i64 value) { return value; }
// CHECK-LABEL: @test_conv_u64_to_f16
// CHECK: cvt_u64_f16 %r1, %r1
f16 test_conv_u64_to_f16(u64 value) { return value; }

// CHECK-LABEL: @test_conv_i128_to_f16
// CHECK: cvt_i128_f16 %r1, %r1
f16 test_conv_i128_to_f16(i128 value) { return value; }
// CHECK-LABEL: @test_conv_u128_to_f16
// CHECK: cvt_u128_f16 %r1, %r1
f16 test_conv_u128_to_f16(u128 value) { return value; }

//===----------------------------------------------------------------------===//
// f32
//===----------------------------------------------------------------------===//

// CHECK-LABEL: @test_conv_f32_to_i32
// CHECK: trunk_f32_i32 %r1, %r1
i32 test_conv_f32_to_i32(f32 value) { return value; }
// CHECK-LABEL: @test_conv_f32_to_u32
// CHECK: trunk_f32_u32 %r1, %r1
u32 test_conv_f32_to_u32(f32 value) { return value; }

// CHECK-LABEL: @test_conv_f32_to_i64
// CHECK: trunk_f32_i64 %r1, %r1
i64 test_conv_f32_to_i64(f32 value) { return value; }
// CHECK-LABEL: @test_conv_f32_to_u64
// CHECK: trunk_f32_u64 %r1, %r1
u64 test_conv_f32_to_u64(f32 value) { return value; }

// CHECK-LABEL: @test_conv_f32_to_i128
// CHECK: trunk_f32_i128 %r1, %r1
i128 test_conv_f32_to_i128(f32 value) { return value; }
// CHECK-LABEL: @test_conv_f32_to_u128
// CHECK: trunk_f32_u128 %r1, %r1
u128 test_conv_f32_to_u128(f32 value) { return value; }

// CHECK-LABEL: @test_conv_i32_to_f32
// CHECK: cvt_i32_f32 %r1, %r1
f32 test_conv_i32_to_f32(i32 value) { return value; }
// CHECK-LABEL: @test_conv_u32_to_f32
// CHECK: cvt_u32_f32 %r1, %r1
f32 test_conv_u32_to_f32(u32 value) { return value; }

// CHECK-LABEL: @test_conv_i64_to_f32
// CHECK: cvt_i64_f32 %r1, %r1
f32 test_conv_i64_to_f32(i64 value) { return value; }
// CHECK-LABEL: @test_conv_u64_to_f32
// CHECK: cvt_u64_f32 %r1, %r1
f32 test_conv_u64_to_f32(u64 value) { return value; }

// CHECK-LABEL: @test_conv_i128_to_f32
// CHECK: cvt_i128_f32 %r1, %r1
f32 test_conv_i128_to_f32(i128 value) { return value; }
// CHECK-LABEL: @test_conv_u128_to_f32
// CHECK: cvt_u128_f32 %r1, %r1
f32 test_conv_u128_to_f32(u128 value) { return value; }

//===----------------------------------------------------------------------===//
// f64
//===----------------------------------------------------------------------===//

// CHECK-LABEL: @test_conv_f64_to_i32
// CHECK: trunk_f64_i32 %r1, %r1
i32 test_conv_f64_to_i32(f64 value) { return value; }
// CHECK-LABEL: @test_conv_f64_to_u32
// CHECK: trunk_f64_u32 %r1, %r1
u32 test_conv_f64_to_u32(f64 value) { return value; }

// CHECK-LABEL: @test_conv_f64_to_i64
// CHECK: trunk_f64_i64 %r1, %r1
i64 test_conv_f64_to_i64(f64 value) { return value; }
// CHECK-LABEL: @test_conv_f64_to_u64
// CHECK: trunk_f64_u64 %r1, %r1
u64 test_conv_f64_to_u64(f64 value) { return value; }

// CHECK-LABEL: @test_conv_f64_to_i128
// CHECK: trunk_f64_i128 %r1, %r1
i128 test_conv_f64_to_i128(f64 value) { return value; }
// CHECK-LABEL: @test_conv_f64_to_u128
// CHECK: trunk_f64_u128 %r1, %r1
u128 test_conv_f64_to_u128(f64 value) { return value; }

// CHECK-LABEL: @test_conv_i32_to_f64
// CHECK: cvt_i32_f64 %r1, %r1
f64 test_conv_i32_to_f64(i32 value) { return value; }
// CHECK-LABEL: @test_conv_u32_to_f64
// CHECK: cvt_u32_f64 %r1, %r1
f64 test_conv_u32_to_f64(u32 value) { return value; }

// CHECK-LABEL: @test_conv_i64_to_f64
// CHECK: cvt_i64_f64 %r1, %r1
f64 test_conv_i64_to_f64(i64 value) { return value; }
// CHECK-LABEL: @test_conv_u64_to_f64
// CHECK: cvt_u64_f64 %r1, %r1
f64 test_conv_u64_to_f64(u64 value) { return value; }

// CHECK-LABEL: @test_conv_i128_to_f64
// CHECK: cvt_i128_f64 %r1, %r1
f64 test_conv_i128_to_f64(i128 value) { return value; }
// CHECK-LABEL: @test_conv_u128_to_f64
// CHECK: cvt_u128_f64 %r1, %r1
f64 test_conv_u128_to_f64(u128 value) { return value; }

//===----------------------------------------------------------------------===//
// f128
//===----------------------------------------------------------------------===//

// CHECK-LABEL: @test_conv_f128_to_i32
// CHECK: trunk_f128_i32 %r1, %r1
i32 test_conv_f128_to_i32(f128 value) { return value; }
// CHECK-LABEL: @test_conv_f128_to_u32
// CHECK: trunk_f128_u32 %r1, %r1
u32 test_conv_f128_to_u32(f128 value) { return value; }

// CHECK-LABEL: @test_conv_f128_to_i64
// CHECK: trunk_f128_i64 %r1, %r1
i64 test_conv_f128_to_i64(f128 value) { return value; }
// CHECK-LABEL: @test_conv_f128_to_u64
// CHECK: trunk_f128_u64 %r1, %r1
u64 test_conv_f128_to_u64(f128 value) { return value; }

// CHECK-LABEL: @test_conv_f128_to_i128
// CHECK: trunk_f128_i128 %r1, %r1
i128 test_conv_f128_to_i128(f128 value) { return value; }
// CHECK-LABEL: @test_conv_f128_to_u128
// CHECK: trunk_f128_u128 %r1, %r1
u128 test_conv_f128_to_u128(f128 value) { return value; }

// CHECK-LABEL: @test_conv_i32_to_f128
// CHECK: cvt_i32_f128 %r1, %r1
f128 test_conv_i32_to_f128(i32 value) { return value; }
// CHECK-LABEL: @test_conv_u32_to_f128
// CHECK: cvt_u32_f128 %r1, %r1
f128 test_conv_u32_to_f128(u32 value) { return value; }

// CHECK-LABEL: @test_conv_i64_to_f128
// CHECK: cvt_i64_f128 %r1, %r1
f128 test_conv_i64_to_f128(i64 value) { return value; }
// CHECK-LABEL: @test_conv_u64_to_f128
// CHECK: cvt_u64_f128 %r1, %r1
f128 test_conv_u64_to_f128(u64 value) { return value; }

// CHECK-LABEL: @test_conv_i128_to_f128
// CHECK: cvt_i128_f128 %r1, %r1
f128 test_conv_i128_to_f128(i128 value) { return value; }
// CHECK-LABEL: @test_conv_u128_to_f128
// CHECK: cvt_u128_f128 %r1, %r1
f128 test_conv_u128_to_f128(u128 value) { return value; }
