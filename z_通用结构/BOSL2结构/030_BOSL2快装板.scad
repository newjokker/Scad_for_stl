include <BOSL2/std.scad>
include <BOSL2/tripod_mounts.scad>

// BOSL2快装板 示例。
// 每个文件只展示一个 BOSL2 常用结构，顶部参数用于快速调整尺寸和显示形式。
// 可直接复制模块调用到具体模型中使用。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 48;

// 倒角模式
chamfer_mode = "all";

part_color = [0.78, 0.80, 0.76, 1.00];


color(part_color)
manfrotto_rc2_plate(
    chamfer=chamfer_mode,
    anchor=BOTTOM
);
