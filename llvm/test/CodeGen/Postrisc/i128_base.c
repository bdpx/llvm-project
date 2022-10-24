// RUN: clang %cflags %s | FileCheck %s
// REQUIRES: postrisc-registered-target

//  -cc1 -triple postrisc -target-cpu pv1 -S -w -o -

#include "common.h"

// CHECK-LABEL: @test_ldi128
i128 test_ldi128(void)
{
  // CHECK: ld_imm %r1, 12345778
  i128 a = 12345778ull;
  return a;
}

// CHECK-LABEL: @test_ldi128_long
i128 test_ldi128_long(void)
{
  // CHECK: ld_imm.l %r1, 987654321123456789
  i128 a = 987654321123456789ull;
  return a;
}

// CHECK-LABEL: @test_ldi128_verylong
i128 test_ldi128_verylong(void)
{
  // CHECK: ld_imm.l %r1, -230686721
  // CHECK: ld_imm_high.l %r1, 1048575
  i128 a = ((i128)0xFFFFFull<<64 | 0xFFFFFFFFF23FFFFFull);
  return a;
}

// CHECK-LABEL: @test_subr_i128
i128 test_subr_i128(i128 a)
{
  // CHECK: sub_i128 %r1, %r2, %r1
  return 1234 - a;
}

// CHECK-LABEL: @test_addi_i128
i128 test_addi_i128(i128 a)
{
  // CHECK: ld_imm.l %r2, 123456789123456789
  // CHECK: add_i128 %r1, %r1, %r2
  // CHECK: ld_imm.l %r2, 9200848539817279407
  // CHECK: or %r1, %r1, %r2
  i128 b = 9200848539817279407ull;
  a += 123456789123456789ull;
  a |= b;
  return a;
}

// CHECK-LABEL: @test_andi_i128
i128 test_andi_i128(i128 a)
{
  // CHECK: and_imm.l %r1, %r1, 123456789123456789
  a &= 123456789123456789ull;
  return a;
}

// CHECK-LABEL: @test_ori_i128
i128 test_ori_i128(i128 a)
{
  // CHECK: or_imm.l %r1, %r1, 987654321123456789
  a |= 987654321123456789ull;
  return a;
}

// CHECK-LABEL: @test_add_i128
i128 test_add_i128(i128 a, i128 b)
{
  // CHECK: add_i128 %r1, %r2, %r1
  return a + b;
}

// CHECK-LABEL: @test_sub_i128
i128 test_sub_i128(i128 a, i128 b)
{
  // CHECK: sub_i128 %r1, %r1, %r2
  return a - b;
}
