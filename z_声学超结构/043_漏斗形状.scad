include <BOSL2/std.scad>

$fn = 200;

// ================= 参数 =================
funnel_height_upper = 5;   // 漏斗锥形段高度
neck_height         = 15;   // 颈部高度
top_radius          = 30;   // 顶部外半径
neck_radius         = 4;    // 颈部外半径
wall_thickness      = 1;    // 统一壁厚

// ================= 派生参数 =================
inner_top_radius  = top_radius  - wall_thickness;
inner_neck_radius = neck_radius - wall_thickness;
total_height      = funnel_height_upper + neck_height;

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
                h = neck_height + 0.02,   // 略微加长，避免布尔运算接缝
                r = inner_neck_radius
            );
    }
}

// ================= 成品 =================
difference() {
    funnel_outer();

    // 不要上移 wall_thickness，否则顶部会封死
    funnel_inner();
}