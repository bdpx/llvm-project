// RUN: clang++ %cflags %s | FileCheck %s --check-prefixes=CHECK
// RUN: clang++ %cflags -fexperimental-relative-c++-abi-vtables %s | FileCheck %s --check-prefixes=CHECK-REL
// REQUIRES: postrisc-registered-target

#if !defined(__cplusplus)
#warning __cplusplus not defined
#endif // __cplusplus

#include "../common.h"

class Interface {
public:
  virtual ~Interface(void) = 0;
  virtual int virtfunc(int a, int b) = 0;
};

int test_class(Interface& iface)
{
  // CHECK: alloc 7
  // CHECK-NEXT: ldz.d %r2, %r1, 0
  // CHECK-NEXT: ldi %r5, 1

  // CHECK: ldi %r6, 2
  // CHECK-NEXT: mov %r4, %r1
  // CHECK-NEXT: call.mi %r3, %r2, 16

  // CHECK: mov %r1, %r4
  // CHECK-NEXT: ret.f 0
  // CHECK-NEXT: nop 0

  // FIXME: relative vtables: merge call with with ldws
  // CHECK-REL: alloc 8
  // CHECK-REL-NEXT: ldz.d %r2, %r1, 0
  // CHECK-REL-NEXT: lds.w %r3, %r2, 8

  // CHECK-REL: ldi %r6, 1
  // CHECK-REL-NEXT: ldi %r7, 2
  // CHECK-REL-NEXT: mov %r5, %r1

  // CHECK-REL: call.ri %r4, %r2, %r3
  // CHECK-REL-NEXT: mov %r1, %r5
  // CHECK-REL-NEXT: ret.f 0

  return iface.virtfunc(1, 2);
}
