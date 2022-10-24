// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

//===----------------------------------------------------------------------===//
// fp extend to wider
//===----------------------------------------------------------------------===//

// CHECK-LABEL: @test_conv_f16_to_f32
// CHECK: fext.sh.ss %r1, %r1
f32 test_conv_f16_to_f32(f16 value) { return value; }
// CHECK-LABEL: @test_conv_f16_to_f64
// CHECK: fext.sh.sd %r1, %r1
f64 test_conv_f16_to_f64(f16 value) { return value; }
// CHECK-LABEL: @test_conv_f16_to_f128
// CHECK: fext.sh.sq %r1, %r1
f128 test_conv_f16_to_f128(f16 value) { return value; }
// CHECK-LABEL: @test_conv_f64_to_f128
// CHECK: fext.sd.sq %r1, %r1
f128 test_conv_f64_to_f128(f64 value) { return value; }
// CHECK-LABEL: @test_conv_f32_to_f64
// CHECK: fext.ss.sd %r1, %r1
f64 test_conv_f32_to_f64(f32 value) { return value; }
// CHECK-LABEL: @test_conv_f32_to_f128
// CHECK: fext.ss.sq %r1, %r1
f128 test_conv_f32_to_f128(f32 value) { return value; }

//===----------------------------------------------------------------------===//
// fp round to narrow
//===----------------------------------------------------------------------===//

// CHECK-LABEL: @test_conv_f32_to_f16
// CHECK: fcvt.ss.sh %r1, %r1, 0
f16 test_conv_f32_to_f16(f32 value) { return value; }
// CHECK-LABEL: @test_conv_f64_to_f16
// CHECK: fcvt.sd.sh %r1, %r1, 0
f16 test_conv_f64_to_f16(f64 value) { return value; }
// CHECK-LABEL: @test_conv_f64_to_f32
// CHECK: fcvt.sd.ss %r1, %r1, 0
f32 test_conv_f64_to_f32(f64 value) { return value; }
// CHECK-LABEL: @test_conv_f128_to_f16
// CHECK: fcvt.sq.sh %r1, %r1, 0
f16 test_conv_f128_to_f16(f128 value) { return value; }
// CHECK-LABEL: @test_conv_f128_to_f32
// CHECK: fcvt.sq.ss %r1, %r1, 0
f32 test_conv_f128_to_f32(f128 value) { return value; }
// CHECK-LABEL: @test_conv_f128_to_f64
// CHECK: fcvt.sq.sd %r1, %r1, 0
f64 test_conv_f128_to_f64(f128 value) { return value; }

//===----------------------------------------------------------------------===//
// f16
//===----------------------------------------------------------------------===//

// CHECK-LABEL: @test_conv_f16_to_i32
// CHECK: fcvt.sh.iw %r1, %r1, 0
i32 test_conv_f16_to_i32(f16 value) { return value; }
// CHECK-LABEL: @test_conv_f16_to_u32
// CHECK: fcvt.sh.uw %r1, %r1, 0
u32 test_conv_f16_to_u32(f16 value) { return value; }

// CHECK-LABEL: @test_conv_f16_to_i64
// CHECK: fcvt.sh.id %r1, %r1, 0
i64 test_conv_f16_to_i64(f16 value) { return value; }
// CHECK-LABEL: @test_conv_f16_to_u64
// CHECK: fcvt.sh.ud %r1, %r1, 0
u64 test_conv_f16_to_u64(f16 value) { return value; }

// CHECK-LABEL: @test_conv_f16_to_i128
// CHECK: fcvt.sh.iq %r1, %r1, 0
i128 test_conv_f16_to_i128(f16 value) { return value; }
// CHECK-LABEL: @test_conv_f16_to_u128
// CHECK: fcvt.sh.uq %r1, %r1, 0
u128 test_conv_f16_to_u128(f16 value) { return value; }

// CHECK-LABEL: @test_conv_i32_to_f16
// CHECK: fcvt.iw.sh %r1, %r1, 0
f16 test_conv_i32_to_f16(i32 value) { return value; }
// CHECK-LABEL: @test_conv_u32_to_f16
// CHECK: fcvt.uw.sh %r1, %r1, 0
f16 test_conv_u32_to_f16(u32 value) { return value; }

