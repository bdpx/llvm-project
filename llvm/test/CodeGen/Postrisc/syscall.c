// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_syscall_2
i64 test_syscall_2(int n, i64 a, i64 b)
{
  // CHECK: alloc 2
  // CHECK-NEXT: syscall
  // CHECK-NEXT: retf 0
  register i64 r1 __asm__("r1"); // FIXME: doesn't work for other regs
  __builtin_postrisc_syscall();
  return r1;
}

// CHECK-LABEL: @test_syscall
void test_syscall(i64 c)
{
  // CHECK: syscall
  __builtin_postrisc_syscall();
  // CHECK: sysret
  __builtin_postrisc_sysret();
};

// CHECK-LABEL: @test_int
void test_int(i64 c)
{
  // CHECK: alloc 2
  // CHECK-NEXT: int %r1, 0
  __builtin_postrisc_int(c);
  // CHECK-NEXT: int %gz, 100
  __builtin_postrisc_int(100);

  // CHECK: int %gz, 200
  __builtin_postrisc_int(200);
  // CHECK-NEXT: int %gz, 255
  __builtin_postrisc_int(255U);
  // CHECK-NEXT: int %gz, 99
  __builtin_postrisc_int(99);

  // CHECK: int %gz, 1
  __builtin_debugtrap();
  // CHECK-NEXT: int %gz, 5
  __builtin_trap();
  // trap never return, there should be no return instruction
  // CHECK-NEXT: nop 0
}
