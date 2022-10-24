// RUN: clang %cflags %s | FileCheck %s
// REQUIRES: postrisc-registered-target

#include "common.h"

/*
Built-in Function: void __atomic_store_n (type *ptr, type val, int memorder)
  This built-in function implements an atomic store operation. It writes val into *ptr.
  The valid memory order variants are __ATOMIC_RELAXED, __ATOMIC_SEQ_CST, and __ATOMIC_RELEASE.

Built-in Function: void __atomic_store (type *ptr, type *val, int memorder)
  This is the generic version of an atomic store. It stores the value of *val into *ptr.
*/

// CHECK-LABEL: @test_atomic_store_i8
void test_atomic_store_i8(i8 *a, i8 *b, i8 *c, i8 value) {
  // CHECK: stab %r4, %r1
  __atomic_store_n(a, value, __ATOMIC_RELAXED);
  // CHECK: stabr %r4, %r2
  __atomic_store_n(b, value, __ATOMIC_RELEASE);
  // CHECK: fencesc
  // CHECK: stab %r4, %r3
  __atomic_store_n(c, value, __ATOMIC_SEQ_CST);
}

// CHECK-LABEL: @test_atomic_store_i16
void test_atomic_store_i16(i16 *a, i16 *b, i16 *c, i16 value) {
  // CHECK: stah %r4, %r1
  __atomic_store_n(a, value, __ATOMIC_RELAXED);
  // CHECK: stahr %r4, %r2
  __atomic_store_n(b, value, __ATOMIC_RELEASE);
  // CHECK: fencesc
  // CHECK: stah %r4, %r3
  __atomic_store_n(c, value, __ATOMIC_SEQ_CST);
}

// CHECK-LABEL: @test_atomic_store_i32
void test_atomic_store_i32(i32 *a, i32 *b, i32 *c, i32 value) {
  // CHECK: staw %r4, %r1
  __atomic_store_n(a, value, __ATOMIC_RELAXED);
  // CHECK: stawr %r4, %r2
  __atomic_store_n(b, value, __ATOMIC_RELEASE);
  // CHECK: fencesc
  // CHECK: staw %r4, %r3
  __atomic_store_n(c, value, __ATOMIC_SEQ_CST);
}

// CHECK-LABEL: @test_atomic_store_i64
void test_atomic_store_i64(i64 *a, i64 *b, i64 *c, i64 value) {
  // CHECK: stad %r4, %r1
  __atomic_store_n(a, value, __ATOMIC_RELAXED);
  // CHECK: stadr  %r4, %r2
  __atomic_store_n(b, value, __ATOMIC_RELEASE);
  // CHECK: fencesc
  // CHECK: stad %r4, %r3
  __atomic_store_n(c, value, __ATOMIC_SEQ_CST);
}

// CHECK-LABEL: @test_atomic_store_i128
void test_atomic_store_i128(i128 *a, i128 *b, i128 *c, i128 value) {
  // CHECK: staq %r4, %r1
  __atomic_store_n(a, value, __ATOMIC_RELAXED);
  // CHECK: staqr  %r4, %r2
  __atomic_store_n(b, value, __ATOMIC_RELEASE);
  // CHECK: fencesc
  // CHECK: staq %r4, %r3
  __atomic_store_n(c, value, __ATOMIC_SEQ_CST);
}
