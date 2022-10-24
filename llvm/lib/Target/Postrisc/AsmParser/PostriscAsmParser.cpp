//===-- PostriscAsmParser.cpp - Parse Postrisc assembly to MCInst instructions --===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/PostriscMCAsmInfo.h"
#include "MCTargetDesc/PostriscMCTargetDesc.h"
#include "TargetInfo/PostriscTargetInfo.h"
#include "Postrisc.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/BinaryFormat/ELF.h"
#include "llvm/MC/MCAsmMacro.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCInstBuilder.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCObjectFileInfo.h"
#include "llvm/MC/MCParser/AsmLexer.h"
#include "llvm/MC/MCParser/MCAsmParser.h"
#include "llvm/MC/MCParser/MCParsedAsmOperand.h"
#include "llvm/MC/MCParser/MCTargetAsmParser.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/Support/Casting.h"
#include "llvm/Support/Compiler.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/MathExtras.h"
#include "llvm/Support/SMLoc.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/Debug.h"
#include "llvm/TargetParser/Triple.h"
#include <algorithm>
#include <cassert>
#include <cstdint>
#include <memory>

#define DEBUG_TYPE "postrisc-asmparser"

using namespace llvm;

// The generated AsmMatcher PostriscGenAsmMatcher uses "Postrisc" as the target
// namespace. But POSTRISC backend uses "POSTRISC" as its namespace.
namespace llvm {
namespace Postrisc {

    using namespace POSTRISC;

} // end namespace Postrisc
} // end namespace llvm

namespace {

class PostriscOperand;

class PostriscAsmParser : public MCTargetAsmParser {
  MCAsmParser &Parser;
  const MCRegisterInfo &MRI;
  MCInst MCB;
  int bundle_size = 0;

  enum class TailRelocKind { Load_GOT, Add_TLS, Load_TLS, Call_TLS };

  /// @name Auto-generated Match Functions
  /// {

#define GET_ASSEMBLER_HEADER
#include "PostriscGenAsmMatcher.inc"

  /// }

  // public interface of the MCTargetAsmParser.
  bool matchAndEmitInstruction(SMLoc IDLoc, unsigned &Opcode,
                               OperandVector &Operands, MCStreamer &Out,
                               uint64_t &ErrorInfo,
                               bool MatchingInlineAsm) override;
  bool parseRegister(MCRegister &Reg, SMLoc &StartLoc, SMLoc &EndLoc) override;
  ParseStatus tryParseRegister(MCRegister &Reg, SMLoc &StartLoc,
                               SMLoc &EndLoc) override;
  bool parseInstruction(ParseInstructionInfo &Info, StringRef Name,
                        SMLoc NameLoc, OperandVector &Operands) override;
  ParseStatus parseDirective(AsmToken DirectiveID) override;

  unsigned validateTargetOperandClass(MCParsedAsmOperand &Op,
                                      unsigned Kind) override;

  // Custom parse functions for Postrisc specific operands.
  bool matchOneInstruction(MCInst &MCB, SMLoc IDLoc,
                           OperandVector &Operands, uint64_t &ErrorInfo,
                           bool MatchingInlineAsm);

  ParseStatus parseOperand(OperandVector &Operands, StringRef Name);

  ParseStatus parsePostriscAsmOperand(std::unique_ptr<PostriscOperand> &Operand,
                                   bool isCall = false);

  // Helper function for dealing with %lo / %hi in PIC mode.
  const MCSpecifierExpr *adjustPICRelocation(Postrisc::Specifier VK,
                                             const MCExpr *subExpr);

  bool finishBundle(SMLoc IDLoc, MCStreamer &Out);
  // returns true if Tok is matched to a register and returns register in RegNo.
  bool matchRegisterName(const AsmToken &Tok, MCRegister &RegNo,
                         unsigned &RegKind);

  bool matchPostriscAsmModifiers(const MCExpr *&EVal, SMLoc &EndLoc);

