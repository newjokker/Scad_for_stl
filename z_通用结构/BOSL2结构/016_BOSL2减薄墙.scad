include <BOSL2/std.scad>
include <BOSL2/walls.scad>

// 3D 打印减薄三角加强墙。
// 使用 BOSL2 thinning_wall() 生成一侧厚一侧薄的渐变墙板，内部自动生成三角加强筋，
// 薄侧通过斜角减料减少打印材料同时保持结构刚度。
// 适用于需要单侧加强、边缘减薄的支架、立板和外壳侧壁场景。
// 可直接复制模块调用到具体模型中使用。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 48;

// 墙高
wall_height = 50;
// 墙长
wall_length = 90;
// 总厚度
wall_thick = 6;
// 斜面角
angle = 30;
// 是否加加强筋
braces = true;
// 加强筋宽
strut = 5;
// 薄壁厚度
wall = 2;

part_color = [0.78, 0.80, 0.76, 1.00];


color(part_color)
thinning_wall(
    h=wall_height,
    l=wall_length,
    thick=wall_thick,
    ang=angle,
    braces=braces,
    strut=strut,
    wall=wall,
    anchor=BOTTOM
);
