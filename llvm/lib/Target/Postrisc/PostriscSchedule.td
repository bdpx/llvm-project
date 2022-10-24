//=== PostriscSchedule.td - Describe the Postrisc Itineraries *- tablegen -*-=//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
//
//===----------------------------------------------------------------------===//


//Functional units
def ALU_X : FuncUnit;
def ALU_Y : FuncUnit;
def ALU_Z : FuncUnit;

//Instruction itinerary classes
def IIC_default          : InstrItinClass;
def IIC_iu_instr         : InstrItinClass;
def IIC_st               : InstrItinClass;
def IIC_jmp_or_call      : InstrItinClass;
def IIC_iu_or_fpu_instr  : InstrItinClass;
def IIC_fpu_normal_instr : InstrItinClass;
def IIC_fpu_fast_instr   : InstrItinClass;
def IIC_ldd              : InstrItinClass;
def IIC_std              : InstrItinClass;
def IIC_iu_smul          : InstrItinClass;
def IIC_iu_umul          : InstrItinClass;
def IIC_iu_div           : InstrItinClass;
def IIC_ticc             : InstrItinClass;
def IIC_fpu_muls         : InstrItinClass;
def IIC_fpu_muld         : InstrItinClass;
def IIC_fpu_divs         : InstrItinClass;
def IIC_fpu_divd         : InstrItinClass;
def IIC_fpu_sqrts        : InstrItinClass;
def IIC_fpu_sqrtd        : InstrItinClass;
def IIC_fpu_abs          : InstrItinClass;
def IIC_fpu_movs         : InstrItinClass;
def IIC_fpu_negs         : InstrItinClass;
def IIC_smac_umac        : InstrItinClass;
def IIC_fpu_stod         : InstrItinClass;

def PostriscItineraries : ProcessorItineraries<
  [ALU_X, ALU_Y, ALU_Z],
  [],
  [
      InstrItinData < IIC_default                 , [ InstrStage < 1, [ALU_X, ALU_Y, ALU_Z]> ] >,
      InstrItinData < IIC_iu_instr                , [ InstrStage < 1, [ALU_X, ALU_Y, ALU_Z]> ] >,
      InstrItinData < IIC_st                      , [ InstrStage < 1, [ALU_X, ALU_Y, ALU_Z]> ] >,
      InstrItinData < IIC_jmp_or_call             , [ InstrStage < 1, [ALU_X, ALU_Y, ALU_Z]> ] >,
      InstrItinData < IIC_iu_or_fpu_instr         , [ InstrStage < 1, [ALU_X, ALU_Y, ALU_Z]> ] >,
      InstrItinData < IIC_fpu_normal_instr        , [ InstrStage < 1, [ALU_X, ALU_Y, ALU_Z]> ] >,
      InstrItinData < IIC_fpu_fast_instr          , [ InstrStage < 1, [ALU_X, ALU_Y, ALU_Z]> ] >,
      InstrItinData < IIC_ldd                     , [ InstrStage < 1, [ALU_X, ALU_Y, ALU_Z]> ] >,
      InstrItinData < IIC_std                     , [ InstrStage < 1, [ALU_X, ALU_Y, ALU_Z]> ] >,
      InstrItinData < IIC_iu_smul                 , [ InstrStage < 1, [ALU_X, ALU_Y, ALU_Z]> ] >,
      InstrItinData < IIC_iu_umul                 , [ InstrStage < 1, [ALU_X, ALU_Y, ALU_Z]> ] >,
      InstrItinData < IIC_iu_div                  , [ InstrStage < 1, [ALU_X, ALU_Y, ALU_Z]> ] >,
      InstrItinData < IIC_ticc                    , [ InstrStage < 1, [ALU_X, ALU_Y, ALU_Z]> ] >,
      InstrItinData < IIC_fpu_muls                , [ InstrStage < 1, [ALU_X, ALU_Y, ALU_Z]> ] >,
      InstrItinData < IIC_fpu_muld                , [ InstrStage < 1, [ALU_X, ALU_Y, ALU_Z]> ] >,
      InstrItinData < IIC_fpu_divs                , [ InstrStage < 1, [ALU_X, ALU_Y, ALU_Z]> ] >,
      InstrItinData < IIC_fpu_divd                , [ InstrStage < 1, [ALU_X, ALU_Y, ALU_Z]> ] >,
      InstrItinData < IIC_fpu_sqrts               , [ InstrStage < 1, [ALU_X, ALU_Y, ALU_Z]> ] >,
      InstrItinData < IIC_fpu_sqrtd               , [ InstrStage < 1, [ALU_X, ALU_Y, ALU_Z]> ] >,
      InstrItinData < IIC_fpu_abs                 , [ InstrStage < 1, [ALU_X, ALU_Y, ALU_Z]> ] >,
      InstrItinData < IIC_fpu_movs                , [ InstrStage < 1, [ALU_X, ALU_Y, ALU_Z]> ] >,
      InstrItinData < IIC_fpu_negs                , [ InstrStage < 1, [ALU_X, ALU_Y, ALU_Z]> ] >,
      InstrItinData < IIC_smac_umac               , [ InstrStage < 1, [ALU_X, ALU_Y, ALU_Z]> ] >,
      InstrItinData < IIC_fpu_stod                , [ InstrStage < 1, [ALU_X, ALU_Y, ALU_Z]> ] >,
  ]
>;
