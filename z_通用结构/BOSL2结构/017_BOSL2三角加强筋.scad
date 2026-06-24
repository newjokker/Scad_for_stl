include <BOSL2/std.scad>
include <BOSL2/walls.scad>

// BOSL2三角加强筋 示例。
// 每个文件只展示一个 BOSL2 常用结构，顶部参数用于快速调整尺寸和显示形式。
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
