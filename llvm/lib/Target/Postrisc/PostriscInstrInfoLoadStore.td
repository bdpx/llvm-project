//===-- PostriscInstrInfoLoadStore.td - Target Description for Postrisc ---===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file describes the Postrisc load/store instructions.
// Load/store part
//
//===----------------------------------------------------------------------===//


//===----------------------------------------------------------------------===//
// load instructions (base+dsip, ip+disp, pre/post update)
//===----------------------------------------------------------------------===//
multiclass
Load<opcode_opx opRI, opcode_opx opRC,
     misc_opx opMIA, misc_opx opMIB,
     string OpcStr, InstrItinClass itin = IIC_iu_instr>
{
  // base + displacement
  let mayLoad = 1 in
  def ri : PRIMARY_RabI21<opRI,
                 (outs GR:$ra), (ins GR:$rb, simm21:$imm),
                 !strconcat(OpcStr, "\t$ra, $rb, $imm"),
                 [], itin>;

  // base + displacement extended
  let mayLoad = 1, AddedComplexity = 3 in
  def ri_ext  : PRIMARY_RabI21_ext<opRI,
                 (outs GR:$ra), (ins GR:$rb, simm21_ext:$imm),
                 !strconcat(OpcStr, ".l\t$ra, $rb, $imm"),
                 [], itin>;

  // ip + forward displacement
  let mayLoad = 1 in
  def rc : PRIMARY_RaI28<opRC,
                 (outs GR:$ra), (ins simm28:$imm),
                 !strconcat(OpcStr, "r\t$ra, $imm"),
                 [], itin>;

  // ip + forward displacement extended
  let mayLoad = 1, AddedComplexity = 3 in
  def rc_ext : PRIMARY_RaI28_ext<opRC,
                 (outs GR:$ra), (ins simm28_ext:$imm),
                 !strconcat(OpcStr, "r.l\t$ra, $imm"),
                 [], itin>;

  // base with base post-update immediate
  let mayLoad = 1, isPostIncrement = 1 in
  def mia : MISC_RabI10<opMIA,
                   (outs GR:$ra), (ins GR:$rb, stride_imm:$imm),
                   !strconcat(OpcStr, "mia\t$ra, $rb, $imm"), [], itin>;

  // base with base post-update immediate (extended)
  let mayLoad = 1, isPostIncrement = 1 in
  def mia_ext : MISC_RabI10_ext<opMIA,
                   (outs GR:$ra), (ins GR:$rb, stride_imm_ext:$imm),
                   !strconcat(OpcStr, "mia.l\t$ra, $rb, $imm"), [], itin>;

  // base with base pre-update immediate
  let mayLoad = 1, isPreIncrement = 1 in
  def mib : MISC_RabI10<opMIB,
                   (outs GR:$ra), (ins GR:$rb, stride_imm:$imm),
                   !strconcat(OpcStr, "mib\t$ra, $rb, $imm"), [], itin>;

  // base with base pre-update immediate (extended)
  let mayLoad = 1, isPreIncrement = 1 in
  def mib_ext : MISC_RabI10_ext<opMIB,
                   (outs GR:$ra), (ins GR:$rb, stride_imm_ext:$imm),
                   !strconcat(OpcStr, "mib.l\t$ra, $rb, $imm"), [], itin>;
}

defm LDBZ : Load<opcode_ldbz, opcode_ldbzr, misc_opx_ldbzmia, misc_opx_ldbzmib, "ldbz">;
defm LDBS : Load<opcode_ldbs, opcode_ldbsr, misc_opx_ldbsmia, misc_opx_ldbsmib, "ldbs">;
defm LDHZ : Load<opcode_ldhz, opcode_ldhzr, misc_opx_ldhzmia, misc_opx_ldhzmib, "ldhz">;
defm LDHS : Load<opcode_ldhs, opcode_ldhsr, misc_opx_ldhsmia, misc_opx_ldhsmib, "ldhs">;
defm LDWZ : Load<opcode_ldwz, opcode_ldwzr, misc_opx_ldwzmia, misc_opx_ldwzmib, "ldwz">;
defm LDWS : Load<opcode_ldws, opcode_ldwsr, misc_opx_ldwsmia, misc_opx_ldwsmib, "ldws">;
defm LDDZ : Load<opcode_lddz, opcode_lddzr, misc_opx_lddzmia, misc_opx_lddzmib, "lddz">;
defm LDDS : Load<opcode_ldds, opcode_lddsr, misc_opx_lddsmia, misc_opx_lddsmib, "ldds">;
defm LDQ  : Load<opcode_ldq,  opcode_ldqr,  misc_opx_ldqmia,  misc_opx_ldqmib,  "ldq">;

//===----------------------------------------------------------------------===//
// indexed instructions and LDAX
//===----------------------------------------------------------------------===//
multiclass
LoadIndexed<opcode_opx opRR, string OpcStr, InstrItinClass itin = IIC_iu_instr>
{
  // base + scaled 64-bit index + displacement
  let mayLoad = 1, isIndexedMemAccess = 1 in
  def rr_s64 : PRIMARY_MemIndexed<opRR, scale_opx_s64,
                 (outs GR:$ra), (ins GR:$rb, GR:$rc, scale:$scale, indexed_disp:$imm),
                 !strconcat(OpcStr, "\t$ra, $rb, $rc, $scale, $imm"),
                 [], itin>;

  // base + scaled 64-bit index + displacement extended
  let mayLoad = 1, isIndexedMemAccess = 1, AddedComplexity = 3 in
  def rr_s64_ext : PRIMARY_MemIndexedLong<opRR, scale_opx_s64,
                 (outs GR:$ra), (ins GR:$rb, GR:$rc, scale:$scale, indexed_disp_ext:$imm),
                 !strconcat(OpcStr, ".l\t$ra, $rb, $rc, $scale, $imm"),
                 [], itin>;

  // base + scaled signed 32-bit index + displacement
  let mayLoad = 1, isIndexedMemAccess = 1 in
  def rr_s32 : PRIMARY_MemIndexed<opRR, scale_opx_s32,
                 (outs GR:$ra), (ins GR:$rb, GR:$rc, scale:$scale, indexed_disp:$imm),
                 !strconcat(OpcStr, ".ws\t$ra, $rb, $rc, $scale, $imm"),
                 [], itin>;

  // base + scaled signed 32-bit index + displacement extended
  let mayLoad = 1, isIndexedMemAccess = 1, AddedComplexity = 3 in
  def rr_s32_ext : PRIMARY_MemIndexedLong<opRR, scale_opx_s32,
                 (outs GR:$ra), (ins GR:$rb, GR:$rc, scale:$scale, indexed_disp_ext:$imm),
                 !strconcat(OpcStr, ".ws.l\t$ra, $rb, $rc, $scale, $imm"),
                 [], itin>;

  // base + scaled unsigned 32-bit index + displacement
  let mayLoad = 1, isIndexedMemAccess = 1 in
  def rr_u32 : PRIMARY_MemIndexed<opRR, scale_opx_u32,
                 (outs GR:$ra), (ins GR:$rb, GR:$rc, scale:$scale, indexed_disp:$imm),
                 !strconcat(OpcStr, ".wz\t$ra, $rb, $rc, $scale, $imm"),
                 [], itin>;

  // base + scaled unsigned 32-bit index + displacement extended
  let mayLoad = 1, isIndexedMemAccess = 1, AddedComplexity = 3 in
  def rr_u32_ext : PRIMARY_MemIndexedLong<opRR, scale_opx_u32,
                 (outs GR:$ra), (ins GR:$rb, GR:$rc, scale:$scale, indexed_disp_ext:$imm),
                 !strconcat(OpcStr, ".wz.l\t$ra, $rb, $rc, $scale, $imm"),
                 [], itin>;
}

