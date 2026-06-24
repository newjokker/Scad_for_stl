include <BOSL2/std.scad>
include <BOSL2/walls.scad>

// 3D 打印波纹加强墙板。
// 使用 BOSL2 corrugated_wall() 生成正弦波纹截面的墙板，外层为连续波纹面，
// 内侧保持平直。波纹结构大幅提升薄壁件的抗弯刚度和抗翘曲能力。
// 适用于薄壁外壳侧板、装饰面板、需要轻量但高刚度的结构件场景。
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
