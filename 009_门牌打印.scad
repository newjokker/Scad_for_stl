$fn = 64;

// =====================
// 全局参数（两部分共用）
// =====================
plate_w = 140;
plate_h = 45;
plate_t = 1.2;
corner_r = 4;

text_str  = "知行室";
text_size = 28;
font_name = "Heiti SC:style=Regular";

text_height = 1.2;

// 笔画连接（防止中文断裂）
stroke_join = 0.35;

// 装配间隙（阴文孔 > 阳文字）
fit_gap = 0.10;

// 阴阳文之间的展示间距
spacing = 160;


// =====================
// 工具模块
// =====================

// 圆角矩形
module rounded_rect(w, h, r) {
    offset(r = r)
        square([w - 2*r, h - 2*r], center = true);
}

// 文字轮廓（统一来源）
module text_shape(delta = 0) {
    offset(delta = delta)
        text(
            text_str,
            size = text_size,
            font = font_name,
            halign = "center",
            valign = "center"
        );
}


// =====================
// 阴文（底板挖空）
// =====================
module yin_plate() {
    difference() {

        // 底板
        linear_extrude(height = plate_t)
            rounded_rect(plate_w, plate_h, corner_r);

        // 挖空文字（略大，形成装配间隙）
        translate([0, 0, -0.1])
            linear_extrude(height = plate_t + 0.2)
                text_shape(delta = stroke_join + fit_gap);
    }
}


// =====================
// 阳文（嵌入字块）
// =====================
module yang_text() {
    linear_extrude(height = text_height)
        text_shape(delta = stroke_join);
}


// =====================
// 组合展示
// =====================

// 左：阴文
translate([0, 0, 0])
    yin_plate();

// 右：阳文
translate([ 0, 45, 0])
    yang_text();