defm LDBZ : LoadIndexed<opcode_ldbzx, "ldbzx">;
defm LDBS : LoadIndexed<opcode_ldbsx, "ldhzx">;
defm LDHZ : LoadIndexed<opcode_ldhzx, "ldhzx">;
defm LDHS : LoadIndexed<opcode_ldhsx, "ldhsx">;
defm LDWZ : LoadIndexed<opcode_ldwzx, "ldwzx">;
defm LDWS : LoadIndexed<opcode_ldwsx, "ldwsx">;
defm LDDZ : LoadIndexed<opcode_lddzx, "lddzx">;
defm LDDS : LoadIndexed<opcode_lddsx, "lddsx">;
defm LDQ  : LoadIndexed<opcode_ldqx,  "ldqx">;

//===----------------------------------------------------------------------===//
// Load patterns.
//===----------------------------------------------------------------------===//
multiclass
LdPatBase<PatFrag LoadOp, InstBase Inst, InstBaseExt instExt, ValueType Ty>
{
  def : Pat<(Ty (LoadOp (add i64:$rb, simm21:$imm))),
            (Inst GR:$rb, simm21:$imm)>;
  def : Pat<(Ty (LoadOp (add AddrFI:$rb, simm21:$imm))),
            (Inst AddrFI:$rb, simm21:$imm)>;
  def : Pat<(Ty (LoadOp i64:$rb)),
            (Inst GR:$rb, 0)>;
  def : Pat<(Ty (LoadOp AddrFI:$rb)),
            (Inst AddrFI:$rb, 0)>;
  def : Pat<(Ty (LoadOp (add i64:$rb, simm21_ext:$imm))),
            (instExt GR:$rb, simm21_ext:$imm)>;
  def : Pat<(Ty (LoadOp (add AddrFI:$rb, simm21_ext:$imm))),
            (instExt AddrFI:$rb, simm21_ext:$imm)>;

  def : Pat<(Ty (LoadOp (add i64:$rb, (tls_offset_wrapper tglobaltlsaddr:$addr)))),
            (Inst GR:$rb, tglobaltlsaddr:$addr)>;
  def : Pat<(Ty (LoadOp (add i64:$rb, (tls_offset_wrapper_ext tglobaltlsaddr:$addr)))),
            (instExt GR:$rb, tglobaltlsaddr:$addr)>;
}

multiclass
LdPatPCRel<PatFrag LoadOp, InstBase Inst, InstBaseExt Inst_ext, ValueType Ty>
{
  // global/external address should be properly wrapped
  // into corresponding PCREL wrapper (_ext or nothing)
  def : Pat<(Ty (LoadOp (pcrel_data_wrapper tglobaladdr:$addr))),
            (Inst tglobaladdr:$addr)>;
  def : Pat<(Ty (LoadOp (pcrel_data_wrapper tconstpool:$addr))),
            (Inst tconstpool:$addr)>;
  def : Pat<(Ty (LoadOp (pcrel_data_wrapper texternalsym:$addr))),
            (Inst texternalsym:$addr)>;
  def : Pat<(Ty (LoadOp (pcrel_data_wrapper tglobaltlsaddr:$addr))),
            (Inst tglobaltlsaddr:$addr)>;
  def : Pat<(Ty (LoadOp (pcrel_data_wrapper tjumptable:$addr))),
            (Inst tjumptable:$addr)>;

  def : Pat<(Ty (LoadOp (pcrel_data_wrapper_ext tglobaladdr:$addr))),
            (Inst_ext tglobaladdr:$addr)>;
  def : Pat<(Ty (LoadOp (pcrel_data_wrapper_ext tconstpool:$addr))),
            (Inst_ext tconstpool:$addr)>;
  def : Pat<(Ty (LoadOp (pcrel_data_wrapper_ext texternalsym:$addr))),
            (Inst_ext texternalsym:$addr)>;
  def : Pat<(Ty (LoadOp (pcrel_data_wrapper_ext tglobaltlsaddr:$addr))),
            (Inst_ext tglobaltlsaddr:$addr)>;
  def : Pat<(Ty (LoadOp (pcrel_data_wrapper_ext tjumptable:$addr))),
            (Inst_ext tjumptable:$addr)>;
}

//===----------------------------------------------------------------------===//
// Indexed addressing patterns.
//===----------------------------------------------------------------------===//

// base + scaled_index + disp
def INDEXED_BSID :
   PatFrag<(ops node:$base, node:$index, node:$scale, node:$offset),
          (add (add node:$base, (shl node:$index, node:$scale)), node:$offset)>;

// base + index + disp (no scale)
def INDEXED_BID :
   PatFrag<(ops node:$base, node:$index, node:$offset),
          (add (add node:$base, node:$index), node:$offset)>;

// base + scaled_index (no disp)
def INDEXED_BSI :
   PatFrag<(ops node:$base, node:$index, node:$scale),
          (add node:$base, (shl node:$index, node:$scale))>;

// base + index (no dips, no scale)
def INDEXED_BI :
   PatFrag<(ops node:$base, node:$index),
          (add node:$base, node:$index)>;

