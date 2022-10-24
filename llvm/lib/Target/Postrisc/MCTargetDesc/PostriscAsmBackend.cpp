//===-- PostriscAsmBackend.cpp - Postrisc Assembler Backend ---------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/PostriscFixupKinds.h"
#include "MCTargetDesc/PostriscMCTargetDesc.h"
#include "Postrisc.h"
#include "llvm/ADT/StringSwitch.h"
#include "llvm/MC/MCAsmBackend.h"
#include "llvm/MC/MCELFObjectWriter.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCFixupKindInfo.h"
#include "llvm/MC/MCObjectWriter.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/MCValue.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/MC/MCAssembler.h"
#include "llvm/Support/EndianStream.h"
#include "llvm/Support/Debug.h"

using namespace llvm;

#define DEBUG_TYPE "postrisc-asmbackend"

#define FIXUP_ALL_FORMS_CASES(NAME)               \
  case Postrisc::FIXUP_POSTRISC_A_##NAME:         \
  case Postrisc::FIXUP_POSTRISC_B_##NAME:         \
  case Postrisc::FIXUP_POSTRISC_C_##NAME:         \
  case Postrisc::FIXUP_POSTRISC_A_##NAME##_EXT:   \
  case Postrisc::FIXUP_POSTRISC_B_##NAME##_EXT:   \

namespace {
  class PostriscAsmBackend : public MCAsmBackend {
  protected:
    const Target &TheTarget;
    bool Is64Bit;

  public:
    PostriscAsmBackend(const Target &T)
        : MCAsmBackend(llvm::endianness::little),
          TheTarget(T), Is64Bit(true) {}

    MCFixupKindInfo getFixupKindInfo(MCFixupKind Kind) const override {
      // should be coherent with PostriscFixupKinds.h
      const static MCFixupKindInfo InfosLE[Postrisc::NumTargetFixupKinds] = {
        // name offset bits flags
        #define FIXUP_KINDINFO(NAME, TARGET_OFFSET, TARGET_SIZE, FLAGS) \
            { "FIXUP_POSTRISC_" #NAME, TARGET_OFFSET, TARGET_SIZE, FLAGS },

        DEFINE_FIXUP_TABLE(FIXUP_KINDINFO)
        #undef FIXUP_KINDINFO
      };

      // Fixup kinds from .reloc directive are like R_POSTRISC_NONE. They do
      // not require any extra processing.
      if (mc::isRelocation(Kind))
        return MCAsmBackend::getFixupKindInfo(FK_NONE);

      if (Kind < FirstTargetFixupKind)
        return MCAsmBackend::getFixupKindInfo(Kind);

      assert(unsigned(Kind - FirstTargetFixupKind) < Postrisc::NumTargetFixupKinds &&
             "Invalid kind!");

      assert(Endian == llvm::endianness::little && "little endian only!");
        return InfosLE[Kind - FirstTargetFixupKind];
    }

    bool shouldForceRelocation(const MCFixup &Fixup, const MCValue &Target) override {
      LLVM_DEBUG(dbgs() << "PostriscAsmBackend::shouldForceRelocation " << Fixup.getTargetKind() << "\n");
      //Asm.dump();

      switch ((Postrisc::Fixups)Fixup.getKind()) {
      default:
        return false;
      FIXUP_ALL_FORMS_CASES(JUMP)
      FIXUP_ALL_FORMS_CASES(BRANCH)
        if (Target.getAddSym()->isTemporary())
          return false;
        [[fallthrough]];
      FIXUP_ALL_FORMS_CASES(PCREL_FWD)
      FIXUP_ALL_FORMS_CASES(PCREL_FWD_GOT)
      FIXUP_ALL_FORMS_CASES(PCREL_FWD_PLT)
      FIXUP_ALL_FORMS_CASES(LDI)
      FIXUP_ALL_FORMS_CASES(OFFSET)
      FIXUP_ALL_FORMS_CASES(TLS_GD_GOT_OFFSET)
      FIXUP_ALL_FORMS_CASES(TLS_GD_CALL)
      FIXUP_ALL_FORMS_CASES(TLS_LD_GOT_OFFSET)
      FIXUP_ALL_FORMS_CASES(TLS_LD_CALL)
      FIXUP_ALL_FORMS_CASES(TLS_LD_OFFSET)
      FIXUP_ALL_FORMS_CASES(TLS_IE_OFFSET)
      FIXUP_ALL_FORMS_CASES(TLS_LE_OFFSET)
        return true;
      }
    }

    void relaxInstruction(MCInst &Inst,
                          const MCSubtargetInfo &STI) const override {
      // FIXME.
      llvm_unreachable("relaxInstruction() unimplemented");
    }

    bool writeNopData(raw_ostream &OS, uint64_t Count,
                      const MCSubtargetInfo *STI) const override {
      if (Count == 0)
        return true;
      // Cannot emit NOP with size not multiple of bundle.
      return false;

      llvm_unreachable("writeNopData() unimplemented");
      if (Count % 16 != 0)
        return false;

      uint64_t NumNops = Count / 4;
      for (uint64_t i = 0; i != NumNops; ++i)
        support::endian::write<uint32_t>(OS, 0x01000000, Endian);

      return true;
    }
  };

