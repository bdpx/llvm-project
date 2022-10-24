//===---- PostriscInstrSIMD.td - Visual Instruction Set extensions (VIS) --===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains instruction formats, definitions and patterns needed for
// SIMD instructions on POSTRISC.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Feature predicates.
//===----------------------------------------------------------------------===//

// HasSIMD - This is true when the target processor has SIMD extensions.
def HasSIMD : Predicate<"Subtarget->HasSIMD()">,
             AssemblerPredicate<(all_of FeatureSIMD)>;

//===----------------------------------------------------------------------===//
// SIMD vector types are bit convertible to each other, f128, i128
//===----------------------------------------------------------------------===//
multiclass
vector_bitconversion<ValueType Ty, ValueType Ta>
{
  def : Pat<(Ty (bitconvert Ta:$val)),  (COPY_TO_REGCLASS $val, GR)>;
  def : Pat<(Ta (bitconvert Ty:$val)),  (COPY_TO_REGCLASS $val, GR)>;
}

defm : vector_bitconversion<v16i8, f128>;
defm : vector_bitconversion<v16i8, i128>;
defm : vector_bitconversion<v8i16, f128>;
defm : vector_bitconversion<v8i16, i128>;
defm : vector_bitconversion<v4i32, f128>;
defm : vector_bitconversion<v4i32, i128>;
defm : vector_bitconversion<v2i64, f128>;
defm : vector_bitconversion<v2i64, i128>;

defm : vector_bitconversion<v16i8, v8i16>;
defm : vector_bitconversion<v16i8, v4i32>;
defm : vector_bitconversion<v16i8, v2i64>;
defm : vector_bitconversion<v8i16, v4i32>;
defm : vector_bitconversion<v8i16, v2i64>;
defm : vector_bitconversion<v4i32, v2i64>;

defm : vector_bitconversion<v8i16, v8f16>;
defm : vector_bitconversion<v4i32, v4f32>;
defm : vector_bitconversion<v2i64, v2f64>;

//===----------------------------------------------------------------------===//
// SIMD vector types are bit convertible to corresponding scalars
//===----------------------------------------------------------------------===//
/*
def : Pat<(i64 (bitconvert v2i64:$val)), (COPY_TO_REGCLASS $val, GR)>;
def : Pat<(i32 (bitconvert v4i32:$val)), (COPY_TO_REGCLASS $val, GR)>;
def : Pat<(f64 (bitconvert v2f64:$val)), (COPY_TO_REGCLASS $val, GR)>;
def : Pat<(f32 (bitconvert v4f32:$val)), (COPY_TO_REGCLASS $val, GR)>;
*/

//===----------------------------------------------------------------------===//
// AES (v2i64)
//===----------------------------------------------------------------------===//
defm AESIMC     : BUILTIN_R2<opcode_aesimc,     int_postrisc_aesimc,     v2i64, v2i64>;
defm AESENC     : BUILTIN_R3<opcode_aesenc,     int_postrisc_aesenc,     v2i64, v2i64, v2i64>;
defm AESENCLAST : BUILTIN_R3<opcode_aesenclast, int_postrisc_aesenclast, v2i64, v2i64, v2i64>;
defm AESDEC     : BUILTIN_R3<opcode_aesdec,     int_postrisc_aesdec,     v2i64, v2i64, v2i64>;
defm AESDECLAST : BUILTIN_R3<opcode_aesdeclast, int_postrisc_aesdeclast, v2i64, v2i64, v2i64>;

def round_constant : Operand<i32>, TImmLeaf<i32, [{ return isUInt<10>(Imm); }]> {
  let DecoderMethod = "DecodeUIMM<10>";
}
def AESKEYGENASSIST : MISC_RabI10<opcode_aeskeygenassist,
              (outs GR:$ra), (ins GR:$rb, round_constant:$imm),
              !strconcat(opcode_aeskeygenassist.mnem, " $ra, $rb, $imm"),
              [(set v2i64:$ra, (int_postrisc_aeskeygenassist v2i64:$rb, i32:$imm))]>;

//===----------------------------------------------------------------------===//
// carry-less multiply
//===----------------------------------------------------------------------===//
def CLMUL : MISC_RabcScale<opcode_clmul, (outs GR:$ra), (ins GR:$rb, GR:$rc, scale:$scale),
                             !strconcat(opcode_clmul.mnem, " $ra, $rb, $rc, $scale"), []>;

def : Pat<(v2i64 (int_postrisc_clmul_ll v2i64:$rb, v2i64:$rc)), (CLMUL GR:$rb, GR:$rc, (i32 0))>;
def : Pat<(v2i64 (int_postrisc_clmul_hl v2i64:$rb, v2i64:$rc)), (CLMUL GR:$rb, GR:$rc, (i32 1))>;
def : Pat<(v2i64 (int_postrisc_clmul_hh v2i64:$rb, v2i64:$rc)), (CLMUL GR:$rb, GR:$rc, (i32 3))>;

//===----------------------------------------------------------------------===//
// CRC
//===----------------------------------------------------------------------===//
defm CRC32CB : BUILTIN_R3<opcode_crc32cb, int_postrisc_crc32cb, i32, i32, i32>;
defm CRC32CH : BUILTIN_R3<opcode_crc32ch, int_postrisc_crc32ch, i32, i32, i32>;
defm CRC32CW : BUILTIN_R3<opcode_crc32cw, int_postrisc_crc32cw, i32, i32, i32>;
defm CRC32CD : BUILTIN_R3<opcode_crc32cd, int_postrisc_crc32cd, i32, i32, i64>;
defm CRC32CQ : BUILTIN_R3<opcode_crc32cq, int_postrisc_crc32cq, i32, i32, i128>;

