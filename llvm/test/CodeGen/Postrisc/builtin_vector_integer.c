// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_builtin_vector_i8
v16i8 test_builtin_vector_i8(v16i8 a, v16i8 b)
{
  v16i8 res = a;
  // CHECK: vaddcb %r2, %r1, %r2
  res = __builtin_postrisc_vaddcb(res, b);
  // CHECK: vaddob %r2, %r2, %r1
  res = __builtin_postrisc_vaddob(res, a);
  // CHECK: vaddssb %r2, %r2, %r1
  res = __builtin_postrisc_vaddssb(res, a);
  // CHECK: vaddusb %r2, %r2, %r1
  res = __builtin_postrisc_vaddusb(res, a);
  // CHECK: vaddub %r2, %r2, %r1
  res = __builtin_postrisc_vaddub(res, a);
  // CHECK: vavgub %r2, %r2, %r1
  res = __builtin_postrisc_vavgub(res, a);
  // CHECK: vavgsb %r2, %r2, %r1
  res = __builtin_postrisc_vavgsb(res, a);
  // CHECK: vcmpeqb %r2, %r2, %r1
  res = __builtin_postrisc_vcmpeqb(res, a);
  // CHECK: vcmpltb %r2, %r2, %r1
  res = __builtin_postrisc_vcmpltb(res, a);
  // CHECK: vcmpltub %r2, %r2, %r1
  res = __builtin_postrisc_vcmpltub(res, a);
  // CHECK: vmaxsb %r2, %r2, %r1
  res = __builtin_postrisc_vmaxsb(res, a);
  // CHECK: vmaxub %r2, %r2, %r1
  res = __builtin_postrisc_vmaxub(res, a);
  // CHECK: vminsb %r2, %r2, %r1
  res = __builtin_postrisc_vminsb(res, a);
  // CHECK: vminub %r2, %r2, %r1
  res = __builtin_postrisc_vminub(res, a);
  // CHECK: vrolb %r2, %r2, %r1
  res = __builtin_postrisc_vrolb(res, a);
  // CHECK: vrorb %r2, %r2, %r1
  res = __builtin_postrisc_vrorb(res, a);
  // CHECK: vsllb %r2, %r2, %r1
  res = __builtin_postrisc_vsllb(res, a);
  // CHECK: vsrab %r2, %r2, %r1
  res = __builtin_postrisc_vsrab(res, a);
  // CHECK: vsrlb %r2, %r2, %r1
  res = __builtin_postrisc_vsrlb(res, a);
  // CHECK: vsubbb %r2, %r2, %r1
  res = __builtin_postrisc_vsubbb(res, a);
  // CHECK: vsubob %r2, %r2, %r1
  res = __builtin_postrisc_vsubob(res, a);
  // CHECK: vsubub %r2, %r2, %r1
  res = __builtin_postrisc_vsubub(res, a);
  // CHECK: vsubssb %r2, %r2, %r1
  res = __builtin_postrisc_vsubssb(res, a);
  // CHECK: vsubusb %r1, %r2, %r1
  res = __builtin_postrisc_vsubusb(res, a);
  return res;
}

