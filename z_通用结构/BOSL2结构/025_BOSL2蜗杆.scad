include <BOSL2/std.scad>
include <BOSL2/gears.scad>

// BOSL2蜗杆 示例。
// 每个文件只展示一个 BOSL2 常用结构，顶部参数用于快速调整尺寸和显示形式。
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
