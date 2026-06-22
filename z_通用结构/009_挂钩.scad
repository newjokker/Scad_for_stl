include <BOSL2/std.scad>
include <BOSL2/hooks.scad>

/* [整体缩放] */
model_scale = 0.5;   // [0.1:0.05:2]

/* [挂钩参数] */
base_w = 50;         // [10:1:100]
base_t = 10;         // [2:1:30]
hole_z = 25;         // [5:1:80]
outer_r = 25;        // [5:1:80]
inner_r = 15;        // [2:1:70]
rounding = 2;        // [0:0.5:10]
fillet = 2;          // [0:0.5:10]
hole_rounding = 1;   // [0:0.5:10]

/* [底板参数] */
plate_w = 50;        // [10:1:150]
plate_d = 30;        // [10:1:100]
plate_h = 2;         // [1:0.5:20]

/* [显示精度] */
fn_val = 64;         // [16:8:128]

$fn = fn_val;


// 挂钩
scale([model_scale, model_scale, model_scale])
ring_hook(
    base_size = [base_w, base_t],
    hole_z = hole_z,
    or = outer_r,
    ir = inner_r,
    rounding = rounding,
    fillet = fillet,
    hole_rounding = hole_rounding
);


// 底板
cuboid(
    [plate_w, plate_d, plate_h],
    anchor = [0, 0, 1]
);