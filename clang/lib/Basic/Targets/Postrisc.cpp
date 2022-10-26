//===--- Postrisc.cpp - Implement Postrisc target feature support ---------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements Postrisc TargetInfo objects.
//
//===----------------------------------------------------------------------===//

#include "Postrisc.h"
#include "Targets.h"
#include "clang/Basic/MacroBuilder.h"
#include "llvm/ADT/StringSwitch.h"
#include "clang/Basic/LangOptions.h"
#include "clang/Basic/TargetBuiltins.h"
#include "clang/Basic/TargetInfo.h"
#include "llvm/Support/raw_ostream.h"
//#include "llvm/TargetParser/PostriscTargetParser.h"
#include "clang/Basic/MacroBuilder.h"
#include "llvm/ADT/ArrayRef.h"
#include "llvm/ADT/StringExtras.h"

using namespace clang;
using namespace clang::targets;

static constexpr int NumBuiltins =
    clang::Postrisc::LastTSBuiltin - Builtin::FirstTSBuiltin;

#define GET_BUILTIN_STR_TABLE
#include "clang/Basic/BuiltinsPostrisc.inc"
#undef GET_BUILTIN_STR_TABLE

static constexpr Builtin::Info BuiltinInfos[] = {
#define GET_BUILTIN_INFOS
#include "clang/Basic/BuiltinsPostrisc.inc"
#undef GET_BUILTIN_INFOS
};
static_assert(std::size(BuiltinInfos) == NumBuiltins);

llvm::SmallVector<Builtin::InfosShard>
PostriscTargetInfo::getTargetBuiltins() const {
  return {{&BuiltinStrings, BuiltinInfos}};
}

const char *const PostriscTargetInfo::GCCRegNames[] = {
    // General registers
    "r0",  "r1",  "r2",  "r3",  "r4",  "r5",  "r6",  "r7",  "r8",  "r9",
    "r10", "r11", "r12", "r13", "r14", "r15", "r16", "r17", "r18", "r19",
    "r20", "r21", "r22", "r23", "r24", "r25", "r26", "r27", "r28", "r29",
    "r30", "r31", "r32", "r33", "r34", "r35", "r36", "r37", "r38", "r39",
    "r40", "r41", "r42", "r43", "r44", "r45", "r46", "r47", "r48", "r49",
    "r50", "r51", "r52", "r53", "r54", "r55", "r56", "r57", "r58", "r59",
    "r60", "r61", "r62", "r63", "r64", "r65", "r66", "r67", "r68", "r69",
    "r70", "r71", "r72", "r73", "r74", "r75", "r76", "r77", "r78", "r79",
    "r80", "r81", "r82", "r83", "r84", "r85", "r86", "r87", "r88", "r89",
    "r90", "r91", "r92", "r93", "r94", "r95", "r96", "r97", "r98", "r99",
    "r100", "r101", "r102", "r103", "r104", "r105", "r106", "r107", "r108", "r109",
    "r110", "r111", "r112", "r113", "r114", "r115", "r116", "r117", "r118", "r119",
    "g0", "g1", "g2", "g3", "tp", "fp", "sp", "gz"
};

ArrayRef<const char *> PostriscTargetInfo::getGCCRegNames() const {
  return llvm::ArrayRef(GCCRegNames);
}

const TargetInfo::GCCRegAlias PostriscTargetInfo::GCCRegAliases[] = {
    {{"g4"}, "tp"}, {{"g5"}, "fp"}, {{"g6"}, "sp"}, {{"g7"}, "gz"}
};

ArrayRef<TargetInfo::GCCRegAlias> PostriscTargetInfo::getGCCRegAliases() const {
  return llvm::ArrayRef(GCCRegAliases);
}

bool
PostriscTargetInfo::validateAsmConstraint(const char *&Name,
                             TargetInfo::ConstraintInfo &info) const
{
  // FIXME: Implement!
  switch (*Name) {
    case 'I': // Signed 13-bit constant
    case 'J': // Zero
    case 'K': // 32-bit constant with the low 12 bits clear
    case 'L': // A constant in the range supported by movcc (11-bit signed imm)
    case 'M': // A constant in the range supported by movrcc (19-bit signed imm)
    case 'N': // Same as 'K' but zext (required for SIMode)
    case 'O': // The constant 4096
      return true;

    case 'f':
    case 'e':
      info.setAllowsRegister();
      return true;
    }
    return false;
}

std::string_view
PostriscTargetInfo::getClobbers() const
{
  // FIXME: Implement!
  return "";
}

bool PostriscTargetInfo::hasFeature(StringRef Feature) const {
  return llvm::StringSwitch<bool>(Feature)
      .Case("softfloat", SoftFloat)
      .Case("postrisc", true)
      .Default(false);
}

struct PostriscCPUInfo {
  llvm::StringLiteral Name;
  PostriscTargetInfo::CPUKind Kind;
  PostriscTargetInfo::CPUGeneration Generation;
};

