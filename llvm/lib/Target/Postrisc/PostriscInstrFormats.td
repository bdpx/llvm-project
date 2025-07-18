//=== PostriscInstrFormats.td - Postrisc Instruction Formats *- tablegen -*===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Instruction Pattern Stuff
//===----------------------------------------------------------------------===//

// indexed scaling (should be i32 for proper folding)
def scale_xform : SDNodeXForm<imm, [{
  return getUnsignedConstant(N, N->getZExtValue());
}]>;
def scale : Operand<i32>, IntImmLeaf<i32, [{ return isZextInt(Imm, 3); }], scale_xform> {
  let DecoderMethod = "DecodeUIMM<3>";
}

// immediate shift amount (should be i32 for proper folding)
def uimm5_xform : SDNodeXForm<imm, [{
  return getI64Imm(N->getZExtValue(), SDLoc(N));
}]>;
def uimm5 : Operand<i32>, IntImmLeaf<i32, [{ return isZextInt(Imm, 5); }], uimm5_xform> {
  let DecoderMethod = "DecodeUIMM<5>";
}

// immediate shift amount (should be i32 for proper folding)
def uimm6_xform : SDNodeXForm<imm, [{
  return getI64Imm(N->getZExtValue(), SDLoc(N));
}]>;
def uimm6 : Operand<i32>, IntImmLeaf<i32, [{ return isZextInt(Imm, 6); }], uimm6_xform> {
  let DecoderMethod = "DecodeUIMM<6>";
}

def uimm7_xform : SDNodeXForm<imm, [{
  return getI64Imm(N->getZExtValue(), SDLoc(N));
}]>;
def uimm7 : Operand<i32>, IntImmLeaf<i32, [{ return isZextInt(Imm, 7); }], uimm7_xform> {
  let DecoderMethod = "DecodeUIMM<7>";
}

def uimm7i64_xform : SDNodeXForm<imm, [{
  return getI64Imm(N->getZExtValue(), SDLoc(N));
}]>;
def uimm7i64 : Operand<i64>, IntImmLeaf<i64, [{ return isZextInt(Imm, 7); }], uimm7i64_xform> {
  let DecoderMethod = "DecodeUIMM<7>";
}

//===----------------------------------------------------------------------===//
// stride immediate (simm 10/52)
//===----------------------------------------------------------------------===//
def stride_xform : SDNodeXForm<imm, [{
  return getI64Imm(N->getSExtValue(), SDLoc(N));
}]>;
def stride_imm : Operand<i64>, IntImmLeaf<i64, [{ return isSextInt(Imm, 10); }], stride_xform> {
  let DecoderMethod = "DecodeSIMM<10>";
}

// simm52 extended (10+42) immediate (stride_ext)
def stride_ext_xform : SDNodeXForm<imm, [{
  return getI64Imm(N->getSExtValue(), SDLoc(N));
}]>;
def stride_imm_ext : Operand<i64>, IntImmLeaf<i64, [{ return isSextInt(Imm, 52); }], stride_ext_xform> {
  let DecoderMethod = "DecodeSIMM<52>";
}

//===----------------------------------------------------------------------===//
// simm11/uimm11 immediates
// 1) compare reg-imm and branch
// 2) compare reg-imm and nullify
// 3) base pre-post update
//===----------------------------------------------------------------------===//
def Plus1     : SDNodeXForm<imm, [{ return getI64Imm(N->getSExtValue() + 1, SDLoc(N)); }]>;
def Minus1    : SDNodeXForm<imm, [{ return getI64Imm(N->getSExtValue() - 1, SDLoc(N)); }]>;
def Plus1_32  : SDNodeXForm<imm, [{ return getI32Imm(N->getSExtValue() + 1, SDLoc(N)); }]>;
def Minus1_32 : SDNodeXForm<imm, [{ return getI32Imm(N->getSExtValue() - 1, SDLoc(N)); }]>;
// getSignedConstant(N, N->getSExtValue() - 1);

def simm11_plus1      : PatLeaf<(imm), [{ APInt tmp = N->getAPIntValue(); tmp += 1; return isSextInt(tmp, 11); }]>;
def simm11_minus1     : PatLeaf<(imm), [{ APInt tmp = N->getAPIntValue(); tmp -= 1; return isSextInt(tmp, 11); }]>;
def simm11_ext_plus1  : PatLeaf<(imm), [{ APInt tmp = N->getAPIntValue(); tmp += 1; return isSextInt(tmp, 40); }]>;
def simm11_ext_minus1 : PatLeaf<(imm), [{ APInt tmp = N->getAPIntValue(); tmp -= 1; return isSextInt(tmp, 40); }]>;

def uimm11_plus1      : PatLeaf<(imm), [{ APInt tmp = N->getAPIntValue(); tmp += 1; return isZextInt(tmp, 11); }]>;
def uimm11_minus1     : PatLeaf<(imm), [{ APInt tmp = N->getAPIntValue(); tmp -= 1; return isZextInt(tmp, 11); }]>;
def uimm11_ext_plus1  : PatLeaf<(imm), [{ APInt tmp = N->getAPIntValue(); tmp += 1; return isZextInt(tmp, 40); }]>;
def uimm11_ext_minus1 : PatLeaf<(imm), [{ APInt tmp = N->getAPIntValue(); tmp -= 1; return isZextInt(tmp, 40); }]>;

