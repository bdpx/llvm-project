//===-- PostriscAsmBackend.cpp - Postrisc Assembler Backend ---------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/PostriscFixupKinds.h"
#include "MCTargetDesc/PostriscMCTargetDesc.h"
#include "Postrisc.h"
#include "llvm/ADT/StringSwitch.h"
#include "llvm/MC/MCAsmBackend.h"
#include "llvm/MC/MCELFObjectWriter.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCObjectWriter.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/MCValue.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/Support/EndianStream.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/Postrisc/PostriscBundle.h"

using namespace llvm;

#define DEBUG_TYPE "postrisc-asmbackend"

/// getFixupKindNumBytes - The number of bytes the fixup may change.
static unsigned getFixupKindNumBytes(unsigned Kind) {
    switch (Kind) {
  default:
    return 4;
  case FK_Data_1:
    return 1;
  case FK_Data_2:
    return 2;
  case FK_Data_8:
    return 8;
  }
}

namespace {
class PostriscAsmBackend : public MCAsmBackend {
protected:
  bool Is64Bit;

public:
  PostriscAsmBackend(const MCSubtargetInfo &STI)
      : MCAsmBackend(llvm::endianness::little),
        Is64Bit(true) {}

  std::optional<MCFixupKind> getFixupKind(StringRef Name) const override;
  MCFixupKindInfo getFixupKindInfo(MCFixupKind Kind) const override;
  void applyFixup(const MCFragment &, const MCFixup &, const MCValue &Target,
                  uint8_t *Data, uint64_t Value, bool IsResolved) override;

    void relaxInstruction(MCInst &Inst,
                          const MCSubtargetInfo &STI) const override {
      // FIXME.
      llvm_unreachable("relaxInstruction() unimplemented");
    }

  bool writeNopData(raw_ostream &OS, uint64_t Count,
                    const MCSubtargetInfo *STI) const override {
    if (Count == 0)
      return true;
    // Cannot emit NOP with size not multiple of bundle.
    return false;

    llvm_unreachable("writeNopData() unimplemented");
    if (Count % 16 != 0)
      return false;

    uint64_t NumNops = Count / 4;
    for (uint64_t i = 0; i != NumNops; ++i)
      support::endian::write<uint32_t>(OS, 0x01000000, Endian);

    return true;
  }
};

class ELFPostriscAsmBackend : public PostriscAsmBackend {
  Triple::OSType OSType;

public:
  ELFPostriscAsmBackend(const MCSubtargetInfo &STI, Triple::OSType OSType)
      : PostriscAsmBackend(STI), OSType(OSType) {}

  std::unique_ptr<MCObjectTargetWriter>
  createObjectTargetWriter() const override {
    uint8_t OSABI = MCELFObjectTargetWriter::getOSABI(OSType);
    return createPostriscELFObjectWriter(Is64Bit, OSABI);
  }
};
} // end anonymous namespace

std::optional<MCFixupKind> PostriscAsmBackend::getFixupKind(StringRef Name) const {
  unsigned Type;
  Type = llvm::StringSwitch<unsigned>(Name)
#define ELF_RELOC(X, Y) .Case(#X, Y)
#include "llvm/BinaryFormat/ELFRelocs/Postrisc.def"
#undef ELF_RELOC
             .Case("BFD_RELOC_NONE", ELF::R_POSTRISC_NONE)
             .Case("BFD_RELOC_8", ELF::R_POSTRISC_8)
             .Case("BFD_RELOC_16", ELF::R_POSTRISC_16)
             .Case("BFD_RELOC_32", ELF::R_POSTRISC_32)
             .Case("BFD_RELOC_64", ELF::R_POSTRISC_64)
             .Default(-1u);
  if (Type == -1u)
    return std::nullopt;
  return static_cast<MCFixupKind>(FirstLiteralRelocationKind + Type);
}

MCFixupKindInfo PostriscAsmBackend::getFixupKindInfo(MCFixupKind Kind) const {
  // clang-format off
  const static MCFixupKindInfo InfosBE[Postrisc::NumTargetFixupKinds] = {
      // name                    offset bits flags
      {"fixup_postrisc_dummy",       0,     0,  0},
};
  const static MCFixupKindInfo InfosLE[Postrisc::NumTargetFixupKinds] = {
      // name                    offset bits flags
      {"fixup_postrisc_dummy",       0,     0,  0},
  };
  // clang-format on

  if (!mc::isRelocation(Kind)) {
    if (Kind < FirstTargetFixupKind)
      return MCAsmBackend::getFixupKindInfo(Kind);
    assert(unsigned(Kind - FirstTargetFixupKind) < Postrisc::NumTargetFixupKinds &&
           "Invalid kind!");
    if (Endian == llvm::endianness::little)
      return InfosLE[Kind - FirstTargetFixupKind];

    return InfosBE[Kind - FirstTargetFixupKind];
  }

  MCFixupKindInfo Info{};
  Info = {"dummy", 0, 0, 0};

#define ALL_CASES(NAME, OFFSET, LENGTH)                                                                         \
  case ELF::R_POSTRISC_A_ ## NAME        :  Info = { "fixup_A_" #NAME       , 0*42+OFFSET, LENGTH, 0 }; break;  \
  case ELF::R_POSTRISC_B_ ## NAME        :  Info = { "fixup_B_" #NAME       , 1*42+OFFSET, LENGTH, 0 }; break;  \
  case ELF::R_POSTRISC_C_ ## NAME        :  Info = { "fixup_C_" #NAME       , 2*42+OFFSET, LENGTH, 0 }; break;  \
  case ELF::R_POSTRISC_A_ ## NAME ## _EXT:  Info = { "fixup_A_" #NAME "_EXT", 0*42+OFFSET, LENGTH, 0 }; break;  \
  case ELF::R_POSTRISC_B_ ## NAME ## _EXT:  Info = { "fixup_B_" #NAME "_EXT", 1*42+OFFSET, LENGTH, 0 }; break;  \

  switch (uint16_t(Kind)) {
  ALL_CASES(JUMP,               0, 28)
  ALL_CASES(BRANCH,             0, 17)
  ALL_CASES(PCREL_FWD,          0, 28)
  ALL_CASES(PCREL_FWD_GOT,      0, 28)
  ALL_CASES(PCREL_FWD_PLT,      0, 28)
  ALL_CASES(LD_IMM,             0, 28)
  ALL_CASES(OFFSET,             0, 28)
  ALL_CASES(TLS_GD_GOT_OFFSET,  0, 28)
  ALL_CASES(TLS_GD_CALL,        0, 28)
  ALL_CASES(TLS_LD_GOT_OFFSET,  0, 28)
  ALL_CASES(TLS_LD_CALL,        0, 28)
  ALL_CASES(TLS_LD_OFFSET,      0, 28)
  ALL_CASES(TLS_IE_OFFSET,      0, 28)
  ALL_CASES(TLS_LE_OFFSET,      0, 28)
  }
#undef ALL_CASES
  assert(Endian == llvm::endianness::little && "little endian only!");
  return Info;
}

