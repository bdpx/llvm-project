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
def indexed_disp_ext : Operand<i64>, IntImmLeaf<i64, [{ return isSextInt(Imm, 7+42); }], indexed_disp_ext_xform> {
  let DecoderMethod = "DecodeSIMM<7+42>";
}

//===----------------------------------------------------------------------===//
// load instructions (base+dsip, ip+disp, pre/post update)
//===----------------------------------------------------------------------===//
multiclass LoadBase<opcode_opx Opc, InstrItinClass itin = IIC_iu_instr>
{
  // base + displacement
  let mayLoad = 1 in
  def NAME : PRIMARY_RabI21<Opc, (outs GR:$ra), (ins GR:$rb, simm21:$imm),
        !strconcat(Opc.mnem, " $ra, $rb, $imm"), [], itin>;

  // base + displacement extended
  let mayLoad = 1 in
  def NAME # _EXT : PRIMARY_RabI21_ext<Opc, (outs GR:$ra), (ins GR:$rb, simm21_ext:$imm),
        !strconcat(Opc.mnem, ".l $ra, $rb, $imm"), [], itin>;
}

defm LD_U8   : LoadBase<opcode_ld_u8>;
defm LD_U16  : LoadBase<opcode_ld_u16>;
defm LD_U32  : LoadBase<opcode_ld_u32>;
defm LD_U64  : LoadBase<opcode_ld_u64>;
defm LD_I8   : LoadBase<opcode_ld_i8>;
defm LD_I16  : LoadBase<opcode_ld_i16>;
defm LD_I32  : LoadBase<opcode_ld_i32>;
defm LD_I64  : LoadBase<opcode_ld_i64>;
defm LD_I128 : LoadBase<opcode_ld_i128>;

multiclass LoadIprel<opcode_opx Opc, InstrItinClass itin = IIC_iu_instr>
{
  // ip + forward displacement
  let mayLoad = 1 in
  def NAME : PRIMARY_RaI28<Opc, (outs GR:$ra), (ins uimm28:$imm),
        !strconcat(Opc.mnem, " $ra, $imm"), [], itin>;

  // ip + forward displacement extended
  let mayLoad = 1 in
  def NAME # _EXT : PRIMARY_RaI28_ext<Opc, (outs GR:$ra), (ins uimm28_ext:$imm),
        !strconcat(Opc.mnem, ".l $ra, $imm"), [], itin>;
}

defm LD_IPREL_U8   : LoadIprel<opcode_ld_iprel_u8>;
defm LD_IPREL_U16  : LoadIprel<opcode_ld_iprel_u16>;
defm LD_IPREL_U32  : LoadIprel<opcode_ld_iprel_u32>;
defm LD_IPREL_U64  : LoadIprel<opcode_ld_iprel_u64>;
defm LD_IPREL_I8   : LoadIprel<opcode_ld_iprel_i8>;
defm LD_IPREL_I16  : LoadIprel<opcode_ld_iprel_i16>;
defm LD_IPREL_I32  : LoadIprel<opcode_ld_iprel_i32>;
defm LD_IPREL_I64  : LoadIprel<opcode_ld_iprel_i64>;
defm LD_IPREL_I128 : LoadIprel<opcode_ld_iprel_i128>;

multiclass LoadModifyAfter<misc_opx Opc, InstrItinClass itin = IIC_iu_instr>
{
  // base with base post-update immediate
  let mayLoad = 1, isPostIncrement = 1, Constraints = "$rx = $rb" in
  def NAME : MISC_RabI10<Opc, (outs GR:$ra, GR:$rx), (ins GR:$rb, stride_imm:$imm),
        !strconcat(Opc.mnem, " $ra, $rb, $imm"), [], itin>;

  // base with base post-update immediate (extended)
  let mayLoad = 1, isPostIncrement = 1, Constraints = "$rx = $rb" in
  def NAME # _EXT : MISC_RabI10_ext<Opc, (outs GR:$ra, GR:$rx), (ins GR:$rb, stride_imm_ext:$imm),
        !strconcat(Opc.mnem, ".l $ra, $rb, $imm"), [], itin>;
}

defm LD_MIA_U8   : LoadModifyAfter<opcode_ld_mia_u8>;
defm LD_MIA_U16  : LoadModifyAfter<opcode_ld_mia_u16>;
defm LD_MIA_U32  : LoadModifyAfter<opcode_ld_mia_u32>;
defm LD_MIA_U64  : LoadModifyAfter<opcode_ld_mia_u64>;
defm LD_MIA_I8   : LoadModifyAfter<opcode_ld_mia_i8>;
defm LD_MIA_I16  : LoadModifyAfter<opcode_ld_mia_i16>;
defm LD_MIA_I32  : LoadModifyAfter<opcode_ld_mia_i32>;
defm LD_MIA_I64  : LoadModifyAfter<opcode_ld_mia_i64>;
defm LD_MIA_I128 : LoadModifyAfter<opcode_ld_mia_i128>;

multiclass LoadModifyBefore<misc_opx Opc, InstrItinClass itin = IIC_iu_instr>
{
  // base with base pre-update immediate
  let mayLoad = 1, isPreIncrement = 1, Constraints = "$rx = $rb" in
  def NAME : MISC_RabI10<Opc, (outs GR:$ra, GR:$rx), (ins GR:$rb, stride_imm:$imm),
        !strconcat(Opc.mnem, " $ra, $rb, $imm"), [], itin>;

  // base with base pre-update immediate (extended)
  let mayLoad = 1, isPreIncrement = 1, Constraints = "$rx = $rb" in
  def NAME # _EXT : MISC_RabI10_ext<Opc, (outs GR:$ra, GR:$rx), (ins GR:$rb, stride_imm_ext:$imm),
        !strconcat(Opc.mnem, ".l $ra, $rb, $imm"), [], itin>;
}

