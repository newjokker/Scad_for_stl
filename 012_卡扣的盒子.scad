
include <BOSL2/std.scad>

$fn = 60;

L = 20;
W = 10;
H = 5;
a = 0.5;    // 盒子外墙的厚度 
b = 0.5;    // 盒子唇边的高度


module box_down(L, W, H, a, b){
    
    // 盒子下部分
    difference(){
        
        // 标准的盒子
        cuboid(size=[L, W , H + b], anchor=[-1, -1, -1]);
        translate([a, a, a])
            cuboid(size=[L-2*a, W -2*a, H * 2], anchor=[-1, -1, -1]);

        // 盒子的唇边
        translate([a/2, a/2, H])
            cuboid(size=[L-a, W -a, H * 2], anchor=[-1, -1, -1]);
    }

    // 突出的几个小块
    c = 0.3;
    translate([L/2, a/2, H + a/2])
        sphere(r = a/3);

}

module box_up(L, W, H, a, b){
    
    // 盒子下部分
    difference(){
        
        // 标准的盒子
        cuboid(size=[L, W , H * 2], anchor=[-1, -1, -1]);

        translate([a, a, a])
            cuboid(size=[L-2*a, W -2*a, H * 2 - 2*a], anchor=[-1, -1, -1]);


        box_down(L, W, H, a, b);

    }

}


box_up(L, W, 1, a, b);

translate([0, 0, -8])
    box_down(L, W, 4, a, b);
