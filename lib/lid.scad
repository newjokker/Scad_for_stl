////////////////////////////////////////////////////////////
// 参数化盖子模块（符合你的四点要求）
//
// lid_size = [L, W]         → 盖子的长宽
// insert_start              → 从盖子底部往上多少开始侵入, 就是盖子外侧部分的厚度
// insert_depth              → 侵入盒子内部的深度
// insert_width              → 边缘侵入框的宽度（固定为一圈侵入）
// handle_size = [L, W]      → 把手长宽
////////////////////////////////////////////////////////////

module lid(
    lid_size=[60, 30],      // 盖子长宽
    insert_start=1.2,       // 盖子从底部开始，有 insert_start 这部分在盒子外（非侵入部分）
    insert_depth=2.5,       // 侵入长度
    insert_width=1.5,       // 侵入框宽度
    handle_size=[12, 6],     // 把手的长和宽
    thick = 1               // 侵入框壁厚
){
    L = lid_size[0];
    W = lid_size[1];

    // 把手厚度 = 非侵入部分厚度 → insert_start
    handle_thickness = insert_start;

    // =============================
    // 1. 盖子上层（不侵入部分）
    // =============================
    cube([L, W, insert_start]);

    // =============================
    // 2. 侵入框（从 insert_start 开始）
    // =============================
    difference() {
        translate([thick, thick, insert_start])
            cube([L-2*thick, W-2*thick, insert_depth]);
        
        translate([insert_width + thick, insert_width + thick, insert_start - 0.5])
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