def simm11_xform : SDNodeXForm<imm, [{
  return getI64Imm(N->getSExtValue(), SDLoc(N));
}]>;
def simm11 : Operand<i64>, IntImmLeaf<i64, [{ return isSextInt(Imm, 11); }], simm11_xform> {
  let DecoderMethod = "DecodeSIMM<11>";
}

def simm11_ext_xform : SDNodeXForm<imm, [{
  return getI64Imm(N->getSExtValue(), SDLoc(N));
}]>;
def simm11_ext : Operand<i64>, IntImmLeaf<i64, [{ return isSextInt(Imm, 40); }], simm11_ext_xform> {
  let DecoderMethod = "DecodeSIMM<40>";
}

def uimm11_xform : SDNodeXForm<imm, [{
  return getI64Imm(N->getZExtValue(), SDLoc(N));
}]>;
def uimm11 : Operand<i64>, IntImmLeaf<i64, [{ return isZextInt(Imm, 11); }], uimm11_xform> {
  let DecoderMethod = "DecodeUIMM<11>";
}

def uimm11_ext_xform : SDNodeXForm<imm, [{
  return getI64Imm(N->getZExtValue(), SDLoc(N));
}]>;
def uimm11_ext : Operand<i64>, IntImmLeaf<i64, [{ return isZextInt(Imm, 40); }], uimm11_ext_xform> {
  let DecoderMethod = "DecodeUIMM<40>";
}

def simm11i32_xform : SDNodeXForm<imm, [{
  return getI64Imm(N->getSExtValue(), SDLoc(N));
}]>;
def simm11i32 : Operand<i32>, IntImmLeaf<i32, [{ return isSextInt(Imm, 11); }], simm11i32_xform> {
  let DecoderMethod = "DecodeSIMM<11>";
}

def simm11i32_ext_xform : SDNodeXForm<imm, [{
  return getI64Imm(N->getSExtValue(), SDLoc(N));
}]>;
def simm11i32_ext : Operand<i32>, IntImmLeaf<i32, [{ return isSextInt(Imm, 32); }], simm11i32_ext_xform> {
  let DecoderMethod = "DecodeSIMM<32>";
}

def uimm11i32_xform : SDNodeXForm<imm, [{
  return getI64Imm(N->getZExtValue(), SDLoc(N));
}]>;
def uimm11i32 : Operand<i32>, IntImmLeaf<i32, [{ return isZextInt(Imm, 11); }], uimm11i32_xform> {
  let DecoderMethod = "DecodeUIMM<11>";
}

def uimm11i32_ext_xform : SDNodeXForm<imm, [{
  return getI64Imm(N->getZExtValue(), SDLoc(N));
}]>;
def uimm11i32_ext : Operand<i32>, IntImmLeaf<i32, [{ return isZextInt(Imm, 32); }], uimm11i32_ext_xform> {
  let DecoderMethod = "DecodeUIMM<32>";
}

//===----------------------------------------------------------------------===//
// simm21 immediate
//===----------------------------------------------------------------------===//
def simm21_xform : SDNodeXForm<imm, [{
  return getI64Imm(N->getSExtValue(), SDLoc(N));
}]>;
def simm21 : Operand<i64>, IntImmLeaf<i64, [{ return isSextInt(Imm, 21); }], simm21_xform> {
  let DecoderMethod = "DecodeSIMM<21>";
}

// simm21 extended (21+42) immediate
def simm21_ext_xform : SDNodeXForm<imm, [{
  return getI64Imm(N->getSExtValue(), SDLoc(N));
}]>;
def simm21_ext : Operand<i64>, IntImmLeaf<i64, [{ return isSextInt(Imm, 63); }], simm21_ext_xform> {
  let DecoderMethod = "DecodeSIMM<63>";
}

def uimm21_xform : SDNodeXForm<imm, [{
  return getI64Imm(N->getZExtValue(), SDLoc(N));
}]>;
def uimm21 : Operand<i64>, IntImmLeaf<i64, [{ return isZextInt(Imm, 21); }], uimm21_xform> {
  let DecoderMethod = "DecodeUIMM<21>";
}

// uimm21 extended (21+42) immediate
def uimm21_ext_xform : SDNodeXForm<imm, [{
  return getI64Imm(N->getZExtValue(), SDLoc(N));
}]>;
def uimm21_ext : Operand<i64>, IntImmLeaf<i64, [{ return isZextInt(Imm, 63); }], uimm21_ext_xform> {
  let DecoderMethod = "DecodeUIMM<63>";
}

/// target constants for intrinsics
def tuimm21 : Operand<i32>, TImmLeaf<i32, [{ return isZextInt(Imm, 21); }]> {
  let DecoderMethod = "DecodeUIMM<21>";
}

def simm21i32_xform : SDNodeXForm<imm, [{
  return CurDAG->getSignedTargetConstant(N->getSExtValue(), SDLoc(N), MVT::i32);
}]>;
def simm21i32 : Operand<i32>, IntImmLeaf<i32, [{ return isSextInt(Imm, 21); }], simm21i32_xform> {
  let DecoderMethod = "DecodeSIMM<21>";
}

