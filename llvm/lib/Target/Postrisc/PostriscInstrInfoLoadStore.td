//===-- PostriscInstrInfoLoadStore.td - Target Description for Postrisc ---===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file describes the Postrisc load/store instructions.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// simm7(49) immediate (indexed_disp)
//===----------------------------------------------------------------------===//
def indexed_disp_xform : SDNodeXForm<imm, [{
  return getI64Imm(N->getSExtValue(), SDLoc(N));
}]>;
def indexed_disp : Operand<i64>, IntImmLeaf<i64, [{ return isSextInt(Imm, 7); }], indexed_disp_xform> {
  let DecoderMethod = "DecodeSIMM<7>";
}

// simm49 extended (7+42) immediate (indexed_disp_ext)
def indexed_disp_ext_xform : SDNodeXForm<imm, [{
  return getI64Imm(N->getSExtValue(), SDLoc(N));
}]>;
def indexed_disp_ext : Operand<i64>, IntImmLeaf<i64, [{ return isSextInt(Imm, 42+7); }], indexed_disp_ext_xform> {
  let DecoderMethod = "DecodeSIMM<42+7>";
}

//===----------------------------------------------------------------------===//
// load instructions (base+dsip, ip+disp, pre/post update)
//===----------------------------------------------------------------------===//
multiclass Load<opcode_opx opRI, opcode_opx opRC, misc_opx opMIA, misc_opx opMIB, InstrItinClass itin = IIC_iu_instr>
{
  // base + displacement
  let mayLoad = 1 in
  def NAME : PRIMARY_RabI21<opRI, (outs GR:$ra), (ins GR:$rb, simm21:$imm),
        !strconcat(opRI.mnem, "\t$ra, $rb, $imm"), [], itin>;

  // base + displacement extended
  let mayLoad = 1, AddedComplexity = 3 in
  def NAME # _EXT  : PRIMARY_RabI21_ext<opRI, (outs GR:$ra), (ins GR:$rb, simm21_ext:$imm),
        !strconcat(opRI.mnem, ".l\t$ra, $rb, $imm"), [], itin>;

  // ip + forward displacement
  let mayLoad = 1 in
  def NAME # R : PRIMARY_RaI28<opRC, (outs GR:$ra), (ins uimm28:$imm),
        !strconcat(opRC.mnem, "\t$ra, $imm"), [], itin>;

  // ip + forward displacement extended
  let mayLoad = 1, AddedComplexity = 3 in
  def NAME # R_EXT : PRIMARY_RaI28_ext<opRC, (outs GR:$ra), (ins uimm28_ext:$imm),
        !strconcat(opRC.mnem, ".l\t$ra, $imm"), [], itin>;

  // base with base post-update immediate
  let mayLoad = 1, isPostIncrement = 1, Constraints = "$rx = $rb" in
  def NAME # MIA : MISC_RabI10<opMIA, (outs GR:$ra, GR:$rx), (ins GR:$rb, stride_imm:$imm),
        !strconcat(opMIA.mnem, "\t$ra, $rb, $imm"), [], itin>;

  // base with base post-update immediate (extended)
  let mayLoad = 1, AddedComplexity = 3, isPostIncrement = 1, Constraints = "$rx = $rb" in
  def NAME # MIA_EXT : MISC_RabI10_ext<opMIA, (outs GR:$ra, GR:$rx), (ins GR:$rb, stride_imm_ext:$imm),
        !strconcat(opMIA.mnem, ".l\t$ra, $rb, $imm"), [], itin>;

  // base with base pre-update immediate
  let mayLoad = 1, isPreIncrement = 1, Constraints = "$rx = $rb" in
  def NAME # MIB : MISC_RabI10<opMIB, (outs GR:$ra, GR:$rx), (ins GR:$rb, stride_imm:$imm),
        !strconcat(opMIB.mnem, "\t$ra, $rb, $imm"), [], itin>;

  // base with base pre-update immediate (extended)
  let mayLoad = 1, AddedComplexity = 3, isPreIncrement = 1, Constraints = "$rx = $rb" in
  def NAME # MIB_EXT : MISC_RabI10_ext<opMIB, (outs GR:$ra, GR:$rx), (ins GR:$rb, stride_imm_ext:$imm),
        !strconcat(opMIB.mnem, ".l\t$ra, $rb, $imm"), [], itin>;
}

defm LDBZ : Load<opcode_ldz_b, opcode_ldz_b_r, misc_opx_ldz_b_mia, misc_opx_ldz_b_mib>;
defm LDBS : Load<opcode_lds_b, opcode_lds_b_r, misc_opx_lds_b_mia, misc_opx_lds_b_mib>;
defm LDHZ : Load<opcode_ldz_h, opcode_ldz_h_r, misc_opx_ldz_h_mia, misc_opx_ldz_h_mib>;
defm LDHS : Load<opcode_lds_h, opcode_lds_h_r, misc_opx_lds_h_mia, misc_opx_lds_h_mib>;
defm LDWZ : Load<opcode_ldz_w, opcode_ldz_w_r, misc_opx_ldz_w_mia, misc_opx_ldz_w_mib>;
defm LDWS : Load<opcode_lds_w, opcode_lds_w_r, misc_opx_lds_w_mia, misc_opx_lds_w_mib>;
defm LDDZ : Load<opcode_ldz_d, opcode_ldz_d_r, misc_opx_ldz_d_mia, misc_opx_ldz_d_mib>;
defm LDDS : Load<opcode_lds_d, opcode_lds_d_r, misc_opx_lds_d_mia, misc_opx_lds_d_mib>;
defm LDQ  : Load<opcode_ld_q,  opcode_ld_q_r,  misc_opx_ld_q_mia,  misc_opx_ld_q_mib>;

