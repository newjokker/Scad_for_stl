include <BOSL2/std.scad>
include <BOSL2/structs.scad>

$fn = 50;

// ===== 参数（单位 mm）=====
t  = 1;   // 壁厚

Lu = 15;    // 上腔高度
Ld = 25;    // 下腔高度

du = 10;    // 上开口宽
dd = 8;     // 下开口宽

lu = 6;     // 上颈长度

l1 = 5;
l2 = 10; 

L= Lu + Ld + 3*t;
H= 30;
W= 30;

module DNEHR(){
    // 外面的大框
    difference(){
        cuboid([H, W, L], anchor=[0, 0, -1]);
        translate([0,0,t])
            cuboid([H -2*t, W-2*t, L-2*t], anchor=[0, 0, -1]);
        translate([0, 0, L-2*t])
            cuboid([du, du, t*3], anchor=[0, 0, -1]);
    }
    // 上面的框
    translate([0,0,L-lu])
        difference(){
            cuboid([du + 2*t, du + 2*t, lu], anchor=[0, 0, -1]);
            translate([0,0,-t])
                cuboid([du, du, lu+2*t], anchor=[0, 0, -1]);
        }
    // 隔板
    difference(){
        translate([0, 0, Ld + t])
            cuboid([H, W, t], anchor=[0, 0, -1]);
        translate([0, 0, Ld + t])
            cuboid([dd, dd, 2*t], anchor=[0, 0, -1]);
    }
    // 下面的框
    translate([0,0,Ld-l2+t])
        difference(){
            cuboid([dd + 2*t, dd + 2*t, l1 + l2 + t], anchor=[0, 0, -1]);
            translate([0,0,-t])
                cuboid([dd, dd, l1 + l2 + t+2*t], anchor=[0, 0, -1]);
        }

}


difference(){
    DNEHR();
    cuboid([100, 100, 100], anchor=[-1, 0, -1]);
}





