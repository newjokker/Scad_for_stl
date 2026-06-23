include <BOSL2/std.scad>

$fn = 200;              // 圆形细分精度

d_in = 150;
thick = 15;


difference(){


    cylinder(h = 100, d = d_in + 2 * thick, center = false);


    translate([0, 0, thick]){
        cylinder(h = 100 + 0.02, d = d_in, center = false);
    }

    translate([0, 0, - thick]){
        cylinder(h = 200, d = d_in - 40, center = false);
    }

}

translate([d_in/2 - 5, 0, 0])
    rotate([180, 0, 0])
    {
        cylinder(h = 80, d = 25, center = false);
    }


translate([-d_in/2 + 5, 0, 0])
    rotate([180, 0, 0])
    {
        cylinder(h = 80, d = 25, center = false);
    }

translate([0, -d_in/2 + 5, 0])
    rotate([180, 0, 0])
    {
        cylinder(h = 80, d = 25, center = false);
    }

translate([0, d_in/2 - 5, 0])
    rotate([180, 0, 0])
    {
        cylinder(h = 80, d = 25, center = false);
    }


translate([0, 0, -85])
    cylinder(h = thick, d = d_in * 1.5, center = false);
