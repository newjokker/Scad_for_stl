include <BOSL2/std.scad>
include <BOSL2/screws.scad>

// 3D 打印常用圆柱支脚结构。
// 圆柱脚带底部圆角和中心螺丝孔，可用于设备脚垫、垫高柱和支撑脚。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 64;
// 打印配合间隙
$slop = 0.12;

// 支脚直径，单位 mm
foot_diam = 22;
// 支脚高度，单位 mm
foot_height = 12;
// 底部圆角，单位 mm
rounding = 2;
// 螺丝规格
screw_spec = "M4";
// 是否显示中心孔
show_hole = true;

part_color = [0.78, 0.80, 0.76, 1.00];


color(part_color)
difference() {
    cyl(d=foot_diam, h=foot_height, rounding=rounding, anchor=BOTTOM);

    if (show_hole)
        up(foot_height + 0.05)
            screw_hole(screw_spec, length=foot_height + 0.2, anchor=TOP);
}
