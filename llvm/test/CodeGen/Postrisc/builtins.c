// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

#if !defined(__POSTRISC__)
#warning "__POSTRISC__" isn't defined
#endif

// CHECK-LABEL: @test_builtin_popcount
int test_builtin_popcount(i32 value)
{
  // CHECK: cnt_pop %r1, %r1, 31
  return __builtin_popcount(value);
}

// CHECK-LABEL: @test_builtin_popcountl
int test_builtin_popcountl(i64 value)
{
  // CHECK: cnt_pop %r1, %r1, 63
  return __builtin_popcountl(value);
}

// CHECK-LABEL: @test_builtin_popcountl
int test_builtin_popcountll(i64 value)
{
  // CHECK: cnt_pop %r1, %r1, 63
  return __builtin_popcountll(value);
}

// CHECK-LABEL: @test_builtin_ctz
int test_builtin_ctz(i32 value)
{
  // CHECK: cnt_tz %r1, %r1, 31
  return __builtin_ctz(value);
}

// CHECK-LABEL: @test_builtin_ctzl
int test_builtin_ctzl(i64 value)
{
  // CHECK: cnt_tz %r1, %r1, 63
  return __builtin_ctzl(value);
}

// CHECK-LABEL: @test_builtin_clz
int test_builtin_clz(i32 value)
{
  // CHECK: cnt_lz %r1, %r1, 31
  return __builtin_clz(value);
}

// CHECK-LABEL: @test_builtin_clzl
int test_builtin_clzl(i64 value)
{
  // CHECK: cnt_lz %r1, %r1, 63
  return __builtin_clzl(value);
}

// CHECK-LABEL: @test_builtin_readcyclecounter
i64 test_builtin_readcyclecounter(void)
{
    // CHECK: get_spr %r1, %itc
    return __builtin_readcyclecounter();
}

// CHECK-LABEL: @test_builtin_thread_pointer
void *test_builtin_thread_pointer(void)
{
  // CHECK: alloc 2
  // CHECK-NEXT: mov %r1, %tp
  // CHECK-NEXT: retf 0
  return __builtin_thread_pointer();
}

// CHECK-LABEL: @test_builtin_set_thread_pointer
void test_builtin_set_thread_pointer(void *ptr)
{
  // CHECK: alloc 2
  // CHECK-NEXT: mov %tp, %r1
  // CHECK-NEXT: retf 0
  __builtin_postrisc_set_thread_pointer(ptr);
}

// CHECK-LABEL: @test_frame_buitin
i64 test_frame_buitin(i64 a)
{
    i64 x = (i64)__builtin_frame_address(0);
    i64 y = (i64)__builtin_return_address(0);
    return x + y;
}

// CHECK-LABEL: @test_builtin_stack_pointer
void *test_builtin_stack_pointer(void)
{
  // CHECK: mov %r1, %sp
  return (void*)__builtin_postrisc_stack_pointer();
}

// CHECK-LABEL: @test_builtin_bitreverse
i64 test_builtin_bitreverse(int a, int argc, int b, int c)
{
  // CHECK: permb %r3, %r1, 31
  int x32 = __builtin_bitreverse32(a+argc); // llvm.bitreverse.i32
  printf("x32=%d", x32);
  i64 y64 = 11LL;
  // CHECK: permb %r2, %r1, 63
  i64 x64 = __builtin_bitreverse64(y64+argc); // llvm.bitreverse.i64
  printf("x32=%lld", x64);
  return x32 + x64;
}

// CHECK-LABEL: @test_builtin_halt
void test_builtin_halt(void)
{
  // CHECK: halt
  __builtin_postrisc_halt();
}

// CHECK-LABEL: @test_builtin_undef
void test_builtin_undef(void)
{
  // CHECK: undef
  // CHECK-NEXT: retf 0
  __builtin_postrisc_undef();
}

// CHECK-LABEL: @test_builtin_rfi
void test_builtin_rfi(void)
{
  // CHECK: rfi
  __builtin_postrisc_rfi();
}

// CHECK-LABEL: @test_builtin_nop
void test_builtin_nop(void)
{
  // CHECK: nop 1234567
  __builtin_postrisc_nop(1234567);

  // CHECK: nop.l 123456789123456789
  __builtin_postrisc_nop(123456789123456789ULL);

  // CHECK: nop 123
  __builtin_postrisc_nop(123);

  // CHECK: nop.l 123
  __builtin_postrisc_nop_l(123);
}

// CHECK-LABEL: @test_builtin_tpa
i64 test_builtin_tpa(void *ptr, u64 asid)
{
  // CHECK: tpa %r1, %r1, %r2
  return  __builtin_postrisc_tpa(ptr, asid);
}

// CHECK-LABEL: @test_builtin_random
i64 test_builtin_random(u64 ptr)
{
  // CHECK: random %r1, %r1
  u64 ret = __builtin_postrisc_random_n(ptr);
  // CHECK: random %r2, %gz
  ret += __builtin_postrisc_random();
  return ret;
}

// CHECK-LABEL: @test_builtin_cache
void test_builtin_cache(void *ptr)
{
  // CHECK: dcbf %r1, 0
  __builtin_postrisc_dcbf(ptr);
  // CHECK: dcbf %r1, 1000
  __builtin_postrisc_dcbf(ptr+1000);
  // CHECK: dcbf.l %r1, 1000000000
  __builtin_postrisc_dcbf(ptr+1000000000);

  // CHECK: dcbt %r1, 0
  __builtin_postrisc_dcbt(ptr);
  // CHECK: dcbt %r1, 1000
  __builtin_postrisc_dcbt(ptr+1000);
  // CHECK: dcbt.l %r1, 1000000000
  __builtin_postrisc_dcbt(ptr+1000000000);

  // CHECK: dcbi %r1, 0
  __builtin_postrisc_dcbi(ptr);
  // CHECK: dcbi %r1, 1000
  __builtin_postrisc_dcbi(ptr+1000);
  // CHECK: dcbi.l %r1, 1000000000
  __builtin_postrisc_dcbi(ptr+1000000000);

  // CHECK: icbi %r1, 0
  __builtin_postrisc_icbi(ptr);
  // CHECK: icbi %r1, 1000
  __builtin_postrisc_icbi(ptr+1000);
  // CHECK: icbi.l %r1, 1000000000
  __builtin_postrisc_icbi(ptr+1000000000);
}