def uimm21i32_xform : SDNodeXForm<imm, [{
  return CurDAG->getTargetConstant(N->getZExtValue(), SDLoc(N), MVT::i32);
}]>;
def uimm21i32 : Operand<i32>, IntImmLeaf<i32, [{ return isZextInt(Imm, 21); }], uimm21i32_xform> {
  let DecoderMethod = "DecodeUIMM<21>";
}

def simm21i64_xform : SDNodeXForm<imm, [{
  return CurDAG->getSignedTargetConstant(N->getSExtValue(), SDLoc(N), MVT::i64);
}]>;
def simm21i64 : Operand<i64>, IntImmLeaf<i64, [{ return isSextInt(Imm, 21); }], simm21i64_xform>
{
  let DecoderMethod = "DecodeSIMM<21>";
}

def uimm21i64_xform : SDNodeXForm<imm, [{
  return CurDAG->getTargetConstant(N->getZExtValue(), SDLoc(N), MVT::i64);
}]>;
def uimm21i64 : Operand<i64>, IntImmLeaf<i64, [{ return isZextInt(Imm, 21); }], uimm21i64_xform>
{
  let DecoderMethod = "DecodeUIMM<21>";
}

// simm21i32 extended (21+42) immediate
def simm21i32_ext_xform : SDNodeXForm<imm, [{
  return getI64Imm(N->getSExtValue(), SDLoc(N));
}]>;
def simm21i32_ext : Operand<i32>, IntImmLeaf<i32, [{ return isSextInt(Imm, 32); }], simm21i32_ext_xform> {
  let DecoderMethod = "DecodeSIMM<32>";
}

def uimm21i32_ext_xform : SDNodeXForm<imm, [{
  return getI64Imm(N->getZExtValue(), SDLoc(N));
}]>;
def uimm21i32_ext : Operand<i32>, IntImmLeaf<i32, [{ return isZextInt(Imm, 32); }], uimm21i32_ext_xform> {
  let DecoderMethod = "DecodeUIMM<32>";
}

//===----------------------------------------------------------------------===//
// immediates for LDI, NOP
//===----------------------------------------------------------------------===//
def simm28_xform : SDNodeXForm<imm, [{
  return getI64Imm(N->getSExtValue(), SDLoc(N));
}]>;
def simm28 : Operand<i64>, IntImmLeaf<i64, [{ return isSextInt(Imm, 28); }], simm28_xform> {
  let DecoderMethod = "DecodeSIMM<28>";
}

// simm28 extended (28+36) immediate
def simm28_ext_xform : SDNodeXForm<imm, [{
  return getI64Imm(N->getSExtValue(), SDLoc(N));
}]>;
def simm28_ext : Operand<i64>, IntImmLeaf<i64, [{ return isSextInt(Imm, 64); }], simm28_ext_xform> {
  let DecoderMethod = "DecodeSIMM<64>";
}

def simm28_32_xform : SDNodeXForm<imm, [{
  return getI32Imm(N->getSExtValue(), SDLoc(N));
}]>;
def simm28_32 : Operand<i32>, IntImmLeaf<i32, [{ return isSextInt(Imm, 28); }], simm28_32_xform> {
  let DecoderMethod = "DecodeSIMM<28>";
}

def uimm28_xform : SDNodeXForm<imm, [{
  return getI64Imm(N->getZExtValue(), SDLoc(N));
}]>;
def uimm28 : Operand<i64>, IntImmLeaf<i64, [{ return isZextInt(Imm, 28); }], uimm28_xform> {
  let DecoderMethod = "DecodeUIMM<28>";
}

// uimm28 extended (28+36) immediate
def uimm28_ext_xform : SDNodeXForm<imm, [{
  return getI64Imm(N->getSExtValue(), SDLoc(N));
}]>;
def uimm28_ext : Operand<i64>, IntImmLeaf<i64, [{ return isZextInt(Imm, 64); }], uimm28_ext_xform> {
  let DecoderMethod = "DecodeUIMM<64>";
}

def simm32_xform : SDNodeXForm<imm, [{
  return getI32Imm(N->getSExtValue(), SDLoc(N));
}]>;
def simm32 : Operand<i32>, IntImmLeaf<i32, [{ return isSextInt(Imm, 32); }], simm32_xform> {
  let DecoderMethod = "DecodeSIMM<32>";
}

//===----------------------------------------------------------------------===//
// instruction formats
//===----------------------------------------------------------------------===//
class CommonInstruction<opcode_opx opcode,
    dag outs, dag ins, string asmstr,
    list<dag> pattern, InstrItinClass itin = NoItinerary>
    : Instruction
{
  bit isLong = 0;
  bit isPostIncrement = 0;
  bit isPreIncrement = 0;
  bit isIndexedMemAccess = 0;

  let Namespace = "POSTRISC";
  let DecoderNamespace = "Postrisc";

  dag OutOperandList = outs;
  dag InOperandList = ins;
  let AsmString   = asmstr;
  let Pattern = pattern;
  let Itinerary = itin;

  bits<7> opcode_field;
  let opcode_field = opcode.value;

  /// These fields correspond to the fields in PostriscInstrInfo.h.
  /// Any changes to these must be reflected there!
  ///
  let TSFlags{0} = isLong;
  let TSFlags{1} = isPostIncrement;
  let TSFlags{2} = isPreIncrement;
  let TSFlags{3} = isIndexedMemAccess;
}

