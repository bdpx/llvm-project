// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

//===----------------------------------------------------------------------===//
// fp extend to wider
//===----------------------------------------------------------------------===//

// CHECK-LABEL: @test_conv_f16_to_f32
// CHECK: fextsh2ss %r1, %r1
f32 test_conv_f16_to_f32(f16 value) { return value; }
// CHECK-LABEL: @test_conv_f16_to_f64
// CHECK: fextsh2sd %r1, %r1
f64 test_conv_f16_to_f64(f16 value) { return value; }
// CHECK-LABEL: @test_conv_f16_to_f128
// CHECK: fextsh2sq %r1, %r1
f128 test_conv_f16_to_f128(f16 value) { return value; }
// CHECK-LABEL: @test_conv_f64_to_f128
// CHECK: fextsd2sq %r1, %r1
f128 test_conv_f64_to_f128(f64 value) { return value; }
// CHECK-LABEL: @test_conv_f32_to_f64
// CHECK: fextss2sd %r1, %r1
f64 test_conv_f32_to_f64(f32 value) { return value; }
// CHECK-LABEL: @test_conv_f32_to_f128
// CHECK: fextss2sq %r1, %r1
f128 test_conv_f32_to_f128(f32 value) { return value; }

//===----------------------------------------------------------------------===//
// fp round to narrow
//===----------------------------------------------------------------------===//

// CHECK-LABEL: @test_conv_f32_to_f16
// CHECK: fcvtss2sh %r1, %r1, 0
f16 test_conv_f32_to_f16(f32 value) { return value; }
// CHECK-LABEL: @test_conv_f64_to_f16
// CHECK: fcvtsd2sh %r1, %r1, 0
f16 test_conv_f64_to_f16(f64 value) { return value; }
// CHECK-LABEL: @test_conv_f64_to_f32
// CHECK: fcvtsd2ss %r1, %r1, 0
f32 test_conv_f64_to_f32(f64 value) { return value; }
// CHECK-LABEL: @test_conv_f128_to_f16
// CHECK: fcvtsq2sh %r1, %r1, 0
f16 test_conv_f128_to_f16(f128 value) { return value; }
// CHECK-LABEL: @test_conv_f128_to_f32
// CHECK: fcvtsq2ss %r1, %r1, 0
f32 test_conv_f128_to_f32(f128 value) { return value; }
// CHECK-LABEL: @test_conv_f128_to_f64
// CHECK: fcvtsq2sd %r1, %r1, 0
f64 test_conv_f128_to_f64(f128 value) { return value; }

//===----------------------------------------------------------------------===//
// f16
//===----------------------------------------------------------------------===//

// CHECK-LABEL: @test_conv_f16_to_i32
// CHECK: fcvtsh2iw %r1, %r1, 0
i32 test_conv_f16_to_i32(f16 value) { return value; }
// CHECK-LABEL: @test_conv_f16_to_u32
// CHECK: fcvtsh2uw %r1, %r1, 0
u32 test_conv_f16_to_u32(f16 value) { return value; }

// CHECK-LABEL: @test_conv_f16_to_i64
// CHECK: fcvtsh2id %r1, %r1, 0
i64 test_conv_f16_to_i64(f16 value) { return value; }
// CHECK-LABEL: @test_conv_f16_to_u64
// CHECK: fcvtsh2ud %r1, %r1, 0
u64 test_conv_f16_to_u64(f16 value) { return value; }

// CHECK-LABEL: @test_conv_f16_to_i128
// CHECK: fcvtsh2iq %r1, %r1, 0
i128 test_conv_f16_to_i128(f16 value) { return value; }
// CHECK-LABEL: @test_conv_f16_to_u128
// CHECK: fcvtsh2uq %r1, %r1, 0
u128 test_conv_f16_to_u128(f16 value) { return value; }

// CHECK-LABEL: @test_conv_i32_to_f16
// CHECK: fcvtiw2sh %r1, %r1, 0
f16 test_conv_i32_to_f16(i32 value) { return value; }
// CHECK-LABEL: @test_conv_u32_to_f16
// CHECK: fcvtuw2sh %r1, %r1, 0
f16 test_conv_u32_to_f16(u32 value) { return value; }

