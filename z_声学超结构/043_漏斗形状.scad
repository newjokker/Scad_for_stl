include <BOSL2/std.scad>

$fn = 200;

// ================= 参数 =================

// ---- 上部长方形口参数 ----
top_rect_x          = 160;    // 上口长边尺寸
top_rect_y          = 60;     // 上口短边尺寸
top_corner_radius   = 6;      // 上口圆角
top_straight_height = 10;     // 上口保留的直段高度

// ---- 过渡段参数 ----
funnel_height_upper = 5;      // 长方形到圆形的过渡高度

// ---- 下部圆颈参数 ----
neck_height         = 15;     // 颈部高度
neck_radius         = 23/2;   // 颈部外半径

// ---- 壁厚 / 底厚 ----
wall_thickness      = 1;      // 统一壁厚
bottom_thickness    = 2.5;    // 底部保留厚度（保留，但会打贯通小孔）

// ================= 过滤板参数 =================
filter_z            = top_straight_height + funnel_height_upper;
filter_thickness    = 1.2;
hole_radius         = 1.5;
hole_spacing        = hole_radius * 2.3;

// ================= 上口侧壁透气孔参数 =================
side_hole_radius      = 1.3;   // 侧壁孔半径
side_hole_spacing_xy  = 3.4;   // 边长方向孔间距
side_hole_spacing_z   = 3.4;   // 高度方向孔间距
side_hole_margin_xy   = 2.0;   // 两端预留
side_hole_margin_z    = 1.5;   // 上下预留
side_hole_depth       = wall_thickness + 1.0;

// ================= 底部打孔参数（新增） =================
bottom_hole_radius    = 1.2;                 // 底部小孔半径
bottom_hole_spacing   = bottom_hole_radius * 2.6;   // 底部小孔间距
bottom_hole_edge_gap  = 1.2;                 // 距离内壁预留，避免边缘太薄

// ================= 派生参数 =================
inner_neck_radius   = neck_radius - wall_thickness;
total_height        = top_straight_height + funnel_height_upper + neck_height;

inner_top_rect_x    = top_rect_x - wall_thickness * 2;
inner_top_rect_y    = top_rect_y - wall_thickness * 2;
inner_top_corner_r  = max(0.01, top_corner_radius - wall_thickness);

neck_base_z         = top_straight_height + funnel_height_upper;

// ================= 安全检查 =================
assert(inner_neck_radius > 0, "inner_neck_radius <= 0，壁厚过大");
assert(inner_top_rect_x > 0, "inner_top_rect_x <= 0，壁厚过大");
assert(inner_top_rect_y > 0, "inner_top_rect_y <= 0，壁厚过大");
assert(top_corner_radius < min(top_rect_x, top_rect_y)/2, "top_corner_radius 太大");
assert(filter_z >= top_straight_height + funnel_height_upper, "filter_z 太低");
assert(filter_z + filter_thickness <= total_height, "filter_z 太高");
assert(bottom_thickness >= 0, "bottom_thickness 不能小于 0");
assert(bottom_thickness < neck_height, "bottom_thickness 必须小于 neck_height");
assert(bottom_hole_radius > 0, "bottom_hole_radius 必须大于 0");
assert(bottom_hole_spacing > bottom_hole_radius * 2, "bottom_hole_spacing 太小");
assert(inner_neck_radius - bottom_hole_edge_gap - bottom_hole_radius > 0,
       "底部孔参数过大，孔会打到边缘，请减小 bottom_hole_radius 或 bottom_hole_edge_gap");

// ================= 2D 圆角矩形 =================
module rounded_rect_2d(x, y, r) {
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
            translate([0, 0, top_straight_height])
                linear_extrude(height = 0.01)
                    rounded_rect_2d(top_rect_x, top_rect_y, top_corner_radius);

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
        // 保留底厚，不整体打穿
        translate([0, 0, neck_base_z + bottom_thickness])
            cylinder(h = neck_height - bottom_thickness + 0.04, r = inner_neck_radius);
    }
}

// ================= 上口直段四侧打孔 =================
module top_side_vent_holes() {
    z_positions = [
        side_hole_margin_z : side_hole_spacing_z : top_straight_height - side_hole_margin_z
    ];

    // 前后长边：沿 X 排列
    x_positions = [
        -top_rect_x/2 + side_hole_margin_xy :
        side_hole_spacing_xy :
        top_rect_x/2 - side_hole_margin_xy
    ];

    // 左右短边：沿 Y 排列
    y_positions = [
        -top_rect_y/2 + side_hole_margin_xy :
        side_hole_spacing_xy :
        top_rect_y/2 - side_hole_margin_xy
    ];

    union() {
        // 前长边（+Y）
        for (z = z_positions)
            for (x = x_positions)
                translate([x, top_rect_y/2 + 0.01, z])
                    rotate([90, 0, 0])
                        cylinder(h = side_hole_depth, r = side_hole_radius);

        // 后长边（-Y）
        for (z = z_positions)
            for (x = x_positions)
                translate([x, -top_rect_y/2 - 0.01, z])
                    rotate([-90, 0, 0])
                        cylinder(h = side_hole_depth, r = side_hole_radius);

        // 左短边（-X）
        for (z = z_positions)
            for (y = y_positions)
                translate([-top_rect_x/2 - 0.01, y, z])
                    rotate([0, 90, 0])
                        cylinder(h = side_hole_depth, r = side_hole_radius);

        // 右短边（+X）
        for (z = z_positions)
            for (y = y_positions)
                translate([top_rect_x/2 + 0.01, y, z])
                    rotate([0, -90, 0])
                        cylinder(h = side_hole_depth, r = side_hole_radius);
    }
}

// ================= 底部贯通孔模块（新增） =================
// 作用：在保留 bottom_thickness 的情况下，把这层底板打出贯通孔
module bottom_perforation_holes() {
    usable_r = inner_neck_radius - bottom_hole_edge_gap;

    for (x = [-usable_r : bottom_hole_spacing : usable_r]) {
        for (y = [-usable_r : bottom_hole_spacing : usable_r]) {
            if (x*x + y*y <= (usable_r - bottom_hole_radius)*(usable_r - bottom_hole_radius)) {
                translate([x, y, neck_base_z - 0.02])
                    cylinder(h = bottom_thickness + 0.04, r = bottom_hole_radius);
            }
        }
    }
}

// ================= 过滤板打孔模块 =================
module perforated_filter_plate() {
    plate_r = inner_neck_radius;

    difference() {
        translate([0, 0, filter_z])
            cylinder(h = filter_thickness, r = plate_r);

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
        top_side_vent_holes();
        bottom_perforation_holes();   // 新增：把底板打穿
    }
}

// ================= 成品 =================
union() {
    funnel_shell();
    perforated_filter_plate();
}