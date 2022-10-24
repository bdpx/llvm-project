//===- PostriscMCAsmInfo.h - Postrisc asm properties -----------------*- C++ -*--===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains the declaration of the PostriscMCAsmInfo class.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_POSTRISC_MCTARGETDESC_POSTRISCMCASMINFO_H
#define LLVM_LIB_TARGET_POSTRISC_MCTARGETDESC_POSTRISCMCASMINFO_H

#include "llvm/MC/MCAsmInfoELF.h"

namespace llvm {

class Triple;

class PostriscELFMCAsmInfo : public MCAsmInfoELF {
  void anchor() override;

public:
  explicit PostriscELFMCAsmInfo(const Triple &TheTriple);

  const MCExpr*
  getExprForPersonalitySymbol(const MCSymbol *Sym, unsigned Encoding,
                              MCStreamer &Streamer) const override;
  const MCExpr* getExprForFDESymbol(const MCSymbol *Sym,
                                    unsigned Encoding,
                                    MCStreamer &Streamer) const override;

  void printSpecifierExpr(raw_ostream &OS,
                          const MCSpecifierExpr &Expr) const override;
};

namespace Postrisc {
enum Specifier : uint16_t {
    S_NONE,
    S_R_DISP32,              //r_disp32
    S_GOTOFF,                //gotoff
    S_JUMP,                  //jpc
    S_JUMP_EXT,              //jpc_ext
    S_BRANCH,                //bpc
    S_BRANCH_EXT,            //bpc_ext
    S_PCREL_FWD,             //pcfwd
    S_PCREL_FWD_EXT,         //pcfwd_ext
    S_LD_IMM,                //ld_imm
    S_LD_IMM_EXT,            //ld_imm_ext
    S_OFFSET,                //offset
    S_OFFSET_EXT,            //offset_ext
    S_TLS_GD_GOT_OFFSET,     //tgd
    S_TLS_GD_GOT_OFFSET_EXT, //tgd_ext
    S_TLS_GD_CALL,           //tgd_call
    S_TLS_GD_CALL_EXT,       //tgd_call_ext
    S_TLS_LD_GOT_OFFSET,     //tld
    S_TLS_LD_GOT_OFFSET_EXT, //tld_ext
    S_TLS_LD_CALL,           //tld_call
    S_TLS_LD_CALL_EXT,       //tld_call_ext
    S_TLS_LD_OFFSET,         //dtpoff
    S_TLS_LD_OFFSET_EXT,     //dtpoff_ext
    S_TLS_IE_OFFSET,         //gottpoff
    S_TLS_IE_OFFSET_EXT,     //gottpoff_ext
    S_TLS_LE_OFFSET,         //tpoff
    S_TLS_LE_OFFSET_EXT,     //tpoff_ext
};

Postrisc::Specifier parseSpecifier(StringRef name);
StringRef getSpecifierName(uint16_t S);
} // namespace Postrisc

} // end namespace llvm

#endif // LLVM_LIB_TARGET_POSTRISC_MCTARGETDESC_POSTRISCMCASMINFO_H
