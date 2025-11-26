
use <lib/simple_box.scad>;
use <lib/corner_clips.scad>;
use <lib/bolt_post.scad>;
use <lib/lid.scad>;
use <lib/TERMINAL_BLOCK.scad>;
use <lib/port.scad>;
include <BOSL2/std.scad>

box_size=[80, 40, 20];
wall_thickness = 1;

// 盒子部分
difference(){
    %simple_box_new(box_size=box_size, wall_thickness=wall_thickness, pos=[0,0,0]);
    
    translate([-box_size[0]/2- 0.01, 0, 5])
        rotate([90, 0, 90])
            type_c_hole( offset=0.2, depth=wall_thickness+0.02, pos=[0,0,0]);
}

// 磁铁柱
magnet_holder(
    magnet_diameter = 6 + 0.3,
    magnet_thickness = 3,
    holder_height = 13.8,    
    wall_thickness = 1,
    pos = [0, 0, 0]       
);

// 芯片的支架
four_corner_clips_new(chip_size = [30, 13, 4], clip_length=2,clip_thick=1.5,pos=[20,0,0]);

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
            holder_height = 0,    
            wall_thickness = 1,
            pos = [0, 0, 1.5 - 0.01]       
        );
    }
}


