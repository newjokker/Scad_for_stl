include <BOSL2/std.scad>

// BOSL2矩形管 示例。
// 每个文件只展示一个 BOSL2 常用结构，顶部参数用于快速调整尺寸和显示形式。
// 可直接复制模块调用到具体模型中使用。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 48;

// 外部长
size_x = 48;
// 外部宽
size_y = 30;
// 高度
height = 34;
// 壁厚
wall = 3;
// 外角圆角
rounding = 2;
// 外角倒角
chamfer = 0;

part_color = [0.78, 0.80, 0.76, 1.00];


color(part_color)
rect_tube(
    h=height,
    size=[size_x, size_y],
    wall=wall,
    rounding=rounding,
    chamfer=chamfer,
    anchor=BOTTOM
);
