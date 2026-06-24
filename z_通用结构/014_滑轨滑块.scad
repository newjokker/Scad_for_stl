include <BOSL2/std.scad>
include <BOSL2/sliders.scad>

$fn = 48;

spacing = 56;
row_gap = 58;   // 两排之间的间距

rail_color = [0.20, 0.47, 0.78, 1.00];
slider_color = [0.95, 0.62, 0.20, 1.00];
ghost_color = [0.95, 0.62, 0.20, 0.42];


// ===== 第一排：V 槽滑块 =====
translate([0, row_gap * 1.5, 0])
xdistribute(spacing=spacing) {

    color(slider_color) slider(l=35, w=10, h=8, base=8, wall=4, ang=30);
    color(slider_color) slider(l=35, w=12, h=10, base=8, wall=5, ang=30);
    color(slider_color) slider(l=35, w=14, h=10, base=10, wall=5, ang=35);
    color(slider_color) slider(l=35, w=16, h=12, base=10, wall=6, ang=40);
}


// ===== 第二排：V 槽滑轨 =====
translate([0, row_gap * 0.5, 0])
xdistribute(spacing=spacing) {

    color(rail_color) rail(l=45, w=10, h=8, ang=30);
    color(rail_color) rail(l=45, w=12, h=10, ang=30);
    color(rail_color) rail(l=45, w=14, h=10, ang=35);
    color(rail_color) rail(l=45, w=16, h=12, ang=40);
}



module slider_rail_pair(l=45, w=12, h=10, base=8, wall=5, ang=30, reveal=0, lift=0, ghost=false) {
    $slop = 0.2;

    color(rail_color)
    rail(l=l, w=w, h=h, ang=ang, anchor=CENTER);

    translate([0, reveal, lift])
    color(ghost ? ghost_color : slider_color)
    slider(l=l * 0.70, w=w, h=h, base=base, wall=wall, ang=ang, anchor=CENTER);
}
