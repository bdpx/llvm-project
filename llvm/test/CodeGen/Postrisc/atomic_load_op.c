// RUN: clang %cflags %s | FileCheck %s
// REQUIRES: postrisc-registered-target

#include "common.h"

/*
Built-in Function: type __atomic_add_fetch (type *ptr, type val, int memorder)
Built-in Function: type __atomic_sub_fetch (type *ptr, type val, int memorder)
Built-in Function: type __atomic_and_fetch (type *ptr, type val, int memorder)
Built-in Function: type __atomic_xor_fetch (type *ptr, type val, int memorder)
Built-in Function: type __atomic_or_fetch (type *ptr, type val, int memorder)
Built-in Function: type __atomic_nand_fetch (type *ptr, type val, int memorder)
  These built-in functions perform the operation suggested by the name, and return the result of the operation.
  Operations on pointer arguments are performed as if the operands were of the uintptr_t type.
  That is, they are not scaled by the size of the type to which the pointer points.

  { *ptr op= val; return *ptr; }
  { *ptr = ~(*ptr & val); return *ptr; } // nand
  The object pointed to by the first argument must be of integer or pointer type.
  It must not be a boolean type. All memory orders are valid.

Built-in Function: type __atomic_fetch_add (type *ptr, type val, int memorder)
Built-in Function: type __atomic_fetch_sub (type *ptr, type val, int memorder)
Built-in Function: type __atomic_fetch_and (type *ptr, type val, int memorder)
Built-in Function: type __atomic_fetch_xor (type *ptr, type val, int memorder)
Built-in Function: type __atomic_fetch_or (type *ptr, type val, int memorder)
Built-in Function: type __atomic_fetch_nand (type *ptr, type val, int memorder)
  These built-in functions perform the operation suggested by the name,
  and return the value that had previously been in *ptr.
  Operations on pointer arguments are performed as if the operands were of the uintptr_t type.
  That is, they are not scaled by the size of the type to which the pointer points.

  { tmp = *ptr; *ptr op= val; return tmp; }
  { tmp = *ptr; *ptr = ~(*ptr & val); return tmp; } // nand
  The same constraints on arguments apply as for the corresponding __atomic_op_fetch built-in functions. All memory orders are valid.
*/

// CHECK-LABEL: @test_atomic_load_op_i8
i8 test_atomic_load_op_i8(i8 value,
  i8 *a, i8 *b, i8 *c, i8 *d, i8 *e, i8 *f) {

  // CHECK: ld.add.b %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELAXED);
  // CHECK: sub.ws %r1, %gz, %r1
  // CHECK: ld.add.b %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.and.b %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.or.b %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.xor.b %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.smin.b %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.smax.b %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELAXED);


  // CHECK: ld.add.b.a %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_CONSUME);
  // CHECK: sub.ws %r1, %gz, %r1
  // CHECK: ld.add.b.a %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.and.b.a %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.or.b.a %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.xor.b.a %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.smin.b.a %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.smax.b.a %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_CONSUME);

  // CHECK: ld.add.b.a %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQUIRE);
  // CHECK: sub.ws %r1, %gz, %r1
  // CHECK: ld.add.b.a %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.and.b.a %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.or.b.a %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.xor.b.a %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.smin.b.a %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.smax.b.a %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQUIRE);


  // CHECK: ld.add.b.r %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELEASE);
  // CHECK: sub.ws %r1, %gz, %r1
  // CHECK: ld.add.b.r %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.and.b.r %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.or.b.r %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.xor.b.r %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.smin.b.r %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.smax.b.r %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELEASE);


  // CHECK: ld.add.b.ar %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQ_REL);
  // CHECK: sub.ws %r1, %gz, %r1
  // CHECK: ld.add.b.ar %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.and.b.ar %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.or.b.ar %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.xor.b.ar %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.smin.b.ar %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.smax.b.ar %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQ_REL);


  // CHECK: fence.sc
  // CHECK: ld.add.b %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: sub.ws %r1, %gz, %r1
  // CHECK: ld.add.b %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.and.b %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.or.b %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.xor.b %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.smin.b %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.smax.b %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_SEQ_CST);

  return value;
}

