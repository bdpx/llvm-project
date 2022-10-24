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
  let mayLoad = 1 in {
    def NAME : PRIMARY_RabI21<Opc, (outs GR:$ra), (ins GR:$rb, simm21:$imm),
        !strconcat(Opc.mnem, " $ra, $rb, $imm"), [], itin>;

    def NAME # _EXT : PRIMARY_RabI21_ext<Opc, (outs GR:$ra), (ins GR:$rb, simm21_ext:$imm),
        !strconcat(Opc.mnem, ".l $ra, $rb, $imm"), [], itin>;
  }
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

multiclass StoreBase<opcode_opx Opc, InstrItinClass itin = IIC_st>
{
  let mayStore = 1 in {
    def NAME : PRIMARY_RabI21<Opc, (outs), (ins GR:$ra, GR:$rb, simm21:$imm),
        !strconcat(Opc.mnem, " $ra, $rb, $imm"), [], itin>;

    def NAME # _EXT : PRIMARY_RabI21_ext<Opc, (outs), (ins GR:$ra, GR:$rb, simm21_ext:$imm),
        !strconcat(Opc.mnem, ".l $ra, $rb, $imm"), [], itin>;
  }
}

defm ST_I8   : StoreBase<opcode_st_i8>;
defm ST_I16  : StoreBase<opcode_st_i16>;
defm ST_I32  : StoreBase<opcode_st_i32>;
defm ST_I64  : StoreBase<opcode_st_i64>;
defm ST_I128 : StoreBase<opcode_st_i128>;

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

defm LD_IPREL_U8   : LoadIprel<opcode_ld_iprel_u8>;
defm LD_IPREL_U16  : LoadIprel<opcode_ld_iprel_u16>;
defm LD_IPREL_U32  : LoadIprel<opcode_ld_iprel_u32>;
defm LD_IPREL_U64  : LoadIprel<opcode_ld_iprel_u64>;
defm LD_IPREL_I8   : LoadIprel<opcode_ld_iprel_i8>;
defm LD_IPREL_I16  : LoadIprel<opcode_ld_iprel_i16>;
defm LD_IPREL_I32  : LoadIprel<opcode_ld_iprel_i32>;
defm LD_IPREL_I64  : LoadIprel<opcode_ld_iprel_i64>;
defm LD_IPREL_I128 : LoadIprel<opcode_ld_iprel_i128>;

multiclass StoreIprel<opcode_opx Opc, InstrItinClass itin = IIC_st>
{
  let mayStore = 1 in {
    def NAME : PRIMARY_RaI28<Opc, (outs), (ins GR:$ra, uimm28:$imm),
        !strconcat(Opc.mnem, " $ra, $imm"), [], itin>;

    def NAME # _EXT : PRIMARY_RaI28_ext<Opc, (outs), (ins GR:$ra, uimm28_ext:$imm),
        !strconcat(Opc.mnem, ".l $ra, $imm"), [], itin>;
  }
}

defm ST_IPREL_I8   : StoreIprel<opcode_st_iprel_i8>;
defm ST_IPREL_I16  : StoreIprel<opcode_st_iprel_i16>;
defm ST_IPREL_I32  : StoreIprel<opcode_st_iprel_i32>;
defm ST_IPREL_I64  : StoreIprel<opcode_st_iprel_i64>;
defm ST_IPREL_I128 : StoreIprel<opcode_st_iprel_i128>;

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

defm LD_MIA_U8   : LoadModifyAfter<opcode_ld_mia_u8>;
defm LD_MIA_U16  : LoadModifyAfter<opcode_ld_mia_u16>;
defm LD_MIA_U32  : LoadModifyAfter<opcode_ld_mia_u32>;
defm LD_MIA_U64  : LoadModifyAfter<opcode_ld_mia_u64>;
defm LD_MIA_I8   : LoadModifyAfter<opcode_ld_mia_i8>;
defm LD_MIA_I16  : LoadModifyAfter<opcode_ld_mia_i16>;
defm LD_MIA_I32  : LoadModifyAfter<opcode_ld_mia_i32>;
defm LD_MIA_I64  : LoadModifyAfter<opcode_ld_mia_i64>;
defm LD_MIA_I128 : LoadModifyAfter<opcode_ld_mia_i128>;

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

defm ST_MIA_I8   : StoreModifyAfter<opcode_st_mia_i8>;
defm ST_MIA_I16  : StoreModifyAfter<opcode_st_mia_i16>;
defm ST_MIA_I32  : StoreModifyAfter<opcode_st_mia_i32>;
defm ST_MIA_I64  : StoreModifyAfter<opcode_st_mia_i64>;
defm ST_MIA_I128 : StoreModifyAfter<opcode_st_mia_i128>;

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

