//===- Postrisc.cpp --------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "OutputSections.h"
#include "Symbols.h"
#include "SyntheticSections.h"
#include "Target.h"
#include "lld/Common/ErrorHandler.h"
#include "llvm/BinaryFormat/ELF.h"
#include "llvm/Support/ELFAttributes.h"
#include "llvm/Support/Endian.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/Postrisc/PostriscBundle.h"

#define DEBUG_TYPE "postrisc-elf-linker"

using namespace llvm;
using namespace llvm::support::endian;
using namespace llvm::ELF;
using namespace lld;
using namespace lld::elf;

namespace {
class Postrisc final : public TargetInfo {
public:
  Postrisc(Ctx& ctx);
  uint32_t calcEFlags() const override;
  RelExpr getRelExpr(RelType type, const Symbol &s,
                const uint8_t *loc) const override;
  int64_t getImplicitAddend(const uint8_t *buf, RelType type) const override;
  RelType getDynRel(RelType type) const override;
  void writePlt(uint8_t *buf, const Symbol &sym,
                uint64_t pltEntryAddr) const override;
  void relocate(uint8_t *loc, const Relocation &rel,
                uint64_t val) const override;
};

// debug mutex for ordering dbgs output
std::mutex dbgsMutex;

} // namespace

Postrisc::Postrisc(Ctx& ctx) : TargetInfo(ctx) {
  copyRel = R_POSTRISC_COPY;
  gotRel = R_POSTRISC_GLOB_DAT;
  pltRel = R_POSTRISC_JMP_SLOT;
  relativeRel = R_POSTRISC_RELATIVE;
  symbolicRel = R_POSTRISC_64;
  pltEntrySize = 32;
  pltHeaderSize = 4 * pltEntrySize;

  defaultCommonPageSize = 16 * 1024;
  defaultMaxPageSize = 64 * 1024;
  defaultImageBase = 0x2000000; // 32MiB
}

static uint32_t getEFlags(Ctx &ctx, InputFile *f) {
  if (ctx.arg.is64)
    return cast<ObjFile<llvm::object::ELF64LE>>(f)->getObj().getHeader().e_flags;
  else
    return cast<ObjFile<llvm::object::ELF32LE>>(f)->getObj().getHeader().e_flags;
}

uint32_t Postrisc::calcEFlags() const {
  // If there are only binary input files (from -b binary), use a
  // value of 0 for the ELF header flags.
  if (ctx.objectFiles.empty())
    return 0;

  uint32_t target = getEFlags(ctx, ctx.objectFiles.front());

  for (InputFile *f : ctx.objectFiles) {
    uint32_t const eflags = getEFlags(ctx, f);
    if (eflags & EF_POSTRISC_PIC)
      target |= EF_POSTRISC_PIC;

    if ((eflags & EF_POSTRISC_ARCH) != (target & EF_POSTRISC_ARCH))
      ErrAlways(ctx) << f << ": cannot link object files with different arch";
  }
  return target;
}

int64_t Postrisc::getImplicitAddend(const uint8_t *buf, RelType type) const {
  switch (type) {
  default:
    InternalErr(ctx, buf) << "cannot read addend for relocation " << type;
    return 0;
  case R_POSTRISC_32:
  //case R_POSTRISC_TLS_DTPMOD32:
  //case R_POSTRISC_TLS_DTPREL32:
  //case R_POSTRISC_TLS_TPREL32:
    return SignExtend64<32>(read32le(buf));
  case R_POSTRISC_64:
  //case R_POSTRISC_TLS_DTPMOD64:
  //case R_POSTRISC_TLS_DTPREL64:
  //case R_POSTRISC_TLS_TPREL64:
    return read64le(buf);
  case R_POSTRISC_RELATIVE:
  //case R_POSTRISC_IRELATIVE:
    return ctx.arg.is64 ? read64le(buf) : read32le(buf);
  case R_POSTRISC_NONE:
  //case R_POSTRISC_JUMP_SLOT:
    // These relocations are defined as not having an implicit addend.
    return 0;
  }
}

