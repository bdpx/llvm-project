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

#include "llvm/BinaryFormat/ELF.h"
#include "llvm/Support/Debug.h"

#define DEBUG_TYPE "postrisc-bundle"

namespace llvm {
namespace postrisc {

using MCFixupKind = uint16_t;

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

    template<int dummy> void
    FixupOffset(uint64_t Value, MCFixupKind type,
        unsigned field_offset, unsigned field_size,
        unsigned field_ext_offset, unsigned field_ext_size);
    template<int dummy> void
    FixupBranch(int64_t Value, MCFixupKind type,
        unsigned field_offset, unsigned field_size,
        unsigned field_ext_offset, unsigned field_ext_size);

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

template<int dummy>
void
CBundle::FixupOffset(uint64_t Value, MCFixupKind type,
  unsigned field_offset, unsigned field_size,
  unsigned field_ext_offset, unsigned field_ext_size)
{
  LLVM_DEBUG(dbgs() << *this << "FixupOffset[" << type << "] "
         << field_offset << ":" << field_size
         << " Value=" << (int64_t)Value << "\n");

  assert(field_size + field_offset <= postrisc::CBundle::bits_per_slot);
  assert(field_ext_size + field_ext_offset <= postrisc::CBundle::bits_per_slot);

  const postrisc::EBundleTemplate Template = GetTemplate();
  uint64_t slot[3] = {
    GetSlotA(),
    GetSlotB(),
    GetSlotC(),
  };

  uint64_t const mask_lo  = ((UINT64_C(1) << field_size    ) - 1) << field_offset;
  uint64_t const mask_hi  = ((UINT64_C(1) << field_ext_size) - 1) << field_ext_offset;

  uint64_t const value_lo = ((Value              ) << field_offset    ) & mask_lo;
  uint64_t const value_hi = ((Value >> field_size) << field_ext_offset) & mask_hi;

    // all relocations with same slot and extension length
#define ALL_CASES(SLOT, EXTENSION)                                    \
    case ELF::R_POSTRISC ## SLOT ## JUMP              ## EXTENSION:   \
    case ELF::R_POSTRISC ## SLOT ## BRANCH            ## EXTENSION:   \
    case ELF::R_POSTRISC ## SLOT ## PCREL_FWD         ## EXTENSION:   \
    case ELF::R_POSTRISC ## SLOT ## PCREL_FWD_GOT     ## EXTENSION:   \
    case ELF::R_POSTRISC ## SLOT ## PCREL_FWD_PLT     ## EXTENSION:   \
    case ELF::R_POSTRISC ## SLOT ## TLS_GD_GOT_OFFSET ## EXTENSION:   \
    case ELF::R_POSTRISC ## SLOT ## TLS_GD_CALL       ## EXTENSION:   \
    case ELF::R_POSTRISC ## SLOT ## TLS_LD_GOT_OFFSET ## EXTENSION:   \
    case ELF::R_POSTRISC ## SLOT ## TLS_LD_CALL       ## EXTENSION:   \
    case ELF::R_POSTRISC ## SLOT ## TLS_LD_OFFSET     ## EXTENSION:   \
    case ELF::R_POSTRISC ## SLOT ## TLS_IE_OFFSET     ## EXTENSION:   \
    case ELF::R_POSTRISC ## SLOT ## TLS_LE_OFFSET     ## EXTENSION:   \

  switch (type) {
    ALL_CASES(_A_, )
      LLVM_DEBUG(dbgs() << "bundle(sss) " << *this << "\n");
      assert(GetTemplate() == postrisc::EBundleTemplate::bundle_sss ||
             GetTemplate() == postrisc::EBundleTemplate::bundle_sll);
      slot[0] &= ~mask_lo;
      slot[0] |= value_lo;
      break;
    ALL_CASES(_B_, )
      LLVM_DEBUG(dbgs() << "bundle(sss) " << *this << "\n");
      assert(GetTemplate() == postrisc::EBundleTemplate::bundle_sss);
      slot[1] &= ~mask_lo;
      slot[1] |= value_lo;
      break;
    ALL_CASES(_C_, )
      LLVM_DEBUG(dbgs() << "bundle(sss) " << *this << "\n");
      assert(GetTemplate() == postrisc::EBundleTemplate::bundle_sss ||
             GetTemplate() == postrisc::EBundleTemplate::bundle_lls);
      slot[2] &= ~mask_lo;
      slot[2] |= value_lo;
      break;
    ALL_CASES(_A_, _EXT)
      LLVM_DEBUG(dbgs() << "bundle(lls) " << *this << "\n");
      assert(GetTemplate() == postrisc::EBundleTemplate::bundle_lls);
      slot[0] &= ~mask_lo;
      slot[0] |= value_lo;
      slot[1] &= ~mask_hi;
      slot[1] |= value_hi;
      break;
    ALL_CASES(_B_, _EXT)
      LLVM_DEBUG(dbgs() << "bundle(sll) " << *this << "\n");
      assert(GetTemplate() == postrisc::EBundleTemplate::bundle_sll);
      slot[1] &= ~mask_lo;
      slot[1] |= value_lo;
      slot[2] &= ~mask_hi;
      slot[2] |= value_hi;
      break;
    default:
      dbgs() << "unknown relocation type: " << type << "\n";
      llvm_unreachable("unknown relocation type");
  }
#undef ALL_CASES

  *this = postrisc::CBundle::create(slot, Template);
  LLVM_DEBUG(dbgs() << (*this) << "\n");
}

template<int dummy>
void
CBundle::FixupBranch(int64_t Value, MCFixupKind type,
  unsigned field_offset, unsigned field_size,
  unsigned field_ext_offset, unsigned field_ext_size)
{
  if (Value == 0) {
    LLVM_DEBUG(dbgs() << "FixupBranch[" << type << "] "
         << *this
         << field_offset << ":" << field_size
         << " Value=" << Value
         << " Unfixed zero\n");
  }

  assert(Value % sizeof(postrisc::CBundle) == 0);
  Value /= sizeof(postrisc::CBundle);
  LLVM_DEBUG(dbgs() << "FixupBranch[" << type << "] "
     << *this
     << field_offset << ":" << field_size
     << " Value=" << Value
     << "\n");

  FixupOffset<dummy>(Value, type,
    field_offset, field_size,
    field_ext_offset, field_ext_size);
}

}}  // end namespace llvm::postrisc

#undef DEBUG_TYPE

#endif
