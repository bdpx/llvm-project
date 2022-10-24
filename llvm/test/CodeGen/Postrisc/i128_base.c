// RUN: clang %cflags %s | FileCheck %s
// REQUIRES: postrisc-registered-target

//  -cc1 -triple postrisc -target-cpu pv1 -S -w -o -

#include "common.h"

// CHECK-LABEL: @test_ldi128_verylong
i128 test_ldi128_verylong(void)
{
  // CHECK: ld_imm.l %r1, -230686721
  // CHECK: ld_imm_high.l %r1, 1048575
  i128 a = ((i128)0xFFFFFull<<64 | 0xFFFFFFFFF23FFFFFull);
  return a;
}


// CHECK-LABEL: @test_addi_i128
i128 test_addi_i128(i128 a)
{
  // CHECK: add_imm_i128.l %r1, %r1, 123456789123456789
  // CHECK: ld_imm.l %r2, 9200848539817279407
  // CHECK: or %r1, %r1, %r2
  i128 b = 9200848539817279407ull;
  a += 123456789123456789ull;
  a |= b;
  return a;
}