// CHECK-LABEL: @test_atomic_load_op_u8
u8 test_atomic_load_op_u8(u8 value,
  u8 *a, u8 *b, u8 *c, u8 *d, u8 *e, u8 *f) {
  // CHECK: ld.add.b %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELAXED);
  // CHECK: sub.ws %r1, %gz, %r1
  // CHECK: ld.add.b %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.and.b %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.or.b %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.xor.b %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.umin.b %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.umax.b %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELAXED);


  // CHECK: ld.add.b.a %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_CONSUME);
  // CHECK: sub.ws %r1, %gz, %r1
  // CHECK: ld.add.b.a %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.and.b.a %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.or.b.a %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.xor.b.a %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.umin.b.a %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.umax.b.a %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_CONSUME);

  // CHECK: ld.add.b.a %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQUIRE);
  // CHECK: sub.ws %r1, %gz, %r1
  // CHECK: ld.add.b.a %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.and.b.a %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.or.b.a %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.xor.b.a %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.umin.b.a %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.umax.b.a %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQUIRE);


  // CHECK: ld.add.b.r %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELEASE);
  // CHECK: sub.ws %r1, %gz, %r1
  // CHECK: ld.add.b.r %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.and.b.r %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.or.b.r %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.xor.b.r %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.umin.b.r %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.umax.b.r %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELEASE);


  // CHECK: ld.add.b.ar %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQ_REL);
  // CHECK: sub.ws %r1, %gz, %r1
  // CHECK: ld.add.b.ar %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.and.b.ar %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.or.b.ar %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.xor.b.ar %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.umin.b.ar %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.umax.b.ar %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQ_REL);


  // CHECK: fence.sc
  // CHECK: ld.add.b %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: sub.ws %r1, %gz, %r1
  // CHECK: ld.add.b %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.and.b %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.or.b %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.xor.b %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.umin.b %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.umax.b %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_SEQ_CST);

  return value;
}

// CHECK-LABEL: @test_atomic_load_op_i16
i16 test_atomic_load_op_i16(i16 value,
  i16 *a, i16 *b, i16 *c, i16 *d, i16 *e, i16 *f) {

  // CHECK: ld.add.h %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELAXED);
  // CHECK: sub.ws %r1, %gz, %r1
  // CHECK: ld.add.h %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.and.h %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.or.h %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.xor.h %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.smin.h %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.smax.h %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELAXED);


  // CHECK: ld.add.h.a %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_CONSUME);
  // CHECK: sub.ws %r1, %gz, %r1
  // CHECK: ld.add.h.a %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.and.h.a %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.or.h.a %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.xor.h.a %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.smin.h.a %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.smax.h.a %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_CONSUME);

  // CHECK: ld.add.h.a %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQUIRE);
  // CHECK: sub.ws %r1, %gz, %r1
  // CHECK: ld.add.h.a %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.and.h.a %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.or.h.a %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.xor.h.a %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.smin.h.a %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.smax.h.a %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQUIRE);


  // CHECK: ld.add.h.r %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELEASE);
  // CHECK: sub.ws %r1, %gz, %r1
  // CHECK: ld.add.h.r %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.and.h.r %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.or.h.r %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.xor.h.r %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.smin.h.r %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.smax.h.r %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELEASE);


  // CHECK: ld.add.h.ar %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQ_REL);
  // CHECK: sub.ws %r1, %gz, %r1
  // CHECK: ld.add.h.ar %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.and.h.ar %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.or.h.ar %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.xor.h.ar %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.smin.h.ar %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.smax.h.ar %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQ_REL);


  // CHECK: fence.sc
  // CHECK: ld.add.h %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: sub.ws %r1, %gz, %r1
  // CHECK: ld.add.h %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.and.h %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.or.h %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.xor.h %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.smin.h %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.smax.h %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_SEQ_CST);

  return value;
}

