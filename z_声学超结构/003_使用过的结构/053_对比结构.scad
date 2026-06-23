include <BOSL2/std.scad>

$fn = 200;

// 交集：圆柱筒 ∩ 立方体
intersection() {
    // 圆柱筒（外径282，内径239，高度70）
    difference() {
        cylinder(h = 70, r = 282 / 2);
        cylinder(h = 70, r = 239 / 2);
    }
    
    // 立方体（200x200x80）
    cuboid([200, 200, 80], anchor = [-1, -1, -1]);
}

