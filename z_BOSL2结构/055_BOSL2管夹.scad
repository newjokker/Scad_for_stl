include <BOSL2/std.scad>
include <BOSL2/screws.scad>

// 3D 打印常用开口管夹结构。
// 中间夹持圆管，两侧耳片用螺丝收紧，适合固定杆件、软管和圆柱传感器。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 64;
// 打印配合间隙
$slop = 0.12;

// 被夹管外径，单位 mm
pipe_diam = 18;
// 管夹宽度，单位 mm
clamp_width = 16;
// 管夹壁厚，单位 mm
wall = 4;
// 开口缝宽，单位 mm
gap = 4;
// 耳片长度，单位 mm
tab_length = 14;
// 螺丝规格
screw_spec = "M3";

part_color = [0.78, 0.80, 0.76, 1.00];


module pipe_clamp() {
    outer_d = pipe_diam + 2 * wall;
    tab_y = outer_d / 2 + tab_length / 2;

    color(part_color)
    difference() {
        union() {
            tube(od=outer_d, id=pipe_diam, h=clamp_width, anchor=CENTER);

            ycopies(spacing=2 * tab_y, n=2)
                cuboid([outer_d, tab_length, clamp_width], rounding=1,
                    edges="Z", anchor=CENTER);
        }

        cuboid([gap, outer_d + 2 * tab_length + 2, clamp_width + 0.2], anchor=CENTER);

        for (y = [-tab_y, tab_y])
            translate([0, y, 0])
                rotate([90, 0, 0])
                    screw_hole(screw_spec, length=tab_length + 0.2, anchor=CENTER);
    }
}

pipe_clamp();