// CHECK-LABEL: @test_atomic_load_op_u16
u16 test_atomic_load_op_u16(u16 value,
  u16 *a, u16 *b, u16 *c, u16 *d, u16 *e, u16 *f) {
  // CHECK: ld.add.h %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELAXED);
  // CHECK: sub.ws %r1, %gz, %r1
  // CHECK: ld.add.h %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.and.h %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.or.h %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.xor.h %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.umin.h %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.umax.h %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELAXED);


  // CHECK: ld.add.h.a %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_CONSUME);
  // CHECK: sub.ws %r1, %gz, %r1
  // CHECK: ld.add.h.a %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.and.h.a %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.or.h.a %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.xor.h.a %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.umin.h.a %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.umax.h.a %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_CONSUME);

  // CHECK: ld.add.h.a %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQUIRE);
  // CHECK: sub.ws %r1, %gz, %r1
  // CHECK: ld.add.h.a %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.and.h.a %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.or.h.a %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.xor.h.a %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.umin.h.a %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.umax.h.a %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQUIRE);


  // CHECK: ld.add.h.r %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELEASE);
  // CHECK: sub.ws %r1, %gz, %r1
  // CHECK: ld.add.h.r %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.and.h.r %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.or.h.r %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.xor.h.r %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.umin.h.r %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.umax.h.r %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELEASE);


  // CHECK: ld.add.h.ar %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQ_REL);
  // CHECK: sub.ws %r1, %gz, %r1
  // CHECK: ld.add.h.ar %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.and.h.ar %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.or.h.ar %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.xor.h.ar %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.umin.h.ar %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.umax.h.ar %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQ_REL);


  // CHECK: fence.sc
  // CHECK: ld.add.h %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: sub.ws %r1, %gz, %r1
  // CHECK: ld.add.h %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.and.h %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.or.h %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.xor.h %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.umin.h %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.umax.h %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_SEQ_CST);

  return value;
}

// CHECK-LABEL: @test_atomic_load_op_i32
i32 test_atomic_load_op_i32(i32 value,
  i32 *a, i32 *b, i32 *c, i32 *d, i32 *e, i32 *f) {

  // CHECK: ld.add.w %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELAXED);
  // CHECK: sub.ws %r1, %gz, %r1
  // CHECK: ld.add.w %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.and.w %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.or.w %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.xor.w %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.smin.w %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.smax.w %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELAXED);


  // CHECK: ld.add.w.a %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_CONSUME);
  // CHECK: sub.ws %r1, %gz, %r1
  // CHECK: ld.add.w.a %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.and.w.a %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.or.w.a %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.xor.w.a %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.smin.w.a %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.smax.w.a %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_CONSUME);

  // CHECK: ld.add.w.a %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQUIRE);
  // CHECK: sub.ws %r1, %gz, %r1
  // CHECK: ld.add.w.a %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.and.w.a %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.or.w.a %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.xor.w.a %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.smin.w.a %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.smax.w.a %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQUIRE);


  // CHECK: ld.add.w.r %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELEASE);
  // CHECK: sub.ws %r1, %gz, %r1
  // CHECK: ld.add.w.r %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.and.w.r %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.or.w.r %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.xor.w.r %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.smin.w.r %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.smax.w.r %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELEASE);


  // CHECK: ld.add.w.ar %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQ_REL);
  // CHECK: sub.ws %r1, %gz, %r1
  // CHECK: ld.add.w.ar %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.and.w.ar %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.or.w.ar %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.xor.w.ar %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.smin.w.ar %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.smax.w.ar %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQ_REL);


  // CHECK: fence.sc
  // CHECK: ld.add.w %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: sub.ws %r1, %gz, %r1
  // CHECK: ld.add.w %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.and.w %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.or.w %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.xor.w %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.smin.w %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.smax.w %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_SEQ_CST);

  return value;
}

// CHECK-LABEL: @test_atomic_load_op_u32
u32 test_atomic_load_op_u32(u32 value,
  u32 *a, u32 *b, u32 *c, u32 *d, u32 *e, u32 *f) {

  // CHECK: ld.add.w %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELAXED);
  // CHECK: sub.ws %r1, %gz, %r1
  // CHECK: ld.add.w %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.and.w %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.or.w %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.xor.w %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.umin.w %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.umax.w %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELAXED);


  // CHECK: ld.add.w.a %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_CONSUME);
  // CHECK: sub.ws %r1, %gz, %r1
  // CHECK: ld.add.w.a %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.and.w.a %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.or.w.a %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.xor.w.a %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.umin.w.a %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.umax.w.a %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_CONSUME);

  // CHECK: ld.add.w.a %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQUIRE);
  // CHECK: sub.ws %r1, %gz, %r1
  // CHECK: ld.add.w.a %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.and.w.a %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.or.w.a %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.xor.w.a %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.umin.w.a %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.umax.w.a %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQUIRE);


  // CHECK: ld.add.w.r %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELEASE);
  // CHECK: sub.ws %r1, %gz, %r1
  // CHECK: ld.add.w.r %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.and.w.r %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.or.w.r %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.xor.w.r %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.umin.w.r %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.umax.w.r %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELEASE);


  // CHECK: ld.add.w.ar %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQ_REL);
  // CHECK: sub.ws %r1, %gz, %r1
  // CHECK: ld.add.w.ar %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.and.w.ar %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.or.w.ar %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.xor.w.ar %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.umin.w.ar %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.umax.w.ar %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQ_REL);


  // CHECK: fence.sc
  // CHECK: ld.add.w %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: sub.ws %r1, %gz, %r1
  // CHECK: ld.add.w %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.and.w %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.or.w %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.xor.w %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.umin.w %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.umax.w %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_SEQ_CST);

  return value;
}

