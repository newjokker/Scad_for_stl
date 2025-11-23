
include <BOSL2/std.scad>
$fn = 60;


module bolt_post(
    screw="m3",
    mode="through",      // "through" = 通孔, "self_tap" = 自攻螺丝孔
    height=10,
    rib_height=5,
    rib_thickness=2,
    pos=[0,0,0],
    fn=60,
    thick=2
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
    post_od = hole_d + thick; // 外径 = 孔径 + 壁厚
    
    translate(pos) {
        difference() {
            // 主螺柱体（外圆柱）
            cylinder(h = height, d = post_od, $fn = fn);
            
            // 中心孔 - 这才是自攻螺丝要拧入的地方！
            cylinder(h = height, d = hole_d, $fn = fn);
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

module magnet_holder(
    magnet_diameter,    // 磁铁的直径
    magnet_thickness,   // 磁铁的厚度
    holder_height,      // 整个外壳（圆柱）的总高度（通常 >= 磁铁厚度）
    wall_thickness_upper = 2, // 有磁铁部分的墙厚度
    wall_thickness_down  = 3, // 没磁铁部分的墙壁的厚度
    fn = 60,            // 圆柱面分段数
    pos = [0, 0, 0]     // 放置位置
) {

    translate(pos){

        // 不包含磁铁的部分
        difference() {
            cylinder(h=holder_height - magnet_thickness, r=(magnet_diameter + wall_thickness_upper)/2 , anchor=DOWN);
            cylinder(h=holder_height - magnet_thickness, r=(magnet_diameter - wall_thickness_down)/2, anchor=DOWN);
        }
        
        // 包含磁铁的部分
        color("red")
        translate([0, 0, holder_height - magnet_thickness]){
            difference() {
                cylinder(h=magnet_thickness, r=(magnet_diameter + wall_thickness_upper)/2, anchor=DOWN);
                cylinder(h=magnet_thickness, r=magnet_diameter/2, anchor=DOWN);
            }
        }

    }
}

// // 测试修正后的模块
// bolt_post(screw="m3", mode="self_tap", height=8, rib_height=6, rib_thickness=0.5);

magnet_holder(
    magnet_diameter = 6 + 0.3,
    magnet_thickness = 3,
    holder_height = 6,     // 稍高于磁铁，可以略高用于卡住或胶粘
    wall_thickness_upper = 1,
    wall_thickness_down = 2,
    pos = [0, 0, 0]       // 放在旁边，不重叠
);