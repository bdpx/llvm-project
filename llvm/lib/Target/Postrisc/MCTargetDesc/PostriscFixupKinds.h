//===-- PostriscFixupKinds.h - Postrisc Specific Fixup Entries --------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_POSTRISC_MCTARGETDESC_POSTRISCFIXUPKINDS_H
#define LLVM_LIB_TARGET_POSTRISC_MCTARGETDESC_POSTRISCFIXUPKINDS_H

#include "llvm/MC/MCFixup.h"

#define DEFINE_FIXUP_TABLE(X)     \
  X(8,                          0,  0,  0 ) \
  X(16,                         0,  0,  0 ) \
  X(32,                         0,  0,  0 ) \
  X(64,                         0,  0,  0 ) \
  X(COPY,                       0,  0,  0 ) \
  X(JMP_SLOT,                   0,  0,  0 ) \
  X(RELATIVE,                   0,  0,  0 ) \
  X(DISP8,                      0,  0,  0 ) \
  X(DISP16,                     0,  0,  0 ) \
  X(DISP32,                     0,  0,  0 ) \
  X(DISP64,                     0,  0,  0 ) \
  X(GLOB_DAT,                   0,  0,  0 ) \
  X(PLT64,                      0,  0,  0 ) \
  X(R_DISP32,                   0,  0,  0 ) \
  X(GOTOFF,                     0,  0,  0 ) \
  X(A_JUMP,                     0,  0,  MCFixupKindInfo::FKF_IsPCRel ) \
  X(B_JUMP,                     0,  0,  MCFixupKindInfo::FKF_IsPCRel ) \
  X(C_JUMP,                     0,  0,  MCFixupKindInfo::FKF_IsPCRel ) \
  X(A_JUMP_EXT,                 0,  0,  MCFixupKindInfo::FKF_IsPCRel ) \
  X(B_JUMP_EXT,                 0,  0,  MCFixupKindInfo::FKF_IsPCRel ) \
  X(A_BRANCH,                   0,  0,  MCFixupKindInfo::FKF_IsPCRel ) \
  X(B_BRANCH,                   0,  0,  MCFixupKindInfo::FKF_IsPCRel ) \
  X(C_BRANCH,                   0,  0,  MCFixupKindInfo::FKF_IsPCRel ) \
  X(A_BRANCH_EXT,               0,  0,  MCFixupKindInfo::FKF_IsPCRel ) \
  X(B_BRANCH_EXT,               0,  0,  MCFixupKindInfo::FKF_IsPCRel ) \
  X(A_PCREL_FWD,                0,  0,  MCFixupKindInfo::FKF_IsPCRel ) \
  X(B_PCREL_FWD,                0,  0,  MCFixupKindInfo::FKF_IsPCRel ) \
  X(C_PCREL_FWD,                0,  0,  MCFixupKindInfo::FKF_IsPCRel ) \
  X(A_PCREL_FWD_EXT,            0,  0,  MCFixupKindInfo::FKF_IsPCRel ) \
  X(B_PCREL_FWD_EXT,            0,  0,  MCFixupKindInfo::FKF_IsPCRel ) \
  X(A_PCREL_FWD_GOT,            0,  0,  MCFixupKindInfo::FKF_IsPCRel ) \
  X(B_PCREL_FWD_GOT,            0,  0,  MCFixupKindInfo::FKF_IsPCRel ) \
  X(C_PCREL_FWD_GOT,            0,  0,  MCFixupKindInfo::FKF_IsPCRel ) \
  X(A_PCREL_FWD_GOT_EXT,        0,  0,  MCFixupKindInfo::FKF_IsPCRel ) \
  X(B_PCREL_FWD_GOT_EXT,        0,  0,  MCFixupKindInfo::FKF_IsPCRel ) \
  X(A_PCREL_FWD_PLT,            0,  0,  MCFixupKindInfo::FKF_IsPCRel ) \
  X(B_PCREL_FWD_PLT,            0,  0,  MCFixupKindInfo::FKF_IsPCRel ) \
  X(C_PCREL_FWD_PLT,            0,  0,  MCFixupKindInfo::FKF_IsPCRel ) \
  X(A_PCREL_FWD_PLT_EXT,        0,  0,  MCFixupKindInfo::FKF_IsPCRel ) \
  X(B_PCREL_FWD_PLT_EXT,        0,  0,  MCFixupKindInfo::FKF_IsPCRel ) \
  X(A_LDI,                      0,  0,  0 ) \
  X(B_LDI,                      0,  0,  0 ) \
  X(C_LDI,                      0,  0,  0 ) \
  X(A_LDI_EXT,                  0,  0,  0 ) \
  X(B_LDI_EXT,                  0,  0,  0 ) \
  X(A_OFFSET,                   0,  0,  0 ) \
  X(B_OFFSET,                   0,  0,  0 ) \
  X(C_OFFSET,                   0,  0,  0 ) \
  X(A_OFFSET_EXT,               0,  0,  0 ) \
  X(B_OFFSET_EXT,               0,  0,  0 ) \
  X(A_TLS_GD_GOT_OFFSET,        0,  0,  MCFixupKindInfo::FKF_IsPCRel ) \
  X(B_TLS_GD_GOT_OFFSET,        0,  0,  MCFixupKindInfo::FKF_IsPCRel ) \
  X(C_TLS_GD_GOT_OFFSET,        0,  0,  MCFixupKindInfo::FKF_IsPCRel ) \
  X(A_TLS_GD_GOT_OFFSET_EXT,    0,  0,  MCFixupKindInfo::FKF_IsPCRel ) \
  X(B_TLS_GD_GOT_OFFSET_EXT,    0,  0,  MCFixupKindInfo::FKF_IsPCRel ) \
  X(A_TLS_GD_CALL,              0,  0,  0 ) \
  X(B_TLS_GD_CALL,              0,  0,  0 ) \
  X(C_TLS_GD_CALL,              0,  0,  0 ) \
  X(A_TLS_GD_CALL_EXT,          0,  0,  0 ) \
  X(B_TLS_GD_CALL_EXT,          0,  0,  0 ) \
  X(A_TLS_LD_GOT_OFFSET,        0,  0,  MCFixupKindInfo::FKF_IsPCRel ) \
  X(B_TLS_LD_GOT_OFFSET,        0,  0,  MCFixupKindInfo::FKF_IsPCRel ) \
  X(C_TLS_LD_GOT_OFFSET,        0,  0,  MCFixupKindInfo::FKF_IsPCRel ) \
  X(A_TLS_LD_GOT_OFFSET_EXT,    0,  0,  MCFixupKindInfo::FKF_IsPCRel ) \
  X(B_TLS_LD_GOT_OFFSET_EXT,    0,  0,  MCFixupKindInfo::FKF_IsPCRel ) \
  X(A_TLS_LD_CALL,              0,  0,  0 ) \
  X(B_TLS_LD_CALL,              0,  0,  0 ) \
  X(C_TLS_LD_CALL,              0,  0,  0 ) \
  X(A_TLS_LD_CALL_EXT,          0,  0,  0 ) \
  X(B_TLS_LD_CALL_EXT,          0,  0,  0 ) \
  X(A_TLS_LD_OFFSET,            0,  0,  0 ) \
  X(B_TLS_LD_OFFSET,            0,  0,  0 ) \
  X(C_TLS_LD_OFFSET,            0,  0,  0 ) \
  X(A_TLS_LD_OFFSET_EXT,        0,  0,  0 ) \
  X(B_TLS_LD_OFFSET_EXT,        0,  0,  0 ) \
  X(A_TLS_IE_OFFSET,            0,  0,  0 ) \
  X(B_TLS_IE_OFFSET,            0,  0,  0 ) \
  X(C_TLS_IE_OFFSET,            0,  0,  0 ) \
  X(A_TLS_IE_OFFSET_EXT,        0,  0,  0 ) \
  X(B_TLS_IE_OFFSET_EXT,        0,  0,  0 ) \
  X(A_TLS_LE_OFFSET,            0,  0,  0 ) \
  X(B_TLS_LE_OFFSET,            0,  0,  0 ) \
  X(C_TLS_LE_OFFSET,            0,  0,  0 ) \
  X(A_TLS_LE_OFFSET_EXT,        0,  0,  0 ) \
  X(B_TLS_LE_OFFSET_EXT,        0,  0,  0 ) \


namespace llvm {
  namespace Postrisc {
    enum Fixups {
      fixup_first = FirstTargetFixupKind - 1,  // so next will be FirstTargetFixupKind

#define FIXUP_ENUM(NAME, TARGET_OFFSET, TARGET_SIZE, FLAGS) FIXUP_POSTRISC_##NAME,
 DEFINE_FIXUP_TABLE(FIXUP_ENUM)
#undef FIXUP_ENUM

      // Marker
      LastTargetFixupKind,
      NumTargetFixupKinds = LastTargetFixupKind - FirstTargetFixupKind
    };
  }
}

#endif
