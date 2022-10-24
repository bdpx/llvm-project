// RUN: clang %cflags %s | FileCheck %s
// REQUIRES: postrisc-registered-target

#include "common.h"

// https://gcc.gnu.org/onlinedocs/gcc/_005f_005fatomic-Builtins.html

/*
__ATOMIC_RELAXED
  Implies no inter-thread ordering constraints.
__ATOMIC_CONSUME
  This is currently implemented using the stronger __ATOMIC_ACQUIRE memory order
  because of a deficiency in C++11’s semantics for memory_order_consume.
__ATOMIC_ACQUIRE
  Creates an inter-thread happens-before constraint from the release (or stronger) semantic store to this acquire load.
  Can prevent hoisting of code to before the operation.
__ATOMIC_RELEASE
  Creates an inter-thread happens-before constraint to acquire (or stronger) semantic loads that read from this release store.
  Can prevent sinking of code to after the operation.
__ATOMIC_ACQ_REL
  Combines the effects of both __ATOMIC_ACQUIRE and __ATOMIC_RELEASE.
__ATOMIC_SEQ_CST
  Enforces total ordering with all other __ATOMIC_SEQ_CST operations.

Built-in Function: bool __atomic_test_and_set (void *ptr, int memorder)
  This built-in function performs an atomic test-and-set operation on the byte at *ptr.
  The byte is set to some implementation defined nonzero “set” value
  and the return value is true if and only if the previous contents were “set”.
  It should be only used for operands of type bool or char. For other types only part of the value may be set.
  All memory orders are valid.

Built-in Function: void __atomic_clear (bool *ptr, int memorder)
  This built-in function performs an atomic clear operation on *ptr.
  After the operation, *ptr contains 0.
  It should be only used for operands of type bool or char and in conjunction with __atomic_test_and_set.
  For other types it may only clear partially. If the type is not bool prefer using __atomic_store.

  The valid memory order variants are __ATOMIC_RELAXED, __ATOMIC_SEQ_CST, and __ATOMIC_RELEASE.

Built-in Function: void __atomic_thread_fence (int memorder)
  This built-in function acts as a synchronization fence between threads based on the specified memory order.
  All memory orders are valid.

Built-in Function: void __atomic_signal_fence (int memorder)
  This built-in function acts as a synchronization fence between a thread and signal handlers based in the same thread.
  All memory orders are valid.

Built-in Function: bool __atomic_always_lock_free (size_t size, void *ptr)
  This built-in function returns true if objects of size bytes always generate
  lock-free atomic instructions for the target architecture.
  size must resolve to a compile-time constant and the result also resolves to a compile-time constant.

  ptr is an optional pointer to the object that may be used to determine alignment.
  A value of 0 indicates typical alignment should be used.
  The compiler may also ignore this parameter.

  if (__atomic_always_lock_free (sizeof (long long), 0))

Built-in Function: bool __atomic_is_lock_free (size_t size, void *ptr)
  This built-in function returns true if objects of size bytes always generate
  lock-free atomic instructions for the target architecture.
  If the built-in function is not known to be lock-free,
  a call is made to a runtime routine named __atomic_is_lock_free.

  ptr is an optional pointer to the object that may be used to determine alignment.
  A value of 0 indicates typical alignment should be used.
  The compiler may also ignore this parameter.

*/

// CHECK-LABEL: @test_fence_acquire
// CHECK: fence.a
void test_fence_acquire(void) {
  __atomic_thread_fence(__ATOMIC_ACQUIRE);
}

// CHECK-LABEL: @test_fence_release
// CHECK: fence.r
void test_fence_release(void) {
  __atomic_thread_fence(__ATOMIC_RELEASE);
}

// CHECK-LABEL: @test_fence_acq_rel
// CHECK: fence.ar
void test_fence_acq_rel(void) {
  __atomic_thread_fence(__ATOMIC_ACQ_REL);
}

// CHECK-LABEL: @test_fence_seq_cst
// CHECK: fence.sc
void test_fence_seq_cst(void) {
  __atomic_thread_fence(__ATOMIC_SEQ_CST);
}

// FIXME: compiler-time MEMBARRIER failed
// CHECK-LABEL: @test_compiler_fence
void test_compiler_fence(void) {
  // nothing should be added
  // CHECK: ret.f
  __atomic_signal_fence(__ATOMIC_SEQ_CST);
}
