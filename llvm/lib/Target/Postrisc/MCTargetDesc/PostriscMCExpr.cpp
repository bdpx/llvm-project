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
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCAssembler.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCObjectStreamer.h"
#include "llvm/MC/MCSymbolELF.h"
#include "llvm/MC/MCValue.h"
#include "llvm/Support/Casting.h"

using namespace llvm;

#define DEBUG_TYPE "postriscmcexpr"

const PostriscMCExpr *PostriscMCExpr::create(Specifier S, const MCExpr *Expr,
                                       MCContext &Ctx) {
  return new (Ctx) PostriscMCExpr(S, Expr);
}

void PostriscMCExpr::printImpl(raw_ostream &OS, const MCAsmInfo *MAI) const {

  bool closeParen = printSpecifier(OS, specifier);
  MAI->printExpr(OS, *Expr);
  if (closeParen)
    OS << ')';
}

bool PostriscMCExpr::printSpecifier(raw_ostream &OS, Specifier S) {
  switch (S) {
  case VK_NONE:     return false;
#define POSTRISC_VARIANT_KIND_TABLE_PRINT(NAME, FUNCNAME) \
  case VK_##NAME: OS << "%" #FUNCNAME "("; return true;

  POSTRISC_USUAL_KIND_TABLE(POSTRISC_VARIANT_KIND_TABLE_PRINT)
  POSTRISC_VARIANT_KIND_TABLE(POSTRISC_VARIANT_KIND_TABLE_PRINT)

#undef POSTRISC_VARIANT_KIND_TABLE_PRINT
  }
  llvm_unreachable("Unhandled PostriscMCExpr::Specifier");
}

PostriscMCExpr::Specifier PostriscMCExpr::parseSpecifier(StringRef name)
{
  return StringSwitch<PostriscMCExpr::Specifier>(name)
#define POSTRISC_VARIANT_KIND_TABLE_NAMECASE(NAME, FUNCNAME) \
  .Case(#FUNCNAME, VK_##NAME)

  POSTRISC_VARIANT_KIND_TABLE(POSTRISC_VARIANT_KIND_TABLE_NAMECASE)

#undef POSTRISC_VARIANT_KIND_TABLE_NAMECASE
    .Default(VK_NONE);
}

Postrisc::Fixups
PostriscMCExpr::getFixupKind(PostriscMCExpr::Specifier Kind)
{
  switch (Kind) {
  default: llvm_unreachable("Unhandled PostriscMCExpr::Specifier");
#define POSTRISC_VARIANT_KIND_TABLE_FIXUP(NAME, FUNCNAME) \
  case VK_##NAME: return Postrisc::FIXUP_POSTRISC_##NAME;

  POSTRISC_USUAL_KIND_TABLE(POSTRISC_VARIANT_KIND_TABLE_FIXUP)

#undef POSTRISC_VARIANT_KIND_TABLE_FIXUP

#define POSTRISC_VARIANT_KIND_TABLE_FIXUP(NAME, FUNCNAME) \
  case VK_##NAME: return Postrisc::FIXUP_POSTRISC_A_##NAME;

  POSTRISC_VARIANT_KIND_TABLE(POSTRISC_VARIANT_KIND_TABLE_FIXUP)

#undef POSTRISC_VARIANT_KIND_TABLE_FIXUP
  }
}

bool PostriscMCExpr::evaluateAsRelocatableImpl(MCValue &Res,
                                            const MCAssembler *Asm) const {
  if (!getSubExpr()->evaluateAsRelocatable(Res, Asm))
    return false;
  Res.setSpecifier(specifier);
  return true;
}

void PostriscMCExpr::visitUsedExpr(MCStreamer &Streamer) const {
  Streamer.visitUsedExpr(*getSubExpr());
}
