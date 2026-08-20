// 茶盘
include <BOSL2/std.scad>

$fn = 168;

// ===== 内部净空间 =====
inner_length = 244;
inner_height = 90;

// ===== 壁厚与底厚 =====
wall_thickness   = 5;
bottom_thickness = 4;

// ===== XY 平面四角圆角 =====
inner_corner_r = 25;
outer_corner_r = inner_corner_r + wall_thickness;

// ===== 顶部内侧斜面 =====
top_bevel_h = 5;       // 斜面高度
top_bevel_w = 3;       // 向外扩大的宽度，单边尺寸

// ===== 自动计算 =====
outer_length = inner_length + wall_thickness * 2;
outer_height = inner_height + bottom_thickness;


// 生成圆角矩形柱
module rounded_box_xy(size, h, r) {
    linear_extrude(height = h)
        rect(
            size,
            rounding = r
        );
}


// 外部主体保持竖直
module outer_body() {
    rounded_box_xy(
        [outer_length, outer_length],
        outer_height,
        outer_corner_r
    );
}


// 内部净空间，顶部向外扩大形成朝内斜面
module inner_cutout() {

    union() {

        // 内部主体空间
        rounded_box_xy(
            [inner_length, inner_length],
            inner_height - top_bevel_h + 0.01,
            inner_corner_r
        );

        // 顶部内侧斜面
        hull() {

            // 斜面底部
            translate([0, 0, inner_height - top_bevel_h])
                linear_extrude(height = 0.01)
                    rect(
                        [inner_length, inner_length],
                        rounding = inner_corner_r
                    );

            // 斜面顶部，开口扩大
            translate([0, 0, inner_height + 0.01])
                linear_extrude(height = 0.01)
                    rect(
                        [
                            inner_length + top_bevel_w * 2,
                            inner_length + top_bevel_w * 2
                        ],
                        rounding = inner_corner_r + top_bevel_w
                    );
        }
    }
}


difference() {

    outer_body();

    translate([0, 0, bottom_thickness])
        inner_cutout();
}