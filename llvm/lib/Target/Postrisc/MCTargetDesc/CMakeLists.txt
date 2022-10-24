add_llvm_component_library(LLVMPostriscDesc
  PostriscAsmBackend.cpp
  PostriscELFObjectWriter.cpp
  PostriscInstPrinter.cpp
  PostriscMCAsmInfo.cpp
  PostriscMCCodeEmitter.cpp
  PostriscMCTargetDesc.cpp
  PostriscMCExpr.cpp
  PostriscTargetStreamer.cpp

  LINK_COMPONENTS
  MC
  PostriscInfo
  Support
  TargetParser

  ADD_TO_COMPONENT
  Postrisc
  )
