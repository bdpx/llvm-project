// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @br_mask_notall_i32
// CHECK: br_mask_notall %r1, 100, [[TARGET:.LBB[0-9]+_[0-9]+]]
void br_mask_notall_i32(i32 a) { CHECK_BRANCH((a & 100) != 100); }

// CHECK-LABEL: @br_mask_all_i32
// CHECK: br_mask_all %r1, 100, [[TARGET:.LBB[0-9]+_[0-9]+]]
void br_mask_all_i32(i32 a) { CHECK_BRANCH((a & 100) == 100); }

// CHECK-LABEL: @br_mask_any_i32
// CHECK: br_mask_any %r1, 100, [[TARGET:.LBB[0-9]+_[0-9]+]]
void br_mask_any_i32(i32 a) { CHECK_BRANCH((a & 100) != 0); }

// CHECK-LABEL: @br_mask_none_i32
// CHECK: br_mask_none %r1, 100, [[TARGET:.LBB[0-9]+_[0-9]+]]
void br_mask_none_i32(i32 a) { CHECK_BRANCH((a & 100) == 0); }



// CHECK-LABEL: @br_mask_notall_i64
// CHECK: br_mask_notall %r1, 100, [[TARGET:.LBB[0-9]+_[0-9]+]]
void br_mask_notall_i64(i64 a) { CHECK_BRANCH((a & 100) != 100); }

// CHECK-LABEL: @br_mask_all_i64
// CHECK: br_mask_all %r1, 100, [[TARGET:.LBB[0-9]+_[0-9]+]]
void br_mask_all_i64(i64 a) { CHECK_BRANCH((a & 100) == 100); }

// CHECK-LABEL: @br_mask_any_i64
// CHECK: br_mask_any %r1, 100, [[TARGET:.LBB[0-9]+_[0-9]+]]
void br_mask_any_i64(i64 a) { CHECK_BRANCH((a & 100) != 0); }

// CHECK-LABEL: @br_mask_none_i64
// CHECK: br_mask_none %r1, 100, [[TARGET:.LBB[0-9]+_[0-9]+]]
void br_mask_none_i64(i64 a) { CHECK_BRANCH((a & 100) == 0); }



// CHECK-LABEL: @br_mask_notall_i128
// CHECK: br_mask_notall %r1, 100, [[TARGET:.LBB[0-9]+_[0-9]+]]
void br_mask_notall_i128(i128 a) { CHECK_BRANCH((a & 100) != 100); }

// CHECK-LABEL: @br_mask_all_i128
// CHECK: br_mask_all %r1, 100, [[TARGET:.LBB[0-9]+_[0-9]+]]
void br_mask_all_i128(i128 a) { CHECK_BRANCH((a & 100) == 100); }

// CHECK-LABEL: @br_mask_any_i128
// CHECK: br_mask_any %r1, 100, [[TARGET:.LBB[0-9]+_[0-9]+]]
void br_mask_any_i128(i128 a) { CHECK_BRANCH((a & 100) != 0); }

// CHECK-LABEL: @br_mask_none_i128
// CHECK: br_mask_none %r1, 100, [[TARGET:.LBB[0-9]+_[0-9]+]]
void br_mask_none_i128(i128 a) { CHECK_BRANCH((a & 100) == 0); }
