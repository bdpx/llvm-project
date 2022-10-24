// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

#if !defined(__POSTRISC__)
#warning "__POSTRISC__" isn't defined
#endif

extern i32 glb;
extern u32 uglb;
extern i32 glbx;
static u64 uglbx = 1;

struct f2 { float f0, f1; };

float ffff(struct f2 f)
{
  return f.f0 + f.f1;
}

// CHECK-LABEL: @i64_test
i64 i64_test(i64 a, i64 b, i64 x)
{
  volatile i64 c = a + b;
  volatile i64 d = a - b;
  volatile i64 e = 1000 - b;
  volatile i64 f = 1000000000 - b;
  volatile i64 g = a - 100;
  volatile i64 h = a - 100;
  volatile i64 result = c-d-e+f-g+h;
  if (a < b && a < c) {
    printf("less %lld\n", result-1);
  } else {
    printf("greater %lld\n", result+1);
    exit(0);
  }
  volatile i64 addsub = c+d-f;
  volatile i64 subsub = c-d-f;
  return result;
}

void NeverReturn(int c, int d)
{
   for(; c != 0; --c) {
      printf("zz=%d\n", c);
      ++uglbx;
   }

   for(;;) {
      printf("xx=%d\n", d);
      --d;
      --glbx;
   }
}

i64 i64_add(i64 a)
{
  i64 tmp = a + glbx + 1234LL;
  glbx = tmp;
  return tmp;
}

extern int cccc(int x);

i32 i32_add(i32 a)
{
  return glb + a + 12345 + cccc(a) + (i64)&cccc;
}

u32 u32_add(u32 a)
{
  int x[100] = {0};
  return uglb + a;
}

i32 float_test(double x, double y)
{
   // TODO: backend hang on compare select
   if (x < y)
   {
     return printf("x=%le\n", x);
   }
   else
   {
     x += y;
     //FIXME: inlineasm not work
     //__asm__ __volatile__("trap 100\n");
     //__asm__ __volatile__("add_i64 %r12, %r90, %r45\n");
     //__asm__ __volatile__("get_spr %r13, %itc");
     return 2;
   }
}

int main(int argc, char **argv)
{
  int a = 123450;
  int b = 456780;
  int c = a + b;
  i64 x[20] = {0,1,2,3,4,5+a,6+b,7+c};
  return 0; //for_loop(20, argc, x) + float_test(argc+1.0, 3.0) + i64_test(argc+1234567890LL, 987654321012LL, 12312312312312LL);
}
