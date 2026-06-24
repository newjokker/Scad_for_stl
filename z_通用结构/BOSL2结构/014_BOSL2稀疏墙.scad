include <BOSL2/std.scad>
include <BOSL2/walls.scad>

// BOSL2稀疏墙 示例。
// 每个文件只展示一个 BOSL2 常用结构，顶部参数用于快速调整尺寸和显示形式。
// 可直接复制模块调用到具体模型中使用。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 48;

// 墙高
wall_height = 48;
// 墙长
wall_length = 90;
// 墙厚
wall_thick = 4;
// 支撑筋宽
strut = 5;
// 最大桥接长度
max_bridge = 20;
// 最大悬垂角
max_angle = 30;

part_color = [0.78, 0.80, 0.76, 1.00];


color(part_color)
sparse_wall(
    h=wall_height,
    l=wall_length,
    thick=wall_thick,
    strut=strut,
    max_bridge=max_bridge,
    maxang=max_angle,
    anchor=BOTTOM
);
