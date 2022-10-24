//===-- PostriscELFObjectWriter.cpp - Postrisc ELF Writer -----------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/PostriscFixupKinds.h"
#include "MCTargetDesc/PostriscMCExpr.h"
#include "MCTargetDesc/PostriscMCTargetDesc.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/MC/MCELFObjectWriter.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCObjectWriter.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCValue.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/Debug.h"

#define DEBUG_TYPE "postrisc-elfobjwriter"

using namespace llvm;

namespace {
  class PostriscELFObjectWriter : public MCELFObjectTargetWriter {
  public:
    PostriscELFObjectWriter(bool Is64Bit, uint8_t OSABI)
      : MCELFObjectTargetWriter(Is64Bit, OSABI,
                                ELF::EM_POSTRISC,
                                /*HasRelocationAddend*/ true) {}

    ~PostriscELFObjectWriter() override = default;

  protected:
    unsigned getRelocType(MCContext &Ctx, const MCValue &Target,
                          const MCFixup &Fixup, bool IsPCRel) const override;

    bool needsRelocateWithSymbol(const MCValue &Val, const MCSymbol &Sym,
                                 unsigned Type) const override;
  };
}

#define FIXUP_TO_RELOC_ALL_CASES(NAME)                                                   \
  case Postrisc::FIXUP_POSTRISC_A_##NAME:        return ELF::R_POSTRISC_A_##NAME;        \
  case Postrisc::FIXUP_POSTRISC_B_##NAME:        return ELF::R_POSTRISC_B_##NAME;        \
  case Postrisc::FIXUP_POSTRISC_C_##NAME:        return ELF::R_POSTRISC_C_##NAME;        \
  case Postrisc::FIXUP_POSTRISC_A_##NAME##_EXT:  return ELF::R_POSTRISC_A_##NAME##_EXT;  \
  case Postrisc::FIXUP_POSTRISC_B_##NAME##_EXT:  return ELF::R_POSTRISC_B_##NAME##_EXT;  \

unsigned PostriscELFObjectWriter::getRelocType(MCContext &Ctx,
                                            const MCValue &Target,
                                            const MCFixup &Fixup,
                                            bool IsPCRel) const {
  LLVM_DEBUG(dbgs() << "ELFOW::getRelocType:"
         // << " Target=" << Target
         << " Fixup=" << *Fixup.getValue() << " " << Fixup.getTargetKind()
         << " IsPCRel=" << IsPCRel << "\n";

  if (Target.getSymA()) {
    const MCSymbol& symbol = Target.getSymA()->getSymbol();
    dbgs() << "getSymA=" << symbol.getName()
           << " hasSubsectionsViaSymbols=" << Target.getSymA()->hasSubsectionsViaSymbols()
           << " isExternal=" << symbol.isExternal()
           << " isCommon=" << symbol.isCommon()
           << " isPrivateExtern=" << symbol.isPrivateExtern()
           << " isTemporary=" << symbol.isTemporary()
           << " isUsed=" << symbol.isUsed()
           << " isRedefinable=" << symbol.isRedefinable()
           << " isDefined=" << symbol.isDefined()
           << " isInSection=" << symbol.isInSection()
           << " isUndefined=" << symbol.isUndefined()
           << " isAbsolute=" << symbol.isAbsolute()
           << " isVariable=" << symbol.isVariable()
           << " isRegistered=" << symbol.isRegistered()
           << "\n";
    if (symbol.isUndefined() && !symbol.isRegistered()) {
      dbgs() << "XXXXXXXXXXXX\n";
    }
  });

  MCFixupKind Kind = Fixup.getKind();
  if (Kind >= FirstLiteralRelocationKind)
    return Kind - FirstLiteralRelocationKind;

  if (const PostriscMCExpr *SExpr = dyn_cast<PostriscMCExpr>(Fixup.getValue())) {
    if (SExpr->getKind() == PostriscMCExpr::VK_POSTRISC_R_DISP32)
      return ELF::R_POSTRISC_DISP32;
  }

  switch(Fixup.getTargetKind()) {
  default:
    LLVM_DEBUG(dbgs() << "Fixup.getTargetKind()=" << Kind << "\n");
    llvm_unreachable("Unimplemented fixup -> relocation");
  case FK_Data_1:  return IsPCRel ? ELF::R_POSTRISC_DISP8  : ELF::R_POSTRISC_8;
  case FK_Data_2:  return IsPCRel ? ELF::R_POSTRISC_DISP16 : ELF::R_POSTRISC_16;
  case FK_Data_4:  return IsPCRel ? ELF::R_POSTRISC_DISP32 : ELF::R_POSTRISC_32;
  case FK_Data_8:  return IsPCRel ? ELF::R_POSTRISC_DISP64 : ELF::R_POSTRISC_64;
  // branches
  FIXUP_TO_RELOC_ALL_CASES(JUMP)
  FIXUP_TO_RELOC_ALL_CASES(BRANCH)
  // PCREL
  FIXUP_TO_RELOC_ALL_CASES(PCREL_FWD)
  FIXUP_TO_RELOC_ALL_CASES(PCREL_FWD_GOT)
  FIXUP_TO_RELOC_ALL_CASES(PCREL_FWD_PLT)
  FIXUP_TO_RELOC_ALL_CASES(LDI)
  FIXUP_TO_RELOC_ALL_CASES(OFFSET)
  // TLS
  FIXUP_TO_RELOC_ALL_CASES(TLS_GD_GOT_OFFSET)
  FIXUP_TO_RELOC_ALL_CASES(TLS_GD_CALL)
  FIXUP_TO_RELOC_ALL_CASES(TLS_LD_GOT_OFFSET)
  FIXUP_TO_RELOC_ALL_CASES(TLS_LD_CALL)
  FIXUP_TO_RELOC_ALL_CASES(TLS_LD_OFFSET)
  FIXUP_TO_RELOC_ALL_CASES(TLS_IE_OFFSET)
  FIXUP_TO_RELOC_ALL_CASES(TLS_LE_OFFSET)
  }

  return ELF::R_POSTRISC_NONE;
}