defm LD_MIB_U8   : LoadModifyBefore<opcode_ld_mib_u8>;
defm LD_MIB_U16  : LoadModifyBefore<opcode_ld_mib_u16>;
defm LD_MIB_U32  : LoadModifyBefore<opcode_ld_mib_u32>;
defm LD_MIB_U64  : LoadModifyBefore<opcode_ld_mib_u64>;
defm LD_MIB_I8   : LoadModifyBefore<opcode_ld_mib_i8>;
defm LD_MIB_I16  : LoadModifyBefore<opcode_ld_mib_i16>;
defm LD_MIB_I32  : LoadModifyBefore<opcode_ld_mib_i32>;
defm LD_MIB_I64  : LoadModifyBefore<opcode_ld_mib_i64>;
defm LD_MIB_I128 : LoadModifyBefore<opcode_ld_mib_i128>;

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

defm ST_MIB_I8   : StoreModifyAfter<opcode_st_mib_i8>;
defm ST_MIB_I16  : StoreModifyAfter<opcode_st_mib_i16>;
defm ST_MIB_I32  : StoreModifyAfter<opcode_st_mib_i32>;
defm ST_MIB_I64  : StoreModifyAfter<opcode_st_mib_i64>;
defm ST_MIB_I128 : StoreModifyAfter<opcode_st_mib_i128>;

//===----------------------------------------------------------------------===//
// XI64 indexing instructions
//===----------------------------------------------------------------------===//
multiclass LoadIndexedI64<mem_xi64_opx Opc, InstrItinClass itin = IIC_iu_instr>
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

multiclass StoreIndexedI64<mem_xi64_opx Opc, InstrItinClass itin = IIC_iu_instr>
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

defm ST_XI64_I8   : StoreIndexedI64<opcode_st_xi64_i8>;
defm ST_XI64_I16  : StoreIndexedI64<opcode_st_xi64_i16>;
defm ST_XI64_I32  : StoreIndexedI64<opcode_st_xi64_i32>;
defm ST_XI64_I64  : StoreIndexedI64<opcode_st_xi64_i64>;
defm ST_XI64_I128 : StoreIndexedI64<opcode_st_xi64_i128>;

//===----------------------------------------------------------------------===//
// XU64 indexing instructions
//===----------------------------------------------------------------------===//
multiclass LoadIndexedU64<mem_xu64_opx Opc, InstrItinClass itin = IIC_iu_instr>
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

defm LD_XU64_U8   : LoadIndexedU64<opcode_ld_xu64_u8>;
defm LD_XU64_U16  : LoadIndexedU64<opcode_ld_xu64_u16>;
defm LD_XU64_U32  : LoadIndexedU64<opcode_ld_xu64_u32>;
defm LD_XU64_U64  : LoadIndexedU64<opcode_ld_xu64_u64>;
defm LD_XU64_I8   : LoadIndexedU64<opcode_ld_xu64_i8>;
defm LD_XU64_I16  : LoadIndexedU64<opcode_ld_xu64_i16>;
defm LD_XU64_I32  : LoadIndexedU64<opcode_ld_xu64_i32>;
defm LD_XU64_I64  : LoadIndexedU64<opcode_ld_xu64_i64>;
defm LD_XU64_I128 : LoadIndexedU64<opcode_ld_xu64_i128>;
defm LDA_XU64     : LoadIndexedU64<opcode_lda_xu64>;

multiclass StoreIndexedU64<mem_xu64_opx Opc, InstrItinClass itin = IIC_iu_instr>
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

defm ST_XU64_I8   : StoreIndexedU64<opcode_st_xu64_i8>;
defm ST_XU64_I16  : StoreIndexedU64<opcode_st_xu64_i16>;
defm ST_XU64_I32  : StoreIndexedU64<opcode_st_xu64_i32>;
defm ST_XU64_I64  : StoreIndexedU64<opcode_st_xu64_i64>;
defm ST_XU64_I128 : StoreIndexedU64<opcode_st_xu64_i128>;

//===----------------------------------------------------------------------===//
// XI32 indexing instructions
//===----------------------------------------------------------------------===//
multiclass LoadIndexedI32<mem_xi32_opx Opc, InstrItinClass itin = IIC_iu_instr>
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

multiclass StoreIndexedI32<mem_xi32_opx Opc, InstrItinClass itin = IIC_iu_instr>
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

defm ST_XI32_I8   : StoreIndexedI32<opcode_st_xi32_i8>;
defm ST_XI32_I16  : StoreIndexedI32<opcode_st_xi32_i16>;
defm ST_XI32_I32  : StoreIndexedI32<opcode_st_xi32_i32>;
defm ST_XI32_I64  : StoreIndexedI32<opcode_st_xi32_i64>;
defm ST_XI32_I128 : StoreIndexedI32<opcode_st_xi32_i128>;

