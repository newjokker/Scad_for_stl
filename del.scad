// 完善的开槽盒子，带倒角功能
// size: [内部长, 内部宽, 高]
// wall_thickness: 壁厚
// corner_radius: 倒角半径
// pos: [x, y, z] 盒子左上角底部的坐标
module simple_box(size=[100, 60, 40], wall_thickness=2, corner_radius=0, pos=[0, 0, 0]) {
    inner_length = size[0];
    inner_width = size[1];
    inner_height = size[2];
    
    // 计算外部尺寸（内部尺寸+2倍壁厚）
    outer_length = inner_length + 2 * wall_thickness;
    outer_width = inner_width + 2 * wall_thickness;
    height = inner_height + wall_thickness; // 高度包括底部壁厚
    
    // 确保倒角半径不超过最小尺寸的一半
    max_corner_radius = min(outer_length, outer_width) / 2;
    actual_corner_radius = min(corner_radius, max_corner_radius);
    
    // 内部倒角半径（不能为负）
    inner_corner_radius = max(actual_corner_radius - wall_thickness, 0);
    
    // 移动到指定位置
    translate(pos) {
        // 空心盒子
        difference() {
            // 外层盒子（带倒角）
            rounded_cube([outer_length, outer_width, height], actual_corner_radius);
            
            // 内层挖空（带倒角）
            translate([wall_thickness, wall_thickness, wall_thickness])
            rounded_cube([inner_length, inner_width, height + 1], inner_corner_radius);
        }
    }
}

// 创建带倒角的长方体模块
module rounded_cube(size, corner_radius) {
    length = size[0];
    width = size[1];
    height = size[2];
    
    // 如果倒角半径为0，使用普通立方体
    if (corner_radius <= 0) {
        cube(size);
    } else {
        // 创建带倒角的长方体
        hull() {
            // 四个角柱
            for (x = [corner_radius, length - corner_radius]) {
                for (y = [corner_radius, width - corner_radius]) {
                    translate([x, y, 0])
                    cylinder(h = height, r = corner_radius, $fn = 60);
                }
            }
        }
    }
}

// 示例使用
// 默认尺寸的盒子
simple_box();

// 大盒子，大倒角
translate([120, 0, 0])
simple_box(size=[80, 50, 30], wall_thickness=3, corner_radius=10);

