// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_call_global_tailcall
extern int tail_call(int a, int b);

int test_call_global_tailcall(int arg)
{
  // FIXME: not tail call
  // CHECK: callr %r2, %jpc(tail_call)
  return tail_call(arg+1, arg+10);
}

// CHECK-LABEL: @test_ptr_tailcall
int test_ptr_tailcall(ft ftable[], int arg)
{
  // CcHECK: lddz %r1, %r1, 48
  // CcHECK: callri %r1, %r1, %gz
  // CHECK: callmi %r3, %r1, 48
  return ftable[6](arg);
}

extern ft global_ftable[20];

// CHECK-LABEL: @test_call_global_ptr_table_tailcall
int test_call_global_ptr_table_tailcall(int arg)
{
  // CcHECK: lddzr %r1, %pcfwd(global_ftable+40)
  // CcHECK: ldwz %r4, %sp, 60
  // CcHECK: callri %r1, %r1, %gz
  // CHECK: callplt %r2, %pcfwd(global_ftable+40)
  return global_ftable[5](arg);
}
