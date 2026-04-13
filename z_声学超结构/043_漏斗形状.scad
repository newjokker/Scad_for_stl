include <BOSL2/std.scad>

$fn = 200;

// ================= 参数 =================

// ---- 上部长方形口参数 ----
top_rect_x          = 160;    // 上口长方形 X 尺寸
top_rect_y          = 60;    // 上口长方形 Y 尺寸
top_corner_radius   = 6;     // 上口圆角
top_straight_height = 10;     // 上口保留的直段高度

// ---- 过渡段参数 ----
funnel_height_upper = 5;    // 长方形到圆形的过渡高度

// ---- 下部圆颈参数 ----
neck_height         = 15;    // 颈部高度
neck_radius         = 23/2;  // 颈部外半径

// ---- 壁厚 ----
wall_thickness      = 0.8;   // 统一壁厚

// ================= 过滤板参数 =================
filter_z            = top_straight_height + funnel_height_upper; // 放在颈部起点
filter_thickness    = 1.2;
hole_radius         = 1;
hole_spacing        = hole_radius * 2.3;

// ================= 派生参数 =================
inner_neck_radius   = neck_radius - wall_thickness;
total_height        = top_straight_height + funnel_height_upper + neck_height;

inner_top_rect_x    = top_rect_x - wall_thickness * 2;
inner_top_rect_y    = top_rect_y - wall_thickness * 2;
inner_top_corner_r  = max(0.01, top_corner_radius - wall_thickness);

// ================= 安全检查 =================
assert(inner_neck_radius > 0, "inner_neck_radius <= 0，壁厚过大");
assert(inner_top_rect_x > 0, "inner_top_rect_x <= 0，壁厚过大");
assert(inner_top_rect_y > 0, "inner_top_rect_y <= 0，壁厚过大");
assert(top_corner_radius < min(top_rect_x, top_rect_y)/2, "top_corner_radius 太大");
assert(filter_z >= top_straight_height + funnel_height_upper, "filter_z 太低");
assert(filter_z + filter_thickness <= total_height, "filter_z 太高");

// ================= 2D 圆角矩形 =================
module rounded_rect_2d(x, y, r) {
    // BOSL2 的 rect 可直接做圆角矩形
    rect([x, y], rounding = r);
}

// ================= 外形模块 =================
module funnel_outer() {
    union() {
        // 1) 上部长方形直段
        linear_extrude(height = top_straight_height)
            rounded_rect_2d(top_rect_x, top_rect_y, top_corner_radius);

        // 2) 长方形 -> 圆形过渡段
        hull() {
            // 过渡段顶部：长方形
            translate([0, 0, top_straight_height])
                linear_extrude(height = 0.01)
                    rounded_rect_2d(top_rect_x, top_rect_y, top_corner_radius);

            // 过渡段底部：圆
            translate([0, 0, top_straight_height + funnel_height_upper])
                cylinder(h = 0.01, r = neck_radius);
        }

        // 3) 下部颈部
        translate([0, 0, top_straight_height + funnel_height_upper])
            cylinder(h = neck_height, r = neck_radius);
    }
}

// ================= 内腔模块 =================
module funnel_inner() {
    union() {
        // 1) 上部长方形内腔直段
        linear_extrude(height = top_straight_height + 0.02)
            rounded_rect_2d(inner_top_rect_x, inner_top_rect_y, inner_top_corner_r);

        // 2) 内部过渡腔
        hull() {
            translate([0, 0, top_straight_height])
                linear_extrude(height = 0.01)
                    rounded_rect_2d(inner_top_rect_x, inner_top_rect_y, inner_top_corner_r);

            translate([0, 0, top_straight_height + funnel_height_upper])
                cylinder(h = 0.01, r = inner_neck_radius);
        }

        // 3) 内部颈部通孔
        translate([0, 0, top_straight_height + funnel_height_upper])
            cylinder(h = neck_height + 0.02, r = inner_neck_radius);
    }
}

// ================= 过滤板打孔模块 =================
module perforated_filter_plate() {
    plate_r = inner_neck_radius;

    difference() {
        // 圆形过滤板本体
        translate([0, 0, filter_z])
            cylinder(h = filter_thickness, r = plate_r);

        // 打孔阵列
        for (x = [-plate_r : hole_spacing : plate_r]) {
            for (y = [-plate_r : hole_spacing : plate_r]) {
                if (x*x + y*y <= (plate_r - hole_radius)*(plate_r - hole_radius)) {
                    translate([x, y, filter_z - 0.01])
                        cylinder(h = filter_thickness + 0.02, r = hole_radius);
                }
            }
        }
    }
}

// ================= 漏斗壳体 =================
module funnel_shell() {
    difference() {
        funnel_outer();
        funnel_inner();
    }
}

// ================= 成品 =================
union() {
    funnel_shell();
    perforated_filter_plate();
}