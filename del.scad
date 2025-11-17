// 圆角盒子带嵌入式螺丝座
module rounded_screw_box(
    // 基本参数
    size = [100, 60, 40],           // 内部尺寸 [长,宽,高]
    wall_thickness = 2,             // 壁厚
    corner_radius = 8,              // 外圆角半径
    
    // 螺丝座参数
    screw_diameter = 3,             // 螺丝直径
    screw_boss_diameter = 12,       // 螺丝座直径
    screw_boss_height = 15,         // 螺丝座高度
    screw_positions = "corners",    // 螺丝位置 ("corners", "sides", 自定义)
    screw_count_per_side = 2,       // 每边螺丝数量
    screw_offset = 15,              // 螺丝距离边缘偏移
    
    // 圆角过渡参数
    transition_angle = 30,          // 过渡角度
    smooth_transition = true,        // 是否平滑过渡
    
    // 其他参数
    lid_screw_holes = true,         // 盖子螺丝孔
    reinforcement_ribs = true,      // 加强筋
    pos = [0, 0, 0]                 // 位置
) {
    inner_length = size[0];
    inner_width = size[1];
    inner_height = size[2];
    
    outer_length = inner_length + 2 * wall_thickness;
    outer_width = inner_width + 2 * wall_thickness;
    total_height = inner_height + wall_thickness;
    
    // 计算有效圆角半径（不能超过尺寸的一半）
    effective_radius = min(corner_radius, min(outer_length, outer_width)/2 - 1);
    
    // 生成螺丝位置
    screw_positions_array = generate_rounded_screw_positions(
        screw_positions, 
        outer_length, 
        outer_width, 
        effective_radius, 
        screw_offset, 
        screw_count_per_side
    );
    
    translate(pos) {
        // 主圆角盒子
        difference() {
            // 外盒（带圆角）
            rounded_cube([outer_length, outer_width, total_height], effective_radius);
            
            // 内盒挖空（也带圆角）
            translate([wall_thickness, wall_thickness, wall_thickness])
            rounded_cube(
                [inner_length, inner_width, total_height - wall_thickness + 0.1], 
                max(0, effective_radius - wall_thickness)
            );
            
            // 盖子螺丝孔
            if (lid_screw_holes) {
                lid_screw_holes_rounded(screw_positions_array, screw_diameter, total_height);
            }
        }
        
        // 创建螺丝座
        for(pos = screw_positions_array) {
            translate([pos[0], pos[1], 0])
            rounded_screw_boss(
                screw_diameter = screw_diameter,
                boss_diameter = screw_boss_diameter,
                boss_height = screw_boss_height,
                total_height = total_height,
                corner_radius = effective_radius,
                transition_angle = transition_angle,
                smooth_transition = smooth_transition,
                reinforcement = reinforcement_ribs
            );
        }
    }
}

// 圆角立方体模块
module rounded_cube(size, radius) {
    length = size[0];
    width = size[1];
    height = size[2];
    
    // 确保圆角半径合理
    r = min(radius, min(length, width)/2);
    
    hull() {
        // 四个角的圆柱
        translate([r, r, 0]) cylinder(h = height, r = r, $fn = 36);
        translate([length - r, r, 0]) cylinder(h = height, r = r, $fn = 36);
        translate([r, width - r, 0]) cylinder(h = height, r = r, $fn = 36);
        translate([length - r, width - r, 0]) cylinder(h = height, r = r, $fn = 36);
    }
}

// 生成圆角盒子的螺丝位置
function generate_rounded_screw_positions(type, length, width, radius, offset, count) =
    (type == "corners") ? [
        // 四角位置（考虑圆角）
        [radius + offset, radius + offset],
        [length - radius - offset, radius + offset],
        [radius + offset, width - radius - offset],
        [length - radius - offset, width - radius - offset]
    ] :
    (type == "sides") ? 
        let(
            usable_length = length - 2 * radius,
            usable_width = width - 2 * radius,
            x_positions = [for(i = [0:count-1]) radius + (i+1) * usable_length / (count+1)],
            y_positions = [for(i = [0:count-1]) radius + (i+1) * usable_width / (count+1)]
        )
        concat(
            // 底边螺丝
            [for(x = x_positions) [x, radius + offset]],
            // 顶边螺丝
            [for(x = x_positions) [x, width - radius - offset]],
            // 左边螺丝
            [for(y = y_positions) [radius + offset, y]],
            // 右边螺丝
            [for(y = y_positions) [length - radius - offset, y]]
        )
    : type;

