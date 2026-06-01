include <BOSL2/std.scad>
include <BOSL2/threading.scad>

$fn = 200;              

w = 105;
l = 108;
h = 160;
wall = 3;
gap = 5;
gap_length = 140;
gap_rounding = 20;

difference() {
    // 外部主体：仅左右棱圆角（TOP+LEFT, TOP+RIGHT, BOTTOM+LEFT, BOTTOM+RIGHT）
    cuboid([w, l, h], anchor=[0,0,-1]);
    
    // 内部掏空：保持同样的边缘圆角逻辑
    translate([wall,0,wall])
        cuboid([w-wall, l-wall*2, h-wall], anchor=[0,0,-1]);
}

// 前挡板
color([0.5, 0.5, 1])
translate([(l-2*wall)/2, gap/2,  0])
    cuboid([wall, (l-gap)/2, h], anchor=[0, -1, -1], rounding=gap_rounding, edges=[TOP+FRONT]);

// 后挡板（对称结构）
color([0.5, 0.5, 1])
translate([(l-2*wall)/2, -gap/2,  0])
    cuboid([wall, (l-gap)/2, h], anchor=[0, 1, -1], rounding=gap_rounding, edges=[TOP+BACK]);