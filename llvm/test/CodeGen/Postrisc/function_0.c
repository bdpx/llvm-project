// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_function_pointer
int test_function_pointer(ft0 fptr)
{
  // CHECK: callri %r2, %r1, %gz
  // CHECK: mov %r1, %r3
  // CHECK: retf 0
  return fptr();
}

extern int ccc(void);

// CHECK-LABEL: @test_function_call
int test_function_call(ft0 fptr, int arg)
{
  // CHECK: call %r3, %jpc(ccc)
  // CHECK: addws %r1, %r4, %r2
  // CHECK: retf 0
  return ccc() + arg;
}

i32 xprintf(void);

// CHECK-LABEL: @test_function
i32 test_function(void *fptr, i32 arg)
{
  // CHECK: call %r3, %jpc(xprintf)
  // CHECK: addws %r1, %r4, %r2
  // CHECK: retf 0
  return xprintf() + arg;
}

extern ft0 gftable[20];

// CHECK-LABEL: @test_callmi
int test_callmi(i64 arg, ft0 ftable[])
{
  // CHECK: sladdd %r2, %r2, %r1, 3
  // CHECK: callmi %r3, %r2, 0
  // CHECK: addws %r1, %r4, %r1
  // CHECK: retf 0
  ft0 x = ftable[arg];
  return x() + arg;
}

// CHECK-LABEL: @test_callmi_folding
int test_callmi_folding(ft0 ftable[], int arg)
{
  // CHECK: callmi %r3, %r1, 48
  // CHECK: addws %r1, %r4, %r2
  // CHECK: retf 0
  return ftable[6]() + arg;
}

// CHECK-LABEL: @test_callplt_folding
int test_callplt_folding(int arg)
{
  // CHECK: callplt %r2, %pcfwd(gftable+40)
  // CHECK: addws %r1, %r3, %r1
  // CHECK: retf 0
  return gftable[5]() + arg;
}
