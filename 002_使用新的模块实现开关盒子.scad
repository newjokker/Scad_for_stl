
use <lib/simple_box.scad>;
use <lib/corner_clips.scad>;
use <lib/bolt_post.scad>;
use <lib/lid.scad>;
use <lib/TERMINAL_BLOCK.scad>;
use <lib/port.scad>;
include <BOSL2/std.scad>

box_size=[75, 35, 10];          // 盒子的长款
wall_thickness = 1;             // 盒子的厚度
magnet_boss_diameter = 9.5;     // 磁铁柱加强筋的直径

type_c_hole_height = wall_thickness + 3;         // typec 孔的中心点的高度

union(){
    // 盒子主体
    difference(){
        %simple_box_new(box_size=box_size, wall_thickness=wall_thickness, pos=[0,0,0]);
        
        // typec 孔
        translate([-box_size[0]/2- 0.01, 0, type_c_hole_height])
            rotate([90, 0, 90])
                type_c_hole( offset=0.2, depth=wall_thickness+0.02, pos=[0,0,0]);
    }

    // 磁铁柱
    magnet_holder(
        magnet_diameter = 6 + 0.3,
        magnet_thickness = 3,
        holder_height = 2.8,    
        wall_thickness = 1,
        boss_diameter = magnet_boss_diameter,
        pos = [0, 0, -0.05]       
    );
}


// 芯片的支架
four_corner_clips_new(chip_size = [30, 13, 4], clip_length=2,clip_thick=1.5,pos=[20,0,-0.05]);

// 盖子部分
translate([0, 0, box_size[2] + 1.5])
{
    rotate([180, 0, 0]) {

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
            wall_thickness = 1,
            boss_diameter = magnet_boss_diameter,
            pos = [0, 0, 1.5 - 0.01]       
        );
    }
}


