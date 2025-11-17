// 简单开口盒子
// size: [内部长, 内部宽, 高]
// wall_thickness: 壁厚
// pos: [x, y, z] 盒子左上角底部的坐标
module simple_box(size=[100, 60, 40], wall_thickness=2, pos=[0, 0, 0]) {
    inner_length = size[0];
    inner_width = size[1];
    inner_height = size[2];
    
    // 计算外部尺寸（内部尺寸+2倍壁厚）
    outer_length = inner_length + 2 * wall_thickness;
    outer_width = inner_width + 2 * wall_thickness;
    height = inner_height + wall_thickness; // 高度包括底部壁厚
    
    // 移动到指定位置
    translate(pos) {
        // 空心盒子
        difference() {
            // 外层盒子
            cube([outer_length, outer_width, height]);
            
            // 内层挖空（内部尺寸就是设定的尺寸）
            translate([wall_thickness, wall_thickness, wall_thickness])
            cube([inner_length, inner_width, height + 1]);
        }
    }
}