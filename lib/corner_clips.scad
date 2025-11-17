// 单个L形卡扣模块
module corner_clip(clip_length=2, thickness=1, arm_height=1) {
    // X方向臂
    cube([clip_length, thickness, arm_height]);
    // Y方向臂
    cube([thickness, clip_length, arm_height]);
}

// 四角卡扣模块
// chip_size: [长度, 宽度, 厚度]
// chip_pos: [x, y, z] 左下角位置
// clip_thickness: 卡扣臂厚度
// arm_height: 卡扣臂高度
// clip_length: 卡扣臂长度
module four_corner_clips(chip_size=[10,8,1.5], chip_pos=[0,0,0], 
                         clip_thickness=1, arm_height=1, clip_length=2) {
    chip_length = chip_size[0];
    chip_width  = chip_size[1];
    chip_thickness = chip_size[2];
    chip_x = chip_pos[0];
    chip_y = chip_pos[1];
    chip_z = chip_pos[2];

    // 左下角
    translate([chip_x - clip_thickness, chip_y - clip_thickness, chip_z])
        corner_clip(clip_length, clip_thickness, arm_height);

    // 右下角
    translate([chip_x + chip_length + clip_thickness, chip_y - clip_thickness, chip_z])
        rotate([0,0,90])
        corner_clip(clip_length, clip_thickness, arm_height);

    // 右上角
    translate([chip_x + chip_length + clip_thickness , chip_y + chip_width + clip_thickness , chip_z])
        rotate([0,0,180])
        corner_clip(clip_length, clip_thickness, arm_height);

    // 左上角
    translate([chip_x - clip_thickness, chip_y + chip_width + clip_thickness, chip_z])
        rotate([0,0,270])
        corner_clip(clip_length, clip_thickness, arm_height);

    // 芯片
    color("blue", 0.3)
    translate([chip_x, chip_y, chip_z])
        cube([chip_length, chip_width, chip_thickness]);
}
