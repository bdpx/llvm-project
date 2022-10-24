// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_builtin_vector_i8
v16i8 test_builtin_vector_i8(v16i8 a, v16i8 b)
{
  v16i8 res = a;
  // CHECK: addc_vu8 %r2, %r1, %r2
  res = __builtin_postrisc_addc_vu8(res, b);
  // CHECK: addo_vi8 %r2, %r2, %r1
  res = __builtin_postrisc_addo_vi8(res, a);
  // CHECK: add_sat_vi8 %r2, %r2, %r1
  res = __builtin_postrisc_add_sat_vi8(res, a);
  // CHECK: add_sat_vu8 %r2, %r2, %r1
  res = __builtin_postrisc_add_sat_vu8(res, a);
  // CHECK: add_vu8 %r2, %r2, %r1
  res = __builtin_postrisc_add_vu8(res, a);
  // CHECK: avg_vu8 %r2, %r2, %r1
  res = __builtin_postrisc_avg_vu8(res, a);
  // CHECK: avg_vi8 %r2, %r2, %r1
  res = __builtin_postrisc_avg_vi8(res, a);
  // CHECK: cmp_eq_vi8 %r2, %r2, %r1
  res = __builtin_postrisc_cmp_eq_vi8(res, a);
  // CHECK: cmp_lt_vi8 %r2, %r2, %r1
  res = __builtin_postrisc_cmp_lt_vi8(res, a);
  // CHECK: cmp_lt_vu8 %r2, %r2, %r1
  res = __builtin_postrisc_cmp_lt_vu8(res, a);
  // CHECK: max_vi8 %r2, %r2, %r1
  res = __builtin_postrisc_max_vi8(res, a);
  // CHECK: max_vu8 %r2, %r2, %r1
  res = __builtin_postrisc_max_vu8(res, a);
  // CHECK: min_vi8 %r2, %r2, %r1
  res = __builtin_postrisc_min_vi8(res, a);
  // CHECK: min_vu8 %r2, %r2, %r1
  res = __builtin_postrisc_min_vu8(res, a);
  // CHECK: rol_vu8 %r2, %r2, %r1
  res = __builtin_postrisc_rol_vu8(res, a);
  // CHECK: ror_vu8 %r2, %r2, %r1
  res = __builtin_postrisc_ror_vu8(res, a);
  // CHECK: sll_vu8 %r2, %r2, %r1
  res = __builtin_postrisc_sll_vu8(res, a);
  // CHECK: sra_vi8 %r2, %r2, %r1
  res = __builtin_postrisc_sra_vi8(res, a);
  // CHECK: srl_vu8 %r2, %r2, %r1
  res = __builtin_postrisc_srl_vu8(res, a);
  // CHECK: subb_vu8 %r2, %r2, %r1
  res = __builtin_postrisc_subb_vu8(res, a);
  // CHECK: subo_vi8 %r2, %r2, %r1
  res = __builtin_postrisc_subo_vi8(res, a);
  // CHECK: sub_vu8 %r2, %r2, %r1
  res = __builtin_postrisc_sub_vu8(res, a);
  // CHECK: sub_sat_vi8 %r2, %r2, %r1
  res = __builtin_postrisc_sub_sat_vi8(res, a);
  // CHECK: sub_sat_vu8 %r1, %r2, %r1
  res = __builtin_postrisc_sub_sat_vu8(res, a);
  return res;
}

