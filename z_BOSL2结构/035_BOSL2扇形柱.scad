include <BOSL2/std.scad>

// 3D 打印扇形柱组件。
// 使用 BOSL2 pie_slice() 生成指定角度的圆柱扇区，可调节半径、角度和高度。
// 适用于旋转限位块、刻度盘、圆形分区隔板、角度指示器等场景。
// 可直接复制模块调用到具体模型中使用。

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