//------------------------------------------------------------------------------
// usual (1 slot) and extended (2 slots) instruction variants
//------------------------------------------------------------------------------
class InstBase<opcode_opx opcode,
    dag outs, dag ins, string asmstr, list<dag> pattern,
    InstrItinClass itin = NoItinerary>
    : CommonInstruction<opcode, outs, ins, asmstr, pattern, itin>
{
  string name = NAME;
  let isLong = 0;
  // llvm can't model 42 bit instructions, so model as 64 bit
  let Size = 8;
  field bits<64> Inst;
  field bits<64> SoftFail = 0;
  // unmodelled part is zero
  let Inst{63-42} = 0;
  // Top 7 bits are the primary opcode
  let Inst{41-35} = opcode_field;
}
def InstBaseEnum : GenericEnum {
  let FilterClass = "InstBase";
  let NameField = "name";
  // let ValueField = "value";
}

class InstBaseExt<opcode_opx opcode,
    dag outs, dag ins, string asmstr,
    list<dag> pattern, InstrItinClass itin = NoItinerary>
    : CommonInstruction<opcode, outs, ins, asmstr, pattern, itin>
{
  string name = NAME;
  let isLong = 1;
  // llvm can't model 84 bit instructions, so model as 128 bit
  let Size = 16;
  field bits<128> Inst;
  field bits<128> SoftFail = 0;
  // unmodelled part is zero
  let Inst{127-84} = 0;
  // Top 7 bits of first slot is the primary opcode
  let Inst{41-35} = opcode_field;
}
def InstBaseExtEnum : GenericEnum {
  let FilterClass = "InstBaseExt";
  let NameField = "name";
  // let ValueField = "value";
}

//------------------------------------------------------------------------------
// ra,imm28(64)
//------------------------------------------------------------------------------
class PRIMARY_RaI28<opcode_opx opcode, dag outs, dag ins,
    string asmstr, list<dag> pattern, InstrItinClass itin = NoItinerary>
    : InstBase<opcode, outs, ins, asmstr, pattern, itin>
{
  bits<7>  ra;
  bits<28> imm;

  let Inst{34-28} = ra;
  let Inst{27-0}  = imm;
}

class PRIMARY_RaI28_ext<opcode_opx opcode, dag outs, dag ins,
    string asmstr, list<dag> pattern, InstrItinClass itin = NoItinerary>
    : InstBaseExt<opcode, outs, ins, asmstr, pattern, itin>
{
  bits<7>  ra;
  bits<64> imm;

  let Inst{83-78} = 0;
  let Inst{77-42} = imm{63-28};
  let Inst{34-28} = ra;
  let Inst{27-0}  = imm{27-0};
}

//------------------------------------------------------------------------------
// ra,rb,imm21(63)
//------------------------------------------------------------------------------
class PRIMARY_RabI21<opcode_opx opcode, dag outs, dag ins,
   string asmstr, list<dag> pattern, InstrItinClass itin = NoItinerary>
  : InstBase<opcode, outs, ins, asmstr, pattern, itin>
{
  bits<7>  ra;
  bits<7>  rb;
  bits<21> imm;

  let Inst{34-28} = ra;
  let Inst{27-21} = rb;
  let Inst{20-0}  = imm;
}

class PRIMARY_RabI21_ext<opcode_opx opcode, dag outs, dag ins,
    string asmstr, list<dag> pattern, InstrItinClass itin = NoItinerary>
    : InstBaseExt<opcode, outs, ins, asmstr, pattern, itin>
{
  bits<7>  ra;
  bits<7>  rb;
  bits<63> imm;

  let Inst{83-42} = imm{62-21};
  let Inst{34-28} = ra;
  let Inst{27-21} = rb;
  let Inst{20-0}  = imm{20-0};
}


//------------------------------------------------------------------------------
// ra,imm11(40),b17(30)
//------------------------------------------------------------------------------
class PRIMARY_RaImmBranch<opcode_opx opcode, dag outs, dag ins,
   string asmstr, list<dag> pattern, InstrItinClass itin = NoItinerary>
  : InstBase<opcode, outs, ins, asmstr, pattern, itin>
{
  bits<7>  ra;
  bits<11> imm;
  bits<17> offset;

  let Inst{34-28} = ra;
  let Inst{27-17} = imm;
  let Inst{16-0}  = offset;
}

class PRIMARY_RaImmBranch_ext<opcode_opx opcode, dag outs, dag ins,
    string asmstr, list<dag> pattern, InstrItinClass itin = NoItinerary>
    : InstBaseExt<opcode, outs, ins, asmstr, pattern, itin>
{
  bits<7>  ra;
  bits<40> imm;
  bits<30> offset;

  let Inst{83-55} = imm{39-11};
  let Inst{54-42} = offset{29-17};
  // Inst{41-35} = opcode
  let Inst{34-28} = ra;
  let Inst{27-17} = imm{10-0};
  let Inst{16-0}  = offset{16-0};
}

