include <BOSL2/std.scad>

$fn = 200;

// ================= 参数 =================
funnel_height_upper = 10;    // 漏斗锥形段高度
neck_height         = 15;   // 颈部高度
top_radius          = 50;   // 顶部外半径
neck_radius         = 23/2;    // 颈部外半径
wall_thickness      = 0.8;    // 统一壁厚

// ================= 过滤板参数 =================
filter_z            = funnel_height_upper ;   // 过滤板所在高度（位于颈部内部）
filter_thickness    = 1.2;                       // 过滤板厚度
hole_radius         = 1;                       // 小孔半径
hole_spacing        = hole_radius * 2.3;                       // 小孔中心间距

// ================= 派生参数 =================
inner_top_radius    = top_radius  - wall_thickness;
inner_neck_radius   = neck_radius - wall_thickness;
total_height        = funnel_height_upper + neck_height;

// ================= 安全检查 =================
assert(inner_top_radius > 0, "inner_top_radius <= 0，壁厚过大");
assert(inner_neck_radius > 0, "inner_neck_radius <= 0，壁厚过大");
assert(filter_z >= funnel_height_upper, "filter_z 太低，已经跑到漏斗段里了");
assert(filter_z + filter_thickness <= total_height, "filter_z 太高，过滤板超出颈部了");

// ================= 外形模块 =================
module funnel_outer() {
    union() {
        // 上部漏斗
        cylinder(
            h  = funnel_height_upper,
            r1 = top_radius,
            r2 = neck_radius
        );

        // 下部颈部
        translate([0, 0, funnel_height_upper])
            cylinder(
                h = neck_height,
                r = neck_radius
            );
    }
}

// ================= 内腔模块 =================
module funnel_inner() {
    union() {
        // 内部漏斗腔
        cylinder(
            h  = funnel_height_upper,
            r1 = inner_top_radius,
            r2 = inner_neck_radius
        );

        // 内部颈部通孔
        translate([0, 0, funnel_height_upper])
            cylinder(
                h = neck_height + 0.02,
                r = inner_neck_radius
            );
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
                // 只在圆板范围内打孔
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