// 单个L形卡扣模块
module four_corner_clips(chip_size=[10,8,1.5], chip_pos=[0,0,0], 
                         clip_thickness=1, arm_height=1, clip_length=2,
                         cylinders=[]) {
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

    // 创建圆柱体, 如果不判断就会在原点画一个圆柱，这个要非常注意，是这个语言的坑
    // cylinders参数格式：[[直径, 高度, [x偏移, y偏移]], ...]
    if (len(cylinders) > 0) {
        for(i = [0:len(cylinders)-1]) {
            cylinder_diameter = cylinders[i][0];
            cylinder_height = cylinders[i][1];
            // 相对位置：[x偏移, y偏移]，z使用芯片的z坐标
            cylinder_offset = cylinders[i][2];
            
            x_pos = chip_x + cylinder_offset[0];
            y_pos = chip_y + cylinder_offset[1];
            z_pos = chip_z;  // 直接使用芯片的z坐标，不加偏移
            
            translate([x_pos, y_pos, z_pos])
                cylinder(h=cylinder_height, d=cylinder_diameter, center=false, $fn=60);
        }
    }

    // 芯片（可选显示）
    // color("blue", 0.3)
    // translate([chip_x, chip_y, chip_z])
    //     cube([chip_length, chip_width, chip_thickness]);
}

// corner_clip 辅助模块
module corner_clip(length, thickness, height) {
    cube([length + thickness, thickness, height]);
    cube([thickness, length + thickness, height]);
}

