
use <lib/simple_box.scad>;
use <lib/corner_clips.scad>;
use <lib/bolt_post.scad>;
use <lib/lid.scad>;

wall_thickness = 1.5;   // 盒子的壁厚
clip_thickness = 1.5;   // 卡扣的厚度
arm_height = 5;         // 卡扣的臂高
chip_offset = 0.5;           // 芯片尺寸的额外偏移量

esp32_chip_size = [23 + chip_offset , 18.17 + chip_offset, wall_thickness]; // ESP32芯片尺寸（含偏移量）
mos_chip_size   = [32 + chip_offset , 16.6 + chip_offset, wall_thickness];    // M0S芯片尺寸（含偏移量）

box_size = [
    32.8 + 42,    // X方向尺寸（含ESP32和M0S芯片及间距）
    16.6 + 8,     // Y方向尺寸（含ESP32和M0S芯片及间距）
    7             // Z方向尺寸（高度）
];

// 调用示例
simple_box(
    size=box_size, 
    wall_thickness=wall_thickness,
    corner_radius=0,
    pos=[0, 0, 0],
    type_c_port=[true, 0, 0, 8.95, 3.15, "right"] 
);


// // 调用示例
four_corner_clips(
    chip_size=mos_chip_size,
    clip_thickness=clip_thickness,
    arm_height=arm_height,
    clip_length=3,
    chip_pos=[4,5,0],
    cylinders=[
        // [1.8, 4, [1.25+1, 1.3+1, 0]],
        // [1.8, 4, [1.25+1, (16.6 + offset)-(1.3+1), 0]],
        ]
);

four_corner_clips(
    chip_size=esp32_chip_size,
    clip_thickness=clip_thickness,
    arm_height=arm_height,
    clip_length=3,
    chip_pos=[52,4.5,0],
    cylinders=[]
);

// bolt_post(screw="m3", mode="self_tap", height=8.5, rib_height=4, rib_thickness=1, pos=[5.5, 14.5, 0], thick=3);
bolt_post(screw="m3", mode="self_tap", height=6.5, rib_height=4, rib_thickness=1, pos=[45, box_size[1]/2 + wall_thickness, wall_thickness], thick=4);

// 盖子调用示例
lid(
    lid_size=[box_size[0], box_size[1]],
    insert_start=2.5,
    insert_depth=2.5,
    insert_width=1.5,
    handle_size=[8,1],
    thick=wall_thickness,
    pos=[0, -40, 0],
    holes = [
        // FIXME: 左右是镜像的，一定要小心，最好使用自动获取位置的方法
        [45, box_size[1]/2 + wall_thickness, "m3"]          // M3通孔
    ]
);
