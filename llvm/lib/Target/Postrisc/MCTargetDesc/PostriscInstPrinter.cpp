//===-- PostriscInstPrinter.cpp - Convert Postrisc MCInst to assembly syntax -----==//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This class prints an Postrisc MCInst to a .s file.
//
//===----------------------------------------------------------------------===//

#include "PostriscInstPrinter.h"
#include "PostriscMCInstrInfo.h"
#include "Postrisc.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCCodeEmitter.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/Debug.h"
#include "llvm/CodeGen/TargetOpcodes.h"

using namespace llvm;

#define DEBUG_TYPE "asm-printer"

// The generated AsmMatcher PostriscGenAsmWriter uses "Postrisc" as the target
// namespace. But POSTRISC backend uses "POSTRISC" as its namespace.
namespace llvm {
namespace Postrisc {
  using namespace POSTRISC;
}
}

#define GET_INSTRUCTION_NAME
#define PRINT_ALIAS_INSTR
#include "PostriscGenAsmWriter.inc"

void PostriscInstPrinter::printRegName(raw_ostream &OS, MCRegister Reg) {
  OS << '%' << getRegisterName(Reg);
}

void PostriscInstPrinter::printInst(const MCInst *MI, uint64_t Address,
                                 StringRef Annot, const MCSubtargetInfo &STI,
                                 raw_ostream &O) {
  LLVM_DEBUG(dbgs() << "PIP::printInst: " << (*MI) << " Annot=" << Annot << "\n");
  assert (Postrisc::isBundle(*MI));
  O << "\t! BUNDLE\n";
  printAnnotation(O, Annot);
  for (auto const &I : Postrisc::bundleInstructions(*MI)) {
    MCInst const &MCI = *I.getInst();
    LLVM_DEBUG(dbgs() << "printInstruction(b): " << MCI << "\n");
    if (!printAliasInstr(&MCI, Address, STI, O) &&
        !printPostriscAliasInstr(&MCI, STI, O))
          printInstructionOrInlineAsm(MCI, Address, STI, O);
    O << "\n";
  }
}

void
PostriscInstPrinter::printInstructionOrInlineAsm(
  const MCInst &MI, uint64_t Address,
  const MCSubtargetInfo &STI, raw_ostream &O)
{

  if (getMnemonic(MI).second == 0) {
    return;
  }

  //if (MI->getOpcode() == TargetOpcode::INLINEASM) {
  //  assert(MI->getOperand(0).isExpr());
  //  O << "\t" << *MI->getOperand(0).getExpr();
  //} else {
    printInstruction(&MI, Address, STI, O);
  //}
}

bool PostriscInstPrinter::printPostriscAliasInstr(const MCInst *MI,
                                            const MCSubtargetInfo &STI,
                                            raw_ostream &O) {
  switch (MI->getOpcode()) {
  default: return false;
  }
}

void PostriscInstPrinter::printOperand(const MCInst *MI, int opNum,
                                    const MCSubtargetInfo &STI,
                                    raw_ostream &O) {
  const MCOperand &MO = MI->getOperand (opNum);

  if (MO.isReg()) {
    printRegName(O, MO.getReg());
    return ;
  }

  if (MO.isImm()) {
    O << (int64_t)MO.getImm();
    return;
  }

  assert(MO.isExpr() && "Unknown operand kind in printOperand");
  MAI.printExpr(O, *MO.getExpr());
}
