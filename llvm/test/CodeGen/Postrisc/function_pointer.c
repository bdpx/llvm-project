// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_function_pointer
int test_function_pointer(ft fptr, int arg)
{
  // CHECK: callri %r3, %r1, %gz
  return fptr(arg) + arg;
}

extern int ccc(int x);

// CHECK-LABEL: @test_function_call
int test_function_call(ft fptr, int arg)
{
  // CHECK: callr %r3, %jpc(ccc)
  return ccc(arg) + arg;
}

i32 xprintf(void *ptr);

// CHECK-LABEL: @test_function
i32 test_function(void *fptr, i32 arg)
{
  // CHECK: callr %r3, %jpc(xprintf)
  return xprintf(fptr) + arg;
}

extern ft gftable[20];

// CHECK-LABEL: @test_callmi
int test_callmi(i64 arg, ft0 ftable[])
{
  // CHECK: ldax %r2, %r2, %r1, 3, 0
  // CHECK: callmi %r3, %r2, 0
  ft0 x = ftable[arg];
  return x() + arg;
}

// CHECK-LABEL: @test_callmi_folding
int test_callmi_folding(ft ftable[], int arg)
{
  // CHECK: callmi %r3, %r1, 48
  return ftable[6](arg)+2;
}

// CHECK-LABEL: @test_callplt_folding
int test_callplt_folding(int arg)
{
  // CHECK: callplt %r2, %pcfwd(gftable+40)
  return gftable[5](arg)+2;
}
