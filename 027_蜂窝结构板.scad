include <BOSL2/std.scad>
include <BOSL2/structs.scad>

$fn = 64;  // 优化性能

// ===================== 参数 =====================
cell_r      = 20;     // 六边形“外接圆半径”，也可理解为单元尺寸
wall_t      = 1;    // 蜂窝壁厚
core_h      = 30;     // 蜂窝高度
rows        = 5;      // 行数
cols        = 5;      // 列数
base_t      = 2;      // 底板厚度

// ===================== 基本六边形 =====================
module hex2d(r=10) {
    polygon(points=[
        for (i=[0:5]) [r*cos(60*i), r*sin(60*i)]
    ]);
}

// 单个蜂窝壁（2D）
module honeycomb_cell_2d(r=10, t=1) {
    difference() {
        hex2d(r);
        offset(delta=-t) hex2d(r);
    }
}

// 单个蜂窝壁（3D）
module honeycomb_cell_3d(r=10, t=1, h=20) {
    rotate([0, 0, 30])
    linear_extrude(height=h)
        honeycomb_cell_2d(r, t);
}

// ===================== 蜂窝阵列 =====================
// pointy-top 六边形排布
module honeycomb_core(r=10, t=1, h=20, rows=5, cols=6) {
    dx = sqrt(3) * (r - wall_t/2);        // 同列中心的 x 间距
    dy = 1.5 * (r - wall_t/2);            // 行间距

    union() {
        for (row = [0:rows-1]) {
            for (col = [0:cols-1]) {
                x = col * dx + (row % 2) * dx / 2;
                y = row * dy;
                translate([x, y, 0])
                    honeycomb_cell_3d(r, t, h);
            }
        }
    }
}

// ===================== 底板 =====================
module base_plate() {

    cuboid([500,500,2], anchor=[0,0,1]);

}

// ===================== 总装 =====================
union() {
    base_plate();
    honeycomb_core(cell_r, wall_t, core_h, rows, cols);
}