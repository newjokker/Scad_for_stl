include <BOSL2/std.scad>
include <BOSL2/threading.scad>

$fn = 200;              

w = 105;
l = 108;
h = 160;
wall = 2.5;
gap = 8;
gap_rounding = 20;
rounding = 10;

difference() {
    // 外部主体：仅左右棱圆角（TOP+LEFT, TOP+RIGHT, BOTTOM+LEFT, BOTTOM+RIGHT）
    cuboid([w, l, h], anchor=[0,0,-1], rounding=rounding, edges=[LEFT+FRONT, LEFT+BACK, RIGHT+FRONT, RIGHT+BACK]);
    
    // 内部掏空：保持同样的边缘圆角逻辑
    translate([0,0,wall])
        cuboid([w-wall*2, l-wall*2, h-wall], anchor=[0,0,-1], rounding=rounding, edges=[LEFT+FRONT, LEFT+BACK, LEFT+BACK, RIGHT+FRONT, RIGHT+BACK]);

    translate([20, 0, wall])
        cuboid([w, gap_rounding * 3, h], anchor=[0,0,-1]);

}

// 前挡板
translate([(w-wall)/2, gap/2,  0])
    cuboid([wall, (l-gap)/2 - 20, h], anchor=[0, -1, -1], rounding=gap_rounding, edges=[TOP+FRONT]);

// 后挡板（对称结构）
translate([(w-wall)/2, -gap/2,  0])
    cuboid([wall, (l-gap)/2 -20, h], anchor=[0, 1, -1], rounding=gap_rounding, edges=[TOP+BACK]);