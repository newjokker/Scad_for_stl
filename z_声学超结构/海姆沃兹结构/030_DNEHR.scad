include <BOSL2/std.scad>
include <BOSL2/structs.scad>

$fn = 50;

module DNEHR(lu, l1, du, dd, W, Lu, H, l2){

    t = 0.8;
    Ld = 45 - Lu - 3*t;   
    L = 45;
    
    difference(){
        cuboid([H, W, L], anchor=[0, 0, -1]);
        translate([0,0,t])
            cuboid([H - 2*t, W - 2*t, L - 2*t], anchor=[0, 0, -1]);
        translate([0, 0, L - 2*t])
            cuboid([du, du, t*3], anchor=[0, 0, -1]);
    }

    translate([0,0,L - lu])
        difference(){
            cuboid([du + 2*t, du + 2*t, lu], anchor=[0, 0, -1]);
            translate([0,0,-t])
                cuboid([du, du, lu + 2*t], anchor=[0, 0, -1]);
        }

    difference(){
        translate([0, 0, Ld + t])
            cuboid([H, W, t], anchor=[0, 0, -1]);
        translate([0, 0, Ld + t])
            cuboid([dd, dd, 2*t], anchor=[0, 0, -1]);
    }

    translate([0,0,Ld - l2 + t])
        difference(){
            cuboid([dd + 2*t, dd + 2*t, l1 + l2 + t], anchor=[0, 0, -1]);
            translate([0,0,-t])
                cuboid([dd, dd, l1 + l2 + t + 2*t], anchor=[0, 0, -1]);
        }
}

params = [
    [9.9, 4.5,  6.8,  2.2, 24.5, 37.3, 10.8,  2.8],
    [2.1, 2.2,  6.7,  3.6, 10.7, 20.2, 10.8, 17.0],
    [2.7, 0.0,  6.6,  5.2, 10.6, 24.7, 10.8,  6.8],
    [3.6, 0.2,  8.5,  7.1, 16.1, 17.9, 14.8, 20.0],
    [2.6, 7.7, 10.8,  5.0, 14.8, 17.3, 14.8, 23.0],
    [1.0, 0.1, 10.5, 10.8, 14.9, 41.8, 14.8,  0.0],
    [5.6, 3.2,  8.7,  7.0, 12.7, 10.3, 20.0, 28.1],
    [1.0,12.9, 11.0,  3.2, 15.0, 32.6, 20.0,  8.0],
    [1.0, 5.7, 10.0,  8.6, 18.1, 27.3, 20.0, 13.5],
];

cols = 3;         // 每行放几个
spacing_x = 20;   // X方向间距
spacing_y = 35;   // Y方向间距

for (i = [0 : len(params)-1]) {
    row = floor(i / cols);
    col = i % cols;
    p = params[i];

    translate([col * spacing_x, row * spacing_y, 0])
        DNEHR(
            lu = p[0],
            l1 = p[1],
            du = p[2],
            dd = p[3],
            W  = p[4],
            Lu = p[5],
            H  = p[6],
            l2 = p[7]
        );
}


