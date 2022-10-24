//===-- PostriscAsmPrinter.cpp - Postrisc LLVM assembly writer ------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains a printer that converts from our internal representation
// of machine-dependent LLVM code to GAS-format POSTRISC assembly language.
// NOTE:
// The AsmPrinter doesn't make any changes of emitted code to not break bundling
// only real instructions are allowed, any pseudos should be lowered before
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/PostriscInstPrinter.h"
#include "MCTargetDesc/PostriscMCExpr.h"
#include "MCTargetDesc/PostriscMCTargetDesc.h"
#include "MCTargetDesc/PostriscTargetStreamer.h"
#include "Postrisc.h"
#include "PostriscInstrInfo.h"
#include "PostriscTargetMachine.h"
#include "TargetInfo/PostriscTargetInfo.h"
#include "llvm/CodeGen/AsmPrinter.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/MachineModuleInfoImpls.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/TargetLoweringObjectFileImpl.h"
#include "llvm/IR/Mangler.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/Debug.h"

using namespace llvm;

#define DEBUG_TYPE "asm-printer"

namespace {
  class PostriscAsmPrinter : public AsmPrinter {
    PostriscTargetStreamer &getTargetStreamer() {
      return static_cast<PostriscTargetStreamer &>(
          *OutStreamer->getTargetStreamer());
    }
  public:
    explicit PostriscAsmPrinter(TargetMachine &TM,
                             std::unique_ptr<MCStreamer> Streamer)
        : AsmPrinter(TM, std::move(Streamer), ID) {}

    StringRef getPassName() const override { return "Postrisc Assembly Printer"; }

    void printOperand(const MachineInstr *MI, int opNum, raw_ostream &OS);
    void printMemOperand(const MachineInstr *MI, int opNum, raw_ostream &OS);

    void emitFunctionBodyStart() override;
    void emitInstruction(const MachineInstr *MI) override;

    static const char *getRegisterName(MCRegister Reg) {
      return PostriscInstPrinter::getRegisterName(Reg);
    }

    bool PrintAsmOperand(const MachineInstr *MI, unsigned OpNo,
                         const char *ExtraCode, raw_ostream &O) override;
    bool PrintAsmMemoryOperand(const MachineInstr *MI, unsigned OpNo,
                               const char *ExtraCode, raw_ostream &O) override;

public:
  static char ID;
};
} // end of anonymous namespace

void PostriscAsmPrinter::emitInstruction(const MachineInstr *MI) {
  MCInst MCB;
  MCB.setOpcode(POSTRISC::BUNDLE);
  MCB.addOperand(MCOperand::createImm(0));
  // const PostriscnstrInfo &MCII = *Subtarget->getInstrInfo();

  assert(MI->isBundle());
  const MachineBasicBlock* MBB = MI->getParent();
  MachineBasicBlock::const_instr_iterator MII = MI->getIterator();

  for (++MII; MII != MBB->instr_end() && MII->isInsideBundle(); ++MII) {
    LLVM_DEBUG(dbgs() << "AP::emitInstruction(loop): " << *MII << "\n");
    if (!(!MII->isDebugInstr() && !MII->isImplicitDef())) {
        dbgs() << "AP::emitInstruction(loop): " << *MII << "\n";
    }
    assert(!MII->isDebugInstr() && !MII->isImplicitDef());
    LLVM_DEBUG(dbgs() << "AP::emitInstruction(bundle)\n");
    MCInst *MCI = OutContext.createMCInst();
    LowerPostriscMachineInstrToMCInst(&*MII, *MCI, *this);
    // for in-bundle instructions we need just visit instruction
    // and register symbols inside operands, so use parent version
    OutStreamer->MCStreamer::emitInstruction(*MCI, getSubtargetInfo());
    MCB.addOperand(MCOperand::createInst(MCI));
  }
  EmitToStreamer(*OutStreamer, MCB);
}

void PostriscAsmPrinter::emitFunctionBodyStart() {
  if (!MF->getSubtarget<PostriscSubtarget>().is64Bit())
    return;

  const MachineRegisterInfo &MRI = MF->getRegInfo();
  const unsigned globalRegs[] = {
    POSTRISC::g2, POSTRISC::g3, POSTRISC::fp, POSTRISC::sp, POSTRISC::tp, 0
  };
  for (unsigned i = 0; globalRegs[i] != 0; ++i) {
    unsigned reg = globalRegs[i];
    if (MRI.use_empty(reg))
      continue;

    if  (reg == POSTRISC::g3 || reg == POSTRISC::tp)
      getTargetStreamer().emitPostriscRegisterIgnore(reg);
    else
      getTargetStreamer().emitPostriscRegisterScratch(reg);
  }
}