// CHECK-LABEL: @test_conv_i64_to_f16
// CHECK: fcvtid2sh %r1, %r1, 0
f16 test_conv_i64_to_f16(i64 value) { return value; }
// CHECK-LABEL: @test_conv_u64_to_f16
// CHECK: fcvtud2sh %r1, %r1, 0
f16 test_conv_u64_to_f16(u64 value) { return value; }

// CHECK-LABEL: @test_conv_i128_to_f16
// CHECK: fcvtiq2sh %r1, %r1, 0
f16 test_conv_i128_to_f16(i128 value) { return value; }
// CHECK-LABEL: @test_conv_u128_to_f16
// CHECK: fcvtuq2sh %r1, %r1, 0
f16 test_conv_u128_to_f16(u128 value) { return value; }

//===----------------------------------------------------------------------===//
// f32
//===----------------------------------------------------------------------===//

// CHECK-LABEL: @test_conv_f32_to_i32
// CHECK: fcvtss2iw %r1, %r1, 0
i32 test_conv_f32_to_i32(f32 value) { return value; }
// CHECK-LABEL: @test_conv_f32_to_u32
// CHECK: fcvtss2uw %r1, %r1, 0
u32 test_conv_f32_to_u32(f32 value) { return value; }

// CHECK-LABEL: @test_conv_f32_to_i64
// CHECK: fcvtss2id %r1, %r1, 0
i64 test_conv_f32_to_i64(f32 value) { return value; }
// CHECK-LABEL: @test_conv_f32_to_u64
// CHECK: fcvtss2ud %r1, %r1, 0
u64 test_conv_f32_to_u64(f32 value) { return value; }

// CHECK-LABEL: @test_conv_f32_to_i128
// CHECK: fcvtss2iq %r1, %r1, 0
i128 test_conv_f32_to_i128(f32 value) { return value; }
// CHECK-LABEL: @test_conv_f32_to_u128
// CHECK: fcvtss2uq %r1, %r1, 0
u128 test_conv_f32_to_u128(f32 value) { return value; }

// CHECK-LABEL: @test_conv_i32_to_f32
// CHECK: fcvtiw2ss %r1, %r1, 0
f32 test_conv_i32_to_f32(i32 value) { return value; }
// CHECK-LABEL: @test_conv_u32_to_f32
// CHECK: fcvtuw2ss %r1, %r1, 0
f32 test_conv_u32_to_f32(u32 value) { return value; }

// CHECK-LABEL: @test_conv_i64_to_f32
// CHECK: fcvtid2ss %r1, %r1, 0
f32 test_conv_i64_to_f32(i64 value) { return value; }
// CHECK-LABEL: @test_conv_u64_to_f32
// CHECK: fcvtud2ss %r1, %r1, 0
f32 test_conv_u64_to_f32(u64 value) { return value; }

// CHECK-LABEL: @test_conv_i128_to_f32
// CHECK: fcvtiq2ss %r1, %r1, 0
f32 test_conv_i128_to_f32(i128 value) { return value; }
// CHECK-LABEL: @test_conv_u128_to_f32
// CHECK: fcvtuq2ss %r1, %r1, 0
f32 test_conv_u128_to_f32(u128 value) { return value; }

//===----------------------------------------------------------------------===//
// f64
//===----------------------------------------------------------------------===//

// CHECK-LABEL: @test_conv_f64_to_i32
// CHECK: fcvtsd2iw %r1, %r1, 0
i32 test_conv_f64_to_i32(f64 value) { return value; }
// CHECK-LABEL: @test_conv_f64_to_u32
// CHECK: fcvtsd2uw %r1, %r1, 0
u32 test_conv_f64_to_u32(f64 value) { return value; }

// CHECK-LABEL: @test_conv_f64_to_i64
// CHECK: fcvtsd2id %r1, %r1, 0
i64 test_conv_f64_to_i64(f64 value) { return value; }
// CHECK-LABEL: @test_conv_f64_to_u64
// CHECK: fcvtsd2ud %r1, %r1, 0
u64 test_conv_f64_to_u64(f64 value) { return value; }

