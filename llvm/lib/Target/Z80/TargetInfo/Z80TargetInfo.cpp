// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

#include "llvm/MC/TargetRegistry.h"

using namespace llvm;

namespace llvm {
Target &getTheZ80Target() {
  static Target TheZ80Target;
  return TheZ80Target;
}
} // namespace llvm

extern "C" LLVM_EXTERNAL_VISIBILITY void LLVMInitializeZ80TargetInfo() {
  RegisterTarget<Triple::z80> X(
    getTheZ80Target(), // Target
    "z80",             // name
    "Zilog Z80",       // Short description
    "Z80"              // Backend Name
  );
}
