
use <lib/corner_clips.scad>;

clip_thickness = 1;
arm_height = 3;

// 调用示例
four_corner_clips(
    chip_size=[15, 12, 1.5],
    chip_pos=[5, 5],
    clip_thickness=clip_thickness,
    arm_height=arm_height,
    clip_length=3
);


four_corner_clips(
    chip_size=[15, 12, 1.5],
    chip_pos=[25, 5],
    
    clip_thickness=clip_thickness,
    arm_height=arm_height,
    clip_length=3
);
