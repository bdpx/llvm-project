// RUN: clang %cflags %s | FileCheck %s
// REQUIRES: postrisc-registered-target

#include "common.h"

// shift-and should be converted to shift-shift in one instruction

// CHECK-LABEL: @shift_right_and_load_i32
u8 shift_right_and_load_i32(u8 local_dc_source[], i32 frac) {
    // 41: 64-16-7, 57: 64-7
    // CHECK: slsrl_imm_u64 %r2, %r2, 41, 57
    // CHECK: ld_xi64_u8 %r1, %r1, %r2, 0, 0
    return local_dc_source[ (frac>>16) & 127 ];
}

// CHECK-LABEL: @shift_right_and_load_u32
u8 shift_right_and_load_u32(u8 local_dc_source[], u32 frac) {
    // 41: 64-16-7, 57: 64-7
    // CHECK: slsrl_imm_u64 %r2, %r2, 41, 57
    // CHECK: ld_xi64_u8 %r1, %r1, %r2, 0, 0
    return local_dc_source[ (frac>>16) & 127 ];
}

// CHECK-LABEL: @shift_right_and_load_i64
u8 shift_right_and_load_i64(u8 local_dc_source[], i64 frac) {
    // 41: 64-16-7, 57: 64-7
    // CHECK: slsrl_imm_u64 %r2, %r2, 41, 57
    // CHECK: ld_xi64_u8 %r1, %r1, %r2, 0, 0
    return local_dc_source[ (frac>>16) & 127 ];
}

// CHECK-LABEL: @shift_right_and_load_u64
u8 shift_right_and_load_u64(u8 local_dc_source[], u64 frac) {
    // 41: 64-16-7, 57: 64-7
    // CHECK: slsrl_imm_u64 %r2, %r2, 41, 57
    // CHECK: ld_xi64_u8 %r1, %r1, %r2, 0, 0
    return local_dc_source[ (frac>>16) & 127 ];
}
