include <BOSL2/std.scad>
include <BOSL2/joiners.scad>

$fn = 48;

spacing = 42;
row_gap = 36;   // 两排之间的间距


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


// ===== 第三排：卡扣销和卡扣孔 =====
translate([0, -row_gap * 2, 0])
xdistribute(spacing=spacing) {

    snap_pin("standard", anchor=CENTER, orient=UP);
    snap_pin("medium", anchor=CENTER, orient=UP);
    snap_pin_socket("standard", anchor=CENTER, orient=UP, fins=true);
    snap_pin_socket("medium", anchor=CENTER, orient=UP, fins=true);
}


// ===== 第四排：兔耳扣 =====
translate([0, -row_gap * 3, 0])
xdistribute(spacing=spacing) {

    rabbit_clip("pin", length=18, width=14, snap=1.2,
        thickness=1.2, depth=6, compression=0.3);
    rabbit_clip("socket", length=18, width=14, snap=1.2,
        thickness=1.2, depth=6.5, clearance=0.2, orient=UP);
    rabbit_clip("double", length=12, width=12, snap=1,
        thickness=1.0, depth=6, compression=0.2, orient=UP);
    rabbit_clip("pin", length=22, width=18, snap=1.6,
        thickness=1.4, depth=7, lock=true, lock_clearance=2);
}
