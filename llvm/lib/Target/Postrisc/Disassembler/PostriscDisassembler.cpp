//===- PostriscDisassembler.cpp - Disassembler for Postrisc -----------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file is part of the Postrisc Disassembler.
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/PostriscMCTargetDesc.h"
#include "TargetInfo/PostriscTargetInfo.h"
#include "Postrisc.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCDecoderOps.h"
#include "llvm/MC/MCDisassembler/MCDisassembler.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/Support/Debug.h"
#include "llvm/ADT/APInt.h"

#define GET_gpr_reg_DECL
#define GET_spr_reg_DECL
#include "PostriscGenSearchableTables.inc"

using namespace llvm;

#define DEBUG_TYPE "postrisc-disassembler"

typedef MCDisassembler::DecodeStatus DecodeStatus;

namespace {

/// A disassembler class for Postrisc.
class PostriscDisassembler : public MCDisassembler {
public:
  PostriscDisassembler(const MCSubtargetInfo &STI, MCContext &Ctx)
      : MCDisassembler(STI, Ctx) {}
  virtual ~PostriscDisassembler() = default;

  DecodeStatus getInstruction(MCInst &Instr, uint64_t &Size,
                              ArrayRef<uint8_t> Bytes, uint64_t Address,
                              raw_ostream &CStream) const override;
private:
  DecodeStatus DecodeShort(MCInst &MI, uint64_t slot, uint64_t Address) const;
  DecodeStatus DecodeLong(MCInst &MI, APInt const& slot, uint64_t Address) const;

};
}

static MCDisassembler *createPostriscDisassembler(const Target &T,
                                               const MCSubtargetInfo &STI,
                                               MCContext &Ctx) {
  return new PostriscDisassembler(STI, Ctx);
}


extern "C" LLVM_EXTERNAL_VISIBILITY void LLVMInitializePostriscDisassembler() {
  // Register the disassembler.
  TargetRegistry::RegisterMCDisassembler(getThePostriscTarget(),
                                         createPostriscDisassembler);
}

static DecodeStatus DecodeGRRegisterClass(MCInst &Inst, unsigned RegNo,
                                              uint64_t Address,
                                              const MCDisassembler *Decoder) {
  unsigned const not_found = -1;
  unsigned reg = not_found;
  switch (static_cast<gpr_reg>(RegNo)) {
#define X(NAME) case gpr_reg_ ## NAME: reg = POSTRISC::NAME; break;
#define R(ID) X(r##ID)
  R(0)   R(1)   R(2)   R(3)   R(4)   R(5)   R(6)   R(7)
  R(8)   R(9)   R(10)  R(11)  R(12)  R(13)  R(14)  R(15)
  R(16)  R(17)  R(18)  R(19)  R(20)  R(21)  R(22)  R(23)
  R(24)  R(25)  R(26)  R(27)  R(28)  R(29)  R(30)  R(31)
  R(32)  R(33)  R(34)  R(35)  R(36)  R(37)  R(38)  R(39)
  R(40)  R(41)  R(42)  R(43)  R(44)  R(45)  R(46)  R(47)
  R(48)  R(49)  R(50)  R(51)  R(52)  R(53)  R(54)  R(55)
  R(56)  R(57)  R(58)  R(59)  R(60)  R(61)  R(62)  R(63)
  R(64)  R(65)  R(66)  R(67)  R(68)  R(69)  R(70)  R(71)
  R(72)  R(73)  R(74)  R(75)  R(76)  R(77)  R(78)  R(79)
  R(80)  R(81)  R(82)  R(83)  R(84)  R(85)  R(86)  R(87)
  R(88)  R(89)  R(90)  R(91)  R(92)  R(93)  R(94)  R(95)
  R(96)  R(97)  R(98)  R(99)  R(100) R(101) R(102) R(103)
  R(104) R(105) R(106) R(107) R(108) R(109) R(110) R(111)
  R(112) R(113) R(114) R(115) R(116) R(117) R(118) R(119)
#undef R
  // globals
  X(g0)  X(g1)  X(g2)  X(g3)  X(tp)  X(fp)  X(sp)  X(gz)
#undef X
  }
  if (reg == not_found)
    return MCDisassembler::Fail;

  Inst.addOperand(MCOperand::createReg(reg));
  return MCDisassembler::Success;
}

