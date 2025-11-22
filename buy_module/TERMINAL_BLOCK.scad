include <BOSL2/std.scad>

module TERMINAL_BLOCK_A() {
    size=[31, 12, 1.5];
    hole_diameter = 3;
    
    difference() {
        cuboid(size, anchor = BOTTOM+LEFT+FRONT);
        
        // 自动计算中心位置
        translate([9.3 + hole_diameter/2, size[1]/2, size[2]/2])
        cylinder(h = size[2] + 1, d = hole_diameter, center = true, $fn = 36);
    }
}

module TERMINAL_BLOCK_B() {
    size=[22, 8.15, 1.5]; hole_diameter = 3; hole_disstance = 14.2 + hole_diameter; hole_start = 1;
    
    difference() {
        cuboid(size, anchor = BOTTOM+LEFT+FRONT);
        
        // 一个洞
        translate([hole_start+ hole_diameter/2, size[1]/2, size[2]/2])
        cylinder(h = size[2] + 1, d = hole_diameter, center = true, $fn = 36);
        
        // 另外一个洞
        translate([hole_start + hole_disstance + hole_diameter/2, size[1]/2, size[2]/2])
            cylinder(h = size[2] + 1, d = hole_diameter, center = true, $fn = 36);
    }
}

module TERMINAL_BLOCK_C() {
    size=[25, 8.15, 1.5]; hole_diameter = 3; hole_disstance = 17.2 + hole_diameter; hole_start = 1;
    
    difference() {
        cuboid(size, anchor = BOTTOM+LEFT+FRONT);
        
        // 一个洞
        translate([hole_start+ hole_diameter/2, size[1]/2, size[2]/2])
        cylinder(h = size[2] + 1, d = hole_diameter, center = true, $fn = 36);
        
        // 另外一个洞
        translate([hole_start + hole_disstance + hole_diameter/2, size[1]/2, size[2]/2])
            cylinder(h = size[2] + 1, d = hole_diameter, center = true, $fn = 36);
    }
}

// 展示三个模块
translate([0, 0, 0]) {
    color("red", 0.8)  // 红色，80%不透明度
    TERMINAL_BLOCK_A();
}

translate([40, 0, 0]) {  // 向右移动40mm
    color("green", 0.8)  // 绿色
    TERMINAL_BLOCK_B();
}

translate([70, 0, 0]) {  // 再向右移动30mm
    color("blue", 0.8)   // 蓝色
    TERMINAL_BLOCK_C();
}

// 添加标签说明（可选）
translate([0, -5, 0]) linear_extrude(1) text("A", size=3);
translate([40, -5, 0]) linear_extrude(1) text("B", size=3);
translate([70, -5, 0]) linear_extrude(1) text("C", size=3);