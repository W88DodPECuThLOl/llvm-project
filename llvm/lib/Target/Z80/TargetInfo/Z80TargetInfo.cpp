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

extern "C" void LLVMInitializeZ80TargetInfo() {
  RegisterTarget<Triple::z80> X(getTheZ80Target(), "z80", "Z80",
                                   "Z80");
}

// FIXME: Temporary stub - this function must be defined for linking
// to succeed and will be called unconditionally by llc, so must be a no-op.
// Remove once this function is properly implemented.
extern "C" void LLVMInitializeZ80TargetMC() {}