// CHECK-LABEL: @test_builtin_vector_i16
v8i16 test_builtin_vector_i16(v8i16 a, v8i16 b)
{
  v8i16 res = a;
  // CHECK: addc_vu16 %r2, %r1, %r2
  res = __builtin_postrisc_addc_vu16(res, b);
  // CHECK: addo_vi16 %r2, %r2, %r1
  res = __builtin_postrisc_addo_vi16(res, a);
  // CHECK: add_sat_vi16 %r2, %r2, %r1
  res = __builtin_postrisc_add_sat_vi16(res, a);
  // CHECK: add_sat_vu16 %r2, %r2, %r1
  res = __builtin_postrisc_add_sat_vu16(res, a);
  // CHECK: add_vu16 %r2, %r2, %r1
  res = __builtin_postrisc_add_vu16(res, a);
  // CHECK: avg_vu16 %r2, %r2, %r1
  res = __builtin_postrisc_avg_vu16(res, a);
  // CHECK: avg_vi16 %r2, %r2, %r1
  res = __builtin_postrisc_avg_vi16(res, a);
  // CHECK: cmp_eq_vi16 %r2, %r2, %r1
  res = __builtin_postrisc_cmp_eq_vi16(res, a);
  // CHECK: cmp_lt_vi16 %r2, %r2, %r1
  res = __builtin_postrisc_cmp_lt_vi16(res, a);
  // CHECK: cmp_lt_vu16 %r2, %r2, %r1
  res = __builtin_postrisc_cmp_lt_vu16(res, a);
  // CHECK: max_vi16 %r2, %r2, %r1
  res = __builtin_postrisc_max_vi16(res, a);
  // CHECK: max_vu16 %r2, %r2, %r1
  res = __builtin_postrisc_max_vu16(res, a);
  // CHECK: min_vi16 %r2, %r2, %r1
  res = __builtin_postrisc_min_vi16(res, a);
  // CHECK: min_vu16 %r2, %r2, %r1
  res = __builtin_postrisc_min_vu16(res, a);
  // CHECK: rol_vu16 %r2, %r2, %r1
  res = __builtin_postrisc_rol_vu16(res, a);
  // CHECK: ror_vu16 %r2, %r2, %r1
  res = __builtin_postrisc_ror_vu16(res, a);
  // CHECK: sll_vu16 %r2, %r2, %r1
  res = __builtin_postrisc_sll_vu16(res, a);
  // CHECK: sra_vi16 %r2, %r2, %r1
  res = __builtin_postrisc_sra_vi16(res, a);
  // CHECK: srl_vu16 %r2, %r2, %r1
  res = __builtin_postrisc_srl_vu16(res, a);
  // CHECK: subb_vu16 %r2, %r2, %r1
  res = __builtin_postrisc_subb_vu16(res, a);
  // CHECK: subo_vi16 %r2, %r2, %r1
  res = __builtin_postrisc_subo_vi16(res, a);
  // CHECK: sub_vu16 %r2, %r2, %r1
  res = __builtin_postrisc_sub_vu16(res, a);
  // CHECK: sub_sat_vi16 %r2, %r2, %r1
  res = __builtin_postrisc_sub_sat_vi16(res, a);
  // CHECK: sub_sat_vu16 %r1, %r2, %r1
  res = __builtin_postrisc_sub_sat_vu16(res, a);
  return res;
}

// CHECK-LABEL: @test_builtin_vector_i32
v4i32 test_builtin_vector_i32(v4i32 a, v4i32 b)
{
  v4i32 res = a;
  // CHECK: addc_vu32 %r2, %r1, %r2
  res = __builtin_postrisc_addc_vu32(res, b);
  // CHECK: addo_vi32 %r2, %r2, %r1
  res = __builtin_postrisc_addo_vi32(res, a);
  // CHECK: add_sat_vi32 %r2, %r2, %r1
  res = __builtin_postrisc_add_sat_vi32(res, a);
  // CHECK: add_sat_vu32 %r2, %r2, %r1
  res = __builtin_postrisc_add_sat_vu32(res, a);
  // CHECK: add_vu32 %r2, %r2, %r1
  res = __builtin_postrisc_add_vu32(res, a);
  // CHECK: avg_vu32 %r2, %r2, %r1
  res = __builtin_postrisc_avg_vu32(res, a);
  // CHECK: avg_vi32 %r2, %r2, %r1
  res = __builtin_postrisc_avg_vi32(res, a);
  // CHECK: cmp_eq_vi32 %r2, %r2, %r1
  res = __builtin_postrisc_cmp_eq_vi32(res, a);
  // CHECK: cmp_lt_vi32 %r2, %r2, %r1
  res = __builtin_postrisc_cmp_lt_vi32(res, a);
  // CHECK: cmp_lt_vu32 %r2, %r2, %r1
  res = __builtin_postrisc_cmp_lt_vu32(res, a);
  // CHECK: max_vi32 %r2, %r2, %r1
  res = __builtin_postrisc_max_vi32(res, a);
  // CHECK: max_vu32 %r2, %r2, %r1
  res = __builtin_postrisc_max_vu32(res, a);
  // CHECK: min_vi32 %r2, %r2, %r1
  res = __builtin_postrisc_min_vi32(res, a);
  // CHECK: min_vu32 %r2, %r2, %r1
  res = __builtin_postrisc_min_vu32(res, a);
  // CHECK: rol_vu32 %r2, %r2, %r1
  res = __builtin_postrisc_rol_vu32(res, a);
  // CHECK: ror_vu32 %r2, %r2, %r1
  res = __builtin_postrisc_ror_vu32(res, a);
  // CHECK: sll_vu32 %r2, %r2, %r1
  res = __builtin_postrisc_sll_vu32(res, a);
  // CHECK: sra_vi32 %r2, %r2, %r1
  res = __builtin_postrisc_sra_vi32(res, a);
  // CHECK: srl_vu32 %r2, %r2, %r1
  res = __builtin_postrisc_srl_vu32(res, a);
  // CHECK: subb_vu32 %r2, %r2, %r1
  res = __builtin_postrisc_subb_vu32(res, a);
  // CHECK: subo_vi32 %r2, %r2, %r1
  res = __builtin_postrisc_subo_vi32(res, a);
  // CHECK: sub_vu32 %r2, %r2, %r1
  res = __builtin_postrisc_sub_vu32(res, a);
  // CHECK: sub_sat_vi32 %r2, %r2, %r1
  res = __builtin_postrisc_sub_sat_vi32(res, a);
  // CHECK: sub_sat_vu32 %r1, %r2, %r1
  res = __builtin_postrisc_sub_sat_vu32(res, a);
  return res;
}

