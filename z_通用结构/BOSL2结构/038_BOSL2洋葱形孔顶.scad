include <BOSL2/std.scad>

// BOSL2 洋葱形孔顶结构示例。
// 使用 onion() 生成圆孔顶部的可打印尖顶，常用作大水平孔的免支撑顶部 mask。

// ---------------- 可调参数 ----------------
// 球形部分半径，单位 mm
radius = 18;
// 顶部锥角，单位 deg
angle = 45;
// 截断高度，单位 mm
cap_height = 26;
// 圆弧细分
$fn = 64;

part_color = [0.18, 0.48, 0.78, 1.00];


color(part_color)
onion(
    r=radius,
    ang=angle,
    cap_h=cap_height,
    anchor=BOTTOM
);