defm LD_MIB_U8   : LoadModifyBefore<opcode_ld_mib_u8>;
defm LD_MIB_U16  : LoadModifyBefore<opcode_ld_mib_u16>;
defm LD_MIB_U32  : LoadModifyBefore<opcode_ld_mib_u32>;
defm LD_MIB_U64  : LoadModifyBefore<opcode_ld_mib_u64>;
defm LD_MIB_I8   : LoadModifyBefore<opcode_ld_mib_i8>;
defm LD_MIB_I16  : LoadModifyBefore<opcode_ld_mib_i16>;
defm LD_MIB_I32  : LoadModifyBefore<opcode_ld_mib_i32>;
defm LD_MIB_I64  : LoadModifyBefore<opcode_ld_mib_i64>;
defm LD_MIB_I128 : LoadModifyBefore<opcode_ld_mib_i128>;

//===----------------------------------------------------------------------===//
// load instructions (indexed and LDAX)
//===----------------------------------------------------------------------===//
multiclass LoadIndexedI64<mem_xi64_opx Opc, InstrItinClass itin = IIC_iu_instr>
{
  // base + scaled 64-bit index + displacement
  let mayLoad = 1, isIndexedMemAccess = 1 in
  def NAME : PRIMARY_Indexed_DS<Opc,
        (outs GR:$ra), (ins GR:$rb, GR:$rc, scale:$scale, indexed_disp:$imm),
        !strconcat(Opc.mnem, " $ra, $rb, $rc, $scale, $imm"), [], itin>;

  // base + scaled 64-bit index + displacement extended
  let mayLoad = 1, isIndexedMemAccess = 1 in
  def NAME # _EXT : PRIMARY_Indexed_DS_Long<Opc,
        (outs GR:$ra), (ins GR:$rb, GR:$rc, scale:$scale, indexed_disp_ext:$imm),
        !strconcat(Opc.mnem, ".l $ra, $rb, $rc, $scale, $imm"), [], itin>;
}

defm LD_XI64_U8   : LoadIndexedI64<opcode_ld_xi64_u8>;
defm LD_XI64_U16  : LoadIndexedI64<opcode_ld_xi64_u16>;
defm LD_XI64_U32  : LoadIndexedI64<opcode_ld_xi64_u32>;
defm LD_XI64_U64  : LoadIndexedI64<opcode_ld_xi64_u64>;
defm LD_XI64_I8   : LoadIndexedI64<opcode_ld_xi64_i8>;
defm LD_XI64_I16  : LoadIndexedI64<opcode_ld_xi64_i16>;
defm LD_XI64_I32  : LoadIndexedI64<opcode_ld_xi64_i32>;
defm LD_XI64_I64  : LoadIndexedI64<opcode_ld_xi64_i64>;
defm LD_XI64_I128 : LoadIndexedI64<opcode_ld_xi64_i128>;
defm LDA_XI64     : LoadIndexedI64<opcode_lda_xi64>;

multiclass LoadIndexedI32<mem_xi32_opx Opc, InstrItinClass itin = IIC_iu_instr>
{
  // base + scaled signed 32-bit index + displacement
  let mayLoad = 1, isIndexedMemAccess = 1 in
  def NAME : PRIMARY_Indexed_WS<Opc,
        (outs GR:$ra), (ins GR:$rb, GR:$rc, scale:$scale, indexed_disp:$imm),
        !strconcat(Opc.mnem, " $ra, $rb, $rc, $scale, $imm"), [], itin>;

  // base + scaled signed 32-bit index + displacement extended
  let mayLoad = 1, isIndexedMemAccess = 1 in
  def NAME # _EXT : PRIMARY_Indexed_WS_Long<Opc,
        (outs GR:$ra), (ins GR:$rb, GR:$rc, scale:$scale, indexed_disp_ext:$imm),
        !strconcat(Opc.mnem, ".l $ra, $rb, $rc, $scale, $imm"), [], itin>;
}

defm LD_XI32_U8   : LoadIndexedI32<opcode_ld_xi32_u8>;
defm LD_XI32_U16  : LoadIndexedI32<opcode_ld_xi32_u16>;
defm LD_XI32_U32  : LoadIndexedI32<opcode_ld_xi32_u32>;
defm LD_XI32_U64  : LoadIndexedI32<opcode_ld_xi32_u64>;
defm LD_XI32_I8   : LoadIndexedI32<opcode_ld_xi32_i8>;
defm LD_XI32_I16  : LoadIndexedI32<opcode_ld_xi32_i16>;
defm LD_XI32_I32  : LoadIndexedI32<opcode_ld_xi32_i32>;
defm LD_XI32_I64  : LoadIndexedI32<opcode_ld_xi32_i64>;
defm LD_XI32_I128 : LoadIndexedI32<opcode_ld_xi32_i128>;
defm LDA_XI32     : LoadIndexedI32<opcode_lda_xi32>;

multiclass LoadIndexedU32<mem_xu32_opx Opc, InstrItinClass itin = IIC_iu_instr>
{
  // base + scaled unsigned 32-bit index + displacement
  let mayLoad = 1, isIndexedMemAccess = 1 in
  def NAME : PRIMARY_Indexed_WZ<Opc,
        (outs GR:$ra), (ins GR:$rb, GR:$rc, scale:$scale, indexed_disp:$imm),
        !strconcat(Opc.mnem, " $ra, $rb, $rc, $scale, $imm"), [], itin>;

  // base + scaled unsigned 32-bit index + displacement extended
  let mayLoad = 1, isIndexedMemAccess = 1 in
  def NAME # _EXT : PRIMARY_Indexed_WZ_Long<Opc,
        (outs GR:$ra), (ins GR:$rb, GR:$rc, scale:$scale, indexed_disp_ext:$imm),
        !strconcat(Opc.mnem, ".l $ra, $rb, $rc, $scale, $imm"), [], itin>;
}

