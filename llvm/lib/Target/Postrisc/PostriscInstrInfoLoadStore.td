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

def indexed_i32_disp_xform : SDNodeXForm<imm, [{
  return getI32Imm(N->getSExtValue(), SDLoc(N));
}]>;
def indexed_i32_disp : Operand<i32>, IntImmLeaf<i32, [{ return isSextInt(Imm, 7); }], indexed_i32_disp_xform> {
  let DecoderMethod = "DecodeSIMM<7>";
}

// simm49 extended (7+42) immediate (indexed_disp_ext)
def indexed_disp_ext_xform : SDNodeXForm<imm, [{
  return getI64Imm(N->getSExtValue(), SDLoc(N));
}]>;
def indexed_disp_ext : Operand<i64>, IntImmLeaf<i64, [{ return isSextInt(Imm, 7+42); }], indexed_disp_ext_xform> {
  let DecoderMethod = "DecodeSIMM<7+42>";
}

def indexed_i32_disp_ext_xform : SDNodeXForm<imm, [{
  return getI64Imm(N->getSExtValue(), SDLoc(N));
}]>;
def indexed_i32_disp_ext : Operand<i32>, IntImmLeaf<i32, [{ return isSextInt(Imm, 7+42); }], indexed_i32_disp_ext_xform> {
  let DecoderMethod = "DecodeSIMM<7+42>";
}

//===----------------------------------------------------------------------===//
// base+disp instructions
//===----------------------------------------------------------------------===//
multiclass LoadBase<opcode_opx Opc, InstrItinClass itin = IIC_iu_instr>
{
  let mayLoad = 1, isBaseMemAccess = 1 in {
    def NAME : PRIMARY_RabI21<Opc, (outs GR:$ra), (ins GR:$rb, simm21:$imm),
        !strconcat(Opc.mnem, " $ra, $rb, $imm"), [], itin>;

    def NAME # _EXT : PRIMARY_RabI21_ext<Opc, (outs GR:$ra), (ins GR:$rb, simm21_ext:$imm),
        !strconcat(Opc.mnem, ".l $ra, $rb, $imm"), [], itin>;
  }
}

defm LDUB : LoadBase<opcode_ldub>;
defm LDUH : LoadBase<opcode_lduh>;
defm LDUW : LoadBase<opcode_lduw>;
defm LDUD : LoadBase<opcode_ldud>;
defm LDSB : LoadBase<opcode_ldsb>;
defm LDSH : LoadBase<opcode_ldsh>;
defm LDSW : LoadBase<opcode_ldsw>;
defm LDSD : LoadBase<opcode_ldsd>;
defm LDQ  : LoadBase<opcode_ldq>;

multiclass StoreBase<opcode_opx Opc, InstrItinClass itin = IIC_st>
{
  let mayStore = 1, isBaseMemAccess = 1 in {
    def NAME : PRIMARY_RabI21<Opc, (outs), (ins GR:$ra, GR:$rb, simm21:$imm),
        !strconcat(Opc.mnem, " $ra, $rb, $imm"), [], itin>;

    def NAME # _EXT : PRIMARY_RabI21_ext<Opc, (outs), (ins GR:$ra, GR:$rb, simm21_ext:$imm),
        !strconcat(Opc.mnem, ".l $ra, $rb, $imm"), [], itin>;
  }
}

defm STB : StoreBase<opcode_stb>;
defm STH : StoreBase<opcode_sth>;
defm STW : StoreBase<opcode_stw>;
defm STD : StoreBase<opcode_std>;
defm STQ : StoreBase<opcode_stq>;

//===----------------------------------------------------------------------===//
// IP+disp instructions
//===----------------------------------------------------------------------===//
multiclass LoadIprel<opcode_opx Opc, InstrItinClass itin = IIC_iu_instr>
{
  let mayLoad = 1 in {
    def NAME : PRIMARY_RaI28<Opc, (outs GR:$ra), (ins uimm28:$imm),
        !strconcat(Opc.mnem, " $ra, $imm"), [], itin>;

    def NAME # _EXT : PRIMARY_RaI28_ext<Opc, (outs GR:$ra), (ins uimm28_ext:$imm),
        !strconcat(Opc.mnem, ".l $ra, $imm"), [], itin>;
  }
}

defm LDUBR : LoadIprel<opcode_ldubr>;
defm LDUHR : LoadIprel<opcode_lduhr>;
defm LDUWR : LoadIprel<opcode_lduwr>;
defm LDUDR : LoadIprel<opcode_ldudr>;
defm LDSBR : LoadIprel<opcode_ldsbr>;
defm LDSHR : LoadIprel<opcode_ldshr>;
defm LDSWR : LoadIprel<opcode_ldswr>;
defm LDSDR : LoadIprel<opcode_ldsdr>;
defm LDQR  : LoadIprel<opcode_ldqr>;

multiclass StoreIprel<opcode_opx Opc, InstrItinClass itin = IIC_st>
{
  let mayStore = 1 in {
    def NAME : PRIMARY_RaI28<Opc, (outs), (ins GR:$ra, uimm28:$imm),
        !strconcat(Opc.mnem, " $ra, $imm"), [], itin>;

    def NAME # _EXT : PRIMARY_RaI28_ext<Opc, (outs), (ins GR:$ra, uimm28_ext:$imm),
        !strconcat(Opc.mnem, ".l $ra, $imm"), [], itin>;
  }
}

defm STBR : StoreIprel<opcode_stbr>;
defm STHR : StoreIprel<opcode_sthr>;
defm STWR : StoreIprel<opcode_stwr>;
defm STDR : StoreIprel<opcode_stdr>;
defm STQR : StoreIprel<opcode_stqr>;

//===----------------------------------------------------------------------===//
// base, post-offset instructions
//===----------------------------------------------------------------------===//
multiclass LoadModifyAfter<misc_opx Opc, InstrItinClass itin = IIC_iu_instr>
{
  let mayLoad = 1, isPostIncrement = 1, Constraints = "$rx = $rb" in {
    def NAME : MISC_RabI10<Opc,
        (outs GR:$ra, GR:$rx), (ins GR:$rb, stride_imm:$imm),
        !strconcat(Opc.mnem, " $ra, $rb, $imm"), [], itin>;

    def NAME # _EXT : MISC_RabI10_ext<Opc,
        (outs GR:$ra, GR:$rx), (ins GR:$rb, stride_imm_ext:$imm),
        !strconcat(Opc.mnem, ".l $ra, $rb, $imm"), [], itin>;
  }
}

defm LDUBMIA : LoadModifyAfter<opcode_ldubmia>;
defm LDUHMIA : LoadModifyAfter<opcode_lduhmia>;
defm LDUWMIA : LoadModifyAfter<opcode_lduwmia>;
defm LDUDMIA : LoadModifyAfter<opcode_ldudmia>;
defm LDSBMIA : LoadModifyAfter<opcode_ldsbmia>;
defm LDSHMIA : LoadModifyAfter<opcode_ldshmia>;
defm LDSWMIA : LoadModifyAfter<opcode_ldswmia>;
defm LDSDMIA : LoadModifyAfter<opcode_ldsdmia>;
defm LDQMIA  : LoadModifyAfter<opcode_ldqmia>;

