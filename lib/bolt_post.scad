
include <BOSL2/std.scad>
$fn = 60;

// 螺栓柱
module boss(
    screw="m3",
    mode="through",         // "through" = 通孔, "self_tap" = 自攻螺丝孔
    height=10,              // 整个螺栓的高度
    rib_height=5,           // 加强筋的高度
    rib_thickness=2,        // 加强柱在外边缘之外的延生宽度
    pos=[0,0,0],            // 螺丝外边缘的壁厚
    thick=2
){
    // 自攻螺丝专用尺寸表
    hole_table = [
        ["m2", 2.2, 1.6],       // 螺丝类型, φ通孔, φ引导孔
        ["m3", 3.5, 2.2]
    ];

    idx = (screw == "m2") ? 0 : 1;
    clearance = hole_table[idx][1]; 
    self_tap = hole_table[idx][2];
    
    // 真正使用的孔径
    hole_d = (mode == "self_tap") ? self_tap : clearance;
    
    // 螺柱外径（根据孔径自动计算）
    post_od = hole_d + thick; 
    
    translate(pos) {

        // 螺栓柱
        color("red")
        difference() {
            cylinder(h = height, d = post_od);            
            cylinder(h = height, d = hole_d);
        }
        
        // 加强筋
        actual_rib_height = min(rib_height, height * 0.8);
        if (actual_rib_height > 0 && rib_thickness > 0) {
            rib_od = post_od + rib_thickness * 2;
            difference() {
                cylinder(h = actual_rib_height, d = rib_od);
                cylinder(h = actual_rib_height, d = post_od);
            }
        }
    }
}

// 磁铁固定座
module magnet_holder(
    magnet_diameter,    // 磁铁的直径
    magnet_thickness,   // 磁铁的厚度
    holder_height,      // 整个外壳（圆柱）的总高度（通常 >= 磁铁厚度）
    wall_thickness = 2, // 有磁铁部分的墙厚度
    fn = 60,            // 圆柱面分段数
    pos = [0, 0, 0]     // 放置位置
) {

    translate(pos){

        // 不包含磁铁的部分
        cylinder(h=holder_height - magnet_thickness, r=(magnet_diameter + wall_thickness)/2 , anchor=DOWN);
        
        // 包含磁铁的部分
        color("red")
        translate([0, 0, holder_height - magnet_thickness]){
            difference() {
                cylinder(h=magnet_thickness, r=(magnet_diameter + wall_thickness)/2, anchor=DOWN);
                cylinder(h=magnet_thickness, r=magnet_diameter/2, anchor=DOWN);
            }
        }
    }
}


// 螺丝柱
// boss(screw="m3", mode="through", height=10, rib_height= 4, rib_thickness=1, thick=2, pos=[0,0,0]);


// 磁铁柱
magnet_holder(
    magnet_diameter = 6 + 0.3,
    magnet_thickness = 3,
    holder_height = 6,    
    wall_thickness = 1,
    pos = [0, 0, 0]       
);