include <BOSL2/std.scad>
include <BOSL2/hooks.scad>

// BOSL2挂环 示例。
// 每个文件只展示一个 BOSL2 常用结构，顶部参数用于快速调整尺寸和显示形式。
// 可直接复制模块调用到具体模型中使用。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 64;

// 底座宽度
base_x = 42;
// 底座厚度
base_y = 10;
// 孔中心高度
hole_z = 28;
// 外圆直径
outer_diam = 34;
// 内孔直径，0 表示实心
inner_diam = 18;
// 边缘圆角
rounding = 1.2;
// 底部过渡圆角
fillet = 2;

part_color = [0.78, 0.80, 0.76, 1.00];


color(part_color)
ring_hook(
    base_size=[base_x, base_y],
    hole_z=hole_z,
    od=outer_diam,
    id=inner_diam,
    rounding=rounding,
    fillet=fillet,
    hole_rounding=rounding,
    anchor=BOTTOM
);