defm LD_XU32_U8   : LoadIndexedU32<opcode_ld_xu32_u8>;
defm LD_XU32_U16  : LoadIndexedU32<opcode_ld_xu32_u16>;
defm LD_XU32_U32  : LoadIndexedU32<opcode_ld_xu32_u32>;
defm LD_XU32_U64  : LoadIndexedU32<opcode_ld_xu32_u64>;
defm LD_XU32_I8   : LoadIndexedU32<opcode_ld_xu32_i8>;
defm LD_XU32_I16  : LoadIndexedU32<opcode_ld_xu32_i16>;
defm LD_XU32_I32  : LoadIndexedU32<opcode_ld_xu32_i32>;
defm LD_XU32_I64  : LoadIndexedU32<opcode_ld_xu32_i64>;
defm LD_XU32_I128 : LoadIndexedU32<opcode_ld_xu32_i128>;
defm LDA_XU32     : LoadIndexedU32<opcode_lda_xu32>;

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

multiclass LdPatI8<PatFrag LoadOp, ValueType Ty>
{
  defm : LdPatBase       <LoadOp, LD_I8,       LD_I8_EXT,        Ty>;
  defm : LdPatPCRel      <LoadOp, LD_IPREL_I8, LD_IPREL_I8_EXT,  Ty>;
  defm : LdPatIndexed_i64<LoadOp, LD_XI64_I8,  LD_XI64_I8_EXT,   Ty, i64>;
  defm : LdPatIndexed_i32<LoadOp, LD_XI32_I8,  LD_XI32_I8_EXT,   Ty, i32, indexed_i32_sext>;
  defm : LdPatIndexed_i32<LoadOp, LD_XU32_I8,  LD_XU32_I8_EXT,   Ty, i32, indexed_i32_zext>;
  defm : LdPatIndexed_i32<LoadOp, LD_XI32_I8,  LD_XI32_I8_EXT,   Ty, i64, indexed_i64_sext>;
  defm : LdPatIndexed_i32<LoadOp, LD_XU32_I8,  LD_XU32_I8_EXT,   Ty, i64, indexed_i64_zext>;
  defm : LdPatIndexed_i32<LoadOp, LD_XU32_I8,  LD_XU32_I8_EXT,   Ty, i64, indexed_i64_trunc>;
}

multiclass LdPatU8<PatFrag LoadOp, ValueType Ty>
{
  defm : LdPatBase       <LoadOp, LD_U8,       LD_U8_EXT,        Ty>;
  defm : LdPatPCRel      <LoadOp, LD_IPREL_U8, LD_IPREL_U8_EXT,  Ty>;
  defm : LdPatIndexed_i64<LoadOp, LD_XI64_U8,  LD_XI64_U8_EXT,   Ty, i64>;
  defm : LdPatIndexed_i32<LoadOp, LD_XI32_U8,  LD_XI32_U8_EXT,   Ty, i32, indexed_i32_sext>;
  defm : LdPatIndexed_i32<LoadOp, LD_XU32_U8,  LD_XU32_U8_EXT,   Ty, i32, indexed_i32_zext>;
  defm : LdPatIndexed_i32<LoadOp, LD_XI32_U8,  LD_XI32_U8_EXT,   Ty, i64, indexed_i64_sext>;
  defm : LdPatIndexed_i32<LoadOp, LD_XU32_U8,  LD_XU32_U8_EXT,   Ty, i64, indexed_i64_zext>;
  defm : LdPatIndexed_i32<LoadOp, LD_XU32_U8,  LD_XU32_U8_EXT,   Ty, i64, indexed_i64_trunc>;
}

multiclass LdPatI16<PatFrag LoadOp, ValueType Ty>
{
  defm : LdPatBase       <LoadOp, LD_I16,       LD_I16_EXT,        Ty>;
  defm : LdPatPCRel      <LoadOp, LD_IPREL_I16, LD_IPREL_I16_EXT,  Ty>;
  defm : LdPatIndexed_i64<LoadOp, LD_XI64_I16,  LD_XI64_I16_EXT,   Ty, i64>;
  defm : LdPatIndexed_i32<LoadOp, LD_XI32_I16,  LD_XI32_I16_EXT,   Ty, i32, indexed_i32_sext>;
  defm : LdPatIndexed_i32<LoadOp, LD_XU32_I16,  LD_XU32_I16_EXT,   Ty, i32, indexed_i32_zext>;
  defm : LdPatIndexed_i32<LoadOp, LD_XI32_I16,  LD_XI32_I16_EXT,   Ty, i64, indexed_i64_sext>;
  defm : LdPatIndexed_i32<LoadOp, LD_XU32_I16,  LD_XU32_I16_EXT,   Ty, i64, indexed_i64_zext>;
  defm : LdPatIndexed_i32<LoadOp, LD_XU32_I16,  LD_XU32_I16_EXT,   Ty, i64, indexed_i64_trunc>;
}