multiclass StoreModifyAfter<misc_opx Opc, InstrItinClass itin = IIC_st>
{
  let mayStore = 1, isPostIncrement = 1, Constraints = "$rx = $rb" in {
    def NAME : MISC_RabI10<Opc,
        (outs GR:$rx), (ins GR:$ra, GR:$rb, stride_imm:$imm),
        !strconcat(Opc.mnem, " $ra, $rb, $imm"), [], itin>;

    def NAME # _EXT : MISC_RabI10_ext<Opc,
        (outs GR:$rx), (ins GR:$ra, GR:$rb, stride_imm_ext:$imm),
        !strconcat(Opc.mnem, ".l $ra, $rb, $imm"), [], itin>;
  }
}

defm STBMIA : StoreModifyAfter<opcode_stbmia>;
defm STHMIA : StoreModifyAfter<opcode_sthmia>;
defm STWMIA : StoreModifyAfter<opcode_stwmia>;
defm STDMIA : StoreModifyAfter<opcode_stdmia>;
defm STQMIA : StoreModifyAfter<opcode_stqmia>;

//===----------------------------------------------------------------------===//
// base, pre-offset instructions
//===----------------------------------------------------------------------===//
multiclass LoadModifyBefore<misc_opx Opc, InstrItinClass itin = IIC_iu_instr>
{
  let mayLoad = 1, isPreIncrement = 1, Constraints = "$rx = $rb" in {
    def NAME : MISC_RabI10<Opc,
        (outs GR:$ra, GR:$rx), (ins GR:$rb, stride_imm:$imm),
        !strconcat(Opc.mnem, " $ra, $rb, $imm"), [], itin>;

    def NAME # _EXT : MISC_RabI10_ext<Opc,
        (outs GR:$ra, GR:$rx), (ins GR:$rb, stride_imm_ext:$imm),
        !strconcat(Opc.mnem, ".l $ra, $rb, $imm"), [], itin>;
  }
}

defm LDUBMIB : LoadModifyBefore<opcode_ldubmib>;
defm LDUHMIB : LoadModifyBefore<opcode_lduhmib>;
defm LDUWMIB : LoadModifyBefore<opcode_lduwmib>;
defm LDUDMIB : LoadModifyBefore<opcode_ldudmib>;
defm LDSBMIB : LoadModifyBefore<opcode_ldsbmib>;
defm LDSHMIB : LoadModifyBefore<opcode_ldshmib>;
defm LDSWMIB : LoadModifyBefore<opcode_ldswmib>;
defm LDSDMIB : LoadModifyBefore<opcode_ldsdmib>;
defm LDQMIB  : LoadModifyBefore<opcode_ldqmib>;

multiclass StoreModifyBefore<misc_opx Opc, InstrItinClass itin = IIC_st>
{
  let mayStore = 1, isPreIncrement = 1, Constraints = "$rx = $rb" in {
    def NAME : MISC_RabI10<Opc,
        (outs GR:$rx), (ins GR:$ra, GR:$rb, stride_imm:$imm),
        !strconcat(Opc.mnem, " $ra, $rb, $imm"), [], itin>;

    def NAME # _EXT : MISC_RabI10_ext<Opc,
        (outs GR:$rx), (ins GR:$ra, GR:$rb, stride_imm_ext:$imm),
        !strconcat(Opc.mnem, ".l $ra, $rb, $imm"), [], itin>;
  }
}

defm STBMIB : StoreModifyAfter<opcode_stbmib>;
defm STHMIB : StoreModifyAfter<opcode_sthmib>;
defm STWMIB : StoreModifyAfter<opcode_stwmib>;
defm STDMIB : StoreModifyAfter<opcode_stdmib>;
defm STQMIB : StoreModifyAfter<opcode_stqmib>;

//===----------------------------------------------------------------------===//
// XI64 indexing instructions
//===----------------------------------------------------------------------===//
multiclass LoadIndexedI64<memxsd_opx Opc, InstrItinClass itin = IIC_iu_instr>
{
  let mayLoad = 1, isIndexedMemAccess = 1 in {
    def NAME : PRIMARY_Indexed_i64<Opc,
        (outs GR:$ra), (ins GR:$rb, GR:$rc, scale:$scale, indexed_disp:$imm),
        !strconcat(Opc.mnem, " $ra, $rb, $rc, $scale, $imm"), [], itin>;

    def NAME # _EXT : PRIMARY_Indexed_i64_ext<Opc,
        (outs GR:$ra), (ins GR:$rb, GR:$rc, scale:$scale, indexed_disp_ext:$imm),
        !strconcat(Opc.mnem, ".l $ra, $rb, $rc, $scale, $imm"), [], itin>;
  }
}

defm LDUBXSD : LoadIndexedI64<opcode_ldubxsd>;
defm LDUHXSD : LoadIndexedI64<opcode_lduhxsd>;
defm LDUWXSD : LoadIndexedI64<opcode_lduwxsd>;
defm LDUDXSD : LoadIndexedI64<opcode_ldudxsd>;
defm LDSBXSD : LoadIndexedI64<opcode_ldsbxsd>;
defm LDSHXSD : LoadIndexedI64<opcode_ldshxsd>;
defm LDSWXSD : LoadIndexedI64<opcode_ldswxsd>;
defm LDSDXSD : LoadIndexedI64<opcode_ldsdxsd>;
defm LDQXSD  : LoadIndexedI64<opcode_ldqxsd>;
defm LDAXSD  : LoadIndexedI64<opcode_ldaxsd>;

multiclass StoreIndexedI64<memxsd_opx Opc, InstrItinClass itin = IIC_iu_instr>
{
  let mayStore = 1, isIndexedMemAccess = 1 in {
    def NAME : PRIMARY_Indexed_i64<Opc, (outs),
        (ins GR:$ra, GR:$rb, GR:$rc, scale:$scale, indexed_disp:$imm),
        !strconcat(Opc.mnem, " $ra, $rb, $rc, $scale, $imm"), [], itin>;

    def NAME # _EXT : PRIMARY_Indexed_i64_ext<Opc, (outs),
        (ins GR:$ra, GR:$rb, GR:$rc, scale:$scale, indexed_disp_ext:$imm),
        !strconcat(Opc.mnem, ".l $ra, $rb, $rc, $scale, $imm"), [], itin>;
  }
}

defm STBXSD : StoreIndexedI64<opcode_stbxsd>;
defm STHXSD : StoreIndexedI64<opcode_sthxsd>;
defm STWXSD : StoreIndexedI64<opcode_stwxsd>;
defm STDXSD : StoreIndexedI64<opcode_stdxsd>;
defm STQXSD : StoreIndexedI64<opcode_stqxsd>;