//===----------------------------------------------------------------------===//
// XU32 indexing instructions
//===----------------------------------------------------------------------===//
multiclass LoadIndexedU32<mem_xu32_opx Opc, InstrItinClass itin = IIC_iu_instr>
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

multiclass StoreIndexedU32<mem_xu32_opx Opc, InstrItinClass itin = IIC_st>
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

defm ST_XU32_I8   : StoreIndexedU32<opcode_st_xu32_i8>;
defm ST_XU32_I16  : StoreIndexedU32<opcode_st_xu32_i16>;
defm ST_XU32_I32  : StoreIndexedU32<opcode_st_xu32_i32>;
defm ST_XU32_I64  : StoreIndexedU32<opcode_st_xu32_i64>;
defm ST_XU32_I128 : StoreIndexedU32<opcode_st_xu32_i128>;

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
                          LDA_XI64, LDA_XI64_EXT, i64, indexed_disp, indexed_disp_ext>;

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
                          LDA_XI32, LDA_XI32_EXT, i32, indexed_disp, indexed_disp_ext>;

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
                          LDA_XU64, LDA_XU64_EXT, i64, indexed_disp, indexed_disp_ext>;

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
                          LDA_XU32, LDA_XU32_EXT, i32, indexed_i32_disp, indexed_i32_disp_ext>;

