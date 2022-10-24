// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @TestDebugRegisters
void TestDebugRegisters(i64 c)
{
  i64 x;

  // CHECK: get_mr %r2, %r1, 1
  x = __builtin_postrisc_get_mr(c+1);

  // CHECK: set_mr %r2, %r1, 1
  __builtin_postrisc_set_mr(x, c+1);

  // CHECK: get_ibr %r2, %r1, 2
  x = __builtin_postrisc_get_ibr(c+2);

  // CHECK: set_ibr %r2, %r1, 1
  __builtin_postrisc_set_ibr(x, c+1);

  // CHECK: get_dbr %r2, %r1, 1
  x = __builtin_postrisc_get_dbr(c+1);

  // CHECK: set_dbr %r2, %r1, 2
  __builtin_postrisc_set_dbr(x, c+2);
};
