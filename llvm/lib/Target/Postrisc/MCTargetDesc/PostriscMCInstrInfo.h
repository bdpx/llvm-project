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
#include <cstddef>
#include <cstdint>

namespace llvm {

class MCContext;
class MCExpr;
class MCInstrDesc;
class MCInstrInfo;
class MCRegisterInfo;
class MCSubtargetInfo;

namespace Postrisc {

class PacketIterator
    : public llvm::iterator_facade_base<
          PacketIterator, std::forward_iterator_tag, const MCInst> {
  MCInst::const_iterator BundleCurrent;
  MCInst::const_iterator BundleEnd;

public:
  PacketIterator(MCInstrInfo const &MCII, MCInst const &Inst);
  PacketIterator(MCInstrInfo const &MCII, MCInst const &Inst, std::nullptr_t);

  PacketIterator &operator++();
  MCInst const &operator*() const;
  bool operator==(PacketIterator const &Other) const;
};
} // end namespace Postrisc

namespace PostriscMCInstrInfo {

constexpr size_t bundleInstructionsOffset = 1;

void addConstant(MCInst &MI, uint64_t Value, MCContext &Context);
void addConstExtender(MCContext &Context, MCInstrInfo const &MCII, MCInst &MCB,
                      MCInst const &MCI);

// Returns a iterator range of instructions in this bundle
iterator_range<Postrisc::PacketIterator>
bundleInstructions(MCInstrInfo const &MCII, MCInst const &MCI);
iterator_range<MCInst::const_iterator> bundleInstructions(MCInst const &MCI);

// Returns the number of instructions in the bundle
size_t bundleSize(MCInst const &MCI);

// Return instruction name
StringRef getName(MCInstrInfo const &MCII, MCInst const &MCI);

// Return the instruction at Index
MCInst const &instruction(MCInst const &MCB, size_t Index);

// Returns whether this MCInst is a wellformed bundle
bool isBundle(MCInst const &MCI);

} // end namespace PostriscMCInstrInfo

} // end namespace llvm

#endif // LLVM_LIB_TARGET_POSTRISC_MCTARGETDESC_POSTRISCMCINSTRINFO_H
