//===-------------- PostriscSpecialRegisters.h --*- C++ -*-----------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_SUPPORT_POSTRISC_SPECIAL_REGISTERS_H
#define LLVM_SUPPORT_POSTRISC_SPECIAL_REGISTERS_H

#include "llvm/ADT/StringRef.h"
#include "llvm/ADT/StringSwitch.h"

#define DEFINE_POSTRISC_SPECIAL_REGISTERS_TABLE(X) \
    X(bsp) \
    X(cause) \
    X(cmcv) \
    X(eca) \
    X(eip) \
    X(fpcr) \
    X(icc) \
    X(ifa) \
    X(iib) \
    X(iip) \
    X(iipa) \
    X(ip) \
    X(ipsr) \
    X(irr0) \
    X(irr1) \
    X(irr2) \
    X(irr3) \
    X(isr0) \
    X(isr1) \
    X(isr2) \
    X(isr3) \
    X(itc) \
    X(itcv) \
    X(itm) \
    X(iv) \
    X(iva) \
    X(kip) \
    X(krsp) \
    X(ksp) \
    X(lid) \
    X(peb) \
    X(pmv) \
    X(psr) \
    X(pta) \
    X(reip) \
    X(rsc) \
    X(rsp) \
    X(teb) \
    X(tpr) \
    X(tsv) \

namespace llvm {
namespace postrisc {
namespace SpecialRegister {

#define GET_spr_reg_DECL
#include "PostriscGenSearchableTables.inc"
#undef GET_spr_reg_DECL

using Type = spr_reg;

inline static const char *toString(Type RndMode) {
  switch (RndMode) {
#define X(NAME) case spr_reg_ ## NAME:   return #NAME;
DEFINE_POSTRISC_SPECIAL_REGISTERS_TABLE(X)
#undef X
  }
  return nullptr;
}

inline static std::optional<Type> toEnum(StringRef Str) {
  return StringSwitch<std::optional<Type>>(Str)
#define X(NAME) .Case(#NAME, spr_reg_ ## NAME)
DEFINE_POSTRISC_SPECIAL_REGISTERS_TABLE(X)
#undef X
   .Default(std::nullopt);
}

inline static bool isValid(unsigned number) {
  return toString(static_cast<Type>(number)) != nullptr;
}

}}}  // end namespace llvm::postrisc::SpecialRegister

#endif