// CHECK-LABEL: @test_conv_f64_to_i128
// CHECK: fcvtsd2iq %r1, %r1, 0
i128 test_conv_f64_to_i128(f64 value) { return value; }
// CHECK-LABEL: @test_conv_f64_to_u128
// CHECK: fcvtsd2uq %r1, %r1, 0
u128 test_conv_f64_to_u128(f64 value) { return value; }

// CHECK-LABEL: @test_conv_i32_to_f64
// CHECK: fcvtiw2sd %r1, %r1, 0
f64 test_conv_i32_to_f64(i32 value) { return value; }
// CHECK-LABEL: @test_conv_u32_to_f64
// CHECK: fcvtuw2sd %r1, %r1, 0
f64 test_conv_u32_to_f64(u32 value) { return value; }

// CHECK-LABEL: @test_conv_i64_to_f64
// CHECK: fcvtid2sd %r1, %r1, 0
f64 test_conv_i64_to_f64(i64 value) { return value; }
// CHECK-LABEL: @test_conv_u64_to_f64
// CHECK: fcvtud2sd %r1, %r1, 0
f64 test_conv_u64_to_f64(u64 value) { return value; }

// CHECK-LABEL: @test_conv_i128_to_f64
// CHECK: fcvtiq2sd %r1, %r1, 0
f64 test_conv_i128_to_f64(i128 value) { return value; }
// CHECK-LABEL: @test_conv_u128_to_f64
// CHECK: fcvtuq2sd %r1, %r1, 0
f64 test_conv_u128_to_f64(u128 value) { return value; }

//===----------------------------------------------------------------------===//
// f128
//===----------------------------------------------------------------------===//

// CHECK-LABEL: @test_conv_f128_to_i32
// CHECK: fcvtsq2iw %r1, %r1, 0
i32 test_conv_f128_to_i32(f128 value) { return value; }
// CHECK-LABEL: @test_conv_f128_to_u32
// CHECK: fcvtsq2uw %r1, %r1, 0
u32 test_conv_f128_to_u32(f128 value) { return value; }

// CHECK-LABEL: @test_conv_f128_to_i64
// CHECK: fcvtsq2id %r1, %r1, 0
i64 test_conv_f128_to_i64(f128 value) { return value; }
// CHECK-LABEL: @test_conv_f128_to_u64
// CHECK: fcvtsq2ud %r1, %r1, 0
u64 test_conv_f128_to_u64(f128 value) { return value; }

// CHECK-LABEL: @test_conv_f128_to_i128
// CHECK: fcvtsq2iq %r1, %r1, 0
i128 test_conv_f128_to_i128(f128 value) { return value; }
// CHECK-LABEL: @test_conv_f128_to_u128
// CHECK: fcvtsq2uq %r1, %r1, 0
u128 test_conv_f128_to_u128(f128 value) { return value; }

// CHECK-LABEL: @test_conv_i32_to_f128
// CHECK: fcvtiw2sq %r1, %r1, 0
f128 test_conv_i32_to_f128(i32 value) { return value; }
// CHECK-LABEL: @test_conv_u32_to_f128
// CHECK: fcvtuw2sq %r1, %r1, 0
f128 test_conv_u32_to_f128(u32 value) { return value; }

// CHECK-LABEL: @test_conv_i64_to_f128
// CHECK: fcvtid2sq %r1, %r1, 0
f128 test_conv_i64_to_f128(i64 value) { return value; }
// CHECK-LABEL: @test_conv_u64_to_f128
// CHECK: fcvtud2sq %r1, %r1, 0
f128 test_conv_u64_to_f128(u64 value) { return value; }

// CHECK-LABEL: @test_conv_i128_to_f128
// CHECK: fcvtiq2sq %r1, %r1, 0
f128 test_conv_i128_to_f128(i128 value) { return value; }
// CHECK-LABEL: @test_conv_u128_to_f128
// CHECK: fcvtuq2sq %r1, %r1, 0
f128 test_conv_u128_to_f128(u128 value) { return value; }