//===----------------------------------------------------------------------===//
// integer
// signed average: ceiled (A+B+1)/2
// unsigned average, ceiled (A+B+1)/2
//===----------------------------------------------------------------------===//

defm VADDB     : BUILTIN_R3<opcode_vaddb,     int_postrisc_vaddb,     v16i8, v16i8, v16i8>;
defm VSUBB     : BUILTIN_R3<opcode_vsubb,     int_postrisc_vsubb,     v16i8, v16i8, v16i8>;
defm VADDCB    : BUILTIN_R3<opcode_vaddcb,    int_postrisc_vaddcb,    v16i8, v16i8, v16i8>;
defm VSUBCB    : BUILTIN_R3<opcode_vsubcb,    int_postrisc_vsubcb,    v16i8, v16i8, v16i8>;
defm VADDOB    : BUILTIN_R3<opcode_vaddob,    int_postrisc_vaddob,    v16i8, v16i8, v16i8>;
defm VSUBOB    : BUILTIN_R3<opcode_vsubob,    int_postrisc_vsubob,    v16i8, v16i8, v16i8>;
defm VADDSSATB : BUILTIN_R3<opcode_vaddssatb, int_postrisc_vaddssatb, v16i8, v16i8, v16i8>;
defm VSUBSSATB : BUILTIN_R3<opcode_vsubssatb, int_postrisc_vsubssatb, v16i8, v16i8, v16i8>;
defm VADDUSATB : BUILTIN_R3<opcode_vaddusatb, int_postrisc_vaddusatb, v16i8, v16i8, v16i8>;
defm VSUBUSATB : BUILTIN_R3<opcode_vsubusatb, int_postrisc_vsubusatb, v16i8, v16i8, v16i8>;
defm VCMPEQB   : BUILTIN_R3<opcode_vcmpeqb,   int_postrisc_vcmpeqb,   v16i8, v16i8, v16i8>;
defm VCMPLTSB  : BUILTIN_R3<opcode_vcmpltsb,  int_postrisc_vcmpltsb,  v16i8, v16i8, v16i8>;
defm VCMPLTUB  : BUILTIN_R3<opcode_vcmpltub,  int_postrisc_vcmpltub,  v16i8, v16i8, v16i8>;
defm VAVGSB    : BUILTIN_R3<opcode_vavgsb,    int_postrisc_vavgsb,    v16i8, v16i8, v16i8>;
defm VAVGUB    : BUILTIN_R3<opcode_vavgub,    int_postrisc_vavgub,    v16i8, v16i8, v16i8>;
defm VMINSB    : BUILTIN_R3<opcode_vminsb,    int_postrisc_vminsb,    v16i8, v16i8, v16i8>;
defm VMAXSB    : BUILTIN_R3<opcode_vmaxsb,    int_postrisc_vmaxsb,    v16i8, v16i8, v16i8>;
defm VMINUB    : BUILTIN_R3<opcode_vminub,    int_postrisc_vminub,    v16i8, v16i8, v16i8>;
defm VMAXUB    : BUILTIN_R3<opcode_vmaxub,    int_postrisc_vmaxub,    v16i8, v16i8, v16i8>;
defm VSLLB     : BUILTIN_R3<opcode_vsllb,     int_postrisc_vsllb,     v16i8, v16i8, v16i8>;
defm VSRLB     : BUILTIN_R3<opcode_vsrlb,     int_postrisc_vsrlb,     v16i8, v16i8, v16i8>;
defm VSRAB     : BUILTIN_R3<opcode_vsrab,     int_postrisc_vsrab,     v16i8, v16i8, v16i8>;
defm VMERGELB  : BUILTIN_R3<opcode_vmergelb,  int_postrisc_vmergelb,  v16i8, v16i8, v16i8>;
defm VMERGEHB  : BUILTIN_R3<opcode_vmergehb,  int_postrisc_vmergehb,  v16i8, v16i8, v16i8>;

