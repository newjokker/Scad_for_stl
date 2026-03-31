
$fn = 128;


module half_ring(a=0, h=30, r=10, thick=1){
    rotate([0,0, a/2 + 90])
        rotate_extrude(angle = 360 - a)
            translate([r, 0, 0])
                square([thick, h]);
}


half_ring(a=30, h=30, r=10, thick=1);

