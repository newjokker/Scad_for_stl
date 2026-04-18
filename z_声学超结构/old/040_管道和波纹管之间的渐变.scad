include <BOSL2/std.scad>
include <BOSL2/structs.scad>

$fn = 128;

// ================= 参数 =================
wall_thickness = 2;

// 下方圆管尺寸
inner_diameter = 120 - wall_thickness * 2;   // 下方内径
outer_diameter = 120;                        // 下方外径

// 顶部新矩形尺寸（注意：这里是外尺寸）
top_outer_length = 192.6;                    // 顶部外矩形长
top_outer_width  = 192.6;                    // 顶部外矩形宽

top_inner_length = top_outer_length - 2 * wall_thickness;
top_inner_width  = top_outer_width  - 2 * wall_thickness;

round_stub_h = 30;     // 底部圆管直段高度
blend_height = 150;    // 过渡段高度
rect_stub_h  = 40;     // 顶部矩形直段高度

top_corner_r = 25/2;      // 顶部矩形圆角，若不要圆角就保持 0


// ================= 圆角矩形截面 =================
module rounded_rect_2d(l=100, w=50, r=8) {
    r_use = min(r, l/2 - 0.01, w/2 - 0.01);
    if (r_use > 0)
        offset(r = r_use)
            square([l - 2*r_use, w - 2*r_use], center=true);
    else
        square([l, w], center=true);
}


// ================= 单层流道外形/内形：圆 -> 矩形 =================
module circle_to_rect_transformer(
    diameter = 120,
    top_length = 192.6,
    top_width = 192.6,
    round_stub_h = 30,
    blend_height = 100,
    rect_stub_h = 40,
    top_corner_r = 0
) {
    union() {
        // 1) 底部圆管直段
        cylinder(h = round_stub_h, d = diameter, center = false);

        // 2) 渐变段：圆 -> 矩形
        hull() {
            translate([0, 0, round_stub_h])
                linear_extrude(height = 0.01)
                    circle(d = diameter);

            translate([0, 0, round_stub_h + blend_height])
                linear_extrude(height = 0.01)
                    rounded_rect_2d(top_length, top_width, top_corner_r);
        }

        // 3) 顶部矩形直段
        translate([0, 0, round_stub_h + blend_height])
            linear_extrude(height = rect_stub_h)
                rounded_rect_2d(top_length, top_width, top_corner_r);
    }
}


// ================= 中空转换器 =================
difference() {
    // 外轮廓：顶部用外尺寸 192.6
    circle_to_rect_transformer(
        diameter     = outer_diameter,
        top_length   = top_outer_length,
        top_width    = top_outer_width,
        round_stub_h = round_stub_h,
        blend_height = blend_height,
        rect_stub_h  = rect_stub_h,
        top_corner_r = top_corner_r
    );

    // 内流道：顶部用内尺寸 192.6 - 2*壁厚
    circle_to_rect_transformer(
        diameter     = inner_diameter,
        top_length   = top_inner_length,
        top_width    = top_inner_width,
        round_stub_h = round_stub_h,
        blend_height = blend_height,
        rect_stub_h  = rect_stub_h,
        top_corner_r = top_corner_r
    );
}