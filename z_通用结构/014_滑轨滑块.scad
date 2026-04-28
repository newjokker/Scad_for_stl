include <BOSL2/std.scad>
include <BOSL2/sliders.scad>

$fn = 48;

spacing = 52;
row_gap = 34;   // 两排之间的间距


// ===== 第一排：V 槽滑块 =====
translate([0, 0, 0])
xdistribute(spacing=spacing) {

    slider(l=35, w=10, h=8, base=8, wall=4, ang=30);
    slider(l=35, w=12, h=10, base=8, wall=5, ang=30);
    slider(l=35, w=14, h=10, base=10, wall=5, ang=35);
    slider(l=35, w=16, h=12, base=10, wall=6, ang=40);
}


// ===== 第二排：V 槽滑轨 =====
translate([0, -row_gap, 0])
xdistribute(spacing=spacing) {

    rail(l=45, w=10, h=8, ang=30);
    rail(l=45, w=12, h=10, ang=30);
    rail(l=45, w=14, h=10, ang=35);
    rail(l=45, w=16, h=12, ang=40);
}


// ===== 第三排：滑块和滑轨组合 =====
translate([0, -row_gap * 2, 0])
xdistribute(spacing=spacing) {

    slider_rail_pair(l=45, w=10, h=8, base=8, wall=4, ang=30);
    slider_rail_pair(l=45, w=12, h=10, base=8, wall=5, ang=30);
    slider_rail_pair(l=45, w=14, h=10, base=10, wall=5, ang=35);
}


module slider_rail_pair(l=45, w=12, h=10, base=8, wall=5, ang=30) {
    $slop = 0.2;

    down(h / 2)
    rail(l=l, w=w, h=h, ang=ang);

    up(base + h / 2 + 3)
    slider(l=l * 0.75, w=w, h=h, base=base, wall=wall, ang=ang);
}
