
include <BOSL2/std.scad>



$fn = 1200;

width = 100;
height = 200;
length = 180;
thickness = 2;


difference(){
    cuboid([length + thickness * 2, width + thickness * 2, height + thickness], anchor=[0, 0, -1]);
    
    translate([0, 0, thickness])
        cuboid([length, width, height], anchor=[0, 0, -1]);

    translate([0, 20, 15])
        cuboid([length, width, width], anchor=[0, 0, -1]);

}



