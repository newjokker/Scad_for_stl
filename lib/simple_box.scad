// 完善的开槽盒子，带倒角功能，支持多种开孔
// size: [内部长, 内部宽, 高]
// wall_thickness: 壁厚
// corner_radius: 倒角半径
// pos: [x, y, z] 盒子左上角底部的坐标
// holes: 开孔数组，支持 Type-C 和圆孔
module simple_box(size=[100, 60, 40], wall_thickness=2, corner_radius=0, pos=[0, 0, 0], 
                  holes=[]) {
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
        difference() {
            // 空心盒子
            difference() {
                // 外层盒子（带倒角）
                rounded_cube([outer_length, outer_width, height], actual_corner_radius);
                
                // 内层挖空（带倒角）
                translate([wall_thickness, wall_thickness, wall_thickness])
                rounded_cube([inner_length, inner_width, height + 1], inner_corner_radius);
            }
            
            // 添加所有开孔
            for (hole = holes) {
                if (hole[0] == "type_c") {
                    type_c_hole(outer_length, outer_width, height, wall_thickness, hole);
                } else if (hole[0] == "circle") {
                    circle_hole(outer_length, outer_width, height, wall_thickness, hole);
                }
            }
        }
    }
}

// Type-C 接口开孔模块（带圆角，可指定面）
module type_c_hole(outer_length, outer_width, height, wall_thickness, hole_params) {
    // hole_params: ["type_c", x_offset, y_offset, width, height, face]
    x_offset = hole_params[1];
    y_offset = hole_params[2];
    hole_width = hole_params[3];
    hole_height = hole_params[4];
    face = hole_params[5]; // "front", "back", "left", "right", "top", "bottom"

    corner_radius = min(hole_width, hole_height)/4;

    // 根据面调整位置和旋转
    if (face == "front") {
        translate([outer_length/2 + x_offset, -0.5, height/2 + y_offset])
        rotate([-90, 0, 0])
        rounded_rectangle_slot(hole_width, hole_height, outer_width, corner_radius);
    } 
    else if (face == "back") {
        translate([outer_length/2 + x_offset, outer_width + 0.5, height/2 + y_offset])
        rotate([90, 0, 0])
        rounded_rectangle_slot(hole_width, hole_height, outer_width, corner_radius);
    }
    else if (face == "left") {
        translate([-0.5, outer_width/2 + x_offset, height/2 + y_offset])
        rotate([0, 90, 0])
        rounded_rectangle_slot(hole_height, hole_width,  outer_length, corner_radius);
    }
    else if (face == "right") {
        translate([outer_length + 0.5, outer_width/2 + x_offset, height/2 + y_offset])
        rotate([0, -90, 0])
        rounded_rectangle_slot(hole_height, hole_width,  outer_length, corner_radius);
    }
    else if (face == "bottom") {
        translate([outer_length/2 + x_offset, outer_width/2 + y_offset, -0.5])
        rotate([180, 0, 0])
        rounded_rectangle_slot(hole_width, hole_height, wall_thickness*2, corner_radius);
    }
}

// 圆孔开孔模块
module circle_hole(outer_length, outer_width, height, wall_thickness, hole_params) {
    // hole_params: ["circle", x_offset, y_offset, diameter, face]
    x_offset = hole_params[1];
    y_offset = hole_params[2];
    diameter = hole_params[3];
    face = hole_params[4]; // "front", "back", "left", "right", "top", "bottom"

    // 根据面调整位置和旋转
    if (face == "front") {
        translate([outer_length/2 + x_offset, -0.5, height/2 + y_offset])
        rotate([-90, 0, 0])
        cylinder(h = wall_thickness + 1, d = diameter, center = false, $fn = 60);
    } 
    else if (face == "back") {
        translate([outer_length/2 + x_offset, outer_width + 0.5, height/2 + y_offset])
        rotate([90, 0, 0])
        cylinder(h = wall_thickness + 1, d = diameter, center = false, $fn = 60);
    }
    else if (face == "left") {
        translate([-0.5, outer_width/2 + x_offset, height/2 + y_offset])
        rotate([0, 90, 0])
        cylinder(h = wall_thickness + 1, d = diameter, center = false, $fn = 60);
    }
    else if (face == "right") {
        translate([outer_length + 0.5, outer_width/2 + x_offset, height/2 + y_offset])
        rotate([0, -90, 0])
        cylinder(h = wall_thickness + 1, d = diameter, center = false, $fn = 60);
    }
    else if (face == "top") {
        translate([outer_length/2 + x_offset, outer_width/2 + y_offset, height + 0.5])
        cylinder(h = wall_thickness + 1, d = diameter, center = false, $fn = 60);
    }
    else if (face == "bottom") {
        translate([outer_length/2 + x_offset, outer_width/2 + y_offset, -0.5])
        rotate([0, 0, 180])
        cylinder(h = wall_thickness + 1, d = diameter, center = false, $fn = 60);
    }
}

// 圆角矩形开孔模块
module rounded_rectangle_slot(width, height, depth, corner_radius) {
    // 如果圆角半径为0，使用普通矩形
    if (corner_radius <= 0) {
        cube([width, height, depth], center=true);
    } else {
        // 确保圆角半径不超过最小尺寸的一半
        max_r = min(width, height) / 2;
        actual_r = min(corner_radius, max_r);
        
        // 创建圆角矩形
        hull() {
            // 四个角柱
            for (x = [-width/2 + actual_r, width/2 - actual_r]) {
                for (y = [-height/2 + actual_r, height/2 - actual_r]) {
                    translate([x, y, 0])
                    cylinder(h = depth, r = actual_r, center=true, $fn = 30);
                }
            }
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
        // 确保倒角半径不超过最小尺寸的一半
        max_r = min(length, width) / 2;
        actual_r = min(corner_radius, max_r);
        
        // 创建带倒角的长方体
        hull() {
            // 四个角柱
            for (x = [actual_r, length - actual_r]) {
                for (y = [actual_r, width - actual_r]) {
                    translate([x, y, 0])
                    cylinder(h = height, r = actual_r, $fn = 60);
                }
            }
        }
    }
}

// 示例使用

simple_box(
    size = [100, 60, 40],
    wall_thickness = 2,
    corner_radius = 5,
    holes = [
        // Type-C 接口在前面板
        ["type_c", 0, 0, 8.5, 3, "front"],
        // 圆孔在右侧
        ["circle", 10, 0, 5, "right"],
        // 圆孔在顶部
        ["circle", -10, 10, 3, "top"],
        // 圆孔在左侧
        ["circle", 0, -10, 4, "left"]
    ]
);
