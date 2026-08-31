// MG996R 双自由度紧凑云台（FDM 免支撑版）
// 底部电机负责水平旋转，上部电机负责俯仰。
// 所有实体都有完整平底；悬挑由 45 度斜撑承托；横孔采用水滴孔。
// 单位：mm；默认输出三件可直接切片的打印件。
// 推荐切片：0.2 mm 层高、4 道墙、5 层顶底、30~40% Gyroid、关闭支撑。
// 叉架承载较重设备时建议 PETG/ABS；PLA 适合轻载，必要时加 5 mm brim。

$fn = 72;

/* [输出] */
output_mode = "print";       // [print:打印摆放,assembly:装配预览,base:底座,yoke:旋转叉架,plate:载荷板]
show_servos = true;          // 仅在 assembly 模式显示半透明电机
show_horns = true;           // 仅在 assembly 模式显示舵盘
part_gap = 12;

/* [MG996R 实测后可微调] */
servo_body_length = 40.5;
servo_body_width = 20.2;
servo_body_height = 37.0;
servo_flange_length = 54.5;
servo_flange_thickness = 2.6;
servo_flange_from_top = 7.5;
servo_mount_spacing = 49.5;
servo_mount_hole = 3.2;
servo_shaft_offset = 10.2;
servo_spline_height = 4.5;
fit_clearance = 0.45;

/* [打印与紧固] */
nozzle_diameter = 0.4;       // 按 0.4 mm 喷嘴设计
layer_height = 0.2;          // 建议层高，仅作记录
wall = 3.2;                  // 8 道喷嘴线宽，适合承力件
plate_thickness = 4;         // 10 层以上实体厚度
m3_clearance = 3.4;
m4_clearance = 4.4;
horn_center_hole = 3.2;
horn_screw_circle = 14;
horn_screw_hole = 2.2;

/* [底座] */
base_length = 66;
base_width = 46;
base_corner_radius = 6;
base_hole_spacing_x = 54;
base_hole_spacing_y = 34;
base_slot_length = 8;
base_socket_height = 33;     // 顶面托住 MG996R 安装耳下表面

/* [旋转叉架] */
pan_deck_length = 64;
pan_deck_width = 48;
pan_deck_radius = 6;
yoke_inside_width = servo_body_height + 2 * fit_clearance;
yoke_side_thickness = 4;
yoke_side_height = 43;
yoke_side_length = 56;
tilt_axis_height = 27;

/* [载荷板] */
payload_length = 58;
payload_height = 42;
payload_corner_radius = 5;
payload_hole_spacing_x = 44;
payload_hole_spacing_z = 28;

eps = 0.1;
shaft_x = -servo_body_length / 2 + servo_shaft_offset;
flange_z = servo_body_height - servo_flange_from_top;

assert(wall >= 2.4, "wall 建议不小于 2.4 mm");
assert(yoke_inside_width >= servo_body_height,
       "叉架内部宽度小于横装电机高度");

module rounded_rect_2d(sx, sy, r) {
    rr = min(r, min(sx, sy) / 2);
    hull()
        for (x = [-sx / 2 + rr, sx / 2 - rr])
            for (y = [-sy / 2 + rr, sy / 2 - rr])
                translate([x, y]) circle(r = rr);
}

module rounded_plate(sx, sy, h, r) {
    linear_extrude(h) rounded_rect_2d(sx, sy, r);
}

module x_slot(length, diameter, height) {
    hull()
        for (x = [-(length - diameter) / 2,
                   (length - diameter) / 2])
            translate([x, 0, 0]) cylinder(h = height, d = diameter);
}

// 沿 Y 轴贯穿的免支撑水滴孔。
// 圆孔顶部改成两个 45 度斜面，横向打印时不会产生圆弧悬空。
module y_teardrop_hole(diameter, length) {
    radius = diameter / 2;
    translate([0, -eps, 0])
        rotate([-90, 0, 0])
            linear_extrude(length + 2 * eps)
                union() {
                    circle(d = diameter);
                    // 旋转后局部 -Y 对应模型 +Z，即孔的尖顶。
                    polygon([[-radius, 0],
                             [ radius, 0],
                             [0, -radius * 2]]);
                }
}