multiclass LdPatU16<PatFrag LoadOp, ValueType Ty>
{
  defm : LdPatBase       <LoadOp, LD_U16,       LD_U16_EXT,        Ty>;
  defm : LdPatPCRel      <LoadOp, LD_IPREL_U16, LD_IPREL_U16_EXT,  Ty>;
  defm : LdPatIndexed_i64<LoadOp, LD_XI64_U16,  LD_XI64_U16_EXT,   Ty, i64>;
  defm : LdPatIndexed_i32<LoadOp, LD_XI32_U16,  LD_XI32_U16_EXT,   Ty, i32, indexed_i32_sext>;
  defm : LdPatIndexed_i32<LoadOp, LD_XU32_U16,  LD_XU32_U16_EXT,   Ty, i32, indexed_i32_zext>;
  defm : LdPatIndexed_i32<LoadOp, LD_XI32_U16,  LD_XI32_U16_EXT,   Ty, i64, indexed_i64_sext>;
  defm : LdPatIndexed_i32<LoadOp, LD_XU32_U16,  LD_XU32_U16_EXT,   Ty, i64, indexed_i64_zext>;
  defm : LdPatIndexed_i32<LoadOp, LD_XU32_U16,  LD_XU32_U16_EXT,   Ty, i64, indexed_i64_trunc>;
}

multiclass LdPatI32<PatFrag LoadOp, ValueType Ty>
{
  defm : LdPatBase       <LoadOp, LD_I32,       LD_I32_EXT,        Ty>;
  defm : LdPatPCRel      <LoadOp, LD_IPREL_I32, LD_IPREL_I32_EXT,  Ty>;
  defm : LdPatIndexed_i64<LoadOp, LD_XI64_I32,  LD_XI64_I32_EXT,   Ty, i64>;
  defm : LdPatIndexed_i32<LoadOp, LD_XI32_I32,  LD_XI32_I32_EXT,   Ty, i32, indexed_i32_sext>;
  defm : LdPatIndexed_i32<LoadOp, LD_XU32_I32,  LD_XU32_I32_EXT,   Ty, i32, indexed_i32_zext>;
  defm : LdPatIndexed_i32<LoadOp, LD_XI32_I32,  LD_XI32_I32_EXT,   Ty, i64, indexed_i64_sext>;
  defm : LdPatIndexed_i32<LoadOp, LD_XU32_I32,  LD_XU32_I32_EXT,   Ty, i64, indexed_i64_zext>;
  defm : LdPatIndexed_i32<LoadOp, LD_XU32_I32,  LD_XU32_I32_EXT,   Ty, i64, indexed_i64_trunc>;
}

multiclass LdPatU32<PatFrag LoadOp, ValueType Ty>
{
  defm : LdPatBase       <LoadOp, LD_U32,       LD_U32_EXT,        Ty>;
  defm : LdPatPCRel      <LoadOp, LD_IPREL_U32, LD_IPREL_U32_EXT,  Ty>;
  defm : LdPatIndexed_i64<LoadOp, LD_XI64_U32,  LD_XI64_U32_EXT,   Ty, i64>;
  defm : LdPatIndexed_i32<LoadOp, LD_XI32_U32,  LD_XI32_U32_EXT,   Ty, i32, indexed_i32_sext>;
  defm : LdPatIndexed_i32<LoadOp, LD_XU32_U32,  LD_XU32_U32_EXT,   Ty, i32, indexed_i32_zext>;
  defm : LdPatIndexed_i32<LoadOp, LD_XI32_U32,  LD_XI32_U32_EXT,   Ty, i64, indexed_i64_sext>;
  defm : LdPatIndexed_i32<LoadOp, LD_XU32_U32,  LD_XU32_U32_EXT,   Ty, i64, indexed_i64_zext>;
  defm : LdPatIndexed_i32<LoadOp, LD_XU32_U32,  LD_XU32_U32_EXT,   Ty, i64, indexed_i64_trunc>;
}

multiclass LdPatI64<PatFrag LoadOp, ValueType Ty>
{
  defm : LdPatBase       <LoadOp, LD_I64,       LD_I64_EXT,        Ty>;
  defm : LdPatPCRel      <LoadOp, LD_IPREL_I64, LD_IPREL_I64_EXT,  Ty>;
  defm : LdPatIndexed_i64<LoadOp, LD_XI64_I64,  LD_XI64_I64_EXT,   Ty, i64>;
  defm : LdPatIndexed_i32<LoadOp, LD_XI32_I64,  LD_XI32_I64_EXT,   Ty, i32, indexed_i32_sext>;
  defm : LdPatIndexed_i32<LoadOp, LD_XU32_I64,  LD_XU32_I64_EXT,   Ty, i32, indexed_i32_zext>;
  defm : LdPatIndexed_i32<LoadOp, LD_XI32_I64,  LD_XI32_I64_EXT,   Ty, i64, indexed_i64_sext>;
  defm : LdPatIndexed_i32<LoadOp, LD_XU32_I64,  LD_XU32_I64_EXT,   Ty, i64, indexed_i64_zext>;
  defm : LdPatIndexed_i32<LoadOp, LD_XU32_I64,  LD_XU32_I64_EXT,   Ty, i64, indexed_i64_trunc>;
}

