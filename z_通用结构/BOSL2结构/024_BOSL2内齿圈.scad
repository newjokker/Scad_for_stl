include <BOSL2/std.scad>
include <BOSL2/gears.scad>

// BOSL2内齿圈 示例。
// 每个文件只展示一个 BOSL2 常用结构，顶部参数用于快速调整尺寸和显示形式。
// 可直接复制模块调用到具体模型中使用。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 64;

// 公制模数
mod_size = 1.4;
// 齿数
teeth = 42;
// 厚度
thickness = 8;
// 外圈背厚
backing = 5;
// 压力角
pressure_angle = 20;
// 斜齿角
helical = 0;

part_color = [0.95, 0.55, 0.16, 1.00];


color(part_color)
ring_gear(
    mod=mod_size,
    teeth=teeth,
    thickness=thickness,
    backing=backing,
    pressure_angle=pressure_angle,
    helical=helical,
    anchor=CENTER
);
