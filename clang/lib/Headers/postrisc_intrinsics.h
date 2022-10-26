/*===--------- postrisc_intrinsics.h - Postrisc intrinsics -----------------===
 *
 * Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
 * See https://llvm.org/LICENSE.txt for license information.
 * SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
 *
 *===-----------------------------------------------------------------------===
 */

#ifndef _POSTRISC_BASE_INTRIN_H
#define _POSTRISC_BASE_INTRIN_H

#ifdef __cplusplus
extern "C" {
#endif

typedef struct rdtime {
  unsigned int value;
  unsigned int timeid;
} __rdtime_t;

typedef struct drdtime {
  unsigned long dvalue;
  unsigned long dtimeid;
} __drdtime_t;

#define __break(/*ui15*/ _1) __builtin_postrisc_break((_1))
#define __dbar(/*ui15*/ _1) __builtin_postrisc_dbar((_1))
#define __ibar(/*ui15*/ _1) __builtin_postrisc_ibar((_1))
#define __syscall(/*ui15*/ _1) __builtin_postrisc_syscall((_1))

extern __inline unsigned int
    __attribute__((__gnu_inline__, __always_inline__, __artificial__))
    __iocsrrd_w(unsigned int _1) {
  return (unsigned int)__builtin_postrisc_iocsrrd_w((unsigned int)_1);
}

extern __inline unsigned long int
    __attribute__((__gnu_inline__, __always_inline__, __artificial__))
    __iocsrrd_d(unsigned int _1) {
  return (unsigned long int)__builtin_postrisc_iocsrrd_d((unsigned int)_1);
}

extern __inline void
    __attribute__((__gnu_inline__, __always_inline__, __artificial__))
    __iocsrwr_w(unsigned int _1, unsigned int _2) {
  __builtin_postrisc_iocsrwr_w((unsigned int)_1, (unsigned int)_2);
}

extern __inline void
    __attribute__((__gnu_inline__, __always_inline__, __artificial__))
    __iocsrwr_d(unsigned long int _1, unsigned int _2) {
  __builtin_postrisc_iocsrwr_d((unsigned long int)_1, (unsigned int)_2);
}

extern __inline unsigned int
    __attribute__((__gnu_inline__, __always_inline__, __artificial__))
    __cpuid(unsigned int _1) {
  return (unsigned int)__builtin_postrisc_cpuid((unsigned int)_1);
}

#ifdef __cplusplus
}
#endif
#endif /* _POSTRISC_BASE_INTRIN_H */
