// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include <stdarg.h>

_Static_assert(sizeof(va_list) == sizeof(void*), "va_list expected contain one pointer");

extern int test_va_list_callback(int t, long x, char *p, va_list ap);

int test_va_start(int count, ...)
{
  char buf[128];
  // CHECK: alloc_sp 7, 144
  // CHECK: add_imm_i64    %r6, %sp, 144
  va_list args;

  // CHECK: st_i64    %r6, %sp, 8
  va_start(args, count);
  // CHECK: add_imm_i32 %r3, %r1, 1
  // CHECK: add_imm_i32 %r4, %r1, -1
  // CHECK: add_imm_i64   %r5, %sp, 16
  // CHECK: call  %r2, %jpc(test_va_list_callback)
  return test_va_list_callback(count+1, count-1, buf, args);
  // CHECK: mov   %r1, %r3
  // CHECK: retf 144
}

extern int test_va_callback(int t, long x, char *p, va_list *ap);

// CHECK-LABEL: @test_va_start_end
int test_va_start_end(int count, ...)
{
  char buf[128];
  // CHECK: alloc_sp 8, 144
  va_list args;

  // CHECK: add_imm_i64  %r1, %sp, 144
  // CHECK: st_i64   %r1, %sp, 8
  va_start(args, count); // count can be omitted since C23

  // CHECK: nop 1000
  __builtin_postrisc_nop(1000);

  // CHECK: ld_u64 %r1, %sp, 8
  // CHECK: alignup_u64 %r1, %r1, 0, 2
  // CHECK: add_imm_i64 %r2, %r1, 4
  // CHECK: st_i64  %r2, %sp, 8
  // CHECK: ld_u32 %r4, %r1, 0

  int result = va_arg(args, int);

  // CHECK: nop 1001
  __builtin_postrisc_nop(1001);

  // CHECK: ld_u64    %r1, %sp, 8
  // CHECK: alignup_u64 %r1, %r1, 0, 3
  // CHECK: add_imm_i64 %r2, %r1, 8
  // CHECK: st_i64    %r2, %sp, 8
  // CHECK: ld_u64    %r5, %r1, 0

  long resultl = va_arg(args, long);

  // CHECK: nop 1002
  // CHECK: nop 1003
  __builtin_postrisc_nop(1002);
  va_end(args);
  __builtin_postrisc_nop(1003);

  // CHECK:     add_imm_i64 %r6, %sp, 16

  // CHECK:     call %r3, %jpc(test_va_callback)
  // CHECK:     mov   %r1, %r4
  // CHECK:     retf  144
  return test_va_callback(result, resultl, buf, &args);
}

extern int test_printf_callback(int t, va_list *ap);

// CHECK-LABEL: @test_printf_valist
int test_printf_valist(char const *fmt, va_list ap)
{
  // CHECK: alloc_sp 6, 16
  // CHECK: st_i64 %r2, %sp, 8
  // CHECK: st_i64 %r2, %sp, 0

  va_list ap2;
  va_copy(ap2, ap);

  // CHECK: ld_imm %r4, 100
  // CHECK: add_imm_i64 %r1, %sp, 0
  // CHECK: mov %r5, %r1
  // CHECK: call %r3, %jpc(test_printf_callback)
  test_printf_callback(100, &ap2);
  // CHECK: ld_imm %r4, 200
  // CHECK: mov %r5, %r1
  // CHECK: call %r3, %jpc(test_printf_callback)
  return test_printf_callback(200, &ap2);
}

extern int test_vprintf_callback(int t, va_list *ap);

// CHECK-LABEL: @test_vprintf_valist
int test_vprintf_valist(char const *fmt, va_list ap)
{
  // CHECK: alloc_sp 6, 32
  // CHECK: st_i64 %r2, %sp, 24
  // CHECK: st_i64 %r2, %sp, 16
  // CHECK: st_i64 %r2, %sp, 8

  va_list ap2;
  va_copy(ap2, ap);
  va_list ap3;
  va_copy(ap3, ap);

  // CHECK: ld_imm %r4, 100
  // CHECK: add_imm_i64 %r5, %sp, 16
  // CHECK: call %r3, %jpc(test_vprintf_callback)
  test_vprintf_callback(100, &ap2);
  // CHECK: ld_imm   %r4, 200
  // CHECK: add_imm_i64 %r5, %sp, 8
  // CHECK: call %r3, %jpc(test_vprintf_callback)
  return test_vprintf_callback(200, &ap3);
  // CHECK: mov  %r1, %r4
  // CHECK: retf 32
}

extern int test_valist_callback(va_list *ap);

extern void *memcpy(void *dst, void const *src, unsigned long size);

// CHECK-LABEL: @test_vacopy
int test_vacopy(char const *fmt, va_list ap)
{
  va_list ap2;
  // memcpy(&ap2, &ap, sizeof(va_list));
  va_copy(ap2, ap);
  // FIXME: something wrong with va_list copy reuse
  // CHECK: alloc_sp 5, 16
  // CHECK: st_i64 %r2, %sp, 8
  // CHECK: st_i64 %r2, %sp, 0
  // CHECK: add_imm_i64 %r1, %sp, 0
  // CHECK: mov %r4, %r1
  // CHECK: call %r3, %jpc(test_valist_callback)
  // CHECK: mov %r4, %r1
  // CHECK: call %r3, %jpc(test_valist_callback)
  // CHECK: mov %r1, %r4
  // CHECK: retf 16
  test_valist_callback(&ap2);
  return test_valist_callback(&ap2);
}

