
include <BOSL2/std.scad>

////////////////////////////////////////////////////////////
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
    n_bumps_per_side = 8,  // 每条边上的小凸起数量
    bump_diameter = 1,    // 小凸起圆柱直径
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
                cuboid([L-2*thick, W-2*thick, insert_depth], anchor=FRONT+LEFT+BOT, chamfer=0.5, edges=[TOP]);
            
            translate([insert_width + thick + bump_diameter/2 , insert_width + thick + bump_diameter/2, insert_start])
                cuboid([L - insert_width*2 -2*thick -bump_diameter, W - insert_width*2 - 2*thick - bump_diameter, insert_depth + 2], anchor=FRONT+LEFT+BOT);
        }
        
        // =============================
        // 3. 把手（厚度 = insert_start）
        // =============================
        translate([
            (L - handle_size[0]) / 2,
            -handle_size[1],                        // 放在盖子外侧
            0        // 居中厚度
        ])
            cube([handle_size[0], handle_size[1], insert_start]);

        // // =============================
        // // 4. 侵入立墙侧边的小凸起（沿着四条垂直边均匀分布）
        // // =============================

        // // === 参数设置 ===
        // // bump_diameter = 1;        // 小凸起圆柱直径
        // // bump_height = insert_depth;  // 小凸起高度 == 侵入深度（从底到顶）
        // // bump_radius = bump_diameter / 2;

        // // 每条边上的小凸起数量
        // // n_bumps_per_side = 8;     // 每条边放几个小凸起

        // // 侵入立墙的位置和尺寸
        // wall_x_start = thick;       // 控制球突出的深浅
        // wall_x_end   = thick + (L - 2*thick);  // 即 L - thick
        // wall_y_start = thick;
        // wall_y_end   = thick + (W - 2*thick);  // 即 W - thick
        // wall_z_start = insert_start;
        // wall_z_end   = insert_start + insert_depth;

        // wall_width_x = wall_x_end - wall_x_start;  // L - 2*thick
        // wall_width_y = wall_y_end - wall_y_start;  // W - 2*thick

        // // 均匀分布的计算
        // spacing_x = wall_width_x / (n_bumps_per_side + 1);
        // spacing_y = wall_width_y / (n_bumps_per_side + 1);

        // // 1. 左侧边 (x = wall_x_start, y 从 y_start 到 y_end)
        // for (i = [1:n_bumps_per_side]) {
        //     y = wall_y_start + (i * spacing_y);
        //     translate([wall_x_start, y, wall_z_start + insert_depth/(9/5)])
        //         sphere(r = bump_diameter / 2, $fn=16);
        // }

        // // 2. 右侧边 (x = wall_x_end, y 从 y_start 到 y_end)
        // for (i = [1:n_bumps_per_side]) {
        //     y = wall_y_start + (i * spacing_y);
        //     translate([wall_x_end, y, wall_z_start + insert_depth/(9/5)])
        //         sphere(r = bump_diameter / 2, $fn=16);
        // }

        // // 3. 下侧边 (y = wall_y_start, x 从 x_start 到 x_end)
        // for (i = [1:n_bumps_per_side]) {
        //     x = wall_x_start + (i * spacing_x);
        //     translate([x, wall_y_start, wall_z_start + insert_depth/(9/5)])
        //         sphere(r = bump_diameter / 2, $fn=16);
        // }

        // // 4. 上侧边 (y = wall_y_end, x 从 x_start 到 x_end)
        // for (i = [1:n_bumps_per_side]) {
        //     x = wall_x_start + (i * spacing_x);
        //     translate([x, wall_y_end, wall_z_start + insert_depth/(9/5)])
        //         sphere(r = bump_diameter / 2, $fn=16);
        // }

    }
}


module lid_new(
    lid_size = [10, 10, 2],
    plug_thickness = 1,
    plug_depth = 1,
    wall_thickness = 1,
    chamfer=0.5,
    hand_width=8,
    hand_height=3,
    hand_direction="right",
    pos=[0,0,0]
){

    translate(pos){

        // 移动到中心点
        translate([-lid_size[0]/2, -lid_size[1]/2, 0])
        {
            // 盖子的主体
            cuboid(lid_size, anchor=[-1, -1, -1], chamfer=chamfer);

            // 盖子的把手
            if(hand_direction == "right"){
                translate([lid_size[0]/2 - hand_width/2, -hand_height+1, 0]){
                    cuboid([hand_width, hand_height, lid_size[2]], chamfer=chamfer, anchor=[-1, -1, -1], edges=[FRONT]);
                }
            }
            else{
                translate([lid_size[0]/2 - hand_width/2, lid_size[1] -1, 0]){
                    cuboid([hand_width, hand_height, lid_size[2]], chamfer=chamfer, anchor=[-1, -1, -1], edges=[BACK]);
                }  
            }

            // 公口部分
            difference(){
                outer_size = [
                    lid_size[0] - 2*wall_thickness,
                    lid_size[1] - 2*wall_thickness, 
                    plug_depth
                ];
                
                inner_size = [
                    lid_size[0] - 2*wall_thickness - 2*plug_thickness,
                    lid_size[1] - 2*wall_thickness - 2*plug_thickness,
                    plug_depth + 0.01  // 高度略大, 为了干净的切割
                ];
                
                // 外圈的矩形
                translate([wall_thickness, wall_thickness, lid_size[2]])
                    cuboid(outer_size, anchor=[-1, -1, -1], chamfer=chamfer, edges=[TOP, LEFT+FRONT, RIGHT+FRONT, LEFT+BACK, RIGHT+BACK]);
                
                // 内圈矩形，让被减去的立方体在高度上略微超出主体，确保完全、干净地切割
                translate([wall_thickness + plug_thickness, wall_thickness + plug_thickness, lid_size[2] - 0.005])
                    cuboid(inner_size, anchor=[-1, -1, -1]);
            }
        }
    }
}


// // 使用示例
// lid(
//     lid_size = [60, 30],
//     insert_start = 1.2,
//     insert_depth = 2.5,
//     insert_width = 1.5,
//     handle_size = [12, 6],
//     thick = 1,
//     pos = [0, 0, 0],  // 移动到新位置
//     holes = [
//         [10, 10, "m2"],    // M2自攻螺丝孔
//         [50, 10, "m3"],    // M3自攻螺丝孔
//         [10, 20, "m3"],    // M3自攻螺丝孔
//         [50, 20, "m2"]     // M2自攻螺丝孔
//     ]
// );

lid_new(
    lid_size=[50, 30, 1.5],
    plug_thickness=1.5,
    plug_depth=1.5,
    wall_thickness=1,
    chamfer=0.5,
    // hand_direction="right",
    hand_direction="left",
    pos=[0, 0, 5]
    );

