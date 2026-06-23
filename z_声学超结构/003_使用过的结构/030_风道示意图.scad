include <BOSL2/std.scad>
include <BOSL2/structs.scad>

$fn = 128;

L = 200;
W = 200;
H = 333;
thick = 3.2;
outer_rounding = 30;
inner_rounding = outer_rounding - thick;

// 洞的尺寸
hole_w = 150;
hole_l = 120;

// 三个孔的高度
// z_list = [500, 500 - 130 * 2, 500 + 130 * 2];
z_list = [333/2];

difference() {
    cuboid(
        [L, W, H],
        anchor=[0, 0, -1],
        rounding=outer_rounding,
        edges=["Z"]
    );

    translate([0, 0, -1]) 
        cuboid(
            [L - thick*2, W - thick*2, H + 5],
            anchor=[0, 0, -1],
            rounding=inner_rounding,
            edges="Z"
        );

    // ========= 左右两侧（X方向） =========
    for (z = z_list) {

        // 左侧 (-X)
        translate([-400, 0, z]) 
            rotate([90, 0, 90]) 
                cuboid([hole_l, hole_w, 800], anchor=[0, 0, -1]);

        // 右侧 (+X)
        translate([400, 0, z]) 
            rotate([90, 0, 90]) 
                cuboid([hole_l, hole_w, 800], anchor=[0, 0, -1]);
    }

    // ========= 前后两侧（Y方向） =========
    for (z = z_list) {

        // 前侧 (-Y)
        translate([0, -400, z]) 
            rotate([90, 90, 0]) 
                cuboid([hole_w, hole_l, 800], anchor=[0, 0, -1]);

        // 后侧 (+Y)
        translate([0, 400, z]) 
            rotate([90, 90, 0]) 
                cuboid([hole_w, hole_l, 800], anchor=[0, 0, -1]);
    }
}