// 纸箱自取提示牌 - OpenSCAD
// 双层结构：白色底板 1mm + 黑色上层 0.5mm
// 修复圆角边框不等宽问题
// 自动根据字符数调整宽度

// ============================================
// 参数配置
// ============================================

include <BOSL2/std.scad>
include <BOSL2/threading.scad>

$fn = 200;              

/* [尺寸参数] */
sign_height = 12;       // 牌子高度 (mm)
border_width = 1;       // 边框厚度 (mm)
corner_radius = 2;      // 外圆角半径 (mm)
white_base_thickness = 2.5;   // 白色底板厚度 (mm)
black_top_thickness = 1;    // 黑色上层厚度 (mm)

/* [颜色] */
frame_color = "black";     // 上层边框/文字颜色（黑色）
base_color = "white";      // 底板颜色（白色）

/* [文字参数] */
text_str = "番茄炒鸡蛋";      // 要显示的文字
text_size = 6;          // 文字大小
font_name = "Heiti SC:style=Regular";  // 字体

/* [磁吸孔参数] */
magnet_hole = true;     // 是否启用磁吸孔
magnet_radius = 3.1;    // 磁吸孔半径 (mm)
magnet_depth = 2.1;     // 磁吸孔深度 (mm)

function get_sign_width(str) = 
    let(len = len(str))
    len == 2 ? 23 :
    len == 3 ? 30 :
    len == 4 ? 38 :
    len == 5 ? 45 :
    len == 6 ? 52 :  
    len == 7 ? 59 :  
    len == 8 ? 66 :  
    23;  // 默认值


// 计算实际宽度
sign_width = get_sign_width(text_str);

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

// 磁吸孔模块
module magnet_hole_module() {
    if (magnet_hole) {
        translate([0, 0, -1])
            cylinder(r=magnet_radius, h=magnet_depth);
    }
}

// ============================================
// 模型生成
// ============================================

difference() {
    union() {
        // 底板
        color(base_color)
            rounded_rect(sign_width, sign_height, corner_radius, white_base_thickness);

        // 黑色边框
        color(frame_color)
            translate([0, 0, white_base_thickness])
                rounded_rect_frame(sign_width, sign_height, corner_radius, border_width, black_top_thickness);

        // 文字
        color(frame_color)
            translate([0, 0, white_base_thickness])
                linear_extrude(height = black_top_thickness)
                    text(
                        text_str,
                        size = text_size,
                        font = font_name,
                        halign = "center",
                        valign = "center"
                    );
    }
    
    // 磁吸孔（在底板底部）
    magnet_hole_module();
}

// ============================================
// 信息输出
// ============================================

echo(str("文字: ", text_str));
echo(str("字符数: ", len(text_str)));
echo(str("自动计算宽度: ", sign_width, "mm"));
echo(str("高度: ", sign_height, "mm"));