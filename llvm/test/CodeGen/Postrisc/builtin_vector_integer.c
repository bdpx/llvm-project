// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_builtin_vector_i8
v16i8 test_builtin_vector_i8(v16i8 a, v16i8 b)
{
  v16i8 res = a;
  // CHECK: vaddc.b %r2, %r1, %r2
  res = __builtin_postrisc_vaddcb(res, b);
  // CHECK: vaddo.b %r2, %r2, %r1
  res = __builtin_postrisc_vaddob(res, a);
  // CHECK: vaddss.b %r2, %r2, %r1
  res = __builtin_postrisc_vaddssb(res, a);
  // CHECK: vaddus.b %r2, %r2, %r1
  res = __builtin_postrisc_vaddusb(res, a);
  // CHECK: vaddu.b %r2, %r2, %r1
  res = __builtin_postrisc_vaddub(res, a);
  // CHECK: vavgu.b %r2, %r2, %r1
  res = __builtin_postrisc_vavgub(res, a);
  // CHECK: vavgs.b %r2, %r2, %r1
  res = __builtin_postrisc_vavgsb(res, a);
  // CHECK: vcmp.eq.b %r2, %r2, %r1
  res = __builtin_postrisc_vcmpeqb(res, a);
  // CHECK: vcmp.lt.b %r2, %r2, %r1
  res = __builtin_postrisc_vcmpltb(res, a);
  // CHECK: vcmp.ltu.b %r2, %r2, %r1
  res = __builtin_postrisc_vcmpltub(res, a);
  // CHECK: vmaxs.b %r2, %r2, %r1
  res = __builtin_postrisc_vmaxsb(res, a);
  // CHECK: vmaxu.b %r2, %r2, %r1
  res = __builtin_postrisc_vmaxub(res, a);
  // CHECK: vmins.b %r2, %r2, %r1
  res = __builtin_postrisc_vminsb(res, a);
  // CHECK: vminu.b %r2, %r2, %r1
  res = __builtin_postrisc_vminub(res, a);
  // CHECK: vrol.b %r2, %r2, %r1
  res = __builtin_postrisc_vrolb(res, a);
  // CHECK: vror.b %r2, %r2, %r1
  res = __builtin_postrisc_vrorb(res, a);
  // CHECK: vsll.b %r2, %r2, %r1
  res = __builtin_postrisc_vsllb(res, a);
  // CHECK: vsra.b %r2, %r2, %r1
  res = __builtin_postrisc_vsrab(res, a);
  // CHECK: vsrl.b %r2, %r2, %r1
  res = __builtin_postrisc_vsrlb(res, a);
  // CHECK: vsubb.b %r2, %r2, %r1
  res = __builtin_postrisc_vsubbb(res, a);
  // CHECK: vsubo.b %r2, %r2, %r1
  res = __builtin_postrisc_vsubob(res, a);
  // CHECK: vsubu.b %r2, %r2, %r1
  res = __builtin_postrisc_vsubub(res, a);
  // CHECK: vsubss.b %r2, %r2, %r1
  res = __builtin_postrisc_vsubssb(res, a);
  // CHECK: vsubus.b %r1, %r2, %r1
  res = __builtin_postrisc_vsubusb(res, a);
  return res;
}

