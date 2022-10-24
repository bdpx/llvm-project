//===-- PostriscRegisterInfo.td - Postrisc Register defs ---------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
//  Declarations that describe the Postrisc register file
//===----------------------------------------------------------------------===//
// Registers are identified with 7-bit ID numbers.

class PostriscReg<bits<7> Enc, string n> : Register<n> {
  let HWEncoding{6-0} = Enc;
  let Namespace = "POSTRISC";
}

class Ri<bits<7> Enc, string n> : PostriscReg<Enc, n>;

// local/rotating registers
foreach I = 0-119 in {
  def r#I : Ri<!add(0,I), "r"#I>, DwarfRegNum<[!add(0,I)]>;
}

// global registers
def g0 : Ri<gpr_reg_g0.value, "g0">, DwarfRegNum<[120]>;
def g1 : Ri<gpr_reg_g1.value, "g1">, DwarfRegNum<[121]>;
def g2 : Ri<gpr_reg_g2.value, "g2">, DwarfRegNum<[122]>;
def g3 : Ri<gpr_reg_g3.value, "g3">, DwarfRegNum<[123]>;
def tp : Ri<gpr_reg_tp.value, "tp">, DwarfRegNum<[124]>;
def fp : Ri<gpr_reg_fp.value, "fp">, DwarfRegNum<[125]>;
def sp : Ri<gpr_reg_sp.value, "sp">, DwarfRegNum<[126]>;
def gz : Ri<gpr_reg_gz.value, "gz">, DwarfRegNum<[127]>;

// Register classes.
//
// FIXME: the register order should be defined in terms of the preferred
// allocation order...
//
def GR : RegisterClass<"POSTRISC",
         [i1, i32, i64, i128, f16, f32, f64, f128, v2f64, v4f32, v8f16, v2i64, v4i32, v8i16, v16i8],
         128,
         (add (sequence "r%u", 0, 119), g0, g1, g2, g3, tp, fp, sp, gz)>;

// Control registers

class PostriscCtrlReg<bits<7> Enc>: Register<NAME> {
  let HWEncoding{6-0} = Enc;
  let Namespace = "POSTRISC";
}

def ip:    PostriscCtrlReg<spr_reg_ip.value>;
def eip:   PostriscCtrlReg<spr_reg_eip.value>;
def fpcr:  PostriscCtrlReg<spr_reg_fpcr.value>;
def eca:   PostriscCtrlReg<spr_reg_eca.value>;
def rsc:   PostriscCtrlReg<spr_reg_rsc.value>;
def rsp:   PostriscCtrlReg<spr_reg_rsp.value>;
def bsp:   PostriscCtrlReg<spr_reg_bsp.value>;
def psr:   PostriscCtrlReg<spr_reg_psr.value>;
def reip:  PostriscCtrlReg<spr_reg_reip.value>;
def kip:   PostriscCtrlReg<spr_reg_kip.value>;
def ksp:   PostriscCtrlReg<spr_reg_ksp.value>;
def krsp:  PostriscCtrlReg<spr_reg_krsp.value>;
def peb:   PostriscCtrlReg<spr_reg_peb.value>;
def teb:   PostriscCtrlReg<spr_reg_teb.value>;
def itc:   PostriscCtrlReg<spr_reg_itc.value>;
def itm:   PostriscCtrlReg<spr_reg_itm.value>;
def pta:   PostriscCtrlReg<spr_reg_pta.value>;
def iva:   PostriscCtrlReg<spr_reg_iva.value>;
def iip:   PostriscCtrlReg<spr_reg_iip.value>;
def iipa:  PostriscCtrlReg<spr_reg_iipa.value>;
def ipsr:  PostriscCtrlReg<spr_reg_ipsr.value>;
def cause: PostriscCtrlReg<spr_reg_cause.value>;
def ifa:   PostriscCtrlReg<spr_reg_ifa.value>;
def iib:   PostriscCtrlReg<spr_reg_iib.value>;
def irr0:  PostriscCtrlReg<spr_reg_irr0.value>;
def irr1:  PostriscCtrlReg<spr_reg_irr1.value>;
def irr2:  PostriscCtrlReg<spr_reg_irr2.value>;
def irr3:  PostriscCtrlReg<spr_reg_irr3.value>;
def isr0:  PostriscCtrlReg<spr_reg_isr0.value>;
def isr1:  PostriscCtrlReg<spr_reg_isr1.value>;
def isr2:  PostriscCtrlReg<spr_reg_isr2.value>;
def isr3:  PostriscCtrlReg<spr_reg_isr3.value>;
def iv:    PostriscCtrlReg<spr_reg_iv.value>;
def lid:   PostriscCtrlReg<spr_reg_lid.value>;
def tpr:   PostriscCtrlReg<spr_reg_tpr.value>;
def itcv:  PostriscCtrlReg<spr_reg_itcv.value>;
def tsv:   PostriscCtrlReg<spr_reg_tsv.value>;
def pmv:   PostriscCtrlReg<spr_reg_pmv.value>;
def cmcv:  PostriscCtrlReg<spr_reg_cmcv.value>, DwarfRegNum<[129]>;

let isAllocatable = 0 in {
  // CtrlReg is not allocatable.
  def PRRegs : RegisterClass<"POSTRISC", [i64, i128], 128,
    (add ip, eip, fpcr, eca, rsc, rsp, bsp, psr, reip, kip, ksp, krsp,
         peb, teb, itc, itm, pta, iva, iip, iipa, ipsr, cause, ifa,
         iib, irr0, irr1, irr2, irr3, isr0, isr1, isr2, isr3,
         iv, lid, tpr, itcv, tsv, pmv, cmcv)>;
}
