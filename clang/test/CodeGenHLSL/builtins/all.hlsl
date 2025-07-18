// RUN: %clang_cc1 -finclude-default-header -x hlsl -triple \
// RUN:   spirv-unknown-vulkan-compute %s -fnative-half-type \
// RUN:   -emit-llvm -disable-llvm-passes -o - | FileCheck %s \ 
// RUN:   --check-prefixes=CHECK,NATIVE_HALF \
// RUN:   -DFNATTRS="hidden spir_func noundef" -DTARGET=spv
// RUN: %clang_cc1 -finclude-default-header -x hlsl -triple \
// RUN:   spirv-unknown-vulkan-compute %s -emit-llvm -disable-llvm-passes \
// RUN:   -o - | FileCheck %s --check-prefixes=CHECK \
// RUN:   -DFNATTRS="hidden spir_func noundef" -DTARGET=spv
// RUN: %clang_cc1 -finclude-default-header -x hlsl -triple \
// RUN:   dxil-pc-shadermodel6.3-library %s -fnative-half-type \
// RUN:   -emit-llvm -disable-llvm-passes -o - | FileCheck %s \ 
// RUN:   --check-prefixes=CHECK,NATIVE_HALF \
// RUN:   -DFNATTRS="hidden noundef" -DTARGET=dx
// RUN: %clang_cc1 -finclude-default-header -x hlsl -triple \
// RUN:   dxil-pc-shadermodel6.3-library %s -emit-llvm -disable-llvm-passes \
// RUN:   -o - | FileCheck %s --check-prefixes=CHECK \
// RUN:   -DFNATTRS="hidden noundef" -DTARGET=dx

#ifdef __HLSL_ENABLE_16_BIT
// NATIVE_HALF: define [[FNATTRS]] i1 @
// NATIVE_HALF: %hlsl.all = call i1 @llvm.[[TARGET]].all.i16
// NATIVE_HALF: ret i1 %hlsl.all
bool test_all_int16_t(int16_t p0) { return all(p0); }
// NATIVE_HALF: define [[FNATTRS]] i1 @
// NATIVE_HALF: %hlsl.all = call i1 @llvm.[[TARGET]].all.v2i16
// NATIVE_HALF: ret i1 %hlsl.all
bool test_all_int16_t2(int16_t2 p0) { return all(p0); }
// NATIVE_HALF: define [[FNATTRS]] i1 @
// NATIVE_HALF: %hlsl.all = call i1 @llvm.[[TARGET]].all.v3i16
// NATIVE_HALF: ret i1 %hlsl.all
bool test_all_int16_t3(int16_t3 p0) { return all(p0); }
// NATIVE_HALF: define [[FNATTRS]] i1 @
// NATIVE_HALF: %hlsl.all = call i1 @llvm.[[TARGET]].all.v4i16
// NATIVE_HALF: ret i1 %hlsl.all
bool test_all_int16_t4(int16_t4 p0) { return all(p0); }
// NATIVE_HALF: define [[FNATTRS]] i1 @
// NATIVE_HALF: %hlsl.all = call i1 @llvm.[[TARGET]].all.i16
// NATIVE_HALF: ret i1 %hlsl.all
bool test_all_uint16_t(uint16_t p0) { return all(p0); }
// NATIVE_HALF: define [[FNATTRS]] i1 @
// NATIVE_HALF: %hlsl.all = call i1 @llvm.[[TARGET]].all.v2i16
// NATIVE_HALF: ret i1 %hlsl.all
bool test_all_uint16_t2(uint16_t2 p0) { return all(p0); }
// NATIVE_HALF: define [[FNATTRS]] i1 @
// NATIVE_HALF: %hlsl.all = call i1 @llvm.[[TARGET]].all.v3i16
// NATIVE_HALF: ret i1 %hlsl.all
bool test_all_uint16_t3(uint16_t3 p0) { return all(p0); }
// NATIVE_HALF: define [[FNATTRS]] i1 @
// NATIVE_HALF: %hlsl.all = call i1 @llvm.[[TARGET]].all.v4i16
// NATIVE_HALF: ret i1 %hlsl.all
bool test_all_uint16_t4(uint16_t4 p0) { return all(p0); }
#endif // __HLSL_ENABLE_16_BIT