// CHECK-LABEL: @test_builtin_vector_i16
v8i16 test_builtin_vector_i16(v8i16 a, v8i16 b)
{
  v8i16 res = a;
  // CHECK: vaddch %r2, %r1, %r2
  res = __builtin_postrisc_vaddch(res, b);
  // CHECK: vaddoh %r2, %r2, %r1
  res = __builtin_postrisc_vaddoh(res, a);
  // CHECK: vaddssh %r2, %r2, %r1
  res = __builtin_postrisc_vaddssh(res, a);
  // CHECK: vaddush %r2, %r2, %r1
  res = __builtin_postrisc_vaddush(res, a);
  // CHECK: vadduh %r2, %r2, %r1
  res = __builtin_postrisc_vadduh(res, a);
  // CHECK: vavguh %r2, %r2, %r1
  res = __builtin_postrisc_vavguh(res, a);
  // CHECK: vavgsh %r2, %r2, %r1
  res = __builtin_postrisc_vavgsh(res, a);
  // CHECK: vcmpeqh %r2, %r2, %r1
  res = __builtin_postrisc_vcmpeqh(res, a);
  // CHECK: vcmplth %r2, %r2, %r1
  res = __builtin_postrisc_vcmplth(res, a);
  // CHECK: vcmpltuh %r2, %r2, %r1
  res = __builtin_postrisc_vcmpltuh(res, a);
  // CHECK: vmaxsh %r2, %r2, %r1
  res = __builtin_postrisc_vmaxsh(res, a);
  // CHECK: vmaxuh %r2, %r2, %r1
  res = __builtin_postrisc_vmaxuh(res, a);
  // CHECK: vminsh %r2, %r2, %r1
  res = __builtin_postrisc_vminsh(res, a);
  // CHECK: vminuh %r2, %r2, %r1
  res = __builtin_postrisc_vminuh(res, a);
  // CHECK: vrolh %r2, %r2, %r1
  res = __builtin_postrisc_vrolh(res, a);
  // CHECK: vrorh %r2, %r2, %r1
  res = __builtin_postrisc_vrorh(res, a);
  // CHECK: vsllh %r2, %r2, %r1
  res = __builtin_postrisc_vsllh(res, a);
  // CHECK: vsrah %r2, %r2, %r1
  res = __builtin_postrisc_vsrah(res, a);
  // CHECK: vsrlh %r2, %r2, %r1
  res = __builtin_postrisc_vsrlh(res, a);
  // CHECK: vsubbh %r2, %r2, %r1
  res = __builtin_postrisc_vsubbh(res, a);
  // CHECK: vsuboh %r2, %r2, %r1
  res = __builtin_postrisc_vsuboh(res, a);
  // CHECK: vsubuh %r2, %r2, %r1
  res = __builtin_postrisc_vsubuh(res, a);
  // CHECK: vsubssh %r2, %r2, %r1
  res = __builtin_postrisc_vsubssh(res, a);
  // CHECK: vsubush %r1, %r2, %r1
  res = __builtin_postrisc_vsubush(res, a);
  return res;
}

// CHECK-LABEL: @test_builtin_vector_i32
v4i32 test_builtin_vector_i32(v4i32 a, v4i32 b)
{
  v4i32 res = a;
  // CHECK: vaddcw %r2, %r1, %r2
  res = __builtin_postrisc_vaddcw(res, b);
  // CHECK: vaddow %r2, %r2, %r1
  res = __builtin_postrisc_vaddow(res, a);
  // CHECK: vaddssw %r2, %r2, %r1
  res = __builtin_postrisc_vaddssw(res, a);
  // CHECK: vaddusw %r2, %r2, %r1
  res = __builtin_postrisc_vaddusw(res, a);
  // CHECK: vadduw %r2, %r2, %r1
  res = __builtin_postrisc_vadduw(res, a);
  // CHECK: vavguw %r2, %r2, %r1
  res = __builtin_postrisc_vavguw(res, a);
  // CHECK: vavgsw %r2, %r2, %r1
  res = __builtin_postrisc_vavgsw(res, a);
  // CHECK: vcmpeqw %r2, %r2, %r1
  res = __builtin_postrisc_vcmpeqw(res, a);
  // CHECK: vcmpltw %r2, %r2, %r1
  res = __builtin_postrisc_vcmpltw(res, a);
  // CHECK: vcmpltuw %r2, %r2, %r1
  res = __builtin_postrisc_vcmpltuw(res, a);
  // CHECK: vmaxsw %r2, %r2, %r1
  res = __builtin_postrisc_vmaxsw(res, a);
  // CHECK: vmaxuw %r2, %r2, %r1
  res = __builtin_postrisc_vmaxuw(res, a);
  // CHECK: vminsw %r2, %r2, %r1
  res = __builtin_postrisc_vminsw(res, a);
  // CHECK: vminuw %r2, %r2, %r1
  res = __builtin_postrisc_vminuw(res, a);
  // CHECK: vrolw %r2, %r2, %r1
  res = __builtin_postrisc_vrolw(res, a);
  // CHECK: vrorw %r2, %r2, %r1
  res = __builtin_postrisc_vrorw(res, a);
  // CHECK: vsllw %r2, %r2, %r1
  res = __builtin_postrisc_vsllw(res, a);
  // CHECK: vsraw %r2, %r2, %r1
  res = __builtin_postrisc_vsraw(res, a);
  // CHECK: vsrlw %r2, %r2, %r1
  res = __builtin_postrisc_vsrlw(res, a);
  // CHECK: vsubbw %r2, %r2, %r1
  res = __builtin_postrisc_vsubbw(res, a);
  // CHECK: vsubow %r2, %r2, %r1
  res = __builtin_postrisc_vsubow(res, a);
  // CHECK: vsubuw %r2, %r2, %r1
  res = __builtin_postrisc_vsubuw(res, a);
  // CHECK: vsubssw %r2, %r2, %r1
  res = __builtin_postrisc_vsubssw(res, a);
  // CHECK: vsubusw %r1, %r2, %r1
  res = __builtin_postrisc_vsubusw(res, a);
  return res;
}

