// RUN: clang %cflags %s | FileCheck %s
// REQUIRES: postrisc-registered-target

#include "common.h"

/*
Built-in Function: type __atomic_load_n (type *ptr, int memorder)
  This built-in function implements an atomic load operation. It returns the contents of *ptr.
  The valid memory order variants are __ATOMIC_RELAXED, __ATOMIC_SEQ_CST, __ATOMIC_ACQUIRE, and __ATOMIC_CONSUME.

Built-in Function: void __atomic_load (type *ptr, type *ret, int memorder)
  This is the generic version of an atomic load. It returns the contents of *ptr in *ret.
*/

// TODO: zero/sign extension atomic loads

// CHECK-LABEL: @test_atomic_load_u8_u8
u8 test_atomic_load_u8_u8(u8 *a, u8 *b, u8 *c, u8 *d) {
  u8 ret = 0;
  // CHECK: ldab %r1, %r1
  ret |= __atomic_load_n(a, __ATOMIC_RELAXED);
  // CHECK: ldaba %r2, %r2
  ret ^= __atomic_load_n(b, __ATOMIC_CONSUME);
  // CHECK: ldaba %r3, %r3
  ret &= __atomic_load_n(c, __ATOMIC_ACQUIRE);
  // CHECK: fencesc
  // CHECK: ldab %r4, %r4
  ret |= __atomic_load_n(d, __ATOMIC_SEQ_CST);
  return ret;
}

// CHECK-LABEL: @test_atomic_load_u8_u16
u16 test_atomic_load_u8_u16(u8 *a, u8 *b, u8 *c, u8 *d) {
  u16 ret = 0;
  // CHECK: ldab %r1, %r1
  ret |= __atomic_load_n(a, __ATOMIC_RELAXED);
  // CHECK: ldaba %r2, %r2
  ret ^= __atomic_load_n(b, __ATOMIC_CONSUME);
  // CHECK: ldaba %r3, %r3
  ret &= __atomic_load_n(c, __ATOMIC_ACQUIRE);
  // CHECK: fencesc
  // CHECK: ldab %r4, %r4
  ret |= __atomic_load_n(d, __ATOMIC_SEQ_CST);
  return ret;
}

// CHECK-LABEL: @test_atomic_load_u8_u32
u32 test_atomic_load_u8_u32(u8 *a, u8 *b, u8 *c, u8 *d) {
  u32 ret = 0;
  // CHECK: ldab %r1, %r1
  ret |= __atomic_load_n(a, __ATOMIC_RELAXED);
  // CHECK: ldaba %r2, %r2
  ret ^= __atomic_load_n(b, __ATOMIC_CONSUME);
  // CHECK: ldaba %r3, %r3
  ret &= __atomic_load_n(c, __ATOMIC_ACQUIRE);
  // CHECK: fencesc
  // CHECK: ldab %r4, %r4
  ret |= __atomic_load_n(d, __ATOMIC_SEQ_CST);
  return ret;
}

// CHECK-LABEL: @test_atomic_load_u8_u64
u64 test_atomic_load_u8_u64(u8 *a, u8 *b, u8 *c, u8 *d) {
  u64 ret = 0;
  // CHECK: ldab %r1, %r1
  ret |= __atomic_load_n(a, __ATOMIC_RELAXED);
  // CHECK: ldaba %r2, %r2
  ret ^= __atomic_load_n(b, __ATOMIC_CONSUME);
  // CHECK: ldaba %r3, %r3
  ret &= __atomic_load_n(c, __ATOMIC_ACQUIRE);
  // CHECK: fencesc
  // CHECK: ldab %r4, %r4
  ret |= __atomic_load_n(d, __ATOMIC_SEQ_CST);
  return ret;
}

// CHECK-LABEL: @test_atomic_load_u16_u16
u16 test_atomic_load_u16_u16(u16 *a, u16 *b, u16 *c, u16 *d) {
  u16 ret = 0;
  // CHECK: ldah %r1, %r1
  ret |= __atomic_load_n(a, __ATOMIC_RELAXED);
  // CHECK: ldaha %r2, %r2
  ret ^= __atomic_load_n(b, __ATOMIC_CONSUME);
  // CHECK: ldaha %r3, %r3
  ret &= __atomic_load_n(c, __ATOMIC_ACQUIRE);
  // CHECK: fencesc
  // CHECK: ldah %r4, %r4
  ret |= __atomic_load_n(d, __ATOMIC_SEQ_CST);
  return ret;
}

