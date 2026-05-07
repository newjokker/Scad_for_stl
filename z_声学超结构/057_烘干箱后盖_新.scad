include <BOSL2/std.scad>

$fn = 500;

module half_ring(a=0, h=30, r=10, thick=1){
    rotate([0,0, a/2 + 90])
        rotate_extrude(angle = 360 - a)
            translate([r, 0, 0])
                square([thick, h]);
}

intersection(){

    union(){
        translate([0, 0, 0])

            // 支撑，用于容纳电动机的部分
            translate([0,0,-15])
                half_ring(a=0, h=65, r=91, thick= 22*2 + 7);
            
            // 里面出气孔层
            translate([0, 0, 50])
                difference(){
                    cylinder(r=91 + 22*2 + 7, h=10, center=false);
                    // 出气孔的大小
                    cylinder(r=15, h=10, center=false);
                }

            # translate([0, 0, 60])
            {
                // 中间的出气孔
                for(angle=[0: 360/8: 360]){
                    rotate([0, 0, angle])
                        half_ring(a=360 - (360/8 -5), h=5, r=91, thick= 22*2 + 7);
                }

                // 最外层盖板
                translate([0, 0, 5])
                    cylinder(r=91 + 22*2 + 7, h=5, center=false);
            }
    }


    // 裁切的立方体
    cuboid([500, 500, 500], anchor=[0, -1, 0]);

}



