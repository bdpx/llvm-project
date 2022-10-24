// RUN: clang %cflags %s | FileCheck %s
// REQUIRES: postrisc-registered-target

#include "common.h"

/*
Built-in Function:
bool __atomic_compare_exchange_n
  (type *ptr, type *expected, type desired, bool weak, int success_memorder, int failure_memorder)

  This built-in function implements an atomic compare and exchange operation.
  This compares the contents of *ptr with the contents of *expected.
  If equal, the operation is a read-modify-write operation that writes desired into *ptr.
  If they are not equal, the operation is a read and the current contents of *ptr
  are written into *expected.
  weak is true for weak compare_exchange, which may fail spuriously,
  and false for the strong variation, which never fails spuriously.
  Many targets only offer the strong variation and ignore the parameter.
  When in doubt, use the strong variation.

  If desired is written into *ptr then true is returned and memory is affected
  according to the memory order specified by success_memorder.
  There are no restrictions on what memory order can be used here.

  Otherwise, false is returned and memory is affected according to failure_memorder.
  This memory order cannot be __ATOMIC_RELEASE nor __ATOMIC_ACQ_REL.
  It also cannot be a stronger order than that specified by success_memorder.

Built-in Function:
bool __atomic_compare_exchange
  (type *ptr, type *expected, type *desired, bool weak, int success_memorder, int failure_memorder)

  This built-in function implements the generic version of __atomic_compare_exchange.
  The function is virtually identical to __atomic_compare_exchange_n,
  except the desired value is also a pointer.
*/

// CHECK-LABEL: @test_atomic_compare_exchange_i8
int test_atomic_compare_exchange_i8(i8 *p, i8 *e, i8 d) {
  volatile int ret = 0;
  // CHECK: casb %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_RELAXED, __ATOMIC_RELAXED);

  // CHECK: casba %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_ACQUIRE, __ATOMIC_RELAXED);
  // CHECK: casba %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_ACQUIRE, __ATOMIC_ACQUIRE);
  // CHECK: casba %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_ACQUIRE, __ATOMIC_CONSUME);

  // CHECK: casba %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_CONSUME, __ATOMIC_RELAXED);
  // CHECK: casba %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_CONSUME, __ATOMIC_ACQUIRE);
  // CHECK: casba %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_CONSUME, __ATOMIC_CONSUME);

  // CHECK: casbr %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_RELEASE, __ATOMIC_RELAXED);

  // CHECK: casbar %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_ACQ_REL, __ATOMIC_RELAXED);
  // CHECK: casbar %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_ACQ_REL, __ATOMIC_CONSUME);
  // CHECK: casbar %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_ACQ_REL, __ATOMIC_ACQUIRE);

  // CHECK: fencesc
  // CHECK: casb %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_SEQ_CST, __ATOMIC_RELAXED);
  // CHECK: fencesc
  // CHECK: casb %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_SEQ_CST, __ATOMIC_ACQUIRE);
  // CHECK: fencesc
  // CHECK: casb %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_SEQ_CST, __ATOMIC_CONSUME);
  // CHECK: fencesc
  // CHECK: casb %r3, %r1, %r4
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_SEQ_CST, __ATOMIC_SEQ_CST);
  return ret;
}

// CHECK-LABEL: @test_atomic_compare_exchange_i16
int test_atomic_compare_exchange_i16(i16 *p, i16 *e, i16 d) {
  volatile int ret = 0;
  // CHECK: cash %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_RELAXED, __ATOMIC_RELAXED);

  // CHECK: casha %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_ACQUIRE, __ATOMIC_RELAXED);
  // CHECK: casha %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_ACQUIRE, __ATOMIC_ACQUIRE);
  // CHECK: casha %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_ACQUIRE, __ATOMIC_CONSUME);

  // CHECK: casha %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_CONSUME, __ATOMIC_RELAXED);
  // CHECK: casha %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_CONSUME, __ATOMIC_ACQUIRE);
  // CHECK: casha %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_CONSUME, __ATOMIC_CONSUME);

  // CHECK: cashr %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_RELEASE, __ATOMIC_RELAXED);

  // CHECK: cashar %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_ACQ_REL, __ATOMIC_RELAXED);
  // CHECK: cashar %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_ACQ_REL, __ATOMIC_CONSUME);
  // CHECK: cashar %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_ACQ_REL, __ATOMIC_ACQUIRE);

  // CHECK: fencesc
  // CHECK: cash %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_SEQ_CST, __ATOMIC_RELAXED);
  // CHECK: fencesc
  // CHECK: cash %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_SEQ_CST, __ATOMIC_ACQUIRE);
  // CHECK: fencesc
  // CHECK: cash %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_SEQ_CST, __ATOMIC_CONSUME);
  // CHECK: fencesc
  // CHECK: cash %r3, %r1, %r4
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_SEQ_CST, __ATOMIC_SEQ_CST);
  return ret;
}

