include <BOSL2/std.scad>

$fn = 200;

// --------------------- 输出选择 ---------------------

// 可选：
// "assembly"      装配预览
// "bottom_plate"  只显示下板
// "top_plate"     只显示上板
// "support_posts" 只显示支撑柱
// "print_layout"  分开摆放，方便整体检查
output_part = "assembly";


// --------------------- 原始尺寸参数 ---------------------

bottom_inner_radius = 91 - 60;        // 下圆环内半径，保持原设计
bottom_ring_width = 22 * 2 + 7 + 60;  // 下圆环径向宽度，保持原设计
bottom_height = 30;                   // 下圆环高度，保持原设计
bottom_z = 14;                        // 装配预览时下圆环底面高度，保持原设计

top_radius = 61 + 22 * 2 + 7;         // 上板外半径，保持原设计
top_height = 10;                      // 上板高度，保持原设计
top_inner_radius = 0;                 // 原代码是实心圆柱；需要圆环时把这里改成内半径


// --------------------- 板间距和支撑参数 ---------------------

plate_gap = 3;                       // 上下板之间的净高度，改这里即可调节间距

support_count = 5;                    // 支撑小圆柱数量
support_diameter = 8;                 // 支撑柱主体直径
support_radius = 86;                  // 支撑柱中心分布半径
support_start_angle = 0;              // 整圈支撑的起始角度

post_pin_diameter = 6;                // 支撑柱两端插入安装孔的定位柱直径
post_pin_height = 5;                  // 支撑柱每端插入安装孔的长度
mount_hole_clearance = 0.3;           // 安装孔和定位柱之间的装配间隙
mount_hole_depth = post_pin_height + 0.4; // 安装孔深度，略大于定位柱长度


// --------------------- 派生参数 ---------------------

bottom_outer_radius = bottom_inner_radius + bottom_ring_width;
top_bottom_z = bottom_z + bottom_height + plate_gap;
top_center_z = top_bottom_z + top_height / 2;
mount_hole_diameter = post_pin_diameter + mount_hole_clearance;


// --------------------- 基础模块 ---------------------

module annular_ring(inner_r, outer_r, h) {
    difference() {
        cylinder(r = outer_r, h = h);
        translate([0, 0, -0.05])
            cylinder(r = inner_r, h = h + 0.1);
    }
}

module disk_or_ring(outer_r, inner_r, h) {
    if (inner_r > 0)
        annular_ring(inner_r, outer_r, h);
    else
        cylinder(r = outer_r, h = h);
}

module mounting_holes(z, h) {
    for (i = [0 : support_count - 1])
        rotate([0, 0, support_start_angle + 360 / support_count * i])
            translate([support_radius, 0, z])
                cylinder(d = mount_hole_diameter, h = h);
}

module bottom_plate() {
    difference() {
        annular_ring(bottom_inner_radius, bottom_outer_radius, bottom_height);

        // 从下板顶面向下开定位孔。
        mounting_holes(
            z = bottom_height - mount_hole_depth,
            h = mount_hole_depth + 0.05
        );
    }
}

module top_plate() {
    difference() {
        disk_or_ring(top_radius, top_inner_radius, top_height);

        // 从上板底面向上开定位孔。
        mounting_holes(
            z = -0.05,
            h = mount_hole_depth + 0.05
        );
    }
}

module support_post() {
    rotate_extrude()
        polygon([
            [0, 0],
            [post_pin_diameter / 2, 0],
            [post_pin_diameter / 2, post_pin_height],
            [support_diameter / 2, post_pin_height],
            [support_diameter / 2, post_pin_height + plate_gap],
            [post_pin_diameter / 2, post_pin_height + plate_gap],
            [post_pin_diameter / 2, post_pin_height * 2 + plate_gap],
            [0, post_pin_height * 2 + plate_gap]
        ]);
}

module support_posts() {
    for (i = [0 : support_count - 1])
        rotate([0, 0, support_start_angle + 360 / support_count * i])
            translate([support_radius, 0, 0])
                support_post();
}


// --------------------- 组合模块 ---------------------

module assembly() {
    translate([0, 0, bottom_z])
        bottom_plate();

    translate([0, 0, bottom_z + bottom_height - post_pin_height])
        support_posts();

    translate([0, 0, top_bottom_z])
        top_plate();
}

module print_layout() {
    bottom_plate();

    translate([bottom_outer_radius + top_radius + 30, 0, 0])
        top_plate();

    translate([0, bottom_outer_radius + support_diameter + 30, 0])
        support_posts();
}


// --------------------- 最终模型 ---------------------

if (output_part == "bottom_plate")
    bottom_plate();
else if (output_part == "top_plate")
    top_plate();
else if (output_part == "support_posts")
    support_posts();
else if (output_part == "print_layout")
    print_layout();
else
    assembly();
