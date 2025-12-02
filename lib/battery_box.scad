

use <simple_box.scad>;
use <port.scad>;
include <BOSL2/std.scad>;


module Battery_18650(pos){
    // 18650 电池
    d = 18.15;
    height = 65;

    translate(pos)
        translate([0, 0, d/2])
            rotate([0, 90, 0])
                cylinder(r=d/2, h=height, anchor=[0,0,0]);
}

module BatteryLevelIndicator(pos=[0,0,0]){
    // 电池电量指示灯
    
    width = 9.5;
    height = 5;
    thick = 2;

    led_width = 6;      // 4 个 显示的 led 灯的宽度 和 高度 
    led_height = 1.9;    // 

    translate(pos){
        translate([-width/2, -height/2, 0]){
            union(){
                cuboid([width, height, thick], anchor=[-1,-1,-1]);
                translate([width/2, height/2, -0.01]){
                    cuboid([width - 2, led_height, thick + 5], anchor=[0,0,0]);
                }
            }
        }
    } 
} 

module A(){

    wall_thickness = 2;
    battery_width = 19 + 2*wall_thickness;
    battery_length = 73 + 2*wall_thickness;
    battery_height = 1.5 + 16.5;

    translate([battery_length/2, battery_width/2, 0])
        simple_box(
            box_size=[battery_length, battery_width, battery_height], 
            wall_thickness=2, 
            chamfer=0);
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
    {
        difference(){
            {
                // 支撑
                C();
                
                // 开孔
                translate([-1, 1.5, 1.5])
                    rotate([0, 90, 0])
                        wire_hole(d=1.5, depth=5);
                
                translate([-1, battery_width -1.5 - 2 * wall_thickness, 1.5])
                    rotate([0, 90, 0])
                        wire_hole(d=1.5, depth=5);
            }
        }
    }

    translate([battery_length - wall_thickness- 0.7 - 0.8 - 13.5 -1.5, wall_thickness, wall_thickness])
    {
        difference(){
            {
                // 支撑
                C();
                
                // 开孔
                translate([-1, 1.5, 1.5])
                    rotate([0, 90, 0])
                        wire_hole(d=1.5, depth=5);
                
                translate([-1, battery_width -1.5 - 2 * wall_thickness, 1.5])
                    rotate([0, 90, 0])
                        wire_hole(d=1.5, depth=5);
            }
        }
    }

    if($show_chip){
        color("red") #
            Battery_18650(pos = [38, 18.15/2 + 0.5 + 2, 1.5]);
    }

}

module Battery_box_base_18650(pos=[0,0,0]){
    translate(pos){
        battery_box();
    }
}

module Battery_box_18650(pos=[0,0,0]){
    // 电池部分
    difference(){
        Battery_box_base_18650(pos=[0,  0, 0]);

        // 电线孔
        translate([6, 3, 2 + 5])
            rotate([90,0,0])
                wire_hole(d=3, depth=6, pos=[0, 0, 0]);

        translate([13, 3, 2 + 5])
            rotate([90,0,0])
                wire_hole(d=3, depth=6, pos=[0, 0, 0]);

        // 开关孔
        translate([-3, 0, 1])
        {
            // 开关主体
            color("red") #
            if($show_chip)
            {
                translate([10, 24, 2])
                    rotate([90,0,0]){
                        cuboid([6, 3.7, 5], anchor=[-1,-1,-1]);
                    }
            }

            // 两个引脚线孔
            translate([9, 24, 3])
                rotate([90,0,0]){
                    cylinder(r=1, h=5, anchor=[-1,-1,-1]);
                }

            translate([15.5, 24, 3])
                rotate([90,0,0]){
                    cylinder(r=1, h=5, anchor=[-1,-1,-1]);
                }
        }

        // 电量显示孔
        // color("red")
        translate([39, 22, 4.8])
            rotate([90,0,0])
                BatteryLevelIndicator(pos=[0,0,0]);

    }
}