defm VADDH     : BUILTIN_R3<opcode_vaddh,     int_postrisc_vaddh,     v8i16, v8i16, v8i16>;
defm VSUBH     : BUILTIN_R3<opcode_vsubh,     int_postrisc_vsubh,     v8i16, v8i16, v8i16>;
defm VADDCH    : BUILTIN_R3<opcode_vaddch,    int_postrisc_vaddch,    v8i16, v8i16, v8i16>;
defm VSUBCH    : BUILTIN_R3<opcode_vsubch,    int_postrisc_vsubch,    v8i16, v8i16, v8i16>;
defm VADDOH    : BUILTIN_R3<opcode_vaddoh,    int_postrisc_vaddoh,    v8i16, v8i16, v8i16>;
defm VSUBOH    : BUILTIN_R3<opcode_vsuboh,    int_postrisc_vsuboh,    v8i16, v8i16, v8i16>;
defm VADDSSATH : BUILTIN_R3<opcode_vaddssath, int_postrisc_vaddssath, v8i16, v8i16, v8i16>;
defm VSUBSSATH : BUILTIN_R3<opcode_vsubssath, int_postrisc_vsubssath, v8i16, v8i16, v8i16>;
defm VADDUSATH : BUILTIN_R3<opcode_vaddusath, int_postrisc_vaddusath, v8i16, v8i16, v8i16>;
defm VSUBUSATH : BUILTIN_R3<opcode_vsubusath, int_postrisc_vsubusath, v8i16, v8i16, v8i16>;
defm VCMPEQH   : BUILTIN_R3<opcode_vcmpeqh,   int_postrisc_vcmpeqh,   v8i16, v8i16, v8i16>;
defm VCMPLTSH  : BUILTIN_R3<opcode_vcmpltsh,  int_postrisc_vcmpltsh,  v8i16, v8i16, v8i16>;
defm VCMPLTUH  : BUILTIN_R3<opcode_vcmpltuh,  int_postrisc_vcmpltuh,  v8i16, v8i16, v8i16>;
defm VAVGSH    : BUILTIN_R3<opcode_vavgsh,    int_postrisc_vavgsh,    v8i16, v8i16, v8i16>;
defm VAVGUH    : BUILTIN_R3<opcode_vavguh,    int_postrisc_vavguh,    v8i16, v8i16, v8i16>;
defm VMINSH    : BUILTIN_R3<opcode_vminsh,    int_postrisc_vminsh,    v8i16, v8i16, v8i16>;
defm VMAXSH    : BUILTIN_R3<opcode_vmaxsh,    int_postrisc_vmaxsh,    v8i16, v8i16, v8i16>;
defm VMINUH    : BUILTIN_R3<opcode_vminuh,    int_postrisc_vminuh,    v8i16, v8i16, v8i16>;
defm VMAXUH    : BUILTIN_R3<opcode_vmaxuh,    int_postrisc_vmaxuh,    v8i16, v8i16, v8i16>;
defm VSLLH     : BUILTIN_R3<opcode_vsllh,     int_postrisc_vsllh,     v8i16, v8i16, v8i16>;
defm VSRLH     : BUILTIN_R3<opcode_vsrlh,     int_postrisc_vsrlh,     v8i16, v8i16, v8i16>;
defm VSRAH     : BUILTIN_R3<opcode_vsrah,     int_postrisc_vsrah,     v8i16, v8i16, v8i16>;
defm VMERGELH  : BUILTIN_R3<opcode_vmergelh,  int_postrisc_vmergelh,  v8i16, v8i16, v8i16>;
defm VMERGEHH  : BUILTIN_R3<opcode_vmergehh,  int_postrisc_vmergehh,  v8i16, v8i16, v8i16>;

defm VADDW     : BUILTIN_R3<opcode_vaddw,     int_postrisc_vaddw,     v4i32, v4i32, v4i32>;
defm VSUBW     : BUILTIN_R3<opcode_vsubw,     int_postrisc_vsubw,     v4i32, v4i32, v4i32>;
defm VADDCW    : BUILTIN_R3<opcode_vaddcw,    int_postrisc_vaddcw,    v4i32, v4i32, v4i32>;
defm VSUBCW    : BUILTIN_R3<opcode_vsubcw,    int_postrisc_vsubcw,    v4i32, v4i32, v4i32>;
defm VADDOW    : BUILTIN_R3<opcode_vaddow,    int_postrisc_vaddow,    v4i32, v4i32, v4i32>;
defm VSUBOW    : BUILTIN_R3<opcode_vsubow,    int_postrisc_vsubow,    v4i32, v4i32, v4i32>;
defm VADDSSATW : BUILTIN_R3<opcode_vaddssatw, int_postrisc_vaddssatw, v4i32, v4i32, v4i32>;
defm VSUBSSATW : BUILTIN_R3<opcode_vsubssatw, int_postrisc_vsubssatw, v4i32, v4i32, v4i32>;
defm VADDUSATW : BUILTIN_R3<opcode_vaddusatw, int_postrisc_vaddusatw, v4i32, v4i32, v4i32>;
defm VSUBUSATW : BUILTIN_R3<opcode_vsubusatw, int_postrisc_vsubusatw, v4i32, v4i32, v4i32>;
defm VCMPEQW   : BUILTIN_R3<opcode_vcmpeqw,   int_postrisc_vcmpeqw,   v4i32, v4i32, v4i32>;
defm VCMPLTSW  : BUILTIN_R3<opcode_vcmpltsw,  int_postrisc_vcmpltsw,  v4i32, v4i32, v4i32>;
defm VCMPLTUW  : BUILTIN_R3<opcode_vcmpltuw,  int_postrisc_vcmpltuw,  v4i32, v4i32, v4i32>;
defm VAVGSW    : BUILTIN_R3<opcode_vavgsw,    int_postrisc_vavgsw,    v4i32, v4i32, v4i32>;
defm VAVGUW    : BUILTIN_R3<opcode_vavguw,    int_postrisc_vavguw,    v4i32, v4i32, v4i32>;
defm VMINSW    : BUILTIN_R3<opcode_vminsw,    int_postrisc_vminsw,    v4i32, v4i32, v4i32>;
defm VMAXSW    : BUILTIN_R3<opcode_vmaxsw,    int_postrisc_vmaxsw,    v4i32, v4i32, v4i32>;
defm VMINUW    : BUILTIN_R3<opcode_vminuw,    int_postrisc_vminuw,    v4i32, v4i32, v4i32>;
defm VMAXUW    : BUILTIN_R3<opcode_vmaxuw,    int_postrisc_vmaxuw,    v4i32, v4i32, v4i32>;
defm VSLLW     : BUILTIN_R3<opcode_vsllw,     int_postrisc_vsllw,     v4i32, v4i32, v4i32>;
defm VSRLW     : BUILTIN_R3<opcode_vsrlw,     int_postrisc_vsrlw,     v4i32, v4i32, v4i32>;
defm VSRAW     : BUILTIN_R3<opcode_vsraw,     int_postrisc_vsraw,     v4i32, v4i32, v4i32>;
defm VMERGELW  : BUILTIN_R3<opcode_vmergelw,  int_postrisc_vmergelw,  v4i32, v4i32, v4i32>;
defm VMERGEHW  : BUILTIN_R3<opcode_vmergehw,  int_postrisc_vmergehw,  v4i32, v4i32, v4i32>;