multiclass LdPatU64<PatFrag LoadOp, ValueType Ty>
{
  defm : LdPatBase       <LoadOp, LD_U64,       LD_U64_EXT,        Ty>;
  defm : LdPatPCRel      <LoadOp, LD_IPREL_U64, LD_IPREL_U64_EXT,  Ty>;
  defm : LdPatIndexed_i64<LoadOp, LD_XI64_U64,  LD_XI64_U64_EXT,   Ty, i64>;
  defm : LdPatIndexed_i32<LoadOp, LD_XI32_U64,  LD_XI32_U64_EXT,   Ty, i32, indexed_i32_sext>;
  defm : LdPatIndexed_i32<LoadOp, LD_XU32_U64,  LD_XU32_U64_EXT,   Ty, i32, indexed_i32_zext>;
  defm : LdPatIndexed_i32<LoadOp, LD_XI32_U64,  LD_XI32_U64_EXT,   Ty, i64, indexed_i64_sext>;
  defm : LdPatIndexed_i32<LoadOp, LD_XU32_U64,  LD_XU32_U64_EXT,   Ty, i64, indexed_i64_zext>;
  defm : LdPatIndexed_i32<LoadOp, LD_XU32_U64,  LD_XU32_U64_EXT,   Ty, i64, indexed_i64_trunc>;
}

multiclass LdPatI128<PatFrag LoadOp, ValueType Ty>
{
  defm : LdPatBase       <LoadOp, LD_I128,       LD_I128_EXT,        Ty>;
  defm : LdPatPCRel      <LoadOp, LD_IPREL_I128, LD_IPREL_I128_EXT,  Ty>;
  defm : LdPatIndexed_i64<LoadOp, LD_XI64_I128,  LD_XI64_I128_EXT,   Ty, i64>;
  defm : LdPatIndexed_i32<LoadOp, LD_XI32_I128,  LD_XI32_I128_EXT,   Ty, i32, indexed_i32_sext>;
  defm : LdPatIndexed_i32<LoadOp, LD_XU32_I128,  LD_XU32_I128_EXT,   Ty, i32, indexed_i32_zext>;
  defm : LdPatIndexed_i32<LoadOp, LD_XI32_I128,  LD_XI32_I128_EXT,   Ty, i64, indexed_i64_sext>;
  defm : LdPatIndexed_i32<LoadOp, LD_XU32_I128,  LD_XU32_I128_EXT,   Ty, i64, indexed_i64_zext>;
  defm : LdPatIndexed_i32<LoadOp, LD_XU32_I128,  LD_XU32_I128_EXT,   Ty, i64, indexed_i64_trunc>;
}

defm : LdPatU8<load,        i1>;
defm : LdPatU8<zextloadi1,  i32>;
defm : LdPatU8<extloadi1,   i32>;
defm : LdPatU8<zextloadi1,  i64>;
defm : LdPatU8<extloadi1,   i64>;
defm : LdPatU8<zextloadi1,  i128>;
defm : LdPatU8<extloadi1,   i128>;
defm : LdPatU8<zextloadi8,  i32>;
defm : LdPatU8<extloadi8,   i32>;
defm : LdPatU8<zextloadi8,  i64>;
defm : LdPatU8<extloadi8,   i64>;
defm : LdPatU8<zextloadi8,  i128>;
defm : LdPatU8<extloadi8,   i128>;

defm : LdPatI8<sextloadi8,  i32>;
defm : LdPatI8<sextloadi8,  i64>;
defm : LdPatI8<sextloadi8,  i128>;

defm : LdPatU16<zextloadi16, i32>;
defm : LdPatU16<extloadi16,  i32>;
defm : LdPatU16<zextloadi16, i64>;
defm : LdPatU16<extloadi16,  i64>;
defm : LdPatU16<zextloadi16, i128>;
defm : LdPatU16<extloadi16,  i128>;

defm : LdPatI16<sextloadi16, i32>;
defm : LdPatI16<sextloadi16, i64>;
defm : LdPatI16<sextloadi16, i128>;

defm : LdPatU32<load,        i32>;
defm : LdPatU32<zextloadi32, i64>;
defm : LdPatU32<extloadi32,  i64>;
defm : LdPatU32<zextloadi32, i128>;
defm : LdPatU32<extloadi32,  i128>;

defm : LdPatI32<sextloadi32, i64>;
defm : LdPatI32<sextloadi32, i128>;

defm : LdPatU64<load,        i64>;
defm : LdPatU64<extloadi64,  i128>;
defm : LdPatU64<zextloadi64, i128>;
defm : LdPatI64<sextloadi64, i128>;

defm : LdPatI128<load, i128>;

defm : LdPatU16<load, f16>;
defm : LdPatU32<load, f32>;
defm : LdPatU64<load, f64>;
defm : LdPatI128<load, f128>;

defm : LdPatI128<load, v2f64>;
defm : LdPatI128<load, v4f32>;
defm : LdPatI128<load, v8f16>;
defm : LdPatI128<load, v16i8>;
defm : LdPatI128<load, v8i16>;
defm : LdPatI128<load, v4i32>;
defm : LdPatI128<load, v2i64>;

//===----------------------------------------------------------------------===//
// Store instructions (base+dsip, ip+disp, pre/post update, indexed)
//===----------------------------------------------------------------------===//
multiclass StoreBase<opcode_opx Opc, InstrItinClass itin = IIC_st>
{
  // base + displacement
  let mayStore = 1 in
  def NAME : PRIMARY_RabI21<Opc, (outs), (ins GR:$ra, GR:$rb, simm21:$imm),
        !strconcat(Opc.mnem, " $ra, $rb, $imm"), [], itin>;

  // base + displacement extended
  let mayStore = 1 in
  def NAME # _EXT : PRIMARY_RabI21_ext<Opc, (outs), (ins GR:$ra, GR:$rb, simm21_ext:$imm),
        !strconcat(Opc.mnem, ".l $ra, $rb, $imm"), [], itin>;
}

defm ST_I8   : StoreBase<opcode_st_i8>;
defm ST_I16  : StoreBase<opcode_st_i16>;
defm ST_I32  : StoreBase<opcode_st_i32>;
defm ST_I64  : StoreBase<opcode_st_i64>;
defm ST_I128 : StoreBase<opcode_st_i128>;