// CHECK-LABEL: @test_conv_i64_to_f16
// CHECK: fcvt.id.sh %r1, %r1, 0
f16 test_conv_i64_to_f16(i64 value) { return value; }
// CHECK-LABEL: @test_conv_u64_to_f16
// CHECK: fcvt.ud.sh %r1, %r1, 0
f16 test_conv_u64_to_f16(u64 value) { return value; }

// CHECK-LABEL: @test_conv_i128_to_f16
// CHECK: fcvt.iq.sh %r1, %r1, 0
f16 test_conv_i128_to_f16(i128 value) { return value; }
// CHECK-LABEL: @test_conv_u128_to_f16
// CHECK: fcvt.uq.sh %r1, %r1, 0
f16 test_conv_u128_to_f16(u128 value) { return value; }

//===----------------------------------------------------------------------===//
// f32
//===----------------------------------------------------------------------===//

// CHECK-LABEL: @test_conv_f32_to_i32
// CHECK: fcvt.ss.iw %r1, %r1, 0
i32 test_conv_f32_to_i32(f32 value) { return value; }
// CHECK-LABEL: @test_conv_f32_to_u32
// CHECK: fcvt.ss.uw %r1, %r1, 0
u32 test_conv_f32_to_u32(f32 value) { return value; }

// CHECK-LABEL: @test_conv_f32_to_i64
// CHECK: fcvt.ss.id %r1, %r1, 0
i64 test_conv_f32_to_i64(f32 value) { return value; }
// CHECK-LABEL: @test_conv_f32_to_u64
// CHECK: fcvt.ss.ud %r1, %r1, 0
u64 test_conv_f32_to_u64(f32 value) { return value; }

// CHECK-LABEL: @test_conv_f32_to_i128
// CHECK: fcvt.ss.iq %r1, %r1, 0
i128 test_conv_f32_to_i128(f32 value) { return value; }
// CHECK-LABEL: @test_conv_f32_to_u128
// CHECK: fcvt.ss.uq %r1, %r1, 0
u128 test_conv_f32_to_u128(f32 value) { return value; }

// CHECK-LABEL: @test_conv_i32_to_f32
// CHECK: fcvt.iw.ss %r1, %r1, 0
f32 test_conv_i32_to_f32(i32 value) { return value; }
// CHECK-LABEL: @test_conv_u32_to_f32
// CHECK: fcvt.uw.ss %r1, %r1, 0
f32 test_conv_u32_to_f32(u32 value) { return value; }

// CHECK-LABEL: @test_conv_i64_to_f32
// CHECK: fcvt.id.ss %r1, %r1, 0
f32 test_conv_i64_to_f32(i64 value) { return value; }
// CHECK-LABEL: @test_conv_u64_to_f32
// CHECK: fcvt.ud.ss %r1, %r1, 0
f32 test_conv_u64_to_f32(u64 value) { return value; }

// CHECK-LABEL: @test_conv_i128_to_f32
// CHECK: fcvt.iq.ss %r1, %r1, 0
f32 test_conv_i128_to_f32(i128 value) { return value; }
// CHECK-LABEL: @test_conv_u128_to_f32
// CHECK: fcvt.uq.ss %r1, %r1, 0
f32 test_conv_u128_to_f32(u128 value) { return value; }

//===----------------------------------------------------------------------===//
// f64
//===----------------------------------------------------------------------===//

// CHECK-LABEL: @test_conv_f64_to_i32
// CHECK: fcvt.sd.iw %r1, %r1, 0
i32 test_conv_f64_to_i32(f64 value) { return value; }
// CHECK-LABEL: @test_conv_f64_to_u32
// CHECK: fcvt.sd.uw %r1, %r1, 0
u32 test_conv_f64_to_u32(f64 value) { return value; }

// CHECK-LABEL: @test_conv_f64_to_i64
// CHECK: fcvt.sd.id %r1, %r1, 0
i64 test_conv_f64_to_i64(f64 value) { return value; }
// CHECK-LABEL: @test_conv_f64_to_u64
// CHECK: fcvt.sd.ud %r1, %r1, 0
u64 test_conv_f64_to_u64(f64 value) { return value; }