static DecodeStatus DecodeSRRegisterClass(MCInst &Inst, unsigned RegNo,
                                              uint64_t Address,
                                              const MCDisassembler *Decoder) {
  unsigned const not_found = -1;
  unsigned reg = not_found;
  switch (static_cast<spr_reg>(RegNo)) {
#define X(NAME) case spr_reg_ ## NAME: reg = POSTRISC::NAME; break;
    X(ip) X(eip) X(fpcr) X(eca) X(rsc) X(rsp) X(bsp)
    X(psr) X(reip) X(kip) X(ksp) X(krsp) X(peb) X(teb) X(itc) X(itm) X(pta) X(iva)
    X(iip) X(iipa) X(ipsr) X(cause) X(ifa) X(iib)
    X(irr0) X(irr1) X(irr2) X(irr3) X(isr0) X(isr1) X(isr2) X(isr3)
    X(iv) X(lid) X(tpr) X(itcv) X(tsv) X(pmv) X(cmcv)
#undef X
  }
  if (reg == not_found)
    return MCDisassembler::Fail;

  Inst.addOperand(MCOperand::createReg(reg));
  return MCDisassembler::Success;
}

template<int Bits, typename InsnType>
static DecodeStatus
DecodeSIMM(MCInst &Inst, InsnType Imm, uint64_t Address, const MCDisassembler *Decoder)
{
  Imm = SignExtend64<Bits>(Imm);
  Inst.addOperand(MCOperand::createImm(Imm));
  return MCDisassembler::Success;
}

template<int Bits, typename InsnType>
static DecodeStatus
DecodeUIMM(MCInst &Inst, InsnType Imm, uint64_t Address,
                              const MCDisassembler *Decoder) {
  Inst.addOperand(MCOperand::createImm(Imm));
  return MCDisassembler::Success;
}

template <typename InsnType>
static DecodeStatus DecodeCall(MCInst &Inst, InsnType insn, uint64_t Address,
                               const MCDisassembler *Decoder);

template <int nbits, typename InsnType>
static DecodeStatus DecodeBranch(MCInst &Inst, InsnType insn, uint64_t Address,
                                 const MCDisassembler *Decoder);

#include "PostriscGenDisassemblerTables.inc"

/// Read 8 bytes from the ArrayRef and return 64-bit word.
static uint64_t
readInstruction64(ArrayRef<uint8_t> Bytes, bool IsLittleEndian)
{
  uint64_t Insn = IsLittleEndian
    ? ((uint64_t)Bytes[0] <<  0) |
      ((uint64_t)Bytes[1] <<  8) |
      ((uint64_t)Bytes[2] << 16) |
      ((uint64_t)Bytes[3] << 24) |
      ((uint64_t)Bytes[4] << 32) |
      ((uint64_t)Bytes[5] << 40) |
      ((uint64_t)Bytes[6] << 48) |
      ((uint64_t)Bytes[7] << 56)
    : ((uint64_t)Bytes[7] <<  0) |
      ((uint64_t)Bytes[6] <<  8) |
      ((uint64_t)Bytes[5] << 16) |
      ((uint64_t)Bytes[4] << 24) |
      ((uint64_t)Bytes[3] << 32) |
      ((uint64_t)Bytes[2] << 40) |
      ((uint64_t)Bytes[1] << 48) |
      ((uint64_t)Bytes[0] << 56);

  return Insn;
}

// DecoderTablePostrisc64 should be auto-generated
DecodeStatus
PostriscDisassembler::DecodeShort(MCInst &MI, uint64_t slot, uint64_t Address) const
{
  MCInst *Inst = getContext().createMCInst();
  DecodeStatus Result = decodeInstruction(DecoderTablePostrisc64, *Inst, slot, Address, this, STI);
  if (Result == MCDisassembler::Fail) {
     return Result;
  }
  MI.addOperand(MCOperand::createInst(Inst));
  return Result;
}

// DecoderTablePostrisc128 should be auto-generated
DecodeStatus
PostriscDisassembler::DecodeLong(MCInst &MI, APInt const& ap, uint64_t Address) const
{
  MCInst *Inst = getContext().createMCInst();
  DecodeStatus Result = decodeInstruction(DecoderTablePostrisc128, *Inst, ap, Address, this, STI);
  if (Result == MCDisassembler::Fail) {
    return Result;
  }
  MI.addOperand(MCOperand::createInst(Inst));
  return Result;
}