//===----------------------------------------------------------------------===//
// XU64 indexing instructions
//===----------------------------------------------------------------------===//
multiclass LoadIndexedU64<memxud_opx Opc, InstrItinClass itin = IIC_iu_instr>
{
  let mayLoad = 1, isIndexedMemAccess = 1 in
  def NAME : PRIMARY_Indexed_u64<Opc,
        (outs GR:$ra), (ins GR:$rb, GR:$rc, scale:$scale, indexed_disp:$imm),
        !strconcat(Opc.mnem, " $ra, $rb, $rc, $scale, $imm"), [], itin>;

  let mayLoad = 1, isIndexedMemAccess = 1 in
  def NAME # _EXT : PRIMARY_Indexed_u64_ext<Opc,
        (outs GR:$ra), (ins GR:$rb, GR:$rc, scale:$scale, indexed_disp_ext:$imm),
        !strconcat(Opc.mnem, ".l $ra, $rb, $rc, $scale, $imm"), [], itin>;
}

defm LDUBXUD : LoadIndexedU64<opcode_ldubxud>;
defm LDUHXUD : LoadIndexedU64<opcode_lduhxud>;
defm LDUWXUD : LoadIndexedU64<opcode_lduwxud>;
defm LDUDXUD : LoadIndexedU64<opcode_ldudxud>;
defm LDSBXUD : LoadIndexedU64<opcode_ldsbxud>;
defm LDSHXUD : LoadIndexedU64<opcode_ldshxud>;
defm LDSWXUD : LoadIndexedU64<opcode_ldswxud>;
defm LDSDXUD : LoadIndexedU64<opcode_ldsdxud>;
defm LDQXUD  : LoadIndexedU64<opcode_ldqxud>;
defm LDAXUD  : LoadIndexedU64<opcode_ldaxud>;

multiclass StoreIndexedU64<memxud_opx Opc, InstrItinClass itin = IIC_iu_instr>
{
  let mayStore = 1, isIndexedMemAccess = 1 in {
    def NAME : PRIMARY_Indexed_u64<Opc, (outs),
        (ins GR:$ra, GR:$rb, GR:$rc, scale:$scale, indexed_disp:$imm),
        !strconcat(Opc.mnem, " $ra, $rb, $rc, $scale, $imm"), [], itin>;

    def NAME # _EXT : PRIMARY_Indexed_u64_ext<Opc, (outs),
        (ins GR:$ra, GR:$rb, GR:$rc, scale:$scale, indexed_disp_ext:$imm),
        !strconcat(Opc.mnem, ".l $ra, $rb, $rc, $scale, $imm"), [], itin>;
  }
}

defm STBXUD : StoreIndexedU64<opcode_stbxud>;
defm STHXUD : StoreIndexedU64<opcode_sthxud>;
defm STWXUD : StoreIndexedU64<opcode_stwxud>;
defm STDXUD : StoreIndexedU64<opcode_stdxud>;
defm STQXUD : StoreIndexedU64<opcode_stqxud>;

//===----------------------------------------------------------------------===//
// XI32 indexing instructions
//===----------------------------------------------------------------------===//
multiclass LoadIndexedI32<memxsw_opx Opc, InstrItinClass itin = IIC_iu_instr>
{
  let mayLoad = 1, isIndexedMemAccess = 1 in {
    def NAME : PRIMARY_Indexed_i32<Opc,
        (outs GR:$ra), (ins GR:$rb, GR:$rc, scale:$scale, indexed_disp:$imm),
        !strconcat(Opc.mnem, " $ra, $rb, $rc, $scale, $imm"), [], itin>;

    def NAME # _EXT : PRIMARY_Indexed_i32_ext<Opc,
        (outs GR:$ra), (ins GR:$rb, GR:$rc, scale:$scale, indexed_disp_ext:$imm),
        !strconcat(Opc.mnem, ".l $ra, $rb, $rc, $scale, $imm"), [], itin>;
  }
}

defm LDUBXSW : LoadIndexedI32<opcode_ldubxsw>;
defm LDUHXSW : LoadIndexedI32<opcode_lduhxsw>;
defm LDUWXSW : LoadIndexedI32<opcode_lduwxsw>;
defm LDUDXSW : LoadIndexedI32<opcode_ldudxsw>;
defm LDSBXSW : LoadIndexedI32<opcode_ldsbxsw>;
defm LDSHXSW : LoadIndexedI32<opcode_ldshxsw>;
defm LDSWXSW : LoadIndexedI32<opcode_ldswxsw>;
defm LDSDXSW : LoadIndexedI32<opcode_ldsdxsw>;
defm LDQXSW  : LoadIndexedI32<opcode_ldqxsw>;
defm LDAXSW  : LoadIndexedI32<opcode_ldaxsw>;

multiclass StoreIndexedI32<memxsw_opx Opc, InstrItinClass itin = IIC_iu_instr>
{
  let mayStore = 1, isIndexedMemAccess = 1 in {
    def NAME : PRIMARY_Indexed_i32<Opc, (outs),
                    (ins GR:$ra, GR:$rb, GR:$rc, scale:$scale, indexed_disp:$imm),
                    !strconcat(Opc.mnem, " $ra, $rb, $rc, $scale, $imm"), [], itin>;

    def NAME # _EXT : PRIMARY_Indexed_i32_ext<Opc, (outs),
                    (ins GR:$ra, GR:$rb, GR:$rc, scale:$scale, indexed_disp_ext:$imm),
                    !strconcat(Opc.mnem, ".l $ra, $rb, $rc, $scale, $imm"), [], itin>;
  }
}

defm STBXSW : StoreIndexedI32<opcode_stbxsw>;
defm STHXSW : StoreIndexedI32<opcode_sthxsw>;
defm STWXSW : StoreIndexedI32<opcode_stwxsw>;
defm STDXSW : StoreIndexedI32<opcode_stdxsw>;
defm STQXSW : StoreIndexedI32<opcode_stqxsw>;

//===----------------------------------------------------------------------===//
// XU32 indexing instructions
//===----------------------------------------------------------------------===//
multiclass LoadIndexedU32<memxuw_opx Opc, InstrItinClass itin = IIC_iu_instr>
{
  let mayLoad = 1, isIndexedMemAccess = 1 in {
    def NAME : PRIMARY_Indexed_u32<Opc,
        (outs GR:$ra), (ins GR:$rb, GR:$rc, scale:$scale, indexed_i32_disp:$imm),
        !strconcat(Opc.mnem, " $ra, $rb, $rc, $scale, $imm"), [], itin>;

    def NAME # _EXT : PRIMARY_Indexed_u32_ext<Opc,
        (outs GR:$ra), (ins GR:$rb, GR:$rc, scale:$scale, indexed_i32_disp_ext:$imm),
        !strconcat(Opc.mnem, ".l $ra, $rb, $rc, $scale, $imm"), [], itin>;
  }
}

