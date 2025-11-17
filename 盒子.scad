
use <lib/simple_box.scad>;
use <lib/corner_clips.scad>;
use <lib/bolt_post.scad>;
use <lib/lid.scad>;

// 调用示例
simple_box(
    size=[32.8 + 34.5, 16.6 + 5, 8], 
    wall_thickness=1,
    corner_radius=0,
    pos=[0, 0, 0]  // 在原点
);

clip_thickness = 1;
arm_height = 3;
offset = 0.5;

// 调用示例
four_corner_clips(
    chip_size=[32.8 + offset , 16.6 + offset, 1.5],
    clip_thickness=clip_thickness,
    arm_height=arm_height,
    clip_length=3,
    chip_pos=[7,3.75,0],
    cylinders=[]
);

four_corner_clips(
    chip_size=[22.76 + offset , 18.17 + offset, 1.5],
    clip_thickness=clip_thickness,
    arm_height=arm_height,
    clip_length=3,
    chip_pos=[45,3,0],
    cylinders=[]
);

bolt_post(screw="m2", mode="self_tap", height=8.5, rib_height=4, rib_thickness=0.5, pos=[4.5, 11.5, 0], thick=2);
bolt_post(screw="m2", mode="self_tap", height=8.5, rib_height=4, rib_thickness=0.5, pos=[42, 11.5, 0], thick=2);

// 盖子调用示例

translate([0, -25, 0])
    lid(
        lid_size=[32.8 + 34.5 + 2, 16.6 + 5, 6  + 2],
        insert_start=1.2,
        insert_depth=1,
        insert_width=0.8,
        handle_size=[8,2],
        thick=1,
        holes = [
            [4.5, 11.5, "m2"],      // M2自攻螺丝孔
            [42, 11.5, "m2"]        // M2自攻螺丝孔
        ]
    );

