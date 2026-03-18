include <BOSL2/std.scad>
$fn = 200;              // 圆形细分精度

// 定义主圆柱参数
cylinder_height = 20;
cylinder_diameter = 20;
cylinder_radius = cylinder_diameter / 2;
thick = 1;
air_thick = 5;      // 空气层厚度

// 定义小孔参数
hole_diameter = 1.5;      // 小孔直径
rows = 7;               // 纵向行数
columns_per_row = 12;   // 每行孔数
start_height_offset = 1; // 起始高度偏移（避免边缘）

// 创建内部多孔圆柱
difference() {
    // 主体圆柱
    cylinder(h = cylinder_height, d = cylinder_diameter, center = false);
    
    // 打孔
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
    
    // 挖空内部形成管状
    translate([0, 0, -0.01])
        cylinder(h = cylinder_height + 0.02, d = cylinder_diameter - thick, center = false);
}

// 创建外壁
difference() {  
    // 外壁主体
    cylinder(h = cylinder_height, d = cylinder_diameter + air_thick, center = false);
    
    // 挖空内部形成外管
    translate([0, 0, -0.01])
        cylinder(h = cylinder_height + 0.02, d = cylinder_diameter - thick + air_thick, center = false);
}

// 创建封顶 - 上部封顶（圆环形） 
translate([0, 0, cylinder_height]) {
    // 内孔封顶（圆环）
    difference() {
        cylinder(h = 2, d = cylinder_diameter, center = false);
        translate([0, 0, -0.01])
            cylinder(h = 2.02, d = cylinder_diameter - thick, center = false);
    }
    
    // 外壁封顶（圆环）
    difference() {
        cylinder(h = 2, d = cylinder_diameter + air_thick, center = false);
        translate([0, 0, -0.01])
            cylinder(h = 2.02, d = cylinder_diameter - thick, center = false);
    }
}

// 创建封顶 - 下部封顶（圆环形）
translate([0, 0, -2]) {
    // 内孔封顶（圆环）
    difference() {
        cylinder(h = 2, d = cylinder_diameter, center = false);
        translate([0, 0, -0.01])
            cylinder(h = 2.02, d = cylinder_diameter - thick, center = false);
    }
    
    // 外壁封顶（圆环）
    difference() {
        cylinder(h = 2, d = cylinder_diameter + air_thick, center = false);
        translate([0, 0, -0.01])
            cylinder(h = 2.02, d = cylinder_diameter - thick, center = false);
    }
}