  SMLoc getLoc() const { return getParser().getTok().getLoc(); }

public:
  PostriscAsmParser(const MCSubtargetInfo &sti, MCAsmParser &parser,
                 const MCInstrInfo &MII, const MCTargetOptions &Options)
      : MCTargetAsmParser(Options, sti, MII), Parser(parser),
        MRI(*Parser.getContext().getRegisterInfo()) {
    Parser.addAliasForDirective(".half", ".2byte");
    Parser.addAliasForDirective(".uahalf", ".2byte");
    Parser.addAliasForDirective(".word", ".4byte");
    Parser.addAliasForDirective(".uaword", ".4byte");
    Parser.addAliasForDirective(".nword", ".8byte");
    Parser.addAliasForDirective(".xword", ".8byte");

    // Initialize the set of available features.
    setAvailableFeatures(ComputeAvailableFeatures(getSTI().getFeatureBits()));
  }
};

/// PostriscOperand - Instances of this class represent a parsed Postrisc machine
/// instruction.
class PostriscOperand : public MCParsedAsmOperand {
public:
  enum RegisterKind {
    rk_None,
    rk_IntReg,
    rk_Special,
  };

private:
  enum KindTy {
    k_Token,
    k_Register,
    k_Immediate,
    k_MemoryReg,
    k_MemoryImm,
  } Kind;

  SMLoc StartLoc, EndLoc;

  struct Token {
    const char *Data;
    unsigned Length;
  };

  struct RegOp {
    unsigned RegNum;
    RegisterKind Kind;
  };

  struct ImmOp {
    const MCExpr *Val;
  };

  struct MemOp {
    unsigned Base;
    unsigned OffsetReg;
    const MCExpr *Off;
  };

  union {
    struct Token Tok;
    struct RegOp Reg;
    struct ImmOp Imm;
    struct MemOp Mem;
  };

public:
  PostriscOperand(KindTy K) : Kind(K) {}

  bool isToken() const override { return Kind == k_Token; }
  bool isReg() const override { return Kind == k_Register; }
  bool isImm() const override { return Kind == k_Immediate; }
  bool isMem() const override { return false; }
  bool isShiftAmtImm5() const {
    if (!isImm())
      return false;

    if (const MCConstantExpr *CE = dyn_cast<MCConstantExpr>(Imm.Val))
      return isUInt<5>(CE->getValue());

    return false;
  }

  bool isShiftAmtImm6() const {
    if (!isImm())
      return false;

    if (const MCConstantExpr *CE = dyn_cast<MCConstantExpr>(Imm.Val))
      return isUInt<6>(CE->getValue());

    return false;
  }

  bool isIntReg() const {
    return (Kind == k_Register && Reg.Kind == rk_IntReg);
  }

  StringRef getToken() const {
    assert(Kind == k_Token && "Invalid access!");
    return StringRef(Tok.Data, Tok.Length);
  }

  MCRegister getReg() const override {
    assert((Kind == k_Register) && "Invalid access!");
    return Reg.RegNum;
  }

  const MCExpr *getImm() const {
    assert((Kind == k_Immediate) && "Invalid access!");
    return Imm.Val;
  }

  unsigned getMemBase() const {
    assert((Kind == k_MemoryReg || Kind == k_MemoryImm) && "Invalid access!");
    return Mem.Base;
  }

  unsigned getMemOffsetReg() const {
    assert((Kind == k_MemoryReg) && "Invalid access!");
    return Mem.OffsetReg;
  }

  const MCExpr *getMemOff() const {
    assert((Kind == k_MemoryImm) && "Invalid access!");
    return Mem.Off;
  }

  /// getStartLoc - Get the location of the first token of this operand.
  SMLoc getStartLoc() const override {
    return StartLoc;
  }
  /// getEndLoc - Get the location of the last token of this operand.
  SMLoc getEndLoc() const override {
    return EndLoc;
  }

