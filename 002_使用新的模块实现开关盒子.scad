
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
chip_size_offset = 0.5
mos_size = [32.8 + offset, 16.6 + offset, 2 + wall_thickness];        // mos管的尺寸
esp32_c3_size = [22.76 + offset, 18.17 + offset, 2 + wall_thickness];    // esp32-c3 的尺寸
type_c_hole_height = wall_thickness + 3;            // typec 孔的中心点的高度

// 盒子
module box_A(){
    // 盒子主体
    difference(){
        simple_box_new(box_size=box_size, wall_thickness=wall_thickness, pos=[0,0,0]);
        
        // typec 孔
        translate([-box_size[0]/2- 0.01, -5, type_c_hole_height])
            rotate([90, 0, 90])
                type_c_hole( offset=0.2, depth=wall_thickness+0.02, pos=[0,0,0]);

        // 电线孔
        translate([ box_size[0]/2 - wall_thickness -0.01, -3, 6])
            rotate([0, 90, 0])
                wire_hole(d=3, depth=wall_thickness+0.02, pos=[0,0,0]);

        translate([ box_size[0]/2 - wall_thickness -0.01, -8, 6])
            rotate([0, 90, 0])
                wire_hole(d=3, depth=wall_thickness+0.02, pos=[0,0,0]);
    }

}

module magnet_down(){
    // 磁铁柱
    magnet_holder(
        magnet_diameter = 6 + 0.3,
        magnet_thickness = 3,
        holder_height = 2.8,    
        wall_thickness = 1.5,
        boss_diameter = magnet_boss_diameter,
        show_magnet=false,
        pos = [-5, -5, 0.05]       
    );
}

// 支架
module clip_A(){
    // 芯片的支架
    union(){
        // mos 管
        four_corner_clips_new(chip_size = mos_size, 
                    clip_length=2,
                    clip_thick=1.5,
                    pos=[20, -5, 0.05], 
                    show_chip=false);
        // esp32-c3 supermini
        four_corner_clips_new(chip_size = esp32_c3_size, 
                    clip_length=2,
                    clip_thick=1.5,
                    pos=[-26,-5, 0.05], 
                    show_chip=false);
        // 接线板
        TERMINAL_BLOCK_B(pos=[0, 11, 0], 
                    show_pins=true, 
                    pin_height=3, 
                    show_chip=false);
        // 柱子
    }
}

// 盖子部分
module lid_A(){

    // 盖子
    lid_new(
        lid_size=[box_size[0], box_size[1], 1.5],
        plug_thickness=1.5,
        plug_depth=1.5,
        wall_thickness=1,
        chamfer=0.5,
        pos=[0, 0, 0]
        );

    // 磁铁柱
    magnet_holder(
        magnet_diameter = 6 + 0.3,
        magnet_thickness = 3,
        holder_height = 1,    
        wall_thickness = 1.5,
        boss_diameter = magnet_boss_diameter,
        pos = [-5, 5, 1.5 - 0.01]       
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

