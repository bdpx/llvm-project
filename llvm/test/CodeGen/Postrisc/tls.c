// RUN: clang %cflags -mcmodel=medium -ftls-model=local-exec     %s | FileCheck %s --check-prefixes=MEDIUM_LE
// RUN: clang %cflags -mcmodel=large  -ftls-model=local-exec     %s | FileCheck %s --check-prefixes=LARGE_LE
// RUN: clang %cflags -mcmodel=medium -ftls-model=local-dynamic  %s | FileCheck %s --check-prefixes=MEDIUM_LD
// RUN: clang %cflags -mcmodel=large  -ftls-model=local-dynamic  %s | FileCheck %s --check-prefixes=LARGE_LD
// RUN: clang %cflags -mcmodel=medium -ftls-model=global-dynamic %s | FileCheck %s --check-prefixes=MEDIUM_GD
// RUN: clang %cflags -mcmodel=large  -ftls-model=global-dynamic %s | FileCheck %s --check-prefixes=LARGE_GD
// RUN: clang %cflags -mcmodel=medium -ftls-model=initial-exec   %s | FileCheck %s --check-prefixes=MEDIUM_IE
// RUN: clang %cflags -mcmodel=large  -ftls-model=initial-exec   %s | FileCheck %s --check-prefixes=LARGE_IE
// RUN: clang %cflags -mcmodel=medium                            %s | FileCheck %s --check-prefixes=MEDIUM
// RUN: clang %cflags -mcmodel=large                             %s | FileCheck %s --check-prefixes=LARGE
// REQUIRES: postrisc-registered-target

#include "common.h"

/*
global-dynamic:
    address = __tls_get_addr(ip + tgd(x))) // R_POSTRISC_TLS_GD_GOT_OFFSET

local-dynamic:
    tls_block = __tls_get_addr(ip + tld(x1 or x2)) // R_POSTRISC_TLS_GD_GOT_OFFSET
    address_x1 = tls_block + dtpoff(x1) // R_POSTRISC_TLS_LD_OFFSET
    address_x2 = tls_block + dtpoff(x2) // R_POSTRISC_TLS_LD_OFFSET
    (may be folded with load/store)

initial-exec:
    address = TP + load(ip + gottpoff(x)) // R_POSTRISC_TLS_IE_OFFSET

local-exec:
    address = TP + tpoff(x) // R_POSTRISC_TLS_LE_OFFSET
    (may be folded with load/store)
*/

// FIXME: __tls_get_addr will be long?

// this var is local to current module
__thread i64 x_tls = 0;

// MEDIUM-LABEL: @test_local_tls
// LARGE-LABEL:  @test_local_tls
// MEDIUM_LD-LABEL: @test_local_tls
// LARGE_LD-LABEL: @test_local_tls
// MEDIUM_GD-LABEL: @test_local_tls
// LARGE_GD-LABEL: @test_local_tls
// MEDIUM_IE-LABEL: @test_local_tls
// LARGE_IE-LABEL: @test_local_tls
// MEDIUM_LE-LABEL: @test_local_tls
// LARGE_LE-LABEL: @test_local_tls

