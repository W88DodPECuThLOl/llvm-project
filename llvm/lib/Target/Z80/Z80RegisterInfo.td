//===- Z80RegisterInfo.td - Describe the Z80 Register Info ----*- tblgen -*-==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Declaration that describes the Z80 register file
//===----------------------------------------------------------------------===//

// レジスタの定義
// @param n    レジスタ名
// @param Enc  backendでのレジスタ識別子？
// @param Cost コスト
class Z80Reg<string n, bits<16> Enc = 0, list<int> Cost = [0]>
  : Register<n> {
  // C++のnamespaceになる？
  let Namespace  = "Z80";

  // backendでのレジスタ識別子？
  let HWEncoding = Enc;

  // レジスタ使った時のコスト？
  let CostPerUse = Cost;

  // メモ）letは親クラスにより設定された値を上書きする
}

// サブレジスタの占有部分を設定
// @param size   ビット数
// @param offset ビット位置
// 
// Size - Size (in bits) of the sub-registers represented by this index.
// Offset - Offset of the first bit that is part of this sub-register index.
// Set it to -1 if the same index is used to represent sub-registers that can
// be at different offsets (for example when using an index to access an
// element in a register tuple).
//
// 例）Z80SubRegIndex<8, 8>; // 8～15ビットを占有する
// 例）Z80SubRegIndex<8, 0>; // 0～7ビットを占有する
// メモ）16ビットレジスタを定義するときに組み合わせて使っている。
class Z80SubRegIndex<int size, int offset = 0> : SubRegIndex<size, offset> {
  let Namespace = "Z80";
}

def subreg_hi : Z80SubRegIndex<8, 8>; // 16ビットレジスタの上位8ビット部分
def subreg_lo : Z80SubRegIndex<8, 0>; // 16ビットレジスタの下位8ビット部分

// サブレジスタで構成されている16ビットレジスタ
// @param n       レジスタ名
// @param Enc     backendでのレジスタ識別子？
// @param subregs サブレジスタ
// @param Cost    コスト
class Z80RegWithSubRegs<string n, bits<16> Enc = 0, list<Register> subregs = [], list<int> Cost = [0]>
  : Z80Reg<n, Enc, Cost> {

  // レジスタを構成するサブレジスタの要素
  //
  // 例）HLレジスタは、HレジスタとLレジスタから構成されるので、[H, L]を設定。
  // 注意）サブレジスタが重なっているものは駄目。例）x64のEAXのAXやALなど重なっているので駄目。
  let SubRegs = subregs;

  // 各サブレジスタがレジスタのどの部分をカバーするのかの設定
  //
  // 下は、
  //   １個目のサブレジスタが16ビットレジスタの上位8ビット
  //   ２個目のサブレジスタが16ビットレジスタの下位8ビット
  //  となるように、レジスタを設定している。
  // 注意）サブレジスタどうしは重なっては行けない。
  let SubRegIndices = [subreg_hi, subreg_lo];

  // サブレジスタで、レジスタ全体をカバーしているかどうか。
  //
  // メモ）16ビットレジスタを、上位8ビット、下位8ビットのサブレジスタで全て占めているので1
  //
  // CoveredBySubRegs - When this bit is set, the value of this register is
  // completely determined by the value of its sub-registers.  For example, the
  // x86 register AX is covered by its sub-registers AL and AH, but EAX is not
  // covered by its sub-register AX.
  let CoveredBySubRegs = 1;
}

// 8ビットレジスタのクラス（まとまり）
// @param reglist レジスタリスト
//
// メモ）レジスタが確保される（割り当てられる）ときの順番を設定
class Z80Reg8Class<dag reglist>
  : RegisterClass<
    "Z80", // namespace
    [i8],  // レジスタタイプ
    8,     // アライメント
    reglist> {
}

// 16ビットレジスタのクラス（まとまり）
// @param reglist レジスタリスト
//
// メモ）レジスタが確保される（割り当てられる）ときの順番を設定
class Z80Reg16Class<dag reglist>
  : RegisterClass<"Z80", [i16], 8, reglist> {
}

//===----------------------------------------------------------------------===//
//  Registers
//===----------------------------------------------------------------------===//

// 8 bit registers
def A : Z80Reg<"a", 7>;
def B : Z80Reg<"b", 0>;
def C : Z80Reg<"c", 1>;
def D : Z80Reg<"d", 2>;
def E : Z80Reg<"e", 3>;
def H : Z80Reg<"h", 4>;
def L : Z80Reg<"l", 5>;
def XH : Z80Reg<"xh", 4, [1]>;
def XL : Z80Reg<"xl", 5, [1]>;
def YH : Z80Reg<"yh", 4, [1]>;
def YL : Z80Reg<"yl", 5, [1]>;

// Flags register
def FLAGS : Z80Reg<"f">;

// 16 bit registers
def BC : Z80RegWithSubRegs<"bc", 0, [B, C]>;
def DE : Z80RegWithSubRegs<"de", 1, [D, E]>;
def HL : Z80RegWithSubRegs<"hl", 2, [H, L]>;
def AF : Z80RegWithSubRegs<"af", 3, [A, FLAGS]>;
def IX : Z80RegWithSubRegs<"ix", 2, [XH, XL], [1]>;
def IY : Z80RegWithSubRegs<"iy", 2, [YH, YL], [1]>;

def SP : Z80Reg<"sp">;
def PC : Z80Reg<"pc">;

def GR8  : Z80Reg8Class<(add A, B, C, D, E, H, L)>;
def GR16 : Z80Reg16Class<(add BC, DE, HL, IX, IY)>;
def BR16 : Z80Reg16Class<(add BC, DE, HL)>;
def IR16 : Z80Reg16Class<(add IX, IY)>;

def EXR16 : Z80Reg16Class<(add HL, DE)>;

def OnlyA : Z80Reg8Class<(add A)>;
// HLレジスタだけ使用可能
def ONLY_HL : Z80Reg16Class<(add HL)>;


// メモ）IXH,IXL,IYH,IYLの扱いは？
// メモ）裏レジスタの扱いは？
