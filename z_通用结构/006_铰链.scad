include <BOSL2/std.scad>
include <BOSL2/hinges.scad>

$fn = 64;

plate_x = 50;
plate_y = 30;
plate_t = 4;

hinge_len = 30;
hinge_d   = 8;
pin_d     = 3;

offset_v = hinge_d / 2 + 2;   // 必须 >= hinge_d/2

// 左板
translate([-plate_x/2, 0, 0])
    cuboid([plate_x, plate_y, plate_t], anchor=CENTER);

// 右板
translate([plate_x/2, 0, 0])
    cuboid([plate_x, plate_y, plate_t], anchor=CENTER);

// 左侧铰链（外铰链）
translate([-plate_t/2, plate_y/2 - hinge_len/2, 0])
    knuckle_hinge(
        length = hinge_len,
        segs = 3,
        offset = offset_v,
        arm_height = plate_t,
        arm_angle = 45,
        inner = false,
        knuckle_diam = hinge_d,
        pin_diam = pin_d,
        fill = true,
        anchor = BOTTOM
    );

// 右侧铰链（内铰链）
translate([plate_t/2, plate_y/2 - hinge_len/2, 0])
    knuckle_hinge(
        length = hinge_len,
        segs = 3,
        offset = offset_v,
        arm_height = plate_t,
        arm_angle = 45,
        inner = true,
        knuckle_diam = hinge_d,
        pin_diam = pin_d,
        fill = true,
        anchor = BOTTOM
    );

// 销轴
translate([0, plate_y/2 - hinge_len/2, 0])
    down(offset_v)
    cyl(d=pin_d + 0.2, h=hinge_len + 4, anchor=CENTER);