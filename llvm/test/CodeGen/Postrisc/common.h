#pragma once

#if !defined(__cplusplus)
#define bool _Bool
#define true 1
#define false 0
#endif

typedef signed        char i8;
typedef unsigned      char u8;
typedef              short i16;
typedef unsigned     short u16;
typedef                int i32;
typedef unsigned       int u32;
typedef          long long i64;
typedef unsigned long long u64;
typedef         __int128_t i128;
typedef        __uint128_t u128;

typedef    _Float16 f16; // native support for ieee halffloat
typedef       float f32;
typedef      double f64;
typedef long double f128;

typedef int (*ft0)();
typedef int (*ft)(int arg);

typedef f16 v8f16 __attribute__((ext_vector_type(8)));
typedef f32 v4f32 __attribute__((ext_vector_type(4)));
typedef f64 v2f64 __attribute__((ext_vector_type(2)));

typedef i8  v16i8 __attribute__((ext_vector_type(16)));
typedef i16 v8i16 __attribute__((ext_vector_type(8)));
typedef i32 v4i32 __attribute__((ext_vector_type(4)));
typedef i64 v2i64 __attribute__((ext_vector_type(2)));

typedef u8  v16u8 __attribute__((ext_vector_type(16)));
typedef u16 v8u16 __attribute__((ext_vector_type(8)));
typedef u32 v4u32 __attribute__((ext_vector_type(4)));
typedef u64 v2u64 __attribute__((ext_vector_type(2)));

typedef struct {
  i64 re;
  i64 im;
} complex;

extern int printf(const char* fmt, ...);
extern void exit(int);

#define BITCAST(TYPE) *(TYPE*)&
