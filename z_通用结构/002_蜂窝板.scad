include <BOSL2/std.scad>
include <BOSL2/structs.scad>

$fn = 80;  // 优化性能

// ===================== 参数 =====================
cell_r      = 8;     // 六边形“外接圆半径”，也可理解为单元尺寸
wall_t      = 0.8;   // 蜂窝壁厚
rows        = 5;     // 行数
cols        = 5;     // 列数

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

// 单个蜂窝单元（带上下盖）
module honeycomb_cell_with_caps(r=10, t=1, h=20, pip_h=15, r_hollow=2) {
    # difference(){
        union(){
            rotate([0, 0, 30])
            union() {
                // 蜂窝壁
                linear_extrude(height=h)
                    honeycomb_cell_2d(r, t);
                
                // 下盖（底板）
                linear_extrude(height=t)
                    hex2d(r - t/2);
                
                // 上盖
                translate([0, 0, h - t])
                linear_extrude(height=t)
                    hex2d(r - t/2);
            }
        }
        translate([0, 0, t])
            cylinder(h=t * 2 + h, r=r_hollow, center=false);
    }

    // 下面的管子
    translate([0, 0, h-pip_h-t])
        difference(){
            cylinder(r=r_hollow + t, h=pip_h);
            cylinder(r=r_hollow, h=pip_h);
        }
}


linear_extrude(height=10)
    honeycomb_cell_2d(8, wall_t);