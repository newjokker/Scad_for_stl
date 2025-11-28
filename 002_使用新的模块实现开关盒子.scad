
use <lib/simple_box.scad>;
use <lib/corner_clips.scad>;
use <lib/bolt_post.scad>;
use <lib/lid.scad>;
use <lib/TERMINAL_BLOCK.scad>;
use <lib/port.scad>;
include <BOSL2/std.scad>

box_size=[80, 35, 10];                              // 盒子的长宽
wall_thickness = 1.5;                               // 盒子的厚度
magnet_boss_diameter = 9.5;                         // 磁铁柱加强筋的直径
chip_size_offset = 1.0;
clip_length = 4;                    // 支架的长度
clip_thick = 2;                     // 支架的厚度
clip_height = 4;                    // 支架的高度

lid_plug_thickness = 1.5;           // 盖子裙边的厚度
lid_plug_depth = 1.5;               // 盖子裙边的高度

pin_height = 2.5;                   // 接线器支架的高度

magnet_diameter = 6 + 0.3;          // 磁铁的直径
magnet_thickness = 3;               // 磁铁的厚度
magnet_wall_thickness = 1.5;        // 磁铁保护壁的厚度

type_c_hole_height = wall_thickness + 3;    // typec 孔的中心点的高度

mos_pos = [18, -5, wall_thickness-0.05];                       // MOS 的位置
esp32c3_pos = [-25,-5, wall_thickness-0.05];                   // 芯片板的位置
terminal_pos = [0, 11, wall_thickness-0.01];    // 接线板的位置

wire_hole_left_pos = [box_size[0]/2 - wall_thickness -0.01, -2.5, 5];    // 左边的电线孔的位置
wire_hole_right_pos = [ box_size[0]/2 - wall_thickness -0.01, -8, 5];    // 左边的电线孔的位置

magnet_down_height = 1.8;               // 下面磁铁的支架的高度
magnet_upper_height = box_size[2] - wall_thickness - magnet_down_height - magnet_thickness*2 -0.3;       // 上面磁铁的支架的高度

mos_size = [32.8 + chip_size_offset, 16.6 + chip_size_offset, clip_height];             // mos管的尺寸
esp32_c3_size = [22.76 + chip_size_offset, 18.17 + chip_size_offset, clip_height];      // esp32-c3 的尺寸

// y轴坐标为，两个边的中间，这个限制太多了我就先不写了
magnet_down_pos = [-6.5, -5, wall_thickness-0.01];             // 下面的磁铁的位置
magnet_upper_pos = [magnet_down_pos[0], -magnet_down_pos[1], wall_thickness - 0.01];     // 上面的磁铁


// 盒子
module box_A(){
    // 盒子主体
    difference(){
        simple_box(box_size=box_size, wall_thickness=wall_thickness, pos=[0,0,0]);
        
        // typec 孔
        translate([-box_size[0]/2- 0.01, -5, type_c_hole_height])
            rotate([90, 0, 90])
                type_c_hole( offset=0.8, depth=wall_thickness+0.02, pos=[0,0,0]);

        // 电线孔
        translate(wire_hole_left_pos)
            rotate([0, 90, 0])
                wire_hole(d=3, depth=wall_thickness+0.02, pos=[0,0,0]);

        translate(wire_hole_right_pos)
            rotate([0, 90, 0])
                wire_hole(d=3, depth=wall_thickness+0.02, pos=[0,0,0]);
    }
}

module magnet_down(){
    // 磁铁柱
    magnet_holder(
        magnet_diameter = magnet_diameter,
        magnet_thickness = magnet_thickness,
        holder_height = magnet_down_height,    
        wall_thickness = magnet_wall_thickness,
        boss_diameter = magnet_boss_diameter,
        show_magnet=false,
        pos = magnet_down_pos       
    );
}

// 支架
module clip_A(){
    // 芯片的支架
    union(){
        // mos 管
        four_corner_clips(chip_size = mos_size, 
                    clip_length=clip_length,
                    clip_thick=clip_thick,
                    pos=mos_pos, 
                    show_chip=false);
        // esp32-c3 supermini
        four_corner_clips(chip_size = esp32_c3_size, 
                    clip_length=clip_length,
                    clip_thick=clip_thick,
                    pos=esp32c3_pos, 
                    show_chip=false);
        // 接线板
        TERMINAL_BLOCK_B(pos=terminal_pos, 
                    show_pins=true, 
                    pin_height=pin_height, 
                    show_chip=false);
    }
}

// 盖子部分
module lid_A(){

    // 盖子
    lid(
        lid_size=[box_size[0], box_size[1], wall_thickness],
        plug_thickness=lid_plug_thickness,
        plug_depth=lid_plug_depth,
        wall_thickness=wall_thickness+0.1,
        chamfer=0.4,
        hand_direction="left",
        pos=[0, 0, 0]
        );

    // 磁铁柱
    magnet_holder(
        magnet_diameter = magnet_diameter,
        magnet_thickness = magnet_thickness,
        holder_height = magnet_upper_height,    
        wall_thickness = magnet_wall_thickness,
        boss_diameter = magnet_boss_diameter,
        pos = magnet_upper_pos      
    );
}

box_A();

magnet_down();

// translate([0, 0, box_size[2] + 1.5])
//     rotate([180, 0, 0])
//         lid_A();

translate([0, 40, 0])
    lid_A();

clip_A();

