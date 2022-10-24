add_llvm_component_library(LLVMPostriscDisassembler
  PostriscDisassembler.cpp

  LINK_COMPONENTS
  MCDisassembler
  MC
  PostriscInfo
  Support

  ADD_TO_COMPONENT
  Postrisc
  )
