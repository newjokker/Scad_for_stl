include <../NopSCADlib/lib.scad>
include <BOSL2/std.scad>


$fn=256;

difference() {

    cuboid([20, 20, 10], anchor=[0, 0, -1], rounding=1.2, edges=[LEFT + FRONT, RIGHT + FRONT, LEFT + BACK, RIGHT + BACK, TOP]);
    
    extrusion(E2020, 5, center=false);
}

