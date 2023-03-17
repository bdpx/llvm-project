//===-------------- PostriscBundle.h bundle class --*- C++ -*--------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains the instruction bundle definitions
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_SUPPORT_POSTRISC_BUNDLE_H
#define LLVM_SUPPORT_POSTRISC_BUNDLE_H

namespace llvm {
namespace postrisc {

  enum slot_type {
    SLOT_A      = 0,
    SLOT_B      = 1,
    SLOT_C      = 2,
    SLOT_A_EXT  = 3,
    SLOT_B_EXT  = 4,
  };

  enum class EBundleTemplate {
    bundle_sss = 0, // short, short, short
    bundle_sll = 1, // short, then long
    bundle_lls = 2, // long, then short
    bundle_lll = 3  // reserved
  };

  struct InstructionFieldSize {
  enum : int {
      BinaryImm = 21,
      CallDisp = 28,
      ForwardDisp = 28,
      BranchDisp = 17,
  };};

  struct LongInstructionFieldSize {
  enum : int {
      BinaryImm = 63,
      CallDisp = 60,
      ForwardDisp = 64,
      BranchDisp = 30,
  };};

  struct InstructionFieldExtSize {
  enum : int {
      BinaryImm   = LongInstructionFieldSize::BinaryImm   - InstructionFieldSize::BinaryImm,
      CallDisp    = LongInstructionFieldSize::CallDisp    - InstructionFieldSize::CallDisp,
      ForwardDisp = LongInstructionFieldSize::ForwardDisp - InstructionFieldSize::ForwardDisp,
      BranchDisp  = LongInstructionFieldSize::BranchDisp  - InstructionFieldSize::BranchDisp,
  };};

  inline char const *GetBundleTemplateName(EBundleTemplate Template) {
    switch (Template) {
      case EBundleTemplate::bundle_sss: return "sss";
      case EBundleTemplate::bundle_sll: return "sll";
      case EBundleTemplate::bundle_lls: return "lls";
      case EBundleTemplate::bundle_lll: return "lll";
    }
    llvm_unreachable("unknown bundle template type");
  }

  class CBundle {
    public:
    uint64_t lo, hi;
    enum {
      bits_per_bundle_template = 2,
      bits_per_slot = 42
    };
    static uint64_t GetSlotMask() { return (1ULL << bits_per_slot) - 1; }

    static CBundle create(const uint64_t slot[3], EBundleTemplate tmplt)
    {
      const uint64_t mask = GetSlotMask();
      const uint64_t s0 = slot[0] & mask;
      const uint64_t s1 = slot[1] & mask;
      const uint64_t s2 = slot[2] & mask;

      CBundle bundle;
      bundle.lo = static_cast<uint64_t>(tmplt) |
         (s0 << bits_per_bundle_template) |
         (s1 << (bits_per_bundle_template + bits_per_slot));

      bundle.hi = (s1 >> (64 - bits_per_slot - bits_per_bundle_template)) |
                  (s2 << (64 - bits_per_slot));
      return bundle;
    }

    EBundleTemplate GetTemplate(void) const {
        return static_cast<EBundleTemplate>(lo & ((1U << bits_per_bundle_template) - 1));
    }

    uint64_t GetSlotA(void) const {
        return  (lo >> bits_per_bundle_template) & GetSlotMask();
    }
    uint64_t GetSlotB(void) const {
        return ((lo >> (bits_per_bundle_template + bits_per_slot)) |
                (hi << (64 - bits_per_slot - bits_per_bundle_template)))
               & GetSlotMask();
    }
    uint64_t GetSlotC(void) const {
        return  (hi >> (64 - bits_per_slot)) & GetSlotMask();
    }
    static void format_u64(raw_ostream& out, uint64_t v) {
      // little endian per-byte
      for (int i=0; i<8; i++) {
        out << format_hex_no_prefix(v & 0xFF, 8/4) << ' ';
        v = v >> 8;
      }
    }
    friend raw_ostream& operator<< (raw_ostream& out, CBundle const& bundle) {
      out << format_hex_no_prefix(bundle.hi, 64/4)
          << '_' << format_hex_no_prefix(bundle.lo, 64/4);
      CBundle::format_u64(out, bundle.lo);
      CBundle::format_u64(out, bundle.hi);
      out << ' ' << format_hex_no_prefix(bundle.GetSlotC(), (CBundle::bits_per_slot+3)/4)
          << ' ' << format_hex_no_prefix(bundle.GetSlotB(), (CBundle::bits_per_slot+3)/4)
          << ' ' << format_hex_no_prefix(bundle.GetSlotA(), (CBundle::bits_per_slot+3)/4)
          << ' ' << GetBundleTemplateName(bundle.GetTemplate());
      return out;
    }
  };

}}  // end namespace llvm::postrisc

#endif