// CHECK-LABEL: @test_conv_f64_to_i128
// CHECK: fcvt.sd.iq %r1, %r1, 0
i128 test_conv_f64_to_i128(f64 value) { return value; }
// CHECK-LABEL: @test_conv_f64_to_u128
// CHECK: fcvt.sd.uq %r1, %r1, 0
u128 test_conv_f64_to_u128(f64 value) { return value; }

// CHECK-LABEL: @test_conv_i32_to_f64
// CHECK: fcvt.iw.sd %r1, %r1, 0
f64 test_conv_i32_to_f64(i32 value) { return value; }
// CHECK-LABEL: @test_conv_u32_to_f64
// CHECK: fcvt.uw.sd %r1, %r1, 0
f64 test_conv_u32_to_f64(u32 value) { return value; }

// CHECK-LABEL: @test_conv_i64_to_f64
// CHECK: fcvt.id.sd %r1, %r1, 0
f64 test_conv_i64_to_f64(i64 value) { return value; }
// CHECK-LABEL: @test_conv_u64_to_f64
// CHECK: fcvt.ud.sd %r1, %r1, 0
f64 test_conv_u64_to_f64(u64 value) { return value; }

// CHECK-LABEL: @test_conv_i128_to_f64
// CHECK: fcvt.iq.sd %r1, %r1, 0
f64 test_conv_i128_to_f64(i128 value) { return value; }
// CHECK-LABEL: @test_conv_u128_to_f64
// CHECK: fcvt.uq.sd %r1, %r1, 0
f64 test_conv_u128_to_f64(u128 value) { return value; }

//===----------------------------------------------------------------------===//
// f128
//===----------------------------------------------------------------------===//

// CHECK-LABEL: @test_conv_f128_to_i32
// CHECK: fcvt.sq.iw %r1, %r1, 0
i32 test_conv_f128_to_i32(f128 value) { return value; }
// CHECK-LABEL: @test_conv_f128_to_u32
// CHECK: fcvt.sq.uw %r1, %r1, 0
u32 test_conv_f128_to_u32(f128 value) { return value; }

// CHECK-LABEL: @test_conv_f128_to_i64
// CHECK: fcvt.sq.id %r1, %r1, 0
i64 test_conv_f128_to_i64(f128 value) { return value; }
// CHECK-LABEL: @test_conv_f128_to_u64
// CHECK: fcvt.sq.ud %r1, %r1, 0
u64 test_conv_f128_to_u64(f128 value) { return value; }

// CHECK-LABEL: @test_conv_f128_to_i128
// CHECK: fcvt.sq.iq %r1, %r1, 0
i128 test_conv_f128_to_i128(f128 value) { return value; }
// CHECK-LABEL: @test_conv_f128_to_u128
// CHECK: fcvt.sq.uq %r1, %r1, 0
u128 test_conv_f128_to_u128(f128 value) { return value; }

// CHECK-LABEL: @test_conv_i32_to_f128
// CHECK: fcvt.iw.sq %r1, %r1, 0
f128 test_conv_i32_to_f128(i32 value) { return value; }
// CHECK-LABEL: @test_conv_u32_to_f128
// CHECK: fcvt.uw.sq %r1, %r1, 0
f128 test_conv_u32_to_f128(u32 value) { return value; }

// CHECK-LABEL: @test_conv_i64_to_f128
// CHECK: fcvt.id.sq %r1, %r1, 0
f128 test_conv_i64_to_f128(i64 value) { return value; }
// CHECK-LABEL: @test_conv_u64_to_f128
// CHECK: fcvt.ud.sq %r1, %r1, 0
f128 test_conv_u64_to_f128(u64 value) { return value; }

// CHECK-LABEL: @test_conv_i128_to_f128
// CHECK: fcvt.iq.sq %r1, %r1, 0
f128 test_conv_i128_to_f128(i128 value) { return value; }
// CHECK-LABEL: @test_conv_u128_to_f128
// CHECK: fcvt.uq.sq %r1, %r1, 0
f128 test_conv_u128_to_f128(u128 value) { return value; }
