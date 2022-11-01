//===-- RegisterInfoPOSIX_postrisc.cpp -----------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===---------------------------------------------------------------------===//

#include <cassert>
#include <lldb/Utility/Flags.h>
#include <stddef.h>

#include "lldb/lldb-defines.h"
#include "llvm/Support/Compiler.h"

#include "RegisterInfo_postrisc.h"

const lldb_private::RegisterInfo *
RegisterInfo_postrisc::GetRegisterInfoPtr(
    const lldb_private::ArchSpec &target_arch) {
  switch (target_arch.GetMachine()) {
  default:
    assert(false && "Unhandled target architecture.");
    return nullptr;
  }
}

uint32_t RegisterInfo_postrisc::GetRegisterInfoCount(
    const lldb_private::ArchSpec &target_arch) {
  switch (target_arch.GetMachine()) {
  default:
    assert(false && "Unhandled target architecture.");
    return 0;
  }
}

RegisterInfo_postrisc::RegisterInfo_postrisc(
    const lldb_private::ArchSpec &target_arch, lldb_private::Flags flags)
    : lldb_private::RegisterInfoAndSetInterface(target_arch),
      m_register_info_p(GetRegisterInfoPtr(target_arch)),
      m_register_info_count(GetRegisterInfoCount(target_arch)) {}

uint32_t RegisterInfo_postrisc::GetRegisterCount() const { return 0; }

size_t RegisterInfo_postrisc::GetGPRSize() const {
  return sizeof(struct RegisterInfo_postrisc::GPR);
}

size_t RegisterInfo_postrisc::GetFPRSize() const {
  return sizeof(struct RegisterInfo_postrisc::FPR);
}

const lldb_private::RegisterInfo *
RegisterInfo_postrisc::GetRegisterInfo() const {
  return m_register_info_p;
}

size_t RegisterInfo_postrisc::GetRegisterSetCount() const { return 0; }

size_t RegisterInfo_postrisc::GetRegisterSetFromRegisterIndex(
    uint32_t reg_index) const {
  return LLDB_INVALID_REGNUM;
}

const lldb_private::RegisterSet *
RegisterInfo_postrisc::GetRegisterSet(size_t set_index) const {
  return nullptr;
}