// CHECK: define [[FNATTRS]] i1 @
// NATIVE_HALF: %hlsl.all = call i1 @llvm.[[TARGET]].all.f16
// NO_HALF: %hlsl.all = call i1 @llvm.[[TARGET]].all.f32
// CHECK: ret i1 %hlsl.all
bool test_all_half(half p0) { return all(p0); }
// CHECK: define [[FNATTRS]] i1 @
// NATIVE_HALF: %hlsl.all = call i1 @llvm.[[TARGET]].all.v2f16
// NO_HALF: %hlsl.all = call i1 @llvm.[[TARGET]].all.v2f32
// CHECK: ret i1 %hlsl.all
bool test_all_half2(half2 p0) { return all(p0); }
// CHECK: define [[FNATTRS]] i1 @
// NATIVE_HALF: %hlsl.all = call i1 @llvm.[[TARGET]].all.v3f16
// NO_HALF: %hlsl.all = call i1 @llvm.[[TARGET]].all.v3f32
// CHECK: ret i1 %hlsl.all
bool test_all_half3(half3 p0) { return all(p0); }
// CHECK: define [[FNATTRS]] i1 @
// NATIVE_HALF: %hlsl.all = call i1 @llvm.[[TARGET]].all.v4f16
// NO_HALF: %hlsl.all = call i1 @llvm.[[TARGET]].all.v4f32
// CHECK: ret i1 %hlsl.all
bool test_all_half4(half4 p0) { return all(p0); }

// CHECK: define [[FNATTRS]] i1 @
// CHECK: %hlsl.all = call i1 @llvm.[[TARGET]].all.f32
// CHECK: ret i1 %hlsl.all
bool test_all_float(float p0) { return all(p0); }
// CHECK: define [[FNATTRS]] i1 @
// CHECK: %hlsl.all = call i1 @llvm.[[TARGET]].all.v2f32
// CHECK: ret i1 %hlsl.all
bool test_all_float2(float2 p0) { return all(p0); }
// CHECK: define [[FNATTRS]] i1 @
// CHECK: %hlsl.all = call i1 @llvm.[[TARGET]].all.v3f32
// CHECK: ret i1 %hlsl.all
bool test_all_float3(float3 p0) { return all(p0); }
// CHECK: define [[FNATTRS]] i1 @
// CHECK: %hlsl.all = call i1 @llvm.[[TARGET]].all.v4f32
// CHECK: ret i1 %hlsl.all
bool test_all_float4(float4 p0) { return all(p0); }

// CHECK: define [[FNATTRS]] i1 @
// CHECK: %hlsl.all = call i1 @llvm.[[TARGET]].all.f64
// CHECK: ret i1 %hlsl.all
bool test_all_double(double p0) { return all(p0); }
// CHECK: define [[FNATTRS]] i1 @
// CHECK: %hlsl.all = call i1 @llvm.[[TARGET]].all.v2f64
// CHECK: ret i1 %hlsl.all
bool test_all_double2(double2 p0) { return all(p0); }
// CHECK: define [[FNATTRS]] i1 @
// CHECK: %hlsl.all = call i1 @llvm.[[TARGET]].all.v3f64
// CHECK: ret i1 %hlsl.all
bool test_all_double3(double3 p0) { return all(p0); }
// CHECK: define [[FNATTRS]] i1 @
// CHECK: %hlsl.all = call i1 @llvm.[[TARGET]].all.v4f64
// CHECK: ret i1 %hlsl.all
bool test_all_double4(double4 p0) { return all(p0); }

// CHECK: define [[FNATTRS]] i1 @
// CHECK: %hlsl.all = call i1 @llvm.[[TARGET]].all.i32
// CHECK: ret i1 %hlsl.all
bool test_all_int(int p0) { return all(p0); }
// CHECK: define [[FNATTRS]] i1 @
// CHECK: %hlsl.all = call i1 @llvm.[[TARGET]].all.v2i32
// CHECK: ret i1 %hlsl.all
bool test_all_int2(int2 p0) { return all(p0); }
// CHECK: define [[FNATTRS]] i1 @
// CHECK: %hlsl.all = call i1 @llvm.[[TARGET]].all.v3i32
// CHECK: ret i1 %hlsl.all
bool test_all_int3(int3 p0) { return all(p0); }
// CHECK: define [[FNATTRS]] i1 @
// CHECK: %hlsl.all = call i1 @llvm.[[TARGET]].all.v4i32
// CHECK: ret i1 %hlsl.all
bool test_all_int4(int4 p0) { return all(p0); }