  void print(raw_ostream &OS, const MCAsmInfo &MAI) const override {
    switch (Kind) {
    case k_Token:     OS << "Token: " << getToken() << "\n"; break;
    case k_Register:  OS << "Reg: #" << getReg() << "\n"; break;
    case k_Immediate: OS << "Imm: " << getImm() << "\n"; break;
    case k_MemoryReg: OS << "Mem: " << getMemBase() << "+"
                         << getMemOffsetReg() << "\n"; break;
    case k_MemoryImm: assert(getMemOff() != nullptr);
      OS << "Mem: " << getMemBase() << "+";
      MAI.printExpr(OS, *getMemOff());
      OS << "\n";
      break;
    }
  }

  void addRegOperands(MCInst &Inst, unsigned N) const {
    assert(N == 1 && "Invalid number of operands!");
    Inst.addOperand(MCOperand::createReg(getReg()));
  }

  void addImmOperands(MCInst &Inst, unsigned N) const {
    assert(N == 1 && "Invalid number of operands!");
    const MCExpr *Expr = getImm();
    addExpr(Inst, Expr);
  }

  void addShiftAmtImm5Operands(MCInst &Inst, unsigned N) const {
    assert(N == 1 && "Invalid number of operands!");
    addExpr(Inst, getImm());
  }
  void addShiftAmtImm6Operands(MCInst &Inst, unsigned N) const {
    assert(N == 1 && "Invalid number of operands!");
    addExpr(Inst, getImm());
  }

  void addExpr(MCInst &Inst, const MCExpr *Expr) const{
    // Add as immediate when possible.  Null MCExpr = 0.
    LLVM_DEBUG(if (Expr) { dbgs() << "addExpr: "; Expr->dump(); dbgs() << "\n"; });
    if (!Expr)
      Inst.addOperand(MCOperand::createImm(0));
    else if (const MCConstantExpr *CE = dyn_cast<MCConstantExpr>(Expr))
      Inst.addOperand(MCOperand::createImm(CE->getValue()));
    else
      Inst.addOperand(MCOperand::createExpr(Expr));
  }

  static std::unique_ptr<PostriscOperand> CreateToken(StringRef Str, SMLoc S) {
    auto Op = std::make_unique<PostriscOperand>(k_Token);
    Op->Tok.Data = Str.data();
    Op->Tok.Length = Str.size();
    Op->StartLoc = S;
    Op->EndLoc = S;
    return Op;
  }

  static std::unique_ptr<PostriscOperand> CreateReg(unsigned RegNum, unsigned Kind,
                                                 SMLoc S, SMLoc E) {
    auto Op = std::make_unique<PostriscOperand>(k_Register);
    Op->Reg.RegNum = RegNum;
    Op->Reg.Kind   = (PostriscOperand::RegisterKind)Kind;
    Op->StartLoc = S;
    Op->EndLoc = E;
    return Op;
  }

  static std::unique_ptr<PostriscOperand> CreateImm(const MCExpr *Val, SMLoc S,
                                                 SMLoc E) {
    auto Op = std::make_unique<PostriscOperand>(k_Immediate);
    Op->Imm.Val = Val;
    Op->StartLoc = S;
    Op->EndLoc = E;
    return Op;
  }

};

} // end anonymous namespace

