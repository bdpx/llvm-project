//===-- PostriscFeatures.td - Describe the Postrisc Features -------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// POSTRISC Subtarget features.
//
//

//===----------------------------------------------------------------------===//

def FeatureV1
  : SubtargetFeature<"v1", "IsV1", "true",
                     "Enable POSTRISC-V1 instructions">;
def FeatureV2
  : SubtargetFeature<"v2", "IsV2", "true",
                     "Enable POSTRISC-V2 instructions">;

def FeatureSIMD : SubtargetFeature<"simd", "HasSIMD", "true",
                     "Enable SIMD Instruction Set extensions">;

def FeatureSoftFloat : SubtargetFeature<"soft-float", "UseSoftFloat", "false",
                              "Use software emulation for floating point">;

//===----------------------------------------------------------------------===//
// POSTRISC Subtarget tuning features.
//

def TuneNoPredictor : SubtargetFeature<"no-predictor", "HasNoPredictor", "false",
                                    "Processor has no branch predictor, branches stall execution", []>;

//==== Features added predmoninantly for POSTRISC subtarget support