//===----------------------------------------------------------------------===//
// load instructions (indexed and LDAX)
//===----------------------------------------------------------------------===//
multiclass LoadIndexed<indexed_ds_opx OpcDS, indexed_ws_opx OpcWS, indexed_wz_opx OpcWZ, InstrItinClass itin = IIC_iu_instr>
{
  // base + scaled 64-bit index + displacement
  let mayLoad = 1, isIndexedMemAccess = 1 in
  def XD : PRIMARY_Indexed_DS<OpcDS,
        (outs GR:$ra), (ins GR:$rb, GR:$rc, scale:$scale, indexed_disp:$imm),
        !strconcat(OpcDS.mnem, "\t$ra, $rb, $rc, $scale, $imm"), [], itin>;

  // base + scaled 64-bit index + displacement extended
  let mayLoad = 1, isIndexedMemAccess = 1, AddedComplexity = 3 in
  def XD_EXT : PRIMARY_Indexed_DS_Long<OpcDS,
        (outs GR:$ra), (ins GR:$rb, GR:$rc, scale:$scale, indexed_disp_ext:$imm),
        !strconcat(OpcDS.mnem, ".l\t$ra, $rb, $rc, $scale, $imm"), [], itin>;

  // base + scaled signed 32-bit index + displacement
  let mayLoad = 1, isIndexedMemAccess = 1 in
  def XWS : PRIMARY_Indexed_WS<OpcWS,
        (outs GR:$ra), (ins GR:$rb, GR:$rc, scale:$scale, indexed_disp:$imm),
        !strconcat(OpcWS.mnem, "\t$ra, $rb, $rc, $scale, $imm"), [], itin>;

  // base + scaled signed 32-bit index + displacement extended
  let mayLoad = 1, isIndexedMemAccess = 1, AddedComplexity = 3 in
  def XWS_EXT : PRIMARY_Indexed_WS_Long<OpcWS,
        (outs GR:$ra), (ins GR:$rb, GR:$rc, scale:$scale, indexed_disp_ext:$imm),
        !strconcat(OpcWS.mnem, ".l\t$ra, $rb, $rc, $scale, $imm"), [], itin>;

  // base + scaled unsigned 32-bit index + displacement
  let mayLoad = 1, isIndexedMemAccess = 1 in
  def XWZ : PRIMARY_Indexed_WZ<OpcWZ,
        (outs GR:$ra), (ins GR:$rb, GR:$rc, scale:$scale, indexed_disp:$imm),
        !strconcat(OpcWZ.mnem, "\t$ra, $rb, $rc, $scale, $imm"), [], itin>;

  // base + scaled unsigned 32-bit index + displacement extended
  let mayLoad = 1, isIndexedMemAccess = 1, AddedComplexity = 3 in
  def XWZ_EXT : PRIMARY_Indexed_WZ_Long<OpcWZ,
        (outs GR:$ra), (ins GR:$rb, GR:$rc, scale:$scale, indexed_disp_ext:$imm),
        !strconcat(OpcWZ.mnem, ".l\t$ra, $rb, $rc, $scale, $imm"), [], itin>;
}

defm LDBZ : LoadIndexed<indexed_ds_opx_ldz_b_xds, indexed_ws_opx_ldz_b_xws, indexed_wz_opx_ldz_b_xwz>;
defm LDBS : LoadIndexed<indexed_ds_opx_lds_b_xds, indexed_ws_opx_lds_b_xws, indexed_wz_opx_lds_b_xwz>;
defm LDHZ : LoadIndexed<indexed_ds_opx_ldz_h_xds, indexed_ws_opx_ldz_h_xws, indexed_wz_opx_ldz_h_xwz>;
defm LDHS : LoadIndexed<indexed_ds_opx_lds_h_xds, indexed_ws_opx_lds_h_xws, indexed_wz_opx_lds_h_xwz>;
defm LDWZ : LoadIndexed<indexed_ds_opx_ldz_w_xds, indexed_ws_opx_ldz_w_xws, indexed_wz_opx_ldz_w_xwz>;
defm LDWS : LoadIndexed<indexed_ds_opx_lds_w_xds, indexed_ws_opx_lds_w_xws, indexed_wz_opx_lds_w_xwz>;
defm LDDZ : LoadIndexed<indexed_ds_opx_ldz_d_xds, indexed_ws_opx_ldz_d_xws, indexed_wz_opx_ldz_d_xwz>;
defm LDDS : LoadIndexed<indexed_ds_opx_lds_d_xds, indexed_ws_opx_lds_d_xws, indexed_wz_opx_lds_d_xwz>;
defm LDQ  : LoadIndexed<indexed_ds_opx_ld_q_xds,  indexed_ws_opx_ld_q_xws,  indexed_wz_opx_ld_q_xwz>;

//===----------------------------------------------------------------------===//
// Load patterns.
//===----------------------------------------------------------------------===//
multiclass LdPatBase<PatFrag LoadOp, InstBase Inst, InstBaseExt InstExt, ValueType Ty>
{
  def : Pat<(Ty (LoadOp (add    i64:$rb, simm21:$imm))), (Inst     GR:$rb, simm21:$imm)>;
  def : Pat<(Ty (LoadOp (add AddrFI:$rb, simm21:$imm))), (Inst AddrFI:$rb, simm21:$imm)>;
  def : Pat<(Ty (LoadOp    i64:$rb)), (Inst     GR:$rb, 0)>;
  def : Pat<(Ty (LoadOp AddrFI:$rb)), (Inst AddrFI:$rb, 0)>;
  def : Pat<(Ty (LoadOp (add    i64:$rb, simm21_ext:$imm))), (InstExt     GR:$rb, simm21_ext:$imm)>;
  def : Pat<(Ty (LoadOp (add AddrFI:$rb, simm21_ext:$imm))), (InstExt AddrFI:$rb, simm21_ext:$imm)>;
  def : Pat<(Ty (LoadOp (add i64:$rb, (tls_offset_wrapper     tglobaltlsaddr:$addr)))), (Inst    GR:$rb, tglobaltlsaddr:$addr)>;
  def : Pat<(Ty (LoadOp (add i64:$rb, (tls_offset_wrapper_ext tglobaltlsaddr:$addr)))), (InstExt GR:$rb, tglobaltlsaddr:$addr)>;
}

