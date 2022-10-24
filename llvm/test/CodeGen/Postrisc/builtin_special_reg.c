// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

extern void consume_sr64(u64);
extern void consume_sr128(u128);

// CHECK-LABEL: @test_builtin_get_special_reg
void test_builtin_get_special_reg(void)
{
  // CHECK: mfspr %r2, %ip
  consume_sr64(__builtin_postrisc_get_ip());
  // CHECK: mfspr %r2, %eip
  consume_sr64(__builtin_postrisc_get_eip());
  // CHECK: mfspr %r2, %fpcr
  consume_sr64(__builtin_postrisc_get_fpcr());
  // CHECK: mfspr %r2, %eca
  consume_sr64(__builtin_postrisc_get_eca());
  // CHECK: mfspr %r2, %rsc
  consume_sr64(__builtin_postrisc_get_rsc());
  // CHECK: mfspr %r2, %rsp
  consume_sr64(__builtin_postrisc_get_rsp());
  // CHECK: mfspr %r2, %bsp
  consume_sr64(__builtin_postrisc_get_bsp());
  // CHECK: mfspr %r2, %reip
  consume_sr64(__builtin_postrisc_get_reip());
  // CHECK: mfspr %r2, %kip
  consume_sr64(__builtin_postrisc_get_kip());
  // CHECK: mfspr %r2, %ksp
  consume_sr64(__builtin_postrisc_get_ksp());
  // CHECK: mfspr %r2, %krsp
  consume_sr64(__builtin_postrisc_get_krsp());
  // CHECK: mfspr %r2, %peb
  consume_sr64(__builtin_postrisc_get_peb());
  // CHECK: mfspr %r2, %teb
  consume_sr64(__builtin_postrisc_get_teb());
  // CHECK: mfspr %r2, %itc
  consume_sr64(__builtin_postrisc_get_itc());
  // CHECK: mfspr %r2, %itm
  consume_sr64(__builtin_postrisc_get_itm());
  // CHECK: mfspr %r2, %pta
  consume_sr64(__builtin_postrisc_get_pta());
  // CHECK: mfspr %r2, %iva
  consume_sr64(__builtin_postrisc_get_iva());
  // CHECK: mfspr %r2, %iip
  consume_sr64(__builtin_postrisc_get_iip());
  // CHECK: mfspr %r2, %iipa
  consume_sr64(__builtin_postrisc_get_iipa());
  // CHECK: mfspr %r2, %cause
  consume_sr64(__builtin_postrisc_get_cause());
  // CHECK: mfspr %r2, %ifa
  consume_sr64(__builtin_postrisc_get_ifa());
  // CHECK: mfspr %r2, %irr0
  consume_sr64(__builtin_postrisc_get_irr0());
  // CHECK: mfspr %r2, %irr1
  consume_sr64(__builtin_postrisc_get_irr1());
  // CHECK: mfspr %r2, %irr2
  consume_sr64(__builtin_postrisc_get_irr2());
  // CHECK: mfspr %r2, %irr3
  consume_sr64(__builtin_postrisc_get_irr3());
  // CHECK: mfspr %r2, %isr0
  consume_sr64(__builtin_postrisc_get_isr0());
  // CHECK: mfspr %r2, %isr1
  consume_sr64(__builtin_postrisc_get_isr1());
  // CHECK: mfspr %r2, %isr2
  consume_sr64(__builtin_postrisc_get_isr2());
  // CHECK: mfspr %r2, %isr3
  consume_sr64(__builtin_postrisc_get_isr3());
  // CHECK: mfspr %r2, %iv
  consume_sr64(__builtin_postrisc_get_iv());
  // CHECK: mfspr %r2, %lid
  consume_sr64(__builtin_postrisc_get_lid());
  // CHECK: mfspr %r2, %tpr
  consume_sr64(__builtin_postrisc_get_tpr());
  // CHECK: mfspr %r2, %itcv
  consume_sr64(__builtin_postrisc_get_itcv());
  // CHECK: mfspr %r2, %tsv
  consume_sr64(__builtin_postrisc_get_tsv());
  // CHECK: mfspr %r2, %pmv
  consume_sr64(__builtin_postrisc_get_pmv());
  // CHECK: mfspr %r2, %cmcv
  consume_sr64(__builtin_postrisc_get_cmcv());
  // CHECK: mfspr %r2, %iib
  consume_sr128(__builtin_postrisc_get_iib());
  // CHECK: mfspr %r2, %psr
  consume_sr64(__builtin_postrisc_get_psr());
  // CHECK: mfspr %r2, %ipsr
  consume_sr64(__builtin_postrisc_get_ipsr());
}