// CHECK-LABEL: @test_builtin_vector_i64
v2i64 test_builtin_vector_i64(v2i64 a, v2i64 b)
{
  v2i64 res = a;
  // CHECK: vaddcd %r2, %r1, %r2
  res = __builtin_postrisc_vaddcd(res, b);
  // CHECK: vaddod %r2, %r2, %r1
  res = __builtin_postrisc_vaddod(res, a);
  // CHECK: vaddssd %r2, %r2, %r1
  res = __builtin_postrisc_vaddssd(res, a);
  // CHECK: vaddusd %r2, %r2, %r1
  res = __builtin_postrisc_vaddusd(res, a);
  // CHECK: vaddud %r2, %r2, %r1
  res = __builtin_postrisc_vaddud(res, a);
  // CHECK: vavgud %r2, %r2, %r1
  res = __builtin_postrisc_vavgud(res, a);
  // CHECK: vavgsd %r2, %r2, %r1
  res = __builtin_postrisc_vavgsd(res, a);
  // CHECK: vcmpeqd %r2, %r2, %r1
  res = __builtin_postrisc_vcmpeqd(res, a);
  // CHECK: vcmpltd %r2, %r2, %r1
  res = __builtin_postrisc_vcmpltd(res, a);
  // CHECK: vcmpltud %r2, %r2, %r1
  res = __builtin_postrisc_vcmpltud(res, a);
  // CHECK: vmaxsd %r2, %r2, %r1
  res = __builtin_postrisc_vmaxsd(res, a);
  // CHECK: vmaxud %r2, %r2, %r1
  res = __builtin_postrisc_vmaxud(res, a);
  // CHECK: vminsd %r2, %r2, %r1
  res = __builtin_postrisc_vminsd(res, a);
  // CHECK: vminud %r2, %r2, %r1
  res = __builtin_postrisc_vminud(res, a);
  // CHECK: vrold %r2, %r2, %r1
  res = __builtin_postrisc_vrold(res, a);
  // CHECK: vrord %r2, %r2, %r1
  res = __builtin_postrisc_vrord(res, a);
  // CHECK: vslld %r2, %r2, %r1
  res = __builtin_postrisc_vslld(res, a);
  // CHECK: vsrad %r2, %r2, %r1
  res = __builtin_postrisc_vsrad(res, a);
  // CHECK: vsrld %r2, %r2, %r1
  res = __builtin_postrisc_vsrld(res, a);
  // CHECK: vsubbd %r2, %r2, %r1
  res = __builtin_postrisc_vsubbd(res, a);
  // CHECK: vsubod %r2, %r2, %r1
  res = __builtin_postrisc_vsubod(res, a);
  // CHECK: vsubud %r2, %r2, %r1
  res = __builtin_postrisc_vsubud(res, a);
  // CHECK: vsubssd %r2, %r2, %r1
  res = __builtin_postrisc_vsubssd(res, a);
  // CHECK: vsubusd %r1, %r2, %r1
  res = __builtin_postrisc_vsubusd(res, a);
  return res;
}