// CHECK-LABEL: @test_builtin_vector_i16
v8i16 test_builtin_vector_i16(v8i16 a, v8i16 b)
{
  v8i16 res = a;
  // CHECK: vaddc.h %r2, %r1, %r2
  res = __builtin_postrisc_vaddch(res, b);
  // CHECK: vaddo.h %r2, %r2, %r1
  res = __builtin_postrisc_vaddoh(res, a);
  // CHECK: vaddss.h %r2, %r2, %r1
  res = __builtin_postrisc_vaddssh(res, a);
  // CHECK: vaddus.h %r2, %r2, %r1
  res = __builtin_postrisc_vaddush(res, a);
  // CHECK: vaddu.h %r2, %r2, %r1
  res = __builtin_postrisc_vadduh(res, a);
  // CHECK: vavgu.h %r2, %r2, %r1
  res = __builtin_postrisc_vavguh(res, a);
  // CHECK: vavgs.h %r2, %r2, %r1
  res = __builtin_postrisc_vavgsh(res, a);
  // CHECK: vcmp.eq.h %r2, %r2, %r1
  res = __builtin_postrisc_vcmpeqh(res, a);
  // CHECK: vcmp.lt.h %r2, %r2, %r1
  res = __builtin_postrisc_vcmplth(res, a);
  // CHECK: vcmp.ltu.h %r2, %r2, %r1
  res = __builtin_postrisc_vcmpltuh(res, a);
  // CHECK: vmaxs.h %r2, %r2, %r1
  res = __builtin_postrisc_vmaxsh(res, a);
  // CHECK: vmaxu.h %r2, %r2, %r1
  res = __builtin_postrisc_vmaxuh(res, a);
  // CHECK: vmins.h %r2, %r2, %r1
  res = __builtin_postrisc_vminsh(res, a);
  // CHECK: vminu.h %r2, %r2, %r1
  res = __builtin_postrisc_vminuh(res, a);
  // CHECK: vrol.h %r2, %r2, %r1
  res = __builtin_postrisc_vrolh(res, a);
  // CHECK: vror.h %r2, %r2, %r1
  res = __builtin_postrisc_vrorh(res, a);
  // CHECK: vsll.h %r2, %r2, %r1
  res = __builtin_postrisc_vsllh(res, a);
  // CHECK: vsra.h %r2, %r2, %r1
  res = __builtin_postrisc_vsrah(res, a);
  // CHECK: vsrl.h %r2, %r2, %r1
  res = __builtin_postrisc_vsrlh(res, a);
  // CHECK: vsubb.h %r2, %r2, %r1
  res = __builtin_postrisc_vsubbh(res, a);
  // CHECK: vsubo.h %r2, %r2, %r1
  res = __builtin_postrisc_vsuboh(res, a);
  // CHECK: vsubu.h %r2, %r2, %r1
  res = __builtin_postrisc_vsubuh(res, a);
  // CHECK: vsubss.h %r2, %r2, %r1
  res = __builtin_postrisc_vsubssh(res, a);
  // CHECK: vsubus.h %r1, %r2, %r1
  res = __builtin_postrisc_vsubush(res, a);
  return res;
}

// CHECK-LABEL: @test_builtin_vector_i32
v4i32 test_builtin_vector_i32(v4i32 a, v4i32 b)
{
  v4i32 res = a;
  // CHECK: vaddc.w %r2, %r1, %r2
  res = __builtin_postrisc_vaddcw(res, b);
  // CHECK: vaddo.w %r2, %r2, %r1
  res = __builtin_postrisc_vaddow(res, a);
  // CHECK: vaddss.w %r2, %r2, %r1
  res = __builtin_postrisc_vaddssw(res, a);
  // CHECK: vaddus.w %r2, %r2, %r1
  res = __builtin_postrisc_vaddusw(res, a);
  // CHECK: vaddu.w %r2, %r2, %r1
  res = __builtin_postrisc_vadduw(res, a);
  // CHECK: vavgu.w %r2, %r2, %r1
  res = __builtin_postrisc_vavguw(res, a);
  // CHECK: vavgs.w %r2, %r2, %r1
  res = __builtin_postrisc_vavgsw(res, a);
  // CHECK: vcmp.eq.w %r2, %r2, %r1
  res = __builtin_postrisc_vcmpeqw(res, a);
  // CHECK: vcmp.lt.w %r2, %r2, %r1
  res = __builtin_postrisc_vcmpltw(res, a);
  // CHECK: vcmp.ltu.w %r2, %r2, %r1
  res = __builtin_postrisc_vcmpltuw(res, a);
  // CHECK: vmaxs.w %r2, %r2, %r1
  res = __builtin_postrisc_vmaxsw(res, a);
  // CHECK: vmaxu.w %r2, %r2, %r1
  res = __builtin_postrisc_vmaxuw(res, a);
  // CHECK: vmins.w %r2, %r2, %r1
  res = __builtin_postrisc_vminsw(res, a);
  // CHECK: vminu.w %r2, %r2, %r1
  res = __builtin_postrisc_vminuw(res, a);
  // CHECK: vrol.w %r2, %r2, %r1
  res = __builtin_postrisc_vrolw(res, a);
  // CHECK: vror.w %r2, %r2, %r1
  res = __builtin_postrisc_vrorw(res, a);
  // CHECK: vsll.w %r2, %r2, %r1
  res = __builtin_postrisc_vsllw(res, a);
  // CHECK: vsra.w %r2, %r2, %r1
  res = __builtin_postrisc_vsraw(res, a);
  // CHECK: vsrl.w %r2, %r2, %r1
  res = __builtin_postrisc_vsrlw(res, a);
  // CHECK: vsubb.w %r2, %r2, %r1
  res = __builtin_postrisc_vsubbw(res, a);
  // CHECK: vsubo.w %r2, %r2, %r1
  res = __builtin_postrisc_vsubow(res, a);
  // CHECK: vsubu.w %r2, %r2, %r1
  res = __builtin_postrisc_vsubuw(res, a);
  // CHECK: vsubss.w %r2, %r2, %r1
  res = __builtin_postrisc_vsubssw(res, a);
  // CHECK: vsubus.w %r1, %r2, %r1
  res = __builtin_postrisc_vsubusw(res, a);
  return res;
}