//===----------------------------------------------------------------------===//
// Indexed index patterns (sign/zero extend, etc)
// FIXME: there is no identity PatFrag, so i64 index patterns are duplicated
//===----------------------------------------------------------------------===//
def indexed_i32_sext  : PatFrag<(ops node:$index), (i64 (sext node:$index))>;
def indexed_i32_zext  : PatFrag<(ops node:$index), (i64 (zext node:$index))>;
def indexed_i64_sext  : PatFrag<(ops node:$index), (sext_inreg node:$index, i32)>;
def indexed_i64_zext  : PatFrag<(ops node:$index), (i64 (zext (i32 (trunc node:$index))))>;
def indexed_i64_trunc : PatFrag<(ops node:$index), (i64 (and node:$index, (i64 0xFFFFFFFF)))>;

multiclass
LdPatIndexed_i32<PatFrag LoadOp, PatFrag IndexOp,
                 InstBase Inst, InstBaseExt instExt, ValueType Ty, ValueType IndexTy>
{
  // base + scaled_index + disp
  def : Pat<(Ty (LoadOp
            (INDEXED_BSID i64:$rb, (IndexOp IndexTy:$rc), scale:$scale, indexed_disp:$imm))),
            (Inst GR:$rb, GR:$rc, scale:$scale, indexed_disp:$imm)>;
  def : Pat<(Ty (LoadOp
            (INDEXED_BSID i64:$rb, (IndexOp IndexTy:$rc), scale:$scale, indexed_disp_ext:$imm))),
            (instExt GR:$rb, GR:$rc, scale:$scale, indexed_disp_ext:$imm)>;

  // base + index + disp
  def : Pat<(Ty (LoadOp
            (INDEXED_BID i64:$rb, (IndexOp IndexTy:$rc), indexed_disp:$imm))),
            (Inst GR:$rb, GR:$rc, 0, indexed_disp:$imm)>;
  def : Pat<(Ty (LoadOp
            (INDEXED_BID i64:$rb, (IndexOp IndexTy:$rc), indexed_disp_ext:$imm))),
            (instExt GR:$rb, GR:$rc, 0, indexed_disp_ext:$imm)>;

  // base + scaled_index (no extended variant)
  def : Pat<(Ty (LoadOp
            (INDEXED_BSI i64:$rb, (IndexOp IndexTy:$rc), scale:$scale))),
            (Inst GR:$rb, GR:$rc, scale:$scale, 0)>;

  // base + index (no extended variant)
  def : Pat<(Ty (LoadOp
            (INDEXED_BI i64:$rb, (IndexOp IndexTy:$rc)))),
            (Inst GR:$rb, GR:$rc, 0, 0)>;
}

multiclass
LdPatIndexed_i64<PatFrag LoadOp, InstBase Inst, InstBaseExt instExt, ValueType Ty>
{
  // base + scaled_index + disp
  def : Pat<(Ty (LoadOp
            (INDEXED_BSID i64:$rb, i64:$rc, scale:$scale, indexed_disp:$imm))),
            (Inst GR:$rb, GR:$rc, scale:$scale, indexed_disp:$imm)>;
  def : Pat<(Ty (LoadOp
            (INDEXED_BSID i64:$rb, i64:$rc, scale:$scale, indexed_disp_ext:$imm))),
            (instExt GR:$rb, GR:$rc, scale:$scale, indexed_disp_ext:$imm)>;

  // base + index + disp
  def : Pat<(Ty (LoadOp
            (INDEXED_BID i64:$rb, i64:$rc, indexed_disp:$imm))),
            (Inst GR:$rb, GR:$rc, 0, indexed_disp:$imm)>;
  def : Pat<(Ty (LoadOp
            (INDEXED_BID i64:$rb, i64:$rc, indexed_disp_ext:$imm))),
            (instExt GR:$rb, GR:$rc, 0, indexed_disp_ext:$imm)>;

  // base + scaled_index (no extended variant)
  def : Pat<(Ty (LoadOp
            (INDEXED_BSI i64:$rb, i64:$rc, scale:$scale))),
            (Inst GR:$rb, GR:$rc, scale:$scale, 0)>;

  // base + index (no extended variant)
  def : Pat<(Ty (LoadOp
            (INDEXED_BI i64:$rb, i64:$rc))),
            (Inst GR:$rb, GR:$rc, 0, 0)>;
}

