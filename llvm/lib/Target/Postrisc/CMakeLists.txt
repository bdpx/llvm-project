add_llvm_component_group(Postrisc HAS_JIT)

set(LLVM_TARGET_DEFINITIONS Postrisc.td)

tablegen(LLVM PostriscGenAsmMatcher.inc -gen-asm-matcher)
tablegen(LLVM PostriscGenAsmWriter.inc -gen-asm-writer)
tablegen(LLVM PostriscGenCallingConv.inc -gen-callingconv)
tablegen(LLVM PostriscGenDAGISel.inc -gen-dag-isel)
tablegen(LLVM PostriscGenDisassemblerTables.inc -gen-disassembler)
tablegen(LLVM PostriscGenInstrInfo.inc -gen-instr-info)
tablegen(LLVM PostriscGenMCCodeEmitter.inc -gen-emitter)
tablegen(LLVM PostriscGenRegisterInfo.inc -gen-register-info)
tablegen(LLVM PostriscGenSDNodeInfo.inc -gen-sd-node-info -sdnode-namespace=PostriscISD)
tablegen(LLVM PostriscGenSearchableTables.inc -gen-searchable-tables)
tablegen(LLVM PostriscGenSubtargetInfo.inc -gen-subtarget)

add_public_tablegen_target(PostriscCommonTableGen)

add_llvm_target(PostriscCodeGen
  PostriscPasses.cpp
  PostriscAsmPrinter.cpp
  PostriscBundlerPass.cpp
  PostriscInstrInfo.cpp
  PostriscISelDAGToDAG.cpp
  PostriscISelLowering.cpp
  PostriscFrameFixer.cpp
  PostriscFrameLowering.cpp
  PostriscMachineFunctionInfo.cpp
  PostriscMergeMovesPass.cpp
  PostriscNullificationPass.cpp
  PostriscOptAddrMode.cpp
  PostriscRegisterInfo.cpp
  PostriscSelectionDAGInfo.cpp
  PostriscSubtarget.cpp
  PostriscTargetMachine.cpp
  PostriscTargetObjectFile.cpp

  LINK_COMPONENTS
  Analysis
  AsmPrinter
  BinaryFormat
  CodeGen
  CodeGenTypes
  Core
  IPO
  MC
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
