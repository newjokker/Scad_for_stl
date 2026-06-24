include <BOSL2/std.scad>

// 3D 打印洋葱形孔顶（免支撑孔顶 mask）组件。
// 使用 BOSL2 onion() 生成洋葱形尖顶，作为大水平圆孔的顶部收口 mask，
// 横向打印时形成自支撑尖拱，无需内部支撑材料。
// 适用于横向大圆孔（如轴承孔、管道孔）的免支撑设计场景。
// 可直接复制模块调用到具体模型中使用。

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