// CHECK-LABEL: @test_atomic_load_op_i64
i64 test_atomic_load_op_i64(i64 value,
  i64 *a, i64 *b, i64 *c, i64 *d, i64 *e, i64 *f) {

  // CHECK: ld.add.d %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELAXED);
  // CHECK: sub %r1, %gz, %r1
  // CHECK: ld.add.d %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.and.d %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.or.d %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.xor.d %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.smin.d %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.smax.d %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELAXED);


  // CHECK: ld.add.d.a %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_CONSUME);
  // CHECK: sub %r1, %gz, %r1
  // CHECK: ld.add.d.a %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.and.d.a %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.or.d.a %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.xor.d.a %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.smin.d.a %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.smax.d.a %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_CONSUME);

  // CHECK: ld.add.d.a %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQUIRE);
  // CHECK: sub %r1, %gz, %r1
  // CHECK: ld.add.d.a %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.and.d.a %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.or.d.a %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.xor.d.a %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.smin.d.a %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.smax.d.a %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQUIRE);


  // CHECK: ld.add.d.r %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELEASE);
  // CHECK: sub %r1, %gz, %r1
  // CHECK: ld.add.d.r %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.and.d.r %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.or.d.r %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.xor.d.r %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.smin.d.r %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.smax.d.r %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELEASE);


  // CHECK: ld.add.d.ar %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQ_REL);
  // CHECK: sub %r1, %gz, %r1
  // CHECK: ld.add.d.ar %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.and.d.ar %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.or.d.ar %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.xor.d.ar %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.smin.d.ar %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.smax.d.ar %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQ_REL);


  // CHECK: fence.sc
  // CHECK: ld.add.d %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: sub %r1, %gz, %r1
  // CHECK: ld.add.d %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.and.d %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.or.d %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.xor.d %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.smin.d %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.smax.d %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_SEQ_CST);

  return value;
}

// CHECK-LABEL: @test_atomic_load_op_u64
u64 test_atomic_load_op_u64(u64 value,
  u64 *a, u64 *b, u64 *c, u64 *d, u64 *e, u64 *f) {
  // CHECK: ld.add.d %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELAXED);
  // CHECK: sub %r1, %gz, %r1
  // CHECK: ld.add.d %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.and.d %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.or.d %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.xor.d %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.umin.d %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.umax.d %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELAXED);


  // CHECK: ld.add.d.a %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_CONSUME);
  // CHECK: sub %r1, %gz, %r1
  // CHECK: ld.add.d.a %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.and.d.a %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.or.d.a %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.xor.d.a %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.umin.d.a %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.umax.d.a %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_CONSUME);

  // CHECK: ld.add.d.a %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQUIRE);
  // CHECK: sub %r1, %gz, %r1
  // CHECK: ld.add.d.a %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.and.d.a %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.or.d.a %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.xor.d.a %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.umin.d.a %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.umax.d.a %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQUIRE);


  // CHECK: ld.add.d.r %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELEASE);
  // CHECK: sub %r1, %gz, %r1
  // CHECK: ld.add.d.r %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.and.d.r %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.or.d.r %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.xor.d.r %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.umin.d.r %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.umax.d.r %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELEASE);


  // CHECK: ld.add.d.ar %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQ_REL);
  // CHECK: sub %r1, %gz, %r1
  // CHECK: ld.add.d.ar %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.and.d.ar %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.or.d.ar %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.xor.d.ar %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.umin.d.ar %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.umax.d.ar %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQ_REL);


  // CHECK: fence.sc
  // CHECK: ld.add.d %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: sub %r1, %gz, %r1
  // CHECK: ld.add.d %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.and.d %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.or.d %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.xor.d %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.umin.d %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.umax.d %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_SEQ_CST);

  return value;
}

