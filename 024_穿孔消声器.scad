include <BOSL2/std.scad>
$fn = 200;              // 圆形细分精度

// 定义主圆柱参数
cylinder_height = 20;
cylinder_diameter = 10;
cylinder_radius = cylinder_diameter / 2;

thick = 1;

// 定义小孔参数
hole_diameter = 2;      // 小孔直径
rows = 5;               // 纵向行数
columns_per_row = 8;   // 每行孔数
start_height_offset = 2; // 起始高度偏移（避免边缘）

// 创建主圆柱
difference() {
    
    cylinder(h = cylinder_height, d = cylinder_diameter, center = false);
    
    translate([0, 0, -0.01])
        cylinder(h = cylinder_height + 0.02, d = cylinder_diameter -thick, center = false);
    
    // 在圆柱表面打孔
    for (row = [0:rows-1]) {
        z = start_height_offset + (row * (cylinder_height - 2*start_height_offset) / (rows-1));
        
        for (col = [0:columns_per_row-1]) {
            angle = 360 * col / columns_per_row;
            x = cylinder_radius * cos(angle);
            y = cylinder_radius * sin(angle);
            
            // 在每个计算位置创建小孔
            translate([x, y, z])
            rotate([0, 90, angle])
            cylinder(h = cylinder_radius*2, d = hole_diameter, center = true);
        }
    }
}


// 外壁
difference() {  
    cylinder(h = cylinder_height, d = cylinder_diameter + 5, center = false);

    translate([0, 0, -0.01])
        cylinder(h = cylinder_height + 0.02, d = cylinder_diameter -thick + 5, center = false);
}


