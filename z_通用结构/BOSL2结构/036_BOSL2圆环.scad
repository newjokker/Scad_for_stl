include <BOSL2/std.scad>

// 3D 打印圆环（实体环）组件。
// 使用 BOSL2 torus() 生成实体圆环，可指定主半径（环半径）和截面半径（管半径）。
// 适用于密封圈、拉环、O 形环轮廓参考、滚轮接触面等场景。
// 可直接复制模块调用到具体模型中使用。

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
