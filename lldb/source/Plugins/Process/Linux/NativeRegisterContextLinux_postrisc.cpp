//===-- NativeRegisterContextLinux_postrisc.cpp ---------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#if defined(__postrisc__)

#include "NativeRegisterContextLinux_postrisc.h"

#include "lldb/Host/HostInfo.h"
#include "lldb/Utility/DataBufferHeap.h"
#include "lldb/Utility/Log.h"
#include "lldb/Utility/RegisterValue.h"
#include "lldb/Utility/Status.h"

#include "Plugins/Process/Linux/NativeProcessLinux.h"
#include "Plugins/Process/Linux/Procfs.h"

using namespace lldb;
using namespace lldb_private;
using namespace lldb_private::process_linux;

std::unique_ptr<NativeRegisterContextLinux>
NativeRegisterContextLinux::CreateHostNativeRegisterContextLinux(
    const ArchSpec &target_arch, NativeThreadLinux &native_thread) {
  switch (target_arch.GetMachine()) {
  case llvm::Triple::postrisc: {
    Flags opt_regsets;
    auto register_info_up = std::make_unique<RegisterInfoPOSIX_postrisc>(
        target_arch, opt_regsets);
    return std::make_unique<NativeRegisterContextLinux_postrisc>(
        target_arch, native_thread, std::move(register_info_up));
  }
  default:
    llvm_unreachable("have no register context for architecture");
  }
}

llvm::Expected<ArchSpec>
NativeRegisterContextLinux::DetermineArchitecture(lldb::tid_t tid) {
  return HostInfo::GetArchitecture();
}

NativeRegisterContextLinux_postrisc::NativeRegisterContextLinux_postrisc(
    const ArchSpec &target_arch, NativeThreadProtocol &native_thread,
    std::unique_ptr<RegisterInfoPOSIX_postrisc> register_info_up)
    : NativeRegisterContextRegisterInfo(native_thread,
                                        register_info_up.release()),
      NativeRegisterContextLinux(native_thread) {
  ::memset(&m_fpr, 0, sizeof(m_fpr));
  ::memset(&m_gpr, 0, sizeof(m_gpr));
}

const RegisterInfoPOSIX_postrisc &
NativeRegisterContextLinux_postrisc::GetRegisterInfo() const {
  return static_cast<const RegisterInfoPOSIX_postrisc &>(
      NativeRegisterContextRegisterInfo::GetRegisterInfoInterface());
}

uint32_t NativeRegisterContextLinux_postrisc::GetRegisterSetCount() const {
  return GetRegisterInfo().GetRegisterSetCount();
}

const RegisterSet *NativeRegisterContextLinux_postrisc::GetRegisterSet(
    uint32_t set_index) const {
  return GetRegisterInfo().GetRegisterSet(set_index);
}

Status NativeRegisterContextLinux_postrisc::ReadRegister(
    const RegisterInfo *reg_info, RegisterValue &reg_value) {
  return Status("Failed to read register value");
}

Status NativeRegisterContextLinux_postrisc::WriteRegister(
    const RegisterInfo *reg_info, const RegisterValue &reg_value) {
  return Status("Failed to write register value");
}

Status NativeRegisterContextLinux_postrisc::ReadAllRegisterValues(
    lldb::WritableDataBufferSP &data_sp) {
  return Status("Failed to read all register values");
}

Status NativeRegisterContextLinux_postrisc::WriteAllRegisterValues(
    const lldb::DataBufferSP &data_sp) {
  return Status("Failed to write all register values");
}

#endif // defined(__postrisc__)
