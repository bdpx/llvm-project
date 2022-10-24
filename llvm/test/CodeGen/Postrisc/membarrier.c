// RUN: clang %cflags -fno-fast-math -ffp-model=strict %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_signal_fence
i32 test_signal_fence(i32 a, i32 b, i32 c,  i32 d)
{
  // should be bundling break between 2 result values
  // CHECK: allocsp 5, 16
  // CHECK-NEXT: addws %r1, %r2, %r1
  // CHECK-NEXT: addws %r1, %r1, %r3
  // CHECK-EMPTY:
  // CHECK-NEXT: ! BUNDLE 
  // CHECK-NEXT: stw %r1, %sp, 12 
  // CHECK-NEXT: nop 3
  // CHECK-NEXT: nop 3
  // CHECK-EMPTY:
  // CHECK-NEXT: !MEMBARRIER 
  // CHECK-NEXT: ! BUNDLE 
  // CHECK-NEXT: lduw %r1, %sp, 12
  // CHECK-NEXT: addws %r1, %r1, %r4
  // CHECK-NEXT: stw %r1, %sp, 12
  // CHECK-EMPTY:
  // CHECK-NEXT: ! BUNDLE 
  // CHECK-NEXT: lduw %r1, %sp, 12 
  // CHECK-NEXT: retf 16
  // CHECK-NEXT: nop 0

  volatile i32 result = a + b + c;
  __atomic_signal_fence(__ATOMIC_SEQ_CST);
  //__atomic_thread_fence(__ATOMIC_ACQ_REL);
  result += d;
  return result;
}