// CHECK-LABEL: @test_builtin_vector_i64
v2i64 test_builtin_vector_i64(v2i64 a, v2i64 b)
{
  v2i64 res = a;
  // CHECK: addc_vu64 %r2, %r1, %r2
  res = __builtin_postrisc_addc_vu64(res, b);
  // CHECK: addo_vi64 %r2, %r2, %r1
  res = __builtin_postrisc_addo_vi64(res, a);
  // CHECK: add_sat_vi64 %r2, %r2, %r1
  res = __builtin_postrisc_add_sat_vi64(res, a);
  // CHECK: add_sat_vu64 %r2, %r2, %r1
  res = __builtin_postrisc_add_sat_vu64(res, a);
  // CHECK: add_vu64 %r2, %r2, %r1
  res = __builtin_postrisc_add_vu64(res, a);
  // CHECK: avg_vu64 %r2, %r2, %r1
  res = __builtin_postrisc_avg_vu64(res, a);
  // CHECK: avg_vi64 %r2, %r2, %r1
  res = __builtin_postrisc_avg_vi64(res, a);
  // CHECK: cmp_eq_vi64 %r2, %r2, %r1
  res = __builtin_postrisc_cmp_eq_vi64(res, a);
  // CHECK: cmp_lt_vi64 %r2, %r2, %r1
  res = __builtin_postrisc_cmp_lt_vi64(res, a);
  // CHECK: cmp_lt_vu64 %r2, %r2, %r1
  res = __builtin_postrisc_cmp_lt_vu64(res, a);
  // CHECK: max_vi64 %r2, %r2, %r1
  res = __builtin_postrisc_max_vi64(res, a);
  // CHECK: max_vu64 %r2, %r2, %r1
  res = __builtin_postrisc_max_vu64(res, a);
  // CHECK: min_vi64 %r2, %r2, %r1
  res = __builtin_postrisc_min_vi64(res, a);
  // CHECK: min_vu64 %r2, %r2, %r1
  res = __builtin_postrisc_min_vu64(res, a);
  // CHECK: rol_vu64 %r2, %r2, %r1
  res = __builtin_postrisc_rol_vu64(res, a);
  // CHECK: ror_vu64 %r2, %r2, %r1
  res = __builtin_postrisc_ror_vu64(res, a);
  // CHECK: sll_vu64 %r2, %r2, %r1
  res = __builtin_postrisc_sll_vu64(res, a);
  // CHECK: sra_vi64 %r2, %r2, %r1
  res = __builtin_postrisc_sra_vi64(res, a);
  // CHECK: srl_vu64 %r2, %r2, %r1
  res = __builtin_postrisc_srl_vu64(res, a);
  // CHECK: subb_vu64 %r2, %r2, %r1
  res = __builtin_postrisc_subb_vu64(res, a);
  // CHECK: subo_vi64 %r2, %r2, %r1
  res = __builtin_postrisc_subo_vi64(res, a);
  // CHECK: sub_vu64 %r2, %r2, %r1
  res = __builtin_postrisc_sub_vu64(res, a);
  // CHECK: sub_sat_vi64 %r2, %r2, %r1
  res = __builtin_postrisc_sub_sat_vi64(res, a);
  // CHECK: sub_sat_vu64 %r1, %r2, %r1
  res = __builtin_postrisc_sub_sat_vu64(res, a);
  return res;
}