// CHECK-LABEL: @test_atomic_load_op_i128
i128 test_atomic_load_op_i128(i128 value,
  i128 *a, i128 *b, i128 *c, i128 *d, i128 *e, i128 *f) {

  // CHECK: ld.add.q %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELAXED);
  // CHECK: sub.q %r1, %gz, %r1
  // CHECK: ld.add.q %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.and.q %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.or.q %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.xor.q %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.smin.q %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.smax.q %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELAXED);


  // CHECK: ld.add.q.a %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_CONSUME);
  // CHECK: sub.q %r1, %gz, %r1
  // CHECK: ld.add.q.a %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.and.q.a %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.or.q.a %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.xor.q.a %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.smin.q.a %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.smax.q.a %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_CONSUME);

  // CHECK: ld.add.q.a %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQUIRE);
  // CHECK: sub.q %r1, %gz, %r1
  // CHECK: ld.add.q.a %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.and.q.a %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.or.q.a %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.xor.q.a %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.smin.q.a %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.smax.q.a %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQUIRE);


  // CHECK: ld.add.q.r %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELEASE);
  // CHECK: sub.q %r1, %gz, %r1
  // CHECK: ld.add.q.r %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.and.q.r %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.or.q.r %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.xor.q.r %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.smin.q.r %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.smax.q.r %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELEASE);


  // CHECK: ld.add.q.ar %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQ_REL);
  // CHECK: sub.q %r1, %gz, %r1
  // CHECK: ld.add.q.ar %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.and.q.ar %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.or.q.ar %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.xor.q.ar %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.smin.q.ar %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.smax.q.ar %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQ_REL);


  // CHECK: fence.sc
  // CHECK: ld.add.q %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: sub.q %r1, %gz, %r1
  // CHECK: ld.add.q %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.and.q %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.or.q %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.xor.q %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.smin.q %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.smax.q %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_SEQ_CST);

  return value;
}

// CHECK-LABEL: @test_atomic_load_op_u128
u128 test_atomic_load_op_u128(u128 value,
  u128 *a, u128 *b, u128 *c, u128 *d, u128 *e, u128 *f) {
  // CHECK: ld.add.q %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELAXED);
  // CHECK: sub.q %r1, %gz, %r1
  // CHECK: ld.add.q %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.and.q %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.or.q %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.xor.q %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.umin.q %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELAXED);
  // CHECK: ld.umax.q %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELAXED);


  // CHECK: ld.add.q.a %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_CONSUME);
  // CHECK: sub.q %r1, %gz, %r1
  // CHECK: ld.add.q.a %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.and.q.a %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.or.q.a %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.xor.q.a %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.umin.q.a %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_CONSUME);
  // CHECK: ld.umax.q.a %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_CONSUME);

  // CHECK: ld.add.q.a %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQUIRE);
  // CHECK: sub.q %r1, %gz, %r1
  // CHECK: ld.add.q.a %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.and.q.a %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.or.q.a %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.xor.q.a %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.umin.q.a %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQUIRE);
  // CHECK: ld.umax.q.a %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQUIRE);


  // CHECK: ld.add.q.r %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_RELEASE);
  // CHECK: sub.q %r1, %gz, %r1
  // CHECK: ld.add.q.r %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.and.q.r %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.or.q.r %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.xor.q.r %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.umin.q.r %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_RELEASE);
  // CHECK: ld.umax.q.r %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_RELEASE);


  // CHECK: ld.add.q.ar %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_ACQ_REL);
  // CHECK: sub.q %r1, %gz, %r1
  // CHECK: ld.add.q.ar %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.and.q.ar %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.or.q.ar %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.xor.q.ar %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.umin.q.ar %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_ACQ_REL);
  // CHECK: ld.umax.q.ar %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_ACQ_REL);


  // CHECK: fence.sc
  // CHECK: ld.add.q %r1, %r2, %r1
  value = __atomic_fetch_add(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: sub.q %r1, %gz, %r1
  // CHECK: ld.add.q %r1, %r2, %r1
  value = __atomic_fetch_sub(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.and.q %r1, %r2, %r1
  value = __atomic_fetch_and(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.or.q %r1, %r2, %r1
  value = __atomic_fetch_or(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.xor.q %r1, %r2, %r1
  value = __atomic_fetch_xor(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.umin.q %r1, %r2, %r1
  value = __atomic_fetch_min(a, value, __ATOMIC_SEQ_CST);
  // CHECK: fence.sc
  // CHECK: ld.umax.q %r1, %r2, %r1
  value = __atomic_fetch_max(a, value, __ATOMIC_SEQ_CST);

  return value;
}
