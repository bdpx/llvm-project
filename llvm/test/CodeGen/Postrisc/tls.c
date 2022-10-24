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
// MEDIUM: lda_iprel.l %r4, %tgd_ext(x_tls)
// MEDIUM: call %r3, %jpc(__tls_get_addr)
// MEDIUM: ld_u64 %r2, %r4, 0

// LARGE: lda_iprel.l %r4, %tgd_ext(x_tls)
// LARGE: call.l %r3, %jpc_ext(__tls_get_addr)
// LARGE: ld_u64 %r2, %r4, 0

// MEDIUM_LE: ld_u64.l %r2, %tp, %tpoff_ext(x_tls)

// LARGE_LE: ld_u64.l %r2, %tp, %tpoff_ext(x_tls)

// MEDIUM_IE: ld_iprel_u64.l %r2, %gottpoff_ext(x_tls)
// MEDIUM_IE: ld_xi64_u64 %r2, %tp, %r2, 0, 0

// LARGE_IE: ld_iprel_u64.l %r2, %gottpoff_ext(x_tls)
// LARGE_IE: ld_xi64_u64 %r2, %tp, %r2, 0, 0

// MEDIUM_LD: lda_iprel.l %r4, %tld_ext(x_tls)
// MEDIUM_LD: call %r3, %jpc(__tls_get_addr)
// MEDIUM_LD: ld_u64.l %r2, %r4, %dtpoff_ext(x_tls)

// LARGE_LD: lda_iprel.l %r4, %tld_ext(x_tls)
// LARGE_LD: call.l %r3, %jpc_ext(__tls_get_addr)
// LARGE_LD: ld_u64.l %r2, %r4, %dtpoff_ext(x_tls)

// MEDIUM_GD: lda_iprel.l %r4, %tgd_ext(x_tls)
// MEDIUM_GD: call %r3, %jpc(__tls_get_addr)
// MEDIUM_GD: ld_u64 %r2, %r4, 0

// LARGE_GD: lda_iprel.l %r4, %tgd_ext(x_tls)
// LARGE_GD: call.l %r3, %jpc_ext(__tls_get_addr)
// LARGE_GD: ld_u64 %r2, %r4, 0

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
// MEDIUM: lda_iprel.l %r4, %tgd_ext(x_tls_extern)
// MEDIUM: call %r3, %jpc(__tls_get_addr)
// MEDIUM: ld_u64 %r2, %r4, 0

// LARGE: lda_iprel.l %r4, %tgd_ext(x_tls_extern)
// LARGE: call.l %r3, %jpc_ext(__tls_get_addr)
// LARGE: ld_u64 %r2, %r4, 0

// MEDIUM_LE: ld_u64.l %r2, %tp, %tpoff_ext(x_tls_extern)

// LARGE_LE: ld_u64.l %r2, %tp, %tpoff_ext(x_tls_extern)

// MEDIUM_IE: ld_iprel_u64.l %r2, %gottpoff_ext(x_tls_extern)
// MEDIUM_IE: ld_xi64_u64 %r2, %tp, %r2, 0, 0

// LARGE_IE: ld_iprel_u64.l %r2, %gottpoff_ext(x_tls_extern)
// LARGE_IE: ld_xi64_u64 %r2, %tp, %r2, 0, 0

// MEDIUM_LD: lda_iprel.l %r4, %tld_ext(x_tls_extern)
// MEDIUM_LD: call %r3, %jpc(__tls_get_addr)
// MEDIUM_LD: ld_u64.l %r2, %r4, %dtpoff_ext(x_tls_extern)

// MEDIUM_GD: lda_iprel.l %r4, %tgd_ext(x_tls_extern)
// MEDIUM_GD: call %r3, %jpc(__tls_get_addr)
// MEDIUM_GD: ld_u64 %r2, %r4, 0

// LARGE_LD: lda_iprel.l %r4, %tld_ext(x_tls_extern)
// LARGE_LD: call.l %r3, %jpc_ext(__tls_get_addr)
// LARGE_LD: ld_u64.l  %r2, %r4, %dtpoff_ext(x_tls_extern)

// LARGE_GD: lda_iprel.l %r4, %tgd_ext(x_tls_extern)
// LARGE_GD: call.l %r3, %jpc_ext(__tls_get_addr)
// LARGE_GD: ld_u64    %r2, %r4, 0

   a += x_tls_extern;
   return a;
}
