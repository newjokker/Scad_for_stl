include <BOSL2/std.scad>
include <BOSL2/modular_hose.scad>

// BOSL2模块化软管 示例。
// 每个文件只展示一个 BOSL2 常用结构，顶部参数用于快速调整尺寸和显示形式。
// 可直接复制模块调用到具体模型中使用。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 64;

// 软管标准尺寸
hose_size = 1/2;
// 结构类型
hose_type = "segment";
// 配合间隙
clearance = 0.06;
// 中间腰部长度
waist_len = 8;

part_color = [0.95, 0.55, 0.16, 1.00];


color(part_color)
modular_hose(
    size=hose_size,
    type=hose_type,
    clearance=clearance,
    waist_len=waist_len,
    anchor=BOTTOM
);
