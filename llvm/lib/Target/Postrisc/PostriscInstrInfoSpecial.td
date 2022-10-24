//===--- PostriscInstrInfoSpecial.td - Target Description for Postrisc ----===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file describes the Postrisc special/privileged instructions.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Read/Write Special purpose Register Instructions
//===----------------------------------------------------------------------===//
let hasSideEffects = 1 in {
  def MFSPR : MISC_Rac<misc_opx_mfspr,
              (outs GR:$ra), (ins PRRegs:$rc),
              "mfspr\t$ra, $rc", []>;

  // FIXME: the MTSPR insn has special reg as OUT, but I can model it only as IN
  //let Constraints = "$rout = $rb" in {
    def MTSPR : MISC_Rac<misc_opx_mtspr,
              (outs), (ins GR:$ra, PRRegs:$rc),
              "mtspr\t$ra, $rc", []>;
  //}
}

// special registers getter/setter builtins
multiclass SPEC_REG<ValueType Ty> {
  def : Pat<(Ty (!cast<ClangBuiltin>("int_postrisc_get_"  # NAME))),
            (MFSPR (Ty !cast<PostriscCtrlReg>(NAME)))>;
  def : Pat<(!cast<ClangBuiltin>("int_postrisc_set_"  # NAME) Ty:$src),
            (MTSPR GR:$src, (Ty !cast<PostriscCtrlReg>(NAME)))>;
}

defm ip:    SPEC_REG<i64>;
defm eip:   SPEC_REG<i64>;
defm fpcr:  SPEC_REG<i64>;
defm eca:   SPEC_REG<i64>;
defm rsc:   SPEC_REG<i64>;
defm rsp:   SPEC_REG<i64>;
defm bsp:   SPEC_REG<i64>;
defm psr:   SPEC_REG<i64>;
defm reip:  SPEC_REG<i64>;
defm kip:   SPEC_REG<i64>;
defm ksp:   SPEC_REG<i64>;
defm krsp:  SPEC_REG<i64>;
defm peb:   SPEC_REG<i64>;
defm teb:   SPEC_REG<i64>;
defm itc:   SPEC_REG<i64>;
defm itm:   SPEC_REG<i64>;
defm pta:   SPEC_REG<i64>;
defm iva:   SPEC_REG<i64>;
defm iip:   SPEC_REG<i64>;
defm iipa:  SPEC_REG<i64>;
defm ipsr:  SPEC_REG<i64>;
defm cause: SPEC_REG<i64>;
defm ifa:   SPEC_REG<i64>;
defm iib:   SPEC_REG<i128>;
defm irr0:  SPEC_REG<i64>;
defm irr1:  SPEC_REG<i64>;
defm irr2:  SPEC_REG<i64>;
defm irr3:  SPEC_REG<i64>;
defm isr0:  SPEC_REG<i64>;
defm isr1:  SPEC_REG<i64>;
defm isr2:  SPEC_REG<i64>;
defm isr3:  SPEC_REG<i64>;
defm iv:    SPEC_REG<i64>;
defm lid:   SPEC_REG<i64>;
defm tpr:   SPEC_REG<i64>;
defm itcv:  SPEC_REG<i64>;
defm tsv:   SPEC_REG<i64>;
defm pmv:   SPEC_REG<i64>;
defm cmcv:  SPEC_REG<i64>;

def : Pat<(i64 (readcyclecounter)), (MFSPR (i64 itc))>;

//===----------------------------------------------------------------------===//
// Register windows/frame and stack/buffer
//===----------------------------------------------------------------------===//
let hasSideEffects = 1 in {
  let imm = 0 in {
    def ALLOC : RAOPX_RbI21<raopx_opx_alloc,
                  (outs), (ins uimm7:$rb), "alloc\t$rb", []>;
  }
  let Defs = [sp], Uses = [sp] in {
    def ALLOCSP : RAOPX_RbI21<raopx_opx_allocsp,
                  (outs), (ins uimm7:$rb, uimm21:$imm),
                  "allocsp\t$rb, $imm", []>;

    def ALLOCSP_ext : RAOPX_RbI21_ext<raopx_opx_allocsp,
                  (outs), (ins uimm7:$rb, uimm21_ext:$imm),
                  "allocsp.l\t$rb, $imm", []>;
  }
  def RSCOVER : MISC_NoArgs<misc_opx_rscover,
                     (outs), (ins), "rscover", []>;

  def RSLOAD : MISC_NoArgs<misc_opx_rsload,
                     (outs), (ins), "rsload", []>;
}

def flushw : SDNode<"PostriscISD::FLUSHW", SDTNone,
                    [SDNPHasChain, SDNPSideEffect, SDNPMayStore]>;

let hasSideEffects = 1, mayStore = 1 in {
  def RSFLUSH : MISC_NoArgs<misc_opx_rsflush,
                     (outs), (ins), "rsflush", [(flushw)]>;
}

//===----------------------------------------------------------------------===//
// CPUID
//===----------------------------------------------------------------------===//
def CPUID : MISC_RabI10<misc_opx_cpuid,
  (outs GR:$ra), (ins GR:$rb, stride_imm:$imm), "cpuid\t$ra, $rb, $imm", []>;

def : Pat<(i64 (int_postrisc_cpuid (add i64:$src, stride_imm:$imm))), (CPUID (i64 $src), stride_imm:$imm)>;
def : Pat<(i64 (int_postrisc_cpuid      i64:$src                  )), (CPUID (i64 $src),               0)>;
def : Pat<(i64 (int_postrisc_cpuid                stride_imm:$imm )), (CPUID (i64   gz), stride_imm:$imm)>;

//===----------------------------------------------------------------------===//
// Software trap (GR + stride_imm)
//===----------------------------------------------------------------------===//
let hasSideEffects = 1, isTerminator = 1 in {
  def INTERRUPTION : MISC_RbI10<misc_opx_int,
    (outs), (ins GR:$rb, stride_imm:$imm), "int\t$rb, $imm", []>;
}

def : Pat<(int_postrisc_int (add i64:$src, stride_imm:$imm)), (INTERRUPTION (i64 $src), stride_imm:$imm)>;
def : Pat<(int_postrisc_int      i64:$src                  ), (INTERRUPTION (i64 $src),               0)>;
def : Pat<(int_postrisc_int                stride_imm:$imm ), (INTERRUPTION (i64   gz), stride_imm:$imm)>;
def : Pat<(trap                                            ), (INTERRUPTION (i64   gz),               5)>;
def : Pat<(debugtrap                                       ), (INTERRUPTION (i64   gz),               1)>;

//===----------------------------------------------------------------------===//
// system call (GR + 12-bit target immediate)
//===----------------------------------------------------------------------===//
let hasSideEffects = 1 in {
  def SYSCALL : MISC_NoArgs<misc_opx_syscall, (outs), (ins), "syscall", [(int_postrisc_syscall)]>;
  def SYSRET  : MISC_NoArgs<misc_opx_sysret,  (outs), (ins), "sysret",  [(int_postrisc_sysret)]>;
  def RFI     : MISC_NoArgs<misc_opx_rfi,     (outs), (ins), "rfi",     [(int_postrisc_rfi)]>;
  def HALT    : MISC_NoArgs<misc_opx_halt,    (outs), (ins), "halt",    [(int_postrisc_halt)]>;
  def UNDEF   : MISC_NoArgs<misc_opx_undef,   (outs), (ins), "undef",   [(int_postrisc_undef)]>;
}

def TPA : MISC_Rab<misc_opx_tpa,
                 (outs GR:$ra), (ins GR:$rb),
                 "tpa\t$ra, $rb",
                 [(set i64:$ra, (int_postrisc_tpa i64:$rb))]>;

//===----------------------------------------------------------------------===//
// NOPS
//===----------------------------------------------------------------------===//
let hasSideEffects = 1 in {
  def NOP : RAOPX_Branch<raopx_opx_nop,
                     (outs), (ins uimm28:$imm),
                     "nop\t$imm", []>;
  def NOP_ext : RAOPX_Branch_ext<raopx_opx_nop,
                     (outs), (ins uimm28_ext:$imm),
                     "nop.l\t$imm", []>;
}

def : Pat<(int_postrisc_nop   uimm28:$imm    ), (NOP     uimm28:$imm)>;
def : Pat<(int_postrisc_nop   uimm28_ext:$imm), (NOP_ext uimm28_ext:$imm)>;
def : Pat<(int_postrisc_nop_l uimm28_ext:$imm), (NOP_ext uimm28_ext:$imm)>;

//def : InstAlias<"nopft",   (NOP 0)>;  // nop after FallThrough block
//def : InstAlias<"nopcall", (NOP 1)>;  // nop after call
//def : InstAlias<"nopterm", (NOP 2)>;  // nop after block with terminator

//===----------------------------------------------------------------------===//
// Move to/from monitor registers
//===----------------------------------------------------------------------===//
let hasSideEffects = 1 in {
def MFMR : MISC_RabI10<misc_opx_mfmr,
    (outs GR:$ra), (ins GR:$rb, stride_imm:$imm), "mfmr\t$ra, $rb, $imm", []>;

def MTMR : MISC_RabI10<misc_opx_mtmr,
    (outs), (ins GR:$ra, GR:$rb, stride_imm:$imm), "mtmr\t$ra, $rb, $imm", []>;
}

def : Pat<(i64 (int_postrisc_get_mr (add i64:$rb, stride_imm:$imm))), (MFMR (i64 $rb), stride_imm:$imm)>;
def : Pat<(i64 (int_postrisc_get_mr      i64:$rb                  )), (MFMR (i64 $rb),               0)>;
def : Pat<(i64 (int_postrisc_get_mr               stride_imm:$imm )), (MFMR (i64  gz), stride_imm:$imm)>;

def : Pat<(int_postrisc_set_mr i64:$ra, (add i64:$rb, stride_imm:$imm)), (MTMR (i64 $ra), (i64 $rb), stride_imm:$imm)>;
def : Pat<(int_postrisc_set_mr i64:$ra,      i64:$rb                  ), (MTMR (i64 $ra), (i64 $rb),               0)>;
def : Pat<(int_postrisc_set_mr i64:$ra,               stride_imm:$imm ), (MTMR (i64 $ra), (i64  gz), stride_imm:$imm)>;

//===----------------------------------------------------------------------===//
// Move to/from instruction breakpoint registers
//===----------------------------------------------------------------------===//
let hasSideEffects = 1 in {
def MFIBR : MISC_RabI10<misc_opx_mfibr,
    (outs GR:$ra), (ins GR:$rb, stride_imm:$imm), "mfibr\t$ra, $rb, $imm", []>;

def MTIBR : MISC_RabI10<misc_opx_mtibr,
    (outs), (ins GR:$ra, GR:$rb, stride_imm:$imm), "mtibr\t$ra, $rb, $imm", []>;
}

def : Pat<(i64 (int_postrisc_get_ibr (add i64:$rb, stride_imm:$imm))), (MFIBR (i64 $rb), stride_imm:$imm)>;
def : Pat<(i64 (int_postrisc_get_ibr      i64:$rb                  )), (MFIBR (i64 $rb),               0)>;
def : Pat<(i64 (int_postrisc_get_ibr               stride_imm:$imm )), (MFIBR (i64  gz), stride_imm:$imm)>;

def : Pat<(int_postrisc_set_ibr i64:$ra, (add i64:$rb, stride_imm:$imm)), (MTIBR (i64 $ra), (i64 $rb), stride_imm:$imm)>;
def : Pat<(int_postrisc_set_ibr i64:$ra,      i64:$rb                  ), (MTIBR (i64 $ra), (i64 $rb),               0)>;
def : Pat<(int_postrisc_set_ibr i64:$ra,               stride_imm:$imm ), (MTIBR (i64 $ra), (i64  gz), stride_imm:$imm)>;

//===----------------------------------------------------------------------===//
// Move to/from data breakpoint registers
//===----------------------------------------------------------------------===//
let hasSideEffects = 1 in {
def MFDBR : MISC_RabI10<misc_opx_mfdbr,
     (outs GR:$ra), (ins GR:$rb, stride_imm:$imm), "mfdbr\t$ra, $rb, $imm", []>;

def MTDBR : MISC_RabI10<misc_opx_mtdbr,
     (outs), (ins GR:$ra, GR:$rb, stride_imm:$imm), "mtdbr\t$ra, $rb, $imm", []>;
}

def : Pat<(i64 (int_postrisc_get_dbr (add i64:$rb, stride_imm:$imm))), (MFDBR $rb, stride_imm:$imm)>;
def : Pat<(i64 (int_postrisc_get_dbr      i64:$rb                  )), (MFDBR $rb,               0)>;
def : Pat<(i64 (int_postrisc_get_dbr               stride_imm:$imm )), (MFDBR (i64 gz), stride_imm:$imm)>;

def : Pat<(int_postrisc_set_dbr i64:$ra, (add i64:$rb, stride_imm:$imm)), (MTDBR $ra, (i64 $rb), stride_imm:$imm)>;
def : Pat<(int_postrisc_set_dbr i64:$ra,      i64:$rb                  ), (MTDBR $ra, (i64 $rb),               0)>;
def : Pat<(int_postrisc_set_dbr i64:$ra,               stride_imm:$imm ), (MTDBR $ra, (i64  gz), stride_imm:$imm)>;

//===----------------------------------------------------------------------===//
// TLB
//===----------------------------------------------------------------------===//
let hasSideEffects = 1 in {
def PTC : MISC_Rabc<misc_opx_ptc,
           (outs), (ins GR:$ra, GR:$rb, GR:$rc), "ptc\t$ra, $rb, $rc",
           [(int_postrisc_tlb_purge iPTR:$ra, iPTR:$rb, i32:$rc)]>;
}
