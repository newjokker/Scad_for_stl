// 遥控器收纳盒（根据 remote_holder.stl 参数化重建）
// 单位：mm
include <BOSL2/std.scad>

$fn = 36;

// -------- 可调参数 --------
box_depth       = 33;  // 盒子前后深度
box_width       = 60;  // 盒子左右宽度
box_height      = 85;  // 盒子高度

front_wall      = 2;
side_wall       = 2;
back_wall       = 3;
bottom_thickness = 2;

wall_thickness = 2;

plan_round      = 5;   // 从上方看的大圆角
inner_round     = 4.8;
edge_round      = 5;   // 上下边缘的小圆角

hook_gap        = 7;   // 挂钩内部空隙
hook_thickness  = 3;
hook_top        = 99;  // 挂钩最高处
hook_drop       = 60;  // 外侧挂片向下长度
hook_round      = 1.2;

// 挂钩各个 X 位置
hook_inner_x = box_depth;
hook_outer_x = hook_inner_x + hook_gap + hook_thickness;
hook_leg_z   = hook_top - hook_drop;


// 从 X-Z 截面沿 Y 方向拉伸
module extrude_xz(length) {
    translate([0, length, 0])
        rotate([90, 0, 0])
            linear_extrude(height=length)
                children();
}

// 背面倒 U 形挂钩：后壁向上、跨过空隙，再向下折返
module rear_hook() {
    extrude_xz(box_width)
        offset(r=hook_round)
            offset(delta=-hook_round)
                union() {
                    // 与盒体后壁连成一体的上升段
                    translate([box_depth-back_wall, box_height-2])
                        square([back_wall, hook_top-box_height+2]);

                    // 顶部横桥
                    translate([box_depth-back_wall, hook_top-hook_thickness])
                        square([hook_outer_x-(box_depth-back_wall), hook_thickness]);

                    // 外侧下垂挂片
                    translate([hook_outer_x-hook_thickness, hook_leg_z])
                        square([hook_thickness, hook_top-hook_leg_z]);
                }
}

union() {
    rear_hook();



    difference() {
        cuboid([box_width, box_depth, box_height], anchor=[0,0,-1], rounding=3 + wall_thickness, edges=[FRONT+LEFT, FRONT+RIGHT]);
        translate([0, 0, wall_thickness])
            cuboid([box_width - wall_thickness * 2, box_depth - wall_thickness * 2,  box_height - wall_thickness], anchor=[0,0,-1], rounding=3, edges=[FRONT+LEFT, FRONT+RIGHT]);
    }




}