static void
FixupOffset(postrisc::CBundle *bundle, uint64_t Value,
  postrisc::slot_type slottype,
  unsigned field_offset, unsigned field_size,
  unsigned field_ext_offset, unsigned field_ext_size)
{
  assert(field_size + field_offset <= postrisc::CBundle::bits_per_slot);
  assert(field_ext_size + field_ext_offset <= postrisc::CBundle::bits_per_slot);

  uint64_t const mask_lo  = ((UINT64_C(1) << field_size    ) - 1) << field_offset;
  uint64_t const mask_hi  = ((UINT64_C(1) << field_ext_size) - 1) << field_ext_offset;

  uint64_t const value_lo = ((Value              ) << field_offset    ) & mask_lo;
  uint64_t const value_hi = ((Value >> field_size) << field_ext_offset) & mask_hi;

  LLVM_DEBUG(dbgs() << *bundle << "\n");
  LLVM_DEBUG(dbgs() << "FixupOffset[" << (int)slottype << "] "
         << field_offset << ":" << field_size
         << " Value=" << (int64_t)Value << " - "
         << value_hi << ":" << value_lo << "\n");

  postrisc::EBundleTemplate const Template = bundle->GetTemplate();
  uint64_t slot[3] = {
    bundle->GetSlotA(),
    bundle->GetSlotB(),
    bundle->GetSlotC()
  };

  switch (slottype) {
    case postrisc::SLOT_A:
      assert(Template == postrisc::EBundleTemplate::bundle_sss ||
             Template == postrisc::EBundleTemplate::bundle_sll);
      slot[0] &= ~mask_lo;
      slot[0] |= value_lo;
      break;
    case postrisc::SLOT_B:
      assert(Template == postrisc::EBundleTemplate::bundle_sss);
      slot[1] &= ~mask_lo;
      slot[1] |= value_lo;
      break;
    case postrisc::SLOT_C:
      assert(Template == postrisc::EBundleTemplate::bundle_sss ||
             Template == postrisc::EBundleTemplate::bundle_lls);
      slot[2] &= ~mask_lo;
      slot[2] |= value_lo;
      break;
    case postrisc::SLOT_A_EXT:
      LLVM_DEBUG(dbgs() << "bundle(lls) " << *bundle << "\n");
      assert(Template == postrisc::EBundleTemplate::bundle_lls);
      slot[0] &= ~mask_lo;
      slot[0] |= value_lo;
      slot[1] &= ~mask_hi;
      slot[1] |= value_hi;
      break;
    case postrisc::SLOT_B_EXT:
      LLVM_DEBUG(dbgs() << "bundle(sll) " << *bundle << "\n");
      assert(Template == postrisc::EBundleTemplate::bundle_sll);
      slot[1] &= ~mask_lo;
      slot[1] |= value_lo;
      slot[2] &= ~mask_hi;
      slot[2] |= value_hi;
      break;
  }

  *bundle = postrisc::CBundle::create(slot, Template);
  LLVM_DEBUG(dbgs() << *bundle << "\n");
}

static uint64_t CorrectNIP(uint64_t val) { return val; }

static postrisc::slot_type GetSlotTypeFromKind(int Kind, int startKind) {
  return (postrisc::slot_type)(Kind - startKind);
}

static void
FixupBranch(postrisc::CBundle *bundle, int64_t Value,
  postrisc::slot_type slottype,
  unsigned field_offset, unsigned field_size,
  unsigned field_ext_offset, unsigned field_ext_size)
{
  if (Value % sizeof(postrisc::CBundle) != 0) {
     dbgs() << "Unaligned: FixupBranch[" << (int)slottype << "] "
       << *bundle
       << field_offset << ":" << field_size
       << " Value=" << Value
       << "\n";
  }
  assert(Value % sizeof(postrisc::CBundle) == 0);
  Value /= sizeof(postrisc::CBundle);
  LLVM_DEBUG(dbgs() << "FixupBranch[" << (int)slottype << "] "
       << *bundle
       << field_offset << ":" << field_size
       << " Value=" << Value
       << "\n");

  FixupOffset(bundle, Value, slottype,
    field_offset, field_size, field_ext_offset, field_ext_size);
}

#define RELOC_ALL_CASES(NAME)       \
  case R_POSTRISC_A_##NAME:         \
  case R_POSTRISC_B_##NAME:         \
  case R_POSTRISC_C_##NAME:         \
  case R_POSTRISC_A_##NAME##_EXT:   \
  case R_POSTRISC_B_##NAME##_EXT:   \