bool
PostriscAsmParser::finishBundle(SMLoc IDLoc, MCStreamer &Out)
{
  LLVM_DEBUG(dbgs() << "AP::finishBundle:" << MCB << "\n");
  MCB.setLoc(IDLoc);

  // const MCRegisterInfo *RI = getContext().getRegisterInfo();
  MCSubtargetInfo const &STI = getSTI();

  Out.emitInstruction(MCB, STI);
  return false; // No error
}
bool PostriscAsmParser::matchAndEmitInstruction(SMLoc IDLoc, unsigned &Opcode,
                                             OperandVector &Operands,
                                             MCStreamer &Out,
                                             uint64_t &ErrorInfo,
                                             bool MatchingInlineAsm) {
  if (bundle_size == 0) {
    MCB.clear();
    MCB.setOpcode(POSTRISC::BUNDLE);
    MCB.addOperand(MCOperand::createImm(0));
  }

  // PostriscOperand &FirstOperand = static_cast<PostriscOperand &>(*Operands[0]);
  MCInst *SubInst = getParser().getContext().createMCInst();
  if (matchOneInstruction(*SubInst, IDLoc, Operands, ErrorInfo, MatchingInlineAsm)) {
    return true;
  }

  const MCInstrDesc &Desc = MII.get(SubInst->getOpcode());
  if (postrisc::isLong(Desc.TSFlags)) {
    bundle_size += 2;
  } else {
    bundle_size += 1;
  }

  MCSubtargetInfo const &STI = getSTI();
  // for in-bundle instructions we need just visit instruction
  // and register symbols inside operands, so use parent version
  Out.MCStreamer::emitInstruction(*SubInst, STI);

  MCB.addOperand(MCOperand::createInst(SubInst));
  LLVM_DEBUG(dbgs() << "AP::Bundle:" << MCB << "\n");
  if (bundle_size == 3) {
    bundle_size = 0;
    return finishBundle(IDLoc, Out);
  }
  return false;
}

bool PostriscAsmParser::matchOneInstruction(MCInst &Inst, SMLoc IDLoc,
                                             OperandVector &Operands,
                                             uint64_t &ErrorInfo,
                                             bool MatchingInlineAsm) {
  unsigned MatchResult = MatchInstructionImpl(Operands, Inst, ErrorInfo,
                                              MatchingInlineAsm);
  switch (MatchResult) {
  case Match_Success: {
    Inst.setLoc(IDLoc);
    LLVM_DEBUG(dbgs() << "AP::MatchInstructionImpl: " << Inst << "\n");
    return false;
  }

  case Match_MissingFeature:
    return Error(IDLoc,
                 "instruction requires a CPU feature not currently enabled");

  case Match_InvalidOperand: {
    SMLoc ErrorLoc = IDLoc;
    if (ErrorInfo != ~0ULL) {
      if (ErrorInfo >= Operands.size())
        return Error(IDLoc, "too few operands for instruction");

      ErrorLoc = ((PostriscOperand &)*Operands[ErrorInfo]).getStartLoc();
      if (ErrorLoc == SMLoc())
        ErrorLoc = IDLoc;
    }

    return Error(ErrorLoc, "invalid operand for instruction");
  }
  case Match_MnemonicFail:
    return Error(IDLoc, "invalid instruction mnemonic");
  }
  llvm_unreachable("Implement any new match types added!");
}

bool PostriscAsmParser::parseRegister(MCRegister &Reg, SMLoc &StartLoc,
                                   SMLoc &EndLoc) {
  if (!tryParseRegister(Reg, StartLoc, EndLoc).isSuccess())
    return Error(StartLoc, "invalid register name");
  return false;
}

ParseStatus PostriscAsmParser::tryParseRegister(MCRegister &Reg, SMLoc &StartLoc,
                                             SMLoc &EndLoc) {
  const AsmToken &Tok = Parser.getTok();
  StartLoc = Tok.getLoc();
  EndLoc = Tok.getEndLoc();
  Reg = Postrisc::NoRegister;
  if (getLexer().getKind() != AsmToken::Percent)
    return ParseStatus::NoMatch;
  Parser.Lex();
  unsigned regKind = PostriscOperand::rk_None;
  if (matchRegisterName(Tok, Reg, regKind)) {
    Parser.Lex();
    return ParseStatus::Success;
  }

  getLexer().UnLex(Tok);
  return ParseStatus::NoMatch;
}

static void applyMnemonicAliases(StringRef &Mnemonic,
                                 const FeatureBitset &Features,
                                 unsigned VariantID);

