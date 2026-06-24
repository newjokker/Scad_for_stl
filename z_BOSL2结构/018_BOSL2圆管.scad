include <BOSL2/std.scad>

// 3D 打印圆管组件。
// 使用 BOSL2 tube() 生成空心圆筒，可指定外径内径和高度，端部可选圆角或倒角。
// 适用于管材连接件、轴套、垫圈、线缆护管、结构立柱等场景。
// 可直接复制模块调用到具体模型中使用。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 80;

// 外径
outer_diam = 32;
// 内径
inner_diam = 22;
// 高度
tube_height = 36;
// 端部圆角
rounding = 1.2;
// 端部倒角
chamfer = 0;

part_color = [0.78, 0.80, 0.76, 1.00];


color(part_color)
tube(
    h=tube_height,
    od=outer_diam,
    id=inner_diam,
    rounding=rounding,
    chamfer=chamfer,
    anchor=BOTTOM
);
