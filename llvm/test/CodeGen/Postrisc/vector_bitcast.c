// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// Those bitcasts are free:
// vector <=> vector, vector <=> i128, vector <=> f128, vector => scalar
// expected result: input is output, return immediately

#if 0
// SHECK-LABEL: @test_vector_bitcast_v4i32_to_i32
// SHECK: alloc 2
// SHECK: ret.f 0
i32 test_vector_bitcast_v4i32_to_i32(v4i32 value) { return BITCAST(i32)value; }

// SHECK-LABEL: @test_vector_bitcast_v2i64_to_i64
// SHECK: alloc 2
// SHECK: ret.f 0
i64 test_vector_bitcast_v2i64_to_i64(v2i64 value) { return BITCAST(i64)value; }

// SHECK-LABEL: @test_vector_bitcast_v4f32_to_f32
// SHECK: alloc 2
// SHECK: ret.f 0
f32 test_vector_bitcast_v4f32_to_f32(v4f32 value) { return BITCAST(f32)value; }

// SHECK-LABEL: @test_vector_bitcast_v2f64_to_f64
// SHECK: alloc 2
// SHECK: ret.f 0
f64 test_vector_bitcast_v2f64_to_f64(v2f64 value) { return BITCAST(f64)value; }
#endif

// CHECK-LABEL: @test_vector_bitcast_v2i64_to_v4i32
// CHECK: alloc 2
// CHECK: ret.f 0
v4i32 test_vector_bitcast_v2i64_to_v4i32(v2i64 value) { return BITCAST(v4i32)value; }

// CHECK-LABEL: @test_vector_bitcast_v2i64_to_v8i16
// CHECK: alloc 2
// CHECK: ret.f 0
v8i16 test_vector_bitcast_v2i64_to_v8i16(v2i64 value) { return BITCAST(v8i16)value; }

// CHECK-LABEL: @test_vector_bitcast_v2i64_to_v16i8
// CHECK: alloc 2
// CHECK: ret.f 0
v16i8 test_vector_bitcast_v2i64_to_v16i8(v2i64 value) { return BITCAST(v16i8)value; }


// CHECK-LABEL: @test_vector_bitcast_v4i32_to_v2i64
// CHECK: alloc 2
// CHECK: ret.f 0
v2i64 test_vector_bitcast_v4i32_to_v2i64(v4i32 value) { return BITCAST(v2i64)value; }

// CHECK-LABEL: @test_vector_bitcast_v4i32_to_v8i16
// CHECK: alloc 2
// CHECK: ret.f 0
v8i16 test_vector_bitcast_v4i32_to_v8i16(v4i32 value) { return BITCAST(v8i16)value; }

// CHECK-LABEL: @test_vector_bitcast_v4i32_to_v16i8
// CHECK: alloc 2
// CHECK: ret.f 0
v16i8 test_vector_bitcast_v4i32_to_v16i8(v4i32 value) { return BITCAST(v16i8)value; }


// CHECK-LABEL: @test_vector_bitcast_v8i16_to_v2i64
// CHECK: alloc 2
// CHECK: ret.f 0
v2i64 test_vector_bitcast_v8i16_to_v2i64(v8i16 value) { return BITCAST(v2i64)value; }

// CHECK-LABEL: @test_vector_bitcast_v8i16_to_v4i32
// CHECK: alloc 2
// CHECK: ret.f 0
v4i32 test_vector_bitcast_v8i16_to_v4i32(v8i16 value) { return BITCAST(v4i32)value; }

// CHECK-LABEL: @test_vector_bitcast_v8i16_to_v16i8
// CHECK: alloc 2
// CHECK: ret.f 0
v16i8 test_vector_bitcast_v8i16_to_v16i8(v8i16 value) { return BITCAST(v16i8)value; }




// CHECK-LABEL: @test_vector_bitcast_v16i8_to_v2i64
// CHECK: alloc 2
// CHECK: ret.f 0
v2i64 test_vector_bitcast_v16i8_to_v2i64(v8i16 value) { return BITCAST(v2i64)value; }

// CHECK-LABEL: @test_vector_bitcast_v16i8_to_v4i32
// CHECK: alloc 2
// CHECK: ret.f 0
v4i32 test_vector_bitcast_v16i8_to_v4i32(v8i16 value) { return BITCAST(v4i32)value; }