RelExpr
Postrisc::getRelExpr(RelType type, const Symbol &s, const uint8_t *loc) const
{
  switch (type) {
    case R_POSTRISC_NONE:
      return R_NONE;

    case R_POSTRISC_8:
    case R_POSTRISC_16:
    case R_POSTRISC_32:
    case R_POSTRISC_64:
      return R_ABS;

    case R_POSTRISC_DISP8:
    case R_POSTRISC_DISP16:
    case R_POSTRISC_DISP32:
    case R_POSTRISC_DISP64:
      return R_PLT_PC;

    // FIXME: add some
      return R_GOT_OFF;

    RELOC_ALL_CASES(TLS_GD_GOT_OFFSET)
    RELOC_ALL_CASES(TLS_GD_CALL)
    RELOC_ALL_CASES(TLS_LD_GOT_OFFSET)
    RELOC_ALL_CASES(TLS_LD_CALL)
    RELOC_ALL_CASES(TLS_LD_OFFSET)
    RELOC_ALL_CASES(TLS_IE_OFFSET)
    RELOC_ALL_CASES(TLS_LE_OFFSET)

    case R_POSTRISC_COPY:
    case R_POSTRISC_GLOB_DAT:
    case R_POSTRISC_JMP_SLOT:
    case R_POSTRISC_RELATIVE:
    case R_POSTRISC_PLT64:
      return R_TPREL;

    //case R_POSTRISC_GOTDATA_OP:
    //  return R_GOT_OFF;

    RELOC_ALL_CASES(JUMP)
    RELOC_ALL_CASES(BRANCH)
    RELOC_ALL_CASES(PCREL_FWD)
    RELOC_ALL_CASES(PCREL_FWD_GOT)
    RELOC_ALL_CASES(PCREL_FWD_PLT)
      return R_PC;
  }
  Err(ctx) << getErrorLoc(ctx, loc) << "unknown relocation (" << type.v
             << ") against symbol " << &s;
  return R_NONE;
}

#undef RELOC_ALL_CASES

#define RELOC_ALL_CASES(NAME)       \
  case R_POSTRISC_A_##NAME:         \
  case R_POSTRISC_B_##NAME:         \
  case R_POSTRISC_C_##NAME:         \
  case R_POSTRISC_A_##NAME##_EXT:   \
  case R_POSTRISC_B_##NAME##_EXT:

void Postrisc::relocate(uint8_t *loc, const Relocation &rel,
                        uint64_t val) const {
  postrisc::CBundle *bundle = reinterpret_cast<postrisc::CBundle*>(loc);
  std::lock_guard<std::mutex> lock(dbgsMutex);

  int64_t sval = (int64_t)val;

  int const Kind = rel.type;
  switch (Kind) {
  case R_POSTRISC_NONE:
    dbgs() << "reloc: NONE\n";
    break;
  case R_POSTRISC_COPY:
    dbgs() << "reloc: COPY\n";
    break;
  case R_POSTRISC_JMP_SLOT:
    dbgs() << "reloc: JMP_SLOT\n";
    break;
  case R_POSTRISC_RELATIVE:
    LLVM_DEBUG(dbgs() << "reloc: RELATIVE\n");
    break;
  case R_POSTRISC_DISP8:
    dbgs() << "reloc: DISP8\n";
    break;
  case R_POSTRISC_DISP16:
    dbgs() << "reloc: DISP16\n";
    break;
  case R_POSTRISC_GLOB_DAT:
    dbgs() << "reloc: GLOB_DAT\n";
    break;
  case R_POSTRISC_PLT64:
    dbgs() << "reloc: PLT64\n";
    break;

  case R_POSTRISC_8:
  case R_POSTRISC_16:
  case R_POSTRISC_32:
    dbgs() << "reloc: 8/16/32\n";
    // V-word32
    checkUInt(ctx, loc, val, 32, rel);
    write32le(loc, val);
    break;

  case R_POSTRISC_R_DISP32:
  case R_POSTRISC_DISP32:
    LLVM_DEBUG(dbgs() << "reloc: (R_)(DISP)32\n");
    // V-disp32
    checkInt(ctx, loc, val, 32, rel);
    write32le(loc, val);
    break;

  case R_POSTRISC_64:
  case R_POSTRISC_DISP64:
    LLVM_DEBUG(dbgs() << "reloc: (DISP)64 " << format_hex(val,8) << "\n");
    // V-xword64
    write64le(loc, val);
    break;

  RELOC_ALL_CASES(JUMP)
    LLVM_DEBUG(dbgs() << "reloc: JUMP (" << Kind << "): " << sval << " offset=" << rel.offset << " addend=" << rel.addend << "\n");
    checkAlignment(ctx, loc, val, sizeof(postrisc::CBundle), rel);
    FixupBranch(bundle, CorrectNIP(val), GetSlotTypeFromKind(Kind, R_POSTRISC_A_JUMP),
      0, llvm::postrisc::InstructionFieldSize::CallDisp,
      0, llvm::postrisc::InstructionFieldExtSize::CallDisp);
    break;
  RELOC_ALL_CASES(BRANCH)
    LLVM_DEBUG(dbgs() << "reloc: BRANCH: " << sval << "\n");
    checkAlignment(ctx, loc, val, sizeof(postrisc::CBundle), rel);
    FixupBranch(bundle, CorrectNIP(val), GetSlotTypeFromKind(Kind, R_POSTRISC_A_BRANCH),
      0, llvm::postrisc::InstructionFieldSize::BranchDisp,
      0, llvm::postrisc::InstructionFieldExtSize::BranchDisp);
    break;
  RELOC_ALL_CASES(PCREL_FWD)
    LLVM_DEBUG(dbgs() << "reloc: PCREL_FWD (" << Kind << "): " << sval << " offset=" << rel.offset << " addend=" << rel.addend << "\n");
    FixupOffset(bundle, CorrectNIP(val), GetSlotTypeFromKind(Kind, R_POSTRISC_A_PCREL_FWD),
      0, llvm::postrisc::InstructionFieldSize::ForwardDisp,
      0, llvm::postrisc::InstructionFieldExtSize::ForwardDisp);
    break;
  RELOC_ALL_CASES(PCREL_FWD_GOT)
    dbgs() << "reloc: PCREL_FWD_GOT: " << sval << "\n";
    break;
  RELOC_ALL_CASES(PCREL_FWD_PLT)
    dbgs() << "reloc: PCREL_FWD_PLT: " << sval << "\n";
    break;
  RELOC_ALL_CASES(LDI)
    dbgs() << "reloc: LDI: " << sval << "\n";
    break;
  RELOC_ALL_CASES(OFFSET)
    dbgs() << "reloc: OFFSET: " << sval << "\n";
    break;

  /******************************************************************************
  * TLS
  ******************************************************************************/
  RELOC_ALL_CASES(TLS_GD_GOT_OFFSET)
    dbgs() << "reloc: TLS_GD_GOT_OFFSET: " << sval << "\n";
    break;
  RELOC_ALL_CASES(TLS_GD_CALL)
    dbgs() << "reloc: TLS_GD_CALL: " << sval << "\n";
    break;
  RELOC_ALL_CASES(TLS_LD_GOT_OFFSET)
    dbgs() << "reloc: TLS_LD_GOT_OFFSET: " << sval << "\n";
    break;
  RELOC_ALL_CASES(TLS_LD_CALL)
    dbgs() << "reloc: TLS_LD_CALL: " << sval << "\n";
    break;
  RELOC_ALL_CASES(TLS_LD_OFFSET)
    dbgs() << "reloc: TLS_LD_OFFSET: " << sval << "\n";
    break;
  RELOC_ALL_CASES(TLS_IE_OFFSET)
    dbgs() << "reloc: TLS_IE_OFFSET: " << sval << "\n";
    break;
  RELOC_ALL_CASES(TLS_LE_OFFSET)
    dbgs() << "reloc: TLS_LE_OFFSET: " << sval << "\n";
    break;

  default:
    dbgs() << "relocate: Kind=" << Kind << " val=" << sval << "\n";
    llvm_unreachable("unknown relocation");
  }
}