defm LDUBXUW : LoadIndexedU32<opcode_ldubxuw>;
defm LDUHXUW : LoadIndexedU32<opcode_lduhxuw>;
defm LDUWXUW : LoadIndexedU32<opcode_lduwxuw>;
defm LDUDXUW : LoadIndexedU32<opcode_ldudxuw>;
defm LDSBXUW : LoadIndexedU32<opcode_ldsbxuw>;
defm LDSHXUW : LoadIndexedU32<opcode_ldshxuw>;
defm LDSWXUW : LoadIndexedU32<opcode_ldswxuw>;
defm LDSDXUW : LoadIndexedU32<opcode_ldsdxuw>;
defm LDQXUW  : LoadIndexedU32<opcode_ldqxuw>;
defm LDAXUW  : LoadIndexedU32<opcode_ldaxuw>;

multiclass StoreIndexedU32<memxuw_opx Opc, InstrItinClass itin = IIC_st>
{
  let mayStore = 1, isIndexedMemAccess = 1 in {
    def NAME : PRIMARY_Indexed_u32<Opc, (outs),
                    (ins GR:$ra, GR:$rb, GR:$rc, scale:$scale, indexed_i32_disp:$imm),
                    !strconcat(Opc.mnem, " $ra, $rb, $rc, $scale, $imm"), [], itin>;

    def NAME # _EXT : PRIMARY_Indexed_u32_ext<Opc, (outs),
                    (ins GR:$ra, GR:$rb, GR:$rc, scale:$scale, indexed_i32_disp_ext:$imm),
                    !strconcat(Opc.mnem, ".l $ra, $rb, $rc, $scale, $imm"), [], itin>;
  }
}

defm STBXUW : StoreIndexedU32<opcode_stbxuw>;
defm STHXUW : StoreIndexedU32<opcode_sthxuw>;
defm STWXUW : StoreIndexedU32<opcode_stwxuw>;
defm STDXUW : StoreIndexedU32<opcode_stdxuw>;
defm STQXUW : StoreIndexedU32<opcode_stqxuw>;

//===----------------------------------------------------------------------===//
// Load/Store patterns.
//===----------------------------------------------------------------------===//
multiclass LdPatBase<PatFrag Op, InstBase Inst, InstBaseExt InstExt, ValueType Ty>
{
  def : Pat<(Ty (Op (add    i64:$rb, simm21:$imm))), (Inst     GR:$rb, simm21:$imm)>;
  def : Pat<(Ty (Op (add AddrFI:$rb, simm21:$imm))), (Inst AddrFI:$rb, simm21:$imm)>;
  def : Pat<(Ty (Op    i64:$rb)), (Inst     GR:$rb, 0)>;
  def : Pat<(Ty (Op AddrFI:$rb)), (Inst AddrFI:$rb, 0)>;
  def : Pat<(Ty (Op (add    i64:$rb, simm21_ext:$imm))), (InstExt     GR:$rb, simm21_ext:$imm)>;
  def : Pat<(Ty (Op (add AddrFI:$rb, simm21_ext:$imm))), (InstExt AddrFI:$rb, simm21_ext:$imm)>;
  def : Pat<(Ty (Op (add i64:$rb, (tls_offset_wrapper     tglobaltlsaddr:$addr)))), (Inst    GR:$rb, tglobaltlsaddr:$addr)>;
  def : Pat<(Ty (Op (add i64:$rb, (tls_offset_wrapper_ext tglobaltlsaddr:$addr)))), (InstExt GR:$rb, tglobaltlsaddr:$addr)>;
}

multiclass StPatBase<PatFrag Op, InstBase Inst, InstBaseExt InstExt, ValueType Ty>
{
  def : Pat<(Op Ty:$ra, (add         i64:$rb,  simm21:$imm)), (Inst GR:$ra,     GR:$rb, simm21:$imm)>;
  def : Pat<(Op Ty:$ra, (add (i64 AddrFI:$rb), simm21:$imm)), (Inst GR:$ra, AddrFI:$rb, simm21:$imm)>;
  def : Pat<(Op Ty:$ra,         i64:$rb ), (Inst GR:$ra,     GR:$rb, 0)>;
  def : Pat<(Op Ty:$ra, (i64 AddrFI:$rb)), (Inst GR:$ra, AddrFI:$rb, 0)>;
  def : Pat<(Op Ty:$ra, (add         i64:$rb , simm21_ext:$imm)), (InstExt GR:$ra,     GR:$rb, simm21_ext:$imm)>;
  def : Pat<(Op Ty:$ra, (add (i64 AddrFI:$rb), simm21_ext:$imm)), (InstExt GR:$ra, AddrFI:$rb, simm21_ext:$imm)>;

  def : Pat<(Op Ty:$ra, (add i64:$rb, (tls_offset_wrapper     tglobaltlsaddr:$addr))), (Inst    GR:$ra, GR:$rb, tglobaltlsaddr:$addr)>;
  def : Pat<(Op Ty:$ra, (add i64:$rb, (tls_offset_wrapper_ext tglobaltlsaddr:$addr))), (InstExt GR:$ra, GR:$rb, tglobaltlsaddr:$addr)>;
}

//===----------------------------------------------------------------------===//
// IP-relative addressing patterns.
//===----------------------------------------------------------------------===//
multiclass LdPatPCRel<PatFrag Op, InstBase Inst, InstBaseExt Inst_ext, ValueType Ty>
{
  // global/external address should be properly wrapped into corresponding PCREL wrapper
  def : Pat<(Ty (Op (pcrel_data_wrapper    tglobaladdr:$addr))), (Inst    tglobaladdr:$addr)>;
  def : Pat<(Ty (Op (pcrel_data_wrapper     tconstpool:$addr))), (Inst     tconstpool:$addr)>;
  def : Pat<(Ty (Op (pcrel_data_wrapper   texternalsym:$addr))), (Inst   texternalsym:$addr)>;
  def : Pat<(Ty (Op (pcrel_data_wrapper tglobaltlsaddr:$addr))), (Inst tglobaltlsaddr:$addr)>;
  def : Pat<(Ty (Op (pcrel_data_wrapper     tjumptable:$addr))), (Inst     tjumptable:$addr)>;

  def : Pat<(Ty (Op (pcrel_data_wrapper_ext    tglobaladdr:$addr))), (Inst_ext    tglobaladdr:$addr)>;
  def : Pat<(Ty (Op (pcrel_data_wrapper_ext     tconstpool:$addr))), (Inst_ext     tconstpool:$addr)>;
  def : Pat<(Ty (Op (pcrel_data_wrapper_ext   texternalsym:$addr))), (Inst_ext   texternalsym:$addr)>;
  def : Pat<(Ty (Op (pcrel_data_wrapper_ext tglobaltlsaddr:$addr))), (Inst_ext tglobaltlsaddr:$addr)>;
  def : Pat<(Ty (Op (pcrel_data_wrapper_ext     tjumptable:$addr))), (Inst_ext     tjumptable:$addr)>;
}

