//===-- PostriscMCInstLower.cpp - Convert Postrisc MachineInstr to MCInst -------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains code to lower Postrisc MachineInstrs to their corresponding
// MCInst records.
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/PostriscMCExpr.h"
#include "Postrisc.h"
#include "llvm/CodeGen/AsmPrinter.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/MachineOperand.h"
#include "llvm/IR/Mangler.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInst.h"
#include "llvm/Support/Debug.h"

#define DEBUG_TYPE "postrisc-mclower"

using namespace llvm;


static MCOperand LowerSymbolOperand(const MachineInstr *MI,
                                    const MachineOperand &MO,
                                    AsmPrinter &AP) {

  PostriscMCExpr::Specifier Kind = (PostriscMCExpr::Specifier)MO.getTargetFlags();
  const MCSymbol *Symbol = nullptr;
  int64_t Offset = 0;

  switch(MO.getType()) {
  default:
    LLVM_DEBUG(dbgs() << "unknown MO.getType()=" << (unsigned)MO.getType() << "\n");
    llvm_unreachable("Unknown type in LowerSymbolOperand");
  case MachineOperand::MO_MachineBasicBlock:
    Symbol = MO.getMBB()->getSymbol();
    LLVM_DEBUG(dbgs() << "LowerSymbolOperand:MachineBasicBlock=" << *Symbol << "\n");
    break;

  case MachineOperand::MO_GlobalAddress:
    Symbol = AP.getSymbol(MO.getGlobal());
    LLVM_DEBUG(dbgs() << "LowerSymbolOperand:GlobalAddress=" << *Symbol << "\n");
    Offset += MO.getOffset();
    break;

  case MachineOperand::MO_BlockAddress:
    Symbol = AP.GetBlockAddressSymbol(MO.getBlockAddress());
    LLVM_DEBUG(dbgs() << "LowerSymbolOperand:BlockAddress=" << *Symbol << "\n");
    Offset += MO.getOffset();
    break;

  case MachineOperand::MO_ExternalSymbol:
    Symbol = AP.GetExternalSymbolSymbol(MO.getSymbolName());
    LLVM_DEBUG(dbgs() << "LowerSymbolOperand:ExternalSymbol=" << *Symbol << "\n");
    Offset += MO.getOffset();
    break;

  case MachineOperand::MO_ConstantPoolIndex:
    Symbol = AP.GetCPISymbol(MO.getIndex());
    LLVM_DEBUG(dbgs() << "LowerSymbolOperand:ConstantPoolSymbol=" << *Symbol << "\n");
    Offset += MO.getOffset();
    break;

  case MachineOperand::MO_JumpTableIndex:
    Symbol = AP.GetJTISymbol(MO.getIndex());
    LLVM_DEBUG(dbgs() << "LowerSymbolOperand:JumpTableIndex=" << *Symbol << "\n");
    break;

  case MachineOperand::MO_MCSymbol:
    Symbol = MO.getMCSymbol();
    LLVM_DEBUG(dbgs() << "LowerSymbolOperand:MCSymbol=" << *Symbol << "\n");
    Offset += MO.getOffset();
    break;
  }

  const MCExpr *MCSym = MCSymbolRefExpr::create(Symbol,
                                                         AP.OutContext);

  if (Offset != 0) {
    LLVM_DEBUG(dbgs() << "LowerSymbolOperand: offset=" << Offset << "\n");
    MCSym = MCBinaryExpr::createAdd(
       MCSym,
       MCConstantExpr::create(MO.getOffset(), AP.OutContext),
       AP.OutContext);
  }
  LLVM_DEBUG(dbgs() << "LowerSymbolOperand: Symbol=" << *Symbol << " MCSym=" << *MCSym << "\n");
  const PostriscMCExpr *expr = PostriscMCExpr::create(Kind, MCSym,
                                                AP.OutContext);
  return MCOperand::createExpr(expr);
}

static MCOperand LowerOperand(const MachineInstr *MI,
                              const MachineOperand &MO,
                              AsmPrinter &AP) {
  LLVM_DEBUG(dbgs() << "MO.getType()=" << (unsigned)MO.getType() << "\n");
  switch(MO.getType()) {
  default:
    LLVM_DEBUG(dbgs() << "unknown MO.getType()=" << (unsigned)MO.getType() << "\n");
    llvm_unreachable("unknown operand type");
    break;
  case MachineOperand::MO_Register:
    if (MO.isImplicit())
      break;
    return MCOperand::createReg(MO.getReg());

  case MachineOperand::MO_Immediate:
    return MCOperand::createImm(MO.getImm());

  case MachineOperand::MO_MachineBasicBlock:
  case MachineOperand::MO_GlobalAddress:
  case MachineOperand::MO_BlockAddress:
  case MachineOperand::MO_ExternalSymbol:
  case MachineOperand::MO_ConstantPoolIndex:
  case MachineOperand::MO_MCSymbol:
  case MachineOperand::MO_JumpTableIndex:
    return LowerSymbolOperand(MI, MO, AP);

  case MachineOperand::MO_RegisterMask:   break;

  case MachineOperand::MO_Metadata:
    LLVM_DEBUG(dbgs() << "MO_Metadata: MI=" << *MI << " MO=" << MO << "\n");
    break;
  }
  return MCOperand();
}

void llvm::LowerPostriscMachineInstrToMCInst(const MachineInstr *MI,
                                          MCInst &OutMI,
                                          AsmPrinter &AP)
{

  OutMI.setOpcode(MI->getOpcode());

  for (const MachineOperand &MO : MI->operands()) {
    MCOperand MCOp = LowerOperand(MI, MO, AP);

    if (MCOp.isValid())
      OutMI.addOperand(MCOp);
  }
}
