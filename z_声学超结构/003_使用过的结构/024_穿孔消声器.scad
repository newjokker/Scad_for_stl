include <BOSL2/std.scad>
include <BOSL2/structs.scad>

$fn = 64;  // 优化性能

// 核心参数
thick = 1;
cylinder_height = 50 - 2*thick;
cylinder_diameter = 70;
air_thick = (99.3 - cylinder_diameter - thick)/2;
cylinder_radius = cylinder_diameter / 2;

// 赫姆霍兹共振腔参数
hole_diameter = 2;
neck_length = thick;  // 孔道长度等于壁厚
cavity_volume_factor = 0.8;  // 蜂窝单元占空比

// 蜂窝结构参数
honeycomb_radius = 3;  // 正六边形内切圆半径
honeycomb_wall_thickness = 0.8;
honeycomb_vertical = 5;  // 垂直分层数

// 生成正六边形
module hexagon(r, h) {
    linear_extrude(height = h)
    polygon([
        for(i=[0:5]) [r*cos(60*i), r*sin(60*i)]
    ]);
}

// 蜂窝单元（带赫姆霍兹共振孔）
module honeycomb_resonator_unit(r, h, has_hole=true) {
    difference() {
        // 正六边形主体
        hexagon(r, h);
        
        if(has_hole) {
            // 赫姆霍兹孔
            translate([0, 0, h/2])
            cylinder(d=hole_diameter, h=neck_length*2, center=true);
            
            // 内部空腔（计算谐振频率）
            translate([0, 0, neck_length])
            cylinder(d=r*1.5, h=h-neck_length*2);
        } else {
            // 实心单元
            translate([0, 0, h/2])
            cylinder(d=r*0.7, h=h, center=true);
        }
    }
}

// 生成蜂窝网格
module honeycomb_grid(width, depth, height) {
    r = honeycomb_radius;
    spacing_x = r * 1.732;  // 六边形水平间距
    spacing_y = r * 1.5;
    
    for(x = [0:spacing_x:width]) {
        for(y = [0:spacing_y:depth]) {
            x_offset = (y % (spacing_y*2) > spacing_y) ? spacing_x/2 : 0;
            
            if(x + x_offset < width && y < depth) {
                translate([x + x_offset, y, 0]) 
                honeycomb_resonator_unit(
                    r - honeycomb_wall_thickness/2, 
                    height,
                    true
                );
            }
        }
    }
}

// 主结构
difference() {
    union() {
        // 外层壳体
        cylinder(h=cylinder_height, d=cylinder_diameter + air_thick*2 + thick*2);
        
        // 上下封盖
        for(z = [-thick, cylinder_height])
        translate([0, 0, z])
        cylinder(h=thick, d=cylinder_diameter + air_thick*2 + thick*2);
    }
    
    // 挖空内腔
    translate([0, 0, -0.1])
    cylinder(h=cylinder_height+0.2, d=cylinder_diameter + air_thick*2);
    
    // 挖空中心通道
    translate([0, 0, -0.1])
    cylinder(h=cylinder_height+0.2, d=cylinder_diameter);
}

// 填充蜂窝结构
translate([0, 0, thick]) {
    // 创建环形蜂窝填充
    intersection() {
        // 限制在环形区域
        difference() {
            cylinder(h=cylinder_height-2*thick, d=cylinder_diameter + air_thick*2 - 0.1);
            cylinder(h=cylinder_height-2*thick+0.2, d=cylinder_diameter + 0.1);
        }
        
        // 旋转展开的蜂窝层
        for(i = [0:honeycomb_vertical-1]) {
            z = i * (cylinder_height-2*thick) / honeycomb_vertical;
            linear_extrude(height=(cylinder_height-2*thick)/honeycomb_vertical)
            rotate_extrude()
            translate([cylinder_radius + air_thick/2, 0])
            honeycomb_grid(
                width=air_thick, 
                depth=PI*(cylinder_radius+air_thick), 
                height=1
            );
        }
    }
}