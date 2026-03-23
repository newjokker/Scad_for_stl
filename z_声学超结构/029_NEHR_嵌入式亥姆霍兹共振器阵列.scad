
include <BOSL2/std.scad>
include <BOSL2/structs.scad>


$fn = 80;

// =====================================================
// NEHR (Neck-Embedded Helmholtz Resonator)
// 单个模型，带内部可视化
// =====================================================

// -------------------------
// 基本参数（单位：mm）
// -------------------------
a  = 12.9;   // 腔体内部长度（x方向）
b  = 13.9;   // 腔体内部宽度（y方向）
Hs = 29.4;   // 共振器总高度（z方向）
ts = 1.0;    // 外壳壁厚
de = 2.5;    // 内嵌方柱（neck）边长
le = 6.3;    // 内嵌方柱向下伸入长度


// 

module Hel(){
    difference(){
        // 外壳：注意 a,b 是内部尺寸，所以外形应加上两侧壁厚
        cuboid([a + 2*ts, b + 2*ts, Hs], anchor=[0, 0, -1]);

        // 内部空腔
        translate([0, 0, ts])
            cuboid([a, b, Hs - 2*ts - le], anchor=[0, 0, -1]);

        // neck 空气通道
        translate([0, 0, Hs - ts - le - 0.01])
            cuboid([de, de, le + ts + 0.02], anchor=[0, 0, -1]);
    }
}

difference(){
    Hel();
    cuboid([100, 100, 100], anchor=[-1, -1, 0]);
}






