// 遥控器收纳盒（根据 remote_holder.stl 参数化重建）
// 单位：mm
include <BOSL2/std.scad>

$fn = 36;

// -------- 可调参数 --------
box_depth       = 33;  // 盒子前后深度
box_width       = 60;  // 盒子左右宽度
box_height      = 85;  // 盒子高度
rounding        = 3;
wall_thickness  = 2;

// -------- 简单挂钩参数 --------
hook_gap       = 7;   // 挂钩内部空隙
hook_thickness = 2;   // 挂钩厚度
hook_rise      = 14;  // 高出盒口的高度
hook_drop      = 60;  // 外侧挂片长度

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
