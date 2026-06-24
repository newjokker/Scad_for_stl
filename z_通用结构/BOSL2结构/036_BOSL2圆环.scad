include <BOSL2/std.scad>

// BOSL2 圆环结构示例。
// 使用 torus() 生成实体圆环，可用于密封圈、拉环、滚动接触轮廓等外形参考。

// ---------------- 可调参数 ----------------
// 主半径，单位 mm
major_radius = 24;
// 截面半径，单位 mm
minor_radius = 5;
// 圆弧细分
$fn = 96;

part_color = [0.78, 0.80, 0.76, 1.00];


color(part_color)
torus(
    r_maj=major_radius,
    r_min=minor_radius,
    anchor=CENTER
);
