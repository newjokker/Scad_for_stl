include <BOSL2/std.scad>
include <BOSL2/gears.scad>

// BOSL2齿条 示例。
// 每个文件只展示一个 BOSL2 常用结构，顶部参数用于快速调整尺寸和显示形式。
// 可直接复制模块调用到具体模型中使用。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 48;

// 公制模数
mod_size = 1.5;
// 齿数
teeth = 14;
// 厚度
thickness = 8;
// 齿根底座高度
bottom = 8;
// 压力角
pressure_angle = 20;
// 斜齿角
helical = 0;

part_color = [0.95, 0.55, 0.16, 1.00];


color(part_color)
rack(
    mod=mod_size,
    teeth=teeth,
    thickness=thickness,
    bottom=bottom,
    pressure_angle=pressure_angle,
    helical=helical,
    anchor=CENTER
);
