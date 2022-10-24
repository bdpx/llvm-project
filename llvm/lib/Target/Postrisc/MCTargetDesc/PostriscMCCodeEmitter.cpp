//===-- PostriscMCCodeEmitter.cpp - Convert Postrisc code to machine code -------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements the PostriscMCCodeEmitter class.
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/PostriscFixupKinds.h"
#include "MCTargetDesc/PostriscMCAsmInfo.h"
#include "PostriscMCTargetDesc.h"
#include "PostriscMCInstrInfo.h"
#include "Postrisc.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/BinaryFormat/ELF.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCCodeEmitter.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCFixup.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCObjectFileInfo.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/Support/Casting.h"
#include "llvm/Support/EndianStream.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/Postrisc/PostriscBundle.h"
#include "llvm/TargetParser/SubtargetFeature.h"
#include "llvm/CodeGen/TargetOpcodes.h"
#include <cassert>
#include <cstdint>

using namespace llvm;

#define DEBUG_TYPE "mccodeemitter"

STATISTIC(MCNumEmitted, "Number of MC instructions emitted");

namespace {

class PostriscMCCodeEmitter : public MCCodeEmitter {
  const MCInstrInfo &MCII;
  MCContext &Ctx;
  mutable int slot_num;
public:
  PostriscMCCodeEmitter(const MCInstrInfo &mcii, MCContext &ctx)
      : MCII(mcii), Ctx(ctx) {}
  PostriscMCCodeEmitter(const PostriscMCCodeEmitter &) = delete;
  PostriscMCCodeEmitter &operator=(const PostriscMCCodeEmitter &) = delete;
  ~PostriscMCCodeEmitter() override = default;

  void encodeInstruction(const MCInst &MI, SmallVectorImpl<char> &CB,
                         SmallVectorImpl<MCFixup> &Fixups,
                         const MCSubtargetInfo &STI) const override;

  // getBinaryCodeForInstr - TableGen'erated function for getting the
  // binary encoding for an instruction.
  void getBinaryCodeForInstr(const MCInst &MI,
                                 SmallVectorImpl<MCFixup> &Fixups,
                                 APInt &Inst,
                                 APInt &Scratch,
                                 const MCSubtargetInfo &STI) const;

  /// getMachineOpValue - Return binary encoding of operand. If the machine
  /// operand requires relocation, record the relocation and return zero.
  void getMachineOpValue(const MCInst &MI, const MCOperand &MO, APInt &op,
                             SmallVectorImpl<MCFixup> &Fixups,
                             const MCSubtargetInfo &STI) const;
  template<bool ext>
  void getCallTargetOpValue(const MCInst &MI, unsigned OpNo,
                            APInt &op,
                            SmallVectorImpl<MCFixup> &Fixups,
                            const MCSubtargetInfo &STI) const;
  template<bool ext>
  void getJumpTargetOpValue(const MCInst &MI, unsigned OpNo,
                            APInt &op,
                            SmallVectorImpl<MCFixup> &Fixups,
                            const MCSubtargetInfo &STI) const;

  template<bool ext>
  void getBranchTargetOpValue(const MCInst &MI, unsigned OpNo,
                            APInt &op,
                            SmallVectorImpl<MCFixup> &Fixups,
                            const MCSubtargetInfo &STI) const;

};

} // end anonymous namespace

static void addFixup(SmallVectorImpl<MCFixup> &Fixups, uint32_t Offset,
                     const MCExpr *Value, uint16_t Kind) {
  bool PCRel = false;
#define ALL_CASES(NAME)                      \
  case ELF::R_POSTRISC_A_ ## NAME:           \
  case ELF::R_POSTRISC_B_ ## NAME:           \
  case ELF::R_POSTRISC_C_ ## NAME:           \
  case ELF::R_POSTRISC_A_ ## NAME ## _EXT:   \
  case ELF::R_POSTRISC_B_ ## NAME ## _EXT:   \

  switch (Kind) {
  ALL_CASES(JUMP)
  ALL_CASES(BRANCH)
  ALL_CASES(PCREL_FWD)
  ALL_CASES(PCREL_FWD_GOT)
  ALL_CASES(PCREL_FWD_PLT)
  ALL_CASES(LD_IMM)
  ALL_CASES(OFFSET)
  ALL_CASES(TLS_GD_GOT_OFFSET)
  ALL_CASES(TLS_GD_CALL)
  ALL_CASES(TLS_LD_GOT_OFFSET)
  ALL_CASES(TLS_LD_CALL)
  ALL_CASES(TLS_LD_OFFSET)
  ALL_CASES(TLS_IE_OFFSET)
  ALL_CASES(TLS_LE_OFFSET)
#undef ALL_CASES
    PCRel = true;
  }
  Fixups.push_back(MCFixup::create(Offset, Value, Kind, PCRel));
}

