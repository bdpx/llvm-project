// RUN: clang %cflags %s | FileCheck %s
// REQUIRES: postrisc-registered-target

#include "common.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
// invert
////////////////////////////////////////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_i32_inv
// CHECK: xori %r1, %r1, -1
// CHECK-NEXT: ret.f 0
i32 test_i32_inv(i32 a) {  return ~a; }

// CHECK-LABEL: @test_i64_inv
// CHECK: xori %r1, %r1, -1
// CHECK-NEXT: ret.f 0
i32 test_i64_inv(i64 a) {  return ~a; }

// CHECK-LABEL: @test_i128_inv
// CHECK: xori %r1, %r1, -1
// CHECK-NEXT: ret.f 0
i128 test_i128_inv(i128 a) {  return ~a; }

////////////////////////////////////////////////////////////////////////////////////////////////////
// and
////////////////////////////////////////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_i32_and
// CHECK: and %r1, %r2, %r1
i32 test_i32_and(i32 a, i32 b) {  return a & b; }

// CHECK-LABEL: @test_i64_and
// CHECK: and %r1, %r2, %r1
// CHECK-NEXT: ret.f 0
i64 test_i64_and(i64 a, i64 b) {  return a & b; }

// CHECK-LABEL: @test_i128_and
// CHECK: and %r1, %r2, %r1
// CHECK-NEXT: ret.f 0
i128 test_i128_and(i128 a, i128 b) {  return a & b; }

// CHECK-LABEL: @test_i32_andi
// CHECK: andi %r1, %r1, 12345
// CHECK-NEXT: ret.f 0
i32 test_i32_andi(i32 a) {  return a & 12345; }

// CHECK-LABEL: @test_i32_andi_ext
// CHECK: andi.l %r1, %r1, 123456789
// CHECK: ret.f 0
i32 test_i32_andi_ext(i32 a) {  return a & 123456789; }

// CHECK-LABEL: @test_i64_andi
// CHECK: andi %r1, %r1, 12345
// CHECK-NEXT: ret.f 0
i64 test_i64_andi(i64 a) {  return a & 12345; }

// CHECK-LABEL: @test_i64_andi_ext
// CHECK: andi.l %r1, %r1, 123456789
// CHECK: ret.f 0
i64 test_i64_andi_ext(i64 a) {  return a & 123456789; }

// CHECK-LABEL: @test_i128_andi
// CHECK: andi %r1, %r1, 12345
// CHECK-NEXT: ret.f 0
i128 test_i128_andi(i128 a) {  return a & 12345; }

// CHECK-LABEL: @test_i128_andi_ext
// CHECK: andi.l %r1, %r1, 123456789
// CHECK: ret.f 0
i128 test_i128_andi_ext(i128 a) {  return a & 123456789; }

////////////////////////////////////////////////////////////////////////////////////////////////////
// and-not
////////////////////////////////////////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_i32_andn
// CHECK: andn %r1, %r1, %r2
i32 test_i32_andn(i32 a, i32 b) {  return (~a) & b; }

// CHECK-LABEL: @test_i64_andn
// CHECK: andn %r1, %r1, %r2
// CHECK-NEXT: ret.f 0
i64 test_i64_andn(i64 a, i64 b) {  return (~a) & b; }

// CHECK-LABEL: @test_i128_andn
// CHECK: andn %r1, %r1, %r2
// CHECK-NEXT: ret.f 0
i128 test_i128_andn(i128 a, i128 b) {  return (~a) & b; }

// CHECK-LABEL: @test_i32_andni
// CHECK: andni %r1, %r1, 12345
// CHECK-NEXT: ret.f 0
i32 test_i32_andni(i32 a) {  return (~a) & 12345; }

// CHECK-LABEL: @test_i32_andni_ext
// CHECK: andni.l %r1, %r1, 123456789
// CHECK: ret.f 0
i32 test_i32_andni_ext(i32 a) {  return (~a) & 123456789; }

// CHECK-LABEL: @test_i64_andni
// CHECK: andni %r1, %r1, 12345
// CHECK-NEXT: ret.f 0
i64 test_i64_andni(i64 a) {  return (~a) & 12345; }

// CHECK-LABEL: @test_i64_andni_ext
// CHECK: andni.l %r1, %r1, 123456789
// CHECK: ret.f 0
i64 test_i64_andni_ext(i64 a) {  return (~a) & 123456789; }

// CHECK-LABEL: @test_i128_andni
// CHECK: andni %r1, %r1, 12345
// CHECK-NEXT: ret.f 0
i128 test_i128_andni(i128 a) {  return (~a) & 12345; }

// CHECK-LABEL: @test_i128_andni_ext
// CHECK: andni.l %r1, %r1, 123456789
// CHECK: ret.f 0
i128 test_i128_andni_ext(i128 a) {  return (~a) & 123456789; }

////////////////////////////////////////////////////////////////////////////////////////////////////
// or
////////////////////////////////////////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_i32_or
// CHECK: or %r1, %r2, %r1
// CHECK-NEXT: ret.f 0
i32 test_i32_or(i32 a, i32 b) {  return a | b; }

// CHECK-LABEL: @test_i64_or
// CHECK: or %r1, %r2, %r1
// CHECK-NEXT: ret.f 0
i64 test_i64_or(i64 a, i64 b) {  return a | b; }

// CHECK-LABEL: @test_i128_or
// CHECK: or %r1, %r2, %r1
// CHECK-NEXT: ret.f 0
i128 test_i128_or(i128 a, i128 b) {  return a | b; }