bool PostriscAsmParser::parseInstruction(ParseInstructionInfo &Info,
                                      StringRef Name, SMLoc NameLoc,
                                      OperandVector &Operands) {

  // First operand in MCInst is instruction mnemonic.
  Operands.push_back(PostriscOperand::CreateToken(Name, NameLoc));

  // apply mnemonic aliases, if any, so that we can parse operands correctly.
  applyMnemonicAliases(Name, getAvailableFeatures(), 0);

  if (getLexer().isNot(AsmToken::EndOfStatement)) {
    // Read the first operand.
    if (!parseOperand(Operands, Name).isSuccess()) {
      SMLoc Loc = getLexer().getLoc();
      return Error(Loc, "unexpected token");
    }

    while (getLexer().is(AsmToken::Comma) || getLexer().is(AsmToken::Plus)) {
      if (getLexer().is(AsmToken::Plus)) {
      // Plus tokens are significant in software_traps (p83, postriscv8.pdf). We must capture them.
        Operands.push_back(PostriscOperand::CreateToken("+", Parser.getTok().getLoc()));
      }
      Parser.Lex(); // Eat the comma or plus.
      // Parse and remember the operand.
      if (!parseOperand(Operands, Name).isSuccess()) {
        SMLoc Loc = getLexer().getLoc();
        return Error(Loc, "unexpected token");
      }
    }
  }
  if (getLexer().isNot(AsmToken::EndOfStatement)) {
    SMLoc Loc = getLexer().getLoc();
    return Error(Loc, "unexpected token");
  }
  Parser.Lex(); // Consume the EndOfStatement.
  return false;
}

ParseStatus PostriscAsmParser::parseDirective(AsmToken DirectiveID) {
  StringRef IDVal = DirectiveID.getString();

  if (IDVal == ".register") {
    // For now, ignore .register directive.
    Parser.eatToEndOfStatement();
    return ParseStatus::Success;
  }
  if (IDVal == ".proc") {
    // For compatibility, ignore this directive.
    // (It's supposed to be an "optimization" in the Sun assembler)
    Parser.eatToEndOfStatement();
    return ParseStatus::Success;
  }

  // Let the MC layer to handle other directives.
  return ParseStatus::NoMatch;
}

ParseStatus PostriscAsmParser::parseOperand(OperandVector &Operands,
                                         StringRef Mnemonic) {

  ParseStatus Res;
#if 0
  Res = MatchOperandParserImpl(Operands, Mnemonic);

  // If there wasn't a custom match, try the generic matcher below. Otherwise,
  // there was a match, but an error occurred, in which case, just return that
  // the operand parsing failed.
  if (Res.isSuccess() || Res.isFailure())
    return Res;
#endif

  if (getLexer().is(AsmToken::LBrac)) {
    // Memory operand
    Operands.push_back(PostriscOperand::CreateToken("[",
                                                 Parser.getTok().getLoc()));
    Parser.Lex(); // Eat the [

    if (Mnemonic == "cas" || Mnemonic == "casx" || Mnemonic == "casa") {
      SMLoc S = Parser.getTok().getLoc();
      if (getLexer().getKind() != AsmToken::Percent)
        return ParseStatus::NoMatch;
      Parser.Lex(); // eat %

      MCRegister RegNo;
      unsigned RegKind;
      if (!matchRegisterName(Parser.getTok(), RegNo, RegKind))
        return ParseStatus::NoMatch;

      Parser.Lex(); // Eat the identifier token.
      SMLoc E = SMLoc::getFromPointer(Parser.getTok().getLoc().getPointer()-1);
      Operands.push_back(PostriscOperand::CreateReg(RegNo, RegKind, S, E));
      Res = ParseStatus::Success;
    } else {
      return ParseStatus::Failure;
      //Res = parseMEMOperand(Operands);
    }

    if (!Res.isSuccess())
      return Res;

    if (!getLexer().is(AsmToken::RBrac))
      return ParseStatus::Failure;

    Operands.push_back(PostriscOperand::CreateToken("]",
                                                 Parser.getTok().getLoc()));
    Parser.Lex(); // Eat the ]

    // Parse an optional address-space identifier after the address.
    if (getLexer().is(AsmToken::Integer)) {
      std::unique_ptr<PostriscOperand> Op;
      Res = parsePostriscAsmOperand(Op, false);
      if (!Res.isSuccess() || !Op)
        return ParseStatus::Failure;
      Operands.push_back(std::move(Op));
    }
    return ParseStatus::Success;
  }

  std::unique_ptr<PostriscOperand> Op;

  Res = parsePostriscAsmOperand(Op, (Mnemonic == "call"));
  if (!Res.isSuccess() || !Op)
    return ParseStatus::Failure;

  // Push the parsed operand into the list of operands
  Operands.push_back(std::move(Op));

  return ParseStatus::Success;
}

