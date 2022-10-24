//===-- PostriscRegisterInfo.td - Postrisc Register defs ---*- tablegen -*-===//
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
def g0 : Ri<gpr_reg_g0.value, gpr_reg_g0.mnem>, DwarfRegNum<[120]>;
def g1 : Ri<gpr_reg_g1.value, gpr_reg_g1.mnem>, DwarfRegNum<[121]>;
def g2 : Ri<gpr_reg_g2.value, gpr_reg_g2.mnem>, DwarfRegNum<[122]>;
def g3 : Ri<gpr_reg_g3.value, gpr_reg_g3.mnem>, DwarfRegNum<[123]>;
def tp : Ri<gpr_reg_tp.value, gpr_reg_tp.mnem>, DwarfRegNum<[124]>;
def fp : Ri<gpr_reg_fp.value, gpr_reg_fp.mnem>, DwarfRegNum<[125]>;
def sp : Ri<gpr_reg_sp.value, gpr_reg_sp.mnem>, DwarfRegNum<[126]>;
def gz : Ri<gpr_reg_gz.value, gpr_reg_gz.mnem>, DwarfRegNum<[127]>;

// Register classes.
// the register order should be defined in terms of the preferred allocation order.
//
def GR : RegisterClass<"POSTRISC",
         [i1, i32, i64, i128, f16, f32, f64, f128, v2f64, v4f32, v8f16, v2i64, v4i32, v8i16, v16i8],
         128,
         (add (sequence "r%u", 0, 119), g0, g1, g2, g3, tp, fp, sp, gz)>;

// Control registers

class PostriscCtrlReg<spr_reg reg>: Register<NAME> {
  let HWEncoding{6-0} = reg.value;
  let Namespace = "POSTRISC";
}

def ip:    PostriscCtrlReg<spr_reg_ip>, DwarfRegNum<[200]>;
def eip:   PostriscCtrlReg<spr_reg_eip>, DwarfRegNum<[201]>;
def fpcr:  PostriscCtrlReg<spr_reg_fpcr>, DwarfRegNum<[202]>;
def eca:   PostriscCtrlReg<spr_reg_eca>, DwarfRegNum<[203]>;
def rsc:   PostriscCtrlReg<spr_reg_rsc>, DwarfRegNum<[204]>;
def rsp:   PostriscCtrlReg<spr_reg_rsp>, DwarfRegNum<[205]>;
def bsp:   PostriscCtrlReg<spr_reg_bsp>, DwarfRegNum<[206]>;
def psr:   PostriscCtrlReg<spr_reg_psr>, DwarfRegNum<[207]>;
def reip:  PostriscCtrlReg<spr_reg_reip>, DwarfRegNum<[208]>;
def kip:   PostriscCtrlReg<spr_reg_kip>, DwarfRegNum<[209]>;
def ksp:   PostriscCtrlReg<spr_reg_ksp>, DwarfRegNum<[200]>;
def krsp:  PostriscCtrlReg<spr_reg_krsp>, DwarfRegNum<[210]>;
def peb:   PostriscCtrlReg<spr_reg_peb>, DwarfRegNum<[211]>;
def teb:   PostriscCtrlReg<spr_reg_teb>, DwarfRegNum<[212]>;
def itc:   PostriscCtrlReg<spr_reg_itc>, DwarfRegNum<[213]>;
def itm:   PostriscCtrlReg<spr_reg_itm>, DwarfRegNum<[214]>;
def pta:   PostriscCtrlReg<spr_reg_pta>, DwarfRegNum<[215]>;
def iva:   PostriscCtrlReg<spr_reg_iva>, DwarfRegNum<[216]>;
def iip:   PostriscCtrlReg<spr_reg_iip>, DwarfRegNum<[217]>;
def iipa:  PostriscCtrlReg<spr_reg_iipa>, DwarfRegNum<[218]>;
def ipsr:  PostriscCtrlReg<spr_reg_ipsr>, DwarfRegNum<[219]>;
def cause: PostriscCtrlReg<spr_reg_cause>, DwarfRegNum<[220]>;
def ifa:   PostriscCtrlReg<spr_reg_ifa>, DwarfRegNum<[221]>;
def iib:   PostriscCtrlReg<spr_reg_iib>, DwarfRegNum<[222]>;
def irr0:  PostriscCtrlReg<spr_reg_irr0>, DwarfRegNum<[223]>;
def irr1:  PostriscCtrlReg<spr_reg_irr1>, DwarfRegNum<[224]>;
def irr2:  PostriscCtrlReg<spr_reg_irr2>, DwarfRegNum<[225]>;
def irr3:  PostriscCtrlReg<spr_reg_irr3>, DwarfRegNum<[226]>;
def isr0:  PostriscCtrlReg<spr_reg_isr0>, DwarfRegNum<[227]>;
def isr1:  PostriscCtrlReg<spr_reg_isr1>, DwarfRegNum<[228]>;
def isr2:  PostriscCtrlReg<spr_reg_isr2>, DwarfRegNum<[229]>;
def isr3:  PostriscCtrlReg<spr_reg_isr3>, DwarfRegNum<[230]>;
def iv:    PostriscCtrlReg<spr_reg_iv>, DwarfRegNum<[231]>;
def lid:   PostriscCtrlReg<spr_reg_lid>, DwarfRegNum<[232]>;
def tpr:   PostriscCtrlReg<spr_reg_tpr>, DwarfRegNum<[233]>;
def itcv:  PostriscCtrlReg<spr_reg_itcv>, DwarfRegNum<[234]>;
def tsv:   PostriscCtrlReg<spr_reg_tsv>, DwarfRegNum<[235]>;
def pmv:   PostriscCtrlReg<spr_reg_pmv>, DwarfRegNum<[236]>;
def cmcv:  PostriscCtrlReg<spr_reg_cmcv>, DwarfRegNum<[237]>;

let isAllocatable = 0 in {
  // Special regs are not allocatable.
  def SR : RegisterClass<"POSTRISC", [i64, i128], 128,
    (add ip, eip, fpcr, eca, rsc, rsp, bsp, psr, reip, kip, ksp, krsp,
         peb, teb, itc, itm, pta, iva, iip, iipa, ipsr, cause, ifa,
         iib, irr0, irr1, irr2, irr3, isr0, isr1, isr2, isr3,
         iv, lid, tpr, itcv, tsv, pmv, cmcv)>;
}
