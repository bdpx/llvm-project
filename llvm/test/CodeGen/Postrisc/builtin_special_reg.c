// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

extern void consume_sr64(u64);
extern void consume_sr128(u128);

// CHECK-LABEL: @test_builtin_get_special_reg
void test_builtin_get_special_reg(void)
{
  // CHECK: get_spr %r2, %ip
  consume_sr64(__builtin_postrisc_get_ip());
  // CHECK: get_spr %r2, %eip
  consume_sr64(__builtin_postrisc_get_eip());
  // CHECK: get_spr %r2, %fpcr
  consume_sr64(__builtin_postrisc_get_fpcr());
  // CHECK: get_spr %r2, %eca
  consume_sr64(__builtin_postrisc_get_eca());
  // CHECK: get_spr %r2, %rsc
  consume_sr64(__builtin_postrisc_get_rsc());
  // CHECK: get_spr %r2, %rsp
  consume_sr64(__builtin_postrisc_get_rsp());
  // CHECK: get_spr %r2, %bsp
  consume_sr64(__builtin_postrisc_get_bsp());
  // CHECK: get_spr %r2, %reip
  consume_sr64(__builtin_postrisc_get_reip());
  // CHECK: get_spr %r2, %kip
  consume_sr64(__builtin_postrisc_get_kip());
  // CHECK: get_spr %r2, %ksp
  consume_sr64(__builtin_postrisc_get_ksp());
  // CHECK: get_spr %r2, %krsp
  consume_sr64(__builtin_postrisc_get_krsp());
  // CHECK: get_spr %r2, %peb
  consume_sr64(__builtin_postrisc_get_peb());
  // CHECK: get_spr %r2, %teb
  consume_sr64(__builtin_postrisc_get_teb());
  // CHECK: get_spr %r2, %itc
  consume_sr64(__builtin_postrisc_get_itc());
  // CHECK: get_spr %r2, %itm
  consume_sr64(__builtin_postrisc_get_itm());
  // CHECK: get_spr %r2, %pta
  consume_sr64(__builtin_postrisc_get_pta());
  // CHECK: get_spr %r2, %iva
  consume_sr64(__builtin_postrisc_get_iva());
  // CHECK: get_spr %r2, %iip
  consume_sr64(__builtin_postrisc_get_iip());
  // CHECK: get_spr %r2, %iipa
  consume_sr64(__builtin_postrisc_get_iipa());
  // CHECK: get_spr %r2, %cause
  consume_sr64(__builtin_postrisc_get_cause());
  // CHECK: get_spr %r2, %ifa
  consume_sr64(__builtin_postrisc_get_ifa());
  // CHECK: get_spr %r2, %irr0
  consume_sr64(__builtin_postrisc_get_irr0());
  // CHECK: get_spr %r2, %irr1
  consume_sr64(__builtin_postrisc_get_irr1());
  // CHECK: get_spr %r2, %irr2
  consume_sr64(__builtin_postrisc_get_irr2());
  // CHECK: get_spr %r2, %irr3
  consume_sr64(__builtin_postrisc_get_irr3());
  // CHECK: get_spr %r2, %isr0
  consume_sr64(__builtin_postrisc_get_isr0());
  // CHECK: get_spr %r2, %isr1
  consume_sr64(__builtin_postrisc_get_isr1());
  // CHECK: get_spr %r2, %isr2
  consume_sr64(__builtin_postrisc_get_isr2());
  // CHECK: get_spr %r2, %isr3
  consume_sr64(__builtin_postrisc_get_isr3());
  // CHECK: get_spr %r2, %iv
  consume_sr64(__builtin_postrisc_get_iv());
  // CHECK: get_spr %r2, %lid
  consume_sr64(__builtin_postrisc_get_lid());
  // CHECK: get_spr %r2, %tpr
  consume_sr64(__builtin_postrisc_get_tpr());
  // CHECK: get_spr %r2, %itcv
  consume_sr64(__builtin_postrisc_get_itcv());
  // CHECK: get_spr %r2, %tsv
  consume_sr64(__builtin_postrisc_get_tsv());
  // CHECK: get_spr %r2, %pmv
  consume_sr64(__builtin_postrisc_get_pmv());
  // CHECK: get_spr %r2, %cmcv
  consume_sr64(__builtin_postrisc_get_cmcv());
  // CHECK: get_spr %r2, %iib
  consume_sr128(__builtin_postrisc_get_iib());
  // CHECK: get_spr %r2, %psr
  consume_sr64(__builtin_postrisc_get_psr());
  // CHECK: get_spr %r2, %ipsr
  consume_sr64(__builtin_postrisc_get_ipsr());
}