// CHECK-LABEL: @test_atomic_load_u16_u32
u32 test_atomic_load_u16_u32(u16 *a, u16 *b, u16 *c, u16 *d) {
  u32 ret = 0;
  // CHECK: ldah %r1, %r1
  ret |= __atomic_load_n(a, __ATOMIC_RELAXED);
  // CHECK: ldaha %r2, %r2
  ret ^= __atomic_load_n(b, __ATOMIC_CONSUME);
  // CHECK: ldaha %r3, %r3
  ret &= __atomic_load_n(c, __ATOMIC_ACQUIRE);
  // CHECK: fencesc
  // CHECK: ldah %r4, %r4
  ret |= __atomic_load_n(d, __ATOMIC_SEQ_CST);
  return ret;
}

// CHECK-LABEL: @test_atomic_load_u16_u64
u64 test_atomic_load_u16_u64(u16 *a, u16 *b, u16 *c, u16 *d) {
  u64 ret = 0;
  // CHECK: ldah %r1, %r1
  ret |= __atomic_load_n(a, __ATOMIC_RELAXED);
  // CHECK: ldaha %r2, %r2
  ret ^= __atomic_load_n(b, __ATOMIC_CONSUME);
  // CHECK: ldaha %r3, %r3
  ret &= __atomic_load_n(c, __ATOMIC_ACQUIRE);
  // CHECK: fencesc
  // CHECK: ldah %r4, %r4
  ret |= __atomic_load_n(d, __ATOMIC_SEQ_CST);
  return ret;
}

// CHECK-LABEL: @test_atomic_load_u32_u32
u32 test_atomic_load_u32_u32(u32 *a, u32 *b, u32 *c, u32 *d) {
  u32 ret = 0;
  // CHECK: ldaw %r1, %r1
  ret |= __atomic_load_n(a, __ATOMIC_RELAXED);
  // CHECK: ldawa %r2, %r2
  ret ^= __atomic_load_n(b, __ATOMIC_CONSUME);
  // CHECK: ldawa %r3, %r3
  ret &= __atomic_load_n(c, __ATOMIC_ACQUIRE);
  // CHECK: fencesc
  // CHECK: ldaw %r4, %r4
  ret |= __atomic_load_n(d, __ATOMIC_SEQ_CST);
  return ret;
}

// CHECK-LABEL: @test_atomic_load_u32_u64
u64 test_atomic_load_u32_u64(u32 *a, u32 *b, u32 *c, u32 *d) {
  u64 ret = 0;
  // CHECK: ldaw %r1, %r1
  ret |= __atomic_load_n(a, __ATOMIC_RELAXED);
  // CHECK: ldawa %r2, %r2
  ret ^= __atomic_load_n(b, __ATOMIC_CONSUME);
  // CHECK: ldawa %r3, %r3
  ret &= __atomic_load_n(c, __ATOMIC_ACQUIRE);
  // CHECK: fencesc
  // CHECK: ldaw %r4, %r4
  ret |= __atomic_load_n(d, __ATOMIC_SEQ_CST);
  return ret;
}

// CHECK-LABEL: @test_atomic_load_u64_u64
u64 test_atomic_load_u64_u64(u64 *a, u64 *b, u64 *c, u64 *d) {
  u64 ret = 0;
  // CHECK: ldad %r1, %r1
  ret |= __atomic_load_n(a, __ATOMIC_RELAXED);
  // CHECK: ldada %r2, %r2
  ret ^= __atomic_load_n(b, __ATOMIC_CONSUME);
  // CHECK: ldada %r3, %r3
  ret &= __atomic_load_n(c, __ATOMIC_ACQUIRE);
  // CHECK: fencesc
  // CHECK: ldad %r4, %r4
  ret |= __atomic_load_n(d, __ATOMIC_SEQ_CST);
  return ret;
}

// CHECK-LABEL: @test_atomic_load_u128_u128
u128 test_atomic_load_u128_u128(u128 *a, u128 *b, u128 *c, u128 *d) {
  u128 ret = 0;
  // CHECK: ldaq %r1, %r1
  ret |= __atomic_load_n(a, __ATOMIC_RELAXED);
  // CHECK: ldaqa %r2, %r2
  ret ^= __atomic_load_n(b, __ATOMIC_CONSUME);
  // CHECK: ldaqa %r3, %r3
  ret &= __atomic_load_n(c, __ATOMIC_ACQUIRE);
  // CHECK: fencesc
  // CHECK: ldaq %r4, %r4
  ret |= __atomic_load_n(d, __ATOMIC_SEQ_CST);
  return ret;
}