//------------------------------------------------------------------------------
// INST ra, rb, bb17(30)
//------------------------------------------------------------------------------
class BRR_RabBranch<opcode_opx opcode, bits<4> opxCode, dag outs, dag ins,
    string asmstr, list<dag> pattern, InstrItinClass itin = NoItinerary>
    : InstBase<opcode, outs, ins, asmstr, pattern, itin>
{
  bits<7>  ra;
  bits<7>  rb;
  bits<17> offset;
  bits<4>  opx;

  let opx = opxCode;

  let Inst{34-28} = ra;
  let Inst{27-21} = rb;
  let Inst{20-17} = opx;
  let Inst{16-0}  = offset;
}

class BRR_RabBranch_ext<opcode_opx opcode, bits<4> opxCode, dag outs, dag ins,
   string asmstr, list<dag> pattern, InstrItinClass itin = NoItinerary>
  : InstBaseExt<opcode, outs, ins, asmstr, pattern, itin>
{
  bits<7>  ra;
  bits<7>  rb;
  bits<30> offset;
  bits<4>  opx;

  let opx = opxCode;

  let Inst{83-55} = 0;
  let Inst{54-42} = offset{29-17}; // high 13 bit
  let Inst{34-28} = ra;
  let Inst{27-21} = rb;
  let Inst{20-17} = opx;
  let Inst{16-0}  = offset{16-0};   // low 17 bit
}

//------------------------------------------------------------------------------
// ra,rb,rc,scale,imm7(49)
//------------------------------------------------------------------------------
class PRIMARY_Indexed_DS<indexed_ds_opx mode, dag outs, dag ins, string asmstr,
                         list<dag> pattern, InstrItinClass itin = NoItinerary>
  : InstBase<opcode_indexed_ds, outs, ins, asmstr, pattern, itin>
{
  bits<7> ra;
  bits<7> rb;
  bits<7> rc;
  bits<4> opx;
  bits<3> scale;
  bits<7> imm;

  let opx = mode.value;

  let Inst{34-28} = ra;
  let Inst{27-21} = rb;
  let Inst{20-14} = rc;
  let Inst{13-11} = scale;
  let Inst{10-7}  = opx;
  let Inst{6-0}   = imm;
}

class PRIMARY_Indexed_DS_Long<indexed_ds_opx mode, dag outs, dag ins, string asmstr,
                             list<dag> pattern, InstrItinClass itin = NoItinerary>
  : InstBaseExt<opcode_indexed_ds, outs, ins, asmstr, pattern, itin>
{
  bits<7>  ra;
  bits<7>  rb;
  bits<7>  rc;
  bits<4>  opx;
  bits<3>  scale;
  bits<49> imm;

  let opx = mode.value;

  let Inst{83-42} = imm{48-7};
  let Inst{34-28} = ra;
  let Inst{27-21} = rb;
  let Inst{20-14} = rc;
  let Inst{13-11} = scale;
  let Inst{10-7}  = opx;
  let Inst{6-0}   = imm{6-0};
}

class PRIMARY_Indexed_WS<indexed_ws_opx mode, dag outs, dag ins, string asmstr,
                         list<dag> pattern, InstrItinClass itin = NoItinerary>
  : InstBase<opcode_indexed_ws, outs, ins, asmstr, pattern, itin>
{
  bits<7> ra;
  bits<7> rb;
  bits<7> rc;
  bits<4> opx;
  bits<3> scale;
  bits<7> imm;

  let opx = mode.value;

  let Inst{34-28} = ra;
  let Inst{27-21} = rb;
  let Inst{20-14} = rc;
  let Inst{13-11} = scale;
  let Inst{10-7}  = opx;
  let Inst{6-0}   = imm;
}

class PRIMARY_Indexed_WS_Long<indexed_ws_opx mode, dag outs, dag ins, string asmstr,
                             list<dag> pattern, InstrItinClass itin = NoItinerary>
  : InstBaseExt<opcode_indexed_ws, outs, ins, asmstr, pattern, itin>
{
  bits<7>  ra;
  bits<7>  rb;
  bits<7>  rc;
  bits<4>  opx;
  bits<3>  scale;
  bits<49> imm;

  let opx = mode.value;

  let Inst{83-42} = imm{48-7};
  let Inst{34-28} = ra;
  let Inst{27-21} = rb;
  let Inst{20-14} = rc;
  let Inst{13-11} = scale;
  let Inst{10-7}  = opx;
  let Inst{6-0}   = imm{6-0};
}

class PRIMARY_Indexed_WZ<indexed_wz_opx mode, dag outs, dag ins, string asmstr,
                         list<dag> pattern, InstrItinClass itin = NoItinerary>
  : InstBase<opcode_indexed_wz, outs, ins, asmstr, pattern, itin>
{
  bits<7> ra;
  bits<7> rb;
  bits<7> rc;
  bits<4> opx;
  bits<3> scale;
  bits<7> imm;

  let opx = mode.value;

  let Inst{34-28} = ra;
  let Inst{27-21} = rb;
  let Inst{20-14} = rc;
  let Inst{13-11} = scale;
  let Inst{10-7}  = opx;
  let Inst{6-0}   = imm;
}

