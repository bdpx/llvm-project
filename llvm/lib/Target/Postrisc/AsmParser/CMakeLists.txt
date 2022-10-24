add_llvm_component_library(LLVMPostriscAsmParser
  PostriscAsmParser.cpp

  LINK_COMPONENTS
  MC
  MCParser
  PostriscDesc
  PostriscInfo
  Support
  TargetParser

  ADD_TO_COMPONENT
  Postrisc
  )
