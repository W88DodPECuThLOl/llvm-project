// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

#include "Z80MCTargetDesc.h"
#include "Z80MCAsmInfo.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/MC/TargetRegistry.h"

#define GET_INSTRINFO_MC_DESC
#include "Z80GenInstrInfo.inc"

#define GET_REGINFO_MC_DESC
#include "Z80GenRegisterInfo.inc"

#define GET_SUBTARGETINFO_MC_DESC
#include "Z80GenSubtargetInfo.inc"

using namespace llvm;

static MCInstrInfo *createZ80MCInstrInfo() {
  MCInstrInfo *X = new MCInstrInfo();
  InitZ80MCInstrInfo(X);
  return X;
}

static MCRegisterInfo *createZ80MCRegisterInfo(const Triple &TT) {
  MCRegisterInfo *X = new MCRegisterInfo();
  InitZ80MCRegisterInfo(X, Z80::PC);
  return X;
}

static MCAsmInfo *createZ80MCAsmInfo(const MCRegisterInfo &MRI,
                                        const Triple &TT,
                                        const MCTargetOptions &Options) {
  return new Z80MCAsmInfo(TT);
}

static MCSubtargetInfo *
createZ80MCSubtargetInfo(const Triple &TT, StringRef CPU, StringRef FS) {
  std::string CPUName = std::string(CPU);
  if (CPUName.empty())
    CPUName = "generic-Z80";
  return createZ80MCSubtargetInfoImpl(TT, CPUName, CPUName, FS);
}

extern "C" void LLVMInitializeZ80TargetMC() {
  Target &T = getTheZ80Target();
  TargetRegistry::RegisterMCAsmInfo(T, createZ80MCAsmInfo);
  TargetRegistry::RegisterMCInstrInfo(T, createZ80MCInstrInfo);
  TargetRegistry::RegisterMCRegInfo(T, createZ80MCRegisterInfo);
  TargetRegistry::RegisterMCAsmBackend(T, createZ80AsmBackend);
  TargetRegistry::RegisterMCSubtargetInfo(T, createZ80MCSubtargetInfo);
  TargetRegistry::RegisterMCCodeEmitter(T, createZ80MCCodeEmitter);
}
