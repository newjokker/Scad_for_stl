include <BOSL2/std.scad>
include <BOSL2/structs.scad>

$fn = 128;

// ================= 参数 =================
wall_thickness = 3;

rect_length = 205;   // 矩形长边
rect_width  = 105;   // 矩形短边
diameter    = 156;   // 圆管内径

rect_stub_h  = 30;   // 底部矩形直段高度
blend_height = 100;  // 过渡段高度
round_stub_h = 30;   // 顶部圆管直段高度

corner_r = 12;       // 矩形圆角半径，建议 8~15


// ================= 圆角矩形截面 =================
module rounded_rect_2d(l=100, w=50, r=8) {
    r_use = min(r, l/2 - 0.01, w/2 - 0.01);
    offset(r = r_use)
        square([l - 2*r_use, w - 2*r_use], center=true);
}


// ================= 单层流道外形/内形 =================
module pip_transformer(
    rect_length = 205,
    rect_width  = 100,
    diameter    = 156,
    rect_stub_h = 20,
    blend_height = 145,
    round_stub_h = 60,
    corner_r = 12
) {
    union() {
        // 1) 底部矩形直段
        linear_extrude(height = rect_stub_h)
            rounded_rect_2d(rect_length, rect_width, corner_r);

        // 2) 渐变段
        hull() {
            translate([0, 0, rect_stub_h])
                linear_extrude(height = 0.01)
                    rounded_rect_2d(rect_length, rect_width, corner_r);

            translate([0, 0, rect_stub_h + blend_height])
                linear_extrude(height = 0.01)
                    circle(d = diameter);
        }

        // 3) 顶部圆管直段
        translate([0, 0, rect_stub_h + blend_height])
            cylinder(h = round_stub_h, d = diameter, center = false);
    }
}


// ================= 中空转换器 =================
difference() {
    // 外轮廓
    pip_transformer(
        rect_length  = rect_length + 2*wall_thickness,
        rect_width   = rect_width  + 2*wall_thickness,
        diameter     = diameter    + 2*wall_thickness,
        rect_stub_h  = rect_stub_h,
        blend_height = blend_height,
        round_stub_h = round_stub_h,
        corner_r     = corner_r + wall_thickness
    );

    // 内流道
    pip_transformer(
        rect_length  = rect_length,
        rect_width   = rect_width,
        diameter     = diameter,
        rect_stub_h  = rect_stub_h,
        blend_height = blend_height,
        round_stub_h = round_stub_h,
        corner_r     = corner_r
    );
}