

include <BOSL2/std.scad>
include <BOSL2/std.scad>
include <BOSL2/joiners.scad>


$fn = 148;

// 总宽度 450 mm，单面玻璃的厚度 8mm

module A() {
    thick = 3;
    thick_glass = 8 + 0.2;
    width = 150;
    height = 40;
    height_end = 10;

    difference() {
        union(){
            translate([0, 0, height_end]) 
                difference() {
                    cuboid([width, thick_glass + thick *2, height], anchor=[0, 0, -1]);
                    translate([0, 0, thick]) 
                        cuboid([width + 0.1, thick_glass, height + 0.1], anchor=[0, 0, -1]);
                }

            cuboid([width, thick_glass + thick *2, height_end], anchor=[0, 0, -1]);
        }

        // 
        translate([30, 0, 0]) 
            cuboid([25, 5, 100], anchor=[0, 0, 0]);

        translate([-30, 0, 0]) 
            cuboid([25, 5, 100], anchor=[0, 0, 0]);

    }

}

A();














