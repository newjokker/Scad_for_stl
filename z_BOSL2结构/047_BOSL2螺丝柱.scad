include <BOSL2/std.scad>
include <BOSL2/screws.scad>

// 3D 打印常用螺丝柱结构。
// 中间为自攻或通孔螺丝孔，外圈为圆柱加强柱，可直接放进盒体或支架内部。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 64;
// 打印配合间隙
$slop = 0.12;

// 螺丝规格
screw_spec = "M3";
// 螺丝柱外径，单位 mm
post_diam = 10;
// 螺丝柱高度，单位 mm
post_height = 16;
// 底部加强盘直径，单位 mm
base_diam = 16;
// 底部加强盘高度，单位 mm
base_height = 2;
// 孔类型：clearance 为通孔，selftap 为自攻孔，threaded 为内螺纹孔
hole_mode = "selftap";     // [clearance, selftap, threaded]

part_color = [0.78, 0.80, 0.76, 1.00];


module screw_post() {
    hole_thread = hole_mode == "threaded" ? true : false;
    hole_tol = hole_mode == "selftap" ? "self tap" : "normal";

    color(part_color)
    difference() {
        union() {
            cyl(d=base_diam, h=base_height, rounding2=0.6, anchor=BOTTOM);
            up(base_height)
                cyl(d=post_diam, h=post_height, rounding2=0.6, anchor=BOTTOM);
        }

        up(base_height + post_height + 0.05)
            screw_hole(
                screw_spec,
                length=base_height + post_height + 0.2,
                thread=hole_thread,
                tolerance=hole_tol,
                anchor=TOP
            );
    }
}

screw_post();
