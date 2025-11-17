
use <lib/simple_box.scad>;
use <lib/corner_clips.scad>;

// 调用示例
simple_box(
    size=[32.8 + 5, 16.6 + 5, 3], 
    wall_thickness=1,
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
    chip_pos=[3,3,0]
);
