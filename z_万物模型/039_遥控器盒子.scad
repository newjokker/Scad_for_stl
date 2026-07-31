// 遥控器收纳盒（根据 remote_holder.stl 参数化重建）
// 单位：mm
include <BOSL2/std.scad>

$fn = 36;

// -------- 可调参数 --------
box_depth       = 33;  // 盒子前后深度
box_width       = 60;  // 盒子左右宽度
box_height      = 85;  // 盒子高度
rounding        = 3; 
wall_thickness = 2;


union() {

    difference() {
        cuboid([box_width, box_depth, box_height], anchor=[0,0,-1], rounding=rounding + wall_thickness, edges=[FRONT+LEFT, FRONT+RIGHT]);
        translate([0, 0, wall_thickness])
            cuboid([box_width - wall_thickness * 2, box_depth - wall_thickness * 2,  box_height - wall_thickness], anchor=[0,0,-1], rounding=rounding, edges=[FRONT+LEFT, FRONT+RIGHT]);
    }




}