void
Postrisc::writePlt(uint8_t *buf, const Symbol& sym, uint64_t pltEntryAddr) const
{
  dbgs() << "writePlt:"
         << " pltEntryAddr=" << pltEntryAddr
         << " sym=" << sym.getName() << "\n";

  const uint8_t pltData[] = {
      0x03, 0x00, 0x00, 0x00, // sethi   (. - .PLT0), %g1
      0x30, 0x68, 0x00, 0x00, // ba,a    %xcc, .PLT1
      0x01, 0x00, 0x00, 0x00, // nop
      0x01, 0x00, 0x00, 0x00, // nop
      0x01, 0x00, 0x00, 0x00, // nop
      0x01, 0x00, 0x00, 0x00, // nop
      0x01, 0x00, 0x00, 0x00, // nop
      0x01, 0x00, 0x00, 0x00  // nop
  };
  memcpy(buf, pltData, sizeof(pltData));

  uint64_t off = pltEntryAddr - ctx.in.plt->getVA();
  // FIXME:
  //relocateNoSym(buf, R_POSTRISC_WDISP_HI20, off);
  //relocateNoSym(buf + 4, R_POSTRISC_WDISP27, -(off + 4 - pltEntrySize));
}

RelType
Postrisc::getDynRel(RelType type) const {
  if (type == R_POSTRISC_64
      // FIXME: add other dynamic (abs) relocations
      // || type == R_X86_64_PC64 || type == R_X86_64_SIZE32 || type == R_X86_64_SIZE64
    )
    return type;
  return R_POSTRISC_NONE;
}

void elf::setPostriscTargetInfo(Ctx &ctx) { ctx.target.reset(new Postrisc(ctx)); }