// CHECK-LABEL: @test_vector_bitcast_v16i8_to_v8i16
// CHECK: alloc 2
// CHECK: ret.f 0
v8i16 test_vector_bitcast_v16i8_to_v8i16(v8i16 value) { return BITCAST(v8i16)value; }




// CHECK-LABEL: @test_vector_bitcast_f128_to_v16i8
// CHECK: alloc 2
// CHECK: ret.f 0
v16i8 test_vector_bitcast_f128_to_v16i8(f128 value) { return BITCAST(v16i8)value; }

// CHECK-LABEL: @test_vector_bitcast_f128_to_v8i16
// CHECK: alloc 2
// CHECK: ret.f 0
v8i16 test_vector_bitcast_f128_to_v8i16(f128 value) { return BITCAST(v8i16)value; }

// CHECK-LABEL: @test_vector_bitcast_f128_to_v4i32
// CHECK: alloc 2
// CHECK: ret.f 0
v4i32 test_vector_bitcast_f128_to_v4i32(f128 value) { return BITCAST(v4i32)value; }

// CHECK-LABEL: @test_vector_bitcast_f128_to_v2i64
// CHECK: alloc 2
// CHECK: ret.f 0
v2i64 test_vector_bitcast_f128_to_v2i64(f128 value) { return BITCAST(v2i64)value; }




// CHECK-LABEL: @test_vector_bitcast_v16i8_to_f128
// CHECK: alloc 2
// CHECK: ret.f 0
f128 test_vector_bitcast_v16i8_to_f128(v16i8 value) { return BITCAST(f128)value; }

// CHECK-LABEL: @test_vector_bitcast_v8i16_to_f128
// CHECK: alloc 2
// CHECK: ret.f 0
f128 test_vector_bitcast_v8i16_to_f128(v8i16 value) { return BITCAST(f128)value; }

// CHECK-LABEL: @test_vector_bitcast_v4i32_to_f128
// CHECK: alloc 2
// CHECK: ret.f 0
f128 test_vector_bitcast_v4i32_to_f128(v4i32 value) { return BITCAST(f128)value; }

// CHECK-LABEL: @test_vector_bitcast_v2i64_to_f128
// CHECK: alloc 2
// CHECK: ret.f 0
f128 test_vector_bitcast_v2i64_to_f128(v2i64 value) { return BITCAST(f128)value; }



// CHECK-LABEL: @test_vector_bitcast_i128_to_v16i8
// CHECK: alloc 2
// CHECK: ret.f 0
v16i8 test_vector_bitcast_i128_to_v16i8(i128 value) { return BITCAST(v16i8)value; }

// CHECK-LABEL: @test_vector_bitcast_i128_to_v8i16
// CHECK: alloc 2
// CHECK: ret.f 0
v8i16 test_vector_bitcast_i128_to_v8i16(i128 value) { return BITCAST(v8i16)value; }

// CHECK-LABEL: @test_vector_bitcast_i128_to_v4i32
// CHECK: alloc 2
// CHECK: ret.f 0
v4i32 test_vector_bitcast_i128_to_v4i32(i128 value) { return BITCAST(v4i32)value; }

// CHECK-LABEL: @test_vector_bitcast_i128_to_v2i64
// CHECK: alloc 2
// CHECK: ret.f 0
v2i64 test_vector_bitcast_i128_to_v2i64(i128 value) { return BITCAST(v2i64)value; }



// CHECK-LABEL: @test_vector_bitcast_v16i8_to_i128
// CHECK: alloc 2
// CHECK: ret.f 0
i128 test_vector_bitcast_v16i8_to_i128(v16i8 value) { return BITCAST(i128)value; }

// CHECK-LABEL: @test_vector_bitcast_v8i16_to_i128
// CHECK: alloc 2
// CHECK: ret.f 0
i128 test_vector_bitcast_v8i16_to_i128(v8i16 value) { return BITCAST(i128)value; }

// CHECK-LABEL: @test_vector_bitcast_v4i32_to_i128
// CHECK: alloc 2
// CHECK: ret.f 0
i128 test_vector_bitcast_v4i32_to_i128(v4i32 value) { return BITCAST(i128)value; }

// CHECK-LABEL: @test_vector_bitcast_v2i64_to_i128
// CHECK: alloc 2
// CHECK: ret.f 0
i128 test_vector_bitcast_v2i64_to_i128(v2i64 value) { return BITCAST(i128)value; }
