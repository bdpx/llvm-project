// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_function_pointer
int test_function_pointer(ft fptr, int arg)
{
  // CHECK: callri %r3, %r1, %gz
  // CHECK: addws %r1, %r4, %r2
  // CHECK: retf 0
  return fptr(arg) + arg;
}

extern int ccc(int x);

// CHECK-LABEL: @test_function_call
int test_function_call(ft fptr, int arg)
{
  // CHECK: call %r3, %jpc(ccc)
  // CHECK: addws %r1, %r4, %r2
  // CHECK: retf 0
  return ccc(arg) + arg;
}

i32 xprintf(void *ptr);

// CHECK-LABEL: @test_function
i32 test_function(void *fptr, i32 arg)
{
  // CHECK: call %r3, %jpc(xprintf)
  // CHECK: addws %r1, %r4, %r2
  // CHECK: retf 0
  return xprintf(fptr) + arg;
}

extern ft gftable[20];

// CHECK-LABEL: @test_callmi
int test_callmi(i64 arg, ft ftable[])
{
  // CHECK: sladdd %r2, %r2, %r1, 3
  // CHECK: callmi %r3, %r2, 0
  // CHECK: addws %r1, %r4, %r1
  // CHECK: retf 0
  ft x = ftable[arg];
  return x(arg) + arg;
}

// CHECK-LABEL: @test_callmi_folding
int test_callmi_folding(ft ftable[], int arg)
{
  // CHECK: callmi %r3, %r1, 48
  // CHECK: addiws %r1, %r4, 2
  // CHECK: retf 0
  return ftable[6](arg)+2;
}

// CHECK-LABEL: @test_callplt_folding
int test_callplt_folding(int arg)
{
  // CHECK: callplt %r2, %pcfwd(gftable+40)
  // CHECK: addiws %r1, %r3, 2
  // CHECK: retf 0
  return gftable[5](arg)+2;
}