// CHECK-LABEL: @test_builtin_vector_mixed
v16i8 test_builtin_vector_mixed(v16i8 a1, v16i8 b1,
                                v8i16 a2, v8i16 b2,
                                v4i32 a4, v4i32 b4,
                                v2i64 a8, v2i64 b8)
{
  v16i8 r1;
  // CHECK: merge_high_vu8 %r1, %r1, %r2
  r1 = __builtin_postrisc_merge_high_vu8(a1, b1);
  // CHECK: merge_low_vu8 %r1, %r1, %r2
  r1 = __builtin_postrisc_merge_low_vu8(r1, b1);

  // CHECK: merge_high_vu16 %r1, %r1, %r4
  r1 = __builtin_postrisc_merge_high_vu16(r1, b2);
  // CHECK: merge_low_vu16 %r1, %r1, %r4
  r1 = __builtin_postrisc_merge_low_vu16(r1, b2);

  // CHECK: merge_high_vu32 %r1, %r1, %r6
  r1 = __builtin_postrisc_merge_high_vu32(r1, b4);
  // CHECK: merge_low_vu32 %r1, %r1, %r6
  r1 = __builtin_postrisc_merge_low_vu32(r1, b4);

  // CHECK: merge_high_vu64 %r1, %r1, %r8
  r1 = __builtin_postrisc_merge_high_vu64(r1, b8);
  // CHECK: merge_low_vu64 %r1, %r1, %r8
  r1 = __builtin_postrisc_merge_low_vu64(r1, b8);

  // CHECK: pack_sat_vi16 %r1, %r1, %r7
  r1 = __builtin_postrisc_pack_sat_vi16(r1, a8);
  // CHECK: pack_sat_vi32 %r1, %r1, %r5
  r1 = __builtin_postrisc_pack_sat_vi32(r1, a4);
  // CHECK: pack_sat_vi64 %r1, %r1, %r7
  r1 = __builtin_postrisc_pack_sat_vi64(r1, a8);

  // CHECK: pack_usat_vi16 %r1, %r1, %r3
  r1 = __builtin_postrisc_pack_usat_vi16(r1, a2);
  // CHECK: pack_usat_vi32 %r1, %r1, %r6
  r1 = __builtin_postrisc_pack_usat_vi32(r1, b4);
  // CHECK: pack_usat_vi64 %r1, %r1, %r8
  r1 = __builtin_postrisc_pack_usat_vi64(r1, b8);

  // CHECK: pack_mod_vu16 %r1, %r1, %r4
  r1 = __builtin_postrisc_pack_mod_vu16(r1, b2);
  // CHECK: pack_mod_vu32 %r1, %r1, %r6
  r1 = __builtin_postrisc_pack_mod_vu32(r1, b4);
  // CHECK: pack_mod_vu64 %r1, %r1, %r8
  r1 = __builtin_postrisc_pack_mod_vu64(r1, b8);

  // CHECK: pack_sat_vu16 %r1, %r1, %r4
  r1 = __builtin_postrisc_pack_sat_vu16(r1, b2);
  // CHECK: pack_sat_vu32 %r1, %r1, %r6
  r1 = __builtin_postrisc_pack_sat_vu32(r1, b4);
  // CHECK: pack_sat_vu64 %r1, %r1, %r8
  r1 = __builtin_postrisc_pack_sat_vu64(r1, b8);

  // CHECK: unpack_high_vi8 %r1, %r1
  r1 = __builtin_postrisc_unpack_high_vi8(r1);
  // CHECK: unpack_high_vi16 %r1, %r1
  r1 = __builtin_postrisc_unpack_high_vi16(r1);
  // CHECK: unpack_high_vi32 %r1, %r1
  r1 = __builtin_postrisc_unpack_high_vi32(r1);

  // CHECK: unpack_low_vi8 %r1, %r1
  r1 = __builtin_postrisc_unpack_low_vi8(r1);
  // CHECK: unpack_low_vi16 %r1, %r1
  r1 = __builtin_postrisc_unpack_low_vi16(r1);
  // CHECK: unpack_low_vi32 %r1, %r1
  r1 = __builtin_postrisc_unpack_low_vi32(r1);

  // CHECK: unpack_high_vu8 %r1, %r1
  r1 = __builtin_postrisc_unpack_high_vu8(r1);
  // CHECK: unpack_high_vu16 %r1, %r1
  r1 = __builtin_postrisc_unpack_high_vu16(r1);
  // CHECK: unpack_high_vu32 %r1, %r1
  r1 = __builtin_postrisc_unpack_high_vu32(r1);

  // CHECK: unpack_low_vu8 %r1, %r1
  r1 = __builtin_postrisc_unpack_low_vu8(r1);
  // CHECK: unpack_low_vu16 %r1, %r1
  r1 = __builtin_postrisc_unpack_low_vu16(r1);
  // CHECK: unpack_low_vu32 %r1, %r1
  r1 = __builtin_postrisc_unpack_low_vu32(r1);
  return r1;
}
