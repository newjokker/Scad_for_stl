include <BOSL2/std.scad>

// BOSL2 水滴孔结构示例。
// 使用 teardrop() 生成适合横向 FDM 打印的水滴形孔或水滴形凸台。

// ---------------- 可调参数 ----------------
// 圆弧半径，单位 mm
radius = 12;
// 挤出长度，单位 mm
length = 34;
// 顶部夹角，单位 deg
angle = 45;
// 端面倒角，单位 mm
chamfer = 0.8;
// 圆弧细分
$fn = 64;

part_color = [0.18, 0.48, 0.78, 1.00];


color(part_color)
teardrop(
    r=radius,
    l=length,
    ang=angle,
    chamfer=chamfer,
    anchor=CENTER,
    orient=RIGHT
);
