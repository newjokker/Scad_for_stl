include <BOSL2/std.scad>
include <BOSL2/walls.scad>

// 3D 打印三角加强筋板。
// 使用 BOSL2 thinning_triangle() 生成内部为桁架结构的三角加强板，
// 可单独使用或成对作为 L 形角撑，可选仅对角筋模式（diagonly）。
// 适用于 L 形支架角部加强、箱体边缘防变形、垂直板连接等场景。
// 可直接复制模块调用到具体模型中使用。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 48;

// 高度
height = 42;
// 长度
length = 70;
// 厚度
thick = 5;
// 减薄角
angle = 30;
// 筋宽
strut = 5;
// 外壁宽
wall = 3;
// 是否只保留对角筋
diag_only = false;

part_color = [0.78, 0.80, 0.76, 1.00];


color(part_color)
thinning_triangle(
    h=height,
    l=length,
    thick=thick,
    ang=angle,
    strut=strut,
    wall=wall,
    diagonly=diag_only,
    anchor=BOTTOM
);
