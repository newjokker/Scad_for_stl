include <BOSL2/std.scad>
include <BOSL2/gears.scad>

// 3D 打印齿条组件。
// 使用 BOSL2 rack() 生成带齿条齿形的线性齿条，可配合 BOSL2 齿轮将旋转运动
// 转换为直线运动。支持直齿和斜齿（helical），有自定义齿根底座高度。
// 适用于线性传动、齿条齿轮机构、滑台驱动、机械臂关节等场景。
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
