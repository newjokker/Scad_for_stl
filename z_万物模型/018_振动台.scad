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

// ========== 派生尺寸 ==========
disk_radius = disk_diameter / 2;
post_radius = post_diameter / 2;
post_center_radius = disk_radius - post_edge_gap - post_radius;

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

module vibration_table() {
    union() {
        // 主圆盘：上表面用于接触物体，背面长出支撑柱。
        cylinder(d = disk_diameter, h = disk_height);

        friction_rings();

        for (i = [0 : post_count - 1]) {
            angle = 360 / post_count * i;

            support_post(angle);

            if (post_blend_enable)
                smooth_post_blend(angle);
        }
    }
}

vibration_table();
