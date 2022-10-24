add_llvm_component_library(LLVMPostriscInfo
  PostriscTargetInfo.cpp

  LINK_COMPONENTS
  MC
  Support

  ADD_TO_COMPONENT
  Postrisc
  )
