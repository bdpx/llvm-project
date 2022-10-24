add_llvm_component_group(Postrisc HAS_JIT)

set(LLVM_TARGET_DEFINITIONS Postrisc.td)

llvm_tablegen(PostriscGenAsmMatcher.inc -gen-asm-matcher)
llvm_tablegen(PostriscGenAsmWriter.inc -gen-asm-writer)
llvm_tablegen(PostriscGenCallingConv.inc -gen-callingconv)
llvm_tablegen(PostriscGenDAGISel.inc -gen-dag-isel)
llvm_tablegen(PostriscGenDisassemblerTables.inc -gen-disassembler)
llvm_tablegen(PostriscGenInstrInfo.inc -gen-instr-info)
llvm_tablegen(PostriscGenMCCodeEmitter.inc -gen-emitter)
llvm_tablegen(PostriscGenRegisterInfo.inc -gen-register-info)
llvm_tablegen(PostriscGenSDNodeInfo.inc -gen-sd-node-info -sdnode-namespace=PostriscISD)
llvm_tablegen(PostriscGenSearchableTables.inc -gen-searchable-tables)
llvm_tablegen(PostriscGenSubtargetInfo.inc -gen-subtarget)

set(LLVM_TARGET_DEFINITIONS PostriscOptions.td)
llvm_tablegen(PostriscOptions.inc -gen-opt-parser-defs)

add_public_tablegen_target(PostriscCommonTableGen)

add_llvm_target(PostriscCodeGen
  PostriscAsmPrinter.cpp
  PostriscCodeGenPassBuilder.cpp
  PostriscBlockMergerPass.cpp
  PostriscBundlerPass.cpp
  PostriscInstrInfo.cpp
  PostriscISelDAGToDAG.cpp
  PostriscISelLowering.cpp
  PostriscFrameFixerPass.cpp
  PostriscFrameLowering.cpp
  PostriscMachineFunctionInfo.cpp
  PostriscMergeMovesPass.cpp
  PostriscNullificationPass.cpp
  PostriscOptAddrModePass.cpp
  PostriscRegisterInfo.cpp
  PostriscSelectionDAGInfo.cpp
  PostriscSubtarget.cpp
  PostriscTargetMachine.cpp
  PostriscTargetObjectFile.cpp
  PostriscTargetTransformInfo.cpp

  LINK_COMPONENTS
  Analysis
  AsmPrinter
  BinaryFormat
  CodeGen
  CodeGenTypes
  Core
  IPO
  MC
  Option
  Passes
  SelectionDAG
  PostriscDesc
  PostriscInfo
  Scalar
  Support
  Target
  TargetParser
  TransformUtils
  GlobalISel

  ADD_TO_COMPONENT
  Postrisc
  )

add_subdirectory(AsmParser)
add_subdirectory(Disassembler)
add_subdirectory(MCTargetDesc)
add_subdirectory(TargetInfo)
