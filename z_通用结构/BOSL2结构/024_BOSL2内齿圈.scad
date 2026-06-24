include <BOSL2/std.scad>
include <BOSL2/gears.scad>

// 3D 打印内齿圈组件。
// 使用 BOSL2 ring_gear() 生成环形内齿圈，齿形在环内壁，可与外啮合齿轮配合
// 组成行星减速器的外圈。支持直齿和斜齿（helical），外圈带背厚（backing）加强。
// 适用于行星齿轮减速器、旋转传动环、内啮合齿轮传动等场景。
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
