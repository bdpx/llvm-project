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
  def MFSPR : MISC_Rac<misc_opx_mfspr, (outs GR:$ra), (ins SR:$rc), !strconcat(misc_opx_mfspr.mnem, "\t$ra, $rc"), []>;
  def MTSPR : MISC_Rac<misc_opx_mtspr, (outs SR:$rc), (ins GR:$ra), !strconcat(misc_opx_mtspr.mnem, "\t$ra, $rc"), []>;
}

// special registers getters builtins (setters are custom)
multiclass SPEC_REG<ValueType Ty> {
  def : Pat<(Ty (!cast<ClangBuiltin>("int_postrisc_get_" # NAME))), (MFSPR (Ty !cast<PostriscCtrlReg>(NAME)))>;
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
    def ALLOC : RAOPX_RbI21<raopx_opx_alloc, (outs), (ins uimm7:$rb), !strconcat(raopx_opx_alloc.mnem, "\t$rb"), []>;
  }
  let Defs = [sp], Uses = [sp] in {
    def ALLOCSP     : RAOPX_RbI21    <raopx_opx_alloc_sp, (outs), (ins uimm7:$rb, uimm21    :$imm), !strconcat(raopx_opx_alloc_sp.mnem,   "\t$rb, $imm"), []>;
    def ALLOCSP_EXT : RAOPX_RbI21_ext<raopx_opx_alloc_sp, (outs), (ins uimm7:$rb, uimm21_ext:$imm), !strconcat(raopx_opx_alloc_sp.mnem, ".l\t$rb, $imm"), []>;
  }
  def RSCOVER : MISC_NoArgs<misc_opx_rscover, (outs), (ins), []>;
  def RSLOAD  : MISC_NoArgs<misc_opx_rsload,  (outs), (ins), []>;
}

def flushw : SDNode<"PostriscISD::FLUSHW", SDTNone,
                    [SDNPHasChain, SDNPSideEffect, SDNPMayStore]>;

let hasSideEffects = 1, mayStore = 1 in {
  def RSFLUSH : MISC_NoArgs<misc_opx_rsflush, (outs), (ins), [(flushw)]>;
}

//===----------------------------------------------------------------------===//
// CPUID
//===----------------------------------------------------------------------===//
def CPUID : MISC_RabI10<misc_opx_cpuid,
  (outs GR:$ra), (ins GR:$rb, stride_imm:$imm), !strconcat(misc_opx_cpuid.mnem, "\t$ra, $rb, $imm"), []>;

def : Pat<(i64 (int_postrisc_cpuid (add i64:$src, stride_imm:$imm))), (CPUID (i64 $src), stride_imm:$imm)>;
def : Pat<(i64 (int_postrisc_cpuid      i64:$src                  )), (CPUID (i64 $src),               0)>;
def : Pat<(i64 (int_postrisc_cpuid                stride_imm:$imm )), (CPUID (i64   gz), stride_imm:$imm)>;

//===----------------------------------------------------------------------===//
// Software trap (GR + stride_imm)
//===----------------------------------------------------------------------===//
let hasSideEffects = 1, isTerminator = 1 in {
  def INT : MISC_RbI10<misc_opx_int,
    (outs), (ins GR:$rb, stride_imm:$imm), !strconcat(misc_opx_int.mnem, "\t$rb, $imm"), []>;
}

def : Pat<(int_postrisc_int (add i64:$src, stride_imm:$imm)), (INT (i64 $src), stride_imm:$imm)>;
def : Pat<(int_postrisc_int      i64:$src                  ), (INT (i64 $src),               0)>;
def : Pat<(int_postrisc_int                stride_imm:$imm ), (INT (i64   gz), stride_imm:$imm)>;
def : Pat<(trap                                            ), (INT (i64   gz),               5)>;
def : Pat<(debugtrap                                       ), (INT (i64   gz),               1)>;

//===----------------------------------------------------------------------===//
// system call (GR + 12-bit target immediate)
//===----------------------------------------------------------------------===//
let hasSideEffects = 1 in {
  def SYSCALL : MISC_NoArgs<misc_opx_syscall, (outs), (ins), [(int_postrisc_syscall)]>;
  def SYSRET  : MISC_NoArgs<misc_opx_sysret,  (outs), (ins), [(int_postrisc_sysret)]>;
  def RFI     : MISC_NoArgs<misc_opx_rfi,     (outs), (ins), [(int_postrisc_rfi)]>;
  def HALT    : MISC_NoArgs<misc_opx_halt,    (outs), (ins), [(int_postrisc_halt)]>;
  def UNDEF   : MISC_NoArgs<misc_opx_undef,   (outs), (ins), [(int_postrisc_undef)]>;
}

def TPA : MISC_Rab<misc_opx_tpa,
                 (outs GR:$ra), (ins GR:$rb),
                 !strconcat(misc_opx_tpa.mnem, "\t$ra, $rb"),
                 [(set i64:$ra, (int_postrisc_tpa i64:$rb))]>;

//===----------------------------------------------------------------------===//
// NOPS
//===----------------------------------------------------------------------===//
let hasSideEffects = 1 in {
  def NOP     : RAOPX_Branch    <raopx_opx_nop, (outs), (ins uimm28    :$imm), !strconcat(raopx_opx_nop.mnem,   "\t$imm"), []>;
  def NOP_EXT : RAOPX_Branch_ext<raopx_opx_nop, (outs), (ins uimm28_ext:$imm), !strconcat(raopx_opx_nop.mnem, ".l\t$imm"), []>;
}

def : Pat<(int_postrisc_nop   uimm28:$imm    ), (NOP     uimm28:$imm)>;
def : Pat<(int_postrisc_nop   uimm28_ext:$imm), (NOP_EXT uimm28_ext:$imm)>;
def : Pat<(int_postrisc_nop_l uimm28_ext:$imm), (NOP_EXT uimm28_ext:$imm)>;

//def : InstAlias<"nopft",   (NOP 0)>;  // nop after FallThrough block
//def : InstAlias<"nopcall", (NOP 1)>;  // nop after call
//def : InstAlias<"nopterm", (NOP 2)>;  // nop after block with terminator

//===----------------------------------------------------------------------===//
// Move to/from monitor, [instruction|data] breakpoint registers
//===----------------------------------------------------------------------===//
multiclass MoveFromRegType<ClangBuiltin Op, InstBase INSN>
{
  def : Pat<(i64 (Op (add i64:$rb, stride_imm:$imm))), (INSN (i64 $rb), stride_imm:$imm)>;
  def : Pat<(i64 (Op      i64:$rb                  )), (INSN (i64 $rb),               0)>;
  def : Pat<(i64 (Op               stride_imm:$imm )), (INSN (i64  gz), stride_imm:$imm)>;
}

multiclass MoveToRegType<ClangBuiltin Op, InstBase INSN>
{
  def : Pat<(Op i64:$ra, (add i64:$rb, stride_imm:$imm)), (INSN (i64 $ra), (i64 $rb), stride_imm:$imm)>;
  def : Pat<(Op i64:$ra,      i64:$rb                  ), (INSN (i64 $ra), (i64 $rb),               0)>;
  def : Pat<(Op i64:$ra,               stride_imm:$imm ), (INSN (i64 $ra), (i64  gz), stride_imm:$imm)>;
}

let hasSideEffects = 1 in {
  def MFMR  : MISC_RabI10<misc_opx_mfmr,  (outs GR:$ra), (ins GR:$rb, stride_imm:$imm),  !strconcat(misc_opx_mfmr.mnem,  "\t$ra, $rb, $imm"), []>;
  def MFIBR : MISC_RabI10<misc_opx_mfibr, (outs GR:$ra), (ins GR:$rb, stride_imm:$imm),  !strconcat(misc_opx_mfibr.mnem, "\t$ra, $rb, $imm"), []>;
  def MFDBR : MISC_RabI10<misc_opx_mfdbr, (outs GR:$ra), (ins GR:$rb, stride_imm:$imm),  !strconcat(misc_opx_mfdbr.mnem, "\t$ra, $rb, $imm"), []>;
  def MTMR  : MISC_RabI10<misc_opx_mtmr,  (outs), (ins GR:$ra, GR:$rb, stride_imm:$imm), !strconcat(misc_opx_mtmr.mnem,  "\t$ra, $rb, $imm"), []>;
  def MTIBR : MISC_RabI10<misc_opx_mtibr, (outs), (ins GR:$ra, GR:$rb, stride_imm:$imm), !strconcat(misc_opx_mtibr.mnem, "\t$ra, $rb, $imm"), []>;
  def MTDBR : MISC_RabI10<misc_opx_mtdbr, (outs), (ins GR:$ra, GR:$rb, stride_imm:$imm), !strconcat(misc_opx_mtdbr.mnem, "\t$ra, $rb, $imm"), []>;
}

defm : MoveFromRegType<int_postrisc_get_mr, MFMR>;
defm : MoveFromRegType<int_postrisc_get_ibr, MFIBR>;
defm : MoveFromRegType<int_postrisc_get_dbr, MFDBR>;

defm : MoveToRegType<int_postrisc_set_mr, MTMR>;
defm : MoveToRegType<int_postrisc_set_ibr, MTIBR>;
defm : MoveToRegType<int_postrisc_set_dbr, MTDBR>;

//===----------------------------------------------------------------------===//
// TLB
//===----------------------------------------------------------------------===//
let hasSideEffects = 1 in {
def PTC : MISC_Rabc<misc_opx_ptc,
           (outs), (ins GR:$ra, GR:$rb, GR:$rc),
           !strconcat(misc_opx_ptc.mnem,  "\t$ra, $rb, $rc"),
           [(int_postrisc_tlb_purge iPTR:$ra, iPTR:$rb, i32:$rc)]>;
}

//===----------------------------------------------------------------------===//
// Cache flush/invalidate/touch
//===----------------------------------------------------------------------===//
multiclass RAOPX_CACHE<raopx_opx opx, ClangBuiltin Op, Operand immOp, Operand immOpExt, InstrItinClass itin = IIC_iu_instr>
{
  def NAME        : RAOPX_RbI21    <opx, (outs), (ins GR:$rb, immOp   :$imm), !strconcat(opx.mnem,   "\t$rb, $imm"), [], itin>;
  def NAME # _EXT : RAOPX_RbI21_ext<opx, (outs), (ins GR:$rb, immOpExt:$imm), !strconcat(opx.mnem, ".l\t$rb, $imm"), [], itin>;

  def : Pat<(Op      iPTR:$rb                ), (!cast<InstBase>(NAME) GR:$rb, 0)>;
  def : Pat<(Op (add iPTR:$rb, immOp   :$imm)), (!cast<InstBase>(NAME) GR:$rb, immOp:$imm)>;
  def : Pat<(Op (add iPTR:$rb, immOpExt:$imm)), (!cast<InstBaseExt>(NAME # _EXT) GR:$rb, immOpExt:$imm)>;
}

defm DCBF : RAOPX_CACHE<raopx_opx_dcbf, int_postrisc_dcbf, simm21, simm21_ext>;
defm DCBI : RAOPX_CACHE<raopx_opx_dcbi, int_postrisc_dcbi, simm21, simm21_ext>;
defm DCBT : RAOPX_CACHE<raopx_opx_dcbt, int_postrisc_dcbt, simm21, simm21_ext>;
defm ICBI : RAOPX_CACHE<raopx_opx_icbi, int_postrisc_icbi, simm21, simm21_ext>;

//===----------------------------------------------------------------------===//
// Random generator
//===----------------------------------------------------------------------===//
def RANDOM : MISC_Rab<misc_opx_random, (outs GR:$ra), (ins GR:$rb), !strconcat(misc_opx_random.mnem, "\t$ra, $rb"), []>;

def : Pat<(int_postrisc_random_n i64:$rb), (RANDOM (i64 $rb))>;
def : Pat<(int_postrisc_random), (RANDOM (i64 gz))>;

//===----------------------------------------------------------------------===//
// Exceptions
//===----------------------------------------------------------------------===//
defm EHTHROW : RAOPX_CACHE<raopx_opx_eh_throw, int_postrisc_eh_throw, simm11, simm11_ext>;
