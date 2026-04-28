
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
        extrend = 6.5;
        length = 125;
        length_diff = 5;
        lenght_h = 5;
        // # for (i = [27:29]){
        for (i = [0:25]){
            translate([0, 0, i * lenght_h])
                cylinder(r1= length + extrend + 3, r2=length + extrend + 3 + length_diff, h=lenght_h);

            translate([0, 0, i * lenght_h + lenght_h])
                cylinder(r1= length + extrend + 3 + length_diff, r2=length + extrend + 3, h=lenght_h);
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