defm VADDD     : BUILTIN_R3<opcode_vaddd,     int_postrisc_vaddd,     v2i64, v2i64, v2i64>;
defm VSUBD     : BUILTIN_R3<opcode_vsubd,     int_postrisc_vsubd,     v2i64, v2i64, v2i64>;
defm VADDCD    : BUILTIN_R3<opcode_vaddcd,    int_postrisc_vaddcd,    v2i64, v2i64, v2i64>;
defm VSUBCD    : BUILTIN_R3<opcode_vsubcd,    int_postrisc_vsubcd,    v2i64, v2i64, v2i64>;
defm VADDOD    : BUILTIN_R3<opcode_vaddod,    int_postrisc_vaddod,    v2i64, v2i64, v2i64>;
defm VSUBOD    : BUILTIN_R3<opcode_vsubod,    int_postrisc_vsubod,    v2i64, v2i64, v2i64>;
defm VADDSSATD : BUILTIN_R3<opcode_vaddssatd, int_postrisc_vaddssatd, v2i64, v2i64, v2i64>;
defm VSUBSSATD : BUILTIN_R3<opcode_vsubssatd, int_postrisc_vsubssatd, v2i64, v2i64, v2i64>;
defm VADDUSATD : BUILTIN_R3<opcode_vaddusatd, int_postrisc_vaddusatd, v2i64, v2i64, v2i64>;
defm VSUBUSATD : BUILTIN_R3<opcode_vsubusatd, int_postrisc_vsubusatd, v2i64, v2i64, v2i64>;
defm VCMPEQD   : BUILTIN_R3<opcode_vcmpeqd,   int_postrisc_vcmpeqd,   v2i64, v2i64, v2i64>;
defm VCMPLTSD  : BUILTIN_R3<opcode_vcmpltsd,  int_postrisc_vcmpltsd,  v2i64, v2i64, v2i64>;
defm VCMPLTUD  : BUILTIN_R3<opcode_vcmpltud,  int_postrisc_vcmpltud,  v2i64, v2i64, v2i64>;
defm VAVGSD    : BUILTIN_R3<opcode_vavgsd,    int_postrisc_vavgsd,    v2i64, v2i64, v2i64>;
defm VAVGUD    : BUILTIN_R3<opcode_vavgud,    int_postrisc_vavgud,    v2i64, v2i64, v2i64>;
defm VMINSD    : BUILTIN_R3<opcode_vminsd,    int_postrisc_vminsd,    v2i64, v2i64, v2i64>;
defm VMINUD    : BUILTIN_R3<opcode_vminud,    int_postrisc_vminud,    v2i64, v2i64, v2i64>;
defm VMAXSD    : BUILTIN_R3<opcode_vmaxsd,    int_postrisc_vmaxsd,    v2i64, v2i64, v2i64>;
defm VMAXUD    : BUILTIN_R3<opcode_vmaxud,    int_postrisc_vmaxud,    v2i64, v2i64, v2i64>;
defm VSLLD     : BUILTIN_R3<opcode_vslld,     int_postrisc_vslld,     v2i64, v2i64, v2i64>;
defm VSRLD     : BUILTIN_R3<opcode_vsrld,     int_postrisc_vsrld,     v2i64, v2i64, v2i64>;
defm VSRAD     : BUILTIN_R3<opcode_vsrad,     int_postrisc_vsrad,     v2i64, v2i64, v2i64>;
defm VMERGELD  : BUILTIN_R3<opcode_vmergeld,  int_postrisc_vmergeld,  v2i64, v2i64, v2i64>;
defm VMERGEHD  : BUILTIN_R3<opcode_vmergehd,  int_postrisc_vmergehd,  v2i64, v2i64, v2i64>;

defm VSLPB : BUILTIN_R4<opcode_vslpb, int_postrisc_vslpb, v16i8, v16i8, v16i8, v16i8>;
defm VSLPH : BUILTIN_R4<opcode_vslph, int_postrisc_vslph, v8i16, v8i16, v8i16, v8i16>;
defm VSLPW : BUILTIN_R4<opcode_vslpw, int_postrisc_vslpw, v4i32, v4i32, v4i32, v4i32>;
defm VSLPD : BUILTIN_R4<opcode_vslpd, int_postrisc_vslpd, v2i64, v2i64, v2i64, v2i64>;

