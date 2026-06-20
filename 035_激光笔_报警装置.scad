
include <BOSL2/std.scad>
use <lib/bolt_post.scad>;
use <lib/lid.scad>;
use <lib/port.scad>;

$fn=600;




module clip(l, w, thick_out, thick_in, h_out, h_in){

    difference(){
        cuboid([l + thick_out*2, w + thick_out *2, h_out], anchor=[0, 0, -1]);
        cuboid([l-thick_in *2, w-thick_in*2, h_out], anchor=[0, 0, -1]);

        translate([0, 0, h_in])
            cuboid([l, w, h_out], anchor=[0, 0, -1]);

    }

}

module ESP(){
    
    esp32_c3_size = [51.5, 21.5, 3];

    difference(){

        // esp32-c3 安装口
        clip(esp32_c3_size[0], esp32_c3_size[1], thick_out=1, thick_in=1.5, h_out=10, h_in=5);
        
        // type c 接口
        translate([0, 0, 2])
            cuboid([100, 9.5, 50], anchor=[-1, 0, -1]);
    }  
}

module TP(){

    TP4056_size = [27, 17.5, 1];

    difference(){

        // TP4056 安装口
        clip(TP4056_size[0], TP4056_size[1], thick_out=1, thick_in=2, h_out=5, h_in=3);    
        
        // type c 接口
        translate([0, 0, 1.5])
            cuboid([100, 9.5, 50], anchor=[1, 0, -1]);
    }
}

module BA(){
    clip(70, 19, thick_out=1, thick_in=1, h_out=10, h_in=0);
}

module HOLE(){
    translate([35, 0, 0])
        difference(){
            cuboid([15, 10, 15], anchor=[0, 0, -1]);

            translate([0, 0, 10])
                rotate([0, 90, 0])
                    cylinder(r=5.5/2, h=30, center=true);
        }
}

module LIP(){
    length = 100;
    width = 50;
    wall_thickness =1;


    translate([0, 70, 0]){
    difference(){
        # lid(
            lid_size=[length + wall_thickness*2, width + wall_thickness * 2, 1.5],
            plug_thickness=1.5,
            plug_depth=1.5,
            wall_thickness=1,
            chamfer=0.5,
            // hand_direction="right",
            hand_direction="left",
            pos=[0, 0, 0]
            );
        
        translate([-30, 13, 0])
            cylinder(r=2.5/2, h=20);

        translate([40, -2, 0])
            cylinder(r=2.5/2, h=20);
        }
    }
}

module SWITCH(){
    // 开关
    clip(l=6.5, w=12.8, thick_out=0.5, thick_in=2, h_out=7, h_in=1);

}

module SHELL(){
    // 外壳

    wall_thickness = 1;

    length = 100;
    width = 50;

    height = 20;

    difference(){

        union(){
            translate([0, 0, -1]){
                difference(){
                    cuboid([length + wall_thickness *2, width + wall_thickness *2, height + wall_thickness * 1], anchor=[0, 0, -1]);
                    translate([0, 0, wall_thickness + 0.01])
                        cuboid([length, width, height], anchor=[0, 0, -1]);
                }
            }

            translate([-(length/2 -6.5/2), -(width/2 -12.8/2 -5), 0])
                SWITCH();
        }

        // 开关的两个洞
        translate([-(length/2 -6.5/2), -(width/2 -12.8/2 -5), 2.5])
            cuboid([length, 10.5, 4], anchor=[0, 0, -1]);

        translate([0, -(width/2 -12.8/2 -5), 2.5])
            cuboid([90, 10.5, 8], anchor=[0, 0, -1]);

        // 激光头的一个洞
        translate([50, 12, 10])
            rotate([0, 90, 0])
                cylinder(r=5/2, h=50, center=true);

        // type c
        translate([-(52/2 + 27/2 + 19), 10, 5])
            rotate([90, 0, 90])
                type_c_hole(offset=0.5, depth=30, pos=[0, 0, 0]);
    }

    boss(screw="m3", mode="self_tap", height=height - 3, rib_height= 10, rib_thickness=1, thick=2, pos=[-30, -13, 0]);
    boss(screw="m3", mode="self_tap", height=height - 3, rib_height= 10, rib_thickness=1, thick=2, pos=[40, 2, 0]);


}

module main(){

    SHELL();

    LIP();

    translate([15, 10, 0])
        union(){

            translate([-8, 2, 0])
            {
                ESP();
                HOLE();
            }

            translate([-(52/2 + 27/2 + 11), 0, 0])
                TP();

            translate([-5, -23, 0])
                BA();


        }
}

main();