multiclass LdPatPCRel<PatFrag LoadOp, InstBase Inst, InstBaseExt Inst_ext, ValueType Ty>
{
  // global/external address should be properly wrapped into corresponding PCREL wrapper
  def : Pat<(Ty (LoadOp (pcrel_data_wrapper    tglobaladdr:$addr))), (Inst    tglobaladdr:$addr)>;
  def : Pat<(Ty (LoadOp (pcrel_data_wrapper     tconstpool:$addr))), (Inst     tconstpool:$addr)>;
  def : Pat<(Ty (LoadOp (pcrel_data_wrapper   texternalsym:$addr))), (Inst   texternalsym:$addr)>;
  def : Pat<(Ty (LoadOp (pcrel_data_wrapper tglobaltlsaddr:$addr))), (Inst tglobaltlsaddr:$addr)>;
  def : Pat<(Ty (LoadOp (pcrel_data_wrapper     tjumptable:$addr))), (Inst     tjumptable:$addr)>;

  def : Pat<(Ty (LoadOp (pcrel_data_wrapper_ext    tglobaladdr:$addr))), (Inst_ext    tglobaladdr:$addr)>;
  def : Pat<(Ty (LoadOp (pcrel_data_wrapper_ext     tconstpool:$addr))), (Inst_ext     tconstpool:$addr)>;
  def : Pat<(Ty (LoadOp (pcrel_data_wrapper_ext   texternalsym:$addr))), (Inst_ext   texternalsym:$addr)>;
  def : Pat<(Ty (LoadOp (pcrel_data_wrapper_ext tglobaltlsaddr:$addr))), (Inst_ext tglobaltlsaddr:$addr)>;
  def : Pat<(Ty (LoadOp (pcrel_data_wrapper_ext     tjumptable:$addr))), (Inst_ext     tjumptable:$addr)>;
}

//===----------------------------------------------------------------------===//
// Indexed addressing patterns.
//===----------------------------------------------------------------------===//

// base + scaled_index + disp
def INDEXED_BSID : PatFrag<(ops node:$base, node:$index, node:$scale, node:$offset), (add (add node:$base, (shl node:$index, node:$scale)), node:$offset)>;
// base + index + disp (no scale)
def INDEXED_BID : PatFrag<(ops node:$base, node:$index, node:$offset), (add (add node:$base, node:$index), node:$offset)>;
// base + scaled_index (no disp)
def INDEXED_BSI : PatFrag<(ops node:$base, node:$index, node:$scale), (add node:$base, (shl node:$index, node:$scale))>;
// base + index (no dips, no scale)
def INDEXED_BI : PatFrag<(ops node:$base, node:$index), (add node:$base, node:$index)>;

//===----------------------------------------------------------------------===//
// Indexed index patterns (sign/zero extend, etc)
// TODO: there is no identity PatFrag, so i64 index patterns are duplicated
//===----------------------------------------------------------------------===//
def indexed_i32_sext  : PatFrag<(ops node:$index), (i64 (sext node:$index))>;
def indexed_i32_zext  : PatFrag<(ops node:$index), (i64 (zext node:$index))>;
def indexed_i64_sext  : PatFrag<(ops node:$index), (sext_inreg node:$index, i32)>;
def indexed_i64_zext  : PatFrag<(ops node:$index), (i64 (zext (i32 (trunc node:$index))))>;
def indexed_i64_trunc : PatFrag<(ops node:$index), (i64 (and node:$index, (i64 0xFFFFFFFF)))>;

def indexed_disp_i32     : PatLeaf<(imm), [{ return isSextInt(N->getAPIntValue(), 9); }]>;
def indexed_disp_i32_ext : PatLeaf<(imm), [{ return isSextInt(N->getAPIntValue(), 32); }]>;

multiclass LdPatIndexed_i32<PatFrag LoadOp, InstBase Inst, InstBaseExt InstExt, ValueType Ty, ValueType IndexTy, PatFrag IndexOp>
{
  // base + scaled_index + disp
  def : Pat<(Ty (LoadOp (INDEXED_BSID i64:$rb, (IndexOp IndexTy:$rc), scale:$scale, indexed_disp    :$imm))), (Inst    GR:$rb, GR:$rc, scale:$scale, indexed_disp    :$imm)>;
  def : Pat<(Ty (LoadOp (INDEXED_BSID i64:$rb, (IndexOp IndexTy:$rc), scale:$scale, indexed_disp_ext:$imm))), (InstExt GR:$rb, GR:$rc, scale:$scale, indexed_disp_ext:$imm)>;

  // base + index + disp
  def : Pat<(Ty (LoadOp (INDEXED_BID i64:$rb, (IndexOp IndexTy:$rc), indexed_disp    :$imm))), (Inst    GR:$rb, GR:$rc, 0, indexed_disp    :$imm)>;
  def : Pat<(Ty (LoadOp (INDEXED_BID i64:$rb, (IndexOp IndexTy:$rc), indexed_disp_ext:$imm))), (InstExt GR:$rb, GR:$rc, 0, indexed_disp_ext:$imm)>;

  // base + scaled_index (no extended variant)
  def : Pat<(Ty (LoadOp (INDEXED_BSI i64:$rb, (IndexOp IndexTy:$rc), scale:$scale))), (Inst GR:$rb, GR:$rc, scale:$scale, 0)>;

  // base + index (no extended variant)
  def : Pat<(Ty (LoadOp (INDEXED_BI i64:$rb, (IndexOp IndexTy:$rc)))), (Inst GR:$rb, GR:$rc, 0, 0)>;

  // FIXME: allow shift/add before IndexOp because int overflow is UB
  def : Pat<(Ty (LoadOp (INDEXED_BID i64:$rb, (IndexOp (shl IndexTy:$rc, scale:$scale)), indexed_disp    :$imm))), (Inst    GR:$rb, GR:$rc, scale:$scale, indexed_disp    :$imm)>;
  def : Pat<(Ty (LoadOp (INDEXED_BID i64:$rb, (IndexOp (shl IndexTy:$rc, scale:$scale)), indexed_disp_ext:$imm))), (InstExt GR:$rb, GR:$rc, scale:$scale, indexed_disp_ext:$imm)>;
  def : Pat<(Ty (LoadOp (INDEXED_BI  i64:$rb, (IndexOp (add (shl IndexTy:$rc, scale:$scale), indexed_disp_i32    :$imm))))), (Inst    GR:$rb, GR:$rc, scale:$scale, (cvt64 $imm))>;
  def : Pat<(Ty (LoadOp (INDEXED_BI  i64:$rb, (IndexOp (add (shl IndexTy:$rc, scale:$scale), indexed_disp_i32_ext:$imm))))), (InstExt GR:$rb, GR:$rc, scale:$scale, (cvt64 $imm))>;
  def : Pat<(Ty (LoadOp (INDEXED_BI  i64:$rb, (IndexOp      (shl IndexTy:$rc, scale:$scale)                        )))), (Inst    GR:$rb, GR:$rc, scale:$scale, 0)>;
}