// 圆头斜肋：用两个横向圆柱做 hull，端部会柔和地融入相邻实体。
module rounded_diagonal_rib(x1, z1, x2, z2, y, depth, diameter) {
    hull()
        for (point = [[x1, z1], [x2, z2]])
            translate([point[0], y, point[1]])
                rotate([90, 0, 0])
                    cylinder(h = depth, d = diameter, center = true);
}

module horn_holes(height) {
    translate([0, 0, -eps]) cylinder(h = height + 2 * eps,
                                     d = horn_center_hole);
    for (a = [0 : 90 : 270])
        rotate([0, 0, a])
            translate([horn_screw_circle / 2, 0, -eps])
                cylinder(h = height + 2 * eps, d = horn_screw_hole);
}

module base_mount() {
    cavity_x = servo_body_length + 2 * fit_clearance;
    cavity_y = servo_body_width + 2 * fit_clearance;
    socket_x = cavity_x + 2 * wall;
    socket_y = cavity_y + 2 * wall;

    difference() {
        union() {
            rounded_plate(base_length, base_width, plate_thickness,
                          base_corner_radius);

            translate([0, 0, plate_thickness])
                difference() {
                    rounded_plate(socket_x, socket_y, base_socket_height, 3);
                    translate([-cavity_x / 2, -cavity_y / 2, wall])
                        cube([cavity_x, cavity_y,
                              base_socket_height + eps]);
                }

            for (x = [-servo_mount_spacing / 2,
                       servo_mount_spacing / 2])
                translate([x, 0, plate_thickness + base_socket_height - 3])
                    rounded_plate(9, socket_y, 3, 2);

            // 安装耳下方使用三条圆头斜肋：比整片三角撑轻巧，
            // 同时让连接处自然融入圆角外壳。
            for (side = [-1, 1])
                for (rib_y = [-socket_y / 2 + 3.2, 0,
                               socket_y / 2 - 3.2])
                    rounded_diagonal_rib(
                        side * (socket_x / 2 - 1.2),
                        plate_thickness + base_socket_height - 9,
                        side * (servo_mount_spacing / 2 + 2.0),
                        plate_thickness + base_socket_height - 3.4,
                        rib_y, 3.2, 4.2);
        }

        for (x = [-1, 1])
            translate([x * (socket_x / 2), 0,
                       plate_thickness + base_socket_height * 0.58])
                cube([wall * 2 + 1, cavity_y - 5,
                      base_socket_height * 0.62], center = true);

        for (x = [-servo_mount_spacing / 2,
                   servo_mount_spacing / 2])
            translate([x, 0, plate_thickness + base_socket_height - 3 - eps])
                cylinder(h = 3 + 2 * eps, d = servo_mount_hole);

        for (x = [-base_hole_spacing_x / 2, base_hole_spacing_x / 2])
            for (y = [-base_hole_spacing_y / 2, base_hole_spacing_y / 2])
                translate([x, y, -eps])
                    x_slot(base_slot_length, m3_clearance,
                           plate_thickness + 2 * eps);
    }
}

module pan_yoke() {
    outer_width = yoke_inside_width + 2 * yoke_side_thickness;