defm VSRPB : BUILTIN_R4<opcode_vsrpb, int_postrisc_vsrpb, v16i8, v16i8, v16i8, v16i8>;
defm VSRPH : BUILTIN_R4<opcode_vsrph, int_postrisc_vsrph, v8i16, v8i16, v8i16, v8i16>;
defm VSRPW : BUILTIN_R4<opcode_vsrpw, int_postrisc_vsrpw, v4i32, v4i32, v4i32, v4i32>;
defm VSRPD : BUILTIN_R4<opcode_vsrpd, int_postrisc_vsrpd, v2i64, v2i64, v2i64, v2i64>;

multiclass
SIMD_Patterns<InstBase ADD, InstBase SUB,
             InstBase SMIN, InstBase SMAX, InstBase UMIN, InstBase UMAX,
             InstBase SAVG, InstBase UAVG,
             InstBase SADDSAT, InstBase SSUBSAT, InstBase UADDSAT, InstBase USUBSAT,
             InstBase SLL, InstBase SRL, InstBase SRA, InstBase SLP, InstBase SRP,
             ValueType Ty>
{
    def : Pat<(Ty (add      Ty:$rb, Ty:$rc)), (ADD GR:$rb, GR:$rc)>;
    def : Pat<(Ty (sub      Ty:$rb, Ty:$rc)), (SUB GR:$rb, GR:$rc)>;
    def : Pat<(Ty (shl      Ty:$rb, Ty:$rc)), (SLL GR:$rb, GR:$rc)>;
    def : Pat<(Ty (srl      Ty:$rb, Ty:$rc)), (SRL GR:$rb, GR:$rc)>;
    def : Pat<(Ty (sra      Ty:$rb, Ty:$rc)), (SRA GR:$rb, GR:$rc)>;
    def : Pat<(Ty (smin     Ty:$rb, Ty:$rc)), (SMIN GR:$rb, GR:$rc)>;
    def : Pat<(Ty (smax     Ty:$rb, Ty:$rc)), (SMAX GR:$rb, GR:$rc)>;
    def : Pat<(Ty (umin     Ty:$rb, Ty:$rc)), (UMIN GR:$rb, GR:$rc)>;
    def : Pat<(Ty (umax     Ty:$rb, Ty:$rc)), (UMAX GR:$rb, GR:$rc)>;
    def : Pat<(Ty (avgceils Ty:$rb, Ty:$rc)), (SAVG GR:$rb, GR:$rc)>;
    def : Pat<(Ty (avgceilu Ty:$rb, Ty:$rc)), (UAVG GR:$rb, GR:$rc)>;
    def : Pat<(Ty (saddsat  Ty:$rb, Ty:$rc)), (SADDSAT GR:$rb, GR:$rc)>;
    def : Pat<(Ty (ssubsat  Ty:$rb, Ty:$rc)), (SSUBSAT GR:$rb, GR:$rc)>;
    def : Pat<(Ty (uaddsat  Ty:$rb, Ty:$rc)), (UADDSAT GR:$rb, GR:$rc)>;
    def : Pat<(Ty (usubsat  Ty:$rb, Ty:$rc)), (USUBSAT GR:$rb, GR:$rc)>;

    def : Pat<(Ty (rotl Ty:$rb, Ty:$rc        )), (SLP GR:$rb, GR:$rb, GR:$rc)>;
    def : Pat<(Ty (rotr Ty:$rb, Ty:$rc        )), (SRP GR:$rb, GR:$rb, GR:$rc)>;
    def : Pat<(Ty (fshl Ty:$rb, Ty:$rc, Ty:$rd)), (SLP GR:$rb, GR:$rc, GR:$rd)>;
    def : Pat<(Ty (fshr Ty:$rb, Ty:$rc, Ty:$rd)), (SRP GR:$rb, GR:$rc, GR:$rd)>;
}

defm : SIMD_Patterns<VADDB, VSUBB, VMINSB, VMAXSB, VMINUB, VMAXUB, VAVGSB, VAVGUB, VADDSSATB, VSUBSSATB, VADDUSATB, VSUBUSATB, VSLLB, VSRLB, VSRAB, VSLPB, VSRPB, v16i8>;
defm : SIMD_Patterns<VADDH, VSUBH, VMINSH, VMAXSH, VMINUH, VMAXUH, VAVGSH, VAVGUH, VADDSSATH, VSUBSSATH, VADDUSATH, VSUBUSATH, VSLLH, VSRLH, VSRAH, VSLPH, VSRPH, v8i16>;
defm : SIMD_Patterns<VADDW, VSUBW, VMINSW, VMAXSW, VMINUW, VMAXUW, VAVGSW, VAVGUW, VADDSSATW, VSUBSSATW, VADDUSATW, VSUBUSATW, VSLLW, VSRLW, VSRAW, VSLPW, VSRPW, v4i32>;
defm : SIMD_Patterns<VADDD, VSUBD, VMINSD, VMAXSD, VMINUD, VMAXUD, VAVGSD, VAVGUD, VADDSSATD, VSUBSSATD, VADDUSATD, VSUBUSATD, VSLLD, VSRLD, VSRAD, VSLPD, VSRPD, v2i64>;

