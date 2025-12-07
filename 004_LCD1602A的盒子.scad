
include <BOSL2/std.scad>


include <NopSCADlib/core.scad>
use <NopSCADlib/utils/layout.scad>

include <NopSCADlib/vitamins/displays.scad>
use <NopSCADlib/vitamins/pcb.scad>

$fn = 60;

// 显示器模块，旁边的一个三角形没显示出来，需要注意
// translate([0, 0, -4 ]) display(LCD1602A);

difference(){

    cuboid([90, 43, 10], anchor = [0,0,-1]);

    // 7.4 屏幕的厚度
    translate([0, 0, 7.4 ]) cuboid([85, 39, 100], anchor = [0,0,-1]);

    // 屏幕的长宽部分
    translate([0, 0, -0.01]) cuboid([71.5, 25, 100], anchor = [0,0,-1]);

    // 冒出来的杜邦线接口 2 是边框的厚度
    translate([13, 15, 2]) cuboid([42, 7, 100], anchor = [0,0,-1]);

    // 凸出来的背光板
    translate([-71.5/2 - 2, 0, 3]) cuboid([5, 14, 100], anchor = [0,0,-1]);

}







