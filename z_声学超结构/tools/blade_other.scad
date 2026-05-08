
// ==================== 全局参数 ====================

$fn = 200;

// 壁厚
thick = 4;


// ==================== 外圈参数 ====================

outer_ring_z = 84;
outer_ring_h = 6;
outer_ring_r = 165;
outer_ring_inner_r = 161;


// ==================== 中心铁棒座参数 ====================

shaft_holder_z = 52 - 12.18;        // 铁棒座底部离底面的高度
shaft_holder_h = 25;                // 铁棒座高度
shaft_holder_outer_r = 18;          // 铁棒座外半径
// shaft_holder_outer_r = 40/2;          // 铁棒座外半径
shaft_hole_d = 12.4;                // 中心孔直径
// shaft_hole_d = 27;                // 中心孔直径


// ==================== 底盘 / 主圆筒参数 ====================

base_h = 55;
base_r = 80;

bottom_plate_h =  2;                 // 底盘的厚度
bottom_plate_r = 162;


// ==================== 窗口参数 ====================

window_count = 5;
window_w = 50;             // 沿圆周方向宽度
window_h = 35;             // Z 方向高度
window_bottom = 10;        // 窗口底部离底面高度
window_cut_depth = 20;     // 切穿侧壁的深度


// ==================== 模块定义 ====================

// 圆环
module ring(h, outer_r, inner_r) {
    difference() {
        cylinder(h = h, r = outer_r);
        translate([0, 0, -0.05])
            cylinder(h = h + 0.1, r = inner_r);
    }
}


// 中心孔
module shaft_hole(h = 200) {
    cylinder(h = h, r = shaft_hole_d / 2);
}


// 中心铁棒座
module shaft_holder() {
    difference() {
        cylinder(h = shaft_holder_h, r = shaft_holder_outer_r);
        shaft_hole(shaft_holder_h + 0.1);
    }
}


// 侧壁窗口
module side_windows() {
    for (i = [0 : window_count - 1]) {
        rotate([0, 0, i * 360 / window_count])
            translate([
                base_r - thick / 2,
                0,
                window_bottom + window_h / 2
            ])
                cube(
                    [window_cut_depth, window_w, window_h],
                    center = true
                );
    }
}


// 主底座
module main_base() {
    difference() {
        union() {
            // 主圆筒
            cylinder(h = base_h, r = base_r);

            // 底部大圆盘
            cylinder(h = bottom_plate_h, r = bottom_plate_r);
        }

        // 内腔
        cylinder(h = base_h - thick, r = base_r - thick);

        // 中心孔
        shaft_hole();

        // 侧面窗口
        side_windows();
    }
}


// 总装
module blade_base() {

    // 外圈
    translate([0, 0, outer_ring_z])
        ring(
            h = outer_ring_h,
            outer_r = outer_ring_r,
            inner_r = outer_ring_inner_r
        );

    // 中心铁棒座
    translate([0, 0, shaft_holder_z])
        shaft_holder();

    // 底盘主体
    main_base();
}


// ==================== 生成模型 ====================

blade_base();



intersection(){

    blade_base();

    cylinder(h= 100, r= 95);

}





     