// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @sign_extend_32
// CHECK: sext_i32 %r1, %r1
i64 sign_extend_32(i32 c) { return c; }

// CHECK-LABEL: @sign_extend_16
// CHECK: sext_i16 %r1, %r1
i64 sign_extend_16(i64 c) { return (i16)c; }

// CHECK-LABEL: @sign_extend_8
// CHECK: sext_i8 %r1, %r1
i64 sign_extend_8(i64 c) { return (i8)c; }




// CHECK-LABEL: @zero_extend_u8_u16
// CHECK: zext_i8 %r1, %r1
u16 zero_extend_u8_u16(u16 c) { return (u8)c; }

// CHECK-LABEL: @zero_extend_u8_u32
// CHECK: zext_i8 %r1, %r1
u32 zero_extend_u8_u32(u16 c) { return (u8)c; }

// CHECK-LABEL: @zero_extend_u8_u64
// CHECK: zext_i8 %r1, %r1
u64 zero_extend_u8_u64(u32 c) { return (u8)c; }

// CHECK-LABEL: @zero_extend_u8_u128
// CHECK: zext_i8 %r1, %r1
u128 zero_extend_u8_u128(u64 c) { return (u8)c; }

// CHECK-LABEL: @zero_extend_u16_u32
// CHECK: zext_i16 %r1, %r1
u32 zero_extend_u16_u32(u32 c) { return (u16)c; }

// CHECK-LABEL: @zero_extend_u16_u64
// CHECK: zext_i16 %r1, %r1
u64 zero_extend_u16_u64(u32 c) { return (u16)c; }

// CHECK-LABEL: @zero_extend_u16_u128
// CHECK: zext_i16 %r1, %r1
u128 zero_extend_u16_u128(u32 c) { return (u16)c; }

// CHECK-LABEL: @zero_extend_u32_u64
// CHECK: zext_i32 %r1, %r1
u64 zero_extend_u32_u64(u64 c) { return (u32)c; }

// CHECK-LABEL: @zero_extend_u32_u128
// CHECK: zext_i32 %r1, %r1
u128 zero_extend_u32_u128(u32 c) { return c; }

// CHECK-LABEL: @zero_extend_u64_u128
// CHECK: zext_i64 %r1, %r1
u128 zero_extend_u64_u128(u64 c) { return c; }

// CHECK-LABEL: @zero_extend_u32_u64_4f
// CHECK: zext_i16 %r1, %r1
u64 zero_extend_u32_u64_4f(u32 c) { return c & 0xffff; }

// CHECK-LABEL: @zero_extend_u128_2f
// CHECK: zext_i8 %r1, %r1
u128 zero_extend_u128_2f(u128 c) { return c & 0xff; }

// CHECK-LABEL: @zero_extend_u128_4f
// CHECK: zext_i16 %r1, %r1
u128 zero_extend_u128_4f(u128 c) { return c & 0xffff; }

// CHECK-LABEL: @zero_extend_u128_8f
// CHECK: zext_i32 %r1, %r1
u128 zero_extend_u128_8f(u128 c) { return c & 0xffffffff; }

// CHECK-LABEL: @zero_extend_u128_16f
// CHECK: zext_i64 %r1, %r1
u128 zero_extend_u128_16f(u128 c) { return c & 0xffffffffffffffff; }

