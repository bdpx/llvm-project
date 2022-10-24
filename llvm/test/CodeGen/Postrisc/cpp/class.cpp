// RUN: clang++ %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#if !defined(__cplusplus)
#warning __cplusplus not defined
#endif // __cplusplus

#include "../common.h"

class CSimple {
public:
  CSimple(void);
  ~CSimple(void);
  i64 func(i64 a);
  i64 a, b;
};

i64 test_class(i64 a)
{
  CSimple ex;
  return ex.func(a) + a; //(i64)__builtin_frame_address(0);
  // CHECK: retf 16
}
