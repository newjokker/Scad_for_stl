
include <BOSL2/std.scad>


include <NopSCADlib/core.scad>
use <NopSCADlib/utils/layout.scad>

include <NopSCADlib/vitamins/displays.scad>
use <NopSCADlib/vitamins/pcb.scad>

$fn = 60;

offset = 0.5;
displat_length = 71;
displat_width = 24;
displat_height = 7.4;
displat_size = [displat_length + offset, displat_width + offset, displat_height];

// 显示器模块，旁边的一个三角形没显示出来，需要注意
// translate([0, 0, 0 ]) display(LCD1602A);

module display_A(size=[90, 43, 20]){
    difference(){

        cuboid(size, anchor = [0,0,-1]);

        // 7.4 屏幕的厚度
        translate([0, 0, 7.4 ]) cuboid([85, 39, 100], anchor = [0,0,-1]);

        // 屏幕的长宽部分
        translate([0, 0, -0.01]) cuboid([displat_size[0] , displat_size[1], 100], anchor = [0,0,-1]);

        // 冒出来的杜邦线接口 2 是边框的厚度
        translate([13, 15, 2]) cuboid([42, 7, 100], anchor = [0,0,-1]);

        // 凸出来的背光板
        translate([-displat_size[0] - 2, 0, 3]) cuboid([5, 14, 100], anchor = [0,0,-1]);

        // 螺丝孔
        r1 = 2.5;
        r2 = 1.4;
        display_out_length = 80;
        display_out_width = 36;
        height = 7;
        translate([-display_out_length/2 + r1 , -display_out_width/2 + r1 , 3]) cylinder(r=r2, h=height, anchor=[0, 0, -1]);
        translate([-display_out_length/2 + r1 , display_out_width/2 - r1 , 3]) cylinder(r=r2, h=height, anchor=[0, 0, -1]);
        translate([display_out_length/2 - r1 , display_out_width/2 - r1 , 3]) cylinder(r=r2, h=height, anchor=[0, 0, -1]);
        translate([display_out_length/2 - r1 , -display_out_width/2 + r1 , 3]) cylinder(r=r2, h=height, anchor=[0, 0, -1]);

    }
}

display_A();