multiclass StPatPCRel<PatFrag Op, InstBase Inst, InstBaseExt Inst_ext, ValueType Ty>
{
  // global/external address should be properly wrapped into corresponding PCREL wrapper (_EXT or nothing)
  def : Pat<(Op Ty:$ra, (pcrel_data_wrapper  tglobaladdr:$addr)), (Inst GR:$ra,  tglobaladdr:$addr)>;
  def : Pat<(Op Ty:$ra, (pcrel_data_wrapper   tconstpool:$addr)), (Inst GR:$ra,   tconstpool:$addr)>;
  def : Pat<(Op Ty:$ra, (pcrel_data_wrapper texternalsym:$addr)), (Inst GR:$ra, texternalsym:$addr)>;

  def : Pat<(Op Ty:$ra, (pcrel_data_wrapper_ext  tglobaladdr:$addr)), (Inst_ext GR:$ra,  tglobaladdr:$addr)>;
  def : Pat<(Op Ty:$ra, (pcrel_data_wrapper_ext   tconstpool:$addr)), (Inst_ext GR:$ra,   tconstpool:$addr)>;
  def : Pat<(Op Ty:$ra, (pcrel_data_wrapper_ext texternalsym:$addr)), (Inst_ext GR:$ra, texternalsym:$addr)>;
}

//===----------------------------------------------------------------------===//
// Universal i32/i64 indexing patterns
//===----------------------------------------------------------------------===//
multiclass
LoadAddressIndexed<PatFrag BIDS, PatFrag BIDS2,
    PatFrag BID, PatFrag BID2, PatFrag BIS, PatFrag BI,
    InstBase Inst, InstBaseExt InstExt,
    ValueType IndexTy, Operand dispOp, Operand dispOpExt>
{
  // base + scaled_index + disp
  def : Pat<(BIDS i64:$base, IndexTy:$index, scale:$scale, dispOp:$disp),
            (Inst GR:$base, GR:$index, scale:$scale, dispOp:$disp)>;
  def : Pat<(BIDS i64:$base, IndexTy:$index, scale:$scale, dispOpExt:$disp),
            (InstExt GR:$base, GR:$index, scale:$scale, dispOpExt:$disp)>;

  def : Pat<(BIDS2 i64:$base, IndexTy:$index, scale:$scale, dispOp:$disp),
            (Inst GR:$base, GR:$index, scale:$scale, dispOp:$disp)>;
  def : Pat<(BIDS2 i64:$base, IndexTy:$index, scale:$scale, dispOpExt:$disp),
            (InstExt GR:$base, GR:$index, scale:$scale, dispOpExt:$disp)>;

  // base + index + disp
  def : Pat<(BID i64:$base, IndexTy:$index, dispOp:$disp),
            (Inst GR:$base, GR:$index, 0, dispOp:$disp)>;
  def : Pat<(BID i64:$base, IndexTy:$index, dispOpExt:$disp),
            (InstExt GR:$base, GR:$index, 0, dispOpExt:$disp)>;

  def : Pat<(BID2 i64:$base, IndexTy:$index, dispOp:$disp),
            (Inst GR:$base, GR:$index, 0, dispOp:$disp)>;
  def : Pat<(BID2 i64:$base, IndexTy:$index, dispOpExt:$disp),
            (InstExt GR:$base, GR:$index, 0, dispOpExt:$disp)>;

  // base + scaled_index (no extended variant)
  def : Pat<(BIS i64:$base, IndexTy:$index, scale:$scale),
            (Inst GR:$base, GR:$index, scale:$scale, 0)>;

  def : Pat<(BI i64:$base, IndexTy:$index),
            (Inst GR:$base, GR:$index, 0, 0)>;
}

multiclass LoadIndexed<PatFrag BIDS, PatFrag BIDS2,
    PatFrag BID, PatFrag BID2, PatFrag BIS, PatFrag BI,
    PatFrag Op, InstBase Inst, InstBaseExt InstExt,
    ValueType Ty, ValueType IndexTy, Operand dispOp, Operand dispOpExt>
{
  // base + scaled_index + disp
  def : Pat<(Ty (Op (BIDS i64:$base, IndexTy:$index, scale:$scale, dispOp:$disp))),
            (Inst GR:$base, GR:$index, scale:$scale, dispOp:$disp)>;
  def : Pat<(Ty (Op (BIDS i64:$base, IndexTy:$index, scale:$scale, dispOpExt:$disp))),
            (InstExt GR:$base, GR:$index, scale:$scale, dispOpExt:$disp)>;

  def : Pat<(Ty (Op (BIDS2 i64:$base, IndexTy:$index, scale:$scale, dispOp:$disp))),
            (Inst GR:$base, GR:$index, scale:$scale, dispOp:$disp)>;
  def : Pat<(Ty (Op (BIDS2 i64:$base, IndexTy:$index, scale:$scale, dispOpExt:$disp))),
            (InstExt GR:$base, GR:$index, scale:$scale, dispOpExt:$disp)>;

  // base + index + disp
  def : Pat<(Ty (Op (BID i64:$base, IndexTy:$index, dispOp:$disp))),
            (Inst GR:$base, GR:$index, 0, dispOp:$disp)>;
  def : Pat<(Ty (Op (BID i64:$base, IndexTy:$index, dispOpExt:$disp))),
            (InstExt GR:$base, GR:$index, 0, dispOpExt:$disp)>;

  def : Pat<(Ty (Op (BID2 i64:$base, IndexTy:$index, dispOp:$disp))),
            (Inst GR:$base, GR:$index, 0, dispOp:$disp)>;
  def : Pat<(Ty (Op (BID2 i64:$base, IndexTy:$index, dispOpExt:$disp))),
            (InstExt GR:$base, GR:$index, 0, dispOpExt:$disp)>;

  // base + scaled_index (no extended variant)
  def : Pat<(Ty (Op (BIS i64:$base, IndexTy:$index, scale:$scale))),
            (Inst GR:$base, GR:$index, scale:$scale, 0)>;

  // base + index (no extended variant)
  def : Pat<(Ty (Op (BI i64:$base, IndexTy:$index))),
            (Inst GR:$base, GR:$index, 0, 0)>;
}

