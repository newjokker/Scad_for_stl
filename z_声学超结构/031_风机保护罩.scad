include <BOSL2/std.scad>
include <BOSL2/structs.scad>

$fn = 128;

thick = 2;



// ================= 参数 =================
wall_thickness = 2;

rect_length = 55 - wall_thickness * 2;                               // 矩形长边
rect_width  = 46.5 - wall_thickness *2;                             // 矩形短边
diameter    = 120 - wall_thickness * 2;         // 圆管内径

rect_stub_h  = 30;   // 底部矩形直段高度
blend_height = 70;  // 过渡段高度
round_stub_h = 40;   // 顶部圆管直段高度

corner_r = 12;       // 矩形圆角半径，建议 8~15


module A(d1, d2) {
    // 2) 渐变段
    hull() {
        translate([0, 0, 0])
            linear_extrude(height = 0.01)
                circle(d = d1);

        translate([0, 0, 0 + blend_height])
            linear_extrude(height = 0.01)
                circle(d = d2);
    }
}

difference() {
    A(70, 150);
    A(70 -2*thick, 150 -2*thick);
}

difference() {
    cylinder(h = 4, r = 120/2);
    A(70 -2 * thick, 150 -2 * thick);
}   