//===----------------------------------------------------------------------===//
// integer SIMD immediate shifts
// note: build_imm_vector_64 requires explicit i64 immediates
//===----------------------------------------------------------------------===//
multiclass SIMD_SHIFT_IMM<misc_opx Opc, ClangBuiltin Builtin, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : MISC_RabSc<Opc, (outs GR:$ra), (ins GR:$rb, uimm7:$shcnt),
        !strconcat(Opc.mnem, " $ra, $rb, $shcnt"),
        [(set Ty:$ra, (Builtin Ty:$rb, i32:$shcnt))], itin>;
}

defm VSRAID : SIMD_SHIFT_IMM<opcode_vsraid, int_postrisc_vsraid, v2i64>;
defm VSLLID : SIMD_SHIFT_IMM<opcode_vsllid, int_postrisc_vsllid, v2i64>;
defm VSRLID : SIMD_SHIFT_IMM<opcode_vsrlid, int_postrisc_vsrlid, v2i64>;

def build_imm_vector_64 : PatFrag<(ops node:$imm), (v2i64 (build_vector
          node:$imm, node:$imm))>;

def cast_shift_i64_to_i32 : SDNodeXForm<imm, [{
  return getU32Imm(N->getZExtValue(), SDLoc(N));
}]>;

def : Pat<(v2i64 (shl v2i64:$rb, (build_imm_vector_64 uimm7i64:$shcnt))), (VSLLID GR:$rb, (cast_shift_i64_to_i32 $shcnt))>;
def : Pat<(v2i64 (srl v2i64:$rb, (build_imm_vector_64 uimm7i64:$shcnt))), (VSRLID GR:$rb, (cast_shift_i64_to_i32 $shcnt))>;
def : Pat<(v2i64 (sra v2i64:$rb, (build_imm_vector_64 uimm7i64:$shcnt))), (VSRAID GR:$rb, (cast_shift_i64_to_i32 $shcnt))>;

defm VSRAIW : SIMD_SHIFT_IMM<opcode_vsraiw, int_postrisc_vsraiw, v4i32>;
defm VSLLIW : SIMD_SHIFT_IMM<opcode_vslliw, int_postrisc_vslliw, v4i32>;
defm VSRLIW : SIMD_SHIFT_IMM<opcode_vsrliw, int_postrisc_vsrliw, v4i32>;

def build_imm_vector_32 : PatFrag<(ops node:$imm), (v4i32 (build_vector
          node:$imm, node:$imm, node:$imm, node:$imm))>;

def : Pat<(v4i32 (shl v4i32:$rb, (build_imm_vector_32 uimm7:$shcnt))), (VSLLIW GR:$rb, uimm7:$shcnt)>;
def : Pat<(v4i32 (srl v4i32:$rb, (build_imm_vector_32 uimm7:$shcnt))), (VSRLIW GR:$rb, uimm7:$shcnt)>;
def : Pat<(v4i32 (sra v4i32:$rb, (build_imm_vector_32 uimm7:$shcnt))), (VSRAIW GR:$rb, uimm7:$shcnt)>;

defm VSRAIH : SIMD_SHIFT_IMM<opcode_vsraih, int_postrisc_vsraih, v8i16>;
defm VSLLIH : SIMD_SHIFT_IMM<opcode_vsllih, int_postrisc_vsllih, v8i16>;
defm VSRLIH : SIMD_SHIFT_IMM<opcode_vsrlih, int_postrisc_vsrlih, v8i16>;

def build_imm_vector_16 : PatFrag<(ops node:$imm), (v8i16 (build_vector
          node:$imm, node:$imm, node:$imm, node:$imm,
          node:$imm, node:$imm, node:$imm, node:$imm))>;

def : Pat<(v8i16 (shl v8i16:$rb, (build_imm_vector_16 uimm7:$shcnt))), (VSLLIH GR:$rb, uimm7:$shcnt)>;
def : Pat<(v8i16 (srl v8i16:$rb, (build_imm_vector_16 uimm7:$shcnt))), (VSRLIH GR:$rb, uimm7:$shcnt)>;
def : Pat<(v8i16 (sra v8i16:$rb, (build_imm_vector_16 uimm7:$shcnt))), (VSRAIH GR:$rb, uimm7:$shcnt)>;

defm VSRAIB : SIMD_SHIFT_IMM<opcode_vsraib, int_postrisc_vsraib, v16i8>;
defm VSLLIB : SIMD_SHIFT_IMM<opcode_vsllib, int_postrisc_vsllib, v16i8>;
defm VSRLIB : SIMD_SHIFT_IMM<opcode_vsrlib, int_postrisc_vsrlib, v16i8>;

def build_imm_vector_8  : PatFrag<(ops node:$imm), (v16i8 (build_vector
          node:$imm, node:$imm, node:$imm, node:$imm,
          node:$imm, node:$imm, node:$imm, node:$imm,
          node:$imm, node:$imm, node:$imm, node:$imm,
          node:$imm, node:$imm, node:$imm, node:$imm))>;

def : Pat<(v16i8 (shl v16i8:$rb, (build_imm_vector_8 uimm7:$shcnt))), (VSLLIB GR:$rb, uimm7:$shcnt)>;
def : Pat<(v16i8 (srl v16i8:$rb, (build_imm_vector_8 uimm7:$shcnt))), (VSRLIB GR:$rb, uimm7:$shcnt)>;
def : Pat<(v16i8 (sra v16i8:$rb, (build_imm_vector_8 uimm7:$shcnt))), (VSRAIB GR:$rb, uimm7:$shcnt)>;

