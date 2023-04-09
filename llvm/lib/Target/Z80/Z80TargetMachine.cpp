// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

#include "Z80TargetMachine.h"
#include "Z80.h"
#include "Z80MachineFunction.h"
#include "Z80Subtarget.h"
#include "Z80TargetObjectFile.h"
#include "TargetInfo/Z80TargetInfo.h"

#include "llvm/CodeGen/GlobalISel/IRTranslator.h"
#include "llvm/CodeGen/GlobalISel/InstructionSelect.h"
#include "llvm/CodeGen/GlobalISel/Legalizer.h"
#include "llvm/CodeGen/GlobalISel/RegBankSelect.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/CodeGen/TargetPassConfig.h"
#include "llvm/InitializePasses.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/PassRegistry.h"
#include <memory>
#include <optional>

//#include "llvm/CodeGen/Passes.h"
//#include "llvm/CodeGen/TargetLoweringObjectFileImpl.h"
//#include "llvm/CodeGen/TargetPassConfig.h"
//#include "llvm/ADT/STLExtras.h"
//#include "llvm/IR/LegacyPassManager.h"
//#include "llvm/Support/FormattedStream.h"
//#include "llvm/MC/TargetRegistry.h"
//#include "llvm/Target/TargetOptions.h"

using namespace llvm;

#define DEBUG_TYPE "z80"

extern "C" LLVM_EXTERNAL_VISIBILITY void LLVMInitializeZ80Target() {
  RegisterTargetMachine<Z80TargetMachine> X(getTheZ80Target());
  auto *PR = PassRegistry::getPassRegistry();
  initializeGlobalISel(*PR);
  initializeZ80DAGToDAGISelPass(*PR);
}

namespace {

/**
 * @brief datalayoutを割り出す
 * @param[in] TT  アーキテクチャ等の情報
 * @return datalayoutの文字列
 */
std::string computeDataLayout(const Triple &TT, StringRef CPU,
                              const TargetOptions &Options) {
  // datalayoutのドキュメント
  // https://llvm.org/docs/LangRef.html#langref-datalayout
  return
    "e"        // Little endian
    "-m:e"     // ELF name manging
    "-p:16:8"  // 16-bit pointers, 8 bit aligned
    "-i8:8"    //  8 bit integers, 8 bit aligned
    "-i16:8"   // 16 bit integers, 8 bit aligned
    "-i32:8"   // 32 bit integers, 8 bit aligned
    "-i64:8"   // 64 bit integers, 8 bit aligned
    "-f32:8"   // float, 8 bit aligned
    "-f64:8"   // double, 8 bit aligned
    "-a:8"     // the alignment for an object of aggregate type
    "-n8:16"   //  8 bit and 16bit native integer widths // メモ)8bitと16bitの計算ができるので2つ設定
  ;
}

/**
 * @return Relocation model type
 */
Reloc::Model getEffectiveRelocModel(const Triple &TT,
                                           std::optional<Reloc::Model> RM) {
  // If not defined we default to static
  if (!RM.has_value())
    return Reloc::Static;
  return *RM;
}

} // end anonymous namespace


Z80TargetMachine::Z80TargetMachine(const Target &T, const Triple &TT,
                                         StringRef CPU, StringRef FS,
                                         const TargetOptions &Options,
                                         std::optional<Reloc::Model> RM,
                                         std::optional<CodeModel::Model> CM,
                                         CodeGenOpt::Level OL, bool JIT)
    : LLVMTargetMachine(T, computeDataLayout(TT, CPU, Options), TT, CPU, FS,
                        Options,
                        getEffectiveRelocModel(TT, RM),
                        getEffectiveCodeModel(CM, CodeModel::Small), OL),
      TLOF(std::make_unique<TargetLoweringObjectFileELF>()),
      Subtarget(TT, CPU, FS, *this) {
  initAsmInfo();
}

Z80TargetMachine::~Z80TargetMachine() {}

const Z80Subtarget *
Z80TargetMachine::getSubtargetImpl(const Function &F) const {
  Attribute CPUAttr = F.getFnAttribute("target-cpu");
  Attribute TuneAttr = F.getFnAttribute("tune-cpu");
  Attribute FSAttr = F.getFnAttribute("target-features");

  auto CPU = CPUAttr.isValid() ? CPUAttr.getValueAsString().str() : TargetCPU;
  auto TuneCPU = TuneAttr.isValid() ? TuneAttr.getValueAsString().str() : CPU;
  auto FS = FSAttr.isValid() ? FSAttr.getValueAsString().str() : TargetFS;

  auto &I = SubtargetMap[CPU + FS];
  if (!I) {
    // This needs to be done before we create a new subtarget since any
    // creation will depend on the TM and the code generation flags on the
    // function that reside in TargetOptions.
    resetTargetOptions(F);
    I = std::make_unique<Z80Subtarget>(TargetTriple, CPU, TuneCPU, FS, *this);
  }
  return I.get();
}

MachineFunctionInfo *Z80TargetMachine::createMachineFunctionInfo(
    BumpPtrAllocator &Allocator, const Function &F,
    const TargetSubtargetInfo *STI) const {
  return Z80MachineFunctionInfo::create<Z80MachineFunctionInfo>(Allocator, F,
                                                                  STI);
}


TargetPassConfig *Z80TargetMachine::createPassConfig(PassManagerBase &PM) {
  return new TargetPassConfig(*this, PM);
}
