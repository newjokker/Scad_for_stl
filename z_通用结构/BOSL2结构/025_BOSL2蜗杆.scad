include <BOSL2/std.scad>
include <BOSL2/gears.scad>

// 3D 打印蜗杆组件。
// 使用 BOSL2 worm() 生成蜗杆（螺杆状齿轮），可配合 BOSL2 齿轮或内齿圈实现大减速
// 比传动。支持多头（starts）和左右旋方向。
// 适用于蜗轮蜗杆减速器、高扭矩传动、自锁机构等场景。
// 可直接复制模块调用到具体模型中使用。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 64;

// 公制模数
mod_size = 1.5;
// 蜗杆直径
diam = 14;
// 蜗杆长度
length = 42;
// 头数
starts = 1;
// 是否左旋
left_handed = false;
// 压力角
pressure_angle = 20;

part_color = [0.95, 0.55, 0.16, 1.00];


color(part_color)
worm(
    mod=mod_size,
    d=diam,
    l=length,
    starts=starts,
    left_handed=left_handed,
    pressure_angle=pressure_angle,
    anchor=CENTER,
    orient=RIGHT
);
