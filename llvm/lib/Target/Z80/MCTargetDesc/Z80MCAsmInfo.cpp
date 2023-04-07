// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

#include "Z80MCAsmInfo.h"
#include "llvm/TargetParser/Triple.h"
using namespace llvm;

void Z80MCAsmInfo::anchor() {}

Z80MCAsmInfo::Z80MCAsmInfo(const Triple &TT) {
  CodePointerSize = 2;
  CalleeSaveStackSlotSize = 2;
  CommentString = "#";
  SupportsDebugInformation = true;
}