multiclass StoreIndexed<PatFrag BIDS, PatFrag BIDS2,
    PatFrag BID, PatFrag BID2, PatFrag BIS, PatFrag BI,
    PatFrag Op, InstBase Inst, InstBaseExt InstExt,
 ValueType Ty, ValueType IndexTy, Operand dispOp, Operand dispOpExt>
{
  def : Pat<(Op Ty:$ra, (BIDS i64:$base, IndexTy:$index, scale:$scale, dispOp:$disp)),
            (Inst GR:$ra, GR:$base, GR:$index, scale:$scale, dispOp:$disp)>;
  def : Pat<(Op Ty:$ra, (BIDS i64:$base, IndexTy:$index, scale:$scale, dispOpExt:$disp)),
            (InstExt GR:$ra, GR:$base, GR:$index, scale:$scale, dispOpExt:$disp)>;

  def : Pat<(Op Ty:$ra, (BIDS2 i64:$base, IndexTy:$index, scale:$scale, dispOp:$disp)),
            (Inst GR:$ra, GR:$base, GR:$index, scale:$scale, dispOp:$disp)>;
  def : Pat<(Op Ty:$ra, (BIDS2 i64:$base, IndexTy:$index, scale:$scale, dispOpExt:$disp)),
            (InstExt GR:$ra, GR:$base, GR:$index, scale:$scale, dispOpExt:$disp)>;

  def : Pat<(Op Ty:$ra, (BID i64:$base, IndexTy:$index, dispOp:$disp)),
            (Inst GR:$ra, GR:$base, GR:$index, 0, dispOp:$disp)>;
  def : Pat<(Op Ty:$ra, (BID i64:$base, IndexTy:$index, dispOpExt:$disp)),
            (InstExt GR:$ra, GR:$base, GR:$index, 0, dispOpExt:$disp)>;

  def : Pat<(Op Ty:$ra, (BID2 i64:$base, IndexTy:$index, dispOp:$disp)),
            (Inst GR:$ra, GR:$base, GR:$index, 0, dispOp:$disp)>;
  def : Pat<(Op Ty:$ra, (BID2 i64:$base, IndexTy:$index, dispOpExt:$disp)),
            (InstExt GR:$ra, GR:$base, GR:$index, 0, dispOpExt:$disp)>;

  def : Pat<(Op Ty:$ra, (BIS i64:$base, IndexTy:$index, scale:$scale)),
            (Inst GR:$ra, GR:$base, GR:$index, scale:$scale, 0)>;

  def : Pat<(Op Ty:$ra, (BI i64:$base, IndexTy:$index)),
            (Inst GR:$ra, GR:$base, GR:$index, 0, 0)>;
}

//===----------------------------------------------------------------------===//
// XI64 indexing
// XI64: base + (index << scale) + disp
//===----------------------------------------------------------------------===//
def XI64_BIDS  : PatFrag<(ops node:$base, node:$index, node:$scale, node:$disp), (i64 (add (add node:$base,      (shl node:$index, node:$scale)), node:$disp) )>;
def XI64_BIDS2 : PatFrag<(ops node:$base, node:$index, node:$scale, node:$disp), (i64 (add      node:$base, (add (shl node:$index, node:$scale),  node:$disp)))>;
def XI64_BID   : PatFrag<(ops node:$base, node:$index,              node:$disp), (i64 (add (add node:$base,           node:$index),               node:$disp) )>;
def XI64_BID2  : PatFrag<(ops node:$base, node:$index,              node:$disp), (i64 (add      node:$base, (add      node:$index,                node:$disp)))>;
def XI64_BIS   : PatFrag<(ops node:$base, node:$index, node:$scale            ), (i64 (add      node:$base,      (shl node:$index, node:$scale)              ))>;
def XI64_BI    : PatFrag<(ops node:$base, node:$index                         ), (i64 (add      node:$base,           node:$index))>;

defm : LoadAddressIndexed<XI64_BIDS, XI64_BIDS2, XI64_BID, XI64_BID2, XI64_BIS, XI64_BI,
                          LDAXSD, LDAXSD_EXT, i64, indexed_disp, indexed_disp_ext>;

//===----------------------------------------------------------------------===//
// XI32 indexing
// XI64: base + (SEXT(index) << scale) + disp
//===----------------------------------------------------------------------===//
def Sext64Index : PatFrag<(ops node:$index), (i64 (sext node:$index))>;
//def indexed_i64_sext  : PatFrag<(ops node:$index), (sext_inreg node:$index, i32)>;

def XI32_BIDS  : PatFrag<(ops node:$base, node:$index, node:$scale, node:$disp), (i64 (add (add node:$base,      (shl (Sext64Index node:$index), node:$scale)), node:$disp) )>;
def XI32_BIDS2 : PatFrag<(ops node:$base, node:$index, node:$scale, node:$disp), (i64 (add      node:$base, (add (shl (Sext64Index node:$index), node:$scale ), node:$disp)))>;
def XI32_BID   : PatFrag<(ops node:$base, node:$index,              node:$disp), (i64 (add (add node:$base,           (Sext64Index node:$index)              ), node:$disp) )>;
def XI32_BID2  : PatFrag<(ops node:$base, node:$index,              node:$disp), (i64 (add      node:$base, (add      (Sext64Index node:$index),                node:$disp)))>;
def XI32_BIS   : PatFrag<(ops node:$base, node:$index, node:$scale            ), (i64 (add      node:$base,      (shl (Sext64Index node:$index), node:$scale))              )>;
def XI32_BI    : PatFrag<(ops node:$base, node:$index                         ), (i64 (add      node:$base,           (Sext64Index node:$index)                            ))>;

defm : LoadAddressIndexed<XI32_BIDS, XI32_BIDS2, XI32_BID, XI32_BID2, XI32_BIS, XI32_BI,
                          LDAXSW, LDAXSW_EXT, i32, indexed_disp, indexed_disp_ext>;

//===----------------------------------------------------------------------===//
// XU64 indexing
// XU64: base + ((index + disp) << scale)
//===----------------------------------------------------------------------===//
def XU64_BIDS  : PatFrag<(ops node:$base, node:$index, node:$scale, node:$disp), (i64 (add      node:$base, (shl (add node:$index,  node:$disp), node:$scale)))>;
def XU64_BIDS2 : PatFrag<(ops node:$base, node:$index, node:$scale, node:$disp), (i64 (add      node:$base, (shl (add node:$index,  node:$disp), node:$scale)))>;
def XU64_BID   : PatFrag<(ops node:$base, node:$index,              node:$disp), (i64 (add      node:$base,      (add node:$index,  node:$disp)              ))>;
def XU64_BID2  : PatFrag<(ops node:$base, node:$index,              node:$disp), (i64 (add (add node:$base,           node:$index), node:$disp)               )>;
def XU64_BIS   : PatFrag<(ops node:$base, node:$index, node:$scale            ), (i64 (add      node:$base, (shl      node:$index,               node:$scale)))>;
def XU64_BI    : PatFrag<(ops node:$base, node:$index                         ), (i64 (add      node:$base,           node:$index                            ))>;

defm : LoadAddressIndexed<XU64_BIDS, XU64_BIDS2, XU64_BID, XU64_BID2, XU64_BIS, XU64_BI,
                          LDAXUD, LDAXUD_EXT, i64, indexed_disp, indexed_disp_ext>;

//===----------------------------------------------------------------------===//
// XU32 indexing
// XU32: base + (ZEXT(index + disp) << scale)
//===----------------------------------------------------------------------===//
def Zext64Index : PatFrag<(ops node:$index), (i64 (zext node:$index))>;