void PostriscAsmPrinter::printOperand(const MachineInstr *MI, int opNum,
                                   raw_ostream &O) {
  const DataLayout &DL = getDataLayout();
  const MachineOperand &MO = MI->getOperand (opNum);
  PostriscMCExpr::Specifier TF = (PostriscMCExpr::Specifier) MO.getTargetFlags();

  bool CloseParen = PostriscMCExpr::printSpecifier(O, TF);

  switch (MO.getType()) {
  case MachineOperand::MO_Register:
    O << "%" << StringRef(getRegisterName(MO.getReg())).lower();
    break;

  case MachineOperand::MO_Immediate:
    O << MO.getImm();
    break;
  case MachineOperand::MO_MachineBasicBlock:
    MO.getMBB()->getSymbol()->print(O, MAI);
    return;
  case MachineOperand::MO_GlobalAddress:
    PrintSymbolOperand(MO, O);
    break;
  case MachineOperand::MO_BlockAddress:
    O <<  GetBlockAddressSymbol(MO.getBlockAddress())->getName();
    break;
  case MachineOperand::MO_ExternalSymbol:
    O << MO.getSymbolName();
    break;
  case MachineOperand::MO_ConstantPoolIndex:
    O << DL.getPrivateGlobalPrefix() << "CPI" << getFunctionNumber() << "_"
      << MO.getIndex();
    break;
  case MachineOperand::MO_JumpTableIndex:
    O << DL.getPrivateGlobalPrefix() << "JTI" << getFunctionNumber() << '_' << MO.getIndex();
    // O << MO.getSymbolName();
    // Symbol = AP.GetJTISymbol(MO.getIndex());
    break;
  case MachineOperand::MO_Metadata:
    MO.getMetadata()->printAsOperand(O, MMI->getModule());
    break;
  default:
    llvm_unreachable("<unknown operand type>");
  }
  if (CloseParen) O << ")";
}

void PostriscAsmPrinter::printMemOperand(const MachineInstr *MI, int opNum,
                                      raw_ostream &O) {
  printOperand(MI, opNum, O);

  if (MI->getOperand(opNum+1).isReg() &&
      MI->getOperand(opNum+1).getReg() == POSTRISC::g0)
    return;   // don't print "+%g0"
  if (MI->getOperand(opNum+1).isImm() &&
      MI->getOperand(opNum+1).getImm() == 0)
    return;   // don't print "+0"

  O << "+";
  printOperand(MI, opNum+1, O);
}

/// PrintAsmOperand - Print out an operand for an inline asm expression.
///
bool PostriscAsmPrinter::PrintAsmOperand(const MachineInstr *MI, unsigned OpNo,
                                      const char *ExtraCode,
                                      raw_ostream &O) {
  if (ExtraCode && ExtraCode[0]) {
    if (ExtraCode[1] != 0) return true; // Unknown modifier.

    switch (ExtraCode[0]) {
    default:
      // See if this is a generic print operand
      return AsmPrinter::PrintAsmOperand(MI, OpNo, ExtraCode, O);
    case 'f':
    case 'r':
     break;
    }
  }

  printOperand(MI, OpNo, O);

  return false;
}

bool PostriscAsmPrinter::PrintAsmMemoryOperand(const MachineInstr *MI,
                                            unsigned OpNo,
                                            const char *ExtraCode,
                                            raw_ostream &O) {
  if (ExtraCode && ExtraCode[0])
    return true;  // Unknown modifier

  O << '[';
  printMemOperand(MI, OpNo, O);
  O << ']';

  return false;
}

char PostriscAsmPrinter::ID = 0;

INITIALIZE_PASS(PostriscAsmPrinter, "postrisc-asm-printer", "Postrisc Assembly Printer",
                false, false)

// Force static initialization.
extern "C" LLVM_EXTERNAL_VISIBILITY void LLVMInitializePostriscAsmPrinter() {
  RegisterAsmPrinter<PostriscAsmPrinter> X(getThePostriscTarget());
}
