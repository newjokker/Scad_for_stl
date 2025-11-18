
use <../lib/corner_clips.scad>;

// clip_thickness = 1;
// arm_height = 3;

// 调用示例
four_corner_clips(
    chip_size=[15, 12, 1.5],
    clip_thickness=1,
    arm_height=3,
    clip_length=3,
    chip_pos=[0,0,0]
);


// 测试调用
four_corner_clips(
    chip_size = [20, 20, 1],
    chip_pos = [20, 0, 0],
    clip_thickness=1,
    arm_height=3,
    clip_length=5,
    cylinders=[
        // [0.75, 3, [1.5, 1.5]],  // 第一个圆柱：直径2，高度3
        // [0.75, 3, [1.5, 10.5]], // 第二个圆柱：直径1.5，高度4
        [2, 3, [3.5, 6]] // 第二个圆柱：直径1.5，高度4
    ]
);