ParseStatus
PostriscAsmParser::parsePostriscAsmOperand(std::unique_ptr<PostriscOperand> &Op,
                                     bool isCall) {
  SMLoc S = Parser.getTok().getLoc();
  SMLoc E = SMLoc::getFromPointer(Parser.getTok().getLoc().getPointer() - 1);
  const MCExpr *EVal;

  Op = nullptr;
  switch (getLexer().getKind()) {
  default:  break;

  case AsmToken::Percent: {
    Parser.Lex(); // Eat the '%'.
    MCRegister Reg;
    unsigned RegKind;
    if (matchRegisterName(Parser.getTok(), Reg, RegKind)) {
      // StringRef Name = Parser.getTok().getString();
      Parser.Lex(); // Eat the identifier token.
      E = SMLoc::getFromPointer(Parser.getTok().getLoc().getPointer() - 1);
      switch (Reg) {
      default:
        Op = PostriscOperand::CreateReg(Reg, RegKind, S, E);
        break;
      //case Postrisc::itc:
      //  Op = PostriscOperand::CreateToken("%itc", S);
      //  break;
      }
      break;
    }
    if (matchPostriscAsmModifiers(EVal, E)) {
      E = SMLoc::getFromPointer(Parser.getTok().getLoc().getPointer() - 1);
      Op = PostriscOperand::CreateImm(EVal, S, E);
      // LLVM_DEBUG(dbgs() << "parsePostriscAsmOperand: Op=" << (*Op.get()) << " EVal=" << (*EVal) << "\n");
    }
    break;
  }

  case AsmToken::Plus:
  case AsmToken::Minus:
  case AsmToken::Integer:
  case AsmToken::LParen:
  case AsmToken::Dot:
    if (!getParser().parseExpression(EVal, E))
      Op = PostriscOperand::CreateImm(EVal, S, E);
    break;

  case AsmToken::Identifier: {
    LLVM_DEBUG(dbgs() << "AsmToken::Identifier\n");
    StringRef Identifier;
    if (!getParser().parseIdentifier(Identifier)) {
      LLVM_DEBUG(dbgs() << "AsmToken::Identifier=" << Identifier << "\n");
      E = SMLoc::getFromPointer(Parser.getTok().getLoc().getPointer() - 1);
      MCSymbol *Sym = getContext().getOrCreateSymbol(Identifier);

      LLVM_DEBUG(dbgs() << "Sym=" << *Sym << "\n");

      const MCExpr *Res = MCSymbolRefExpr::create(Sym, getContext());
      Postrisc::Specifier Kind = Postrisc::S_NONE;

      if (getContext().getObjectFileInfo()->isPositionIndependent()) {
        if (isCall)
          Kind = Postrisc::S_JUMP;
        else
          Kind = Postrisc::S_PCREL_FWD;
      }

      Res = MCSpecifierExpr::create(Res, Kind, getContext());

      Op = PostriscOperand::CreateImm(Res, S, E);
    } else {
      LLVM_DEBUG(dbgs() << "AsmToken::Identifier=unknown\n");
    }
    break;
  }
  }
  return Op ? ParseStatus::Success : ParseStatus::Failure;
}

