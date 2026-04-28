include <BOSL2/std.scad>
include <BOSL2/joiners.scad>

$fn = 64;

spacing = 42;
row_gap = 34;   // 两排之间的间距

plate = [28, 38, 4];
slot_w = 16;
slot_h = 7;
slot_l = 28;


// ===== 第一排：燕尾榫和燕尾槽 =====
translate([0, 0, 0])
xdistribute(spacing=spacing) {

    dovetail("male", width=slot_w, height=slot_h, slide=slot_l);
    dovetail("female", width=slot_w, height=slot_h, slide=slot_l);
    dovetail("male", width=slot_w, height=slot_h, slide=slot_l, taper=5);
    dovetail("female", width=slot_w, height=slot_h, slide=slot_l, taper=5);
}


// ===== 第二排：带底板的公母件 =====
translate([0, -row_gap, 0])
xdistribute(spacing=spacing) {

    male_plate();
    female_plate();
    male_plate(taper=5);
    female_plate(taper=5);
}


// ===== 第三排：圆角和倒角燕尾 =====
translate([0, -row_gap * 2, 0])
xdistribute(spacing=spacing) {

    dovetail("male", width=slot_w, height=slot_h, slide=slot_l,
        chamfer=1);
    dovetail("female", width=slot_w, height=slot_h, slide=slot_l,
        chamfer=1);
    dovetail("male", width=slot_w, height=slot_h, slide=slot_l,
        radius=1.2, round=true);
    dovetail("female", width=slot_w, height=slot_h, slide=slot_l,
        radius=1.2, round=true);
}


module male_plate(taper=0) {
    cuboid(plate, anchor=BOTTOM)
        attach(TOP)
            dovetail("male", width=slot_w, height=slot_h,
                slide=slot_l, taper=taper);
}


module female_plate(taper=0) {
    diff()
    cuboid(plate, anchor=BOTTOM) {
        tag("remove")
        attach(TOP)
            dovetail("female", width=slot_w, height=slot_h,
                slide=slot_l, taper=taper);
    }
}