// 圆角过渡螺丝座
module rounded_screw_boss(
    screw_diameter = 3,
    boss_diameter = 12,
    boss_height = 15,
    total_height = 40,
    corner_radius = 8,
    transition_angle = 30,
    smooth_transition = true,
    reinforcement = true
) {
    bottom_thickness = 3; // 底部厚度
    
    difference() {
        union() {
            // 螺丝座主体
            cylinder(h = boss_height, d = boss_diameter, $fn = 48);
            
            // 底部平台
            cylinder(h = bottom_thickness, d = boss_diameter + 4, $fn = 48);
            
            // 圆角过渡部分
            if (smooth_transition) {
                translate([0, 0, bottom_thickness])
                smooth_transition_ring(boss_diameter, corner_radius, boss_height - bottom_thickness, transition_angle);
            } else {
                // 简单圆锥过渡
                translate([0, 0, bottom_thickness])
                cylinder(h = boss_height - bottom_thickness, d1 = boss_diameter + 4, d2 = boss_diameter, $fn = 48);
            }
        }
        
        // 螺丝孔（底部留底）
        translate([0, 0, bottom_thickness])
        cylinder(h = boss_height - bottom_thickness + 0.1, d = screw_diameter, $fn = 24);
        
        // 顶部倒角
        translate([0, 0, boss_height - 2])
        cylinder(h = 2.1, d1 = screw_diameter, d2 = screw_diameter + 2, $fn = 24);
    }
    
    // 加强筋
    if (reinforcement && boss_height > 12) {
        for(angle = [0:90:270]) {
            rotate([0, 0, angle])
            reinforcement_rib(
                boss_diameter, 
                corner_radius, 
                boss_height, 
                bottom_thickness,
                transition_angle
            );
        }
    }
}

// 平滑过渡环
module smooth_transition_ring(boss_dia, corner_radius, height, angle) {
    transition_height = min(height, boss_dia/2 * tan(angle));
    
    if (transition_height < height) {
        // 过渡部分 + 垂直部分
        cylinder(h = transition_height, d1 = boss_dia + corner_radius, d2 = boss_dia, $fn = 48);
        translate([0, 0, transition_height])
        cylinder(h = height - transition_height, d = boss_dia, $fn = 48);
    } else {
        // 只有过渡部分
        cylinder(h = height, d1 = boss_dia + corner_radius, d2 = boss_dia, $fn = 48);
    }
}

// 加强筋模块
module reinforcement_rib(boss_dia, corner_radius, height, bottom_thickness, angle) {
    rib_width = 3;
    rib_length = corner_radius * 0.7;
    
    translate([boss_dia/2 - 0.5, -rib_width/2, bottom_thickness])
    hull() {
        // 底部（宽）
        cube([rib_length, rib_width, 1]);
        // 顶部（连接到螺丝座）
        translate([0, 0, height - bottom_thickness])
        cube([1, rib_width, 1]);
    }
}

// 圆角盒子的盖子螺丝孔
module lid_screw_holes_rounded(positions, screw_dia, total_height) {
    for(pos = positions) {
        translate([pos[0], pos[1], total_height - 3])
        cylinder(h = 3.1, d = screw_dia + 0.5, $fn = 20);
    }
}

// 测试模块
module test_rounded_screw_box() {
    echo("=== 圆角螺丝盒子测试 ===");
    
    // 测试1：基本四角圆角盒子
    translate([0, 0, 0])
    rounded_screw_box(
        size = [80, 50, 30],
        wall_thickness = 2,
        corner_radius = 10,
        screw_diameter = 2.5,
        screw_boss_diameter = 14,
        screw_boss_height = 18,
        screw_positions = "corners",
        screw_offset = 12,
        smooth_transition = true
    );
    
    // 测试2：侧边多螺丝
    translate([100, 0, 0])
    rounded_screw_box(
        size = [100, 70, 40],
        wall_thickness = 2.5,
        corner_radius = 12,
        screw_diameter = 3,
        screw_boss_diameter = 16,
        screw_boss_height = 20,
        screw_positions = "sides",
        screw_count_per_side = 3,
        screw_offset = 15,
        transition_angle = 45
    );
    
    // 测试3：大圆角小螺丝座
    translate([0, 80, 0])
    rounded_screw_box(
        size = [120, 80, 35],
        wall_thickness = 3,
        corner_radius = 20,
        screw_diameter = 4,
        screw_boss_diameter = 18,
        screw_boss_height = 22,
        screw_positions = "corners",
        screw_offset = 18,
        smooth_transition = false
    );
    
    // 测试4：自定义位置
    translate([130, 80, 0])
    rounded_screw_box(
        size = [90, 60, 25],
        wall_thickness = 2,
        corner_radius = 8,
        screw_diameter = 2.5,
        screw_boss_diameter = 10,
        screw_boss_height = 12,
        screw_positions = [
            [20, 15], [70, 15],
            [20, 45], [70, 45],
            [45, 30]  // 中心一个
        ],
        transition_angle = 25
    );
}

// 单独测试螺丝座
module test_screw_boss() {
    translate([0, 0, 0])
    rounded_screw_boss(
        screw_diameter = 3,
        boss_diameter = 12,
        boss_height = 15,
        total_height = 30,
        corner_radius = 8,
        transition_angle = 30,
        smooth_transition = true,
        reinforcement = true
    );
    
    translate([20, 0, 0])
    rounded_screw_boss(
        screw_diameter = 4,
        boss_diameter = 16,
        boss_height = 20,
        total_height = 40,
        corner_radius = 10,
        transition_angle = 45,
        smooth_transition = false,
        reinforcement = true
    );
}

// 渲染选择
// test_rounded_screw_box(); // 取消注释测试完整盒子
test_screw_boss();       // 取消注释测试螺丝座

// // 实际使用示例
// rounded_screw_box(
//     size = [80, 50, 30],
//     wall_thickness = 2,
//     corner_radius = 8,
//     screw_diameter = 2,
//     screw_boss_diameter = 6,
//     screw_boss_height = 15,
//     screw_positions = "corners",
//     screw_offset = 5,
//     smooth_transition = true,
//     reinforcement_ribs = true
// );