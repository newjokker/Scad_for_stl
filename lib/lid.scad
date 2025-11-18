////////////////////////////////////////////////////////////
// 参数化盖子模块（符合你的四点要求）
//
// lid_size = [L, W]         → 盖子的长宽
// insert_start              → 从盖子底部往上多少开始侵入, 就是盖子外侧部分的厚度
// insert_depth              → 侵入盒子内部的深度
// insert_width              → 边缘侵入框的宽度（固定为一圈侵入）
// handle_size = [L, W]      → 把手长宽
// holes = []                → 孔的列表，每个元素为 [x, y, screw_type]
// screw_type: "m2" 或 "m3" → 螺丝类型，自动计算合适孔径
// pos = [x, y, z]          → 盖子位置坐标
////////////////////////////////////////////////////////////

module lid(
    lid_size=[60, 30],      // 盖子长宽
    insert_start=1.2,       // 盖子从底部开始，有 insert_start 这部分在盒子外（非侵入部分）
    insert_depth=2.5,       // 侵入长度
    insert_width=1.5,       // 侵入框宽度
    handle_size=[12, 6],     // 把手的长和宽
    thick = 1,              // 侵入框壁厚
    pos = [0,0,0],          // 盖子位置
    holes = []              // 孔的列表，格式：[[x1, y1, "m2"], [x2, y2, "m3"], ...]
){
    
    L = lid_size[0] + 2*thick;
    W = lid_size[1] + 2*thick;

    // 螺丝对应的孔径（塑料用自攻螺丝的经验值）
    function get_hole_diameter(screw_type) = 
        screw_type == "m2" ? 2.2 :  // M2通孔径
        screw_type == "m3" ? 3.2 :  // M3通孔径
        2.4; // 默认用M3孔径

    // 把手厚度 = 非侵入部分厚度 → insert_start
    handle_thickness = insert_start;

    // 应用位置变换
    translate(pos) {
        // =============================
        // 1. 盖子上层（不侵入部分）
        // =============================
        difference() {
            cube([L, W, insert_start]);
            
            // 打孔
            for(hole = holes) {
                hole_diameter = get_hole_diameter(hole[2]);
                translate([hole[0], hole[1], -0.1])
                    cylinder(h = insert_start + 0.2, d = hole_diameter, $fn = 30);
            }
        }

        // =============================
        // 2. 侵入框（从 insert_start 开始）
        // =============================
        difference() {
            translate([thick, thick, insert_start])
                cube([L-2*thick, W-2*thick, insert_depth]);
            
            translate([insert_width + thick, insert_width + thick, insert_start])
                cube([L - insert_width*2 -2*thick , W - insert_width*2 - 2*thick, insert_depth + 2]);
        }
        
        // =============================
        // 3. 把手（厚度 = insert_start）
        // =============================
        translate([
            (L - handle_size[0]) / 2,
            W,                        // 放在盖子外侧
            0        // 居中厚度
        ])
            cube([handle_size[0], handle_size[1], insert_start]);
    }
}

// 使用示例
lid(
    lid_size = [60, 30],
    insert_start = 1.2,
    insert_depth = 2.5,
    insert_width = 1.5,
    handle_size = [12, 6],
    thick = 1,
    pos = [10, 20, 5],  // 移动到新位置
    holes = [
        [10, 10, "m2"],    // M2自攻螺丝孔
        [50, 10, "m3"],    // M3自攻螺丝孔
        [10, 20, "m3"],    // M3自攻螺丝孔
        [50, 20, "m2"]     // M2自攻螺丝孔
    ]
);