class PRIMARY_Indexed_WZ_Long<indexed_wz_opx mode, dag outs, dag ins, string asmstr,
                             list<dag> pattern, InstrItinClass itin = NoItinerary>
  : InstBaseExt<opcode_indexed_wz, outs, ins, asmstr, pattern, itin>
{
  bits<7>  ra;
  bits<7>  rb;
  bits<7>  rc;
  bits<4>  opx;
  bits<3>  scale;
  bits<49> imm;

  let opx = mode.value;

  let Inst{83-42} = imm{48-7};
  let Inst{34-28} = ra;
  let Inst{27-21} = rb;
  let Inst{20-14} = rc;
  let Inst{13-11} = scale;
  let Inst{10-7}  = opx;
  let Inst{6-0}   = imm{6-0};
}

class PRIMARY_Rabcde<opcode_opx opcode, dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin = NoItinerary>
  : InstBase<opcode, outs, ins, asmstr, pattern, itin>
{
  bits<7> ra;
  bits<7> rb;
  bits<7> rc;
  bits<7> rd;
  bits<7> re;

  let Inst{34-28} = ra;
  let Inst{27-21} = rb;
  let Inst{20-14} = rc;
  let Inst{13-7}  = rd;
  let Inst{6-0}   = re;
}

//------------------------------------------------------------------------------
// MISC extended opcodes
//------------------------------------------------------------------------------
class MISC<misc_opx opxCode, dag outs, dag ins, string asmstr,
           list<dag> pattern, InstrItinClass itin = NoItinerary>
   : InstBase<opcode_misc, outs, ins, asmstr, pattern, itin>
{
  bits<11> opx;
  let opx = opxCode.value;
  let Inst{10-0} = opx;
}

class MISC_ext<misc_opx opxCode, dag outs, dag ins, string asmstr,
            list<dag> pattern, InstrItinClass itin = NoItinerary>
   : InstBaseExt<opcode_misc, outs, ins, asmstr, pattern, itin>
{
  bits<11> opx;
  let opx = opxCode.value;
  let Inst{10-0} = opx;
}

class MISC_Rabc<misc_opx opxCode, dag outs, dag ins, string asmstr,
                list<dag> pattern, InstrItinClass itin = NoItinerary>
   : MISC<opxCode, outs, ins, asmstr, pattern, itin>
{
  bits<7> ra;
  bits<7> rb;
  bits<7> rc;

  let Inst{34-28} = ra;
  let Inst{27-21} = rb;
  let Inst{20-14} = rc;
  let Inst{13-11} = 0;
}

class MISC_RabcScale<misc_opx opxCode,
                     dag outs, dag ins, string asmstr,
                     list<dag> pattern, InstrItinClass itin = NoItinerary>
  : MISC<opxCode, outs, ins, asmstr, pattern, itin>
{
  bits<7> ra;
  bits<7> rb;
  bits<7> rc;
  bits<3> scale;

  let Inst{34-28} = ra;
  let Inst{27-21} = rb;
  let Inst{20-14} = rc;
  let Inst{13-11} = scale;
}

class MISC_Rab<misc_opx opxCode, dag outs, dag ins, string asmstr,
               list<dag> pattern, InstrItinClass itin = IIC_iu_instr>
   : MISC<opxCode, outs, ins, asmstr, pattern, itin>
{
  bits<7> ra;
  bits<7> rb;

  let Inst{34-28} = ra;
  let Inst{27-21} = rb;
  let Inst{20-14} = 0; // rc
  let Inst{13-11} = 0;
}

class MISC_Rac<misc_opx opxCode, dag outs, dag ins, string asmstr,
               list<dag> pattern, InstrItinClass itin = IIC_iu_instr>
   : MISC<opxCode, outs, ins, asmstr, pattern, itin>
{
  bits<7> ra;
  bits<7> rc;

  let Inst{34-28} = ra;
  let Inst{27-21} = 0; // rb
  let Inst{20-14} = rc;
  let Inst{13-11} = 0;
}

class MISC_Rbc<misc_opx opxCode, dag outs, dag ins, string asmstr,
               list<dag> pattern, InstrItinClass itin = NoItinerary>
   : MISC<opxCode, outs, ins, asmstr, pattern, itin>
{
  bits<7> rb;
  bits<7> rc;
  let Inst{34-28} = 0; // ra
  let Inst{27-21} = rb;
  let Inst{20-14} = rc;
  let Inst{13-11} = 0;
}

// Shift by immediate.
class MISC_RabSc<misc_opx opxCode, dag outs, dag ins, string asmstr,
                 list<dag> pattern, InstrItinClass itin = IIC_iu_instr>
   : MISC<opxCode, outs, ins, asmstr, pattern, itin>
{
  bits<7> ra;
  bits<7> rb;
  bits<7> shcnt;   // shcnt32 / shcnt64.

  let Inst{34-28} = ra;
  let Inst{27-21} = rb;
  let Inst{20-14} = shcnt;
  let Inst{13-11} = 0;
}

class MISC_RabI10<misc_opx opxCode, dag outs, dag ins, string asmstr,
                  list<dag> pattern, InstrItinClass itin = NoItinerary>
   : MISC<opxCode, outs, ins, asmstr, pattern, itin>
{
  bits<7>  ra;
  bits<7>  rb;
  bits<10> imm;

  let Inst{34-28} = ra;
  let Inst{27-21} = rb;
  let Inst{20-11} = imm;
}

