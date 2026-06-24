include <BOSL2/std.scad>

// 3D 打印矩形管组件。
// 使用 BOSL2 rect_tube() 生成空心矩形管，可指定外尺寸和壁厚，外角可选圆角或倒角。
// 适用于方管连接、框架结构、外壳边框、线槽等场景。
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