multiclass LdPatIndexed_i64<PatFrag LoadOp, InstBase Inst, InstBaseExt InstExt, ValueType Ty, ValueType IndexTy>
{
  // base + scaled_index + disp
  def : Pat<(Ty (LoadOp (INDEXED_BSID i64:$rb, IndexTy:$rc, scale:$scale, indexed_disp    :$imm))), (Inst    GR:$rb, GR:$rc, scale:$scale, indexed_disp    :$imm)>;
  def : Pat<(Ty (LoadOp (INDEXED_BSID i64:$rb, IndexTy:$rc, scale:$scale, indexed_disp_ext:$imm))), (InstExt GR:$rb, GR:$rc, scale:$scale, indexed_disp_ext:$imm)>;

  // base + index + disp
  def : Pat<(Ty (LoadOp (INDEXED_BID i64:$rb, IndexTy:$rc, indexed_disp    :$imm))), (Inst    GR:$rb, GR:$rc, 0, indexed_disp    :$imm)>;
  def : Pat<(Ty (LoadOp (INDEXED_BID i64:$rb, IndexTy:$rc, indexed_disp_ext:$imm))), (InstExt GR:$rb, GR:$rc, 0, indexed_disp_ext:$imm)>;

  // base + scaled_index (no extended variant)
  def : Pat<(Ty (LoadOp (INDEXED_BSI i64:$rb, IndexTy:$rc, scale:$scale))), (Inst GR:$rb, GR:$rc, scale:$scale, 0)>;

  // base + index (no extended variant)
  def : Pat<(Ty (LoadOp (INDEXED_BI i64:$rb, IndexTy:$rc))), (Inst GR:$rb, GR:$rc, 0, 0)>;
}

