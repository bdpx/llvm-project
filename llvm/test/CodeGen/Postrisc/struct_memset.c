// RUN: clang %cflags %s | FileCheck %s
// REQUIRES: postrisc-registered-target

#include <stdarg.h>

#include "common.h"

#define EOF (-1)

typedef struct _IO_FILE FILE;
typedef unsigned long size_t;
typedef unsigned long off_t;

struct _IO_FILE {
    unsigned flags;
    unsigned char *rpos, *rend;
    int (*close)(FILE *);
    unsigned char *wend, *wpos;
    unsigned char *mustbezero_1;
    unsigned char *wbase;
    size_t (*read)(FILE *, unsigned char *, size_t);
    size_t (*write)(FILE *, const unsigned char *, size_t);
    off_t (*seek)(FILE *, off_t, int);
    unsigned char *buf;
    size_t buf_size;
    FILE *prev, *next;
    int fd;
    int pipe_pid;
    long lockcount;
    int mode;
    volatile int lock;
    int lbf;
    void *cookie;
    off_t off;
    char *getln_buf;
    void *mustbezero_2;
    unsigned char *shend;
    off_t shlim, shcnt;
    FILE *prev_locked, *next_locked;
    struct __locale_struct *locale;
};

struct cookie {
    char *s;
    size_t n;
    char *dummy;
};

extern u32 test_struct_memset_consumer(FILE *f);

#define MIN(a, b) ((a) < (b) ? (a) : (b))

static size_t sn_write(FILE *f, const unsigned char *s, size_t l)
{
    struct cookie *c = f->cookie;
    size_t k = MIN(c->n, f->wpos - f->wbase);
    if (k) {
        //memcpy(c->s, f->wbase, k);
        c->s += k;
        c->n -= k;
    }
    k = MIN(c->n, l);
    if (k) {
        //memcpy(c->s, s, k);
        c->s += k;
        c->n -= k;
    }
    *c->s = 0;
    f->wpos = f->wbase = f->buf;
    /* pretend to succeed, even if we discarded extra data */
    return l;
}

// CHECK-LABEL: @test_struct_memset
u32 test_struct_memset(char *restrict s, size_t n, const char *restrict fmt, va_list ap)
{
    unsigned char buf[1];
    char dummy[1];
    struct cookie c = { .s = n ? s : dummy, .n = n ? n-1 : 0 };
    // CXHECK:    callr %r3, %jpc(memset)
    // .LBB0_1:   ! %loadstoreloop
    //            ! =>This Inner Loop Header: Depth=1
    // CXHECK: stbx %gz, %r3, %r1, 0, 0
    // CXHECK: addi %r1, %r1, 1
    // CXHECK: bdltui %r1, 232, .LBB0_1

    // CHECK: stq %gz, %sp, 64
    // CHECK: stq %gz, %sp, 80
    // CHECK: stq %gz, %sp, 128
    // CHECK: stq %gz, %sp, 144
    // CHECK: stq %gz, %sp, 208
    // CHECK: std %gz, %sp, 224
    // CHECK: stq %gz, %sp, 192
    // CHECK: stq %gz, %sp, 176
    // CHECK: stq %gz, %sp, 160
    // CHECK: stq %gz, %sp, 112
    // CHECK: stq %gz, %sp, 96
    // CHECK: stq %gz, %sp, 48
    // CHECK: stq %gz, %sp, 32
    // CHECK: stq %gz, %sp, 16
    // CHECK: stq %gz, %sp, 0

    FILE f = {
        .lbf = EOF,
        .write = sn_write,
        .lock = -1,
        .buf = buf,
        .prev_locked = &f,
    };

    // CHECK: callr %r2, %jpc(test_struct_memset_consumer)
    return test_struct_memset_consumer(&f);
}
