include <BOSL2/std.scad>

$fn = 336;

// 类似于旗杆，底部有一个弯折里面有螺丝孔

thick = 1.2;

// difference() {
//     cuboid([5, 14, 23], anchor=[-1, 0, -1]);
//     translate([thick, 0, 0]) 
//         cuboid([5 - thick * 2, 14 - thick * 2, 23], anchor=[-1, 0, -1]);
//     translate([thick, 0, 0]) 
//         cuboid([5 - thick, thick * 4, 23], anchor=[-1, 0, -1]);
// }

// difference() {
//     cuboid([20, 14, 2], anchor=[-1, 0, -1]);
//     translate([15, 0, 0, ]) 
//         cylinder(h=10, r=3.3/2);
// }


length = 10;
          
difference() {
    translate([0, 0, 1])
        rotate([90, 0, 0])
            difference() {
                // 管子
                union() {
                    cuboid([2, 1, length], anchor=[0, 1, 0]);
                    cylinder(h=length, r=1, center=true);
                }
                // 掏空心
                cylinder(h=length, r=0.8, center=true);
            }
    // 安装天线的缝
    translate([0, 0, 0.5])
        cuboid([0.2, length, 5], anchor=[0, 0, -1]);

}




