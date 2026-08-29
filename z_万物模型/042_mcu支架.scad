// MCU 高架：两孔窄底座 + 单工字梁立柱 + 可拆安装平台
// 单位：mm。为 FDM 3D 打印优化：默认拆成两件平放，无需打印支撑。

$fn = 64;

/* [MCU 平台] */
platform_length = 45;       // 平台 X 方向长度
platform_width = 23;        // 平台 Y 方向宽度
platform_thickness = 3;     // 平台厚度
platform_corner_radius = 4;

// MCU 四个安装位的中心距。
mcu_hole_spacing_x = 35;
mcu_hole_spacing_y = 15;
mcu_screw_diameter = 3.2;   // M3 通孔留量
mcu_slot_length = 8;        // 长孔可兼容不同 MCU 孔距

// 平台用 4 颗 M3x8 沉头螺丝固定到中央立柱顶部。
attach_hole_spacing_x = 12;
attach_hole_spacing_y = 6;
attach_screw_diameter = 3.4;
attach_head_diameter = 6.4;
attach_head_depth = 1.8;

/* [高度与支撑] */
clear_height = 80;          // 底座上表面到平台下表面
beam_flange_width = 20;     // 单立柱翼缘宽度（X）
beam_depth = 11;            // 单立柱总深度（Y）
beam_wall = 3;              // 工字梁翼缘/腹板厚度
gusset_length = 3;          // 加强筋与左右安装孔保持间隙
gusset_height = 10;         // 加强筋沿立柱向上的高度
column_cap_height = 6;      // 顶部实心螺丝座高度
pilot_hole_diameter = 2.6;  // M3 自攻孔；材料收缩大时可调到 2.7
pilot_hole_depth = 5.2;

/* [底座与底板孔] */
base_length = 50;
base_width = 25;
base_thickness = 3;
base_corner_radius = 5;
base_hole_spacing_x = 38;   // 左右两孔中心距
base_screw_diameter = 3.4;  // M3 安装孔
base_slot_length = 9;       // 沿 X 方向的调节量

/* [预览] */
output_mode = "print";      // [print:免支撑打印摆放, assembly:装配预览]
part_spacing = 10;
show_mcu_preview = false;
preview_mcu_thickness = 1.6;

module rounded_plate(size_x, size_y, height, radius) {
    safe_r = min(radius, min(size_x, size_y) / 2);
    linear_extrude(height)
        hull()
            for (x = [-size_x / 2 + safe_r, size_x / 2 - safe_r])
                for (y = [-size_y / 2 + safe_r, size_y / 2 - safe_r])
                    translate([x, y]) circle(r = safe_r);
}

// 两端半圆的 X 向长孔。
module x_slot(length, diameter, height) {
    hull()
        for (x = [-(length - diameter) / 2, (length - diameter) / 2])
            translate([x, 0, 0])
                cylinder(h = height, d = diameter);
}

module mounting_base() {
    difference() {
        rounded_plate(base_length, base_width, base_thickness,
                      base_corner_radius);

        for (x = [-base_hole_spacing_x / 2, base_hole_spacing_x / 2])
            translate([x, 0, -0.1])
                x_slot(base_slot_length, base_screw_diameter,
                       base_thickness + 0.2);
    }
}

// 沿 Z 方向拉伸的工字梁：两侧翼缘 + 中间腹板。
module i_beam_column(height) {
    union() {
        for (y = [-(beam_depth - beam_wall) / 2,
                   (beam_depth - beam_wall) / 2])
            translate([0, y, height / 2])
                cube([beam_flange_width, beam_wall, height], center = true);

        translate([0, 0, height / 2])
            cube([beam_wall, beam_depth, height], center = true);
    }
}

// 工字梁顶部增加实心块，预留 M3 自攻孔。
// 孔不贯穿顶块，打印时不会在孔内产生悬空封顶。
module printable_column() {
    column_body_height = clear_height - column_cap_height;

    difference() {
        union() {
            i_beam_column(column_body_height);
            translate([0, 0, column_body_height])
                linear_extrude(column_cap_height)
                    square([beam_flange_width, beam_depth], center = true);
        }

        for (x = [-attach_hole_spacing_x / 2,
                   attach_hole_spacing_x / 2])
            for (y = [-attach_hole_spacing_y / 2,
                       attach_hole_spacing_y / 2])
                translate([x, y,
                           clear_height - pilot_hole_depth])
                    cylinder(h = pilot_hole_depth + 0.1,
                             d = pilot_hole_diameter);
    }
}

// 加强筋只沿 X 方向展开，Y 向不超出立柱，
// 因此整个下部结构会严格保持在 15 mm 底座宽度内。
module column_gussets() {
    for (x_sign = [-1, 1])
        hull() {
            translate([x_sign * beam_wall / 2, 0, 0.4])
                cube([beam_wall, beam_wall, 0.8], center = true);
            translate([x_sign * (beam_flange_width / 2 + gusset_length / 2),
                       0, 0.4])
                cube([gusset_length, beam_wall, 0.8], center = true);
            translate([x_sign * beam_wall / 2, 0, gusset_height])
                cube([beam_wall, beam_wall, 0.8], center = true);
        }
}

module mcu_platform() {
    difference() {
        rounded_plate(platform_length, platform_width, platform_thickness,
                      platform_corner_radius);

        for (x = [-mcu_hole_spacing_x / 2, mcu_hole_spacing_x / 2])
            for (y = [-mcu_hole_spacing_y / 2, mcu_hole_spacing_y / 2])
                translate([x, y, -0.1])
                    x_slot(mcu_slot_length, mcu_screw_diameter,
                           platform_thickness + 0.2);

        // 固定平台的四个沉头孔，螺丝头不会顶住 MCU。
        for (x = [-attach_hole_spacing_x / 2,
                   attach_hole_spacing_x / 2])
            for (y = [-attach_hole_spacing_y / 2,
                       attach_hole_spacing_y / 2]) {
                translate([x, y, -0.1])
                    cylinder(h = platform_thickness + 0.2,
                             d = attach_screw_diameter);
                translate([x, y, platform_thickness - attach_head_depth])
                    cylinder(h = attach_head_depth + 0.1,
                             d1 = attach_screw_diameter,
                             d2 = attach_head_diameter);
            }
    }
}

module support_stand() {
    union() {
        mounting_base();

        translate([0, 0, base_thickness]) {
            printable_column();
            column_gussets();
        }
    }
}

module assembled_bracket() {
    support_stand();
    translate([0, 0, base_thickness + clear_height])
        mcu_platform();
}

if (output_mode == "assembly") {
    assembled_bracket();
} else {
    // 两件都以最大平面接触热床，无需支撑。
    support_stand();
    translate([(base_length + platform_length) / 2 + part_spacing, 0, 0])
        mcu_platform();
}

// 半透明绿色块只用于确认 MCU 尺寸，不会成为支架几何的一部分。
if (show_mcu_preview && output_mode == "assembly")
    %color([0.1, 0.55, 0.2, 0.55])
        translate([0, 0,
                   base_thickness + clear_height + platform_thickness + 2])
            cube([platform_length - 8, platform_width - 8,
                  preview_mcu_thickness], center = true);
