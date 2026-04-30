include <BOSL2/std.scad>

$fn = 80;

// 参数设置（现在全表示内部尺寸）
bottom_length = 100;    // 底部内边长
bottom_width  = 55;     // 底部内边宽
top_length    = 10;     // 顶部内边长
top_width     = 5;      // 顶部内边宽
height        = 60;     // 总高度
wall_thickness = 1.5;     // 侧壁厚度

// 主函数：根据内径+壁厚自动算外径
module hollow_frustum(ibL, ibW, itL, itW, H, t) {
    // 外轮廓 = 内径 + 两侧壁厚
    obL = ibL + 2 * t;
    obW = ibW + 2 * t;
    otL = itL + 2 * t;
    otW = itW + 2 * t;

    difference() {
        // 用外径做实体
        linear_extrude(height = H, scale = [otL / obL, otW / obW]) {
            square([obL, obW], center = true);
        }

        // 用内径挖空（上下各留一点余量防渲染瑕疵）
        translate([0, 0, -0.001])
        linear_extrude(height = H + 0.002, scale = [itL / ibL, itW / ibW]) {
            square([ibL, ibW], center = true);
        }
    }
}

// 调用生成（传的是内径）
hollow_frustum(
    bottom_length, bottom_width,
    top_length, top_width,
    height, wall_thickness
);


# translate([0, 0, -30])
    difference(){
        cuboid([bottom_length + 2*wall_thickness, bottom_width + 2*wall_thickness, height * 1.8], anchor = [0, 0, -1]);
        cuboid([bottom_length , bottom_width, height * 1.8 - wall_thickness], anchor = [0, 0, -1]);
        translate([0, 15, 0])
            cuboid([bottom_length , bottom_width, 30], anchor = [0, 0, -1]);
    }

cuboid([bottom_length , bottom_width/2, wall_thickness], anchor = [0, -1, -1]);