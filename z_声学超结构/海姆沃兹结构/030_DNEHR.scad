include <BOSL2/std.scad>
include <BOSL2/structs.scad>

$fn = 50;

// ===== 参数（单位 mm）=====
t  = 1;   // 壁厚

lu  = 30.1;     
l1  = 0.3;
du  = 6.7;    
dd  = 3.2;     
W   = 24.1;
Lu  = 35.7;    
H   = 10.8;

Ld = 45 - Lu -3*t;    // 下腔高度
l2 = 4; 
L= 45;


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





