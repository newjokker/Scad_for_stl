include <BOSL2/std.scad>

// 3D 打印水滴形孔/凸台组件。
// 使用 BOSL2 teardrop() 生成顶部为尖拱的水滴形截面柱体，横向打印时无需支撑。
// 适用于横向螺丝孔、轴孔、减重孔等需要避免悬垂的区域，大幅提升孔内打印质量。
// 可直接复制模块调用到具体模型中使用。

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
