include <BOSL2/std.scad>
include <BOSL2/structs.scad>

$fn = 128;

L = 150;
W = 200;
H = 1000;
thick = 3.2;
outer_rounding = 30;
inner_rounding = outer_rounding - thick;

hole_w = 130;
hole_l = 130;

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

    // 开三个 150 *  150 的方孔，方便安装
    translate([0, 0, 500]) 
        rotate([90, 0, 90]) 
            cuboid(
                [hole_w, hole_l, 200],
                anchor=[0, 0, -1],
            );

    translate([0, 0, 500 - 150 * 2]) 
        rotate([90, 0, 90]) 
            cuboid(
                [hole_w, hole_l, 200],
                anchor=[0, 0, -1],
            );

    translate([0, 0, 500 + 150 * 2]) 
        rotate([90, 0, 90]) 
            cuboid(
                [hole_w, hole_l, 200],
                anchor=[0, 0, -1],
            );

}