    difference() {
        union() {
            rounded_plate(pan_deck_length, pan_deck_width,
                          plate_thickness, pan_deck_radius);

            for (y = [-outer_width / 2 + yoke_side_thickness / 2,
                       outer_width / 2 - yoke_side_thickness / 2])
                translate([0, y, plate_thickness + yoke_side_height / 2])
                    cube([yoke_side_length, yoke_side_thickness,
                          yoke_side_height], center = true);

            for (y = [-outer_width / 2, outer_width / 2])
                for (x = [-yoke_side_length / 2 + 7,
                           yoke_side_length / 2 - 7])
                    hull() {
                        translate([x, y, plate_thickness + 0.5])
                            cube([8, yoke_side_thickness, 1], center = true);
                        translate([x, y, plate_thickness + 11])
                            cube([3, yoke_side_thickness, 1], center = true);
                    }
        }

        horn_holes(plate_thickness);

        translate([shaft_x, -outer_width / 2 - eps,
                   plate_thickness + tilt_axis_height])
            y_teardrop_hole(horn_center_hole,
                            yoke_side_thickness + 2 * eps);
        for (a = [0 : 90 : 270])
            translate([shaft_x + cos(a) * horn_screw_circle / 2,
                       -outer_width / 2 - eps,
                       plate_thickness + tilt_axis_height
                           + sin(a) * horn_screw_circle / 2])
                y_teardrop_hole(horn_screw_hole,
                                yoke_side_thickness + 2 * eps);

        translate([shaft_x, outer_width / 2 - yoke_side_thickness - eps,
                   plate_thickness + tilt_axis_height])
            y_teardrop_hole(m4_clearance,
                            yoke_side_thickness + 2 * eps);

        for (x = [-servo_mount_spacing / 2, servo_mount_spacing / 2])
            for (y = [-outer_width / 2 - eps,
                       outer_width / 2 - yoke_side_thickness - eps])
                translate([x, y,
                           plate_thickness + tilt_axis_height - shaft_x])
                    y_teardrop_hole(servo_mount_hole,
                                    yoke_side_thickness + 2 * eps);
    }
}

module payload_plate() {
    difference() {
        rounded_plate(payload_length, payload_height, plate_thickness,
                      payload_corner_radius);
        horn_holes(plate_thickness);

        for (x = [-payload_hole_spacing_x / 2,
                   payload_hole_spacing_x / 2])
            for (y = [-payload_hole_spacing_z / 2,
                       payload_hole_spacing_z / 2])
                translate([x, y, -eps])
                    x_slot(8, m3_clearance, plate_thickness + 2 * eps);
    }
}

module servo_preview() {
    color([0.12, 0.18, 0.22, 0.55])
        cube([servo_body_length, servo_body_width,
              servo_body_height]);
    color([0.18, 0.22, 0.27, 0.6])
        translate([-(servo_flange_length - servo_body_length) / 2,
                   0, flange_z])
            cube([servo_flange_length, servo_body_width,
                  servo_flange_thickness]);
    color([0.75, 0.75, 0.78, 0.8])
        translate([shaft_x + servo_body_length / 2,
                   servo_body_width / 2,
                   servo_body_height])
            cylinder(h = servo_spline_height, d = 6);
}

module horn_preview() {
    color([0.92, 0.92, 0.88, 0.7]) cylinder(h = 2.2, d = 22);
}

module assembly() {
    base_mount();
    base_servo_z = plate_thickness + wall;
    if (show_servos)
        %translate([-servo_body_length / 2, -servo_body_width / 2,
                    base_servo_z]) servo_preview();

    pan_z = base_servo_z + servo_body_height + servo_spline_height + 2.2;
    translate([shaft_x, 0, pan_z]) pan_yoke();
    if (show_horns)
        %translate([shaft_x, 0, pan_z - 2.2]) horn_preview();

    tilt_origin = [shaft_x - servo_body_length / 2,
                   yoke_inside_width / 2,
                   pan_z + plate_thickness + tilt_axis_height];
    if (show_servos)
        %translate(tilt_origin)
            rotate([90, 0, 0]) servo_preview();

    tilt_axis_x = 2 * shaft_x;
    plate_y = -yoke_inside_width / 2 - yoke_side_thickness - 2.2;
    translate([tilt_axis_x, plate_y,
               pan_z + plate_thickness + tilt_axis_height])
        rotate([90, 0, 0]) payload_plate();
    if (show_horns)
        %translate([tilt_axis_x, plate_y + 2.2,
                    pan_z + plate_thickness + tilt_axis_height])
            rotate([90, 0, 0]) horn_preview();
}

module print_layout() {
    base_mount();

    // 底板贴热床，两侧板竖直生长，无大跨度悬空。
    translate([(base_length + pan_deck_length) / 2 + part_gap, 0, 0])
        pan_yoke();

    translate([0, -(base_width + payload_height) / 2 - part_gap, 0])
        payload_plate();
}

if (output_mode == "assembly")
    assembly();
else if (output_mode == "base")
    base_mount();
else if (output_mode == "yoke")
    pan_yoke();
else if (output_mode == "plate")
    payload_plate();
else
    print_layout();
