include <BOSL2/std.scad>

$fn = 200;              // 圆形细分精度


difference(){
    cuboid([215, 215, 10], anchor=[0, 0, -1]);

    translate([0, 0, -0.01])
        cylinder(h=10 + 0.02, r=125/2, center=false);

    cuboid([1000, 1000, 1000], anchor=[1, 0, -1]);

}

