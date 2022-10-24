//===-- Postrisc.td - Describe the Postrisc Target Machine -------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Target-independent interfaces which we are implementing
//===----------------------------------------------------------------------===//

include "llvm/Target/Target.td"
include "llvm/TableGen/SearchableTable.td"

include "PostriscFeatures.td"

//===----------------------------------------------------------------------===//
// Register File, Calling Conv, Instruction Descriptions
//===----------------------------------------------------------------------===//

include "PostriscInstrEncoding.td"
include "PostriscRegisterInfo.td"
include "PostriscCallingConv.td"
include "PostriscSchedule.td"
include "PostriscInstrFormats.td"
include "PostriscInstrInfo.td"
include "PostriscInstrInfoBitwise.td"
include "PostriscInstrInfoShift.td"
include "PostriscInstrInfoLoadStore.td"
include "PostriscInstrInfoCondBranch.td"
include "PostriscInstrInfoCondMove.td"
include "PostriscInstrInfoNullification.td"
include "PostriscInstrInfoSpecial.td"
include "PostriscInstrInfoAtomic.td"
include "PostriscInstrInfoFloat.td"
include "PostriscInstrInfoSIMD.td"
include "PostriscInstrInfoMisc.td"

defm : RemapAllTargetPseudoPointerOperands<GR>;

def PostriscInstrInfo : InstrInfo;

def PostriscAsmParser : AsmParser {
  let ShouldEmitMatchRegisterName = true;
  let ShouldEmitMatchRegisterAltName = true;
  let AllowDuplicateRegisterNames = true;
}

def PostriscAsmParserVariant : AsmParserVariant {
  let RegisterPrefix = "%";
}

include "PostriscProcessors.td"

//===----------------------------------------------------------------------===//
// Declare the target which we are implementing
//===----------------------------------------------------------------------===//

def PostriscAsmWriter : AsmWriter {
  string AsmWriterClassName  = "InstPrinter";
  int PassSubtarget = 1;
  int Variant = 0;
}

def Postrisc : Target {
  // Pull in Instruction Info:
  let InstructionSet = PostriscInstrInfo;
  let AssemblyParsers  = [PostriscAsmParser];
  let AssemblyParserVariants = [PostriscAsmParserVariant];
  let AssemblyWriters = [PostriscAsmWriter];
  let AllowRegisterRenaming = 1;
}