class MISC_RabI10_ext<misc_opx opxCode, dag outs, dag ins, string asmstr,
                  list<dag> pattern, InstrItinClass itin = NoItinerary>
   : MISC_ext<opxCode, outs, ins, asmstr, pattern, itin>
{
  bits<7>  ra;
  bits<7>  rb;
  bits<52> imm;

  let Inst{83-42} = imm{51-10};
  let Inst{34-28} = ra;
  let Inst{27-21} = rb;
  let Inst{20-11} = imm{9-0};
}

class MISC_RbI10<misc_opx opxCode, dag outs, dag ins, string asmstr,
                 list<dag> pattern, InstrItinClass itin = NoItinerary>
   : MISC<opxCode, outs, ins, asmstr, pattern, itin>
{
  bits<7>  rb;
  bits<10> imm;

  let Inst{34-28} = 0;
  let Inst{27-21} = rb;
  let Inst{20-11} = imm;
}

def rounding_mode : Operand<i8>, TImmLeaf<i8, [{ return isZextInt(Imm, 3) && Imm <= 5; }]> {
  let DecoderMethod = "DecodeUIMM<3>";
}

class MISC_RabRM<misc_opx opxCode, InstrItinClass itin = NoItinerary>
   : MISC<opxCode, (outs GR:$ra), (ins GR:$rb, rounding_mode:$rounding_mode),
     !strconcat(opxCode.mnem, "\t$ra, $rb, $rounding_mode"), [], itin>
{
  bits<7> ra;
  bits<7> rb;
  bits<3> rounding_mode;

  let Inst{34-28} = ra;
  let Inst{27-21} = rb;
  let Inst{20-14} = 0;
  let Inst{13-11}  = rounding_mode;
}

class MISC_NoArgs<misc_opx opxCode, dag outs, dag ins,
                  list<dag> pattern, InstrItinClass itin = IIC_iu_instr>
   : MISC<opxCode, outs, ins, opxCode.mnem, pattern, itin>
{
  let Inst{34-10} = 0;
}

//------------------------------------------------------------------------------
// FUSED extended opcodes
//------------------------------------------------------------------------------
class FUSED<fused_opx opxCode, dag outs, dag ins, string asmstr,
            list<dag> pattern, InstrItinClass itin = NoItinerary>
   : InstBase<opcode_fused, outs, ins, asmstr, pattern, itin>
{
  bits<7> opx;
  let opx = opxCode.value;
  let Inst{6-0} = opx;
}

class FUSED_ext<fused_opx opxCode, dag outs, dag ins, string asmstr,
            list<dag> pattern, InstrItinClass itin = NoItinerary>
   : InstBaseExt<opcode_fused, outs, ins, asmstr, pattern, itin>
{
  bits<7> opx;
  let opx = opxCode.value;
  let Inst{6-0} = opx;
}

class FUSED_Rabcd<fused_opx opxCode, dag outs, dag ins, string asmstr,
                  list<dag> pattern, InstrItinClass itin = NoItinerary>
   : FUSED<opxCode, outs, ins, asmstr, pattern, itin>
{
  bits<7> ra;
  bits<7> rb;
  bits<7> rc;
  bits<7> rd;

  let Inst{34-28} = ra;
  let Inst{27-21} = rb;
  let Inst{20-14} = rc;
  let Inst{13-7}  = rd;
}

multiclass FUSED_R4<fused_opx opx, PatFrag/*SDNode*/ OpNode,
                    ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : FUSED_Rabcd<opx,
                 (outs GR:$ra), (ins GR:$rb, GR:$rc, GR:$rd),
                 !strconcat(opx.mnem, "\t$ra, $rb, $rc, $rd"),
                 [(set Ty:$ra, (OpNode Ty:$rb, Ty:$rc, Ty:$rd))],
                 itin>;
}

multiclass FUSED_R4rrii<fused_opx opx, PatFrag/*SDNode*/ OpNode,
                    ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : FUSED_Rabcd<opx,
                 (outs GR:$ra), (ins GR:$rb, uimm6:$rc, uimm6:$rd),
                 !strconcat(opx.mnem, "\t$ra, $rb, $rc, $rd"),
                 [(set Ty:$ra, (OpNode Ty:$rb, uimm6:$rc, uimm6:$rd))],
                 itin>;
}

//===----------------------------------------------------------------------===//
// Nullification
//===----------------------------------------------------------------------===//

class Nullify<fused_opx opxCode, dag outs, dag ins,
    string asmstr, list<dag> pattern, InstrItinClass itin = NoItinerary>
    : FUSED<opxCode, outs, ins, asmstr, pattern, itin>
{
  bits<5> bb_yes;
  bits<5> bb_no;

  let Inst{16-12} = bb_no;
  let Inst{11-7}  = bb_yes;
}

class Nullify_ext<fused_opx opxCode, dag outs, dag ins,
   string asmstr, list<dag> pattern, InstrItinClass itin = NoItinerary>
  : FUSED_ext<opxCode, outs, ins, asmstr, pattern, itin>
{
  bits<5> bb_yes;
  bits<5> bb_no;

  let Inst{16-12} = bb_no;
  let Inst{11-7}  = bb_yes;
}