// CHECK-LABEL: @test_builtin_set_special_reg
void test_builtin_set_special_reg(u64 value, u128 value128)
{
  // CHECK: mtspr %r1, %ip
  __builtin_postrisc_set_ip(value);
  // CHECK: mtspr %r1, %eip
  __builtin_postrisc_set_eip(value);
  // CHECK: mtspr %r1, %fpcr
  __builtin_postrisc_set_fpcr(value);
  // CHECK: mtspr %r1, %eca
  __builtin_postrisc_set_eca(value);
  // CHECK: mtspr %r1, %rsc
  __builtin_postrisc_set_rsc(value);
  // CHECK: mtspr %r1, %rsp
  __builtin_postrisc_set_rsp(value);
  // CHECK: mtspr %r1, %bsp
  __builtin_postrisc_set_bsp(value);
  // CHECK: mtspr %r1, %reip
  __builtin_postrisc_set_reip(value);
  // CHECK: mtspr %r1, %kip
  __builtin_postrisc_set_kip(value);
  // CHECK: mtspr %r1, %ksp
  __builtin_postrisc_set_ksp(value);
  // CHECK: mtspr %r1, %krsp
  __builtin_postrisc_set_krsp(value);
  // CHECK: mtspr %r1, %peb
  __builtin_postrisc_set_peb(value);
  // CHECK: mtspr %r1, %teb
  __builtin_postrisc_set_teb(value);
  // CHECK: mtspr %r1, %itc
  __builtin_postrisc_set_itc(value);
  // CHECK: mtspr %r1, %itm
  __builtin_postrisc_set_itm(value);
  // CHECK: mtspr %r1, %pta
  __builtin_postrisc_set_pta(value);
  // CHECK: mtspr %r1, %iva
  __builtin_postrisc_set_iva(value);
  // CHECK: mtspr %r1, %iip
  __builtin_postrisc_set_iip(value);
  // CHECK: mtspr %r1, %iipa
  __builtin_postrisc_set_iipa(value);
  // CHECK: mtspr %r1, %cause
  __builtin_postrisc_set_cause(value);
  // CHECK: mtspr %r1, %ifa
  __builtin_postrisc_set_ifa(value);
  // CHECK: mtspr %r1, %irr0
  __builtin_postrisc_set_irr0(value);
  // CHECK: mtspr %r1, %irr1
  __builtin_postrisc_set_irr1(value);
  // CHECK: mtspr %r1, %irr2
  __builtin_postrisc_set_irr2(value);
  // CHECK: mtspr %r1, %irr3
  __builtin_postrisc_set_irr3(value);
  // CHECK: mtspr %r1, %isr0
  __builtin_postrisc_set_isr0(value);
  // CHECK: mtspr %r1, %isr1
  __builtin_postrisc_set_isr1(value);
  // CHECK: mtspr %r1, %isr2
  __builtin_postrisc_set_isr2(value);
  // CHECK: mtspr %r1, %isr3
  __builtin_postrisc_set_isr3(value);
  // CHECK: mtspr %r1, %iv
  __builtin_postrisc_set_iv(value);
  // CHECK: mtspr %r1, %lid
  __builtin_postrisc_set_lid(value);
  // CHECK: mtspr %r1, %tpr
  __builtin_postrisc_set_tpr(value);
  // CHECK: mtspr %r1, %itcv
  __builtin_postrisc_set_itcv(value);
  // CHECK: mtspr %r1, %tsv
  __builtin_postrisc_set_tsv(value);
  // CHECK: mtspr %r1, %pmv
  __builtin_postrisc_set_pmv(value);
  // CHECK: mtspr %r1, %cmcv
  __builtin_postrisc_set_cmcv(value);
  // CHECK: mtspr %r1, %psr
  __builtin_postrisc_set_psr(value);
  // CHECK: mtspr %r2, %iib
  __builtin_postrisc_set_iib(value128);
  // CHECK: mtspr %r1, %ipsr
  __builtin_postrisc_set_ipsr(value);
}
