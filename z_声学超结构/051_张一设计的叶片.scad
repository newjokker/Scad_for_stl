
include <BOSL2/std.scad>
use <tools/blade_from_zy.scad>;

$fn = 200;
thick = 5;

module main() {
    // 扇叶
    leaf_num = 53;
    for (i = [0 : leaf_num-1])
        color("red")
            rotate([0, 0, i * (360 / leaf_num)/1 ])
                translate([138, 0, 0])
                    rotate([0, 0, 30])
                        mirror([0, 1, 0])
                            centrifugal_blade_airfoil(
                                m = 0.06,
                                p = 0.40,
                                t = 0.12,
                                num_points = 200,
                                chord = 28,
                                mode = "3d",
                                width = 90,
                                center_3d = false
                            );

    // 外圈
    translate([0, 0, 90 -6])
        difference() {
            cylinder(h=6, r=165, center=false);  
            translate([0, 0, -0.05])
                cylinder(h=6.1, r=161, center=false);  
        }

    // 穿铁棒的结构
    translate([0, 0, 67])
        difference() {
            cylinder(h=15, r=18, center=false);  
            cylinder(h=15, r=11.8/2, center=false);  
        }

    // 底盘
    difference(){
        union() {
            cylinder(h=75, r=80, center=false); 
            cylinder(h=2.3, r=162, center=false); 
        }
        cylinder(h=75-thick, r=80 -thick, center=false); 
        cylinder(h=150, r=11.8/2, center=false);
    }
}


// scale([0.7,0.7,0.7])
// {
//     main();
// }





