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
  def GET_SPR : MISC_Rac<opcode_get_spr, (outs GR:$ra), (ins SR:$rc), !strconcat(opcode_get_spr.mnem, " $ra, $rc"), []>;
  def SET_SPR : MISC_Rac<opcode_set_spr, (outs SR:$rc), (ins GR:$ra), !strconcat(opcode_set_spr.mnem, " $ra, $rc"), []>;
}

// special registers getters builtins (setters are custom)
multiclass SPEC_REG<ValueType Ty> {
  def : Pat<(Ty (!cast<ClangBuiltin>("int_postrisc_get_" # NAME))), (GET_SPR (Ty !cast<PostriscCtrlReg>(NAME)))>;
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

def : Pat<(i64 (readcyclecounter)), (GET_SPR (i64 itc))>;

//===----------------------------------------------------------------------===//
// Register windows/frame and stack/buffer
//===----------------------------------------------------------------------===//
let hasSideEffects = 1 in {
  let imm = 0 in {
    def ALLOC : RAOPX_RbI21<opcode_alloc, (outs), (ins uimm7:$rb), !strconcat(opcode_alloc.mnem, " $rb"), []>;
  }
  let Defs = [sp], Uses = [sp] in {
    def ALLOCSP     : RAOPX_RbI21    <opcode_alloc_sp, (outs), (ins uimm7:$rb, uimm21    :$imm), !strconcat(opcode_alloc_sp.mnem,   " $rb, $imm"), []>;
    def ALLOCSP_EXT : RAOPX_RbI21_ext<opcode_alloc_sp, (outs), (ins uimm7:$rb, uimm21_ext:$imm), !strconcat(opcode_alloc_sp.mnem, ".l $rb, $imm"), []>;
  }
  def RSCOVER : MISC_NoArgs<opcode_rscover, (outs), (ins), []>;
  def RSLOAD  : MISC_NoArgs<opcode_rsload,  (outs), (ins), []>;
}

def flushw : SDNode<"PostriscISD::FLUSHW", SDTNone,
                    [SDNPHasChain, SDNPSideEffect, SDNPMayStore]>;

let hasSideEffects = 1, mayStore = 1 in {
  def RSFLUSH : MISC_NoArgs<opcode_rsflush, (outs), (ins), [(flushw)]>;
}

//===----------------------------------------------------------------------===//
// CPUID
//===----------------------------------------------------------------------===//
def CPUID : MISC_RabI10<opcode_cpuid,
  (outs GR:$ra), (ins GR:$rb, stride_imm:$imm), !strconcat(opcode_cpuid.mnem, " $ra, $rb, $imm"), []>;

def : Pat<(i64 (int_postrisc_cpuid (add i64:$src, stride_imm:$imm))), (CPUID (i64 $src), stride_imm:$imm)>;
def : Pat<(i64 (int_postrisc_cpuid      i64:$src                  )), (CPUID (i64 $src),               0)>;
def : Pat<(i64 (int_postrisc_cpuid                stride_imm:$imm )), (CPUID (i64   gz), stride_imm:$imm)>;

//===----------------------------------------------------------------------===//
// Software trap (GR + stride_imm)
//===----------------------------------------------------------------------===//
let hasSideEffects = 1, isTerminator = 1 in {
  def INT : MISC_RbI10<opcode_int,
    (outs), (ins GR:$rb, stride_imm:$imm), !strconcat(opcode_int.mnem, " $rb, $imm"), []>;
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
  def SYSCALL   : MISC_NoArgs<opcode_syscall,   (outs), (ins), [(int_postrisc_syscall)]>;
  def SYSRET    : MISC_NoArgs<opcode_sysret,    (outs), (ins), [(int_postrisc_sysret)]>;
  def RFI       : MISC_NoArgs<opcode_rfi,       (outs), (ins), [(int_postrisc_rfi)]>;
  def HALT      : MISC_NoArgs<opcode_halt,      (outs), (ins), [(int_postrisc_halt)]>;
  def UNDEF     : MISC_NoArgs<opcode_undef,     (outs), (ins), [(int_postrisc_undef)]>;
}

def TPA : MISC_Rabc<opcode_tpa,
                 (outs GR:$ra), (ins GR:$rb, GR:$rc),
                 !strconcat(opcode_tpa.mnem, " $ra, $rb, $rc"),
                 [(set i64:$ra, (int_postrisc_tpa i64:$rb, i64:$rc))]>;

//===----------------------------------------------------------------------===//
// NOPS
//===----------------------------------------------------------------------===//
let hasSideEffects = 1 in {
  def NOP     : RAOPX_Branch    <opcode_nop, (outs), (ins simm28    :$imm), !strconcat(opcode_nop.mnem,   " $imm"), []>;
  def NOP_EXT : RAOPX_Branch_ext<opcode_nop, (outs), (ins simm28_ext:$imm), !strconcat(opcode_nop.mnem, ".l $imm"), []>;
}

def : Pat<(int_postrisc_nop   uimm28:$imm    ), (NOP     uimm28:$imm)>;
def : Pat<(int_postrisc_nop   uimm28_ext:$imm), (NOP_EXT uimm28_ext:$imm)>;
def : Pat<(int_postrisc_nop_l uimm28_ext:$imm), (NOP_EXT uimm28_ext:$imm)>;

//def : InstAlias<"nopft",   (NOP 0)>;  // nop after FallThrough block
//def : InstAlias<"nopcall", (NOP 1)>;  // nop after call
//def : InstAlias<"nopterm", (NOP 2)>;  // nop after block with terminator

// special codegened NOP, trick to avoid nullification for MBB in tests
let isCodeGenOnly = 1, hasSideEffects = 1 in {
  def NUL_NEVER     : RAOPX_Branch    <opcode_nop, (outs), (ins simm28    :$imm), !strconcat(opcode_nop.mnem,   " $imm"), [(int_postrisc_nul_never simm28    :$imm)]>;
  def NUL_NEVER_EXT : RAOPX_Branch_ext<opcode_nop, (outs), (ins simm28_ext:$imm), !strconcat(opcode_nop.mnem, ".l $imm"), [(int_postrisc_nul_never simm28_ext:$imm)]>;
}

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
  def GET_MR  : MISC_RabI10<opcode_get_mr,  (outs GR:$ra), (ins GR:$rb, stride_imm:$imm),  !strconcat(opcode_get_mr.mnem,  " $ra, $rb, $imm"), []>;
  def GET_IBR : MISC_RabI10<opcode_get_ibr, (outs GR:$ra), (ins GR:$rb, stride_imm:$imm),  !strconcat(opcode_get_ibr.mnem, " $ra, $rb, $imm"), []>;
  def GET_DBR : MISC_RabI10<opcode_get_dbr, (outs GR:$ra), (ins GR:$rb, stride_imm:$imm),  !strconcat(opcode_get_dbr.mnem, " $ra, $rb, $imm"), []>;
  def SET_MR  : MISC_RabI10<opcode_set_mr,  (outs), (ins GR:$ra, GR:$rb, stride_imm:$imm), !strconcat(opcode_set_mr.mnem,  " $ra, $rb, $imm"), []>;
  def SET_IBR : MISC_RabI10<opcode_set_ibr, (outs), (ins GR:$ra, GR:$rb, stride_imm:$imm), !strconcat(opcode_set_ibr.mnem, " $ra, $rb, $imm"), []>;
  def SET_DBR : MISC_RabI10<opcode_set_dbr, (outs), (ins GR:$ra, GR:$rb, stride_imm:$imm), !strconcat(opcode_set_dbr.mnem, " $ra, $rb, $imm"), []>;
}

defm : MoveFromRegType<int_postrisc_get_mr,  GET_MR>;
defm : MoveFromRegType<int_postrisc_get_ibr, GET_IBR>;
defm : MoveFromRegType<int_postrisc_get_dbr, GET_DBR>;

defm : MoveToRegType<int_postrisc_set_mr,  SET_MR>;
defm : MoveToRegType<int_postrisc_set_ibr, SET_IBR>;
defm : MoveToRegType<int_postrisc_set_dbr, SET_DBR>;

//===----------------------------------------------------------------------===//
// TLB
//===----------------------------------------------------------------------===//
let hasSideEffects = 1 in {
def PTC : MISC_Rabc<opcode_ptc,
           (outs), (ins GR:$ra, GR:$rb, GR:$rc),
           !strconcat(opcode_ptc.mnem,  " $ra, $rb, $rc"),
           [(int_postrisc_tlb_purge iPTR:$ra, iPTR:$rb, i32:$rc)]>;
}

//===----------------------------------------------------------------------===//
// Cache flush/invalidate/touch
//===----------------------------------------------------------------------===//
multiclass RAOPX_CACHE<raopx_opx opx, ClangBuiltin Op, Operand immOp, Operand immOpExt, InstrItinClass itin = IIC_iu_instr>
{
  def NAME        : RAOPX_RbI21    <opx, (outs), (ins GR:$rb, immOp   :$imm), !strconcat(opx.mnem,   " $rb, $imm"), [], itin>;
  def NAME # _EXT : RAOPX_RbI21_ext<opx, (outs), (ins GR:$rb, immOpExt:$imm), !strconcat(opx.mnem, ".l $rb, $imm"), [], itin>;

  def : Pat<(Op      iPTR:$rb                ), (!cast<InstBase>(NAME) GR:$rb, 0)>;
  def : Pat<(Op (add iPTR:$rb, immOp   :$imm)), (!cast<InstBase>(NAME) GR:$rb, immOp:$imm)>;
  def : Pat<(Op (add iPTR:$rb, immOpExt:$imm)), (!cast<InstBaseExt>(NAME # _EXT) GR:$rb, immOpExt:$imm)>;
}

defm DCBF : RAOPX_CACHE<opcode_dcbf, int_postrisc_dcbf, simm21, simm21_ext>;
defm DCBI : RAOPX_CACHE<opcode_dcbi, int_postrisc_dcbi, simm21, simm21_ext>;
defm DCBT : RAOPX_CACHE<opcode_dcbt, int_postrisc_dcbt, simm21, simm21_ext>;
defm ICBI : RAOPX_CACHE<opcode_icbi, int_postrisc_icbi, simm21, simm21_ext>;

//===----------------------------------------------------------------------===//
// Random generator
//===----------------------------------------------------------------------===//
def RANDOM : MISC_Rab<opcode_random, (outs GR:$ra), (ins GR:$rb), !strconcat(opcode_random.mnem, " $ra, $rb"), []>;

def : Pat<(int_postrisc_random_n i64:$rb), (RANDOM (i64 $rb))>;
def : Pat<(int_postrisc_random), (RANDOM (i64 gz))>;

//===----------------------------------------------------------------------===//
// Exceptions
//===----------------------------------------------------------------------===//
defm EH_THROW : RAOPX_CACHE<opcode_eh_throw, int_postrisc_eh_throw, simm11, simm11_ext>;
