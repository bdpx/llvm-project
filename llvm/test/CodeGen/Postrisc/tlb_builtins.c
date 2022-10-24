// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_builtin_tlb_purge
void test_builtin_tlb_purge(void *p1, void *p2, u32 asid) {
  // CHECK: ptc %r1, %r2, %r3
  __builtin_postrisc_tlb_purge(p1, p2, asid);
  // CHECK-NEXT retf 0
}