bool PostriscAsmParser::matchRegisterName(const AsmToken &Tok, MCRegister &RegNo,
                                       unsigned &RegKind) {
  const unsigned notFound = 0xFFFFFFFF;
  RegNo = 0;
  RegKind = PostriscOperand::rk_None;
  if (!Tok.is(AsmToken::Identifier)) {
    return false;
  }

  StringRef name = Tok.getString();

#define X(NAME) .Case(#NAME, Postrisc::NAME)
  RegNo = StringSwitch<unsigned>(name) GENERAL_REGISTERS_CASES(X) .Default(notFound);
  if (RegNo != notFound) {
    RegKind = PostriscOperand::rk_IntReg;
    return true;
  }

  RegNo = StringSwitch<unsigned>(name) SPECIAL_REGISTERS_CASES(X) .Default(notFound);
  if (RegNo != notFound) {
    RegKind = PostriscOperand::rk_Special;
    return true;
  }
#undef X

  return false;
}

// Determine if an expression contains a reference to the symbol
// "_GLOBAL_OFFSET_TABLE_".
static bool hasGOTReference(const MCExpr *Expr) {
  switch (Expr->getKind()) {
  case MCExpr::Target:
    if (const MCSpecifierExpr *SE = dyn_cast<MCSpecifierExpr>(Expr))
      return hasGOTReference(SE->getSubExpr());
    break;

  case MCExpr::Constant:
    break;

  case MCExpr::Binary: {
    const MCBinaryExpr *BE = cast<MCBinaryExpr>(Expr);
    return hasGOTReference(BE->getLHS()) || hasGOTReference(BE->getRHS());
  }

  case MCExpr::SymbolRef: {
    const MCSymbolRefExpr &SymRef = *cast<MCSymbolRefExpr>(Expr);
    return (SymRef.getSymbol().getName() == "_GLOBAL_OFFSET_TABLE_");
  }

  case MCExpr::Unary:
    return hasGOTReference(cast<MCUnaryExpr>(Expr)->getSubExpr());

  case MCExpr::Specifier:
    llvm_unreachable("unused by this backend");
  }
  return false;
}

const MCSpecifierExpr *
PostriscAsmParser::adjustPICRelocation(Postrisc::Specifier VK,
                                    const MCExpr *subExpr) {
  return MCSpecifierExpr::create(subExpr, VK, getContext());
}

bool PostriscAsmParser::matchPostriscAsmModifiers(const MCExpr *&EVal,
                                            SMLoc &EndLoc) {
  AsmToken Tok = Parser.getTok();
  if (!Tok.is(AsmToken::Identifier))
    return false;

  StringRef name = Tok.getString();

  Postrisc::Specifier VK = Postrisc::parseSpecifier(name);
  switch (VK) {
  case Postrisc::S_NONE:
    Error(getLoc(), "invalid operand modifier");
    return false;

  case Postrisc::S_TLS_GD_CALL:
    // These are special-cased at tablegen level.
    return false;

  default:
    LLVM_DEBUG(dbgs() << "matchPostriscAsmModifiers:Specifier=" << (int)VK << "\n");
    break;
  }

  Parser.Lex(); // Eat the identifier.
  if (Parser.getTok().getKind() != AsmToken::LParen)
    return false;

  Parser.Lex(); // Eat the LParen token.
  const MCExpr *subExpr = nullptr;
  if (Parser.parseParenExpression(subExpr, EndLoc))
    return false;
  // LLVM_DEBUG(dbgs() << "matchPostriscAsmModifiers=" << (*subExpr) << "\n");

  EVal = adjustPICRelocation(VK, subExpr);
  return true;
}

extern "C" LLVM_ABI LLVM_EXTERNAL_VISIBILITY void LLVMInitializePostriscAsmParser() {
  RegisterMCAsmParser<PostriscAsmParser> A(getThePostriscTarget());
}

#define GET_REGISTER_MATCHER
#define GET_MATCHER_IMPLEMENTATION
#include "PostriscGenAsmMatcher.inc"

// Allow a target to add special case operand matching for things that
// tblgen doesn't/can't handle effectively. For example, literal
// immediates on ARM. TableGen expects a token operand, but the parser
// will recognize them as immediates.
unsigned PostriscAsmParser::validateTargetOperandClass(MCParsedAsmOperand &GOp,
                                                    unsigned Kind) {
  return Match_InvalidOperand;
}