multiclass LdPat<PatFrag LoadOp, ValueType Ty>
{
  defm : LdPatBase       <LoadOp, !cast<InstBase>(NAME      ), !cast<InstBaseExt>(NAME # _EXT   ), Ty>;
  defm : LdPatPCRel      <LoadOp, !cast<InstBase>(NAME # R  ), !cast<InstBaseExt>(NAME # R_EXT  ), Ty>;
  defm : LdPatIndexed_i64<LoadOp, !cast<InstBase>(NAME # XD ), !cast<InstBaseExt>(NAME # XD_EXT ), Ty, i64>;
  defm : LdPatIndexed_i32<LoadOp, !cast<InstBase>(NAME # XWS), !cast<InstBaseExt>(NAME # XWS_EXT), Ty, i32, indexed_i32_sext>;
  defm : LdPatIndexed_i32<LoadOp, !cast<InstBase>(NAME # XWZ), !cast<InstBaseExt>(NAME # XWZ_EXT), Ty, i32, indexed_i32_zext>;
  defm : LdPatIndexed_i32<LoadOp, !cast<InstBase>(NAME # XWS), !cast<InstBaseExt>(NAME # XWS_EXT), Ty, i64, indexed_i64_sext>;
  defm : LdPatIndexed_i32<LoadOp, !cast<InstBase>(NAME # XWZ), !cast<InstBaseExt>(NAME # XWZ_EXT), Ty, i64, indexed_i64_zext>;
  defm : LdPatIndexed_i32<LoadOp, !cast<InstBase>(NAME # XWZ), !cast<InstBaseExt>(NAME # XWZ_EXT), Ty, i64, indexed_i64_trunc>;
}

defm LDBZ : LdPat<load,        i1>;
defm LDBZ : LdPat<zextloadi1,  i32>;
defm LDBZ : LdPat<extloadi1,   i32>;
defm LDBZ : LdPat<zextloadi1,  i64>;
defm LDBZ : LdPat<extloadi1,   i64>;
defm LDBZ : LdPat<zextloadi1,  i128>;
defm LDBZ : LdPat<extloadi1,   i128>;
defm LDBZ : LdPat<zextloadi8,  i32>;
defm LDBZ : LdPat<extloadi8,   i32>;
defm LDBZ : LdPat<zextloadi8,  i64>;
defm LDBZ : LdPat<extloadi8,   i64>;
defm LDBZ : LdPat<zextloadi8,  i128>;
defm LDBZ : LdPat<extloadi8,   i128>;

defm LDBS : LdPat<sextloadi8,  i32>;
defm LDBS : LdPat<sextloadi8,  i64>;
defm LDBS : LdPat<sextloadi8,  i128>;

defm LDHZ : LdPat<zextloadi16, i32>;
defm LDHZ : LdPat<extloadi16,  i32>;
defm LDHZ : LdPat<zextloadi16, i64>;
defm LDHZ : LdPat<extloadi16,  i64>;
defm LDHZ : LdPat<zextloadi16, i128>;
defm LDHZ : LdPat<extloadi16,  i128>;

defm LDHS : LdPat<sextloadi16, i32>;
defm LDHS : LdPat<sextloadi16, i64>;
defm LDHS : LdPat<sextloadi16, i128>;

defm LDWZ : LdPat<load,        i32>;
defm LDWZ : LdPat<zextloadi32, i64>;
defm LDWZ : LdPat<extloadi32,  i64>;
defm LDWZ : LdPat<zextloadi32, i128>;
defm LDWZ : LdPat<extloadi32,  i128>;

defm LDWS : LdPat<sextloadi32, i64>;
defm LDWS : LdPat<sextloadi32, i128>;

defm LDDZ : LdPat<load,        i64>;
defm LDDZ : LdPat<extloadi64,  i128>;
defm LDDZ : LdPat<zextloadi64, i128>;

defm LDQ  : LdPat<load, i128>;

defm LDHZ : LdPat<load, f16>;
defm LDWZ : LdPat<load, f32>;
defm LDDZ : LdPat<load, f64>;
defm LDQ  : LdPat<load, f128>;

defm LDQ : LdPat<load, v2f64>;
defm LDQ : LdPat<load, v4f32>;
defm LDQ : LdPat<load, v8f16>;
defm LDQ : LdPat<load, v16i8>;
defm LDQ : LdPat<load, v8i16>;
defm LDQ : LdPat<load, v4i32>;
defm LDQ : LdPat<load, v2i64>;

//===----------------------------------------------------------------------===//
// Store instructions (base+dsip, ip+disp, pre/post update, indexed)
//===----------------------------------------------------------------------===//
multiclass Store<opcode_opx opRI, opcode_opx opRC, misc_opx opMIA, misc_opx opMIB,
  indexed_ds_opx OpcDS, indexed_ws_opx OpcWS, indexed_wz_opx OpcWZ, InstrItinClass itin = IIC_st>
{
  // base + displacement
  let mayStore = 1 in
  def NAME : PRIMARY_RabI21<opRI, (outs), (ins GR:$ra, GR:$rb, simm21:$imm),
        !strconcat(opRI.mnem, "\t$ra, $rb, $imm"), [], itin>;

  // base + displacement extended
  let mayStore = 1, AddedComplexity = 3 in
  def NAME # _EXT : PRIMARY_RabI21_ext<opRI, (outs), (ins GR:$ra, GR:$rb, simm21_ext:$imm),
        !strconcat(opRI.mnem, ".l\t$ra, $rb, $imm"), [], itin>;

  // ip + forward displacement
  let mayStore = 1 in
  def NAME # R : PRIMARY_RaI28<opRC, (outs), (ins GR:$ra, uimm28:$imm),
        !strconcat(opRC.mnem, "\t$ra, $imm"), [], itin>;

  // ip + forward displacement extended
  let mayStore = 1, AddedComplexity = 3 in
  def NAME # R_EXT : PRIMARY_RaI28_ext<opRC, (outs), (ins GR:$ra, uimm28_ext:$imm),
        !strconcat(opRC.mnem, ".l\t$ra, $imm"), [], itin>;

  // base + scaled 64-bit index + displacement
  let mayStore = 1, isIndexedMemAccess = 1 in
  def XD : PRIMARY_Indexed_DS<OpcDS, (outs), (ins GR:$ra, GR:$rb, GR:$rc, scale:$scale, indexed_disp:$imm),
        !strconcat(OpcDS.mnem, "\t$ra, $rb, $rc, $scale, $imm"), [], itin>;

  // base + scaled 64-bit index + displacement extended
  let mayStore = 1, isIndexedMemAccess = 1, AddedComplexity = 3 in
  def XD_EXT : PRIMARY_Indexed_DS_Long<OpcDS, (outs), (ins GR:$ra, GR:$rb, GR:$rc, scale:$scale, indexed_disp_ext:$imm),
        !strconcat(OpcDS.mnem, ".l\t$ra, $rb, $rc, $scale, $imm"), [], itin>;

  // base + scaled signed 32-bit index + displacement
  let mayStore = 1, isIndexedMemAccess = 1 in
  def XWS : PRIMARY_Indexed_WS<OpcWS, (outs), (ins GR:$ra, GR:$rb, GR:$rc, scale:$scale, indexed_disp:$imm),
        !strconcat(OpcWS.mnem, "\t$ra, $rb, $rc, $scale, $imm"), [], itin>;

  // base + scaled signed 32-bit index + displacement extended
  let mayStore = 1, isIndexedMemAccess = 1, AddedComplexity = 3 in
  def XWS_EXT : PRIMARY_Indexed_WS_Long<OpcWS, (outs), (ins GR:$ra, GR:$rb, GR:$rc, scale:$scale, indexed_disp_ext:$imm),
        !strconcat(OpcWS.mnem, ".l\t$ra, $rb, $rc, $scale, $imm"), [], itin>;

  // base + scaled unsigned 32-bit index + displacement
  let mayStore = 1, isIndexedMemAccess = 1 in
  def XWZ : PRIMARY_Indexed_WZ<OpcWZ, (outs), (ins GR:$ra, GR:$rb, GR:$rc, scale:$scale, indexed_disp:$imm),
        !strconcat(OpcWZ.mnem, "\t$ra, $rb, $rc, $scale, $imm"), [], itin>;

  // base + scaled unsigned 32-bit index + displacement extended
  let mayStore = 1, isIndexedMemAccess = 1, AddedComplexity = 3 in
  def XWZ_EXT : PRIMARY_Indexed_WZ_Long<OpcWZ, (outs), (ins GR:$ra, GR:$rb, GR:$rc, scale:$scale, indexed_disp_ext:$imm),
        !strconcat(OpcWZ.mnem, ".l\t$ra, $rb, $rc, $scale, $imm"), [], itin>;

  // base with base post-update immediate
  let mayStore = 1, isPostIncrement = 1, Constraints = "$rx = $rb" in
  def MIA : MISC_RabI10<opMIA, (outs GR:$rx), (ins GR:$ra, GR:$rb, stride_imm:$imm),
        !strconcat(opMIA.mnem, "\t$ra, $rb, $imm"), [], itin>;

  // base with base post-update immediate (extended)
  let mayStore = 1, isPostIncrement = 1, AddedComplexity = 3, Constraints = "$rx = $rb" in
  def MIA_EXT : MISC_RabI10_ext<opMIA, (outs GR:$rx), (ins GR:$ra, GR:$rb, stride_imm_ext:$imm),
        !strconcat(opMIA.mnem, ".l\t$ra, $rb, $imm"), [], itin>;

  // base with base pre-update immediate
  let mayStore = 1, isPreIncrement = 1, Constraints = "$rx = $rb" in
  def MIB : MISC_RabI10<opMIB, (outs GR:$rx), (ins GR:$ra, GR:$rb, stride_imm:$imm),
        !strconcat(opMIB.mnem, "\t$ra, $rb, $imm"), [], itin>;

  // base with base pre-update immediate (extended)
  let mayStore = 1, isPreIncrement = 1, AddedComplexity = 3, Constraints = "$rx = $rb" in
  def MIB_EXT : MISC_RabI10_ext<opMIB, (outs GR:$rx), (ins GR:$ra, GR:$rb, stride_imm_ext:$imm),
        !strconcat(opMIB.mnem, ".l\t$ra, $rb, $imm"), [], itin>;
}

defm STB : Store<opcode_st_b, opcode_st_b_r, misc_opx_st_b_mia, misc_opx_st_b_mib, indexed_ds_opx_st_b_xds, indexed_ws_opx_st_b_xws, indexed_wz_opx_st_b_xwz>;
defm STH : Store<opcode_st_h, opcode_st_h_r, misc_opx_st_h_mia, misc_opx_st_h_mib, indexed_ds_opx_st_h_xds, indexed_ws_opx_st_h_xws, indexed_wz_opx_st_h_xwz>;
defm STW : Store<opcode_st_w, opcode_st_w_r, misc_opx_st_w_mia, misc_opx_st_w_mib, indexed_ds_opx_st_w_xds, indexed_ws_opx_st_w_xws, indexed_wz_opx_st_w_xwz>;
defm STD : Store<opcode_st_d, opcode_st_d_r, misc_opx_st_d_mia, misc_opx_st_d_mib, indexed_ds_opx_st_d_xds, indexed_ws_opx_st_d_xws, indexed_wz_opx_st_d_xwz>;
defm STQ : Store<opcode_st_q, opcode_st_q_r, misc_opx_st_q_mia, misc_opx_st_q_mib, indexed_ds_opx_st_q_xds, indexed_ws_opx_st_q_xws, indexed_wz_opx_st_q_xwz>;

//===----------------------------------------------------------------------===//
// Store patterns.
//===----------------------------------------------------------------------===//
multiclass StPatBase<PatFrag StoreOp, InstBase Inst, InstBaseExt InstExt, ValueType Ty>
{
  def : Pat<(StoreOp Ty:$ra, (add         i64:$rb,  simm21:$imm)), (Inst GR:$ra,     GR:$rb, simm21:$imm)>;
  def : Pat<(StoreOp Ty:$ra, (add (i64 AddrFI:$rb), simm21:$imm)), (Inst GR:$ra, AddrFI:$rb, simm21:$imm)>;
  def : Pat<(StoreOp Ty:$ra,         i64:$rb ), (Inst GR:$ra,     GR:$rb, 0)>;
  def : Pat<(StoreOp Ty:$ra, (i64 AddrFI:$rb)), (Inst GR:$ra, AddrFI:$rb, 0)>;
  def : Pat<(StoreOp Ty:$ra, (add         i64:$rb , simm21_ext:$imm)), (InstExt GR:$ra,     GR:$rb, simm21_ext:$imm)>;
  def : Pat<(StoreOp Ty:$ra, (add (i64 AddrFI:$rb), simm21_ext:$imm)), (InstExt GR:$ra, AddrFI:$rb, simm21_ext:$imm)>;

  def : Pat<(StoreOp Ty:$ra, (add i64:$rb, (tls_offset_wrapper     tglobaltlsaddr:$addr))), (Inst    GR:$ra, GR:$rb, tglobaltlsaddr:$addr)>;
  def : Pat<(StoreOp Ty:$ra, (add i64:$rb, (tls_offset_wrapper_ext tglobaltlsaddr:$addr))), (InstExt GR:$ra, GR:$rb, tglobaltlsaddr:$addr)>;
}

multiclass StPatPCRel<PatFrag StoreOp, InstBase Inst, InstBaseExt Inst_ext, ValueType Ty>
{
  // global/external address should be properly wrapped into corresponding PCREL wrapper (_EXT or nothing)
  def : Pat<(StoreOp Ty:$ra, (pcrel_data_wrapper  tglobaladdr:$addr)), (Inst GR:$ra,  tglobaladdr:$addr)>;
  def : Pat<(StoreOp Ty:$ra, (pcrel_data_wrapper   tconstpool:$addr)), (Inst GR:$ra,   tconstpool:$addr)>;
  def : Pat<(StoreOp Ty:$ra, (pcrel_data_wrapper texternalsym:$addr)), (Inst GR:$ra, texternalsym:$addr)>;

  def : Pat<(StoreOp Ty:$ra, (pcrel_data_wrapper_ext  tglobaladdr:$addr)), (Inst_ext GR:$ra,  tglobaladdr:$addr)>;
  def : Pat<(StoreOp Ty:$ra, (pcrel_data_wrapper_ext   tconstpool:$addr)), (Inst_ext GR:$ra,   tconstpool:$addr)>;
  def : Pat<(StoreOp Ty:$ra, (pcrel_data_wrapper_ext texternalsym:$addr)), (Inst_ext GR:$ra, texternalsym:$addr)>;
}

multiclass StPatIndexed_i32<PatFrag StoreOp, InstBase Inst, InstBaseExt InstExt, ValueType Ty, ValueType IndexTy, PatFrag IndexOp>
{
  // base + scaled_index + disp
  def : Pat<(StoreOp Ty:$ra, (INDEXED_BSID i64:$rb, (IndexOp IndexTy:$rc), scale:$scale, indexed_disp    :$imm)), (Inst    GR:$ra, GR:$rb, GR:$rc, scale:$scale, indexed_disp    :$imm)>;
  def : Pat<(StoreOp Ty:$ra, (INDEXED_BSID i64:$rb, (IndexOp IndexTy:$rc), scale:$scale, indexed_disp_ext:$imm)), (InstExt GR:$ra, GR:$rb, GR:$rc, scale:$scale, indexed_disp_ext:$imm)>;

  // base + index + disp
  def : Pat<(StoreOp Ty:$ra, (INDEXED_BID i64:$rb, (IndexOp IndexTy:$rc), indexed_disp    :$imm)), (Inst    GR:$ra, GR:$rb, GR:$rc, 0, indexed_disp    :$imm)>;
  def : Pat<(StoreOp Ty:$ra, (INDEXED_BID i64:$rb, (IndexOp IndexTy:$rc), indexed_disp_ext:$imm)), (InstExt GR:$ra, GR:$rb, GR:$rc, 0, indexed_disp_ext:$imm)>;

  // base + scaled_index (no extended variant)
  def : Pat<(StoreOp Ty:$ra, (INDEXED_BSI i64:$rb, (IndexOp IndexTy:$rc), scale:$scale)), (Inst GR:$ra, GR:$rb, GR:$rc, scale:$scale, 0)>;
  // base + index (no extended variant)
  def : Pat<(StoreOp Ty:$ra, (INDEXED_BI i64:$rb, (IndexOp IndexTy:$rc))), (Inst GR:$ra, GR:$rb, GR:$rc, 0, 0)>;

  // FIXME: allow shift/add before IndexOp because int overflow is UB
  def : Pat<(StoreOp Ty:$ra, (INDEXED_BID i64:$rb, (IndexOp (shl IndexTy:$rc, scale:$scale)), indexed_disp    :$imm)), (Inst    GR:$ra, GR:$rb, GR:$rc, scale:$scale, indexed_disp    :$imm)>;
  def : Pat<(StoreOp Ty:$ra, (INDEXED_BID i64:$rb, (IndexOp (shl IndexTy:$rc, scale:$scale)), indexed_disp_ext:$imm)), (InstExt GR:$ra, GR:$rb, GR:$rc, scale:$scale, indexed_disp_ext:$imm)>;
  def : Pat<(StoreOp Ty:$ra, (INDEXED_BI  i64:$rb, (IndexOp (add (shl IndexTy:$rc, scale:$scale), indexed_disp_i32    :$imm)))), (Inst    GR:$ra, GR:$rb, GR:$rc, scale:$scale, (cvt64 $imm))>;
  def : Pat<(StoreOp Ty:$ra, (INDEXED_BI  i64:$rb, (IndexOp (add (shl IndexTy:$rc, scale:$scale), indexed_disp_i32_ext:$imm)))), (InstExt GR:$ra, GR:$rb, GR:$rc, scale:$scale, (cvt64 $imm))>;
  def : Pat<(StoreOp Ty:$ra, (INDEXED_BI  i64:$rb, (IndexOp (     shl IndexTy:$rc, scale:$scale)                            ))), (Inst    GR:$ra, GR:$rb, GR:$rc, scale:$scale, 0)>;
}

multiclass StPatIndexed_i64<PatFrag StoreOp, InstBase Inst, InstBaseExt InstExt, ValueType Ty, ValueType IndexTy>
{
  // base + scaled_index + disp
  def : Pat<(StoreOp Ty:$ra, (INDEXED_BSID i64:$rb, IndexTy:$rc, scale:$scale, indexed_disp:    $imm)), (Inst    GR:$ra, GR:$rb, GR:$rc, scale:$scale, indexed_disp:    $imm)>;
  def : Pat<(StoreOp Ty:$ra, (INDEXED_BSID i64:$rb, IndexTy:$rc, scale:$scale, indexed_disp_ext:$imm)), (InstExt GR:$ra, GR:$rb, GR:$rc, scale:$scale, indexed_disp_ext:$imm)>;
  // base + index + disp
  def : Pat<(StoreOp Ty:$ra, (INDEXED_BID i64:$rb, IndexTy:$rc, indexed_disp:    $imm)), (Inst    GR:$ra, GR:$rb, GR:$rc, 0, indexed_disp:    $imm)>;
  def : Pat<(StoreOp Ty:$ra, (INDEXED_BID i64:$rb, IndexTy:$rc, indexed_disp_ext:$imm)), (InstExt GR:$ra, GR:$rb, GR:$rc, 0, indexed_disp_ext:$imm)>;
  // base + scaled_index (no extended variant)
  def : Pat<(StoreOp Ty:$ra, (INDEXED_BSI i64:$rb, IndexTy:$rc, scale:$scale)), (Inst GR:$ra, GR:$rb, GR:$rc, scale:$scale, 0)>;
  // base + index (no extended variant)
  def : Pat<(StoreOp Ty:$ra, (INDEXED_BI i64:$rb, IndexTy:$rc)), (Inst GR:$ra, GR:$rb, GR:$rc, 0, 0)>;
}

multiclass StPat<PatFrag StoreOp, ValueType Ty>
{
  defm : StPatBase        <StoreOp, !cast<InstBase>(NAME      ), !cast<InstBaseExt>(NAME # _EXT   ), Ty>;
  defm : StPatPCRel       <StoreOp, !cast<InstBase>(NAME # R  ), !cast<InstBaseExt>(NAME # R_EXT  ), Ty>;
  defm : StPatIndexed_i64 <StoreOp, !cast<InstBase>(NAME # XD ), !cast<InstBaseExt>(NAME # XD_EXT ), Ty, i64>;
  defm : StPatIndexed_i32 <StoreOp, !cast<InstBase>(NAME # XWS), !cast<InstBaseExt>(NAME # XWS_EXT), Ty, i32, indexed_i32_sext>;
  defm : StPatIndexed_i32 <StoreOp, !cast<InstBase>(NAME # XWZ), !cast<InstBaseExt>(NAME # XWZ_EXT), Ty, i32, indexed_i32_zext>;
  defm : StPatIndexed_i32 <StoreOp, !cast<InstBase>(NAME # XWS), !cast<InstBaseExt>(NAME # XWS_EXT), Ty, i64, indexed_i64_sext>;
  defm : StPatIndexed_i32 <StoreOp, !cast<InstBase>(NAME # XWZ), !cast<InstBaseExt>(NAME # XWZ_EXT), Ty, i64, indexed_i64_zext>;
  defm : StPatIndexed_i32 <StoreOp, !cast<InstBase>(NAME # XWZ), !cast<InstBaseExt>(NAME # XWZ_EXT), Ty, i64, indexed_i64_trunc>;
}

// TODO: patterns for stXmia/stXmib

defm STB : StPat<store,         i1>;
defm STB : StPat<truncstorei8,  i32>;
defm STB : StPat<truncstorei8,  i64>;
defm STB : StPat<truncstorei8,  i128>;

defm STH : StPat<truncstorei16, i32>;
defm STH : StPat<truncstorei16, i64>;
defm STH : StPat<truncstorei16, i128>;
defm STW : StPat<store,         i32>;
defm STW : StPat<truncstorei32, i64>;
defm STW : StPat<truncstorei32, i128>;
defm STD : StPat<store,         i64>;
defm STD : StPat<truncstorei64, i128>;
defm STQ : StPat<store,         i128>;

defm STH : StPat<store, f16>;
defm STW : StPat<store, f32>;
defm STD : StPat<store, f64>;
defm STQ : StPat<store, f128>;

defm STQ : StPat<store, v8f16>;
defm STQ : StPat<store, v4f32>;
defm STQ : StPat<store, v2f64>;
defm STQ : StPat<store, v16i8>;
defm STQ : StPat<store, v8i16>;
defm STQ : StPat<store, v4i32>;
defm STQ : StPat<store, v2i64>;

//===----------------------------------------------------------------------===//
// LDAX patterns (sign/zero extend, etc)
// TODO: there is no identity PatFrag, so i64 index patterns are duplicated
//===----------------------------------------------------------------------===//
multiclass LdaxPatIndexed_i32<InstBase Inst, InstBaseExt InstExt, ValueType IndexTy, PatFrag IndexOp>
{
  // base + scaled_index + disp
  def : Pat<(INDEXED_BSID i64:$rb, (IndexOp IndexTy:$rc), scale:$scale, indexed_disp    :$imm), (Inst    GR:$rb, GR:$rc, scale:$scale, indexed_disp    :$imm)>;
  def : Pat<(INDEXED_BSID i64:$rb, (IndexOp IndexTy:$rc), scale:$scale, indexed_disp_ext:$imm), (InstExt GR:$rb, GR:$rc, scale:$scale, indexed_disp_ext:$imm)>;

  // base + index + disp
  def : Pat<(INDEXED_BID i64:$rb, (IndexOp IndexTy:$rc), indexed_disp    :$imm), (Inst    GR:$rb, GR:$rc, 0, indexed_disp    :$imm)>;
  def : Pat<(INDEXED_BID i64:$rb, (IndexOp IndexTy:$rc), indexed_disp_ext:$imm), (InstExt GR:$rb, GR:$rc, 0, indexed_disp_ext:$imm)>;

  // base + scaled_index (no extended variant)
  def : Pat<(INDEXED_BSI i64:$rb, (IndexOp IndexTy:$rc), scale:$scale), (Inst GR:$rb, GR:$rc, scale:$scale, 0)>;

  // base + index (no extended variant)
  def : Pat<(INDEXED_BI i64:$rb, (IndexOp IndexTy:$rc)), (Inst GR:$rb, GR:$rc, 0, 0)>;

  // FIXME: allow shift before IndexOp because int overflow is UB
  def : Pat<(INDEXED_BID i64:$rb, (IndexOp (shl IndexTy:$rc, scale:$scale)), indexed_disp    :$imm), (Inst    GR:$rb, GR:$rc, scale:$scale, indexed_disp    :$imm)>;
  def : Pat<(INDEXED_BID i64:$rb, (IndexOp (shl IndexTy:$rc, scale:$scale)), indexed_disp_ext:$imm), (InstExt GR:$rb, GR:$rc, scale:$scale, indexed_disp_ext:$imm)>;
  def : Pat<(INDEXED_BI  i64:$rb, (IndexOp (add (shl IndexTy:$rc, scale:$scale), indexed_disp_i32    :$imm))), (Inst    GR:$rb, GR:$rc, scale:$scale, (cvt64 $imm))>;
  def : Pat<(INDEXED_BI  i64:$rb, (IndexOp (add (shl IndexTy:$rc, scale:$scale), indexed_disp_i32_ext:$imm))), (InstExt GR:$rb, GR:$rc, scale:$scale, (cvt64 $imm))>;
  def : Pat<(INDEXED_BI  i64:$rb, (IndexOp (     shl IndexTy:$rc, scale:$scale)                            )), (Inst    GR:$rb, GR:$rc, scale:$scale, 0)>;
}

multiclass LdaxPatIndexed_i64<InstBase Inst, InstBaseExt InstExt, ValueType IndexTy>
{
  // base + scaled_index + disp
  def : Pat<(INDEXED_BSID i64:$rb, IndexTy:$rc, scale:$scale, indexed_disp:    $imm), (Inst    GR:$rb, GR:$rc, scale:$scale, indexed_disp:    $imm)>;
  def : Pat<(INDEXED_BSID i64:$rb, IndexTy:$rc, scale:$scale, indexed_disp_ext:$imm), (InstExt GR:$rb, GR:$rc, scale:$scale, indexed_disp_ext:$imm)>;
  // base + index + disp
  def : Pat<(INDEXED_BID i64:$rb, IndexTy:$rc, indexed_disp:    $imm), (Inst    GR:$rb, GR:$rc, 0, indexed_disp:    $imm)>;
  def : Pat<(INDEXED_BID i64:$rb, IndexTy:$rc, indexed_disp_ext:$imm), (InstExt GR:$rb, GR:$rc, 0, indexed_disp_ext:$imm)>;
  // base + scaled_index (no extended variant)
  def : Pat<(INDEXED_BSI i64:$rb, IndexTy:$rc, scale:$scale), (Inst GR:$rb, GR:$rc, scale:$scale, 0)>;
  // base + index (no extended variant)
  def : Pat<(INDEXED_BI i64:$rb, IndexTy:$rc), (Inst GR:$rb, GR:$rc, 0, 0)>;
}

multiclass LdaxPat
{
  defm : LdaxPatIndexed_i64 <!cast<InstBase>(NAME # XD ), !cast<InstBaseExt>(NAME # XD_EXT ), i64>;
  defm : LdaxPatIndexed_i32 <!cast<InstBase>(NAME # XWS), !cast<InstBaseExt>(NAME # XWS_EXT), i32, indexed_i32_sext>;
  defm : LdaxPatIndexed_i32 <!cast<InstBase>(NAME # XWZ), !cast<InstBaseExt>(NAME # XWZ_EXT), i32, indexed_i32_zext>;
  defm : LdaxPatIndexed_i32 <!cast<InstBase>(NAME # XWS), !cast<InstBaseExt>(NAME # XWS_EXT), i64, indexed_i64_sext>;
  defm : LdaxPatIndexed_i32 <!cast<InstBase>(NAME # XWZ), !cast<InstBaseExt>(NAME # XWZ_EXT), i64, indexed_i64_zext>;
  defm : LdaxPatIndexed_i32 <!cast<InstBase>(NAME # XWZ), !cast<InstBaseExt>(NAME # XWZ_EXT), i64, indexed_i64_trunc>;
}

defm CA_X : LoadIndexed<indexed_ds_opx_ca_xds, indexed_ws_opx_ca_xws, indexed_wz_opx_ca_xwz>;
defm CA_X : LdaxPat;
