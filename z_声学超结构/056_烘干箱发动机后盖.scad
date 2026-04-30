include <BOSL2/std.scad>

$fn = 200;

module half_ring(a=0, h=30, r=10, thick=1){
    rotate([0,0, a/2 + 90])
        rotate_extrude(angle = 360 - a)
            translate([r, 0, 0])
                square([thick, h]);
}

module old(){
    a = 0;   // 旋转的角度

    rotate([0, 0, 45])
    {
        difference(){
            half_ring(a=a, h=10, r=91, thick= 22*2 + 7);
            half_ring(a=a -1 , h=10, r=91 + 22, thick= 7);
            translate([0, 0, 3])
                half_ring(a=a -1 , h=4, r=91 + 3, thick= 19 * 2 + 7);
        }
    }

    translate([0, 0, 60])
        rotate([0, 0, 45])
        {
            difference(){
                half_ring(a=a, h=10, r=91, thick= 22*2 + 7);
                half_ring(a=a -1 , h=10, r=91 + 22, thick= 7);
                translate([0, 0, 3])
                    half_ring(a=a -1 , h=4, r=91 + 3, thick= 19 * 2 + 7);
            }
        }

    translate([0, 0, 10])
        half_ring(a=a, h=50, r=91, thick= 22);
}

old();

