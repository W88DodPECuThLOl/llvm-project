add_llvm_component_group(Z80)

add_llvm_target(Z80CodeGen
  Z80TargetMachine.cpp

  LINK_COMPONENTS
  Core
  CodeGen
  Z80Info
  Support
  Target

  ADD_TO_COMPONENT
  Z80
  )
add_subdirectory(TargetInfo)
