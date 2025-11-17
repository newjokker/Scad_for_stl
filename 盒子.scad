
use <lib/simple_box.scad>;
use <lib/corner_clips.scad>;

// 调用示例
simple_box(
    size=[40, 15, 8], 
    wall_thickness=1,
    pos=[0, 0, 0]  // 在原点
);


clip_thickness = 1;
arm_height = 3;

// 调用示例
four_corner_clips(
    chip_size=[12, 8, 1.5],
    chip_pos=[5, 5],
    clip_thickness=clip_thickness,
    arm_height=arm_height,
    clip_length=3,
    chip_pos=[5,5,0]
);

// 调用示例
four_corner_clips(
    chip_size=[12, 8, 1.5],
    chip_pos=[5, 5],
    clip_thickness=clip_thickness,
    arm_height=arm_height,
    clip_length=3,
    chip_pos=[25,5,0]
);
