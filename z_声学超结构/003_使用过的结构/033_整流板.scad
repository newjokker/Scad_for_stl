

include <BOSL2/std.scad>
include <BOSL2/structs.scad>

$fn = 80;  // 优化性能

// ===================== 参数 =====================
cell_r      = 6;     // 六边形“外接圆半径”，也可理解为单元尺寸
wall_t      = 0.8;   // 蜂窝壁厚
rows        = 35;     // 行数
cols        = 35;     // 列数
height      = 12;    // 蜂窝高度

// ===================== 基本六边形 =====================
module hex2d(r=10) {
    polygon(points=[
        for (i=[0:5]) [r*cos(60*i), r*sin(60*i)]
    ]);
}

// 单个蜂窝壁
module honeycomb_cell_3d(r=10, t=1, h=10) {
    rotate([0, 0, 30])
        linear_extrude(height=h)
            difference() {
                hex2d(r);
                offset(delta=-t) hex2d(r);
            }
}

// 蜂窝阵列（带盖子）
module honeycomb_core(r=10, t=1, rows=5, cols=6,  h=10) {
    dx = sqrt(3) * (r - t/2);        // 同列中心的 x 间距
    dy = 1.5 * (r - t/2);            // 行间距

    union() {
        for (row = [0:rows-1]) {
            for (col = [0:cols-1]) {
                x = col * dx + (row % 2) * dx / 2;
                y = row * dy;
                translate([x, y, 0])
                    honeycomb_cell_3d(r, wall_t, h);
            }
        }
    }
}


thick = 2;
r = 120/2;

difference(){
    cylinder(r=r, h=height, center=false);
    translate([0, 0, -0.01])
    cylinder(r=r - thick , h=height + 0.02, center=false);
}

intersection(){
    translate([-200, -200, 0])
        honeycomb_core(r=cell_r, t=wall_t, rows=rows, cols=cols, h=height);
    
    cylinder(r=r, h=height, center=false);
}