#define RELOC_ALL_CASES(NAME)            \
  case ELF::R_POSTRISC_A_##NAME:         \
  case ELF::R_POSTRISC_B_##NAME:         \
  case ELF::R_POSTRISC_C_##NAME:         \
  case ELF::R_POSTRISC_A_##NAME##_EXT:   \
  case ELF::R_POSTRISC_B_##NAME##_EXT:   \

bool PostriscELFObjectWriter::needsRelocateWithSymbol(const MCValue &,
                                                   const MCSymbol &Sym,
                                                   unsigned Type) const {
  LLVM_DEBUG(dbgs() << "ELFOW::needsRelocateWithSymbol:"
         // << " Target=" << Target
         << " Fixup=" << Sym.getName() << " Type=" << Type
         << "\n");

  switch (Type) {
  default:
    LLVM_DEBUG(dbgs() << "ELFOW::needsRelocateWithSymbol: default false\n");
    return false;
  // All relocations that use a GOT need a symbol, not an offset, as
  // the offset of the symbol within the section is irrelevant to
  // where the GOT entry is. Don't need to list all the TLS entries,
  // as they're all marked as requiring a symbol anyways.
  RELOC_ALL_CASES(JUMP)
  RELOC_ALL_CASES(BRANCH)
  // PCREL
  RELOC_ALL_CASES(PCREL_FWD)
  RELOC_ALL_CASES(PCREL_FWD_GOT)
  RELOC_ALL_CASES(PCREL_FWD_PLT)
  RELOC_ALL_CASES(LDI)
  RELOC_ALL_CASES(OFFSET)
  // TLS
  RELOC_ALL_CASES(TLS_GD_GOT_OFFSET)
  RELOC_ALL_CASES(TLS_GD_CALL)
  RELOC_ALL_CASES(TLS_LD_GOT_OFFSET)
  RELOC_ALL_CASES(TLS_LD_CALL)
  RELOC_ALL_CASES(TLS_LD_OFFSET)
  RELOC_ALL_CASES(TLS_IE_OFFSET)
  RELOC_ALL_CASES(TLS_LE_OFFSET)
    LLVM_DEBUG(dbgs() << "ELFOW::needsRelocateWithSymbol: true\n");
    return true;
  }
}

std::unique_ptr<MCObjectTargetWriter>
llvm::createPostriscELFObjectWriter(bool Is64Bit, uint8_t OSABI) {
  return std::make_unique<PostriscELFObjectWriter>(Is64Bit, OSABI);
}
