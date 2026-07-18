

include <BOSL2/std.scad>
include <BOSL2/std.scad>
include <BOSL2/joiners.scad>


$fn = 148;

// 总宽度 450 mm，单面玻璃的厚度 8mm

module A() {
    thick = 4;              // 边缘的厚度
    thick_glass = 8 + 0.2;  // 鱼缸玻璃的厚度
    width = 140;      // 
    height = 35;     // 卡住的边的高度
    height_end = 15; // 底部留下来的高度

    length_1 = 97.5/2; // 两块板子距离中心的距离 
    length_2 = 5; // 螺丝间距
    length_3 = height_end/2; // 螺丝脱离底面的距离
    hole_d = 3.5; // 通孔的直径 

    b_thick = 5.2; // 插入的板子的厚度


    difference() {
        union(){
            translate([0, 0, height_end]) 
                difference() {
                    cuboid([width, thick_glass + thick *2, height], anchor=[0, 0, -1]);
                    translate([0, 0, 0]) 
                        cuboid([width + 0.1, thick_glass, height + 0.1], anchor=[0, 0, -1]);
                }

            cuboid([width, thick_glass + thick *2, height_end], anchor=[0, 0, -1]);
        }

        // 穿过去的板子
        translate([length_1, 0, 0]) 
            cuboid([25, b_thick, 100], anchor=[0, 0, 0]);

        translate([-length_1, 0, 0]) 
            cuboid([25, b_thick, 100], anchor=[0, 0, 0]);

        // 螺丝孔
        translate([length_1 + length_2, 0, length_3]) 
            rotate([90, 0, 0])
                cylinder(h = 100, r = hole_d/2, center=true);

        translate([length_1 - length_2, 0, length_3]) 
            rotate([90, 0, 0])
                cylinder(h = 100, r = hole_d/2, center=true);
        
        translate([-(length_1 + length_2), 0, length_3]) 
            rotate([90, 0, 0])
                cylinder(h = 100, r = hole_d/2, center=true);

        translate([-(length_1 - length_2), 0, length_3]) 
            rotate([90, 0, 0])
                cylinder(h = 100, r = hole_d/2, center=true);


    }

}

A();














