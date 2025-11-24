
include <BOSL2/std.scad>

// 改进版L形卡扣模块 - 不占用芯片空间
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
    
    // 四个角卡扣 - 改进版：卡扣围绕芯片外部
    // 左下角
    translate([chip_x, chip_y , chip_z])
        external_corner_clip(clip_length, clip_thickness, arm_height);

    // 右下角
    translate([chip_x + chip_length, chip_y, chip_z])
        rotate([0,0,90])
        external_corner_clip(clip_length, clip_thickness, arm_height);

    // 右上角
    translate([chip_x + chip_length, chip_width + chip_y, chip_z])
        rotate([0,0,180])
        external_corner_clip(clip_length, clip_thickness, arm_height);

    // 左上角
    translate([chip_x, chip_width  + chip_y, chip_z])
        rotate([0,0,270])
        external_corner_clip(clip_length, clip_thickness, arm_height);

    // 圆柱体（可选）
    if (len(actual_cylinders) > 0) {
        for(i = [0:len(actual_cylinders)-1]) {
            cylinder_diameter = actual_cylinders[i][0];
            cylinder_height = actual_cylinders[i][1];
            cylinder_offset = actual_cylinders[i][2];
            translate([chip_x + cylinder_offset[0], chip_y + cylinder_offset[1], chip_z])

            // translate([chip_x + cylinder_offset[0], chip_y, chip_z])
                cylinder(h=cylinder_height, d=cylinder_diameter, center=false, $fn=60);
        }
    }
}

// 改进的corner_clip辅助模块 - 外部卡扣
module external_corner_clip(length, thickness, height) {
    // 水平臂（向外延伸）
    translate([0, -thickness, 0])
        cube([length, thickness, height]);
    
    // 垂直臂（向外延伸）
    translate([-thickness, 0, 0])
        cube([thickness, length, height]);
    
    // 角部加强块
    translate([-thickness, -thickness, 0])
        cube([thickness, thickness, height]);
}

// 可选：如果您希望卡扣部分向内包裹芯片，可以使用这个版本
module wrapping_corner_clip(length, thickness, height) {
    // 水平臂（外部支撑，内部包裹）
    cube([length, thickness, height]);
    
    // 垂直臂（外部支撑，内部包裹）
    cube([thickness, length, height]);
}


// 芯片的卡扣
module four_corner_clips_new(
    chip_size = [20, 10, 4],    // 芯片的长宽高
    clip_length=2,              // 卡扣的边长
    clip_thick=1.5,              // 卡扣的厚度
    pos=[0,0,0]                 // 中心点所在的位置
){
    
    // 对中心点进行移动
    translate(pos){
        // 先将中心点移动到原点
        translate([-(chip_size[0]/2 + clip_thick), -(chip_size[1]/2 + clip_thick), 0]){

            difference(){
                // 原始的矩形
                cuboid([chip_size[0]+2*clip_thick,chip_size[1]+2*clip_thick,chip_size[2]], anchor=[-1, -1, -1]);
                // 中间部分
                translate([clip_thick, clip_thick, -0.5])
                    cuboid([chip_size[0], chip_size[1], chip_size[2] + 1], anchor=[-1, -1, -1]);
                // 使用两个矩形剪切出四个边
                translate([clip_thick + clip_length, -0.5, -0.5])
                            cuboid([chip_size[0]-2*clip_length, chip_size[1] + clip_thick*2 + 1, chip_size[2] + 1], anchor=[-1, -1, -1]);

                translate([-0.5, clip_thick + clip_length, -0.5])
                            cuboid([chip_size[0]+2*clip_thick + 1, chip_size[1]-2*clip_length, chip_size[2] + 1], anchor=[-1, -1, -1]);

            }
        }
    }
}


// // 使用示例：
// four_corner_clips(
//     chip_size = [20, 20, 2],
//     chip_pos = [0, 0, 0],
//     clip_thickness = 1,
//     arm_height = 3,
//     clip_length = 4,
//     cylinders = [
//         [3, 6, [10, 10]],     // 直径3mm，高度6mm，位置相对于芯片中心偏移 (10,10)
//         [3, 6, [10, -10]],
//         [3, 6, [-10, 10]],
//         [3, 6, [-10, -10]]
//     ]
// );


four_corner_clips_new(clip_thick=1.5, pos=[20,20,0]);