multiclass StoreIprel<opcode_opx Opc, InstrItinClass itin = IIC_st>
{
  // ip + forward displacement
  let mayStore = 1 in
  def NAME : PRIMARY_RaI28<Opc, (outs), (ins GR:$ra, uimm28:$imm),
        !strconcat(Opc.mnem, " $ra, $imm"), [], itin>;

  // ip + forward displacement extended
  let mayStore = 1 in
  def NAME # _EXT : PRIMARY_RaI28_ext<Opc, (outs), (ins GR:$ra, uimm28_ext:$imm),
        !strconcat(Opc.mnem, ".l $ra, $imm"), [], itin>;
}

defm ST_IPREL_I8   : StoreIprel<opcode_st_iprel_i8>;
defm ST_IPREL_I16  : StoreIprel<opcode_st_iprel_i16>;
defm ST_IPREL_I32  : StoreIprel<opcode_st_iprel_i32>;
defm ST_IPREL_I64  : StoreIprel<opcode_st_iprel_i64>;
defm ST_IPREL_I128 : StoreIprel<opcode_st_iprel_i128>;

multiclass StoreModifyAfter<misc_opx Opc, InstrItinClass itin = IIC_st>
{
  // base with base post-update immediate
  let mayStore = 1, isPostIncrement = 1, Constraints = "$rx = $rb" in
  def NAME : MISC_RabI10<Opc, (outs GR:$rx), (ins GR:$ra, GR:$rb, stride_imm:$imm),
        !strconcat(Opc.mnem, " $ra, $rb, $imm"), [], itin>;

  // base with base post-update immediate (extended)
  let mayStore = 1, isPostIncrement = 1, Constraints = "$rx = $rb" in
  def NAME # _EXT : MISC_RabI10_ext<Opc, (outs GR:$rx), (ins GR:$ra, GR:$rb, stride_imm_ext:$imm),
        !strconcat(Opc.mnem, ".l $ra, $rb, $imm"), [], itin>;
}

defm ST_MIA_I8   : StoreModifyAfter<opcode_st_mia_i8>;
defm ST_MIA_I16  : StoreModifyAfter<opcode_st_mia_i16>;
defm ST_MIA_I32  : StoreModifyAfter<opcode_st_mia_i32>;
defm ST_MIA_I64  : StoreModifyAfter<opcode_st_mia_i64>;
defm ST_MIA_I128 : StoreModifyAfter<opcode_st_mia_i128>;

multiclass StoreModifyBefore<misc_opx Opc, InstrItinClass itin = IIC_st>
{
  // base with base pre-update immediate
  let mayStore = 1, isPreIncrement = 1, Constraints = "$rx = $rb" in
  def NAME : MISC_RabI10<Opc, (outs GR:$rx), (ins GR:$ra, GR:$rb, stride_imm:$imm),
        !strconcat(Opc.mnem, " $ra, $rb, $imm"), [], itin>;

  // base with base pre-update immediate (extended)
  let mayStore = 1, isPreIncrement = 1, Constraints = "$rx = $rb" in
  def NAME # _EXT : MISC_RabI10_ext<Opc, (outs GR:$rx), (ins GR:$ra, GR:$rb, stride_imm_ext:$imm),
        !strconcat(Opc.mnem, ".l $ra, $rb, $imm"), [], itin>;
}

defm ST_MIB_I8   : StoreModifyAfter<opcode_st_mib_i8>;
defm ST_MIB_I16  : StoreModifyAfter<opcode_st_mib_i16>;
defm ST_MIB_I32  : StoreModifyAfter<opcode_st_mib_i32>;
defm ST_MIB_I64  : StoreModifyAfter<opcode_st_mib_i64>;
defm ST_MIB_I128 : StoreModifyAfter<opcode_st_mib_i128>;

multiclass StoreIndexedI64<mem_xi64_opx Opc, InstrItinClass itin = IIC_iu_instr>
{
  // base + scaled 64-bit index + displacement
  let mayStore = 1, isIndexedMemAccess = 1 in
  def NAME : PRIMARY_Indexed_DS<Opc, (outs), (ins GR:$ra, GR:$rb, GR:$rc, scale:$scale, indexed_disp:$imm),
        !strconcat(Opc.mnem, " $ra, $rb, $rc, $scale, $imm"), [], itin>;

  // base + scaled 64-bit index + displacement extended
  let mayStore = 1, isIndexedMemAccess = 1 in
  def NAME # _EXT : PRIMARY_Indexed_DS_Long<Opc, (outs), (ins GR:$ra, GR:$rb, GR:$rc, scale:$scale, indexed_disp_ext:$imm),
        !strconcat(Opc.mnem, ".l $ra, $rb, $rc, $scale, $imm"), [], itin>;
}

defm ST_XI64_I8   : StoreIndexedI64<opcode_st_xi64_i8>;
defm ST_XI64_I16  : StoreIndexedI64<opcode_st_xi64_i16>;
defm ST_XI64_I32  : StoreIndexedI64<opcode_st_xi64_i32>;
defm ST_XI64_I64  : StoreIndexedI64<opcode_st_xi64_i64>;
defm ST_XI64_I128 : StoreIndexedI64<opcode_st_xi64_i128>;

