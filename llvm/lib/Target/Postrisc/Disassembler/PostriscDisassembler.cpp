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
#include "llvm/MC/MCDecoder.h"
#include "llvm/MC/MCDecoderOps.h"
#include "llvm/MC/MCDisassembler/MCDisassembler.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/Support/Compiler.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/Postrisc/PostriscBundle.h"
#include "llvm/ADT/APInt.h"

#define GET_gpr_reg_DECL
#define GET_spr_reg_DECL
#include "PostriscGenSearchableTables.inc"

using namespace llvm;
using namespace llvm::MCD;

#define DEBUG_TYPE "postrisc-disassembler"

typedef MCDisassembler::DecodeStatus DecodeStatus;

namespace {

/// A disassembler class for Postrisc.
class PostriscDisassembler : public MCDisassembler {
public:
  PostriscDisassembler(const MCSubtargetInfo &STI, MCContext &Ctx)
      : MCDisassembler(STI, Ctx) {}
  ~PostriscDisassembler() override = default;

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

extern "C" LLVM_ABI LLVM_EXTERNAL_VISIBILITY void
LLVMInitializePostriscDisassembler() {
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
    GENERAL_REGISTERS_CASES(X)
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
    SPECIAL_REGISTERS_CASES(X)
#undef X
  }
  if (reg == not_found)
    return MCDisassembler::Fail;

  Inst.addOperand(MCOperand::createReg(reg));
  return MCDisassembler::Success;
}

template <unsigned B> constexpr uint32_t ZeroExtend32(uint32_t X) {
  static_assert(B <= 32, "Bit width out of range.");
  if constexpr (B == 0)
    return 0;
  if constexpr (B == 32)
    return X;
  return X & ((static_cast<uint64_t>(1) << B) - 1);
}

template <unsigned B> constexpr uint64_t ZeroExtend64(uint64_t X) {
  static_assert(B <= 64, "Bit width out of range.");
  if constexpr (B == 0)
    return 0;
  if constexpr (B == 64)
    return X;
  return X & ((static_cast<uint64_t>(1) << B) - 1);
}

template<int Bits, typename InsnType>
static DecodeStatus
DecodeSIMM(MCInst &Inst, InsnType Imm, uint64_t Address, const MCDisassembler *Decoder) {
  Imm = SignExtend64<Bits>(Imm);
  Inst.addOperand(MCOperand::createImm(Imm));
  return MCDisassembler::Success;
}

template<int Bits, typename InsnType>
static DecodeStatus
DecodeUIMM(MCInst &Inst, InsnType Imm, uint64_t Address, const MCDisassembler *Decoder) {
  Imm = ZeroExtend64<Bits>(Imm);
  Inst.addOperand(MCOperand::createImm(Imm));
  return MCDisassembler::Success;
}

template<int Bits, typename InsnType>
static DecodeStatus
DecodeLoopStride(MCInst &Inst, InsnType Imm, uint64_t Address, const MCDisassembler *Decoder) {
  Inst.addOperand(MCOperand::createImm(Imm + 1));
  return MCDisassembler::Success;
}

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