//===----------------------------------------------------------------------===//
// Prepare using all addressing patterns
//===----------------------------------------------------------------------===//
multiclass LoadPats<PatFrag Op, ValueType Ty>
{
  defm : LdPatBase<Op, !cast<InstBase>("LD_" # NAME), !cast<InstBaseExt>("LD_" # NAME # _EXT), Ty>;

  defm : LdPatPCRel<Op, !cast<InstBase>("LD_IPREL_" # NAME), !cast<InstBaseExt>("LD_IPREL_" # NAME # _EXT), Ty>;

  let AddedComplexity = Complexity_XI64_LoadStore.value in {
    defm : LoadIndexed<XI64_BIDS, XI64_BIDS2, XI64_BID, XI64_BID2, XI64_BIS, XI64_BI, Op,
            !cast<InstBase>("LD_XI64_" # NAME), !cast<InstBaseExt>("LD_XI64_" # NAME # _EXT),
            Ty, i64, indexed_disp, indexed_disp_ext>;

  }
  let AddedComplexity = Complexity_XU64_LoadStore.value in {
  defm : LoadIndexed<XU64_BIDS, XU64_BIDS2, XU64_BID, XU64_BID2, XU64_BIS, XU64_BI, Op,
            !cast<InstBase>("LD_XU64_" # NAME), !cast<InstBaseExt>("LD_XU64_" # NAME # _EXT),
            Ty, i64, indexed_disp, indexed_disp_ext>;
  }
  let AddedComplexity = Complexity_XI32_LoadStore.value in {
    defm : LoadIndexed<XI32_BIDS, XI32_BIDS2, XI32_BID, XI32_BID2, XI32_BIS, XI32_BI, Op,
            !cast<InstBase>("LD_XI32_" # NAME), !cast<InstBaseExt>("LD_XI32_" # NAME # _EXT),
            Ty, i32, indexed_disp, indexed_disp_ext>;
  }
  let AddedComplexity = Complexity_XU32_LoadStore.value in {
    defm : LoadIndexed<XU32_BIDS, XU32_BIDS2, XU32_BID, XU32_BID2, XU32_BIS, XU32_BI, Op,
            !cast<InstBase>("LD_XU32_" # NAME), !cast<InstBaseExt>("LD_XU32_" # NAME # _EXT),
            Ty, i32, indexed_i32_disp, indexed_i32_disp_ext>;
  }
}

multiclass StorePats<PatFrag Op, ValueType Ty>
{
  defm : StPatBase<Op, !cast<InstBase>("ST_" # NAME), !cast<InstBaseExt>("ST_" # NAME # _EXT), Ty>;

  defm : StPatPCRel<Op, !cast<InstBase>("ST_IPREL_" # NAME), !cast<InstBaseExt>("ST_IPREL_" # NAME # _EXT), Ty>;

  let AddedComplexity = Complexity_XI64_LoadStore.value in {
    defm : StoreIndexed<XI64_BIDS, XI64_BIDS2, XI64_BID, XI64_BID2, XI64_BIS, XI64_BI, Op,
            !cast<InstBase>("ST_XI64_" # NAME), !cast<InstBaseExt>("ST_XI64_" # NAME # _EXT),
            Ty, i64, indexed_disp, indexed_disp_ext>;
  }
  let AddedComplexity = Complexity_XU64_LoadStore.value in {
    defm : StoreIndexed<XU64_BIDS, XU64_BIDS2, XU64_BID, XU64_BID2, XU64_BIS, XU64_BI, Op,
            !cast<InstBase>("ST_XU64_" # NAME), !cast<InstBaseExt>("ST_XU64_" # NAME # _EXT),
            Ty, i64, indexed_disp, indexed_disp_ext>;
  }
  let AddedComplexity = Complexity_XI32_LoadStore.value in {
    defm : StoreIndexed<XI32_BIDS, XI32_BIDS2, XI32_BID, XI32_BID2, XI32_BIS, XI32_BI, Op,
            !cast<InstBase>("ST_XI32_" # NAME), !cast<InstBaseExt>("ST_XI32_" # NAME # _EXT),
            Ty, i32, indexed_disp, indexed_disp_ext>;
  }
  let AddedComplexity = Complexity_XU32_LoadStore.value in {
    defm : StoreIndexed<XU32_BIDS, XU32_BIDS2, XU32_BID, XU32_BID2, XU32_BIS, XU32_BI, Op,
            !cast<InstBase>("ST_XU32_" # NAME), !cast<InstBaseExt>("ST_XU32_" # NAME # _EXT),
            Ty, i32, indexed_i32_disp, indexed_i32_disp_ext>;
  }
}

defm U8 : LoadPats<load,        i1>;

defm U8 : LoadPats<zextloadi1,  i32>;
defm U8 : LoadPats<extloadi1,   i32>;

defm U8 : LoadPats<zextloadi1,  i64>;
defm U8 : LoadPats<extloadi1,   i64>;

defm U8 : LoadPats<zextloadi1,  i128>;
defm U8 : LoadPats<extloadi1,   i128>;

defm U8 : LoadPats<zextloadi8,  i32>;
defm I8 : LoadPats<sextloadi8,  i32>;
defm U8 : LoadPats<extloadi8,   i32>;

defm U8 : LoadPats<zextloadi8,  i64>;
defm I8 : LoadPats<sextloadi8,  i64>;
defm U8 : LoadPats<extloadi8,   i64>;

defm U8 : LoadPats<zextloadi8,  i128>;
defm I8 : LoadPats<sextloadi8,  i128>;
defm U8 : LoadPats<extloadi8,   i128>;


defm U16 : LoadPats<zextloadi16, i32>;
defm I16 : LoadPats<sextloadi16, i32>;
defm U16 : LoadPats<extloadi16,  i32>;

defm U16 : LoadPats<zextloadi16, i64>;
defm I16 : LoadPats<sextloadi16, i64>;
defm U16 : LoadPats<extloadi16,  i64>;

defm U16 : LoadPats<zextloadi16, i128>;
defm I16 : LoadPats<sextloadi16, i128>;
defm U16 : LoadPats<extloadi16,  i128>;

defm U32 : LoadPats<load,        i32>;

defm U32 : LoadPats<zextloadi32, i64>;
defm I32 : LoadPats<sextloadi32, i64>;
defm U32 : LoadPats<extloadi32,  i64>;

defm U32 : LoadPats<zextloadi32, i128>;
defm I32 : LoadPats<sextloadi32, i128>;
defm U32 : LoadPats<extloadi32,  i128>;

defm U64 : LoadPats<load,        i64>;

defm I64 : LoadPats<sextloadi64, i128>;
defm U64 : LoadPats<zextloadi64, i128>;
defm U64 : LoadPats<extloadi64,  i128>;


defm U16 : LoadPats<load, f16>;
defm U32 : LoadPats<load, f32>;
defm U64 : LoadPats<load, f64>;

defm I8 : StorePats<store,         i1>;
defm I8 : StorePats<truncstorei8,  i32>;
defm I8 : StorePats<truncstorei8,  i64>;
defm I8 : StorePats<truncstorei8,  i128>;

defm I16 : StorePats<truncstorei16, i32>;
defm I16 : StorePats<truncstorei16, i64>;
defm I16 : StorePats<truncstorei16, i128>;

defm I32 : StorePats<store,         i32>;
defm I32 : StorePats<truncstorei32, i64>;
defm I32 : StorePats<truncstorei32, i128>;

defm I64 : StorePats<store,         i64>;
defm I64 : StorePats<truncstorei64, i128>;

defm I16 : StorePats<store, f16>;
defm I32 : StorePats<store, f32>;
defm I64 : StorePats<store, f64>;

foreach Vt = [i128, f128, v2f64, v4f32, v8f16, v16i8, v8i16, v4i32, v2i64] in {
  defm I128 : LoadPats<load, Vt>;
  defm I128 : StorePats<store, Vt>;
}

// FIXME: temp solution to not crash for LocalExec/LocalDynamic
def : Pat<(tls_offset_wrapper     tglobaltlsaddr:$addr), (LD_IMM     tglobaltlsaddr:$addr)>;
def : Pat<(tls_offset_wrapper_ext tglobaltlsaddr:$addr), (LD_IMM_EXT tglobaltlsaddr:$addr)>;
