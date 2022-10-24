//===-- PostriscProcessors.td - POSTRISC Processor Definitions ---*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// POSTRISC processors supported.
//===----------------------------------------------------------------------===//

class Proc<string Name, list<SubtargetFeature> Features,
           list<SubtargetFeature> TuneFeatures = []>
 : Processor<Name, NoItineraries, Features, TuneFeatures>;

def : Proc<"generic",         []>;

def : Proc<"postrisc", [FeatureSIMD]>;

def : Proc<"v1",  [FeatureV1, FeatureSIMD]>;
def : Proc<"v2",  [FeatureV1, FeatureV2, FeatureSIMD]>;