def XU32_BIDS  : PatFrag<(ops node:$base, node:$index, node:$scale, node:$disp), (i64 (add node:$base, (shl (Zext64Index (add node:$index, node:$disp)), node:$scale)))>;
def XU32_BIDS2 : PatFrag<(ops node:$base, node:$index, node:$scale, node:$disp), (i64 (add node:$base, (shl (Zext64Index (add node:$index, node:$disp)), node:$scale)))>;
def XU32_BID   : PatFrag<(ops node:$base, node:$index,              node:$disp), (i64 (add node:$base,      (Zext64Index (add node:$index, node:$disp))              ))>;
def XU32_BID2  : PatFrag<(ops node:$base, node:$index,              node:$disp), (i64 (add node:$base,      (Zext64Index (add node:$index, node:$disp))              ))>;
def XU32_BIS   : PatFrag<(ops node:$base, node:$index, node:$scale            ), (i64 (add node:$base, (shl (Zext64Index      node:$index             ), node:$scale)))>;
def XU32_BI    : PatFrag<(ops node:$base, node:$index                         ), (i64 (add node:$base,      (Zext64Index      node:$index             )              ))>;

//def indexed_i32_zext  : PatFrag<(ops node:$index), (i64 (zext node:$index))>;
//def indexed_i64_zext  : PatFrag<(ops node:$index), (i64 (zext (i32 (trunc node:$index))))>;
//def indexed_i64_trunc : PatFrag<(ops node:$index), (i64 (and node:$index, (i64 0xFFFFFFFF)))>;

defm : LoadAddressIndexed<XU32_BIDS, XU32_BIDS2, XU32_BID, XU32_BID2, XU32_BIS, XU32_BI,
                          LDAXUW, LDAXUW_EXT, i32, indexed_i32_disp, indexed_i32_disp_ext>;

//===----------------------------------------------------------------------===//
// Prepare using all addressing patterns
//===----------------------------------------------------------------------===//
multiclass LoadPats<PatFrag Op,
    InstBase LD_BASE,  InstBaseExt LD_BASE_EXT,
    InstBase LD_REL,   InstBaseExt LD_REL_EXT,
    InstBase LD_XSD,   InstBaseExt LD_XSD_EXT,
    InstBase LD_XUD,   InstBaseExt LD_XUD_EXT,
    InstBase LD_XSW,   InstBaseExt LD_XSW_EXT,
    InstBase LD_XUW,   InstBaseExt LD_XUW_EXT, ValueType Ty>
{
  defm : LdPatBase<Op, LD_BASE, LD_BASE_EXT, Ty>;
  defm : LdPatPCRel<Op, LD_REL, LD_REL_EXT, Ty>;

  let AddedComplexity = Complexity_XI64_LoadStore.value in {
    defm : LoadIndexed<XI64_BIDS, XI64_BIDS2, XI64_BID, XI64_BID2, XI64_BIS, XI64_BI, Op,
            LD_XSD, LD_XSD_EXT, Ty, i64, indexed_disp, indexed_disp_ext>;
  }
  let AddedComplexity = Complexity_XU64_LoadStore.value in {
  defm : LoadIndexed<XU64_BIDS, XU64_BIDS2, XU64_BID, XU64_BID2, XU64_BIS, XU64_BI, Op,
            LD_XUD, LD_XUD_EXT, Ty, i64, indexed_disp, indexed_disp_ext>;
  }
  let AddedComplexity = Complexity_XI32_LoadStore.value in {
    defm : LoadIndexed<XI32_BIDS, XI32_BIDS2, XI32_BID, XI32_BID2, XI32_BIS, XI32_BI, Op,
            LD_XSW, LD_XSW_EXT, Ty, i32, indexed_disp, indexed_disp_ext>;
  }
  let AddedComplexity = Complexity_XU32_LoadStore.value in {
    defm : LoadIndexed<XU32_BIDS, XU32_BIDS2, XU32_BID, XU32_BID2, XU32_BIS, XU32_BI, Op,
            LD_XUW, LD_XUW_EXT, Ty, i32, indexed_i32_disp, indexed_i32_disp_ext>;
  }
}

multiclass LoadPats_I8<PatFrag Op, ValueType Ty> {
  defm : LoadPats<Op, LDSB, LDSB_EXT, LDSBR, LDSBR_EXT,
                      LDSBXSD, LDSBXSD_EXT, LDSBXUD, LDSBXUD_EXT,
                      LDSBXSW, LDSBXSW_EXT, LDSBXUW, LDSBXUW_EXT, Ty>;
}
multiclass LoadPats_U8<PatFrag Op, ValueType Ty> {
  defm : LoadPats<Op, LDUB, LDUB_EXT, LDUBR, LDUBR_EXT,
                      LDUBXSD, LDUBXSD_EXT, LDUBXUD, LDUBXUD_EXT,
                      LDUBXSW, LDUBXSW_EXT, LDUBXUW, LDUBXUW_EXT, Ty>;
}
multiclass LoadPats_I16<PatFrag Op, ValueType Ty> {
  defm : LoadPats<Op, LDSH, LDSH_EXT, LDSHR, LDSHR_EXT,
                      LDSHXSD, LDSHXSD_EXT, LDSHXUD, LDSHXUD_EXT,
                      LDSHXSW, LDSHXSW_EXT, LDSHXUW, LDSHXUW_EXT, Ty>;
}
multiclass LoadPats_U16<PatFrag Op, ValueType Ty> {
  defm : LoadPats<Op, LDUH, LDUH_EXT, LDUHR, LDUHR_EXT,
                      LDUHXSD, LDUHXSD_EXT, LDUHXUD, LDUHXUD_EXT,
                      LDUHXSW, LDUHXSW_EXT, LDUHXUW, LDUHXUW_EXT, Ty>;
}
multiclass LoadPats_I32<PatFrag Op, ValueType Ty> {
  defm : LoadPats<Op, LDSW, LDSW_EXT, LDSWR, LDSWR_EXT,
                      LDSWXSD, LDSWXSD_EXT, LDSWXUD, LDSWXUD_EXT,
                      LDSWXSW, LDSWXSW_EXT, LDSWXUW, LDSWXUW_EXT, Ty>;
}
multiclass LoadPats_U32<PatFrag Op, ValueType Ty> {
  defm : LoadPats<Op, LDUW, LDUW_EXT, LDUWR, LDUWR_EXT,
                      LDUWXSD, LDUWXSD_EXT, LDUWXUD, LDUWXUD_EXT,
                      LDUWXSW, LDUWXSW_EXT, LDUWXUW, LDUWXUW_EXT, Ty>;
}
multiclass LoadPats_I64<PatFrag Op, ValueType Ty> {
  defm : LoadPats<Op, LDSD, LDSD_EXT, LDSDR, LDSDR_EXT,
                      LDSDXSD, LDSDXSD_EXT, LDSDXUD, LDSDXUD_EXT,
                      LDSDXSW, LDSDXSW_EXT, LDSDXUW, LDSDXUW_EXT, Ty>;
}
multiclass LoadPats_U64<PatFrag Op, ValueType Ty> {
  defm : LoadPats<Op, LDUD, LDUD_EXT, LDUDR, LDUDR_EXT,
                      LDUDXSD, LDUDXSD_EXT, LDUDXUD, LDUDXUD_EXT,
                      LDUDXSW, LDUDXSW_EXT, LDUDXUW, LDUDXUW_EXT, Ty>;
}
multiclass LoadPats_I128<PatFrag Op, ValueType Ty> {
  defm : LoadPats<Op, LDQ, LDQ_EXT, LDQR, LDQR_EXT,
                      LDQXSD, LDQXSD_EXT, LDQXUD, LDQXUD_EXT,
                      LDQXSW, LDQXSW_EXT, LDQXUW, LDQXUW_EXT, Ty>;
}

