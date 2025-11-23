
use <lib/simple_box.scad>;
use <lib/corner_clips.scad>;
use <lib/bolt_post.scad>;
use <lib/lid.scad>;
use <lib/TERMINAL_BLOCK.scad>;
include <BOSL2/std.scad>


wall_thickness = 1.5;   // 盒子的壁厚
clip_thickness = 1.5;   // 卡扣的厚度
arm_height = 5;         // 卡扣的臂高
chip_offset = 0.8;           // 芯片尺寸的额外偏移量

esp32_chip_size = [23 + chip_offset , 18.17 + chip_offset, wall_thickness]; // ESP32芯片尺寸（含偏移量）
mos_chip_size   = [32.8 + chip_offset , 16.6 + chip_offset, wall_thickness];    // M0S芯片尺寸（含偏移量）

box_size = [
    32.8 + 42,    // X方向尺寸（含ESP32和M0S芯片及间距）
    16.6 + 18,     // Y方向尺寸（含ESP32和M0S芯片及间距）
    8             // Z方向尺寸（高度）
];

// 盒子
simple_box(
    size=box_size, 
    wall_thickness=wall_thickness,
    corner_radius=0,
    pos=[0, 0, 0],
    holes = [
        // Type-C
        ["type_c", 0, 0, 8.95, 3.15, "right"],
        // 圆孔
        ["circle", 2, 0, 2.5, "left"],
        ["circle", 7, 0, 2.5, "left"]
    ]
);


// mos 卡扣
four_corner_clips(
    chip_size=mos_chip_size,
    clip_thickness=clip_thickness,
    arm_height=arm_height,
    clip_length=3,
    chip_pos=[6.5,15.2,clip_thickness],
    cylinders=[
        // [1.8, 4, [1.25+1, 1.3+1, 0]],
        // [1.8, 4, [1.25+1, (16.6 + offset)-(1.3+1), 0]],
        ]
);

// // 电源设备
// %translate([25 , 3 , wall_thickness]) {  // 向右移动40mm
//     color("red", 0.8)  // 绿色
//     TERMINAL_BLOCK_B();
// }

// TODO: 写一个模块输入这个模块中心点的坐标，返回两个圆柱体的坐标信息
// 电源设备柱
translate([25 + 1 + 1.5, 3 + 8.15/2, wall_thickness]) {  
    color("yellow", 0.8)  // 绿色
    cylinder(h=2.5, r=1.45, $fn = 30);
    cylinder(h=1, r2=1.45, r1=1.4+1, $fn = 30);
}

translate([25 + 1 + 1.5 + 14.2 + 3, 3 + 8.15/2, wall_thickness]) {  
    color("yellow", 0.8)  // 绿色
    cylinder(h=2.5, r=1.45, $fn = 30);
    cylinder(h=1, r2=1.45, r1=1.4+1, $fn = 30);
}


// esp32c3-supermini 卡扣
four_corner_clips(
    chip_size=esp32_chip_size,
    clip_thickness=clip_thickness,
    arm_height=arm_height,
    clip_length=3,
    chip_pos=[52,wall_thickness + box_size[1]/2 - esp32_chip_size[1]/2,clip_thickness],
    cylinders=[]
);

// 螺柱
// bolt_post(screw="m3", mode="self_tap", height=8.5, rib_height=4, rib_thickness=1, pos=[5.5, 14.5, 0], thick=3);
// bolt_post(screw="m3", mode="self_tap", height=7.5, rib_height=4, rib_thickness=1, pos=[46, box_size[1]/2 + wall_thickness, wall_thickness], thick=4);

// 盖子
insert_start = 2;
lid(
    lid_size=[box_size[0], box_size[1]],
    insert_start=insert_start,
    insert_depth=2.5,
    insert_width=1.5,
    handle_size=[8,1],
    thick=wall_thickness,
    pos=[0, -40, 0],
    n_bumps_per_side = 8,  // 每条边上的小凸起数量
    bump_diameter = 2.2    // 小凸起圆柱直径
    // holes = [
    //     // FIXME: 左右是镜像的，一定要小心，最好使用自动获取位置的方法
    //     [46, box_size[1]/2 + wall_thickness, "m3"]                  // M3通孔
    // ]
);


// 盒子磁吸柱
magnet_thickness = 3;
magnet_holder(
        magnet_diameter = 6 + 0.3,
        magnet_thickness = magnet_thickness,
        holder_height = box_size[2] - magnet_thickness - 0.2,     // 稍高于磁铁，可以略高用于卡住或胶粘
        wall_thickness_upper = 1.5,
        wall_thickness_down = 2.5,
        fn = 60,
        pos = [46, box_size[1]/2 + wall_thickness, wall_thickness]       // 放在旁边，不重叠
    );

// 盖子磁吸柱
magnet_holder(
        magnet_diameter = 6 + 0.3,
        magnet_thickness = magnet_thickness,
        holder_height = magnet_thickness - 0.2,     
        wall_thickness_upper = 1.5,
        wall_thickness_down = 2.5,
        fn = 60,
        pos = [46, box_size[1]/2 + wall_thickness -40, insert_start]       // 放在旁边，不重叠
    );

