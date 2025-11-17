
use <lib/simple_box.scad>;
use <lib/corner_clips.scad>;
use <lib/bolt_post.scad>;
use <lib/lid.scad>;

// 调用示例
simple_box(
    size=[34.8 + 43, 18.6 + 7, 8], 
    wall_thickness=1,
    corner_radius=0,
    pos=[0, 0, 0],
    type_c_port=[true, 0, 0, 8.95, 3.15, "right"] 
);

clip_thickness = 1;
arm_height = 5;
offset = 0.5;

// // 调用示例
four_corner_clips(
    chip_size=[32.8 + offset , 16.6 + offset, 1.5],
    clip_thickness=clip_thickness,
    arm_height=arm_height,
    clip_length=3,
    chip_pos=[6,5,0],
    cylinders=[
        [1.8, 4, [1.25+1, 1.3+1, 0]],
        [1.8, 4, [1.25+1, (16.6 + offset)-(1.3+1), 0]],
        ]
    // cylinders=[]
);

four_corner_clips(
    chip_size=[22.76 + offset , 18.17 + offset, 1.5],
    clip_thickness=clip_thickness,
    arm_height=arm_height,
    clip_length=3,
    chip_pos=[54,4.5,0],
    cylinders=[]
);

bolt_post(screw="m3", mode="self_tap", height=8.5, rib_height=4, rib_thickness=1, pos=[5.5, 14.5, 0], thick=3);
bolt_post(screw="m3", mode="self_tap", height=8.5, rib_height=4, rib_thickness=1, pos=[46.5, 13.5, 0], thick=4);

// 盖子调用示例
// translate([0, -35, 0])
//     lid(
//         lid_size=[34.8 + 43, 18.6 + 7],
//         insert_start=1.5,
//         insert_depth=1.5,
//         insert_width=0.8,
//         handle_size=[8,1],
//         thick=1,
//         holes = [
//             // [5.5, 14.5, "m3"],      // M2自攻螺丝孔
//             [46.5, 13.5, "m2"]        // M2自攻螺丝孔
//         ]
//     );
