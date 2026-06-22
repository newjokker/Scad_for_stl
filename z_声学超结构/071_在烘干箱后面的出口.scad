include <BOSL2/std.scad>



$fn = 160;

width = 90;
length = 180;
height = 150;
thickness = 2;

body_corner_r = 6;

side_window_length = length - 16;
side_window_height = 92;
side_window_bottom = 16;
side_window_corner_r = 10;
side_window_depth = thickness + 8;

// 顶部渐缩出口参数：底部接整个箱体上口，顶部收成较小的排气口
top_outlet_length = 110;
top_outlet_width = 55;
top_taper_height = 60;
top_straight_height = 25;
top_corner_r = 14;

module rounded_rect_2d(l, w, r=0) {
    r_use = min(r, l / 2 - 0.01, w / 2 - 0.01);

    if (r_use > 0)
        offset(r = r_use)
            square([l - 2 * r_use, w - 2 * r_use], center = true);
    else
        square([l, w], center = true);
}

module rect_taper_solid(
    bottom_l,
    bottom_w,
    top_l,
    top_w,
    taper_h,
    straight_h,
    bottom_corner_r = 0,
    top_corner_r = 0
) {
    union() {
        hull() {
            linear_extrude(height = 0.01)
                rounded_rect_2d(bottom_l, bottom_w, bottom_corner_r);

            translate([0, 0, taper_h])
                linear_extrude(height = 0.01)
                    rounded_rect_2d(top_l, top_w, top_corner_r);
        }

        translate([0, 0, taper_h])
            linear_extrude(height = straight_h)
                rounded_rect_2d(top_l, top_w, top_corner_r);
    }
}

module top_tapered_outlet() {
    eps = 0.02;

    difference() {
        rect_taper_solid(
            length + thickness * 2,
            width + thickness * 2,
            top_outlet_length + thickness * 2,
            top_outlet_width + thickness * 2,
            top_taper_height,
            top_straight_height,
            body_corner_r,
            top_corner_r + thickness
        );

        translate([0, 0, -eps])
            rect_taper_solid(
                length,
                width,
                top_outlet_length,
                top_outlet_width,
                top_taper_height + eps * 2,
                top_straight_height + eps * 2,
                max(body_corner_r - thickness, 0),
                top_corner_r
            );
    }
}

module side_window_cut() {
    translate([0, width / 2 + thickness + 0.01, side_window_bottom + side_window_height / 2])
        rotate([90, 0, 0])
            linear_extrude(height = side_window_depth)
                rounded_rect_2d(
                    side_window_length,
                    side_window_height,
                    side_window_corner_r
                );
}

module body_shell() {
    difference() {
        cuboid(
            [length + thickness * 2, width + thickness * 2, height + thickness],
            anchor = [0, 0, -1],
            rounding = body_corner_r,
            edges = "Z"
        );
        
        translate([0, 0, thickness])
            cuboid(
                [length, width, height + 0.02],
                anchor = [0, 0, -1],
                rounding = max(body_corner_r - thickness, 0),
                edges = "Z"
            );
    }
}

module side_to_top_air_box() {
    difference() {
        body_shell();
        side_window_cut();
    }
}

union() {
    side_to_top_air_box();
    translate([0, 0, height + thickness])
        top_tapered_outlet();
}