class Nullify_Rab<fused_opx fused_opx, bits<4> opxCode, dag outs, dag ins,
    string asmstr, list<dag> pattern, InstrItinClass itin = NoItinerary>
    : Nullify<fused_opx, outs, ins, asmstr, pattern, itin>
{
  bits<7> ra;
  bits<7> rb;
  bits<4> opx2;

  let opx2 = opxCode;

  let Inst{34-28} = ra;
  let Inst{27-21} = rb;
  let Inst{20-17} = opx2;
}

class Nullify_RaIMM<fused_opx opxCode, dag outs, dag ins,
    string asmstr, list<dag> pattern, InstrItinClass itin = NoItinerary>
    : Nullify<opxCode, outs, ins, asmstr, pattern, itin>
{
  bits<7>   ra;
  bits<7>   imm;

  let Inst{34-28} = ra;
  let Inst{27-21} = imm;
}

class Nullify_RaIMM_ext<fused_opx opxCode, dag outs, dag ins,
    string asmstr, list<dag> pattern, InstrItinClass itin = NoItinerary>
    : Nullify_ext<opxCode, outs, ins, asmstr, pattern, itin>
{
  bits<7>   ra;
  bits<40>  imm;

  let Inst{83-55} = imm{39-11};  // high 28 bit
  let Inst{54-42} = 0;           // high 13 bit
  let Inst{34-28} = ra;
  let Inst{27-17} = imm{10-0};
}

//------------------------------------------------------------------------------
// RAOPX extended opcodes
//------------------------------------------------------------------------------
class RAOPX<raopx_opx opxCode, dag outs, dag ins, string asmstr,
            list<dag> pattern, InstrItinClass itin = NoItinerary>
   : InstBase<opcode_raopx, outs, ins, asmstr, pattern, itin>
{
  bits<7> opx;
  let opx = opxCode.value;
  let Inst{34-28} = opx;
}

class RAOPX_ext<raopx_opx opxCode, dag outs, dag ins, string asmstr,
                list<dag> pattern, InstrItinClass itin = NoItinerary>
   : InstBaseExt<opcode_raopx, outs, ins, asmstr, pattern, itin>
{
  bits<7> opx;
  let opx = opxCode.value;
  let Inst{34-28} = opx;
}

class RAOPX_Branch<raopx_opx opxCode, dag outs, dag ins, string asmstr,
                   list<dag> pattern, InstrItinClass itin = NoItinerary>
   : RAOPX<opxCode, outs, ins, asmstr, pattern, itin>
{
  bits<28> imm;
  let Inst{27-0} = imm;
}

class RAOPX_Branch_ext<raopx_opx opxCode, dag outs, dag ins, string asmstr,
                   list<dag> pattern, InstrItinClass itin = NoItinerary>
   : RAOPX_ext<opxCode, outs, ins, asmstr, pattern, itin>
{
  bits<64> imm;

  let Inst{83-78} = 0;
  let Inst{77-42} = imm{63-28};
  let Inst{27-0}  = imm{27-0};
}

class RAOPX_RbI21<raopx_opx opxCode, dag outs, dag ins, string asmstr,
                  list<dag> pattern, InstrItinClass itin = NoItinerary>
   : RAOPX<opxCode, outs, ins, asmstr, pattern, itin>
{
  bits<7> rb;
  bits<21> imm;

  let Inst{27-21} = rb;
  let Inst{20-0}  = imm;
}

class RAOPX_RbI21_ext<raopx_opx opxCode, dag outs, dag ins, string asmstr,
                  list<dag> pattern, InstrItinClass itin = NoItinerary>
  : RAOPX_ext<opxCode, outs, ins, asmstr, pattern, itin>
{
  bits<7> rb;
  bits<63> imm;

  let Inst{83-42} = imm{62-21};
  let Inst{27-21} = rb;
  let Inst{20-0}  = imm{20-0};
}

//===----------------------------------------------------------------------===//
// standard builtins for registers only
//===----------------------------------------------------------------------===//
multiclass
BUILTIN_R2<misc_opx opx, ClangBuiltin OpNode, ValueType Ta, ValueType Tb, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : MISC_Rab<opx,
          (outs GR:$ra), (ins GR:$rb),
          !strconcat(opx.mnem, "\t$ra, $rb"),
          [(set Ta:$ra, (OpNode Tb:$rb))],
          itin>;
}

multiclass
BUILTIN_R3<misc_opx opx, ClangBuiltin OpNode, ValueType Ta, ValueType Tb, ValueType Tc, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : MISC_Rabc<opx,
          (outs GR:$ra), (ins GR:$rb, GR:$rc),
          !strconcat(opx.mnem, "\t$ra, $rb, $rc"),
          [(set Ta:$ra, (OpNode Tb:$rb, Tc:$rc))],
          itin>;
}

multiclass
BUILTIN_R4<fused_opx opx, ClangBuiltin OpNode, ValueType Ta, ValueType Tb, ValueType Tc, ValueType Td, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : FUSED_Rabcd<opx,
          (outs GR:$ra), (ins GR:$rb, GR:$rc, GR:$rd),
          !strconcat(opx.mnem, "\t$ra, $rb, $rc, $rd"),
          [(set Ta:$ra, (OpNode Tb:$rb, Tc:$rc, Td:$rd))],
          itin>;
}