// CHECK-LABEL: @test_i32_ori
// CHECK: ori %r1, %r1, 12345
// CHECK-NEXT: ret.f 0
i32 test_i32_ori(i32 a) {  return a | 12345; }

// CHECK-LABEL: @test_i32_ori_ext
// CHECK: ori.l %r1, %r1, 123456789
// CHECK: ret.f 0
i32 test_i32_ori_ext(i32 a) {  return a | 123456789; }

// CHECK-LABEL: @test_i64_ori
// CHECK: ori %r1, %r1, 12345
// CHECK: ret.f 0
i64 test_i64_ori(i64 a) {  return a | 12345; }

// CHECK-LABEL: @test_i64_ori_ext
// CHECK: ori.l %r1, %r1, 123456789
// CHECK: ret.f 0
i64 test_i64_ori_ext(i64 a) {  return a | 123456789; }

// CHECK-LABEL: @test_i128_ori
// CHECK: ori %r1, %r1, 12345
// CHECK: ret.f 0
i128 test_i128_ori(i128 a) {  return a | 12345; }

// CHECK-LABEL: @test_i128_ori_ext
// CHECK: ori.l %r1, %r1, 123456789
// CHECK: ret.f 0
i128 test_i128_ori_ext(i128 a) {  return a | 123456789; }

////////////////////////////////////////////////////////////////////////////////////////////////////
// or-not
////////////////////////////////////////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_i32_orn
// CHECK: orn %r1, %r1, %r2
// CHECK-NEXT: ret.f 0
i32 test_i32_orn(i32 a, i32 b) {  return (~a) | b; }

// CHECK-LABEL: @test_i64_orn
// CHECK: orn %r1, %r1, %r2
// CHECK-NEXT: ret.f 0
i64 test_i64_orn(i64 a, i64 b) {  return (~a) | b; }

// CHECK-LABEL: @test_i128_orn
// CHECK: orn %r1, %r1, %r2
// CHECK-NEXT: ret.f 0
i128 test_i128_orn(i128 a, i128 b) {  return (~a) | b; }

// CHECK-LABEL: @test_i32_orni
// CHECK: orni %r1, %r1, 12345
// CHECK-NEXT: ret.f 0
i32 test_i32_orni(i32 a) {  return (~a) | 12345; }

// CHECK-LABEL: @test_i32_orni_ext
// CHECK: orni.l %r1, %r1, 123456789
// CHECK: ret.f 0
i32 test_i32_orni_ext(i32 a) {  return (~a) | 123456789; }

// CHECK-LABEL: @test_i64_orni
// CHECK: orni %r1, %r1, 12345
// CHECK: ret.f 0
i64 test_i64_orni(i64 a) {  return (~a) | 12345; }

// CHECK-LABEL: @test_i64_orni_ext
// CHECK: orni.l %r1, %r1, 123456789
// CHECK: ret.f 0
i64 test_i64_orni_ext(i64 a) {  return (~a) | 123456789; }

// CHECK-LABEL: @test_i128_orni
// CHECK: orni %r1, %r1, 12345
// CHECK: ret.f 0
i128 test_i128_orni(i128 a) {  return (~a) | 12345; }

// CHECK-LABEL: @test_i128_orni_ext
// CHECK: orni.l %r1, %r1, 123456789
// CHECK: ret.f 0
i128 test_i128_orni_ext(i128 a) {  return (~a) | 123456789; }

////////////////////////////////////////////////////////////////////////////////////////////////////
// xor
////////////////////////////////////////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_i32_xor
// CHECK: xor %r1, %r2, %r1
// CHECK-NEXT: ret.f 0
i32 test_i32_xor(i32 a, i32 b) {  return a ^ b; }

// CHECK-LABEL: @test_i64_xor
// CHECK: xor %r1, %r2, %r1
// CHECK-NEXT: ret.f 0
i64 test_i64_xor(i64 a, i64 b) {  return a ^ b; }

// CHECK-LABEL: @test_i128_xor
// CHECK: xor %r1, %r2, %r1
// CHECK-NEXT: ret.f 0
i128 test_i128_xor(i128 a, i128 b) {  return a ^ b; }

// CHECK-LABEL: @test_i32_xori
// CHECK: xori %r1, %r1, 12345
// CHECK-NEXT: ret.f 0
i32 test_i32_xori(i32 a) {  return a ^ 12345; }

// CHECK-LABEL: @test_i32_xori_ext
// CHECK: xori.l %r1, %r1, 123456789
// CHECK: ret.f 0
i32 test_i32_xori_ext(i32 a) {  return a ^ 123456789; }

// CHECK-LABEL: @test_i64_xori
// CHECK: xori %r1, %r1, 12345
// CHECK: ret.f 0
i64 test_i64_xori(i64 a) {  return a ^ 12345; }

// CHECK-LABEL: @test_i64_xori_ext
// CHECK: xori.l %r1, %r1, 123456789
// CHECK: ret.f 0
i64 test_i64_xori_ext(i64 a) {  return a ^ 123456789; }

// CHECK-LABEL: @test_i128_xori
// CHECK: xori %r1, %r1, 12345
// CHECK: ret.f 0
i128 test_i128_xori(i128 a) {  return a ^ 12345; }

// CHECK-LABEL: @test_i128_xori_ext
// CHECK: xori.l %r1, %r1, 123456789
// CHECK: ret.f 0
i128 test_i128_xori_ext(i128 a) {  return a ^ 123456789; }
