
include <BOSL2/std.scad>
include <BOSL2/rounding.scad>

$fn = 200;  // 优化性能

thick = 2;

// difference(){
//     cuboid([65.15 + 2 + thick, 37 + 2 + thick, 40], anchor=[0, 0, -1]);
    
//     translate([0, 0, thick])
//         cuboid([65.15 + 2, 37 + 2 , 40], anchor=[0, 0, -1]);

//     translate([0, 0, -thick])
//         cuboid([65.15 - 2, 37 - 2 , 40], anchor=[0, 0, -1]);

    
//     translate([25, 0, 40/2])
//         rotate([0,90,0])
//             cylinder(h = 20, r=5.8/2);

// }


L = 112;
W = 58;
thick = 2;
H = 30;

difference(){

cuboid([L + 2 * thick, W + 2 * thick, H + 2 * thick], anchor=[0, 0, -1]);

translate([0, 0, thick])
    cuboid([L, W, H + thick * 2], anchor=[0, 0, -1]);
}




