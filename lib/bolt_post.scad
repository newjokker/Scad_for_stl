// -------------------------
// 修正后的自攻螺丝专用螺栓柱模块
// -------------------------
module bolt_post(
    screw="m3",
    mode="through",      // "through" = 通孔, "self_tap" = 自攻螺丝孔
    height=10,
    rib_height=5,
    rib_thickness=2,
    pos=[0,0,0],
    fn=60
){
    // 自攻螺丝专用尺寸表
    hole_table = [
        ["m2", 2.2, 1.6, 4],
        ["m3", 3.5, 2.2, 6]
    ];

    idx = (screw == "m2") ? 0 : 1;
    clearance = hole_table[idx][1]; 
    self_tap = hole_table[idx][2];
    min_thickness = hole_table[idx][3];
    
    // 真正使用的孔径
    hole_d = (mode == "self_tap") ? self_tap : clearance;
    
    // 螺柱外径（根据孔径自动计算）
    post_od = hole_d + 3; // 外径 = 孔径 + 3mm壁厚
    
    translate(pos) {
        difference() {
            // 主螺柱体（外圆柱）
            cylinder(h = height, d = post_od, $fn = fn);
            
            // 中心孔 - 这才是自攻螺丝要拧入的地方！
            cylinder(h = height, d = hole_d, $fn = fn);
        }
        
        // 自攻螺丝导向倒角
        if (mode == "self_tap") {
            translate([0, 0, height])
            cylinder(h = 1, d1 = hole_d, d2 = hole_d + 1, $fn = fn);
        }

        // 加强筋（现在是在螺柱外部）
        actual_rib_height = min(rib_height, height * 0.8);
        if (actual_rib_height > 0 && rib_thickness > 0) {
            rib_od = post_od + rib_thickness * 2;
            difference() {
                cylinder(h = actual_rib_height, d = rib_od, $fn = fn);
                cylinder(h = actual_rib_height, d = post_od, $fn = fn);
            }
        }
    }
}

// 测试修正后的模块
bolt_post(screw="m3", mode="self_tap", height=8, rib_height=6, rib_thickness=0.5);