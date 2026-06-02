// 纸箱自取提示牌 - OpenSCAD
// 双层结构：白色底板 1mm + 黑色上层 0.5mm
// 修复圆角边框不等宽问题

// ============================================
// 参数配置
// ============================================

include <BOSL2/std.scad>
include <BOSL2/threading.scad>


$fn = 200;              


/* [尺寸参数] */
sign_width = 40;       // 牌子宽度 (mm)
sign_height = 15;       // 牌子高度 (mm)
border_width = 1;     // 边框厚度 (mm)
corner_radius = 1;      // 外圆角半径 (mm)
white_base_thickness = 0.5;   // 白色底板厚度 (mm)
black_top_thickness = 0.5;   // 黑色上层厚度 (mm)

/* [颜色] */
frame_color = "black";     // 上层边框/文字颜色（黑色）
base_color = "white";      // 底板颜色（白色）

text_str  = "知行室测试";
text_size = 6;
font_name = "Heiti SC:style=Regular";


// ============================================
// 模块定义
// ============================================

module rounded_rect(w, h, r, thickness) {
    linear_extrude(thickness)
        offset(r=r, $fn=64)
            square([w - 2*r, h - 2*r], center=true);
}

// 带不等距偏移的圆角矩形（用于等宽边框）
module rounded_rect_frame(outer_w, outer_h, outer_r, frame_w, thickness) {
    linear_extrude(thickness)
        difference() {
            offset(r=outer_r, $fn=64)
                square([outer_w - 2*outer_r, outer_h - 2*outer_r], center=true);
            // 关键修复：内圈圆角半径 = 外圈半径 - 边框宽度
            offset(r=outer_r - frame_w, $fn=64)
                square([outer_w - 2*outer_r, outer_h - 2*outer_r], center=true);
        }
}

// ============================================
// 模型生成
// ============================================

// 第一层：白色底板
color(base_color)
    rounded_rect(sign_width, sign_height, corner_radius, white_base_thickness);

// 第二层：黑色边框（等宽圆角）
color(frame_color)
    translate([0, 0, white_base_thickness])
        rounded_rect_frame(sign_width, sign_height, corner_radius, border_width, black_top_thickness);

color(frame_color)
    linear_extrude(height = white_base_thickness + black_top_thickness)
        text(
            text_str,
            size = text_size,
            font = font_name,
            halign = "center",
            valign = "center"
        );