static MCFixupKind getFixupKind(Postrisc::Specifier specifier, int slot_num)
{
#define ALL_CASES(NAME)                                                  \
  case Postrisc::S_ ## NAME:                                             \
  switch (slot_num) {                                                    \
    case 0: return ELF::R_POSTRISC_A_ ## NAME;                           \
    case 1: return ELF::R_POSTRISC_B_ ## NAME;                           \
    case 2: return ELF::R_POSTRISC_C_ ## NAME;                           \
    default:                                                             \
      dbgs() << #NAME "unhandled short slot num " << slot_num << "\n";   \
      llvm_unreachable(#NAME "Unhandled short slot_num");                \
    }                                                                    \
    break;                                                               \
  case Postrisc::S_ ## NAME ## _EXT:                                     \
  switch (slot_num) {                                                    \
    case 0: return ELF::R_POSTRISC_A_ ## NAME ## _EXT;                   \
    case 1: return ELF::R_POSTRISC_B_ ## NAME ## _EXT;                   \
    default:                                                             \
      dbgs() << #NAME "unhandled long slot num " << slot_num << "\n";    \
      llvm_unreachable(#NAME "Unhandled long slot_num");                 \
    }                                                                    \
    break;                                                               \

  switch (specifier) {
  default: llvm_unreachable("Unhandled Postrisc::Specifier");
  case Postrisc::S_R_DISP32: return ELF::R_POSTRISC_R_DISP32;
  case Postrisc::S_GOTOFF: return ELF::R_POSTRISC_GOTOFF;

  ALL_CASES(JUMP)
  ALL_CASES(BRANCH)
  ALL_CASES(PCREL_FWD)
  ALL_CASES(LD_IMM)
  ALL_CASES(OFFSET)
  ALL_CASES(TLS_GD_GOT_OFFSET)
  ALL_CASES(TLS_GD_CALL)
  ALL_CASES(TLS_LD_GOT_OFFSET)
  ALL_CASES(TLS_LD_CALL)
  ALL_CASES(TLS_LD_OFFSET)
  ALL_CASES(TLS_IE_OFFSET)
  ALL_CASES(TLS_LE_OFFSET)
#undef ALL_CASES
  }

  dbgs() << "unhandled specifier: " << (int)specifier << " slot=" << slot_num << "\n";
  llvm_unreachable("Unhandled specifier to fixup");
}

void PostriscMCCodeEmitter::encodeInstruction(const MCInst &MI,
                                           SmallVectorImpl<char> &CB,
                                           SmallVectorImpl<MCFixup> &Fixups,
                                           const MCSubtargetInfo &STI) const {
  const llvm::endianness endianness =
        Ctx.getAsmInfo()->isLittleEndian() ? llvm::endianness::little
                                           : llvm::endianness::big;
  assert(endianness == llvm::endianness::little);

  LLVM_DEBUG(dbgs() << "encodeInstruction(s): " << MI << "\n");
  assert(Postrisc::isBundle(MI));

  APInt Inst;
  APInt Scratch;
  LLVM_DEBUG(dbgs() << "encodeInstruction(bundle): " << MI.size() << " " << MI << "\n");
  uint64_t slot[3] = { 0 };
  unsigned is_long_mask = 0;
  slot_num = 0;
  for (auto &I : Postrisc::bundleInstructions(MI)) {
    MCInst const &HMI = *I.getInst();

    unsigned const Opcode = HMI.getOpcode();
    const MCInstrDesc &Desc = MCII.get(Opcode);
    uint64_t const TSFlags = Desc.TSFlags;
    bool const isLong = postrisc::isLong(TSFlags);

    getBinaryCodeForInstr(HMI, Fixups, Inst, Scratch, STI);
    LLVM_DEBUG(dbgs() << "encodeInstruction: Inst "
           << format_hex_no_prefix(Inst.extractBitsAsZExtValue(
                                   postrisc::CBundle::bits_per_slot,
                                   postrisc::CBundle::bits_per_slot),
                                   (postrisc::CBundle::bits_per_slot+3)/4)
           << ' '
           << format_hex_no_prefix(Inst.extractBitsAsZExtValue(
                                   postrisc::CBundle::bits_per_slot, 0),
                                   (postrisc::CBundle::bits_per_slot+3)/4)
           << "\n");
    //Inst.dump();
    uint64_t const bits = Inst.extractBitsAsZExtValue(postrisc::CBundle::bits_per_slot, 0);
    LLVM_DEBUG(dbgs() << "encodeInstruction: 0x");
    LLVM_DEBUG(dbgs().write_hex(bits));
    LLVM_DEBUG(dbgs() << " " << HMI << " Fixups=" << Fixups.size() << "\n");
    assert(slot_num < 3);
    is_long_mask = (is_long_mask << 1) | isLong;
    slot[slot_num++] = bits;
    if (isLong) {
      uint64_t const ext_bits = Inst.extractBitsAsZExtValue(
           postrisc::CBundle::bits_per_slot, postrisc::CBundle::bits_per_slot);
      LLVM_DEBUG(dbgs() << "encodeInstruction(ext): 0x");
      LLVM_DEBUG(dbgs().write_hex(ext_bits));
      assert(slot_num < 3);
      is_long_mask = (is_long_mask << 1) | isLong;
      slot[slot_num++] = ext_bits;
    }
    ++MCNumEmitted;  // Keep track of the # of mi's emitted.
  }
  postrisc::EBundleTemplate Template = postrisc::EBundleTemplate::bundle_sss;
  switch (is_long_mask) {
    case 0+0+0: Template = postrisc::EBundleTemplate::bundle_sss;  break;
    case 0+2+1: Template = postrisc::EBundleTemplate::bundle_sll;  break;
    case 4+2+0: Template = postrisc::EBundleTemplate::bundle_lls;  break;
    default:
      dbgs() << "encodeInstruction: invalid template " << is_long_mask << "\n";
      llvm_unreachable("Unhandled is_long_mask!");
  }
  postrisc::CBundle bundle = postrisc::CBundle::create(slot, Template);
  LLVM_DEBUG(dbgs() << "encodeInstruction: bundle " << bundle << "\n");

  if (endianness == llvm::endianness::little) {
    support::endian::write(CB, bundle.lo, endianness);
    support::endian::write(CB, bundle.hi, endianness);
  } else {
    support::endian::write(CB, bundle.hi, endianness);
    support::endian::write(CB, bundle.lo, endianness);
  }
}

void PostriscMCCodeEmitter::
getMachineOpValue(const MCInst &MI, const MCOperand &MO,
                  APInt &op,
                  SmallVectorImpl<MCFixup> &Fixups,
                  const MCSubtargetInfo &STI) const {
  if (MO.isReg())
  {
    op = Ctx.getRegisterInfo()->getEncodingValue(MO.getReg());
    return;
  }

  if (MO.isImm())
  {
    op = MO.getImm();
    return;
  }

  assert(MO.isExpr());
  const MCExpr *Expr = MO.getExpr();
  if (const auto *SExpr = dyn_cast<MCSpecifierExpr>(Expr)) {
    MCFixupKind Kind = getFixupKind(static_cast<Postrisc::Specifier>(SExpr->getSpecifier()), slot_num);
    //Fixups.push_back(MCFixup::create(0, Expr, Kind, true/*PCRel*/));
    addFixup(Fixups, 0, Expr, Kind);
    op = 0;
    return;
  }

  int64_t Res;
  if (Expr->evaluateAsAbsolute(Res))
  {
    op = Res;
    return;
  }

  llvm_unreachable("Unhandled expression!");
  op = 0;
}

template<bool ext>
void PostriscMCCodeEmitter::
getCallTargetOpValue(const MCInst &MI, unsigned OpNo,
                     APInt &op,
                     SmallVectorImpl<MCFixup> &Fixups,
                     const MCSubtargetInfo &STI) const {
  const MCOperand &MO = MI.getOperand(OpNo);
  const MCExpr *Expr = MO.getExpr();
  const MCSpecifierExpr *SExpr = dyn_cast<MCSpecifierExpr>(Expr);
  assert(SExpr);

  LLVM_DEBUG(dbgs() << "getCallTargetOpValue:" << OpNo << " " << MO << "\n");
  if (MO.isReg() || MO.isImm()) {
    return getMachineOpValue(MI, MO, op, Fixups, STI);
  }
#if 0
  if (MI.getOpcode() == POSTRISC::TLS_CALL) {
    // No fixups for __tls_get_addr. Will emit for fixups for tls_symbol in
    // encodeInstruction.
#ifndef NDEBUG
    // Verify that the callee is actually __tls_get_addr.
    assert(SExpr && SExpr->getSubExpr()->getKind() == MCExpr::SymbolRef && "Unexpected expression in TLS_CALL");
    const MCSymbolRefExpr *SymExpr = cast<MCSymbolRefExpr>(SExpr->getSubExpr());
    assert(SymExpr->getSymbol().getName() == "__tls_get_addr" && "Unexpected function for TLS_CALL");
#endif
    op = 0;
    return;
  }
#endif

  MCFixupKind Kind = getFixupKind(static_cast<Postrisc::Specifier>(SExpr->getSpecifier()), slot_num);
  // Fixups.push_back(MCFixup::create(0, Expr, Kind));
  addFixup(Fixups, 0, Expr, Kind);
  op = 0;
}

template<bool ext>
void PostriscMCCodeEmitter::
getJumpTargetOpValue(const MCInst &MI, unsigned OpNo,
                  APInt &op,
                  SmallVectorImpl<MCFixup> &Fixups,
                  const MCSubtargetInfo &STI) const {
  const MCOperand &MO = MI.getOperand(OpNo);
  LLVM_DEBUG(dbgs() << "getJumpTargetOpValue:"
                    << ext << " OpNo=" << OpNo << " " << MO << "\n");

  if (MO.isReg() || MO.isImm()) {
    return getMachineOpValue(MI, MO, op, Fixups, STI);
  }

  const MCFixupKind fixup = getFixupKind(ext ? Postrisc::S_JUMP_EXT : Postrisc::S_JUMP, slot_num);
  Fixups.push_back(MCFixup::create(0, MO.getExpr(), fixup, true/*PCRel*/));
  op = 0;
}

template<bool ext>
void PostriscMCCodeEmitter::
getBranchTargetOpValue(const MCInst &MI, unsigned OpNo,
                  APInt &op,
                  SmallVectorImpl<MCFixup> &Fixups,
                  const MCSubtargetInfo &STI) const {
  const MCOperand &MO = MI.getOperand(OpNo);
  LLVM_DEBUG(dbgs() << "getBranchTargetOpValue:"
                    << ext << " OpNo=" << OpNo << " " << MO << "\n");
  if (MO.isReg() || MO.isImm()) {
    return getMachineOpValue(MI, MO, op, Fixups, STI);
  }

  const MCFixupKind fixup = getFixupKind(ext ? Postrisc::S_BRANCH_EXT : Postrisc::S_BRANCH, slot_num);
  Fixups.push_back(MCFixup::create(0, MO.getExpr(), fixup, true/*PCRel*/));
  op = 0;
}

#include "PostriscGenMCCodeEmitter.inc"

MCCodeEmitter *llvm::createPostriscMCCodeEmitter(const MCInstrInfo &MCII,
                                              MCContext &Ctx) {
  return new PostriscMCCodeEmitter(MCII, Ctx);
}