long test_local_tls(long a)
{
// MEDIUM: ca.rf.l %r4, %tgd_ext(x_tls)
// MEDIUM: call.r %r3, %jpc(__tls_get_addr)
// MEDIUM: ldz.d %r2, %r4, 0

// LARGE: ca.rf.l %r4, %tgd_ext(x_tls)
// LARGE: call.r.l %r3, %jpc_ext(__tls_get_addr)
// LARGE: ldz.d %r2, %r4, 0

// MEDIUM_LE: ldz.d.l %r2, %tp, %tpoff_ext(x_tls)

// LARGE_LE: ldz.d.l %r2, %tp, %tpoff_ext(x_tls)

// MEDIUM_IE: ldz.d.r.l %r2, %gottpoff_ext(x_tls)
// MEDIUM_IE: ldz.d.xd %r2, %tp, %r2, 0, 0

// LARGE_IE: ldz.d.r.l %r2, %gottpoff_ext(x_tls)
// LARGE_IE: ldz.d.xd %r2, %tp, %r2, 0, 0

// MEDIUM_LD: ca.rf.l %r4, %tld_ext(x_tls)
// MEDIUM_LD: call.r %r3, %jpc(__tls_get_addr)
// MEDIUM_LD: ldz.d.l %r2, %r4, %dtpoff_ext(x_tls)

// LARGE_LD: ca.rf.l %r4, %tld_ext(x_tls)
// LARGE_LD: call.r.l %r3, %jpc_ext(__tls_get_addr)
// LARGE_LD: ldz.d.l %r2, %r4, %dtpoff_ext(x_tls)

// MEDIUM_GD: ca.rf.l %r4, %tgd_ext(x_tls)
// MEDIUM_GD: call.r %r3, %jpc(__tls_get_addr)
// MEDIUM_GD: ldz.d %r2, %r4, 0

// LARGE_GD: ca.rf.l %r4, %tgd_ext(x_tls)
// LARGE_GD: call.r.l %r3, %jpc_ext(__tls_get_addr)
// LARGE_GD: ldz.d %r2, %r4, 0

   a += x_tls;
   return a;
}

// this var module is unknown
extern __thread i64 x_tls_extern;

// MEDIUM-LABEL: @test_extern_tls
// LARGE-LABEL:  @test_extern_tls
// MEDIUM_LD-LABEL: @test_extern_tls
// LARGE_LD-LABEL: @test_extern_tls
// MEDIUM_GD-LABEL: @test_extern_tls
// LARGE_GD-LABEL: @test_extern_tls
// MEDIUM_IE-LABEL: @test_extern_tls
// LARGE_IE-LABEL: @test_extern_tls
// MEDIUM_LE-LABEL: @test_extern_tls
// LARGE_LE-LABEL: @test_extern_tls

long test_extern_tls(long a)
{
// MEDIUM: ca.rf.l %r4, %tgd_ext(x_tls_extern)
// MEDIUM: call.r %r3, %jpc(__tls_get_addr)
// MEDIUM: ldz.d %r2, %r4, 0

// LARGE: ca.rf.l %r4, %tgd_ext(x_tls_extern)
// LARGE: call.r.l %r3, %jpc_ext(__tls_get_addr)
// LARGE: ldz.d %r2, %r4, 0

// MEDIUM_LE: ldz.d.l %r2, %tp, %tpoff_ext(x_tls_extern)

// LARGE_LE: ldz.d.l %r2, %tp, %tpoff_ext(x_tls_extern)

// MEDIUM_IE: ldz.d.r.l %r2, %gottpoff_ext(x_tls_extern)
// MEDIUM_IE: ldz.d.xd %r2, %tp, %r2, 0, 0

// LARGE_IE: ldz.d.r.l %r2, %gottpoff_ext(x_tls_extern)
// LARGE_IE: ldz.d.xd %r2, %tp, %r2, 0, 0

// MEDIUM_LD: ca.rf.l %r4, %tld_ext(x_tls_extern)
// MEDIUM_LD: call.r %r3, %jpc(__tls_get_addr)
// MEDIUM_LD: ldz.d.l %r2, %r4, %dtpoff_ext(x_tls_extern)

// MEDIUM_GD: ca.rf.l %r4, %tgd_ext(x_tls_extern)
// MEDIUM_GD: call.r %r3, %jpc(__tls_get_addr)
// MEDIUM_GD: ldz.d %r2, %r4, 0

// LARGE_LD: ca.rf.l %r4, %tld_ext(x_tls_extern)
// LARGE_LD: call.r.l %r3, %jpc_ext(__tls_get_addr)
// LARGE_LD: ldz.d.l  %r2, %r4, %dtpoff_ext(x_tls_extern)

// LARGE_GD: ca.rf.l %r4, %tgd_ext(x_tls_extern)
// LARGE_GD: call.r.l %r3, %jpc_ext(__tls_get_addr)
// LARGE_GD: ldz.d    %r2, %r4, 0

   a += x_tls_extern;
   return a;
}