static void
FixupData(uint8_t *Data, uint64_t Value, unsigned NumBytes, bool littleEndian)
{
  LLVM_DEBUG(dbgs() << "FixupData: NumBytes=" << NumBytes << "\n");
  for (unsigned i = 0; i != NumBytes; ++i) {
    unsigned Idx = littleEndian ? i : (NumBytes - 1) - i;
    Data[Idx] |= uint8_t((Value >> (i * 8)) & 0xff);
  }
}

void PostriscAsmBackend::applyFixup(const MCFragment &F, const MCFixup &Fixup,
                                 const MCValue &Target, uint8_t *Data,
                                 uint64_t Value, bool IsResolved) {
  maybeAddReloc(F, Fixup, Target, Value, IsResolved);
  if (!IsResolved)
    return;
  // Value = adjustFixupValue(Fixup.getKind(), Value);

  MCFixupKind const Kind = Fixup.getKind();

  LLVM_DEBUG(dbgs()
         << "applyFixup: Kind=" << Fixup.getKind()
         << " " << getFixupKindInfo(Kind).Name
         << " Value=" << (int64_t)Value << "\n");

  postrisc::CBundle *bundle = reinterpret_cast<postrisc::CBundle*>(Data);

#define ALL_CASES(NAME)      \
  case ELF::R_POSTRISC_A_##NAME:         \
  case ELF::R_POSTRISC_B_##NAME:         \
  case ELF::R_POSTRISC_C_##NAME:         \
  case ELF::R_POSTRISC_A_##NAME##_EXT:   \
  case ELF::R_POSTRISC_B_##NAME##_EXT:   \

  switch (Fixup.getKind()) {
  default:
    LLVM_DEBUG(dbgs() << "Unknown fixup kind: " << Fixup.getKind() << "\n");
    llvm_unreachable("Unknown fixup kind!");
  case FK_Data_1: FixupData(Data, Value, 1, Endian == llvm::endianness::little);  break;
  case FK_Data_2: FixupData(Data, Value, 2, Endian == llvm::endianness::little);  break;
  case FK_Data_4: FixupData(Data, Value, 4, Endian == llvm::endianness::little);  break;
  case FK_Data_8: FixupData(Data, Value, 8, Endian == llvm::endianness::little);  break;

  ALL_CASES(JUMP)
    bundle->FixupBranch<0>(Value, Kind,
      0, llvm::postrisc::InstructionFieldSize::CallDisp,
      0, llvm::postrisc::InstructionFieldExtSize::CallDisp);
    break;

  ALL_CASES(BRANCH)
    bundle->FixupBranch<0>(Value, Kind,
      0, llvm::postrisc::InstructionFieldSize::BranchDisp,
      0, llvm::postrisc::InstructionFieldExtSize::BranchDisp);
    break;

  ALL_CASES(PCREL_FWD)
    bundle->FixupOffset<0>(Value, Kind,
      0, llvm::postrisc::InstructionFieldSize::ForwardDisp,
      0, llvm::postrisc::InstructionFieldExtSize::ForwardDisp);
    break;

  ALL_CASES(TLS_GD_GOT_OFFSET)
  ALL_CASES(TLS_LD_GOT_OFFSET)
  ALL_CASES(TLS_LD_OFFSET)
  ALL_CASES(TLS_IE_OFFSET)
  ALL_CASES(TLS_LE_OFFSET)
    assert(Value == 0 && "Postrisc TLS relocs expect zero Value");
    break;

  ALL_CASES(TLS_GD_CALL)
  ALL_CASES(TLS_LD_CALL)
    llvm_unreachable("Unsupported fixup kind!");
    break;
  }
#undef ALL_CASES
}

MCAsmBackend *llvm::createPostriscAsmBackend(const Target &T,
                                          const MCSubtargetInfo &STI,
                                          const MCRegisterInfo &MRI,
                                          const MCTargetOptions &Options) {
  return new ELFPostriscAsmBackend(STI, STI.getTargetTriple().getOS());
}