static constexpr PostriscCPUInfo CPUInfo[] = {
    {{"pv1"}, PostriscTargetInfo::CK_V1, PostriscTargetInfo::CG_V1},
    {{"pv2"}, PostriscTargetInfo::CK_V2, PostriscTargetInfo::CG_V2},
};

PostriscTargetInfo::CPUGeneration
PostriscTargetInfo::getCPUGeneration(CPUKind Kind) const {
  if (Kind == CK_GENERIC)
    return CG_V1;
  const PostriscCPUInfo *Item = llvm::find_if(
      CPUInfo, [Kind](const PostriscCPUInfo &Info) { return Info.Kind == Kind; });
  if (Item == std::end(CPUInfo))
    llvm_unreachable("Unexpected CPU kind");
  return Item->Generation;
}

PostriscTargetInfo::CPUKind PostriscTargetInfo::getCPUKind(StringRef Name) const {
  const PostriscCPUInfo *Item = llvm::find_if(
      CPUInfo, [Name](const PostriscCPUInfo &Info) { return Info.Name == Name; });

  if (Item == std::end(CPUInfo))
    return CK_GENERIC;
  return Item->Kind;
}

void PostriscTargetInfo::fillValidCPUList(
    SmallVectorImpl<StringRef> &Values) const {
  for (const PostriscCPUInfo &Info : CPUInfo)
    Values.push_back(Info.Name);
}

void PostriscTargetInfo::getTargetDefines(const LangOptions &Opts,
                                       MacroBuilder &Builder) const {
  DefineStd(Builder, "postrisc", Opts);
  Builder.defineMacro("__REGISTER_PREFIX__", "");

  if (SoftFloat)
    Builder.defineMacro("SOFT_FLOAT", "1");
}

//===----------------------------------------------------------------------===//
//
// PostriscV1
//
//===----------------------------------------------------------------------===//
PostriscV1TargetInfo::PostriscV1TargetInfo(const llvm::Triple &Triple, const TargetOptions &Opts)
  : PostriscTargetInfo(Triple, Opts)
{
  resetDataLayout(
     "e"             // little-endian
     "-m:e"          // mangling is ELF
     "-S128"         // stack alignment 128-bit
     "-p:64:64:64"   // 64-bit pointers with 64-bit alignment
     "-i1:8:8"       // i1 is 8-bit (byte) aligned
     "-i8:8:8"       // i8 is 8-bit (byte) aligned as mandated
     "-i16:16:16"    // i16 is 16-bit aligned
     "-i32:32:32"    // i32 is 32-bit aligned
     "-i64:64:64"    // i64 is 64-bit aligned
     "-i128:128:128" // i128 is 128-bit aligned
     "-n64"          // native integers are 64-bit
     "-f16:16:16"    // half is 16-bit aligned
     "-f32:32:32"    // float is 32-bit aligned
     "-f64:64:64"    // double is 64-bit aligned
     "-f128:128:128" // quad is 128-bit aligned
     "-v128:128:128" // 128-bit vector is 128-bit aligned
     "-a:0:64"       // aggregates are 64-bit aligned
   );

  // This is an LP64 platform.
  LongWidth = LongAlign = 64;
  PointerWidth = PointerAlign = 64;

  // OpenBSD uses long long for int64_t and intmax_t.
  if (getTriple().isOSOpenBSD())
    IntMaxType = SignedLongLong;
  else
    IntMaxType = SignedLong;
  Int64Type = IntMaxType;

  // has long double 128-bits in size, 16-byte aligned.
  LongDoubleWidth = 128;
  LongDoubleAlign = 128;
  SuitableAlign = 128;
  LongDoubleFormat = &llvm::APFloat::IEEEquad();
  MaxAtomicPromoteWidth = MaxAtomicInlineWidth = 128;
}

void PostriscV1TargetInfo::getTargetDefines(const LangOptions &Opts,
                                         MacroBuilder &Builder) const {
  PostriscTargetInfo::getTargetDefines(Opts, Builder);
  Builder.defineMacro("__arch64__");
  Builder.defineMacro("__POSTRISC__");

  Builder.defineMacro("__FMA__");
  Builder.defineMacro("__FP_FAST_FMA");

  Builder.defineMacro("__GCC_HAVE_SYNC_COMPARE_AND_SWAP_1");
  Builder.defineMacro("__GCC_HAVE_SYNC_COMPARE_AND_SWAP_2");
  Builder.defineMacro("__GCC_HAVE_SYNC_COMPARE_AND_SWAP_4");
  Builder.defineMacro("__GCC_HAVE_SYNC_COMPARE_AND_SWAP_8");
  Builder.defineMacro("__GCC_HAVE_SYNC_COMPARE_AND_SWAP_16");
}

void PostriscV1TargetInfo::fillValidCPUList(
    SmallVectorImpl<StringRef> &Values) const {
  for (const PostriscCPUInfo &Info : CPUInfo)
    if (Info.Generation == CG_V1)
      Values.push_back(Info.Name);
}
