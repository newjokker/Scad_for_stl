
include <BOSL2/std.scad>



$fn = 24;

// 简化版 Type-C 接口开孔模块
module type_c_hole(offset=0.2, depth=3) {
    
    // Type-C 接口标准尺寸
    hole_width = 8.4 + offset;                  // 标准宽度
    hole_height = 2.6 + offset * (2.6/8.4);     // 标准高度
    corner_radius = 0.5;                        // 圆角半径
    
    // 对应的圆角矩形
    cuboid([hole_width, hole_height, depth], 
           anchor = [-1, -1, -1], 
           rounding = corner_radius, 
           edges = [LEFT+FRONT, RIGHT+FRONT, LEFT+BACK, RIGHT+BACK]);
}

// 使用示例
type_c_hole(offset=0.5, depth=5);