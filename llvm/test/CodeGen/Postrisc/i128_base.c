// RUN: clang %cflags %s | FileCheck %s
// REQUIRES: postrisc-registered-target

//  -cc1 -triple postrisc -target-cpu pv1 -S -w -o -

#include "common.h"

// CHECK-LABEL: @test_ldi128
i128 test_ldi128(void)
{
  // CHECK: ldi %r1, 12345778
  i128 a = 12345778ull;
  return a;
}

// CHECK-LABEL: @test_ldi128_long
i128 test_ldi128_long(void)
{
  // CHECK: ldi.l %r1, 987654321123456789
  i128 a = 987654321123456789ull;
  return a;
}

// CHECK-LABEL: @test_ldi128_verylong
i128 test_ldi128_verylong(void)
{
  // CHECK: ldi.l %r1, -230686721
  // CHECK: ldih.l %r1, 1048575
  i128 a = ((i128)0xFFFFFull<<64 | 0xFFFFFFFFF23FFFFFull);
  return a;
}

// CHECK-LABEL: @test_subfi_i128
i128 test_subfi_i128(i128 a)
{
  // CHECK: sub.q %r1, %r2, %r1
  return 1234 - a;
}

// CHECK-LABEL: @test_addi_i128
i128 test_addi_i128(i128 a)
{
  // CHECK: ldi.l %r2, 123456789123456789
  // CHECK: add.q %r1, %r1, %r2
  // CHECK: ldi.l %r2, 9200848539817279407
  // CHECK: or %r1, %r1, %r2
  i128 b = 9200848539817279407ull;
  a += 123456789123456789ull;
  a |= b;
  return a;
}

// CHECK-LABEL: @test_andi_i128
i128 test_andi_i128(i128 a)
{
  // CHECK: andi.l %r1, %r1, 123456789123456789
  a &= 123456789123456789ull;
  return a;
}

// CHECK-LABEL: @test_ori_i128
i128 test_ori_i128(i128 a)
{
  // CHECK: ori.l %r1, %r1, 987654321123456789
  a |= 987654321123456789ull;
  return a;
}

// CHECK-LABEL: @test_add_i128
i128 test_add_i128(i128 a, i128 b)
{
  // CHECK: add.q %r1, %r2, %r1
  return a + b;
}

// CHECK-LABEL: @test_sub_i128
i128 test_sub_i128(i128 a, i128 b)
{
  // CHECK: sub.q %r1, %r1, %r2
  return a - b;
}
