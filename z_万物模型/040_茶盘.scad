// 茶盘
include <BOSL2/std.scad>

$fn = 168;

// ===== 内部净空间 =====
inner_length = (252 + 242) / 2;
inner_height = 90;

// ===== 壁厚与底厚 =====
wall_thickness   = 5;
bottom_thickness = 5;

// ===== XY 平面四角圆角 =====
inner_corner_r = 25;
outer_corner_r = inner_corner_r + wall_thickness;

// ===== 顶部边缘圆角 =====
top_edge_r = 3;

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


// 带圆润顶部边缘的外壳
module outer_body() {

    union() {

        // 下部主体
        rounded_box_xy(
            [outer_length, outer_length],
            outer_height - top_edge_r,
            outer_corner_r
        );

        // 顶部圆润过渡
        hull() {

            translate([0, 0, outer_height - top_edge_r])
                linear_extrude(height = 0.01)
                    rect(
                        [outer_length, outer_length],
                        rounding = outer_corner_r
                    );

            translate([0, 0, outer_height])
                linear_extrude(height = 0.01)
                    rect(
                        [
                            outer_length - top_edge_r * 2,
                            outer_length - top_edge_r * 2
                        ],
                        rounding = outer_corner_r - top_edge_r
                    );
        }
    }
}


difference() {

    outer_body();

    // 内部净空间
    translate([0, 0, bottom_thickness])
        rounded_box_xy(
            [inner_length, inner_length],
            inner_height + 1,
            inner_corner_r
        );
}