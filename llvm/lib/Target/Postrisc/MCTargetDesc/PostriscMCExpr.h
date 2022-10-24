//====- PostriscMCExpr.h - Postrisc specific MC expression classes --*- C++ -*-=====//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file describes Postrisc-specific MCExprs, used for modifiers like
// "%hi" or "%lo" etc.,
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_POSTRISC_MCTARGETDESC_POSTRISCMCEXPR_H
#define LLVM_LIB_TARGET_POSTRISC_MCTARGETDESC_POSTRISCMCEXPR_H

#include "PostriscFixupKinds.h"
#include "llvm/MC/MCExpr.h"

namespace llvm {

#define POSTRISC_USUAL_KIND_TABLE(X)                                 \
    X(R_DISP32,              r_disp32      ) /*                   */ \
    X(GOTOFF,                gotoff        ) /*                   */ \

// variant_kind,
// asm_name,
// initial fixup type
#define POSTRISC_VARIANT_KIND_TABLE(X)                               \
    X(JUMP,                  jpc           ) /*                   */ \
    X(JUMP_EXT,              jpc_ext       ) /*                   */ \
    X(BRANCH,                bpc           ) /*                   */ \
    X(BRANCH_EXT,            bpc_ext       ) /*                   */ \
    X(PCREL_FWD,             pcfwd         ) /*                   */ \
    X(PCREL_FWD_EXT,         pcfwd_ext     ) /*                   */ \
    X(LDI,                   ldi           ) /*                   */ \
    X(LDI_EXT,               ldi_ext       ) /*                   */ \
    X(OFFSET,                offset        ) /*                   */ \
    X(OFFSET_EXT,            offset_ext    ) /*                   */ \
    X(TLS_GD_GOT_OFFSET,     tgd           ) /*                   */ \
    X(TLS_GD_GOT_OFFSET_EXT, tgd_ext       ) /*                   */ \
    X(TLS_GD_CALL,           tgd_call      ) /*                   */ \
    X(TLS_GD_CALL_EXT,       tgd_call_ext  ) /*                   */ \
    X(TLS_LD_GOT_OFFSET,     tld           ) /*                   */ \
    X(TLS_LD_GOT_OFFSET_EXT, tld_ext       ) /*                   */ \
    X(TLS_LD_CALL,           tld_call      ) /*                   */ \
    X(TLS_LD_CALL_EXT,       tld_call_ext  ) /*                   */ \
    X(TLS_LD_OFFSET,         dtpoff        ) /*                   */ \
    X(TLS_LD_OFFSET_EXT,     dtpoff_ext    ) /*                   */ \
    X(TLS_IE_OFFSET,         gottpoff      ) /*                   */ \
    X(TLS_IE_OFFSET_EXT,     gottpoff_ext  ) /*                   */ \
    X(TLS_LE_OFFSET,         tpoff         ) /*                   */ \
    X(TLS_LE_OFFSET_EXT,     tpoff_ext     ) /*                   */ \


class StringRef;
class PostriscMCExpr : public MCTargetExpr {
public:
  enum Specifier {
    VK_NONE,

#define POSTRISC_VARIANT_KIND_TABLE_ENUM(NAME, FUNCNAME) VK_##NAME,

  POSTRISC_USUAL_KIND_TABLE(POSTRISC_VARIANT_KIND_TABLE_ENUM)
  POSTRISC_VARIANT_KIND_TABLE(POSTRISC_VARIANT_KIND_TABLE_ENUM)

#undef POSTRISC_VARIANT_KIND_TABLE_ENUM
  };

private:
  const Specifier specifier;
  const MCExpr *Expr;

  explicit PostriscMCExpr(Specifier S, const MCExpr *Expr)
      : specifier(S), Expr(Expr) {}

public:
  /// @name Construction
  /// @{

  static const PostriscMCExpr *create(Specifier S, const MCExpr *Expr,
                                 MCContext &Ctx);
  /// @}
  /// @name Accessors
  /// @{

  Specifier getSpecifier() const { return specifier; }
  const MCExpr *getSubExpr() const { return Expr; }
  Postrisc::Fixups getFixupKind() const { return getFixupKind(specifier); }

  /// @}
  void printImpl(raw_ostream &OS, const MCAsmInfo *MAI) const override;
  bool evaluateAsRelocatableImpl(MCValue &Res,
                                 const MCAssembler *Asm) const override;
  void visitUsedExpr(MCStreamer &Streamer) const override;
  MCFragment *findAssociatedFragment() const override {
    return getSubExpr()->findAssociatedFragment();
  }

  static bool classof(const MCExpr *E) {
    return E->getKind() == MCExpr::Target;
  }

  static Specifier parseSpecifier(StringRef name);
  static bool printSpecifier(raw_ostream &OS, Specifier Kind);
  static Postrisc::Fixups getFixupKind(Specifier Kind);
};

} // end namespace llvm.

#endif
