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

//===----------------------------------------------------------------------===//
// POSTRISC Subtarget features.
//

def FeatureSIMD : SubtargetFeature<"simd", "HasSIMD", "true",
                     "Enable SIMD Instruction Set extensions">;

def FeatureSoftFloat : SubtargetFeature<"soft-float", "UseSoftFloat", "false",
                              "Use software emulation for floating point">;

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
  bit ShouldEmitMatchRegisterName = 0;
}

//===----------------------------------------------------------------------===//
// POSTRISC processors supported.
//===----------------------------------------------------------------------===//

class Proc<string Name, list<SubtargetFeature> Features>
 : Processor<Name, NoItineraries, Features>;

def : Proc<"generic",         []>;

def : Processor<"postrisc", PostriscItineraries,
                [FeatureSIMD]>;

def : Processor<"pv1",      PostriscItineraries,
                [FeatureSIMD]>;

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
  let AssemblyWriters = [PostriscAsmWriter];
  let AllowRegisterRenaming = 1;
}
