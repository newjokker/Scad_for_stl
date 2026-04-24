

thick = 4;
$fn = 200;


module blade_base(
    window_count = 5,          // 窗口数量
    window_w = 50,             // 窗口宽度（沿圆周方向）
    window_h = 40,             // 窗口高度（Z方向）
    window_bottom = 13,        // 窗口底部离底面的高度
    window_cut_depth = 20      // 切割深度，足够大即可
) {

    // 外圈
    translate([0, 0, 90 - 6])
        difference() {
            cylinder(h = 6, r = 165, center = false);  
            translate([0, 0, -0.05])
                cylinder(h = 6.1, r = 161, center = false);  
        }

    // 穿铁棒的小结构
    translate([0, 0, 52])
        difference() {
            cylinder(h = 25, r = 18, center = false);  
            cylinder(h = 25, r = 12.4 / 2, center = false);  
        }

    // 底盘 + 大凸起部分开窗
    difference() {
        union() {
            cylinder(h = 65, r = 80, center = false); 
            cylinder(h = 2.3, r = 162, center = false); 
        }

        // 内腔
        cylinder(h = 65 - thick, r = 80 - thick, center = false); 

        // 中心孔
        cylinder(h = 150, r = 12.4 / 2, center = false);

        // ===== 大圆筒侧壁开多个窗口 =====
        for (i = [0 : window_count - 1]) {
            rotate([0, 0, i * 360 / window_count])
                translate([80 - thick/2, 0, window_bottom + window_h/2])
                    cube([window_cut_depth, window_w, window_h], center = true);
        }
    }

}



intersection(){

    blade_base();

    // cylinder(h= 100, r= 95);

}





     