multiclass StoreIndexedI32<mem_xi32_opx Opc, InstrItinClass itin = IIC_iu_instr>
{
  // base + scaled signed 32-bit index + displacement
  let mayStore = 1, isIndexedMemAccess = 1 in
  def NAME : PRIMARY_Indexed_WS<Opc, (outs), (ins GR:$ra, GR:$rb, GR:$rc, scale:$scale, indexed_disp:$imm),
        !strconcat(Opc.mnem, " $ra, $rb, $rc, $scale, $imm"), [], itin>;

  // base + scaled signed 32-bit index + displacement extended
  let mayStore = 1, isIndexedMemAccess = 1 in
  def NAME # _EXT : PRIMARY_Indexed_WS_Long<Opc, (outs), (ins GR:$ra, GR:$rb, GR:$rc, scale:$scale, indexed_disp_ext:$imm),
        !strconcat(Opc.mnem, ".l $ra, $rb, $rc, $scale, $imm"), [], itin>;
}

defm ST_XI32_I8   : StoreIndexedI32<opcode_st_xi32_i8>;
defm ST_XI32_I16  : StoreIndexedI32<opcode_st_xi32_i16>;
defm ST_XI32_I32  : StoreIndexedI32<opcode_st_xi32_i32>;
defm ST_XI32_I64  : StoreIndexedI32<opcode_st_xi32_i64>;
defm ST_XI32_I128 : StoreIndexedI32<opcode_st_xi32_i128>;

multiclass StoreIndexedU32<mem_xu32_opx Opc, InstrItinClass itin = IIC_st>
{
  // base + scaled unsigned 32-bit index + displacement
  let mayStore = 1, isIndexedMemAccess = 1 in
  def NAME : PRIMARY_Indexed_WZ<Opc, (outs), (ins GR:$ra, GR:$rb, GR:$rc, scale:$scale, indexed_disp:$imm),
        !strconcat(Opc.mnem, " $ra, $rb, $rc, $scale, $imm"), [], itin>;

  // base + scaled unsigned 32-bit index + displacement extended
  let mayStore = 1, isIndexedMemAccess = 1 in
  def NAME # _EXT : PRIMARY_Indexed_WZ_Long<Opc, (outs), (ins GR:$ra, GR:$rb, GR:$rc, scale:$scale, indexed_disp_ext:$imm),
        !strconcat(Opc.mnem, ".l $ra, $rb, $rc, $scale, $imm"), [], itin>;
}

defm ST_XU32_I8   : StoreIndexedU32<opcode_st_xu32_i8>;
defm ST_XU32_I16  : StoreIndexedU32<opcode_st_xu32_i16>;
defm ST_XU32_I32  : StoreIndexedU32<opcode_st_xu32_i32>;
defm ST_XU32_I64  : StoreIndexedU32<opcode_st_xu32_i64>;
defm ST_XU32_I128 : StoreIndexedU32<opcode_st_xu32_i128>;

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

multiclass StPatI8<PatFrag StoreOp, ValueType Ty>
{
  defm : StPatBase        <StoreOp, ST_I8,       ST_I8_EXT,       Ty>;
  defm : StPatPCRel       <StoreOp, ST_IPREL_I8, ST_IPREL_I8_EXT, Ty>;
  defm : StPatIndexed_i64 <StoreOp, ST_XI64_I8,  ST_XI64_I8_EXT,  Ty, i64>;
  defm : StPatIndexed_i32 <StoreOp, ST_XI32_I8,  ST_XI32_I8_EXT,  Ty, i32, indexed_i32_sext>;
  defm : StPatIndexed_i32 <StoreOp, ST_XU32_I8,  ST_XU32_I8_EXT,  Ty, i32, indexed_i32_zext>;
  defm : StPatIndexed_i32 <StoreOp, ST_XI32_I8,  ST_XI32_I8_EXT,  Ty, i64, indexed_i64_sext>;
  defm : StPatIndexed_i32 <StoreOp, ST_XU32_I8,  ST_XU32_I8_EXT,  Ty, i64, indexed_i64_zext>;
  defm : StPatIndexed_i32 <StoreOp, ST_XU32_I8,  ST_XU32_I8_EXT,  Ty, i64, indexed_i64_trunc>;
}

multiclass StPatI16<PatFrag StoreOp, ValueType Ty>
{
  defm : StPatBase        <StoreOp, ST_I16,       ST_I16_EXT,       Ty>;
  defm : StPatPCRel       <StoreOp, ST_IPREL_I16, ST_IPREL_I16_EXT, Ty>;
  defm : StPatIndexed_i64 <StoreOp, ST_XI64_I16,  ST_XI64_I16_EXT,  Ty, i64>;
  defm : StPatIndexed_i32 <StoreOp, ST_XI32_I16,  ST_XI32_I16_EXT,  Ty, i32, indexed_i32_sext>;
  defm : StPatIndexed_i32 <StoreOp, ST_XU32_I16,  ST_XU32_I16_EXT,  Ty, i32, indexed_i32_zext>;
  defm : StPatIndexed_i32 <StoreOp, ST_XI32_I16,  ST_XI32_I16_EXT,  Ty, i64, indexed_i64_sext>;
  defm : StPatIndexed_i32 <StoreOp, ST_XU32_I16,  ST_XU32_I16_EXT,  Ty, i64, indexed_i64_zext>;
  defm : StPatIndexed_i32 <StoreOp, ST_XU32_I16,  ST_XU32_I16_EXT,  Ty, i64, indexed_i64_trunc>;
}