//===----------------------------------------------------------------------===//
// immediate funnel shifts
//===----------------------------------------------------------------------===//
multiclass SIMD_FUSED_SHIFT_IMM<fused_opx opx, ClangBuiltin Builtin,
                    ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : FUSED_Rabcd<opx,
                 (outs GR:$ra), (ins GR:$rb, GR:$rc, uimm7:$rd),
                 !strconcat(opx.mnem, " $ra, $rb, $rc, $rd"),
                 [(set Ty:$ra, (Builtin Ty:$rb, Ty:$rc, i32:$rd))],
                 itin>;
}

defm VSRPIB : SIMD_FUSED_SHIFT_IMM<opcode_vsrpib, int_postrisc_vsrpib, v16i8>;
defm VSRPIH : SIMD_FUSED_SHIFT_IMM<opcode_vsrpih, int_postrisc_vsrpih, v8i16>;
defm VSRPIW : SIMD_FUSED_SHIFT_IMM<opcode_vsrpiw, int_postrisc_vsrpiw, v4i32>;
defm VSRPID : SIMD_FUSED_SHIFT_IMM<opcode_vsrpid, int_postrisc_vsrpid, v2i64>;

def : Pat<(v16i8 (fshr v16i8:$rb, v16i8:$rc, (build_imm_vector_8  uimm7   :$shcnt))), (VSRPIB GR:$rb, GR:$rc, uimm7:$shcnt)>;
def : Pat<(v8i16 (fshr v8i16:$rb, v8i16:$rc, (build_imm_vector_16 uimm7   :$shcnt))), (VSRPIH GR:$rb, GR:$rc, uimm7:$shcnt)>;
def : Pat<(v4i32 (fshr v4i32:$rb, v4i32:$rc, (build_imm_vector_32 uimm7   :$shcnt))), (VSRPIW GR:$rb, GR:$rc, uimm7:$shcnt)>;
def : Pat<(v2i64 (fshr v2i64:$rb, v2i64:$rc, (build_imm_vector_64 uimm7i64:$shcnt))), (VSRPID GR:$rb, GR:$rc, (cast_shift_i64_to_i32 $shcnt))>;

// model immediate rotate-right a special immediate funnel-right
def : Pat<(v16i8 (rotr v16i8:$rb, (build_imm_vector_8  uimm7   :$shcnt))), (VSRPIB GR:$rb, GR:$rb, uimm7:$shcnt)>;
def : Pat<(v8i16 (rotr v8i16:$rb, (build_imm_vector_16 uimm7   :$shcnt))), (VSRPIH GR:$rb, GR:$rb, uimm7:$shcnt)>;
def : Pat<(v4i32 (rotr v4i32:$rb, (build_imm_vector_32 uimm7   :$shcnt))), (VSRPIW GR:$rb, GR:$rb, uimm7:$shcnt)>;
def : Pat<(v2i64 (rotr v2i64:$rb, (build_imm_vector_64 uimm7i64:$shcnt))), (VSRPID GR:$rb, GR:$rb, (cast_shift_i64_to_i32 $shcnt))>;

def : Pat<(v16i8 (fshl v16i8:$rb, v16i8:$rc, (build_imm_vector_8  uimm7   :$shcnt))), (VSRPIB GR:$rb, GR:$rc, (CastLeftShiftToRight_8  $shcnt))>;
def : Pat<(v8i16 (fshl v8i16:$rb, v8i16:$rc, (build_imm_vector_16 uimm7   :$shcnt))), (VSRPIH GR:$rb, GR:$rc, (CastLeftShiftToRight_16 $shcnt))>;
def : Pat<(v4i32 (fshl v4i32:$rb, v4i32:$rc, (build_imm_vector_32 uimm7   :$shcnt))), (VSRPIW GR:$rb, GR:$rc, (CastLeftShiftToRight_32 $shcnt))>;
def : Pat<(v2i64 (fshl v2i64:$rb, v2i64:$rc, (build_imm_vector_64 uimm7i64:$shcnt))), (VSRPID GR:$rb, GR:$rc, (CastLeftShiftToRight_64 $shcnt))>;

// model immediate rotate-left as immediate rotate-right with modified immediate
def : Pat<(v16i8 (rotl v16i8:$rb, (build_imm_vector_8  uimm7   :$shcnt))), (VSRPIB GR:$rb, GR:$rb, (CastLeftShiftToRight_8  $shcnt))>;
def : Pat<(v8i16 (rotl v8i16:$rb, (build_imm_vector_16 uimm7   :$shcnt))), (VSRPIH GR:$rb, GR:$rb, (CastLeftShiftToRight_16 $shcnt))>;
def : Pat<(v4i32 (rotl v4i32:$rb, (build_imm_vector_32 uimm7   :$shcnt))), (VSRPIW GR:$rb, GR:$rb, (CastLeftShiftToRight_32 $shcnt))>;
def : Pat<(v2i64 (rotl v2i64:$rb, (build_imm_vector_64 uimm7i64:$shcnt))), (VSRPID GR:$rb, GR:$rb, (CastLeftShiftToRight_64 $shcnt))>;


