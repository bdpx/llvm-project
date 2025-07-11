; This tests hotpatching functions that bypass double-indirection for global variables.
;
; RUN: llc -mtriple=x86_64-windows < %s | FileCheck %s

source_filename = ".\\ms-secure-hotpatch-direct-global-access.ll"
target datalayout = "e-m:w-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-windows-msvc19.36.32537"

@some_global_var = external global i32 #2

define noundef i32 @this_gets_hotpatched() #0 {
    %1 = load i32, ptr @some_global_var
    %2 = add i32 %1, 1
    ret i32 %2
}

attributes #0 = { "marked_for_windows_hot_patching" mustprogress noinline nounwind optnone uwtable }

; CHECK: this_gets_hotpatched: # @this_gets_hotpatched
; CHECK-NEXT: bb.0:
; CHECK-NEXT: movl some_global_var(%rip), %eax
; CHECK-NEXT: addl $1, %eax
; CHECK-NEXT: retq

define noundef i32 @this_does_not_get_hotpatched() #1 {
    %1 = load i32, ptr @some_global_var
    %2 = add i32 %1, 1
    ret i32 %2
}

attributes #1 = { mustprogress noinline nounwind optnone uwtable }

attributes #2 = { "allow_direct_access_in_hot_patch_function" }

; CHECK: this_does_not_get_hotpatched: # @this_does_not_get_hotpatched
; CHECK-NEXT: bb.0:
; CHECK-NEXT: movl some_global_var(%rip), %eax
; CHECK-NEXT: addl $1, %eax
; CHECK-NEXT: retq
