add_llvm_component_group(Z80)

set(LLVM_TARGET_DEFINITIONS Z80.td)

tablegen(LLVM Z80GenRegisterInfo.inc -gen-register-info)
tablegen(LLVM Z80GenInstrInfo.inc -gen-instr-info)
tablegen(LLVM Z80GenMCCodeEmitter.inc -gen-emitter)
tablegen(LLVM Z80GenSubtargetInfo.inc -gen-subtarget)
tablegen(LLVM Z80GenAsmMatcher.inc -gen-asm-matcher)
tablegen(LLVM Z80GenAsmWriter.inc -gen-asm-writer)

add_public_tablegen_target(Z80CommonTableGen)

add_llvm_target(Z80CodeGen
  Z80TargetMachine.cpp

  LINK_COMPONENTS
  Core
  CodeGen
  Z80Info
  Z80Desc
  Support
  Target

  ADD_TO_COMPONENT
  Z80
  )
  add_subdirectory(AsmParser)
  add_subdirectory(MCTargetDesc)
  add_subdirectory(TargetInfo)
