// 遥控器收纳盒
include <BOSL2/std.scad>

$fn = 336;

// -------- 可调参数 --------
// 盒子前后深度
box_depth       = 33;   // [5:260]
// 盒子左右宽度 
box_width       = 90;   // [5:260]
// 盒子高度 
box_height      = 80;   // [5:260]
// 盒子圆角弧度
rounding        = 3;    // [0:0.5:10]
// 盒子厚度
wall_thickness  = 3;    // [2:0.5:8]

// -------- 简单挂钩参数 --------
// 挂钩内部空隙
hook_gap       = 7;     // [3:1:20]
// 挂钩厚度  
hook_thickness = 3;     // [2:0.5:8]
// 高出盒口的高度  
hook_rise      = 14;    // [0:1:50]
// 外侧挂片长度 
hook_drop      = 60;    // [0:1:130]

// 由三块直板组成的简单倒 U 形挂钩
module simple_hook() {
    back_y   = box_depth/2;
    hook_top = box_height + hook_rise;

    // 与盒子后壁连接的上升段
    translate([
        -box_width/2,
        back_y-hook_thickness,
        box_height-wall_thickness
    ])
        cube([
            box_width,
            hook_thickness,
            hook_top-box_height+wall_thickness
        ]);

    // 顶部横桥
    translate([
        -box_width/2,
        back_y-hook_thickness,
        hook_top-hook_thickness
    ])
        cube([
            box_width,
            hook_gap+2*hook_thickness,
            hook_thickness
        ]);

    // 外侧向下的挂片
    translate([
        -box_width/2,
        back_y+hook_gap,
        hook_top-hook_drop
    ])
        cube([
            box_width,
            hook_thickness,
            hook_drop
        ]);
}


union() {

    simple_hook();

    difference() {
        cuboid([box_width, box_depth, box_height], anchor=[0,0,-1], rounding=rounding + wall_thickness, edges=[FRONT+LEFT, FRONT+RIGHT]);
        translate([0, 0, wall_thickness])
            cuboid([box_width - wall_thickness * 2, box_depth - wall_thickness * 2,  box_height - wall_thickness], anchor=[0,0,-1], rounding=rounding, edges=[FRONT+LEFT, FRONT+RIGHT]);
    }
}
