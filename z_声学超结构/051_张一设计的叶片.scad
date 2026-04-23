
include <BOSL2/std.scad>
use <tools/blade_from_zy.scad>;
use <tools/blade_other.scad>;

$fn = 200;

module main() {


    leaf_num = 53;

    difference(){

        for (i = [0 : leaf_num-1])
            color("red")
                rotate([0, 0, i * (360 / leaf_num)/1 ])
                    translate([136.5, 0, 0])
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

        // 锯齿边
        extrend = 8.4;
        for (i = [0:29]){
            translate([0, 0, i * 3])
                cylinder(r1= 128 + extrend, r2=131 + extrend, h=1.6);

            translate([0, 0, i * 3 + 1.6])
                cylinder(r1= 131 + extrend, r2=128 + extrend, h=1.6);
        }

    }




// 叶片
    blade_base();
}

// scale_factor = 0.7;
scale_factor = 1;

scale([scale_factor, scale_factor, scale_factor])
{
    main();
}





