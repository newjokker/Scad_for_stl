
use <lib/simple_box.scad>;
use <lib/corner_clips.scad>;
use <lib/bolt_post.scad>;
use <lib/lid.scad>;
include <lib/TERMINAL_BLOCK.scad>;
use <lib/port.scad>;
use <lib/utils.scad>;
use <lib/battery_box.scad>;
include <BOSL2/std.scad>

wall_thickness = 2;         // 电池盒壁厚
bottom_thickness = 1.5;     // 电池盒底部厚度
lid_thickness = 1.5;        // 电池盒盖子厚度
chip_offset = 0.3;
show_chip = false;

clip_length = 4;                    // 支架的长度
clip_thick = 2;                     // 支架的厚度

box_size = [77, 52, 10];            // 电池盒的尺寸

module Battery(pos=[0,0,0]){
    // 电池盒子模块，先这么用，后面再去转为 stl 吧
    width = 23;
    length = 77;
    height = 18;

    translate(pos){

        battery_box();
            if(show_chip){
                color("red") #
                    Battery_18650(pos = [38, 18.15/2 + 0.5 + 2, 1.5]);
            }
    }
}

module lid_A(){

    plug_thickness = 1.5;

    translate([box_size[0]/2, -box_size[1]/2, 0]){
        rotate([0, 0, 0]){
            union(){
                lid(
                    lid_size=[box_size[0], box_size[1], 1.5],
                    plug_thickness=plug_thickness,
                    plug_depth=1.5,
                    wall_thickness=wall_thickness + 0.1,  // 盖子内侧稍微大一点点，确保能盖上
                    chamfer=0.1,
                    hand_direction="left"
                    );
            }
        }
    }

    magnet_holder(
        magnet_diameter = 6 + 0.2,
        magnet_thickness = 2,
        holder_height = 1,    
        wall_thickness = 2,
        boss_diameter = 9,
        show_magnet=show_chip,
        pos = [45.5, -(box_size[1]-23.5), plug_thickness-0.01]       
    );
}

// 电池部分
difference(){
    Battery(pos=[0,  0, 0]);

    // 电线孔
    translate([6, 3, 2 + box_size[2]/2])
        rotate([90,0,0])
            wire_hole(d=3, depth=6, pos=[0, 0, 0]);

    translate([13, 3, 2 + box_size[2]/2])
        rotate([90,0,0])
            wire_hole(d=3, depth=6, pos=[0, 0, 0]);
}

// TP4056
four_corner_clips(chip_size = size_offset(TP4056_size, chip_offset), pos=[17, -14, wall_thickness-0.01], show_chip=show_chip, clip_thick=clip_thick, clip_length=clip_length);

// DCDC_A
four_corner_clips(chip_size = size_offset(DCDC_A_size, chip_offset), pos=[47, -10, wall_thickness-0.01], show_chip=show_chip, clip_thick=clip_thick, clip_length=clip_length);

// 接线柱
translate([67, -25, wall_thickness-0.01]){
    rotate([0, 0, -90])
        TERMINAL_BLOCK_A(show_chip=show_chip, pin_height=3);
}


// ESP32_C3_supermini
four_corner_clips(chip_size = size_offset(ESP32_C3_supermini_size, chip_offset), pos=[17, -38, wall_thickness-0.01], show_chip=show_chip, clip_thick=clip_thick, clip_length=clip_length);

// 毫米波雷达
four_corner_clips(chip_size = size_offset(LD2401_size, chip_offset), pos=[45, -38, wall_thickness-0.01], show_chip=show_chip, clip_thick=clip_thick, clip_length=clip_length);

// 磁力柱
magnet_holder(
    magnet_diameter = 6 + 0.3,
    magnet_thickness = 3,
    holder_height = 1.8,    
    wall_thickness = 2,
    boss_diameter = 9,
    show_magnet=show_chip,
    pos = [45.5, -23.5, wall_thickness-0.01]       
);

// 外壳
%difference(){
    // 内部空间
    simple_box(box_size=box_size, pos=[box_size[0]/2, -box_size[1]/2], chamfer=0, wall_thickness=wall_thickness);

    // Type-C 开孔
    rotate([90,0,90])
        type_c_hole(offset=0.8, depth=4, pos=[-14, wall_thickness + 3, -1]);

    // 电线孔
    translate([6, 3, 2 + box_size[2]/2])
        rotate([90,0,0])
            wire_hole(d=3, depth=6, pos=[0, 0, 0]);

    translate([13, 3, 2 + box_size[2]/2])
        rotate([90,0,0])
            wire_hole(d=3, depth=6, pos=[0, 0, 0]);

}

// 盖子
translate([0, -box_size[1], box_size[2] + 1.5]){
    rotate([180, 0, 0]){
        lid_A();
    }
}


// translate([0, 78, 0]){
//     rotate([0, 0, 0]){
//         lid_A();
//     }
// }




