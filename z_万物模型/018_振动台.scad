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
show_part = "assembly";      // "assembly" 装配预览；"top_disk" 上圆盘；"top_posts" 上柱子；"base_disk" 底盘；"base_posts" 底座柱子；"top" / "base" 整体件
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

// 拆分打印用定位结构
split_mode = true;               // true 时装配预览也显示定位凸起/定位孔
locator_pin_diameter = 4;        // 柱子/电机座定位凸起直径
locator_pin_height = 2.2;        // 定位凸起高度
locator_clearance = 0.25;        // 定位孔单边余量，胶水装配建议 0.2~0.4
top_socket_depth = 2.4;          // 上圆盘底部定位孔深度，需小于 disk_height
base_socket_depth = 3;           // 底盘顶部定位孔深度，需小于 base_height

// 底座固定孔和脚垫
mount_hole_count = 4;
mount_hole_diameter = 4.2;   // M4 螺丝孔可用 4.2 左右
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
locator_hole_diameter = locator_pin_diameter + locator_clearance * 2;

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

module top_post_socket_holes() {
    for (i = [0 : post_count - 1]) {
        angle = 360 / post_count * i;

        rotate([0, 0, angle])
            translate([post_center_radius, 0, -0.1])
                cylinder(d = locator_hole_diameter, h = top_socket_depth + 0.1);
    }
}

module base_post_socket_holes() {
    for (i = [0 : post_count - 1]) {
        angle = 360 / post_count * i;

        rotate([0, 0, angle])
            translate([post_center_radius, 0, base_height - base_socket_depth])
                cylinder(d = locator_hole_diameter, h = base_socket_depth + 0.1);
    }
}

module top_disk_piece(with_sockets = true) {
    difference() {
        union() {
            cylinder(d = disk_diameter, h = disk_height);
            friction_rings();
        }

        if (with_sockets) {
            top_post_socket_holes();
        }
    }
}

module support_post(angle, with_locator = true) {
    rotate([0, 0, angle])
        translate([post_center_radius, 0, 0]) {
            translate([0, 0, -post_height])
                cylinder(d = post_diameter, h = post_height);

            if (with_locator)
                cylinder(d = locator_pin_diameter, h = locator_pin_height);
        }
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

module top_posts_piece(with_locator = true) {
    for (i = [0 : post_count - 1]) {
        angle = 360 / post_count * i;

        support_post(angle, with_locator);

        if (post_blend_enable)
            smooth_post_blend(angle);
    }
}

module spring_seat(angle) {
    rotate([0, 0, angle])
        translate([post_center_radius, 0, base_height]) {
            cylinder(d = spring_outer_diameter, h = spring_seat_height);
        }
}

module base_support_post(angle, with_locator = true) {
    rotate([0, 0, angle])
        translate([post_center_radius, 0, base_height]) {
            if (with_locator)
                translate([0, 0, -locator_pin_height])
                    cylinder(d = locator_pin_diameter, h = locator_pin_height);

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

module base_posts_piece(with_locator = true) {
    for (i = [0 : post_count - 1]) {
        angle = 360 / post_count * i;
        spring_seat(angle);

        if (base_post_enable)
            base_support_post(angle, with_locator);
    }
}

module base_disk_piece(with_sockets = true) {
    difference() {
        union() {
            cylinder(d = base_diameter, h = base_height);
            bottom_feet();
        }

        base_mount_holes();

        if (with_sockets)
            base_post_socket_holes();
    }
}

module base_mount_holes() {
    for (i = [0 : foot_count - 1]) {
        angle = 360 / foot_count * i + 45;

        rotate([0, 0, angle])
            translate([foot_radius, 0, -foot_height - 0.1])
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
        top_disk_piece(split_mode);
        limit_sleeve();
        top_posts_piece(split_mode);
    }
}

module vibration_base() {
    union() {
        base_disk_piece(split_mode);
        base_posts_piece(split_mode);

        if (center_limiter_enable)
            translate([0, 0, base_height])
                cylinder(d = center_limiter_diameter, h = center_limiter_height);
    }
}

module vibration_table() {
    if (show_part == "top_disk") {
        top_disk_piece();
    } else if (show_part == "top_posts") {
        top_posts_piece();
    } else if (show_part == "base_disk") {
        base_disk_piece();
    } else if (show_part == "base_posts") {
        base_posts_piece();
    } else if (show_part == "top") {
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
