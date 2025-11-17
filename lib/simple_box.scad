// 完善的开槽盒子，带倒角功能，支持 Type-C 开孔
// size: [内部长, 内部宽, 高]
// wall_thickness: 壁厚
// corner_radius: 倒角半径
// pos: [x, y, z] 盒子左上角底部的坐标
// type_c_port: 是否添加 Type-C 接口开孔 [enable, x_offset, y_offset, width, height]
module simple_box(size=[100, 60, 40], wall_thickness=2, corner_radius=0, pos=[0, 0, 0], 
                  type_c_port=[false, 0, 0, 8.5, 3, "front"]) {
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
            
            // 添加 Type-C 接口开孔
            if (type_c_port[0]) {
                type_c_hole(outer_length, outer_width, height, wall_thickness, type_c_port);
            }
        }
    }
}

// Type-C 接口开孔模块（带圆角，可指定面）
module type_c_hole(outer_length, outer_width, height, wall_thickness, type_c_port) {
    // type_c_port 参数: [enable, x_offset, y_offset, width, height, face]
    x_offset = type_c_port[1];
    y_offset = type_c_port[2];
    hole_width = type_c_port[3];
    hole_height = type_c_port[4];
    face = type_c_port[5]; // "front", "back", "left", "right", "top", "bottom"

    corner_radius = min(hole_width, hole_height)/4;

    // 默认位置
    hole_x = outer_length/2 + x_offset;
    hole_y = outer_width/2 + y_offset;
    hole_z = height/2 + y_offset;

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


// 圆角矩形开孔模块
module rounded_rectangle_slot(width, height, depth, corner_radius) {
    // 如果圆角半径为0，使用普通矩形
    if (corner_radius <= 0) {
        cube([width, height, depth], center=true);
    } else {
        // 创建圆角矩形
        hull() {
            // 四个角柱
            for (x = [-width/2 + corner_radius, width/2 - corner_radius]) {
                for (y = [-height/2 + corner_radius, height/2 - corner_radius]) {
                    translate([x, y, 0])
                    cylinder(h = depth, r = corner_radius, center=true, $fn = 30);
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
