//===- PostriscMCInstrInfo.cpp - Postrisc sub-class of MCInst -------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This class extends MCInstrInfo to allow Postrisc specific MCInstr queries
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/PostriscMCInstrInfo.h"
#include "MCTargetDesc/PostriscMCTargetDesc.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/StringSwitch.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCInstrItineraries.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/Support/Casting.h"
#include "llvm/Support/ErrorHandling.h"
#include <cassert>
#include <cstdint>
#include <limits>

using namespace llvm;

Postrisc::PacketIterator::PacketIterator(MCInstrInfo const &MCII, MCInst const &Inst)
  : BundleCurrent(Inst.begin() + PostriscMCInstrInfo::bundleInstructionsOffset)
  , BundleEnd(Inst.end())
{}

Postrisc::PacketIterator::PacketIterator(MCInstrInfo const &MCII, MCInst const &Inst, std::nullptr_t)
  : BundleCurrent(Inst.end())
  , BundleEnd(Inst.end())
{}

Postrisc::PacketIterator& Postrisc::PacketIterator::operator++() {
  ++BundleCurrent;
  return *this;
}

MCInst const & Postrisc::PacketIterator::operator*() const {
  return *BundleCurrent->getInst();
}

bool Postrisc::PacketIterator::operator==(PacketIterator const &Other) const {
  return BundleCurrent == Other.BundleCurrent && BundleEnd == Other.BundleEnd;
}

void PostriscMCInstrInfo::addConstant(MCInst &MI, uint64_t Value,
                                     MCContext &Context) {
  MI.addOperand(MCOperand::createExpr(MCConstantExpr::create(Value, Context)));
}

bool PostriscMCInstrInfo::isBundle(MCInst const &MCI)
{
  bool const Result = POSTRISC::BUNDLE == MCI.getOpcode();
  assert(!Result || (MCI.size() > 0 && MCI.getOperand(0).isImm()));
  return Result;
}

iterator_range<Postrisc::PacketIterator>
PostriscMCInstrInfo::bundleInstructions(MCInstrInfo const &MCII, MCInst const &MCI) {
  assert(isBundle(MCI));
  return make_range(Postrisc::PacketIterator(MCII, MCI),
                    Postrisc::PacketIterator(MCII, MCI, nullptr));
}

iterator_range<MCInst::const_iterator>
PostriscMCInstrInfo::bundleInstructions(MCInst const &MCI) {
  assert(isBundle(MCI));
  return drop_begin(MCI, bundleInstructionsOffset);
}

size_t
PostriscMCInstrInfo::bundleSize(MCInst const &MCI)
{
  if (PostriscMCInstrInfo::isBundle(MCI))
    return (MCI.size() - bundleInstructionsOffset);
  else
    return (1);
}
