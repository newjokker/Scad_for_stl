$fn = 48;

// ========== 显示模式 ==========
show_part = "upper";      // "assembly" 装配预览；"lower" 下托；"upper" 上盖

// ========== 180 振动电机尺寸 ==========
motor_length = 32;           // 电机机身长度
motor_width = 20;            // 电机机身宽度
motor_height = 15.2;         // 电机机身高度
shaft_diameter = 3;          // 轴径
front_expose_length = 22;    // 装配预览中偏心轮/轴露出的长度
eccentric_diameter = 15;     // 偏心轮预览直径，不参与打印件
eccentric_thickness = 7;     // 偏心轮预览厚度，不参与打印件
back_wire_length = 10;       // 后端接线开口长度

// ========== 打印和装配参数 ==========
fit_clearance = 0.7;         // 电机装配间隙，打印偏紧就加大
wall = 3;                    // 盒子侧壁厚度
floor_thickness = 3;         // 下托底厚
cover_thickness = 3;         // 上盖顶厚
end_lip = 2;                 // 前后端包住机身的边，前端仍露出偏心轮
split_gap = 0.25;            // 上下盖合缝预留

// 螺丝参数
screw_diameter = 3.2;        // 上盖 M3 通孔
screw_pilot_diameter = 2.6;  // 下托 M3 自攻/热熔铜螺母预孔
screw_head_diameter = 6.4;   // M3 圆柱头/杯头沉孔
screw_head_depth = 2.2;      // 上盖沉孔深度
screw_boss_diameter = 7.5;   // 螺丝柱/耳朵直径
screw_x_spacing = 24;        // 前后两排螺丝间距，压在机身两端附近
screw_y_spacing = 31;        // 左右两列螺丝间距，位于机身两侧

// ========== 派生尺寸 ==========
cavity_length = motor_length + fit_clearance * 2;
cavity_width = motor_width + fit_clearance * 2;
cavity_height = motor_height + fit_clearance * 2;

body_length = motor_length + end_lip * 2;
box_length = body_length + wall * 2;
box_width = max(cavity_width + wall * 2, screw_y_spacing + screw_boss_diameter + 4);
half_cavity_height = cavity_height / 2 + split_gap / 2;
lower_height = floor_thickness + half_cavity_height;
upper_height = cover_thickness + half_cavity_height;

cavity_center_z_lower = floor_thickness + cavity_height / 2;
cavity_center_z_upper = 0;
front_face_x = motor_length / 2 + end_lip + wall;
back_face_x = -motor_length / 2 - end_lip - wall;

// ========== 基础模块 ==========
module screw_positions() {
    for (x = [-screw_x_spacing / 2, screw_x_spacing / 2])
        for (y = [-screw_y_spacing / 2, screw_y_spacing / 2])
            translate([x, y, 0])
                children();
}

module motor_body_channel(center_z) {
    translate([0, 0, center_z])
        cube([cavity_length, cavity_width, cavity_height], center = true);
}

module front_shaft_relief(center_z) {
    translate([motor_length / 2 + end_lip / 2 + wall / 2, 0, center_z])
        rotate([0, 90, 0])
            cylinder(d = shaft_diameter + fit_clearance * 2, h = end_lip + wall + 0.4, center = true);
}

module front_open_cut(center_z) {
    translate([front_face_x + 0.5, 0, center_z])
        cube([wall + 1.2, cavity_width * 0.8, cavity_height * 0.85], center = true);
}

module back_wire_cut(center_z) {
    translate([back_face_x - 0.5, 0, center_z])
        cube([back_wire_length + 1, cavity_width * 0.55, cavity_height * 0.55], center = true);
}

module motor_reliefs(center_z) {
    motor_body_channel(center_z);
    front_shaft_relief(center_z);
    front_open_cut(center_z);
    back_wire_cut(center_z);
}

module clamp_body(height) {
    union() {
        translate([0, 0, height / 2])
            cube([box_length, cavity_width + wall * 2, height], center = true);

        screw_positions()
            cylinder(d = screw_boss_diameter, h = height);
    }
}

module lower_case() {
    difference() {
        clamp_body(lower_height);

        motor_reliefs(cavity_center_z_lower);

        screw_positions()
            translate([0, 0, -0.1])
                cylinder(d = screw_pilot_diameter, h = lower_height + 0.2);
    }
}

module upper_case() {
    difference() {
        clamp_body(upper_height);

        motor_reliefs(cavity_center_z_upper);

        screw_positions()
            translate([0, 0, -0.1])
                cylinder(d = screw_diameter, h = upper_height + 0.2);

        screw_positions()
            translate([0, 0, upper_height - screw_head_depth])
                cylinder(d = screw_head_diameter, h = screw_head_depth + 0.2);
    }
}

module motor_preview() {
    color("silver")
        translate([0, 0, lower_height])
            cube([motor_length, motor_width, motor_height], center = true);

    color("gray")
        translate([motor_length / 2 + front_expose_length / 2, 0, lower_height])
            rotate([0, 90, 0])
                cylinder(d = shaft_diameter, h = front_expose_length, center = true);

    color("gold")
        translate([motor_length / 2 + front_expose_length - eccentric_thickness / 2, 0, lower_height + 1.5])
            rotate([0, 90, 0])
                cylinder(d = eccentric_diameter, h = eccentric_thickness, center = true);
}

module motor_box() {
    if (show_part == "lower") {
        lower_case();
    } else if (show_part == "upper") {
        upper_case();
    } else {
        lower_case();
        motor_preview();

        translate([0, 0, lower_height + upper_height + 4])
            rotate([180, 0, 0])
            upper_case();
    }
}

motor_box();