// CHECK-LABEL: @test_builtin_vector_mixed
v16i8 test_builtin_vector_mixed(v16i8 a1, v16i8 b1,
                                v8i16 a2, v8i16 b2,
                                v4i32 a4, v4i32 b4,
                                v2i64 a8, v2i64 b8)
{
  v16i8 r1;
  // CHECK: vmrghb %r1, %r1, %r2
  r1 = __builtin_postrisc_vmrghb(a1, b1);
  // CHECK: vmrglb %r1, %r1, %r2
  r1 = __builtin_postrisc_vmrglb(r1, b1);
  // CHECK: vmrghh %r1, %r1, %r4
  r1 = __builtin_postrisc_vmrghh(r1, b2);
  // CHECK: vmrglh %r1, %r1, %r4
  r1 = __builtin_postrisc_vmrglh(r1, b2);
  // CHECK: vmrghw %r1, %r1, %r6
  r1 = __builtin_postrisc_vmrghw(r1, b4);
  // CHECK: vmrglw %r1, %r1, %r6
  r1 = __builtin_postrisc_vmrglw(r1, b4);
  // CHECK: vmrghd %r1, %r1, %r8
  r1 = __builtin_postrisc_vmrghd(r1, b8);
  // CHECK: vmrgld %r1, %r1, %r8
  r1 = __builtin_postrisc_vmrgld(r1, b8);

  // CHECK: vpksssh %r1, %r1, %r7
  r1 = __builtin_postrisc_vpksssh(r1, a8);
  // CHECK: vpksssw %r1, %r1, %r5
  r1 = __builtin_postrisc_vpksssw(r1, a4);
  // CHECK: vpksssd %r1, %r1, %r7
  r1 = __builtin_postrisc_vpksssd(r1, a8);
  // CHECK: vpksush %r1, %r1, %r3
  r1 = __builtin_postrisc_vpksush(r1, a2);
  // CHECK: vpksusw %r1, %r1, %r6
  r1 = __builtin_postrisc_vpksusw(r1, b4);
  // CHECK: vpksusd %r1, %r1, %r8
  r1 = __builtin_postrisc_vpksusd(r1, b8);
  // CHECK: vpkuumh %r1, %r1, %r4
  r1 = __builtin_postrisc_vpkuumh(r1, b2);
  // CHECK: vpkuumw %r1, %r1, %r6
  r1 = __builtin_postrisc_vpkuumw(r1, b4);
  // CHECK: vpkuumd %r1, %r1, %r8
  r1 = __builtin_postrisc_vpkuumd(r1, b8);
  // CHECK: vpkuush %r1, %r1, %r4
  r1 = __builtin_postrisc_vpkuush(r1, b2);
  // CHECK: vpkuusw %r1, %r1, %r6
  r1 = __builtin_postrisc_vpkuusw(r1, b4);
  // CHECK: vpkuusd %r1, %r1, %r8
  r1 = __builtin_postrisc_vpkuusd(r1, b8);

  // CHECK: vupkhsb %r1, %r1
  r1 = __builtin_postrisc_vupkhsb(r1);
  // CHECK: vupkhsh %r1, %r1
  r1 = __builtin_postrisc_vupkhsh(r1);
  // CHECK: vupkhsw %r1, %r1
  r1 = __builtin_postrisc_vupkhsw(r1);
  // CHECK: vupklsb %r1, %r1
  r1 = __builtin_postrisc_vupklsb(r1);
  // CHECK: vupklsh %r1, %r1
  r1 = __builtin_postrisc_vupklsh(r1);
  // CHECK: vupklsw %r1, %r1
  r1 = __builtin_postrisc_vupklsw(r1);
  return r1;
}
