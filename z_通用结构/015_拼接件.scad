include <BOSL2/std.scad>
include <BOSL2/joiners.scad>

$fn = 48;

spacing = 42;
row_gap = 36;   // 两排之间的间距

body_color = [0.78, 0.80, 0.76, 1.00];
joiner_a_color = [0.95, 0.58, 0.18, 1.00];
joiner_b_color = [0.18, 0.48, 0.78, 1.00];


// ===== 第一排：半拼接件和完整拼接件 =====
translate([0, 0, 0])
xdistribute(spacing=spacing) {

    half_joiner(l=24, w=12, base=8);
    half_joiner2(l=24, w=12, base=8);
    joiner(l=36, w=12, base=8);
    joiner(l=36, w=12, base=8, screwsize=3);
}


// ===== 第二排：燕尾拼接 =====
translate([0, -row_gap, 0])
xdistribute(spacing=spacing) {

    dovetail("male", width=16, height=8, slide=28);
    dovetail("female", width=16, height=8, slide=28);
    dovetail("male", width=16, height=8, slide=28, taper=5);
    dovetail("female", width=16, height=8, slide=28, taper=5);
}


// ===== 第三排：两段式小置物架，中间必须靠拼接件合成整体 =====
translate([0, -row_gap * 2.5, 0])
xdistribute(spacing=118) {

    split_shelf_demo(exploded=true);
    split_shelf_demo(exploded=false);
}


// // ===== 第三排：卡扣销和卡扣孔 =====
// translate([0, -row_gap * 2, 0])
// xdistribute(spacing=spacing) {

//     snap_pin("standard", anchor=CENTER, orient=UP);
//     snap_pin("medium", anchor=CENTER, orient=UP);
//     snap_pin_socket("standard", anchor=CENTER, orient=UP, fins=true);
//     snap_pin_socket("medium", anchor=CENTER, orient=UP, fins=true);
// }


// // ===== 第四排：兔耳扣 =====
// translate([0, -row_gap * 3, 0])
// xdistribute(spacing=spacing) {

//     rabbit_clip("pin", length=18, width=14, snap=1.2,
//         thickness=1.2, depth=6, compression=0.3);
//     rabbit_clip("socket", length=18, width=14, snap=1.2,
//         thickness=1.2, depth=6.5, clearance=0.2, orient=UP);
//     rabbit_clip("double", length=12, width=12, snap=1,
//         thickness=1.0, depth=6, compression=0.2, orient=UP);
//     rabbit_clip("pin", length=22, width=18, snap=1.6,
//         thickness=1.4, depth=7, lock=true, lock_clearance=2);
// }


module split_shelf_demo(exploded=false) {
    gap = exploded ? 20 : 0;

    translate([-32 - gap / 2, 0, 0])
        split_shelf_half(side="left");

    translate([32 + gap / 2, 0, 0])
        split_shelf_half(side="right");
}


// 简单用途示例：左右两半分别打印，扣合后成为一条完整小置物架。
module split_shelf_half(
    side="left",
    size=[64, 38, 8],
    wall=2.4,
    lip_h=10,
    joiner_l=26,
    joiner_w=10,
    joiner_base=7
) {
    $slop = 0.2;
    seam_dir = side == "left" ? 1 : -1;
    seam_x = seam_dir * size.x / 2;
    joiner_kind = side == "left" ? "a" : "b";

    color(body_color)
    union() {
        cuboid(size, rounding=1.4, edges="Z", anchor=BOTTOM);

        // 后挡边，扣合后变成一条连续挡边，适合放小工具或手机。
        translate([0, size.y / 2 - wall / 2, size.z])
            cuboid([size.x, wall, lip_h], rounding=1.0, edges="Z", anchor=BOTTOM);

        // 前方低挡条，防止圆柱类小零件滚落。
        translate([0, -size.y / 2 + wall / 2, size.z])
            cuboid([size.x, wall, wall * 1.6], rounding=0.8, edges="Z", anchor=BOTTOM);
    }

    translate([seam_x + seam_dir * (joiner_base / 2 - 0.05), 0, size.z / 2])
        shelf_joiner_pair(
            kind=joiner_kind,
            side_dir=seam_dir,
            shelf_w=size.y,
            l=joiner_l,
            w=joiner_w,
            base=joiner_base
        );

    // 接缝处的小定位台，扣合时两块平台高度更容易对齐。
    color(body_color)
    translate([seam_x - seam_dir * wall / 2, 0, size.z])
        cuboid([wall, size.y - wall * 4, wall], rounding=0.6, edges="Z", anchor=BOTTOM);
}


module shelf_joiner_pair(kind="a", side_dir=1, shelf_w=38, l=26, w=10, base=7) {
    ycopies(spacing=shelf_w * 0.48, n=2)
    rotate([0, side_dir * 90, 0])
    color(kind == "a" ? joiner_a_color : joiner_b_color)
    if (kind == "a")
        half_joiner(l=l, w=w, base=base, ang=30);
    else
        half_joiner2(l=l, w=w, base=base, ang=30);
}
