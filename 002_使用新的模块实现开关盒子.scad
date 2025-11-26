
use <lib/simple_box.scad>;
use <lib/corner_clips.scad>;
use <lib/bolt_post.scad>;
use <lib/lid.scad>;
use <lib/TERMINAL_BLOCK.scad>;
include <BOSL2/std.scad>

// 盖子部分
%translate([0, 0, 50])
{
    rotate([180, 0, 0]) {

        // 盖子
        lid_new(
            lid_size=[80, 50, 1.5],
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