// CHECK-LABEL: @test_builtin_set_special_reg
void test_builtin_set_special_reg(u64 value, u128 value128)
{
  // CHECK: set_spr %r1, %ip
  __builtin_postrisc_set_ip(value);
  // CHECK: set_spr %r1, %eip
  __builtin_postrisc_set_eip(value);
  // CHECK: set_spr %r1, %fpcr
  __builtin_postrisc_set_fpcr(value);
  // CHECK: set_spr %r1, %eca
  __builtin_postrisc_set_eca(value);
  // CHECK: set_spr %r1, %rsc
  __builtin_postrisc_set_rsc(value);
  // CHECK: set_spr %r1, %rsp
  __builtin_postrisc_set_rsp(value);
  // CHECK: set_spr %r1, %bsp
  __builtin_postrisc_set_bsp(value);
  // CHECK: set_spr %r1, %reip
  __builtin_postrisc_set_reip(value);
  // CHECK: set_spr %r1, %kip
  __builtin_postrisc_set_kip(value);
  // CHECK: set_spr %r1, %ksp
  __builtin_postrisc_set_ksp(value);
  // CHECK: set_spr %r1, %krsp
  __builtin_postrisc_set_krsp(value);
  // CHECK: set_spr %r1, %peb
  __builtin_postrisc_set_peb(value);
  // CHECK: set_spr %r1, %teb
  __builtin_postrisc_set_teb(value);
  // CHECK: set_spr %r1, %itc
  __builtin_postrisc_set_itc(value);
  // CHECK: set_spr %r1, %itm
  __builtin_postrisc_set_itm(value);
  // CHECK: set_spr %r1, %pta
  __builtin_postrisc_set_pta(value);
  // CHECK: set_spr %r1, %iva
  __builtin_postrisc_set_iva(value);
  // CHECK: set_spr %r1, %iip
  __builtin_postrisc_set_iip(value);
  // CHECK: set_spr %r1, %iipa
  __builtin_postrisc_set_iipa(value);
  // CHECK: set_spr %r1, %cause
  __builtin_postrisc_set_cause(value);
  // CHECK: set_spr %r1, %ifa
  __builtin_postrisc_set_ifa(value);
  // CHECK: set_spr %r1, %irr0
  __builtin_postrisc_set_irr0(value);
  // CHECK: set_spr %r1, %irr1
  __builtin_postrisc_set_irr1(value);
  // CHECK: set_spr %r1, %irr2
  __builtin_postrisc_set_irr2(value);
  // CHECK: set_spr %r1, %irr3
  __builtin_postrisc_set_irr3(value);
  // CHECK: set_spr %r1, %isr0
  __builtin_postrisc_set_isr0(value);
  // CHECK: set_spr %r1, %isr1
  __builtin_postrisc_set_isr1(value);
  // CHECK: set_spr %r1, %isr2
  __builtin_postrisc_set_isr2(value);
  // CHECK: set_spr %r1, %isr3
  __builtin_postrisc_set_isr3(value);
  // CHECK: set_spr %r1, %iv
  __builtin_postrisc_set_iv(value);
  // CHECK: set_spr %r1, %lid
  __builtin_postrisc_set_lid(value);
  // CHECK: set_spr %r1, %tpr
  __builtin_postrisc_set_tpr(value);
  // CHECK: set_spr %r1, %itcv
  __builtin_postrisc_set_itcv(value);
  // CHECK: set_spr %r1, %tsv
  __builtin_postrisc_set_tsv(value);
  // CHECK: set_spr %r1, %pmv
  __builtin_postrisc_set_pmv(value);
  // CHECK: set_spr %r1, %cmcv
  __builtin_postrisc_set_cmcv(value);
  // CHECK: set_spr %r1, %psr
  __builtin_postrisc_set_psr(value);
  // CHECK: set_spr %r2, %iib
  __builtin_postrisc_set_iib(value128);
  // CHECK: set_spr %r1, %ipsr
  __builtin_postrisc_set_ipsr(value);
}
