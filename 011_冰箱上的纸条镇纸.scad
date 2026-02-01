include <BOSL2/std.scad>

$fn = 60;

L = 150;
W = 15;
H = 8;
R = 3.1;
magnet_height = 2.1;

// 自定义磁铁数量
magnet_count = 8; 

difference() {
    color("lightblue") {
        cuboid([L, W, H], anchor=[-1, -1, -1]);
    }
    
    if (magnet_count > 0) {
        spacing = L / (magnet_count + 1);
        
        // 均匀分布磁铁孔
        for (i = [1 : magnet_count]) {
            x_position = i * spacing;
            
            translate([x_position, W/2, -0.1])
                cylinder(r=R, h=magnet_height, anchor=DOWN);
        }
    }
}