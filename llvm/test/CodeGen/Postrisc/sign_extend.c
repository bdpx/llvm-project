// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_sign_extend_32
i64 test_sign_extend_32(i32 c)
{
  // CHECK: sra_imm_i32 %r1, %r1, 0
  return c;
}

// CHECK-LABEL: @test_sign_extend_16
i64 test_sign_extend_16(i64 c)
{
  // CHECK: slsra_imm_i64 %r1, %r1, 48, 48
  return (i16)c;
}

// CHECK-LABEL: @test_sign_extend_8
i64 test_sign_extend_8(i64 c)
{
  // CHECK: slsra_imm_i64 %r1, %r1, 56, 56
  return (i8)c;
}

// CHECK-LABEL: @test_zero_extend_32
u64 test_zero_extend_32(u32 c)
{
  // CHECK: srl_imm_u32 %r1, %r1, 0
  return c;
}

// CHECK-LABEL: @test_zero_extend_16
u64 test_zero_extend_16(u64 c)
{
  // CHECK: and_imm %r1, %r1, 65535
  return (u16)c;
}

// CHECK-LABEL: @test_zero_extend_8
u64 test_zero_extend_8(u64 c)
{
  // CHECK: and_imm %r1, %r1, 255
  return (u8)c;
}
