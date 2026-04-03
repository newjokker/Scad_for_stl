
include <BOSL2/std.scad>

$fn = 128;


length = 220;

thick = 5;

difference(){

    cuboid([length, length, length], anchor = [-1,-1,-1]);

    translate([thick, thick, thick])
        cuboid([length - 2 * thick, length - 2 * thick, length + 100], anchor = [-1,-1,-1]);

    translate([length/2, length/2, -0.01])
        cylinder(h=10 + 0.02, r=125/2, center=false);

}

//


// translate([215/2, 215/2, 215 + 40])
//     difference(){
//         cuboid([215, 215, 10], anchor=[0, 0, -1]);

//         translate([0, 0, -0.01])
//             cylinder(h=10 + 0.02, r=125/2, center=false);

//         cuboid([1000, 1000, 1000], anchor=[1, 0, -1]);

//     }





