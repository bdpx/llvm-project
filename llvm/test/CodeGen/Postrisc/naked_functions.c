// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_naked
// expected: no instructions
__attribute__((naked)) void test_naked() {
  ;
}

// CHECK-LABEL: @test_after_naked
void test_after_naked() {
  ;
}