// CHECK: define [[FNATTRS]] i1 @
// CHECK: %hlsl.all = call i1 @llvm.[[TARGET]].all.i32
// CHECK: ret i1 %hlsl.all
bool test_all_uint(uint p0) { return all(p0); }
// CHECK: define [[FNATTRS]] i1 @
// CHECK: %hlsl.all = call i1 @llvm.[[TARGET]].all.v2i32
// CHECK: ret i1 %hlsl.all
bool test_all_uint2(uint2 p0) { return all(p0); }
// CHECK: define [[FNATTRS]] i1 @
// CHECK: %hlsl.all = call i1 @llvm.[[TARGET]].all.v3i32
// CHECK: ret i1 %hlsl.all
bool test_all_uint3(uint3 p0) { return all(p0); }
// CHECK: define [[FNATTRS]] i1 @
// CHECK: %hlsl.all = call i1 @llvm.[[TARGET]].all.v4i32
// CHECK: ret i1 %hlsl.all
bool test_all_uint4(uint4 p0) { return all(p0); }

// CHECK: define [[FNATTRS]] i1 @
// CHECK: %hlsl.all = call i1 @llvm.[[TARGET]].all.i64
// CHECK: ret i1 %hlsl.all
bool test_all_int64_t(int64_t p0) { return all(p0); }
// CHECK: define [[FNATTRS]] i1 @
// CHECK: %hlsl.all = call i1 @llvm.[[TARGET]].all.v2i64
// CHECK: ret i1 %hlsl.all
bool test_all_int64_t2(int64_t2 p0) { return all(p0); }
// CHECK: define [[FNATTRS]] i1 @
// CHECK: %hlsl.all = call i1 @llvm.[[TARGET]].all.v3i64
// CHECK: ret i1 %hlsl.all
bool test_all_int64_t3(int64_t3 p0) { return all(p0); }
// CHECK: define [[FNATTRS]] i1 @
// CHECK: %hlsl.all = call i1 @llvm.[[TARGET]].all.v4i64
// CHECK: ret i1 %hlsl.all
bool test_all_int64_t4(int64_t4 p0) { return all(p0); }

// CHECK: define [[FNATTRS]] i1 @
// CHECK: %hlsl.all = call i1 @llvm.[[TARGET]].all.i64
// CHECK: ret i1 %hlsl.all
bool test_all_uint64_t(uint64_t p0) { return all(p0); }
// CHECK: define [[FNATTRS]] i1 @
// CHECK: %hlsl.all = call i1 @llvm.[[TARGET]].all.v2i64
// CHECK: ret i1 %hlsl.all
bool test_all_uint64_t2(uint64_t2 p0) { return all(p0); }
// CHECK: define [[FNATTRS]] i1 @
// CHECK: %hlsl.all = call i1 @llvm.[[TARGET]].all.v3i64
// CHECK: ret i1 %hlsl.all
bool test_all_uint64_t3(uint64_t3 p0) { return all(p0); }
// CHECK: define [[FNATTRS]] i1 @
// CHECK: %hlsl.all = call i1 @llvm.[[TARGET]].all.v4i64
// CHECK: ret i1 %hlsl.all
bool test_all_uint64_t4(uint64_t4 p0) { return all(p0); }

// CHECK: define [[FNATTRS]] i1 @
// CHECK: %hlsl.all = call i1 @llvm.[[TARGET]].all.i1
// CHECK: ret i1 %hlsl.all
bool test_all_bool(bool p0) { return all(p0); }
// CHECK: define [[FNATTRS]] i1 @
// CHECK: %hlsl.all = call i1 @llvm.[[TARGET]].all.v2i1
// CHECK: ret i1 %hlsl.all
bool test_all_bool2(bool2 p0) { return all(p0); }
// CHECK: define [[FNATTRS]] i1 @
// CHECK: %hlsl.all = call i1 @llvm.[[TARGET]].all.v3i1
// CHECK: ret i1 %hlsl.all
bool test_all_bool3(bool3 p0) { return all(p0); }
// CHECK: define [[FNATTRS]] i1 @
// CHECK: %hlsl.all = call i1 @llvm.[[TARGET]].all.v4i1
// CHECK: ret i1 %hlsl.all
bool test_all_bool4(bool4 p0) { return all(p0); }
