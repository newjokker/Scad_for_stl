
include <BOSL2/std.scad>


length = 215;

thick = 5;

difference(){

    cuboid([length, length, length], anchor = [-1,-1,-1]);

    translate([thick, thick, thick])
        cuboid([length - 2 * thick, length - 2 * thick, length + 100], anchor = [-1,-1,-1]);

}