multiclass StorePats<PatFrag Op,
    InstBase ST_BASE,  InstBaseExt ST_BASE_EXT,
    InstBase ST_IPREL, InstBaseExt ST_IPREL_EXT,
    InstBase ST_XI64,  InstBaseExt ST_XI64_EXT,
    InstBase ST_XU64,  InstBaseExt ST_XU64_EXT,
    InstBase ST_XI32,  InstBaseExt ST_XI32_EXT,
    InstBase ST_XU32,  InstBaseExt ST_XU32_EXT, ValueType Ty>
{
  defm : StPatBase<Op, ST_BASE, ST_BASE_EXT, Ty>;
  defm : StPatPCRel<Op, ST_IPREL, ST_IPREL_EXT, Ty>;

  let AddedComplexity = Complexity_XI64_LoadStore.value in {
    defm : StoreIndexed<XI64_BIDS, XI64_BIDS2, XI64_BID, XI64_BID2, XI64_BIS, XI64_BI, Op,
            ST_XI64, ST_XI64_EXT, Ty, i64, indexed_disp, indexed_disp_ext>;
  }
  let AddedComplexity = Complexity_XU64_LoadStore.value in {
    defm : StoreIndexed<XU64_BIDS, XU64_BIDS2, XU64_BID, XU64_BID2, XU64_BIS, XU64_BI, Op,
            ST_XU64, ST_XU64_EXT, Ty, i64, indexed_disp, indexed_disp_ext>;
  }
  let AddedComplexity = Complexity_XI32_LoadStore.value in {
    defm : StoreIndexed<XI32_BIDS, XI32_BIDS2, XI32_BID, XI32_BID2, XI32_BIS, XI32_BI, Op,
            ST_XI32, ST_XI32_EXT, Ty, i32, indexed_disp, indexed_disp_ext>;
  }
  let AddedComplexity = Complexity_XU32_LoadStore.value in {
    defm : StoreIndexed<XU32_BIDS, XU32_BIDS2, XU32_BID, XU32_BID2, XU32_BIS, XU32_BI, Op,
            ST_XU32, ST_XU32_EXT, Ty, i32, indexed_i32_disp, indexed_i32_disp_ext>;
  }
}

multiclass StorePats_I8<PatFrag Op, ValueType Ty> {
  defm : StorePats<Op, STB, STB_EXT, STBR, STBR_EXT,
                       STBXSD, STBXSD_EXT, STBXUD, STBXUD_EXT,
                       STBXSW, STBXSW_EXT, STBXUW, STBXUW_EXT, Ty>;
}
multiclass StorePats_I16<PatFrag Op, ValueType Ty> {
  defm : StorePats<Op, STH, STH_EXT, STHR, STHR_EXT,
                       STHXSD, STHXSD_EXT, STHXUD, STHXUD_EXT,
                       STHXSW, STHXSW_EXT, STHXUW, STHXUW_EXT, Ty>;
}
multiclass StorePats_I32<PatFrag Op, ValueType Ty> {
  defm : StorePats<Op, STW, STW_EXT, STWR, STWR_EXT,
                       STWXSD, STWXSD_EXT, STWXUD, STWXUD_EXT,
                       STWXSW, STWXSW_EXT, STWXUW, STWXUW_EXT, Ty>;
}
multiclass StorePats_I64<PatFrag Op, ValueType Ty> {
  defm : StorePats<Op, STD, STD_EXT, STDR, STDR_EXT,
                       STDXSD, STDXSD_EXT, STDXUD, STDXUD_EXT,
                       STDXSW, STDXSW_EXT, STDXUW, STDXUW_EXT, Ty>;
}
multiclass StorePats_I128<PatFrag Op, ValueType Ty> {
  defm : StorePats<Op, STQ, STQ_EXT, STQR, STQR_EXT,
                       STQXSD, STQXSD_EXT, STQXUD, STQXUD_EXT,
                       STQXSW, STQXSW_EXT, STQXUW, STQXUW_EXT, Ty>;
}

defm : LoadPats_U8<load, i1>;
defm : LoadPats_U32<load, i32>;
defm : LoadPats_U64<load, i64>;
defm : LoadPats_U16<load, f16>;
defm : LoadPats_U32<load, f32>;
defm : LoadPats_U64<load, f64>;

// load-store to bigger types
foreach Vt = [i32, i64, i128] in {
  defm : LoadPats_U8<zextloadi1, Vt>;
  defm : LoadPats_U8<extloadi1, Vt>;
  defm : LoadPats_U8<extloadi8, Vt>;
  defm : LoadPats_U8<zextloadi8, Vt>;
  defm : LoadPats_I8<sextloadi8, Vt>;
  defm : LoadPats_U16<zextloadi16, Vt>;
  defm : LoadPats_I16<sextloadi16, Vt>;
  defm : LoadPats_U16<extloadi16, Vt>;
  defm : StorePats_I8<truncstorei8, Vt>;
  defm : StorePats_I16<truncstorei16, Vt>;
}

foreach Vt = [i64, i128] in {
  defm : LoadPats_U32<zextloadi32, Vt>;
  defm : LoadPats_I32<sextloadi32, Vt>;
  defm : LoadPats_U32<extloadi32,  Vt>;
  defm : StorePats_I32<truncstorei32, Vt>;
}

defm : LoadPats_I64<sextloadi64, i128>;
defm : LoadPats_U64<zextloadi64, i128>;
defm : LoadPats_U64<extloadi64,  i128>;

defm : StorePats_I64<truncstorei64, i128>;
defm : StorePats_I8<store, i1>;
defm : StorePats_I32<store, i32>;
defm : StorePats_I64<store, i64>;
defm : StorePats_I16<store, f16>;
defm : StorePats_I32<store, f32>;
defm : StorePats_I64<store, f64>;

foreach Vt = [i128, f128, v2f64, v4f32, v8f16, v16i8, v8i16, v4i32, v2i64] in {
  defm : LoadPats_I128<load, Vt>;
  defm : StorePats_I128<store, Vt>;
}

// FIXME: temp solution to not crash for LocalExec/LocalDynamic
def : Pat<(tls_offset_wrapper     tglobaltlsaddr:$addr), (LDI     tglobaltlsaddr:$addr)>;
def : Pat<(tls_offset_wrapper_ext tglobaltlsaddr:$addr), (LDI_EXT tglobaltlsaddr:$addr)>;
