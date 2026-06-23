
include <BOSL2/std.scad>
use <tools/hh_cube.scad>;

$fn = 96;


ext = 20;
ext_2 = 8;
width = 180;
height = 90;
wall_thickness_button = 1.5;
wall_thickness = 2.5;

length = 45.6;

translate([0, 0, -wall_thickness_button/2])
difference(){
    cuboid([width+ext*2, height+ext*2, wall_thickness_button], anchor=[0, 0, 0]);
    cuboid([width, height, wall_thickness_button + 1], anchor=[0, 0, 0]);
}

difference(){
    cuboid([width+wall_thickness*2, height+wall_thickness*2, length], anchor=[0, 0, -1]);
    translate([0, 0, -0.01])
        cuboid([width, height, length + 1], anchor=[0, 0, -1]);

    translate([0, 0, ext_2])
        cuboid([width * 2, height - ext_2*2, length - ext_2 * 2], anchor=[0, 0, -1]);

    translate([0, 0, ext_2])
        cuboid([width - ext_2*2, height * 2, length - ext_2 * 2], anchor=[0, 0, -1]);

}

