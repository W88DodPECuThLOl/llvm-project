//===-- Z80.td - Z80 target definitions --------------------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

include "llvm/Target/Target.td"

//===----------------------------------------------------------------------===//
// Register file, instruction descriptions.
//===----------------------------------------------------------------------===//

include "Z80RegisterInfo.td"
include "Z80InstrInfo.td"

//===----------------------------------------------------------------------===//
// Z80 processors supported.
//===----------------------------------------------------------------------===//

//
// -mattr=で指定するもの
//

// 乗算機能のサポート
def FeatureMExt : SubtargetFeature<"m", "is_enable_M", "true",
    "'M' Integer Multiplication support">;

//
// -mcpu=で指定するもの
//

// Z80
def : ProcessorModel<"generic", NoSchedModel, []>;
// R800
def : ProcessorModel<"r800", NoSchedModel, [FeatureMExt]>;

//===----------------------------------------------------------------------===//
// Define the Z80 target.
//===----------------------------------------------------------------------===//

def Z80InstrInfo : InstrInfo;


def Z80AsmParser : AsmParser {
  // Use alternative names of registers when emitting.
  let ShouldEmitMatchRegisterAltName = 1;
}

//def Z80AsmWriter : AsmWriter {
//  // Use alternative names of registers when emitting.
//  let ShouldEmitMatchRegisterAltName = 1;
//}

def Z80 : Target {
  let InstructionSet = Z80InstrInfo;
  let AssemblyParsers = [Z80AsmParser];
}
