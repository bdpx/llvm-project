//===- PostriscMCInstrInfo.cpp - Utility functions on Postrisc MCInsts ----===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Utility functions for Postrisc specific MCInst queries
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_POSTRISC_MCTARGETDESC_POSTRISCMCINSTRINFO_H
#define LLVM_LIB_TARGET_POSTRISC_MCTARGETDESC_POSTRISCMCINSTRINFO_H

#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/ADT/iterator.h"
#include "llvm/ADT/iterator_range.h"
#include "llvm/MC/MCInst.h"
#include "llvm/Support/MathExtras.h"
#include <cassert>
#include <cstddef>
#include <cstdint>
#include <limits>

#include "MCTargetDesc/PostriscMCTargetDesc.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCInstrItineraries.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/Support/Casting.h"
#include "llvm/Support/ErrorHandling.h"

namespace llvm {

class MCContext;
class MCExpr;
class MCInstrDesc;
class MCInstrInfo;
class MCRegisterInfo;
class MCSubtargetInfo;

namespace Postrisc {

constexpr size_t bundleInstructionsOffset = 1;

class PacketIterator
    : public llvm::iterator_facade_base<
          PacketIterator, std::forward_iterator_tag, const MCInst> {
  MCInst::const_iterator BundleCurrent;
  MCInst::const_iterator BundleEnd;

public:
  PacketIterator(MCInstrInfo const &MCII, MCInst const &Inst)
    : BundleCurrent(Inst.begin() + bundleInstructionsOffset)
    , BundleEnd(Inst.end())
    {}

  PacketIterator(MCInstrInfo const &MCII, MCInst const &Inst, std::nullptr_t)
    : BundleCurrent(Inst.end())
    , BundleEnd(Inst.end())
    {}

  PacketIterator &operator++() {
    ++BundleCurrent;
    return *this;
  }

  MCInst const &operator*() const {
    return *BundleCurrent->getInst();
  }

  bool operator==(PacketIterator const &Other) const {
    return BundleCurrent == Other.BundleCurrent && BundleEnd == Other.BundleEnd;
  }
};

inline void addConstant(MCInst &MI, uint64_t Value, MCContext &Context) {
  MI.addOperand(MCOperand::createExpr(MCConstantExpr::create(Value, Context)));
}

void addConstExtender(MCContext &Context, MCInstrInfo const &MCII, MCInst &MCB,
                      MCInst const &MCI);

// Return instruction name
StringRef getName(MCInstrInfo const &MCII, MCInst const &MCI);

// Return the instruction at Index
MCInst const &instruction(MCInst const &MCB, size_t Index);

// Returns whether this MCInst is a wellformed bundle
inline bool isBundle(MCInst const &MCI) {
  bool const Result = POSTRISC::BUNDLE == MCI.getOpcode();
  assert(!Result || (MCI.size() > 0 && MCI.getOperand(0).isImm()));
  return Result;
}

// Returns the number of instructions in the bundle
inline size_t bundleSize(MCInst const &MCI) {
  if (isBundle(MCI))
    return (MCI.size() - Postrisc::bundleInstructionsOffset);
  else
    return (1);
}

// Returns a iterator range of instructions in this bundle
inline iterator_range<Postrisc::PacketIterator> bundleInstructions(MCInstrInfo const &MCII, MCInst const &MCI) {
  assert(isBundle(MCI));
  return make_range(Postrisc::PacketIterator(MCII, MCI),
                    Postrisc::PacketIterator(MCII, MCI, nullptr));
}

inline iterator_range<MCInst::const_iterator> bundleInstructions(MCInst const &MCI) {
  assert(isBundle(MCI));
  return drop_begin(MCI, Postrisc::bundleInstructionsOffset);
}

} // end namespace Postrisc

} // end namespace llvm

#endif // LLVM_LIB_TARGET_POSTRISC_MCTARGETDESC_POSTRISCMCINSTRINFO_H
