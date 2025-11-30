
use <lib/simple_box.scad>;
include <BOSL2/std.scad>;

$fn=24;

wall_thickness = 2;
battery_width = 19 + 2*wall_thickness;
battery_length = 73 + 2*wall_thickness;
battery_height = 1.5 + 16.5;

module A(){
    translate([battery_length/2, battery_width/2, 0])
        simple_box(
            box_size=[battery_length, battery_width, battery_height], 
            wall_thickness=2, 
            chamfer=0.5);
}

A();

// 先在其他地方画出中间的挡板，再去组装到盒子里面
translate([wall_thickness + 0.7, wall_thickness+0.01, 0])
    color("red")
        difference(){
            cuboid([0.8, battery_width - 2*wall_thickness + 0.02, battery_height], anchor=[-1, -1, -1]);
            
            translate([-0.01, 4.25, 0])
                cuboid([0.8 + 0.02, 10.5 + 0.02, battery_height + 0.01], anchor=[-1, -1, -1]);
            
            translate([-0.01, 0.5, 9 + 2.9/2])
                cuboid([0.8  + 1 + 0.02, 2.5, 2.9], anchor=[-1,-1,-1]);
            
            translate([-0.01, 0.5, 9 + 2.9/2])
                cuboid([0.8  + 1 + 0.02, 2.5, 2.9], anchor=[-1,-1,-1]);
        }