DecodeStatus PostriscDisassembler::getInstruction(MCInst &Instr, uint64_t &Size,
                                               ArrayRef<uint8_t> Bytes,
                                               uint64_t Address,
                                               raw_ostream &CStream) const {
  bool isLittleEndian = getContext().getAsmInfo()->isLittleEndian();

  // We want to read exactly 16 Bytes of data.
  if (Bytes.size() < sizeof(postrisc::CBundle)) {
    Size = 0;
    return MCDisassembler::Fail;
  }

  postrisc::CBundle bundle;
  bundle.lo = readInstruction64(Bytes, isLittleEndian);
  Bytes = Bytes.slice(8);
  bundle.hi = readInstruction64(Bytes, isLittleEndian);

  postrisc::EBundleTemplate Template = bundle.GetTemplate();
  uint64_t slots[3] = {
     bundle.GetSlotA(),
     bundle.GetSlotB(),
     bundle.GetSlotC()
  };

  LLVM_DEBUG(dbgs() << "getInstruction: bundle " << bundle << "\n");

  DecodeStatus Result;
  uint64_t bigVal[2];

  Instr.setOpcode(POSTRISC::BUNDLE);
  Instr.addOperand(MCOperand::createImm(0));
  switch (Template) {
    case postrisc::EBundleTemplate::bundle_sss:
      for (int i = 0; i < 3; i++) {
        Result = DecodeShort(Instr, slots[i], Address);
        if (Result != MCDisassembler::Success) {
          dbgs() << "DecodeShort(sss) slot[" << i << "] failed"
                 << " result=" << (int)Result
                 << " bundle: " << bundle << "\n";
          return Result;
        }
      }
      break;

    case postrisc::EBundleTemplate::bundle_sll: {
      Result = DecodeShort(Instr, slots[0], Address);
      if (Result != MCDisassembler::Success) {
        dbgs() << "DecodeShort(lls) failed " << (int)Result << "\n";
        return Result;
      }
      bigVal[0] = slots[1] | (slots[2] << postrisc::CBundle::bits_per_slot);
      bigVal[1] = slots[2] >> (64 - postrisc::CBundle::bits_per_slot);
      APInt ap(128, ArrayRef<uint64_t>(bigVal, 2));
      Result = DecodeLong(Instr, ap, Address);
      if (Result != MCDisassembler::Success) {
        dbgs() << "DecodeLong(lls) failed " << (int)Result << "\n";
        return Result;
      }
      }
      break;
    case postrisc::EBundleTemplate::bundle_lls: {
      bigVal[0] = slots[0] | (slots[1] << postrisc::CBundle::bits_per_slot);
      bigVal[1] = slots[1] >> (64 - postrisc::CBundle::bits_per_slot);
      APInt ap(128, ArrayRef<uint64_t>(bigVal, 2));
      Result = DecodeLong(Instr, ap, Address);
      if (Result != MCDisassembler::Success) {
        dbgs() << "DecodeLong(sll) failed " << (int)Result << "\n";
        return Result;
      }
      Result = DecodeShort(Instr, slots[2], Address);
      if (Result != MCDisassembler::Success) {
        dbgs() << "DecodeShort(sll) failed " << (int)Result << "\n";
        return Result;
      }
      }
      break;
    default:
      llvm_unreachable("Invalid bundle template");
      break;
  }

  Size = sizeof(postrisc::CBundle);
  return MCDisassembler::Success;
}

static bool tryAddingSymbolicOperand(int64_t Value, bool isBranch,
                                     uint64_t Address, uint64_t Offset,
                                     uint64_t Width, MCInst &MI,
                                     const MCDisassembler *Decoder) {
  return Decoder->tryAddingSymbolicOperand(MI, Value, Address, isBranch, Offset,
                                           Width, /*InstSize=*/sizeof(postrisc::CBundle));
}

template <typename InsnType>
static DecodeStatus DecodeCall(MCInst &MI, InsnType insn, uint64_t Address,
                               const MCDisassembler *Decoder) {
  InsnType offset = insn * sizeof(postrisc::CBundle);
  if (!tryAddingSymbolicOperand(Address + offset, false, Address,
                                0, 28, MI, Decoder))
    MI.addOperand(MCOperand::createImm(offset));
  return MCDisassembler::Success;
}

template <int nbits, typename InsnType>
static DecodeStatus
DecodeBranch(MCInst &MI, InsnType insn, uint64_t Address, const MCDisassembler *Decoder)
{
  InsnType tgt = SignExtend64<nbits>(insn);
  LLVM_DEBUG(dbgs() << "DecodeBranch: Address=" << Address
                    << " tgt(" << nbits << ")=" << (int64_t)(tgt) << "\n");

  InsnType offset = tgt * sizeof(postrisc::CBundle);

  if (!tryAddingSymbolicOperand(Address + offset, false, Address, 0, nbits, MI, Decoder))
    MI.addOperand(MCOperand::createImm(offset));
  return MCDisassembler::Success;
}
