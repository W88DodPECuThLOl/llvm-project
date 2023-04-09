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
// @param name レジスタ名
// @param enc  backendでのレジスタ識別子
// @param cost コスト
class Z80Reg<string name, bits<16> enc = -1, list<int> cost = [0]> : Register<name> {
  let Namespace  = "Z80"; // C++のnamespace
  let HWEncoding = enc;   // backendでのレジスタ識別子
  let CostPerUse = cost;  // レジスタ使った時のコスト
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
// メモ）16ビットレジスタを定義するときに組み合わせて使用
class Z80SubRegIndex<int size, int offset> : SubRegIndex<size, offset> {
  let Namespace  = "Z80"; // C++のnamespace
}

def subreg_hi : Z80SubRegIndex<8, 8>; // 16ビットレジスタの上位8ビット部分
def subreg_lo : Z80SubRegIndex<8, 0>; // 16ビットレジスタの下位8ビット部分

// サブレジスタで構成されている16ビットレジスタ
// @param name    レジスタ名
// @param Enc     backendでのレジスタ識別子？
// @param subregs サブレジスタ
// @param Cost    コスト
class Z80RegPair<string name, bits<16> enc, list<Register> subregs = [], list<int> cost = [0]> : Z80Reg<name, enc, cost> {
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

//===----------------------------------------------------------------------===//
//  Registers
//===----------------------------------------------------------------------===//

// 8 bit registers
def A   : Z80Reg<"a", 7>;
def F   : Z80Reg<"f">;
def B   : Z80Reg<"b", 0>;
def C   : Z80Reg<"c", 1>;
def D   : Z80Reg<"d", 2>;
def E   : Z80Reg<"e", 3>;
def H   : Z80Reg<"h", 4>;
def L   : Z80Reg<"l", 5>;
def IXH : Z80Reg<"ixh", 4, [1]>;
def IXL : Z80Reg<"ixl", 5, [1]>;
def IYH : Z80Reg<"iyh", 4, [1]>;
def IYL : Z80Reg<"iyl", 5, [1]>;

def A2  : Z80Reg<"a2", 7>;
def F2  : Z80Reg<"f2">;
def B2  : Z80Reg<"b2", 0>;
def C2  : Z80Reg<"c2", 1>;
def D2  : Z80Reg<"d2", 2>;
def E2  : Z80Reg<"e2", 3>;
def H2  : Z80Reg<"h2", 4>;
def L2  : Z80Reg<"l2", 5>;

// 16 bit registers
def BC : Z80RegPair<"bc", 0, [B,   C]>;
def DE : Z80RegPair<"de", 1, [D,   E]>;
def HL : Z80RegPair<"hl", 2, [H,   L]>;
def AF : Z80RegPair<"af", 3, [A,   F]>;
def IX : Z80RegPair<"ix", 2, [IXH, IXL], [1]>;
def IY : Z80RegPair<"iy", 2, [IYH, IYL], [1]>;

def BC2 : Z80RegPair<"bc2", 0, [B2, C2]>;
def DE2 : Z80RegPair<"de2", 1, [D2, E2]>;
def HL2 : Z80RegPair<"hl2", 2, [H2, L2]>;
def AF2 : Z80RegPair<"af2", 3, [A2, F2]>;

// misc registers
def SP : Z80Reg<"sp", 3>;
def PC : Z80Reg<"pc">;
def I  : Z80Reg<"i">;
def R  : Z80Reg<"r">;


//===----------------------------------------------------------------------===//
//  Register Class Definitions...
//

// 8ビットレジスタのクラス（まとまり）
// @param reglist レジスタリスト
//
// メモ）レジスタが確保される（割り当てられる）ときの順番を設定
class Z80RegClass8<dag reglist>
  : RegisterClass<
    "Z80", // namespace
    [i8],  // レジスタの型
    8,     // アライメント
    reglist> {
}

// 16ビットレジスタのクラス（まとまり）
// @param reglist レジスタリスト
//
// メモ）レジスタが確保される（割り当てられる）ときの順番を設定
class Z80RegClass16<dag reglist> : RegisterClass<"Z80", [i16], 8, reglist> {}





def RC8  : Z80RegClass8<(add A, B, C, D, E, H, L)>;
def RC16 : Z80RegClass16<(add BC, DE, HL, IX, IY)>;

def RC_EXR16 : Z80RegClass16<(add HL, DE)>;

// Fレジスタだけ
def RC8F : Z80RegClass8<(add F)>;
// Aレジスタだけ
def RC8A : Z80RegClass8<(add A)>;
// HLレジスタだけ
def RC16HL : Z80RegClass16<(add HL)>;
// AFレジスタだけ
def RC16AF : Z80RegClass16<(add AF)>;
// AF'レジスタだけ
def RC16AF2 : Z80RegClass16<(add AF2)>;


// メモ）裏レジスタの扱いは？
