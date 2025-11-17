// 单个L形卡扣模块 - 安全版本
module four_corner_clips(chip_size, chip_pos, 
                         clip_thickness=1, arm_height=1, clip_length=2,
                         cylinders=undef) {
    
    // 参数验证和默认值处理
    actual_cylinders = (cylinders == undef) ? [] : cylinders;
    
    // 提取芯片参数
    chip_length = is_undef(chip_size[0]) ? 10 : chip_size[0];
    chip_width  = is_undef(chip_size[1]) ? 10 : chip_size[1];
    chip_thickness = is_undef(chip_size[2]) ? 1 : chip_size[2];
    
    chip_x = is_undef(chip_pos[0]) ? 0 : chip_pos[0];
    chip_y = is_undef(chip_pos[1]) ? 0 : chip_pos[1];
    chip_z = is_undef(chip_pos[2]) ? 0 : chip_pos[2];
    
    // 四个角卡扣
    // 左下角
    translate([chip_x - clip_thickness, chip_y - clip_thickness, chip_z])
        corner_clip(clip_length, clip_thickness, arm_height);

    // 右下角
    translate([chip_x + chip_length, chip_y - clip_thickness, chip_z])
        rotate([0,0,90])
        corner_clip(clip_length, clip_thickness, arm_height);

    // 右上角
    translate([chip_x + chip_length, chip_y + chip_width, chip_z])
        rotate([0,0,180])
        corner_clip(clip_length, clip_thickness, arm_height);

    // 左上角
    translate([chip_x - clip_thickness, chip_y + chip_width, chip_z])
        rotate([0,0,270])
        corner_clip(clip_length, clip_thickness, arm_height);

    // 圆柱体（可选）
    if (len(actual_cylinders) > 0) {
        for(i = [0:len(actual_cylinders)-1]) {
            cylinder_diameter = actual_cylinders[i][0];
            cylinder_height = actual_cylinders[i][1];
            cylinder_offset = actual_cylinders[i][2];
            
            translate([chip_x + cylinder_offset[0], chip_y + cylinder_offset[1], chip_z])
                cylinder(h=cylinder_height, d=cylinder_diameter, center=false, $fn=60);
        }
    }
}

// corner_clip 辅助模块
module corner_clip(length, thickness, height) {
    cube([length + thickness, thickness, height]);
    cube([thickness, length + thickness, height]);
}

