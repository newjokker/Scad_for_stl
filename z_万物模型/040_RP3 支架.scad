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


module A(length=10, r1=1, r2=0.5, gap=0.3) {
    difference() {
        translate([0, 0, r1])
            rotate([90, 0, 0])
                difference() {
                    // 管子
                    union() {
                        cuboid([r1*2, r1, length], anchor=[0, 1, 0]);
                        cylinder(h=length, r=r1, center=true);
                    }
                    // 掏空心
                    cylinder(h=length, r=r2, center=true);
                }
        // 安装天线的缝
        translate([0, 0, r1/2 * 3/2])
            cuboid([gap, length, 5], anchor=[0, 0, -1]);
    }
}

difference() {

    union(){
        A(length=15);

        translate([-12/2, 0, 0]) 
            rotate([0, 0, 90])
                A(length=12);
    }

    translate([0, 0, 1/2]) 
        cuboid([9, 5, 5], anchor=[0, 0, -1]);
}





