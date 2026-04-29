$fn = 96;

// ========== 参数配置区 ==========
// 圆盘本体
disk_diameter = 150;         // 圆盘直径
disk_height = 4;             // 圆盘厚度

// 圆盘背面的支撑圆柱
post_count = 6;              // 圆柱数量
post_diameter = 6.8;          // 圆柱直径
post_height = 20;            // 圆柱高度，向圆盘背面伸出
post_edge_gap = 10;          // 圆柱外壁到圆盘边缘的最短距离

// 圆柱与圆盘背面的过渡加强
post_blend_enable = true;    // 是否开启缓慢过渡
blend_diameter = 20;         // 过渡底座最大直径
blend_height = 6;            // 过渡高度
blend_neck_diameter = 14;    // 过渡靠近柱子一端的直径

// 圆盘正面的凸起同心防滑圆
friction_ring_enable = true;
ring_count = 5;              // 同心圆数量
ring_width = 2.2;            // 每个凸起圆环的宽度
ring_height = 1.2;           // 凸起高度
ring_spacing = 10;            // 圆环之间的间距
ring_start_radius = 12;      // 最内侧圆环的内半径

// 底座
show_part = "assembly";      // "assembly" 装配预览；"top" 只显示上盘；"base" 只显示底座
base_diameter = 180;         // 底座直径，建议比上盘略大
base_height = 8;             // 底座厚度，厚一些更稳
base_gap = 34;               // 上盘圆柱底部到底座上表面的距离

// 底座上的 6 个对应下柱，与上盘圆柱数量和位置一致
base_post_enable = true;
base_post_diameter = post_diameter;
base_post_height = 15;        // 下柱高度，需小于 base_gap，给弹簧留压缩空间
base_post_blend_diameter = 18;
base_post_blend_height = 4;

// 底座上的弹簧定位座，弹簧套在上下两组柱子之间
spring_outer_diameter = 18;  // 弹簧座外径，略大于弹簧外径
spring_seat_height = 3;      // 弹簧座凸台高度

// 中心限位，防止上盘振动时横向跑偏；实际装配时要留活动间隙
center_limiter_enable = false;
center_limiter_diameter = 14;
center_limiter_engage_depth = 8;    // 限位柱伸入上盘套筒的深度

// 上盘背面的限位套筒，与底座中心限位柱配合
limit_sleeve_enable = false;
limit_sleeve_clearance = 2;      // 套筒内径比限位柱大多少，留给振动的活动间隙
limit_sleeve_wall = 3;           // 套筒壁厚
limit_sleeve_height = 12;        // 套筒向下伸出的高度，需短于上下盘间距
limit_sleeve_blend_diameter = 30;
limit_sleeve_blend_height = 4;

// 上盘背面的电机支架，用扎带固定小振动电机
motor_mount_enable = true;
motor_mount_angle = 30;          // 电机支架所在角度，默认放在两个弹簧柱之间
motor_mount_radius = 35;         // 电机支架中心到圆心距离
motor_mount_length = 38;         // 电机支架长度
motor_mount_width = 24;          // 电机支架宽度
motor_mount_thickness = 3;       // 电机支架底板厚度
motor_side_wall_height = 7;      // 两侧挡边高度
motor_side_wall_thickness = 2.4; // 两侧挡边厚度
motor_zip_slot_width = 3.2;      // 扎带槽宽度
motor_zip_slot_spacing = 22;     // 两条扎带槽中心距

// 底座固定孔和脚垫
mount_hole_count = 4;
mount_hole_diameter = 4.2;   // M4 螺丝孔可用 4.2 左右
mount_hole_radius = 68;
foot_count = 4;
foot_diameter = 22;
foot_height = 3;
foot_radius = 62;

// ========== 派生尺寸 ==========
disk_radius = disk_diameter / 2;
post_radius = post_diameter / 2;
post_center_radius = disk_radius - post_edge_gap - post_radius;
base_z = -post_height - base_gap - base_height;
limit_sleeve_inner_diameter = center_limiter_diameter + limit_sleeve_clearance;
limit_sleeve_outer_diameter = limit_sleeve_inner_diameter + limit_sleeve_wall * 2;
center_limiter_height = post_height + base_gap - limit_sleeve_height + center_limiter_engage_depth;

// ========== 基础模块 ==========
module annular_ring(inner_radius, width, height) {
    difference() {
        cylinder(r = inner_radius + width, h = height);
        translate([0, 0, -0.05])
            cylinder(r = inner_radius, h = height + 0.1);
    }
}

module friction_rings() {
    if (friction_ring_enable) {
        for (i = [0 : ring_count - 1]) {
            inner_radius = ring_start_radius + i * (ring_width + ring_spacing);

            if (inner_radius + ring_width <= disk_radius)
                translate([0, 0, disk_height])
                    annular_ring(inner_radius, ring_width, ring_height);
        }
    }
}

module support_post(angle) {
    rotate([0, 0, angle])
        translate([post_center_radius, 0, -post_height])
            cylinder(d = post_diameter, h = post_height);
}