multiclass
LdPat<string INSTNAME, PatFrag LoadOp, ValueType Ty>
{
  defm : LdPatBase<LoadOp,
           !cast<InstBase>(INSTNAME # "ri"),
           !cast<InstBaseExt>(INSTNAME # "ri_ext"), Ty>;
  defm : LdPatPCRel<LoadOp,
           !cast<InstBase>(INSTNAME # "rc"),
           !cast<InstBaseExt>(INSTNAME # "rc_ext"), Ty>;
  defm : LdPatIndexed_i64<LoadOp,
           !cast<InstBase>(INSTNAME # "rr_s64"),
           !cast<InstBaseExt>(INSTNAME # "rr_s64_ext"), Ty>;
  defm : LdPatIndexed_i32<LoadOp, indexed_i32_sext,
           !cast<InstBase>(INSTNAME # "rr_s32"),
           !cast<InstBaseExt>(INSTNAME # "rr_s32_ext"), Ty, i32>;
  defm : LdPatIndexed_i32<LoadOp, indexed_i32_zext,
           !cast<InstBase>(INSTNAME # "rr_u32"),
           !cast<InstBaseExt>(INSTNAME # "rr_u32_ext"), Ty, i32>;
  defm : LdPatIndexed_i32<LoadOp, indexed_i64_sext,
           !cast<InstBase>(INSTNAME # "rr_s32"),
           !cast<InstBaseExt>(INSTNAME # "rr_s32_ext"), Ty, i64>;
  defm : LdPatIndexed_i32<LoadOp, indexed_i64_zext,
           !cast<InstBase>(INSTNAME # "rr_u32"),
           !cast<InstBaseExt>(INSTNAME # "rr_u32_ext"), Ty, i64>;
  defm : LdPatIndexed_i32<LoadOp, indexed_i64_trunc,
           !cast<InstBase>(INSTNAME # "rr_u32"),
           !cast<InstBaseExt>(INSTNAME # "rr_u32_ext"), Ty, i64>;
}

defm : LdPat<"LDBZ", load,        i1>;
defm : LdPat<"LDBZ", zextloadi1,  i32>;
defm : LdPat<"LDBZ", extloadi1,   i32>;
defm : LdPat<"LDBZ", zextloadi1,  i64>;
defm : LdPat<"LDBZ", extloadi1,   i64>;
defm : LdPat<"LDBZ", zextloadi8,  i32>;
defm : LdPat<"LDBZ", extloadi8,   i32>;
defm : LdPat<"LDBZ", zextloadi8,  i64>;
defm : LdPat<"LDBZ", extloadi8,   i64>;
defm : LdPat<"LDBZ", zextloadi8,  i128>;

defm : LdPat<"LDBS", sextloadi8,  i32>;
defm : LdPat<"LDBS", sextloadi8,  i64>;

defm : LdPat<"LDHZ", zextloadi16, i32>;
defm : LdPat<"LDHZ", extloadi16,  i32>;
defm : LdPat<"LDHZ", zextloadi16, i64>;
defm : LdPat<"LDHZ", extloadi16,  i64>;
defm : LdPat<"LDHZ", zextloadi16, i128>;

defm : LdPat<"LDHS", sextloadi16, i32>;
defm : LdPat<"LDHS", sextloadi16, i64>;

defm : LdPat<"LDWZ", load,        i32>;
defm : LdPat<"LDWZ", zextloadi32, i64>;
defm : LdPat<"LDWZ", extloadi32,  i64>;
defm : LdPat<"LDWZ", zextloadi32, i128>;

defm : LdPat<"LDWS", sextloadi32, i64>;

defm : LdPat<"LDDZ", load,        i64>;
defm : LdPat<"LDDZ", zextloadi64, i128>;

defm : LdPat<"LDQ",  load,        i128>;

//===----------------------------------------------------------------------===//
// Store instructions.
//===----------------------------------------------------------------------===//
multiclass
Store<opcode_opx opRR, opcode_opx opRI, opcode_opx opRC,
      misc_opx opMIA, misc_opx opMIB,
      string OpcStr, InstrItinClass itin = IIC_st>
{
  // base + displacement
  let mayStore = 1 in
  def ri       : PRIMARY_RabI21<opRI,
                 (outs), (ins GR:$ra, GR:$rb, simm21:$imm),
                 !strconcat(OpcStr, "\t$ra, $rb, $imm"),
                 [], itin>;

  // base + displacement extended
  let mayStore = 1, AddedComplexity = 3 in
  def ri_ext  : PRIMARY_RabI21_ext<opRI,
                 (outs), (ins GR:$ra, GR:$rb, simm21_ext:$imm),
                 !strconcat(OpcStr, ".l\t$ra, $rb, $imm"),
                 [], itin>;

  // ip + forward displacement
  let mayStore = 1 in
  def rc       : PRIMARY_RaI28<opRC,
                 (outs), (ins GR:$ra, simm28:$imm),
                 !strconcat(OpcStr, "r\t$ra, $imm"),
                 [], itin>;

  // ip + forward displacement extended
  let mayStore = 1, AddedComplexity = 3 in
  def rc_ext  : PRIMARY_RaI28_ext<opRC,
                 (outs), (ins GR:$ra, simm28_ext:$imm),
                 !strconcat(OpcStr, "r.l\t$ra, $imm"),
                 [], itin>;

  // base + scaled 64-bit index + displacement
  let mayStore = 1, isIndexedMemAccess = 1 in
  def rr_s64 : PRIMARY_MemIndexed<opRR, scale_opx_s64,
                 (outs), (ins GR:$ra, GR:$rb, GR:$rc, scale:$scale, indexed_disp:$imm),
                 !strconcat(OpcStr, "x\t$ra, $rb, $rc, $scale, $imm"),
                 [], itin>;

  // base + scaled 64-bit index + displacement extended
  let mayStore = 1, isIndexedMemAccess = 1, AddedComplexity = 3 in
  def rr_s64_ext  : PRIMARY_MemIndexedLong<opRR, scale_opx_s64,
                 (outs), (ins GR:$ra, GR:$rb, GR:$rc, scale:$scale, indexed_disp_ext:$imm),
                 !strconcat(OpcStr, "x.l\t$ra, $rb, $rc, $scale, $imm"),
                 [], itin>;

  // base + scaled signed 32-bit index + displacement
  let mayStore = 1, isIndexedMemAccess = 1 in
  def rr_s32  : PRIMARY_MemIndexed<opRR, scale_opx_s32,
                 (outs), (ins GR:$ra, GR:$rb, GR:$rc, scale:$scale, indexed_disp:$imm),
                 !strconcat(OpcStr, "x.ws\t$ra, $rb, $rc, $scale, $imm"),
                 [], itin>;

  // base + scaled signed 32-bit index + displacement extended
  let mayStore = 1, isIndexedMemAccess = 1, AddedComplexity = 3 in
  def rr_s32_ext : PRIMARY_MemIndexedLong<opRR, scale_opx_s32,
                 (outs), (ins GR:$ra, GR:$rb, GR:$rc, scale:$scale, indexed_disp_ext:$imm),
                 !strconcat(OpcStr, "x.ws.l\t$ra, $rb, $rc, $scale, $imm"),
                 [], itin>;

  // base + scaled unsigned 32-bit index + displacement
  let mayStore = 1, isIndexedMemAccess = 1 in
  def rr_u32  : PRIMARY_MemIndexed<opRR, scale_opx_u32,
                 (outs), (ins GR:$ra, GR:$rb, GR:$rc, scale:$scale, indexed_disp:$imm),
                 !strconcat(OpcStr, "x.wz\t$ra, $rb, $rc, $scale, $imm"),
                 [], itin>;

  // base + scaled unsigned 32-bit index + displacement extended
  let mayStore = 1, isIndexedMemAccess = 1, AddedComplexity = 3 in
  def rr_u32_ext : PRIMARY_MemIndexedLong<opRR, scale_opx_u32,
                 (outs), (ins GR:$ra, GR:$rb, GR:$rc, scale:$scale, indexed_disp_ext:$imm),
                 !strconcat(OpcStr, "x.wz.l\t$ra, $rb, $rc, $scale, $imm"),
                 [], itin>;

  // base with base post-update immediate
  let mayStore = 1, isPostIncrement = 1 in
  def mia : MISC_RabI10<opMIA,
                   (outs), (ins GR:$ra, GR:$rb, stride_imm:$imm),
                   !strconcat(OpcStr, "mia\t$ra, $rb, $imm"), [], itin>;

  // base with base post-update immediate (extended)
  let mayStore = 1, isPostIncrement = 1 in
  def mia_ext : MISC_RabI10_ext<opMIA,
                   (outs), (ins GR:$ra, GR:$rb, stride_imm_ext:$imm),
                   !strconcat(OpcStr, "mia.l\t$ra, $rb, $imm"), [], itin>;

  // base with base pre-update immediate
  let mayStore = 1, isPreIncrement = 1 in
  def mib : MISC_RabI10<opMIB,
                   (outs), (ins GR:$ra, GR:$rb, stride_imm:$imm),
                   !strconcat(OpcStr, "mib\t$ra, $rb, $imm"), [], itin>;

  // base with base pre-update immediate (extended)
  let mayStore = 1, isPreIncrement = 1 in
  def mib_ext : MISC_RabI10_ext<opMIB,
                   (outs), (ins GR:$ra, GR:$rb, stride_imm_ext:$imm),
                   !strconcat(OpcStr, "mib.l\t$ra, $rb, $imm"), [], itin>;
}

defm STB : Store<opcode_stbx, opcode_stb, opcode_stbr, misc_opx_stbmia, misc_opx_stbmib, "stb">;
defm STH : Store<opcode_sthx, opcode_sth, opcode_sthr, misc_opx_sthmia, misc_opx_sthmib, "sth">;
defm STW : Store<opcode_stwx, opcode_stw, opcode_stwr, misc_opx_stwmia, misc_opx_stwmib, "stw">;
defm STD : Store<opcode_stdx, opcode_std, opcode_stdr, misc_opx_stdmia, misc_opx_stdmib, "std">;
defm STQ : Store<opcode_stqx, opcode_stq, opcode_stqr, misc_opx_stqmia, misc_opx_stqmib, "stq">;

//===----------------------------------------------------------------------===//
// Store patterns.
//===----------------------------------------------------------------------===//
multiclass
StPatBase<PatFrag StoreOp, InstBase Inst, InstBaseExt instExt, ValueType Ty>
{
  def : Pat<(StoreOp Ty:$ra, (add i64:$rb, simm21:$imm)),
            (Inst    GR:$ra, GR:$rb, simm21:$imm)>;
  def : Pat<(StoreOp Ty:$ra, (add (i64 AddrFI:$rb), simm21:$imm)),
            (Inst    GR:$ra, AddrFI:$rb, simm21:$imm)>;
  def : Pat<(StoreOp Ty:$ra, i64:$rb),
            (Inst    GR:$ra, GR:$rb, 0)>;
  def : Pat<(StoreOp Ty:$ra, (i64 AddrFI:$rb)),
            (Inst    GR:$ra, AddrFI:$rb, 0)>;
  def : Pat<(StoreOp Ty:$ra, (add i64:$rb , simm21_ext:$imm)),
            (instExt GR:$ra, GR:$rb, simm21_ext:$imm)>;
  def : Pat<(StoreOp Ty:$ra, (add (i64 AddrFI:$rb), simm21_ext:$imm)),
            (instExt GR:$ra, AddrFI:$rb, simm21_ext:$imm)>;

  def : Pat<(StoreOp Ty:$ra, (add i64:$rb, (tls_offset_wrapper tglobaltlsaddr:$addr))),
            (Inst    GR:$ra, GR:$rb, tglobaltlsaddr:$addr)>;
  def : Pat<(StoreOp Ty:$ra, (add i64:$rb, (tls_offset_wrapper_ext tglobaltlsaddr:$addr))),
            (instExt GR:$ra, GR:$rb, tglobaltlsaddr:$addr)>;
}

// base+disp for 0 storing
multiclass
StPatZeroBase<PatFrag StoreOp, InstBase Inst, InstBaseExt instExt, ValueType Ty>
{
  def : Pat<(StoreOp (Ty 0), (add i64:$rb, simm21:$imm)),
            (Inst    (Ty gz), GR:$rb, simm21:$imm)>;
  def : Pat<(StoreOp (Ty 0), (add (i64 AddrFI:$rb), simm21:$imm)),
            (Inst    (Ty gz), AddrFI:$rb, simm21:$imm)>;
  def : Pat<(StoreOp (Ty 0), i64:$rb),
            (Inst    (Ty gz), GR:$rb, 0)>;
  def : Pat<(StoreOp (Ty 0), (i64 AddrFI:$rb)),
            (Inst    (Ty gz), AddrFI:$rb, 0)>;
  def : Pat<(StoreOp (Ty 0), (add i64:$rb , simm21_ext:$imm)),
            (instExt (Ty gz), GR:$rb, simm21_ext:$imm)>;
  def : Pat<(StoreOp (Ty 0), (add (i64 AddrFI:$rb), simm21_ext:$imm)),
            (instExt (Ty gz), AddrFI:$rb, simm21_ext:$imm)>;

  def : Pat<(StoreOp (Ty 0), (add i64:$rb, (tls_offset_wrapper tglobaltlsaddr:$addr))),
            (Inst    (Ty gz), GR:$rb, tglobaltlsaddr:$addr)>;
  def : Pat<(StoreOp (Ty 0), (add i64:$rb, (tls_offset_wrapper_ext tglobaltlsaddr:$addr))),
            (instExt (Ty gz), GR:$rb, tglobaltlsaddr:$addr)>;
}

multiclass
StPatPCRel<PatFrag StoreOp, InstBase Inst, InstBaseExt Inst_ext, ValueType Ty>
{
  // global/external address should be properly wrapped
  // into corresponding PCREL wrapper (_ext or nothing)
  def : Pat<(StoreOp Ty:$ra, (pcrel_data_wrapper tglobaladdr:$addr)),
            (Inst GR:$ra, tglobaladdr:$addr)>;
  def : Pat<(StoreOp Ty:$ra, (pcrel_data_wrapper tconstpool:$addr)),
            (Inst GR:$ra, tconstpool:$addr)>;
  def : Pat<(StoreOp Ty:$ra, (pcrel_data_wrapper texternalsym:$addr)),
            (Inst GR:$ra, texternalsym:$addr)>;

  def : Pat<(StoreOp Ty:$ra, (pcrel_data_wrapper_ext tglobaladdr:$addr)),
            (Inst_ext GR:$ra, tglobaladdr:$addr)>;
  def : Pat<(StoreOp Ty:$ra, (pcrel_data_wrapper_ext tconstpool:$addr)),
            (Inst_ext GR:$ra, tconstpool:$addr)>;
  def : Pat<(StoreOp Ty:$ra, (pcrel_data_wrapper_ext texternalsym:$addr)),
            (Inst_ext GR:$ra, texternalsym:$addr)>;
}

// ip+fwdrel for 0 storing
multiclass
StPatZeroPCRel<PatFrag StoreOp, InstBase Inst, InstBaseExt Inst_ext, ValueType Ty>
{
  // global/external address should be properly wrapped
  // into corresponding PCREL wrapper (_ext or nothing)
  def : Pat<(StoreOp (Ty 0), (pcrel_data_wrapper tglobaladdr:$addr)),
            (Inst (Ty gz), tglobaladdr:$addr)>;
  def : Pat<(StoreOp (Ty 0), (pcrel_data_wrapper tconstpool:$addr)),
            (Inst (Ty gz), tconstpool:$addr)>;
  def : Pat<(StoreOp (Ty 0), (pcrel_data_wrapper texternalsym:$addr)),
            (Inst (Ty gz), texternalsym:$addr)>;

  def : Pat<(StoreOp (Ty 0), (pcrel_data_wrapper_ext tglobaladdr:$addr)),
            (Inst_ext (Ty gz), tglobaladdr:$addr)>;
  def : Pat<(StoreOp (Ty 0), (pcrel_data_wrapper_ext tconstpool:$addr)),
            (Inst_ext (Ty gz), tconstpool:$addr)>;
  def : Pat<(StoreOp (Ty 0), (pcrel_data_wrapper_ext texternalsym:$addr)),
            (Inst_ext (Ty gz), texternalsym:$addr)>;
}

multiclass
StPatIndexed_i32<PatFrag StoreOp, PatFrag IndexOp,
                 InstBase Inst, InstBaseExt InstExt, ValueType Ty, ValueType IndexTy>
{
  // base + scaled_index + disp
  def : Pat<(StoreOp Ty:$ra,
            (INDEXED_BSID i64:$rb, (IndexOp IndexTy:$rc), scale:$scale, indexed_disp:$imm)),
            (Inst GR:$ra, GR:$rb, GR:$rc, scale:$scale, indexed_disp:$imm)>;
  def : Pat<(StoreOp Ty:$ra,
            (INDEXED_BSID i64:$rb, (IndexOp IndexTy:$rc), scale:$scale, indexed_disp_ext:$imm)),
            (InstExt GR:$ra, GR:$rb, GR:$rc, scale:$scale, indexed_disp_ext:$imm)>;
  // base + index + disp
  def : Pat<(StoreOp Ty:$ra,
            (INDEXED_BID i64:$rb, (IndexOp IndexTy:$rc), indexed_disp:$imm)),
            (Inst GR:$ra, GR:$rb, GR:$rc, 0, indexed_disp:$imm)>;
  def : Pat<(StoreOp Ty:$ra,
            (INDEXED_BID i64:$rb, (IndexOp IndexTy:$rc), indexed_disp_ext:$imm)),
            (InstExt GR:$ra, GR:$rb, GR:$rc, 0, indexed_disp_ext:$imm)>;
  // base + scaled_index (no extended variant)
  def : Pat<(StoreOp Ty:$ra,
            (INDEXED_BSI i64:$rb, (IndexOp IndexTy:$rc), scale:$scale)),
            (Inst GR:$ra, GR:$rb, GR:$rc, scale:$scale, 0)>;
  // base + index (no extended variant)
  def : Pat<(StoreOp Ty:$ra,
            (INDEXED_BI i64:$rb, (IndexOp IndexTy:$rc))),
            (Inst GR:$ra, GR:$rb, GR:$rc, 0, 0)>;
}

// base + scaled index + offset for 0 storing
multiclass
StPatZeroIndexed_i32<PatFrag StoreOp, PatFrag IndexOp,
                 InstBase Inst, InstBaseExt InstExt, ValueType Ty, ValueType IndexTy>
{
  // base + scaled_index + disp
  def : Pat<(StoreOp (Ty 0),
            (INDEXED_BSID i64:$rb, (IndexOp IndexTy:$rc), scale:$scale, indexed_disp:$imm)),
            (Inst (Ty gz), GR:$rb, GR:$rc, scale:$scale, indexed_disp:$imm)>;
  def : Pat<(StoreOp (Ty 0),
            (INDEXED_BSID i64:$rb, (IndexOp IndexTy:$rc), scale:$scale, indexed_disp_ext:$imm)),
            (InstExt (Ty gz), GR:$rb, GR:$rc, scale:$scale, indexed_disp_ext:$imm)>;
  // base + index + disp
  def : Pat<(StoreOp (Ty 0),
            (INDEXED_BID i64:$rb, (IndexOp IndexTy:$rc), indexed_disp:$imm)),
            (Inst (Ty gz), GR:$rb, GR:$rc, 0, indexed_disp:$imm)>;
  def : Pat<(StoreOp (Ty 0),
            (INDEXED_BID i64:$rb, (IndexOp IndexTy:$rc), indexed_disp_ext:$imm)),
            (InstExt (Ty gz), GR:$rb, GR:$rc, 0, indexed_disp_ext:$imm)>;
  // base + scaled_index (no extended variant)
  def : Pat<(StoreOp (Ty 0),
            (INDEXED_BSI i64:$rb, (IndexOp IndexTy:$rc), scale:$scale)),
            (Inst (Ty gz), GR:$rb, GR:$rc, scale:$scale, 0)>;
  // base + index (no extended variant)
  def : Pat<(StoreOp (Ty 0),
            (INDEXED_BI i64:$rb, (IndexOp IndexTy:$rc))),
            (Inst (Ty gz), GR:$rb, GR:$rc, 0, 0)>;
}

multiclass
StPatIndexed_i64<PatFrag StoreOp, InstBase Inst, InstBaseExt InstExt, ValueType Ty>
{
  // base + scaled_index + disp
  def : Pat<(StoreOp Ty:$ra,
            (INDEXED_BSID i64:$rb, i64:$rc, scale:$scale, indexed_disp:$imm)),
            (Inst GR:$ra, GR:$rb, GR:$rc, scale:$scale, indexed_disp:$imm)>;
  def : Pat<(StoreOp Ty:$ra,
            (INDEXED_BSID i64:$rb, i64:$rc, scale:$scale, indexed_disp_ext:$imm)),
            (InstExt GR:$ra, GR:$rb, GR:$rc, scale:$scale, indexed_disp_ext:$imm)>;
  // base + index + disp
  def : Pat<(StoreOp Ty:$ra,
            (INDEXED_BID i64:$rb, i64:$rc, indexed_disp:$imm)),
            (Inst GR:$ra, GR:$rb, GR:$rc, 0, indexed_disp:$imm)>;
  def : Pat<(StoreOp Ty:$ra,
            (INDEXED_BID i64:$rb, i64:$rc, indexed_disp_ext:$imm)),
            (InstExt GR:$ra, GR:$rb, GR:$rc, 0, indexed_disp_ext:$imm)>;
  // base + scaled_index (no extended variant)
  def : Pat<(StoreOp Ty:$ra,
            (INDEXED_BSI i64:$rb, i64:$rc, scale:$scale)),
            (Inst GR:$ra, GR:$rb, GR:$rc, scale:$scale, 0)>;
  // base + index (no extended variant)
  def : Pat<(StoreOp Ty:$ra,
            (INDEXED_BI i64:$rb, i64:$rc)),
            (Inst GR:$ra, GR:$rb, GR:$rc, 0, 0)>;
}

// base + scaled index + offset for 0 storing
multiclass
StPatZeroIndexed_i64<PatFrag StoreOp, InstBase Inst, InstBaseExt InstExt, ValueType Ty>
{
  // base + scaled_index + disp
  def : Pat<(StoreOp (Ty 0),
            (INDEXED_BSID i64:$rb, i64:$rc, scale:$scale, indexed_disp:$imm)),
            (Inst (Ty gz), GR:$rb, GR:$rc, scale:$scale, indexed_disp:$imm)>;
  def : Pat<(StoreOp (Ty 0),
            (INDEXED_BSID i64:$rb, i64:$rc, scale:$scale, indexed_disp_ext:$imm)),
            (InstExt (Ty gz), GR:$rb, GR:$rc, scale:$scale, indexed_disp_ext:$imm)>;
  // base + index + disp
  def : Pat<(StoreOp (Ty 0),
            (INDEXED_BID i64:$rb, i64:$rc, indexed_disp:$imm)),
            (Inst (Ty gz), GR:$rb, GR:$rc, 0, indexed_disp:$imm)>;
  def : Pat<(StoreOp (Ty 0),
            (INDEXED_BID i64:$rb, i64:$rc, indexed_disp_ext:$imm)),
            (InstExt (Ty gz), GR:$rb, GR:$rc, 0, indexed_disp_ext:$imm)>;
  // base + scaled_index (no extended variant)
  def : Pat<(StoreOp (Ty 0),
            (INDEXED_BSI i64:$rb, i64:$rc, scale:$scale)),
            (Inst (Ty gz), GR:$rb, GR:$rc, scale:$scale, 0)>;
  // base + index (no extended variant)
  def : Pat<(StoreOp (Ty 0),
            (INDEXED_BI i64:$rb, i64:$rc)),
            (Inst (Ty gz), GR:$rb, GR:$rc, 0, 0)>;
}


multiclass
StPat<string INSTNAME, PatFrag StoreOp, ValueType Ty>
{
  defm : StPatBase<StoreOp,
           !cast<InstBase>(INSTNAME # "ri"),
           !cast<InstBaseExt>(INSTNAME # "ri_ext"), Ty>;
  defm : StPatPCRel<StoreOp,
           !cast<InstBase>(INSTNAME # "rc"),
           !cast<InstBaseExt>(INSTNAME # "rc_ext"), Ty>;
  defm : StPatIndexed_i64<StoreOp,
           !cast<InstBase>(INSTNAME # "rr_s64"),
           !cast<InstBaseExt>(INSTNAME # "rr_s64_ext"), Ty>;
  defm : StPatIndexed_i32<StoreOp, indexed_i32_sext,
           !cast<InstBase>(INSTNAME # "rr_s32"),
           !cast<InstBaseExt>(INSTNAME # "rr_s32_ext"), Ty, i32>;
  defm : StPatIndexed_i32<StoreOp, indexed_i32_zext,
           !cast<InstBase>(INSTNAME # "rr_u32"),
           !cast<InstBaseExt>(INSTNAME # "rr_u32_ext"), Ty, i32>;
  defm : StPatIndexed_i32<StoreOp, indexed_i64_sext,
           !cast<InstBase>(INSTNAME # "rr_s32"),
           !cast<InstBaseExt>(INSTNAME # "rr_s32_ext"), Ty, i64>;
  defm : StPatIndexed_i32<StoreOp, indexed_i64_zext,
           !cast<InstBase>(INSTNAME # "rr_u32"),
           !cast<InstBaseExt>(INSTNAME # "rr_u32_ext"), Ty, i64>;
  defm : StPatIndexed_i32<StoreOp, indexed_i64_trunc,
           !cast<InstBase>(INSTNAME # "rr_u32"),
           !cast<InstBaseExt>(INSTNAME # "rr_u32_ext"), Ty, i64>;
}

multiclass
StPatZero<string INSTNAME, PatFrag StoreOp, ValueType Ty>
{
  defm : StPatZeroBase<StoreOp,
           !cast<InstBase>(INSTNAME # "ri"),
           !cast<InstBaseExt>(INSTNAME # "ri_ext"), Ty>;
  defm : StPatZeroPCRel<StoreOp,
           !cast<InstBase>(INSTNAME # "rc"),
           !cast<InstBaseExt>(INSTNAME # "rc_ext"), Ty>;
  defm : StPatZeroIndexed_i64<StoreOp,
           !cast<InstBase>(INSTNAME # "rr_s64"),
           !cast<InstBaseExt>(INSTNAME # "rr_s64_ext"), Ty>;
  defm : StPatZeroIndexed_i32<StoreOp, indexed_i32_sext,
           !cast<InstBase>(INSTNAME # "rr_s32"),
           !cast<InstBaseExt>(INSTNAME # "rr_s32_ext"), Ty, i32>;
  defm : StPatZeroIndexed_i32<StoreOp, indexed_i32_zext,
           !cast<InstBase>(INSTNAME # "rr_u32"),
           !cast<InstBaseExt>(INSTNAME # "rr_u32_ext"), Ty, i32>;
  defm : StPatZeroIndexed_i32<StoreOp, indexed_i64_sext,
           !cast<InstBase>(INSTNAME # "rr_s32"),
           !cast<InstBaseExt>(INSTNAME # "rr_s32_ext"), Ty, i64>;
  defm : StPatZeroIndexed_i32<StoreOp, indexed_i64_zext,
           !cast<InstBase>(INSTNAME # "rr_u32"),
           !cast<InstBaseExt>(INSTNAME # "rr_u32_ext"), Ty, i64>;
  defm : StPatZeroIndexed_i32<StoreOp, indexed_i64_trunc,
           !cast<InstBase>(INSTNAME # "rr_u32"),
           !cast<InstBaseExt>(INSTNAME # "rr_u32_ext"), Ty, i64>;
}

// TODO: patterns for stXmia/stXmib

defm : StPat<"STB", store,         i1>;
defm : StPat<"STB", truncstorei8,  i32>;
defm : StPat<"STB", truncstorei8,  i64>;
defm : StPat<"STH", truncstorei16, i1>;
defm : StPat<"STH", truncstorei16, i32>;
defm : StPat<"STH", truncstorei16, i64>;
defm : StPat<"STW", store,         i32>;
defm : StPat<"STW", truncstorei32, i64>;
defm : StPat<"STD", store,         i64>;
defm : StPat<"STQ", store,         i128>;

defm : StPatZero<"STB", store,         i1>;
defm : StPatZero<"STB", truncstorei8,  i32>;
defm : StPatZero<"STB", truncstorei8,  i64>;
defm : StPatZero<"STH", truncstorei16, i1>;
defm : StPatZero<"STH", truncstorei16, i32>;
defm : StPatZero<"STH", truncstorei16, i64>;
defm : StPatZero<"STW", store,         i32>;
defm : StPatZero<"STW", truncstorei32, i64>;
defm : StPatZero<"STD", store,         i64>;
defm : StPatZero<"STQ", store,         i128>;

//===----------------------------------------------------------------------===//
// LDAX patterns (sign/zero extend, etc)
// FIXME: there is no identity PatFrag, so i64 index patterns are duplicated
//===----------------------------------------------------------------------===//
multiclass
LdaxPatIndexed_i32<PatFrag IndexOp, InstBase Inst, InstBaseExt instExt, ValueType IndexTy>
{
  // base + scaled_index + disp
  def : Pat<(INDEXED_BSID i64:$rb, (IndexOp IndexTy:$rc), scale:$scale, indexed_disp:$imm),
            (Inst GR:$rb, GR:$rc, scale:$scale, indexed_disp:$imm)>;
  def : Pat<(INDEXED_BSID i64:$rb, (IndexOp IndexTy:$rc), scale:$scale, indexed_disp_ext:$imm),
            (instExt GR:$rb, GR:$rc, scale:$scale, indexed_disp_ext:$imm)>;

  // base + index + disp
  def : Pat<(INDEXED_BID i64:$rb, (IndexOp IndexTy:$rc), indexed_disp:$imm),
            (Inst GR:$rb, GR:$rc, 0, indexed_disp:$imm)>;
  def : Pat<(INDEXED_BID i64:$rb, (IndexOp IndexTy:$rc), indexed_disp_ext:$imm),
            (instExt GR:$rb, GR:$rc, 0, indexed_disp_ext:$imm)>;

  // base + scaled_index (no extended variant)
  def : Pat<(INDEXED_BSI i64:$rb, (IndexOp IndexTy:$rc), scale:$scale),
            (Inst GR:$rb, GR:$rc, scale:$scale, 0)>;

  // base + index (no extended variant)
  def : Pat<(INDEXED_BI i64:$rb, (IndexOp IndexTy:$rc)),
            (Inst GR:$rb, GR:$rc, 0, 0)>;
}

multiclass
LdaxPatIndexed_i64<InstBase Inst, InstBaseExt instExt>
{
  // base + scaled_index + disp
  def : Pat<(INDEXED_BSID i64:$rb, i64:$rc, scale:$scale, indexed_disp:$imm),
            (Inst GR:$rb, GR:$rc, scale:$scale, indexed_disp:$imm)>;
  def : Pat<(INDEXED_BSID i64:$rb, i64:$rc, scale:$scale, indexed_disp_ext:$imm),
            (instExt GR:$rb, GR:$rc, scale:$scale, indexed_disp_ext:$imm)>;

  // base + index + disp
  def : Pat<(INDEXED_BID i64:$rb, i64:$rc, indexed_disp:$imm),
            (Inst GR:$rb, GR:$rc, 0, indexed_disp:$imm)>;
  def : Pat<(INDEXED_BID i64:$rb, i64:$rc, indexed_disp_ext:$imm),
            (instExt GR:$rb, GR:$rc, 0, indexed_disp_ext:$imm)>;

  // base + scaled_index (no extended variant)
  def : Pat<(INDEXED_BSI i64:$rb, i64:$rc, scale:$scale),
            (Inst GR:$rb, GR:$rc, scale:$scale, 0)>;

  // base + index (no extended variant)
  def : Pat<(INDEXED_BI i64:$rb, i64:$rc),
            (Inst GR:$rb, GR:$rc, 0, 0)>;
}

multiclass
LdaxPat<string INSTNAME>
{
  defm : LdaxPatIndexed_i64<
           !cast<InstBase>(INSTNAME # "rr_s64"),
           !cast<InstBaseExt>(INSTNAME # "rr_s64_ext")>;

  defm : LdaxPatIndexed_i32< indexed_i32_sext,
           !cast<InstBase>(INSTNAME # "rr_s32"),
           !cast<InstBaseExt>(INSTNAME # "rr_s32_ext"), i32>;
  defm : LdaxPatIndexed_i32< indexed_i32_zext,
           !cast<InstBase>(INSTNAME # "rr_u32"),
           !cast<InstBaseExt>(INSTNAME # "rr_u32_ext"), i32>;
  defm : LdaxPatIndexed_i32< indexed_i64_sext,
           !cast<InstBase>(INSTNAME # "rr_s32"),
           !cast<InstBaseExt>(INSTNAME # "rr_s32_ext"), i64>;
  defm : LdaxPatIndexed_i32< indexed_i64_zext,
           !cast<InstBase>(INSTNAME # "rr_u32"),
           !cast<InstBaseExt>(INSTNAME # "rr_u32_ext"), i64>;
  defm : LdaxPatIndexed_i32< indexed_i64_trunc,
           !cast<InstBase>(INSTNAME # "rr_u32"),
           !cast<InstBaseExt>(INSTNAME # "rr_u32_ext"), i64>;
}

defm LDAX : LoadIndexed<opcode_ldax,  "ldax">;
defm : LdaxPat<"LDAX">;
