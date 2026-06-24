include <BOSL2/std.scad>

// 3D 打印常用薄壁圆角盒角结构。
// 用 rect_tube() 生成一段圆角矩形筒，适合作为盒体角部、保护套和外壳截面参考。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 48;

// 外部 X 尺寸，单位 mm
outer_x = 48;
// 外部 Y 尺寸，单位 mm
outer_y = 34;
// 高度，单位 mm
height = 24;
// 壁厚，单位 mm
wall = 2.4;
// 外角圆角，单位 mm
rounding = 5;

part_color = [0.78, 0.80, 0.76, 1.00];


color(part_color)
rect_tube(
    h=height,
    size=[outer_x, outer_y],
    wall=wall,
    rounding=rounding,
    anchor=BOTTOM
);
