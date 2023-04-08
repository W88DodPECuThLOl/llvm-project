// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

#include "Z80TargetMachine.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/CodeGen/TargetLoweringObjectFileImpl.h"
#include "llvm/CodeGen/TargetPassConfig.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Support/FormattedStream.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/Target/TargetOptions.h"
using namespace llvm;

extern "C" void LLVMInitializeZ80Target() {
  RegisterTargetMachine<Z80TargetMachine> X(getTheZ80Target());
}

/**
 * @brief datalayoutを割り出す
 * @param[in] TT  アーキテクチャ等の情報
 * @return datalayoutの文字列
 */
static std::string computeDataLayout(const Triple &TT) {
  // datalayoutのドキュメント
  // https://llvm.org/docs/LangRef.html#langref-datalayout
  return
    "e"        // Little endian
    "-m:e"     // ELF name manging
    "-p:16:8"  // 16-bit pointers, 8 bit aligned
    "-i8:8"    //  8 bit integers, 8 bit aligned
    "-i16:8"   // 16 bit integers, 8 bit aligned
    "-n8:16"   //  8 bit and 16bit native integer widths // メモ)8bitと16bitの計算ができるので2つ設定
  ;
}

/**
 * @return Relocation model type
 */
static Reloc::Model getEffectiveRelocModel(const Triple &TT,
                                           std::optional<Reloc::Model> RM) {
  if (!RM.has_value())
    return Reloc::Static;
  return *RM;
}

Z80TargetMachine::Z80TargetMachine(const Target &T, const Triple &TT,
                                         StringRef CPU, StringRef FS,
                                         const TargetOptions &Options,
                                         std::optional<Reloc::Model> RM,
                                         std::optional<CodeModel::Model> CM,
                                         CodeGenOpt::Level OL, bool JIT)
    : LLVMTargetMachine(T, computeDataLayout(TT), TT, CPU, FS, Options,
                        getEffectiveRelocModel(TT, RM),
                        getEffectiveCodeModel(CM, CodeModel::Small), OL),
      TLOF(std::make_unique<TargetLoweringObjectFileELF>()) {
  initAsmInfo();
}

TargetPassConfig *Z80TargetMachine::createPassConfig(PassManagerBase &PM) {
  return new TargetPassConfig(*this, PM);
}
