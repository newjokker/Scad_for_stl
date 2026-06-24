include <BOSL2/std.scad>

// BOSL2圆管 示例。
// 每个文件只展示一个 BOSL2 常用结构，顶部参数用于快速调整尺寸和显示形式。
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
