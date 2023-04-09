//===-- Z80.td - Z80 target definitions --------------------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

include "llvm/Target/Target.td"

//===----------------------------------------------------------------------===//
// Z80 Subtarget features
//===----------------------------------------------------------------------===//

// -mattr=で指定するもの「乗算機能」
def FeatureMulExt : SubtargetFeature<
  "mul",                           // Feature name.  Used by command line (-mattr=) to determine the appropriate target chip.
  "HasMul",                        // Attribute - Attribute to be set by feature.
  "true",                          // Value - Value the attribute to be set to by feature.
  "Integer Multiplication support" // Desc - Feature description.  Used by command line (-mattr=) to display help information.  
>;

//===----------------------------------------------------------------------===//
// Z80 processors supported.
//===----------------------------------------------------------------------===//

// -mcpu=で指定するもの「generic」
def : ProcessorModel<"generic", NoSchedModel, []>;

// -mcpu=で指定するもの「r800」
// ・R800の「乗算機能」を有効に
def : ProcessorModel<
  "r800",          // Name - Chip set name.  Used by command line (-mcpu=) to determine the appropriate target chip.
  NoSchedModel,    // SchedModel - The machine model for scheduling and instruction cost.
  [FeatureMulExt]  // Features - list of
>;

//===----------------------------------------------------------------------===//
// Register File Description
//===----------------------------------------------------------------------===//

include "Z80RegisterInfo.td"

//===----------------------------------------------------------------------===//
// Instruction Descriptions
//===----------------------------------------------------------------------===//

include "Z80InstrInfo.td"
def Z80InstrInfo : InstrInfo;

//===----------------------------------------------------------------------===//
// Calling Conventions
//===----------------------------------------------------------------------===//

//include "Z80CallingConv.td"

//===----------------------------------------------------------------------===//
// Assembly writer
//===----------------------------------------------------------------------===//

def Z80AsmParser : AsmParser {
  // Set to false if the target needs a hand written register name matcher
  let ShouldEmitMatchRegisterAltName = 1;
}

//def Z80AsmWriter : AsmWriter {
//  // Set to false if the target needs a hand written register name matcher
//  let ShouldEmitMatchRegisterAltName = 1;
//}

//===----------------------------------------------------------------------===//
// Define the Z80 target.
//===----------------------------------------------------------------------===//

def Z80 : Target {
  let InstructionSet = Z80InstrInfo;    // InstructionSet - Instruction set description for this target.
  let AssemblyParsers = [Z80AsmParser]; // AssemblyParsers - The AsmParser instances available for this target.
//  let AssemblyWriters = [Z80AsmWriter]; // AssemblyWriters - The AsmWriter instances available for this target.
}