// CHECK-LABEL: @test_builtin_vector_i64
v2i64 test_builtin_vector_i64(v2i64 a, v2i64 b)
{
  v2i64 res = a;
  // CHECK: vaddc.d %r2, %r1, %r2
  res = __builtin_postrisc_vaddcd(res, b);
  // CHECK: vaddo.d %r2, %r2, %r1
  res = __builtin_postrisc_vaddod(res, a);
  // CHECK: vaddss.d %r2, %r2, %r1
  res = __builtin_postrisc_vaddssd(res, a);
  // CHECK: vaddus.d %r2, %r2, %r1
  res = __builtin_postrisc_vaddusd(res, a);
  // CHECK: vaddu.d %r2, %r2, %r1
  res = __builtin_postrisc_vaddud(res, a);
  // CHECK: vavgu.d %r2, %r2, %r1
  res = __builtin_postrisc_vavgud(res, a);
  // CHECK: vavgs.d %r2, %r2, %r1
  res = __builtin_postrisc_vavgsd(res, a);
  // CHECK: vcmp.eq.d %r2, %r2, %r1
  res = __builtin_postrisc_vcmpeqd(res, a);
  // CHECK: vcmp.lt.d %r2, %r2, %r1
  res = __builtin_postrisc_vcmpltd(res, a);
  // CHECK: vcmp.ltu.d %r2, %r2, %r1
  res = __builtin_postrisc_vcmpltud(res, a);
  // CHECK: vmaxs.d %r2, %r2, %r1
  res = __builtin_postrisc_vmaxsd(res, a);
  // CHECK: vmaxu.d %r2, %r2, %r1
  res = __builtin_postrisc_vmaxud(res, a);
  // CHECK: vmins.d %r2, %r2, %r1
  res = __builtin_postrisc_vminsd(res, a);
  // CHECK: vminu.d %r2, %r2, %r1
  res = __builtin_postrisc_vminud(res, a);
  // CHECK: vrol.d %r2, %r2, %r1
  res = __builtin_postrisc_vrold(res, a);
  // CHECK: vror.d %r2, %r2, %r1
  res = __builtin_postrisc_vrord(res, a);
  // CHECK: vsll.d %r2, %r2, %r1
  res = __builtin_postrisc_vslld(res, a);
  // CHECK: vsra.d %r2, %r2, %r1
  res = __builtin_postrisc_vsrad(res, a);
  // CHECK: vsrl.d %r2, %r2, %r1
  res = __builtin_postrisc_vsrld(res, a);
  // CHECK: vsubb.d %r2, %r2, %r1
  res = __builtin_postrisc_vsubbd(res, a);
  // CHECK: vsubo.d %r2, %r2, %r1
  res = __builtin_postrisc_vsubod(res, a);
  // CHECK: vsubu.d %r2, %r2, %r1
  res = __builtin_postrisc_vsubud(res, a);
  // CHECK: vsubss.d %r2, %r2, %r1
  res = __builtin_postrisc_vsubssd(res, a);
  // CHECK: vsubus.d %r1, %r2, %r1
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
  // CHECK: vmrg.h.b %r1, %r1, %r2
  r1 = __builtin_postrisc_vmrghb(a1, b1);
  // CHECK: vmrg.l.b %r1, %r1, %r2
  r1 = __builtin_postrisc_vmrglb(r1, b1);
  // CHECK: vmrg.h.h %r1, %r1, %r4
  r1 = __builtin_postrisc_vmrghh(r1, b2);
  // CHECK: vmrg.l.h %r1, %r1, %r4
  r1 = __builtin_postrisc_vmrglh(r1, b2);
  // CHECK: vmrg.h.w %r1, %r1, %r6
  r1 = __builtin_postrisc_vmrghw(r1, b4);
  // CHECK: vmrg.l.w %r1, %r1, %r6
  r1 = __builtin_postrisc_vmrglw(r1, b4);
  // CHECK: vmrg.h.d %r1, %r1, %r8
  r1 = __builtin_postrisc_vmrghd(r1, b8);
  // CHECK: vmrg.l.d %r1, %r1, %r8
  r1 = __builtin_postrisc_vmrgld(r1, b8);

  // CHECK: vpksss.h %r1, %r1, %r7
  r1 = __builtin_postrisc_vpksssh(r1, a8);
  // CHECK: vpksss.w %r1, %r1, %r5
  r1 = __builtin_postrisc_vpksssw(r1, a4);
  // CHECK: vpksss.d %r1, %r1, %r7
  r1 = __builtin_postrisc_vpksssd(r1, a8);
  // CHECK: vpksus.h %r1, %r1, %r3
  r1 = __builtin_postrisc_vpksush(r1, a2);
  // CHECK: vpksus.w %r1, %r1, %r6
  r1 = __builtin_postrisc_vpksusw(r1, b4);
  // CHECK: vpksus.d %r1, %r1, %r8
  r1 = __builtin_postrisc_vpksusd(r1, b8);
  // CHECK: vpkuum.h %r1, %r1, %r4
  r1 = __builtin_postrisc_vpkuumh(r1, b2);
  // CHECK: vpkuum.w %r1, %r1, %r6
  r1 = __builtin_postrisc_vpkuumw(r1, b4);
  // CHECK: vpkuum.d %r1, %r1, %r8
  r1 = __builtin_postrisc_vpkuumd(r1, b8);
  // CHECK: vpkuus.h %r1, %r1, %r4
  r1 = __builtin_postrisc_vpkuush(r1, b2);
  // CHECK: vpkuus.w %r1, %r1, %r6
  r1 = __builtin_postrisc_vpkuusw(r1, b4);
  // CHECK: vpkuus.d %r1, %r1, %r8
  r1 = __builtin_postrisc_vpkuusd(r1, b8);

  // CHECK: vupkhs.b %r1, %r1
  r1 = __builtin_postrisc_vupkhsb(r1);
  // CHECK: vupkhs.h %r1, %r1
  r1 = __builtin_postrisc_vupkhsh(r1);
  // CHECK: vupkhs.w %r1, %r1
  r1 = __builtin_postrisc_vupkhsw(r1);
  // CHECK: vupkls.b %r1, %r1
  r1 = __builtin_postrisc_vupklsb(r1);
  // CHECK: vupkls.h %r1, %r1
  r1 = __builtin_postrisc_vupklsh(r1);
  // CHECK: vupkls.w %r1, %r1
  r1 = __builtin_postrisc_vupklsw(r1);
  return r1;
}
