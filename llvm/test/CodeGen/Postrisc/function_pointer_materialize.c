// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

typedef int (*test_function_pointer_t)(int x);

extern int test_extern_function_pointer_target(int x);

static int test_static_function_pointer_target(int x)
{
  return x + 1;
}

int test_global_function_pointer_target(int x)
{
  return x + 1;
}

// CHECK-LABEL: @test_static_function_pointer_materialize
test_function_pointer_t test_static_function_pointer_materialize(int x)
{
  // CHECK: lda_r %r1, %jpc(test_static_function_pointer_target)
  return test_static_function_pointer_target;
}

// CHECK-LABEL: @test_global_function_pointer_materialize
test_function_pointer_t test_global_function_pointer_materialize(int x)
{
  // CHECK: lda_r %r1, %jpc(test_global_function_pointer_target)
  return test_global_function_pointer_target;
}

// CHECK-LABEL: @test_extern_function_pointer_materialize
test_function_pointer_t test_extern_function_pointer_materialize(int x)
{
  // CHECK: lda_r %r1, %jpc(test_extern_function_pointer_target)
  return test_extern_function_pointer_target;
}
