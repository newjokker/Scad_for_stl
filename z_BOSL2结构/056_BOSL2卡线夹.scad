include <BOSL2/std.scad>
include <BOSL2/screws.scad>

// 3D 打印常用卡线夹结构。
// U 形槽固定线缆，中间留出圆弧线槽，两侧可用螺丝固定到底板。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 48;
// 打印配合间隙
$slop = 0.12;

// 线缆直径，单位 mm
cable_diam = 6;
// 线夹长度，单位 mm
clip_length = 34;
// 线夹宽度，单位 mm
clip_width = 18;
// 底板厚度，单位 mm
base_thick = 3;
// 线夹壁厚，单位 mm
wall = 3;
// 螺丝规格
screw_spec = "M3";

part_color = [0.78, 0.80, 0.76, 1.00];


color(part_color)
difference() {
    union() {
        cuboid([clip_length, clip_width, base_thick], rounding=1, edges="Z", anchor=BOTTOM);

        up(base_thick)
            rect_tube(
                h=clip_length,
                size=[cable_diam + 2 * wall, clip_width],
                wall=wall,
                rounding=1.2,
                anchor=CENTER,
                orient=RIGHT
            );
    }

    translate([0, 0, base_thick + cable_diam / 2])
        rotate([0, 90, 0])
            cyl(d=cable_diam, h=clip_length + 0.4, anchor=CENTER);

    for (x = [-clip_length * 0.32, clip_length * 0.32])
        translate([x, 0, base_thick + 0.05])
            screw_hole(screw_spec, length=base_thick + 0.2, anchor=TOP);
}
