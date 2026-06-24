include <BOSL2/std.scad>

// BOSL2 扇形柱结构示例。
// 使用 pie_slice() 生成指定角度的圆柱扇区，可用于刻度盘、限位块和圆形分区件。

// ---------------- 可调参数 ----------------
// 扇形半径，单位 mm
radius = 32;
// 扇形角度，单位 deg
angle = 85;
// 扇形柱高度，单位 mm
height = 8;

part_color = [0.95, 0.55, 0.16, 1.00];


color(part_color)
pie_slice(
    r=radius,
    h=height,
    ang=angle,
    anchor=BOTTOM
);
