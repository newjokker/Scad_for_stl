include <BOSL2/std.scad>

$fn = 200;

translate([0, 0, -80])

    difference(){
        cuboid([200, 200, 80], anchor = [0, 0, -1]);
        translate([10, 0, 5])
            cuboid([210, 190, 75], anchor = [0, 0, -1]);

        translate([0, 0, 0])
            cylinder(h = 200, r = 14/2);
    }

rotate([180, 0, 0])
    difference(){
        cuboid([180, 180, 70], anchor = [0, 0, -1]);
        translate([0, 0, 10])
            cuboid([170, 170, 70], anchor = [0, 0, -1]);
        
        translate([80, 0, 55])
            cuboid([40, 40, 80], anchor = [0, 0, -1]);
    }

