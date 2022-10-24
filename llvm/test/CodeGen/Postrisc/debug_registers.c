// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @TestDebugRegisters
void TestDebugRegisters(i64 c)
{
  i64 x;

  // CHECK: mfmr %r2, %r1, 1
  x = __builtin_postrisc_get_mr(c+1);

  // CHECK: mtmr %r2, %r1, 1
  __builtin_postrisc_set_mr(x, c+1);

  // CHECK: mfibr %r2, %r1, 2
  x = __builtin_postrisc_get_ibr(c+2);

  // CHECK: mtibr %r2, %r1, 1
  __builtin_postrisc_set_ibr(x, c+1);

  // CHECK: mfdbr %r2, %r1, 1
  x = __builtin_postrisc_get_dbr(c+1);

  // CHECK: mtdbr %r2, %r1, 2
  __builtin_postrisc_set_dbr(x, c+2);
};