//===----------------------------------------------------------------------===//
// vector splat
//===----------------------------------------------------------------------===//
multiclass VSPLAT_SHIFT_IMM<misc_opx Opc, ClangBuiltin Builtin, ValueType Ty, InstrItinClass itin = IIC_iu_instr>
{
  def NAME : MISC_RabSc<Opc, (outs GR:$ra), (ins GR:$rb, uimm7:$shcnt),
        !strconcat(Opc.mnem, " $ra, $rb, $shcnt"),
        [(set Ty:$ra, (Builtin Ty:$rb, uimm7:$shcnt))], itin>;
}

defm VSPLATIB : VSPLAT_SHIFT_IMM<opcode_vsplatib, int_postrisc_vsplatb, v16i8>;
defm VSPLATIH : VSPLAT_SHIFT_IMM<opcode_vsplatih, int_postrisc_vsplath, v8i16>;
defm VSPLATIW : VSPLAT_SHIFT_IMM<opcode_vsplatiw, int_postrisc_vsplatw, v4i32>;
defm VSPLATID : VSPLAT_SHIFT_IMM<opcode_vsplatid, int_postrisc_vsplatd, v2i64>;

defm VSPLATB : BUILTIN_R3<opcode_vsplatb, int_postrisc_vsplatb, v16i8, v16i8, i32>;
defm VSPLATH : BUILTIN_R3<opcode_vsplath, int_postrisc_vsplath, v8i16, v8i16, i32>;
defm VSPLATW : BUILTIN_R3<opcode_vsplatw, int_postrisc_vsplatw, v4i32, v4i32, i32>;
defm VSPLATD : BUILTIN_R3<opcode_vsplatd, int_postrisc_vsplatd, v2i64, v2i64, i32>;

//===----------------------------------------------------------------------===//
// integer SIMD mixed type conversions
//===----------------------------------------------------------------------===//
defm VPKSSATH  : BUILTIN_R3<opcode_vpkssath,  int_postrisc_vpkssath,  v16i8, v8i16, v8i16>;
defm VPKUSATH  : BUILTIN_R3<opcode_vpkusath,  int_postrisc_vpkusath,  v16i8, v8i16, v8i16>;
defm VPKUMODH  : BUILTIN_R3<opcode_vpkumodh,  int_postrisc_vpkumodh,  v16i8, v8i16, v8i16>;
defm VPKUSATSH : BUILTIN_R3<opcode_vpkusatsh, int_postrisc_vpkusatsh, v16i8, v8i16, v8i16>;

defm VPKSSATW  : BUILTIN_R3<opcode_vpkssatw,  int_postrisc_vpkssatw,  v8i16, v4i32, v4i32>;
defm VPKUSATW  : BUILTIN_R3<opcode_vpkusatw,  int_postrisc_vpkusatw,  v8i16, v4i32, v4i32>;
defm VPKUMODW  : BUILTIN_R3<opcode_vpkumodw,  int_postrisc_vpkumodw,  v8i16, v4i32, v4i32>;
defm VPKUSATSW : BUILTIN_R3<opcode_vpkusatsw, int_postrisc_vpkusatsw, v8i16, v4i32, v4i32>;

defm VPKSSATD  : BUILTIN_R3<opcode_vpkssatd,  int_postrisc_vpkssatd,  v4i32, v2i64, v2i64>;
defm VPKUSATD  : BUILTIN_R3<opcode_vpkusatd,  int_postrisc_vpkusatd,  v4i32, v2i64, v2i64>;
defm VPKUMODD  : BUILTIN_R3<opcode_vpkumodd,  int_postrisc_vpkumodd,  v4i32, v2i64, v2i64>;
defm VPKUSATSD : BUILTIN_R3<opcode_vpkusatsd, int_postrisc_vpkusatsd, v4i32, v2i64, v2i64>;

defm VUPKLSB : BUILTIN_R2<opcode_vupklsb, int_postrisc_vupklsb, v8i16, v16i8>;
defm VUPKHSB : BUILTIN_R2<opcode_vupkhsb, int_postrisc_vupkhsb, v8i16, v16i8>;
defm VUPKLUB : BUILTIN_R2<opcode_vupklub, int_postrisc_vupklub, v8i16, v16i8>;
defm VUPKHUB : BUILTIN_R2<opcode_vupkhub, int_postrisc_vupkhub, v8i16, v16i8>;

defm VUPKLSH : BUILTIN_R2<opcode_vupklsh, int_postrisc_vupklsh, v4i32, v8i16>;
defm VUPKHSH : BUILTIN_R2<opcode_vupkhsh, int_postrisc_vupkhsh, v4i32, v8i16>;
defm VUPKLUH : BUILTIN_R2<opcode_vupkluh, int_postrisc_vupkluh, v4i32, v8i16>;
defm VUPKHUH : BUILTIN_R2<opcode_vupkhuh, int_postrisc_vupkhuh, v4i32, v8i16>;

defm VUPKLSW : BUILTIN_R2<opcode_vupklsw, int_postrisc_vupklsw, v2i64, v4i32>;
defm VUPKHSW : BUILTIN_R2<opcode_vupkhsw, int_postrisc_vupkhsw, v2i64, v4i32>;
defm VUPKLUW : BUILTIN_R2<opcode_vupkluw, int_postrisc_vupkluw, v2i64, v4i32>;
defm VUPKHUW : BUILTIN_R2<opcode_vupkhuw, int_postrisc_vupkhuw, v2i64, v4i32>;

defm VPERMB : BUILTIN_R4<opcode_vpermb, int_postrisc_vpermb, v16i8, v16i8, v16i8, v16i8>;
