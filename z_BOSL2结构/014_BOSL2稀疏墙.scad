include <BOSL2/std.scad>
include <BOSL2/walls.scad>

// 3D 打印轻量稀疏支撑墙。
// 使用 BOSL2 sparse_wall() 生成内部带三角形桁架网格的轻量墙板，
// 在保证抗弯刚度的同时最大限度减少材料，参数可控制最大桥接长度和悬垂角。
// 适用于大面积壳体侧壁、隔板、支架立板等需要减重降本的场景。
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