module smooth_post_blend(angle) {
    rotate([0, 0, angle])
        translate([post_center_radius, 0, -blend_height]) {
            hull() {
                cylinder(d = blend_neck_diameter, h = 0.4);

                translate([0, 0, blend_height - 0.4])
                    cylinder(d = blend_diameter, h = 0.4);
            }
        }
}

module limit_sleeve() {
    if (limit_sleeve_enable && center_limiter_enable) {
        difference() {
            union() {
                translate([0, 0, -limit_sleeve_height])
                    cylinder(d = limit_sleeve_outer_diameter, h = limit_sleeve_height);

                translate([0, 0, -limit_sleeve_blend_height]) {
                    hull() {
                        cylinder(d = limit_sleeve_blend_diameter, h = 0.4);

                        translate([0, 0, limit_sleeve_blend_height - 0.4])
                            cylinder(d = limit_sleeve_outer_diameter, h = 0.4);
                    }
                }
            }

            translate([0, 0, -limit_sleeve_height - 0.05])
                cylinder(d = limit_sleeve_inner_diameter, h = limit_sleeve_height + 0.1);
        }
    }
}

module motor_mount() {
    if (motor_mount_enable) {
        rotate([0, 0, motor_mount_angle])
            translate([motor_mount_radius, 0, 0]) {
                difference() {
                    union() {
                        translate([0, 0, -motor_mount_thickness / 2])
                            cube(
                                [motor_mount_length, motor_mount_width, motor_mount_thickness],
                                center = true
                            );

                        translate([
                            0,
                            motor_mount_width / 2 - motor_side_wall_thickness / 2,
                            -motor_mount_thickness - motor_side_wall_height / 2
                        ])
                            cube(
                                [motor_mount_length, motor_side_wall_thickness, motor_side_wall_height],
                                center = true
                            );

                        translate([
                            0,
                            -motor_mount_width / 2 + motor_side_wall_thickness / 2,
                            -motor_mount_thickness - motor_side_wall_height / 2
                        ])
                            cube(
                                [motor_mount_length, motor_side_wall_thickness, motor_side_wall_height],
                                center = true
                            );
                    }

                    for (x = [-motor_zip_slot_spacing / 2, motor_zip_slot_spacing / 2])
                        translate([x, 0, -motor_mount_thickness / 2])
                            cube(
                                [
                                    motor_zip_slot_width,
                                    motor_mount_width + 0.4,
                                    motor_mount_thickness + 0.4
                                ],
                                center = true
                            );
                }
            }
    }
}

module spring_seat(angle) {
    rotate([0, 0, angle])
        translate([post_center_radius, 0, base_height]) {
            cylinder(d = spring_outer_diameter, h = spring_seat_height);
        }
}

module base_support_post(angle) {
    rotate([0, 0, angle])
        translate([post_center_radius, 0, base_height]) {
            if (base_post_blend_height > 0) {
                hull() {
                    cylinder(d = base_post_blend_diameter, h = 0.4);

                    translate([0, 0, base_post_blend_height - 0.4])
                        cylinder(d = base_post_diameter, h = 0.4);
                }
            }

            cylinder(d = base_post_diameter, h = base_post_height);
        }
}

module base_mount_holes() {
    for (i = [0 : mount_hole_count - 1]) {
        angle = 360 / mount_hole_count * i + 45;

        rotate([0, 0, angle])
            translate([mount_hole_radius, 0, -foot_height - 0.1])
                cylinder(
                    d = mount_hole_diameter,
                    h = base_height + foot_height + spring_seat_height + 0.2
                );
    }
}

module bottom_feet() {
    for (i = [0 : foot_count - 1]) {
        angle = 360 / foot_count * i + 45;

        rotate([0, 0, angle])
            translate([foot_radius, 0, -foot_height])
                cylinder(d = foot_diameter, h = foot_height);
    }
}

module vibration_top() {
    union() {
        // 主圆盘：上表面用于接触物体，背面长出支撑柱。
        cylinder(d = disk_diameter, h = disk_height);

        friction_rings();

        limit_sleeve();

        motor_mount();

        for (i = [0 : post_count - 1]) {
            angle = 360 / post_count * i;

            support_post(angle);

            if (post_blend_enable)
                smooth_post_blend(angle);
        }
    }
}

module vibration_base() {
    difference() {
        union() {
            cylinder(d = base_diameter, h = base_height);

            for (i = [0 : post_count - 1]) {
                angle = 360 / post_count * i;
                spring_seat(angle);

                if (base_post_enable)
                    base_support_post(angle);
            }

            if (center_limiter_enable)
                translate([0, 0, base_height])
                    cylinder(d = center_limiter_diameter, h = center_limiter_height);

            bottom_feet();
        }

        base_mount_holes();
    }
}

module vibration_table() {
    if (show_part == "top") {
        vibration_top();
    } else if (show_part == "base") {
        vibration_base();
    } else {
        vibration_top();

        translate([0, 0, base_z])
            vibration_base();
    }
}

vibration_table();
