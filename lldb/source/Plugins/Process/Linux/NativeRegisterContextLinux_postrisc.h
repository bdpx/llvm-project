//===-- NativeRegisterContextLinux_postrisc.h -------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#if defined(__postrisc__)

#ifndef lldb_NativeRegisterContextLinux_postrisc_h
#define lldb_NativeRegisterContextLinux_postrisc_h

#include "Plugins/Process/Linux/NativeRegisterContextLinux.h"
#include "Plugins/Process/Utility/RegisterInfoPOSIX_postrisc.h"

#include <asm/ptrace.h>

namespace lldb_private {
namespace process_linux {

class NativeProcessLinux;

class NativeRegisterContextLinux_postrisc
    : public NativeRegisterContextLinux {
public:
  NativeRegisterContextLinux_postrisc(
      const ArchSpec &target_arch, NativeThreadProtocol &native_thread,
      std::unique_ptr<RegisterInfoPOSIX_postrisc> register_info_up);

  uint32_t GetRegisterSetCount() const override;

  const RegisterSet *GetRegisterSet(uint32_t set_index) const override;

  Status ReadRegister(const RegisterInfo *reg_info,
                      RegisterValue &reg_value) override;

  Status WriteRegister(const RegisterInfo *reg_info,
                       const RegisterValue &reg_value) override;

  Status ReadAllRegisterValues(lldb::WritableDataBufferSP &data_sp) override;

  Status WriteAllRegisterValues(const lldb::DataBufferSP &data_sp) override;

protected:
  void *GetGPRBuffer() override { return &m_gpr; }

  void *GetFPRBuffer() override { return &m_fpr; }

  size_t GetGPRSize() const override { return GetRegisterInfo().GetGPRSize(); }

  size_t GetFPRSize() override { return GetRegisterInfo().GetFPRSize(); }

private:
  RegisterInfoPOSIX_postrisc::GPR m_gpr;

  RegisterInfoPOSIX_postrisc::FPR m_fpr;

  const RegisterInfoPOSIX_postrisc &GetRegisterInfo() const;
};

} // namespace process_linux
} // namespace lldb_private

#endif // #ifndef lldb_NativeRegisterContextLinux_postrisc_h

#endif // defined(__postrisc__)