multiclass StPatI32<PatFrag StoreOp, ValueType Ty>
{
  defm : StPatBase        <StoreOp, ST_I32,       ST_I32_EXT,       Ty>;
  defm : StPatPCRel       <StoreOp, ST_IPREL_I32, ST_IPREL_I32_EXT, Ty>;
  defm : StPatIndexed_i64 <StoreOp, ST_XI64_I32,  ST_XI64_I32_EXT,  Ty, i64>;
  defm : StPatIndexed_i32 <StoreOp, ST_XI32_I32,  ST_XI32_I32_EXT,  Ty, i32, indexed_i32_sext>;
  defm : StPatIndexed_i32 <StoreOp, ST_XU32_I32,  ST_XU32_I32_EXT,  Ty, i32, indexed_i32_zext>;
  defm : StPatIndexed_i32 <StoreOp, ST_XI32_I32,  ST_XI32_I32_EXT,  Ty, i64, indexed_i64_sext>;
  defm : StPatIndexed_i32 <StoreOp, ST_XU32_I32,  ST_XU32_I32_EXT,  Ty, i64, indexed_i64_zext>;
  defm : StPatIndexed_i32 <StoreOp, ST_XU32_I32,  ST_XU32_I32_EXT,  Ty, i64, indexed_i64_trunc>;
}

multiclass StPatI64<PatFrag StoreOp, ValueType Ty>
{
  defm : StPatBase        <StoreOp, ST_I64,       ST_I64_EXT,       Ty>;
  defm : StPatPCRel       <StoreOp, ST_IPREL_I64, ST_IPREL_I64_EXT, Ty>;
  defm : StPatIndexed_i64 <StoreOp, ST_XI64_I64,  ST_XI64_I64_EXT,  Ty, i64>;
  defm : StPatIndexed_i32 <StoreOp, ST_XI32_I64,  ST_XI32_I64_EXT,  Ty, i32, indexed_i32_sext>;
  defm : StPatIndexed_i32 <StoreOp, ST_XU32_I64,  ST_XU32_I64_EXT,  Ty, i32, indexed_i32_zext>;
  defm : StPatIndexed_i32 <StoreOp, ST_XI32_I64,  ST_XI32_I64_EXT,  Ty, i64, indexed_i64_sext>;
  defm : StPatIndexed_i32 <StoreOp, ST_XU32_I64,  ST_XU32_I64_EXT,  Ty, i64, indexed_i64_zext>;
  defm : StPatIndexed_i32 <StoreOp, ST_XU32_I64,  ST_XU32_I64_EXT,  Ty, i64, indexed_i64_trunc>;
}

multiclass StPatI128<PatFrag StoreOp, ValueType Ty>
{
  defm : StPatBase        <StoreOp, ST_I128,       ST_I128_EXT,       Ty>;
  defm : StPatPCRel       <StoreOp, ST_IPREL_I128, ST_IPREL_I128_EXT, Ty>;
  defm : StPatIndexed_i64 <StoreOp, ST_XI64_I128,  ST_XI64_I128_EXT,  Ty, i64>;
  defm : StPatIndexed_i32 <StoreOp, ST_XI32_I128,  ST_XI32_I128_EXT,  Ty, i32, indexed_i32_sext>;
  defm : StPatIndexed_i32 <StoreOp, ST_XU32_I128,  ST_XU32_I128_EXT,  Ty, i32, indexed_i32_zext>;
  defm : StPatIndexed_i32 <StoreOp, ST_XI32_I128,  ST_XI32_I128_EXT,  Ty, i64, indexed_i64_sext>;
  defm : StPatIndexed_i32 <StoreOp, ST_XU32_I128,  ST_XU32_I128_EXT,  Ty, i64, indexed_i64_zext>;
  defm : StPatIndexed_i32 <StoreOp, ST_XU32_I128,  ST_XU32_I128_EXT,  Ty, i64, indexed_i64_trunc>;
}

// TODO: patterns for stXmia/stXmib

defm STB : StPatI8<store,         i1>;
defm STB : StPatI8<truncstorei8,  i32>;
defm STB : StPatI8<truncstorei8,  i64>;
defm STB : StPatI8<truncstorei8,  i128>;

defm STH : StPatI16<truncstorei16, i32>;
defm STH : StPatI16<truncstorei16, i64>;
defm STH : StPatI16<truncstorei16, i128>;

defm STW : StPatI32<store,         i32>;
defm STW : StPatI32<truncstorei32, i64>;
defm STW : StPatI32<truncstorei32, i128>;
defm STD : StPatI64<store,         i64>;
defm STD : StPatI64<truncstorei64, i128>;
defm STQ : StPatI128<store,         i128>;

defm STH : StPatI16<store, f16>;
defm STW : StPatI32<store, f32>;
defm STD : StPatI64<store, f64>;
defm STQ : StPatI128<store, f128>;

defm STQ : StPatI128<store, v8f16>;
defm STQ : StPatI128<store, v4f32>;
defm STQ : StPatI128<store, v2f64>;
defm STQ : StPatI128<store, v16i8>;
defm STQ : StPatI128<store, v8i16>;
defm STQ : StPatI128<store, v4i32>;
defm STQ : StPatI128<store, v2i64>;

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

defm : LdaxPatIndexed_i64 <LDA_XI64, LDA_XI64_EXT, i64>;
defm : LdaxPatIndexed_i32 <LDA_XI32, LDA_XI32_EXT, i32, indexed_i32_sext>;
defm : LdaxPatIndexed_i32 <LDA_XU32, LDA_XU32_EXT, i32, indexed_i32_zext>;
defm : LdaxPatIndexed_i32 <LDA_XI32, LDA_XI32_EXT, i64, indexed_i64_sext>;
defm : LdaxPatIndexed_i32 <LDA_XU32, LDA_XU32_EXT, i64, indexed_i64_zext>;
defm : LdaxPatIndexed_i32 <LDA_XU32, LDA_XU32_EXT, i64, indexed_i64_trunc>;