// CHECK-LABEL: @test_atomic_compare_exchange_i32
int test_atomic_compare_exchange_i32(i32 *p, i32 *e, i32 d) {
  volatile int ret = 0;
  // CHECK: casw %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_RELAXED, __ATOMIC_RELAXED);

  // CHECK: caswa %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_ACQUIRE, __ATOMIC_RELAXED);
  // CHECK: caswa %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_ACQUIRE, __ATOMIC_ACQUIRE);
  // CHECK: caswa %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_ACQUIRE, __ATOMIC_CONSUME);

  // CHECK: caswa %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_CONSUME, __ATOMIC_RELAXED);
  // CHECK: caswa %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_CONSUME, __ATOMIC_ACQUIRE);
  // CHECK: caswa %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_CONSUME, __ATOMIC_CONSUME);

  // CHECK: caswr %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_RELEASE, __ATOMIC_RELAXED);

  // CHECK: caswar %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_ACQ_REL, __ATOMIC_RELAXED);
  // CHECK: caswar %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_ACQ_REL, __ATOMIC_CONSUME);
  // CHECK: caswar %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_ACQ_REL, __ATOMIC_ACQUIRE);

  // CHECK: fencesc
  // CHECK: casw %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_SEQ_CST, __ATOMIC_RELAXED);
  // CHECK: fencesc
  // CHECK: casw %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_SEQ_CST, __ATOMIC_ACQUIRE);
  // CHECK: fencesc
  // CHECK: casw %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_SEQ_CST, __ATOMIC_CONSUME);
  // CHECK: fencesc
  // CHECK: casw %r3, %r1, %r4
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_SEQ_CST, __ATOMIC_SEQ_CST);
  return ret;
}

// CHECK-LABEL: @test_atomic_compare_exchange_i64
int test_atomic_compare_exchange_i64(i64 *p, i64 *e, i64 d) {
  volatile int ret = 0;
  // CHECK: casd %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_RELAXED, __ATOMIC_RELAXED);

  // CHECK: casda %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_ACQUIRE, __ATOMIC_RELAXED);
  // CHECK: casda %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_ACQUIRE, __ATOMIC_ACQUIRE);
  // CHECK: casda %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_ACQUIRE, __ATOMIC_CONSUME);

  // CHECK: casda %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_CONSUME, __ATOMIC_RELAXED);
  // CHECK: casda %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_CONSUME, __ATOMIC_ACQUIRE);
  // CHECK: casda %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_CONSUME, __ATOMIC_CONSUME);

  // CHECK: casdr %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_RELEASE, __ATOMIC_RELAXED);

  // CHECK: casdar %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_ACQ_REL, __ATOMIC_RELAXED);
  // CHECK: casdar %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_ACQ_REL, __ATOMIC_CONSUME);
  // CHECK: casdar %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_ACQ_REL, __ATOMIC_ACQUIRE);

  // CHECK: fencesc
  // CHECK: casd %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_SEQ_CST, __ATOMIC_RELAXED);
  // CHECK: fencesc
  // CHECK: casd %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_SEQ_CST, __ATOMIC_ACQUIRE);
  // CHECK: fencesc
  // CHECK: casd %r5, %r1, %r6
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_SEQ_CST, __ATOMIC_CONSUME);
  // CHECK: fencesc
  // CHECK: casd %r3, %r1, %r4
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_SEQ_CST, __ATOMIC_SEQ_CST);
  return ret;
}

// CHECK-LABEL: @test_atomic_compare_exchange_i128
int test_atomic_compare_exchange_i128(i128 *p, i128 *e, i128 d) {
  volatile int ret = 0;
  // CHECK: casq %r5, %r1, %r4
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_RELAXED, __ATOMIC_RELAXED);

  // CHECK: casqa %r5, %r1, %r4
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_ACQUIRE, __ATOMIC_RELAXED);
  // CHECK: casqa %r5, %r1, %r4
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_ACQUIRE, __ATOMIC_ACQUIRE);
  // CHECK: casqa %r5, %r1, %r4
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_ACQUIRE, __ATOMIC_CONSUME);

  // CHECK: casqa %r5, %r1, %r4
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_CONSUME, __ATOMIC_RELAXED);
  // CHECK: casqa %r5, %r1, %r4
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_CONSUME, __ATOMIC_ACQUIRE);
  // CHECK: casqa %r5, %r1, %r4
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_CONSUME, __ATOMIC_CONSUME);

  // CHECK: casqr %r5, %r1, %r4
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_RELEASE, __ATOMIC_RELAXED);

  // CHECK: casqar %r5, %r1, %r4
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_ACQ_REL, __ATOMIC_RELAXED);
  // CHECK: casqar %r5, %r1, %r4
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_ACQ_REL, __ATOMIC_CONSUME);
  // CHECK: casqar %r5, %r1, %r4
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_ACQ_REL, __ATOMIC_ACQUIRE);

  // CHECK: fencesc
  // CHECK: casq %r5, %r1, %r4
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_SEQ_CST, __ATOMIC_RELAXED);
  // CHECK: fencesc
  // CHECK: casq %r5, %r1, %r4
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_SEQ_CST, __ATOMIC_ACQUIRE);
  // CHECK: fencesc
  // CHECK: casq %r5, %r1, %r4
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_SEQ_CST, __ATOMIC_CONSUME);
  // CHECK: fencesc
  // CHECK: casq %r3, %r1, %r4
  ret += __atomic_compare_exchange_n(p, e, d, false, __ATOMIC_SEQ_CST, __ATOMIC_SEQ_CST);
  return ret;
}
