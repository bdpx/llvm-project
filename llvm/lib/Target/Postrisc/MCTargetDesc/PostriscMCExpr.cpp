//===-- PostriscMCExpr.cpp - Postrisc specific MC expression classes --------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains the implementation of the assembly expression modifiers
// accepted by the Postrisc architecture (e.g. "%hi", "%lo", ...).
//
//===----------------------------------------------------------------------===//

#include "PostriscMCExpr.h"
#include "llvm/BinaryFormat/ELF.h"
#include "llvm/MC/MCAssembler.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCObjectStreamer.h"
#include "llvm/MC/MCSymbolELF.h"
#include "llvm/Support/Casting.h"

using namespace llvm;

#define DEBUG_TYPE "postriscmcexpr"

const PostriscMCExpr*
PostriscMCExpr::create(VariantKind Kind, const MCExpr *Expr,
                      MCContext &Ctx) {
    return new (Ctx) PostriscMCExpr(Kind, Expr);
}

void PostriscMCExpr::printImpl(raw_ostream &OS, const MCAsmInfo *MAI) const {

  bool closeParen = printVariantKind(OS, Kind);

  const MCExpr *Expr = getSubExpr();
  Expr->print(OS, MAI);

  if (closeParen)
    OS << ')';
}

bool PostriscMCExpr::printVariantKind(raw_ostream &OS, VariantKind Kind)
{
  switch (Kind) {
  case VK_POSTRISC_NONE:     return false;
#define POSTRISC_VARIANT_KIND_TABLE_PRINT(NAME, FUNCNAME) \
  case VK_POSTRISC_##NAME: OS << "%" #FUNCNAME "("; return true;

  POSTRISC_USUAL_KIND_TABLE(POSTRISC_VARIANT_KIND_TABLE_PRINT)
  POSTRISC_VARIANT_KIND_TABLE(POSTRISC_VARIANT_KIND_TABLE_PRINT)

#undef POSTRISC_VARIANT_KIND_TABLE_PRINT
  }
  llvm_unreachable("Unhandled PostriscMCExpr::VariantKind");
}

PostriscMCExpr::VariantKind PostriscMCExpr::parseVariantKind(StringRef name)
{
  return StringSwitch<PostriscMCExpr::VariantKind>(name)
#define POSTRISC_VARIANT_KIND_TABLE_NAMECASE(NAME, FUNCNAME) \
  .Case(#FUNCNAME, VK_POSTRISC_##NAME)

  POSTRISC_VARIANT_KIND_TABLE(POSTRISC_VARIANT_KIND_TABLE_NAMECASE)

#undef POSTRISC_VARIANT_KIND_TABLE_NAMECASE
    .Default(VK_POSTRISC_NONE);
}

Postrisc::Fixups
PostriscMCExpr::getFixupKind(PostriscMCExpr::VariantKind Kind)
{
  switch (Kind) {
  default: llvm_unreachable("Unhandled PostriscMCExpr::VariantKind");
#define POSTRISC_VARIANT_KIND_TABLE_FIXUP(NAME, FUNCNAME) \
  case VK_POSTRISC_##NAME: return Postrisc::FIXUP_POSTRISC_##NAME;

  POSTRISC_USUAL_KIND_TABLE(POSTRISC_VARIANT_KIND_TABLE_FIXUP)

#undef POSTRISC_VARIANT_KIND_TABLE_FIXUP

#define POSTRISC_VARIANT_KIND_TABLE_FIXUP(NAME, FUNCNAME) \
  case VK_POSTRISC_##NAME: return Postrisc::FIXUP_POSTRISC_A_##NAME;

  POSTRISC_VARIANT_KIND_TABLE(POSTRISC_VARIANT_KIND_TABLE_FIXUP)

#undef POSTRISC_VARIANT_KIND_TABLE_FIXUP
  }
}

bool
PostriscMCExpr::evaluateAsRelocatableImpl(MCValue &Res,
                                       const MCAsmLayout *Layout,
                                       const MCFixup *Fixup) const {
  return getSubExpr()->evaluateAsRelocatable(Res, Layout, Fixup);
}

static void fixELFSymbolsInTLSFixupsImpl(const MCExpr *Expr, MCAssembler &Asm) {
  switch (Expr->getKind()) {
  case MCExpr::Target:
    llvm_unreachable("Can't handle nested target expr!");
    break;

  case MCExpr::Constant:
    break;

  case MCExpr::Binary: {
    const MCBinaryExpr *BE = cast<MCBinaryExpr>(Expr);
    fixELFSymbolsInTLSFixupsImpl(BE->getLHS(), Asm);
    fixELFSymbolsInTLSFixupsImpl(BE->getRHS(), Asm);
    break;
  }

  case MCExpr::SymbolRef: {
    const MCSymbolRefExpr &SymRef = *cast<MCSymbolRefExpr>(Expr);
    cast<MCSymbolELF>(SymRef.getSymbol()).setType(ELF::STT_TLS);
    break;
  }

  case MCExpr::Unary:
    fixELFSymbolsInTLSFixupsImpl(cast<MCUnaryExpr>(Expr)->getSubExpr(), Asm);
    break;
  }

}

void PostriscMCExpr::fixELFSymbolsInTLSFixups(MCAssembler &Asm) const {
  switch(getKind()) {
  default: return;
  case VK_POSTRISC_TLS_GD_CALL:
  case VK_POSTRISC_TLS_LD_CALL: {
    // The corresponding relocations reference __tls_get_addr, as they call it,
    // but this is only implicit; we must explicitly add it to our symbol table
    // to bind it for these uses.
    MCSymbol *Symbol = Asm.getContext().getOrCreateSymbol("__tls_get_addr");
    Asm.registerSymbol(*Symbol);
    auto ELFSymbol = cast<MCSymbolELF>(Symbol);
    if (!ELFSymbol->isBindingSet()) {
      ELFSymbol->setBinding(ELF::STB_GLOBAL);
      ELFSymbol->setExternal(true);
    }
    [[fallthrough]];
  }
  case VK_POSTRISC_TLS_GD_GOT_OFFSET:
  case VK_POSTRISC_TLS_LD_GOT_OFFSET:
  case VK_POSTRISC_TLS_LD_OFFSET:
  case VK_POSTRISC_TLS_IE_OFFSET:
  case VK_POSTRISC_TLS_LE_OFFSET:
    break;
  }
  fixELFSymbolsInTLSFixupsImpl(getSubExpr(), Asm);
}

void PostriscMCExpr::visitUsedExpr(MCStreamer &Streamer) const {
  Streamer.visitUsedExpr(*getSubExpr());
}
