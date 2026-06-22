
use <lib/simple_box.scad>;
use <lib/corner_clips.scad>;
use <lib/bolt_post.scad>;
use <lib/lid.scad>;
include <lib/TERMINAL_BLOCK.scad>;
use <lib/port.scad>;
use <lib/utils.scad>;
use <lib/battery_box.scad>;
include <BOSL2/std.scad>



// 全局的参数
wall_thickness      = 2;            // 电池盒壁厚
$show_chip          = false;         // 是否显示需要安装的内容 
$fn=60;

// 芯片的支架
chip_offset         = 0.5;                  // 直接误差大小
clip_length         = 2;                    // 支架的长度
clip_thick          = 2;                    // 支架的厚度

// 芯片
TP4056_pos              = [17, -14, wall_thickness-0.01];   

// 盒子的尺寸
box_size                = [77, 53, 10];            // 电池盒的尺寸


// TP4056
// four_corner_clips(chip_size = size_offset(TP4056_size, chip_offset), pos=TP4056_pos, clip_thick=clip_thick, clip_length=clip_length);

// translate([11, 0, 5]) 
//     rotate([0, 0, 90]) 
//         Battery_box_base_18650();

difference(){

    import("/Users/jokkerling/Documents/Code/Scad_for_stl/stls/18650充电器/BASE.stl");


    a = 1.03;
    scale([a, 1, 1]) 
        translate([11.5, 26, -2]) 
            rotate([0, 0, 90]) 
                import("/Users/jokkerling/Documents/Code/Scad_for_stl/stls/battery/18650_battery_shell.stl");


}



