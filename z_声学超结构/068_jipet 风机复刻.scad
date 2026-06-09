
include <BOSL2/std.scad>
use <tools/blade_from_zy.scad>;
use <tools/blade_jipet.scad>;

$fn = 1200;

module main() {


    leaf_num = 53;
    // leaf_num = 61;

    difference(){

        for (i = [0 : leaf_num-1])
            color("red")
                rotate([0, 0, i * (360 / leaf_num)/1 ])
                    translate([108, 0, 0])
                        rotate([0, 0, 10])
                            mirror([0, 0, 0])
                                centrifugal_blade_airfoil(
                                    // m = 0.06,
                                    // FIXME: 这边是修改的弯曲程度
                                    m = 0.19,
                                    p = 0.40,
                                    t = 0.12,
                                    num_points = 200,
                                    chord = 23,
                                    mode = "3d",
                                    width = 106,
                                    center_3d = false
                                );

        // // 锯齿边
        // extrend = 6.5;
        // length = 125;
        // length_diff = 5;
        // lenght_h = 5;
        // // # for (i = [27:29]){
        // for (i = [0:25]){
        //     translate([0, 0, i * lenght_h])
        //         cylinder(r1= length + extrend + 3, r2=length + extrend + 3 + length_diff, h=lenght_h);

        //     translate([0, 0, i * lenght_h + lenght_h])
        //         cylinder(r1= length + extrend + 3 + length_diff, r2=length + extrend + 3, h=lenght_h);
        // }

    }




// 叶片
    blade_base();
}

main();






