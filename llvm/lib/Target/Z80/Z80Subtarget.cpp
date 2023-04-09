//===-- Z80Subtarget.cpp - Z80 Subtarget Information ----------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the Z80 specific subclass of TargetSubtargetInfo.
//
//===----------------------------------------------------------------------===//

#include "Z80Subtarget.h"
#include "GISel/Z80CallLowering.h"
#include "GISel/Z80LegalizerInfo.h"
#include "GISel/Z80RegisterBankInfo.h"

#include "Z80.h"
#include "Z80MachineFunction.h"
#include "Z80RegisterInfo.h"
#include "Z80TargetMachine.h"

#include "llvm/CodeGen/MachineJumpTableInfo.h"
#include "llvm/IR/Attributes.h"
#include "llvm/IR/Function.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/ErrorHandling.h"

//#include "llvm/CodeGen/GlobalISel/InstructionSelect.h"
//#include "MCTargetDesc/Z80MCTargetDesc.h"
//#include "GISel/Z80InlineAsmLowering.h"
//#include "GISel/Z80LegalizerInfo.h"
//#include "llvm/CodeGen/GlobalISel/InlineAsmLowering.h"

using namespace llvm;

#define DEBUG_TYPE "z80-subtarget"

#define GET_SUBTARGETINFO_TARGET_DESC
#define GET_SUBTARGETINFO_CTOR
#include "Z80GenSubtargetInfo.inc"

Z80Subtarget &Z80Subtarget::initializeSubtargetDependencies(
  StringRef CPU,
  Triple TT, 
  StringRef TuneCPU,
  StringRef FS,
  const Z80TargetMachine &TM) {
  if (CPU.empty()) {
    CPU = "generic";
  }
  if (TuneCPU.empty()) {
    TuneCPU = CPU;
  }

  // Parse features string.
  ParseSubtargetFeatures(CPU, TuneCPU, FS);

  // Initialize scheduling itinerary for the specified CPU.
  InstrItins = getInstrItineraryForCPU(CPU);

  return *this;
}

Z80Subtarget::Z80Subtarget(const Triple &TT, StringRef CPU, StringRef TuneCPU,
                           StringRef FS, const Z80TargetMachine &TM)
    : Z80GenSubtargetInfo(TT, CPU, TuneCPU, FS)
    , TM(TM)
    , InstrInfo(initializeSubtargetDependencies(CPU, TT, TuneCPU, FS, TM))
    , TLInfo(TM, *this)
    , FrameLowering(*this)
    , TargetTriple(TT) {
  CallLoweringInfo.reset(new Z80CallLowering(*getTargetLowering()));
  //InlineAsmLoweringInfo.reset(new Z80InlineAsmLowering(*getTargetLowering()));
  Legalizer.reset(new Z80LegalizerInfo(*this, TM));

  auto *RBI = new Z80RegisterBankInfo(*getRegisterInfo());
  RegBankInfo.reset(RBI);
  InstSelector.reset(createZ80InstructionSelector(TM, *this, *RBI));
}

const CallLowering *Z80Subtarget::getCallLowering() const {
  return CallLoweringInfo.get();
}

InstructionSelector *Z80Subtarget::getInstructionSelector() const {
  return InstSelector.get();
}

const LegalizerInfo *Z80Subtarget::getLegalizerInfo() const {
  return Legalizer.get();
}

const RegisterBankInfo *Z80Subtarget::getRegBankInfo() const {
  return RegBankInfo.get();
}
