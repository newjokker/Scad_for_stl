

use <simple_box.scad>;
include <BOSL2/std.scad>;

$fn=60;

module A(){

    wall_thickness = 2;
    battery_width = 19 + 2*wall_thickness;
    battery_length = 73 + 2*wall_thickness;
    battery_height = 1.5 + 16.5;

    translate([battery_length/2, battery_width/2, 0])
        simple_box(
            box_size=[battery_length, battery_width, battery_height], 
            wall_thickness=2, 
            chamfer=0.2);
}

module B(){

    wall_thickness = 2;
    battery_width = 19 + 2*wall_thickness;
    battery_length = 73 + 2*wall_thickness;
    battery_height = 1.5 + 16.5;

    difference(){
        cuboid([0.8, battery_width - 2*wall_thickness + 0.02, battery_height], anchor=[-1, -1, -1]);
        
        translate([-0.01, 4.25, -0.01])
            cuboid([0.8 + 0.02, 10.5 + 0.02, battery_height + 0.02], anchor=[-1, -1, -1]);
        
        translate([-0.01, 0.5, 9 + 2.9/2])
            cuboid([0.8 + 0.02, 2.5, 2.9], anchor=[-1,-1,-1]);

        translate([-0.01, battery_width - 2*wall_thickness - 0.5 - 2.5, 9 + 2.9/2])
            cuboid([0.8 + 0.02, 2.5, 2.9], anchor=[-1,-1,-1]);
    }
}

module C(){

    difference() {
        cuboid([1.5, 19, 18/2], anchor=[-1,-1,-1]);

        r = 19.5/2;   // 切割圆的半径
        translate([-0.01, 19/2, r])
            rotate([0, 90, 0])
                cylinder(r=r, h=2); 
    }
}

module battery_box(){

    wall_thickness = 2;
    battery_width = 19 + 2*wall_thickness;
    battery_length = 73 + 2*wall_thickness;
    battery_height = 1.5 + 16.5;

    // 边框和对应的孔
    difference(){
        A();
        // 电池的插孔
        translate([wall_thickness, wall_thickness + 6.750, -0.01])
            cuboid([0.7 + 0.02, 5.5, 2 + 0.02], anchor=[-1,-1,-1]);

        translate([battery_length-wall_thickness-0.7, wall_thickness + 6.750, -0.01])
            cuboid([0.7 + 0.02, 5.5, 2 + 0.02], anchor=[-1,-1,- 1]);
    }

    // 两个插板
    translate([wall_thickness + 0.7, wall_thickness+0.01, 0])
        B();

    translate([battery_length - wall_thickness - 0.7 - 0.8, wall_thickness+0.01, 0])
        B();

    // 支撑部分
    translate([wall_thickness + 0.7 + 0.8 + 13.5, wall_thickness, wall_thickness])
        C();

    translate([battery_length - wall_thickness- 0.7 - 0.8 - 13.5 -1.5, wall_thickness, wall_thickness])
        C();
}

