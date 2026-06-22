// helmholtz_lib.scad

include <BOSL2/std.scad>
use <tools/hh_cube.scad>;

$fn = 96;

// ---------------- 参数 ----------------
nx = 7;   // X方向数量
ny = 2;   // Y方向数量

cavity_length = 24.5;
cavity_width  = 21.3;
cavity_height = 20;

// neck_length = 10;
// neck_radius = 3.6;
wall_thickness = 1.0;

// 相邻 cube 共用一层墙
pitch_x = cavity_length + wall_thickness;
pitch_y = cavity_width  + wall_thickness;

// ---------------- 矩阵生成 ----------------
for (ix = [0 : nx - 1]) {
    for (iy = [0 : ny - 1]) {

        translate([
            (ix - (nx - 1) / 2) * pitch_x,
            (iy - (ny - 1) / 2) * pitch_y,
            0
        ])

        let(
            neck_length = ix * 1.5 + 5,
            neck_radius = 3.6 + iy
        )

        helmholtz_resonator(
            cavity_length = cavity_length,
            cavity_width = cavity_width,
            cavity_height = cavity_height,
            neck_length = neck_length,
            neck_radius = neck_radius,
            wall_thickness = wall_thickness,
            neck_direction = "inside",
            display_mode = "solid",
            show_frequency = true,
            frequency_text_size = 3,
            text_emboss_height = 0.8
        );
    }
}



