add_llvm_component_library(LLVMZ80Desc
  Z80MCTargetDesc.cpp
  Z80MCAsmInfo.cpp
  Z80AsmBackend.cpp
  Z80ELFObjectWriter.cpp
  Z80MCCodeEmitter.cpp

  LINK_COMPONENTS
  MC
  Z80Info
  Z80Desc
  Support

  ADD_TO_COMPONENT
  Z80
)
