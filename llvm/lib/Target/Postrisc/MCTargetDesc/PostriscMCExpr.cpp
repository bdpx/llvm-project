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

#include "MCTargetDesc/PostriscMCAsmInfo.h"
#include "llvm/BinaryFormat/ELF.h"
#include "llvm/MC/MCObjectStreamer.h"

using namespace llvm;

#define DEBUG_TYPE "postriscmcexpr"

StringRef Postrisc::getSpecifierName(uint16_t S) {
  // clang-format off
  switch (S) {
  case Postrisc::S_NONE: return {};
  case Postrisc::S_R_DISP32: return "r_disp32";
  case Postrisc::S_GOTOFF: return "gotoff";
  case Postrisc::S_JUMP: return "jpc";
  case Postrisc::S_JUMP_EXT: return "jpc_ext";
  case Postrisc::S_BRANCH: return "bpc";
  case Postrisc::S_BRANCH_EXT: return "bpc_ext";
  case Postrisc::S_PCREL_FWD: return "pcfwd";
  case Postrisc::S_PCREL_FWD_EXT: return "pcfwd_ext";
  case Postrisc::S_LD_IMM: return "ld_imm";
  case Postrisc::S_LD_IMM_EXT: return "ld_imm_ext";
  case Postrisc::S_OFFSET: return "offset";
  case Postrisc::S_OFFSET_EXT: return "offset_ext";
  case Postrisc::S_TLS_GD_GOT_OFFSET: return "tgd";
  case Postrisc::S_TLS_GD_GOT_OFFSET_EXT: return "tgd_ext";
  case Postrisc::S_TLS_GD_CALL: return "tgd_call";
  case Postrisc::S_TLS_GD_CALL_EXT: return "tgd_call_ext";
  case Postrisc::S_TLS_LD_GOT_OFFSET: return "tld";
  case Postrisc::S_TLS_LD_GOT_OFFSET_EXT: return "tld_ext";
  case Postrisc::S_TLS_LD_CALL: return "tld_call";
  case Postrisc::S_TLS_LD_CALL_EXT: return "tld_call_ext";
  case Postrisc::S_TLS_LD_OFFSET: return "dtpoff";
  case Postrisc::S_TLS_LD_OFFSET_EXT: return "dtpoff_ext";
  case Postrisc::S_TLS_IE_OFFSET: return "gottpoff";
  case Postrisc::S_TLS_IE_OFFSET_EXT: return "gottpoff_ext";
  case Postrisc::S_TLS_LE_OFFSET: return "tpoff";
  case Postrisc::S_TLS_LE_OFFSET_EXT: return "tpoff_ext";
  }
  // clang-format on
  llvm_unreachable("Unhandled PostriscMCExpr::Specifier");
}

Postrisc::Specifier Postrisc::parseSpecifier(StringRef name) {
  return StringSwitch<Postrisc::Specifier>(name)
      .Case("r_disp32", Postrisc::S_R_DISP32)
      .Case("gotoff", Postrisc::S_GOTOFF)
      .Case("jpc", Postrisc::S_JUMP)
      .Case("jpc_ext", Postrisc::S_JUMP_EXT)
      .Case("bpc", Postrisc::S_BRANCH)
      .Case("bpc_ext", Postrisc::S_BRANCH_EXT)
      .Case("pcfwd", Postrisc::S_PCREL_FWD)
      .Case("pcfwd_ext", Postrisc::S_PCREL_FWD_EXT)
      .Case("ld_imm", Postrisc::S_LD_IMM)
      .Case("ld_imm_ext", Postrisc::S_LD_IMM_EXT)
      .Case("offset", Postrisc::S_OFFSET)
      .Case("offset_ext", Postrisc::S_OFFSET_EXT)
      .Case("tgd", Postrisc::S_TLS_GD_GOT_OFFSET)
      .Case("tgd_ext", Postrisc::S_TLS_GD_GOT_OFFSET_EXT)
      .Case("tgd_call", Postrisc::S_TLS_GD_CALL)
      .Case("tgd_call_ext", Postrisc::S_TLS_GD_CALL_EXT)
      .Case("tld", Postrisc::S_TLS_LD_GOT_OFFSET)
      .Case("tld_ext", Postrisc::S_TLS_LD_GOT_OFFSET_EXT)
      .Case("tld_call", Postrisc::S_TLS_LD_CALL)
      .Case("tld_call_ext", Postrisc::S_TLS_LD_CALL_EXT)
      .Case("dtpoff", Postrisc::S_TLS_LD_OFFSET)
      .Case("dtpoff_ext", Postrisc::S_TLS_LD_OFFSET_EXT)
      .Case("gottpoff", Postrisc::S_TLS_IE_OFFSET)
      .Case("gottpoff_ext", Postrisc::S_TLS_IE_OFFSET_EXT)
      .Case("tpoff", Postrisc::S_TLS_LE_OFFSET)
      .Case("tpoff_ext", Postrisc::S_TLS_LE_OFFSET_EXT)
      .Default(Postrisc::S_NONE);
}
