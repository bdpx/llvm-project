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

// clang-format off
namespace llvm {
  namespace Postrisc {
  // clang-format off
    enum Fixups {
      fixup_postrisc_dummy = FirstTargetFixupKind,

      // Marker
      LastTargetFixupKind,
      NumTargetFixupKinds = LastTargetFixupKind - FirstTargetFixupKind
    };
  // clang-format on
  }
}
// clang-format on
#endif
