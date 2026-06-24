include <BOSL2/std.scad>
include <BOSL2/walls.scad>

// BOSL2波纹墙 示例。
// 每个文件只展示一个 BOSL2 常用结构，顶部参数用于快速调整尺寸和显示形式。
// 可直接复制模块调用到具体模型中使用。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 48;

// 墙高
wall_height = 46;
// 墙长
wall_length = 90;
// 总厚度
wall_thick = 6;
// 波纹节距
strut = 6;
// 壁厚
wall = 2;

part_color = [0.78, 0.80, 0.76, 1.00];


color(part_color)
corrugated_wall(
    h=wall_height,
    l=wall_length,
    thick=wall_thick,
    strut=strut,
    wall=wall,
    anchor=BOTTOM
);
