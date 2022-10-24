#pragma once

#if !defined(__cplusplus)
#define bool _Bool
#define true 1
#define false 0
#endif

#if !defined(likely)
    #define likely(x)      __builtin_expect(!!(x), 1)
#endif

#if !defined(unlikely)
    #define unlikely(x)    __builtin_expect(!!(x), 0)
#endif

// macros to check branch instructions
#define CHECK_BRANCH(COND)               \
  if (unlikely(COND)) {                  \
    __builtin_postrisc_nul_never(111);   \
  } else {                               \
    __builtin_postrisc_nul_never(222);   \
  }

#define CHECK_INV_BRANCH(COND)           \
  if (likely(COND)) {                    \
    __builtin_postrisc_nul_never(333);   \
  } else {                               \
    __builtin_postrisc_nul_never(444);   \
  }

// macros to check nullification instructions
#define CHECK_NULLIFICATION(COND)        \
  if (COND) {                            \
    __builtin_postrisc_nop(555);         \
  } else {                               \
    __builtin_postrisc_nop(666);         \
  }

#define CHECK_INV_NULLIFICATION(COND)    \
  if (likely(COND)) {                    \
    __builtin_postrisc_nop(777);         \
  } else {                               \
    __builtin_postrisc_nop(888);         \
  }

typedef signed char i8;
typedef unsigned char u8;
typedef short i16;
typedef unsigned short u16;
typedef int i32;
typedef unsigned int u32;
typedef long long i64;
typedef unsigned long long u64;
typedef __int128_t i128;
typedef __uint128_t u128;

typedef _Float16 f16; // native support for ieee halffloat
typedef float f32;
typedef double f64;
typedef long double f128;

typedef int (*ft0)();
typedef int (*ft)(int arg);

typedef __attribute__((ext_vector_type(8))) f16 v8f16;
typedef __attribute__((ext_vector_type(4))) f32 v4f32;
typedef __attribute__((ext_vector_type(2))) f64 v2f64;

typedef __attribute__((ext_vector_type(16))) i8 v16i8;
typedef __attribute__((ext_vector_type(8))) i16 v8i16;
typedef __attribute__((ext_vector_type(4))) i32 v4i32;
typedef __attribute__((ext_vector_type(2))) i64 v2i64;

typedef __attribute__((ext_vector_type(16))) u8 v16u8;
typedef __attribute__((ext_vector_type(8))) u16 v8u16;
typedef __attribute__((ext_vector_type(4))) u32 v4u32;
typedef __attribute__((ext_vector_type(2))) u64 v2u64;

typedef struct {
  i64 re;
  i64 im;
} complex;

extern int printf(const char* fmt, ...);
extern void exit(int);

#define BITCAST(TYPE) *(TYPE*)&
