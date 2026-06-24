include <BOSL2/std.scad>
include <BOSL2/gears.scad>

// BOSL2齿轮 示例。
// 每个文件只展示一个 BOSL2 常用结构，顶部参数用于快速调整尺寸和显示形式。
// 可直接复制模块调用到具体模型中使用。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 64;

// 公制模数
mod_size = 1.5;
// 齿数
teeth = 24;
// 齿轮厚度
thickness = 8;
// 轴孔直径
shaft_diam = 5;
// 压力角
pressure_angle = 20;
// 斜齿角
helical = 0;
// 是否做人字齿
herringbone = false;

gear_color = [0.95, 0.55, 0.16, 1.00];


color(gear_color)
spur_gear(
    mod=mod_size,
    teeth=teeth,
    thickness=thickness,
    shaft_diam=shaft_diam,
    pressure_angle=pressure_angle,
    helical=helical,
    herringbone=herringbone,
    anchor=CENTER
);