  class ELFPostriscAsmBackend : public PostriscAsmBackend {
    Triple::OSType OSType;
  public:
    ELFPostriscAsmBackend(const Target &T, Triple::OSType OSType) :
      PostriscAsmBackend(T), OSType(OSType) { }

    void applyFixup(const MCFragment &fragment, const MCFixup &Fixup,
                    const MCValue &Target, MutableArrayRef<char> Data,
                    uint64_t Value, bool IsResolved) override;

    std::unique_ptr<MCObjectTargetWriter>
    createObjectTargetWriter() const override {
      uint8_t OSABI = MCELFObjectTargetWriter::getOSABI(OSType);
      return createPostriscELFObjectWriter(Is64Bit, OSABI);
    }
  };


static void
FixupOffset(postrisc::CBundle *bundle, uint64_t Value,
  postrisc::slot_type slottype,
  unsigned field_offset, unsigned field_size,
  unsigned field_ext_offset, unsigned field_ext_size)
{
  LLVM_DEBUG(dbgs() << "FixupOffset[" << (int)slottype << "] "
         << field_offset << ":" << field_size
         << " Value=" << (int64_t)Value << "\n");

  postrisc::EBundleTemplate const Template = bundle->GetTemplate();
  uint64_t slot[3] = {
    bundle->GetSlotA(),
    bundle->GetSlotB(),
    bundle->GetSlotC()
  };

  assert(field_size + field_offset <= postrisc::CBundle::bits_per_slot);
  assert(field_ext_size + field_ext_offset <= postrisc::CBundle::bits_per_slot);

  uint64_t const mask_lo  = ((UINT64_C(1) << field_size    ) - 1) << field_offset;
  uint64_t const mask_hi  = ((UINT64_C(1) << field_ext_size) - 1) << field_ext_offset;

  uint64_t const value_lo = ((Value              ) << field_offset    ) & mask_lo;
  uint64_t const value_hi = ((Value >> field_size) << field_ext_offset) & mask_hi;

  switch (slottype) {
    case postrisc::SLOT_A:
      assert(bundle->GetTemplate() == postrisc::EBundleTemplate::bundle_sss ||
             bundle->GetTemplate() == postrisc::EBundleTemplate::bundle_sll);
      slot[0] &= ~mask_lo;
      slot[0] |= value_lo;
      break;
    case postrisc::SLOT_B:
      assert(bundle->GetTemplate() == postrisc::EBundleTemplate::bundle_sss);
      slot[1] &= ~mask_lo;
      slot[1] |= value_lo;
      break;
    case postrisc::SLOT_C:
      assert(bundle->GetTemplate() == postrisc::EBundleTemplate::bundle_sss ||
             bundle->GetTemplate() == postrisc::EBundleTemplate::bundle_lls);
      slot[2] &= ~mask_lo;
      slot[2] |= value_lo;
      break;
    case postrisc::SLOT_A_EXT:
      LLVM_DEBUG(dbgs() << "bundle(lls) " << *bundle << "\n");
      assert(bundle->GetTemplate() == postrisc::EBundleTemplate::bundle_lls);
      slot[0] &= ~mask_lo;
      slot[0] |= value_lo;
      slot[1] &= ~mask_hi;
      slot[1] |= value_hi;
      break;
    case postrisc::SLOT_B_EXT:
      LLVM_DEBUG(dbgs() << "bundle(sll) " << *bundle << "\n");
      assert(bundle->GetTemplate() == postrisc::EBundleTemplate::bundle_sll);
      slot[1] &= ~mask_lo;
      slot[1] |= value_lo;
      slot[2] &= ~mask_hi;
      slot[2] |= value_hi;
      break;
  }

  *bundle = postrisc::CBundle::create(slot, Template);
}

static void
FixupBranch(postrisc::CBundle *bundle, int64_t Value,
  postrisc::slot_type slottype,
  unsigned field_offset, unsigned field_size,
  unsigned field_ext_offset, unsigned field_ext_size)
{
  if (Value == 0) {
    LLVM_DEBUG(dbgs() << "FixupBranch[" << (int)slottype << "] "
         << *bundle
         << field_offset << ":" << field_size
         << " Value=" << Value
         << " Unfixed zero\n");
  }

  assert(Value % sizeof(postrisc::CBundle) == 0);
  Value /= sizeof(postrisc::CBundle);
  LLVM_DEBUG(dbgs() << "FixupBranch[" << (int)slottype << "] "
     << *bundle
     << field_offset << ":" << field_size
     << " Value=" << Value
     << "\n");

  FixupOffset(bundle, Value, slottype,
    field_offset, field_size,
    field_ext_offset, field_ext_size);
}

static void
FixupData(MutableArrayRef<char> Data, uint32_t Offset, uint64_t Value,
  unsigned NumBytes, bool littleEndian)
{
  LLVM_DEBUG(dbgs() << "FixupData: Offset=" << Offset << " NumBytes=" << NumBytes << "\n");
  for (unsigned i = 0; i != NumBytes; ++i) {
    unsigned Idx = littleEndian ? i : (NumBytes - 1) - i;
    Data[Offset + Idx] |= uint8_t((Value >> (i * 8)) & 0xff);
  }
}

void ELFPostriscAsmBackend::applyFixup(
  const MCFragment &fragment, const MCFixup &Fixup,
  const MCValue &Target, MutableArrayRef<char> Data,
  uint64_t Value, bool IsResolved)
{
  if (!IsResolved)
    return;

  MCFixupKind const Kind = Fixup.getKind();
  uint32_t const Offset = Fixup.getOffset();

  LLVM_DEBUG(dbgs()
         << "applyFixup: Kind=" << Fixup.getTargetKind()
         << " " << getFixupKindInfo(Kind).Name
         << " Offset=" << Offset
         << " Value=" << (int64_t)Value << "\n");

  if (mc::isRelocation(Kind))
    return;

  // Asm.dump();

  postrisc::CBundle *bundle = (postrisc::CBundle *)(&Data[Offset]);
  postrisc::slot_type slottype;
  switch (Fixup.getTargetKind()) {
  default:
    llvm_unreachable("Unknown fixup kind!");
  case FK_Data_1: FixupData(Data, Offset, Value, 1, Endian == llvm::endianness::little);  break;
  case FK_Data_2: FixupData(Data, Offset, Value, 2, Endian == llvm::endianness::little);  break;
  case FK_Data_4: FixupData(Data, Offset, Value, 4, Endian == llvm::endianness::little);  break;
  case FK_Data_8: FixupData(Data, Offset, Value, 8, Endian == llvm::endianness::little);  break;

  FIXUP_ALL_FORMS_CASES(JUMP)
    slottype = (postrisc::slot_type)(Kind - Postrisc::FIXUP_POSTRISC_A_JUMP);
    FixupBranch(bundle, Value, slottype,
      0, llvm::postrisc::InstructionFieldSize::CallDisp,
      0, llvm::postrisc::InstructionFieldExtSize::CallDisp);
    break;

  FIXUP_ALL_FORMS_CASES(BRANCH)
    slottype = (postrisc::slot_type)(Kind - Postrisc::FIXUP_POSTRISC_A_BRANCH);
    FixupBranch(bundle, Value, slottype,
      0, llvm::postrisc::InstructionFieldSize::BranchDisp,
      0, llvm::postrisc::InstructionFieldExtSize::BranchDisp);
    break;

  FIXUP_ALL_FORMS_CASES(PCREL_FWD)
    slottype = (postrisc::slot_type)(Kind - Postrisc::FIXUP_POSTRISC_A_PCREL_FWD);
    FixupOffset(bundle, Value, slottype,
      0, llvm::postrisc::InstructionFieldSize::ForwardDisp,
      0, llvm::postrisc::InstructionFieldExtSize::ForwardDisp);
    break;

  FIXUP_ALL_FORMS_CASES(TLS_GD_GOT_OFFSET)
  FIXUP_ALL_FORMS_CASES(TLS_LD_GOT_OFFSET)
  FIXUP_ALL_FORMS_CASES(TLS_LD_OFFSET)
  FIXUP_ALL_FORMS_CASES(TLS_IE_OFFSET)
  FIXUP_ALL_FORMS_CASES(TLS_LE_OFFSET)
    assert(Value == 0 && "Postrisc TLS relocs expect zero Value");
    break;

  FIXUP_ALL_FORMS_CASES(TLS_GD_CALL)
  FIXUP_ALL_FORMS_CASES(TLS_LD_CALL)
    llvm_unreachable("Unsupported fixup kind!");
    break;
  }
}

} // end anonymous namespace

MCAsmBackend *llvm::createPostriscAsmBackend(const Target &T,
                                          const MCSubtargetInfo &STI,
                                          const MCRegisterInfo &MRI,
                                          const MCTargetOptions &Options) {
  return new ELFPostriscAsmBackend(T, STI.getTargetTriple().getOS());
}
