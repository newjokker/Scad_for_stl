
include <BOSL2/std.scad>
use <lib/battery_box.scad>;
use <lib/corner_clips.scad>;
include <lib/TERMINAL_BLOCK.scad>;
use <lib/port.scad>;


$fn = 60;
$show_chip = false;

offset = 0.2;
displat_length = 71;
displat_width = 24;
displat_height = 7.4;
displat_size = [displat_length + offset, displat_width + offset, displat_height];


size = [93, 43, 20];
angle = -115;

module display_A(size=[89, 43, 20]){

    translate([size[0]/2, -size[1]/2, 0])
    {
        // 显示器模块，旁边的一个三角形没显示出来，需要注意
        if ($show_chip){
            translate([0, 0, 0]) display(LCD1602A);
        }

        difference(){

            cuboid(size, anchor = [0,0,-1]);

            // 7.4 屏幕的厚度
            translate([0, 0, 7.4 ]) cuboid([85, 39, 100], anchor = [0,0,-1]);

            // 屏幕的长宽部分
            translate([0, 0, -0.01]) cuboid([displat_size[0] , displat_size[1], 100], anchor = [0,0,-1]);

            // 冒出来的杜邦线接口 2 是边框的厚度
            translate([13, 15, 2]) cuboid([42, 7, 100], anchor = [0,0,-1]);

            // 凸出来的背光板
            translate([-71.5/2 - 2, 0, 3]) cuboid([5, 14, 100], anchor = [0,0,-1]);

            // 螺丝孔
            r1 = 2.5;
            r2 = 1.4;
            display_out_length = 80;
            display_out_width = 36;
            height = 7;
            translate([-display_out_length/2 + r1 , -display_out_width/2 + r1 , 3]) cylinder(r=r2, h=height, anchor=[0, 0, -1]);
            translate([-display_out_length/2 + r1 , display_out_width/2 - r1 , 3]) cylinder(r=r2, h=height, anchor=[0, 0, -1]);
            translate([display_out_length/2 - r1 , display_out_width/2 - r1 , 3]) cylinder(r=r2, h=height, anchor=[0, 0, -1]);
            translate([display_out_length/2 - r1 , -display_out_width/2 + r1 , 3]) cylinder(r=r2, h=height, anchor=[0, 0, -1]);

        }
    }


}

module display_B() {

    height = size[1] * sin(abs(angle));
    display_size_b = [size[0], 40, height];

    // 盒子的主体
    difference() {

        translate([0, 0, 0]){
            wall_thick = 2;
            difference() {
                cuboid(size = [size[0], display_size_b[1], height], anchor=[-1, -1, -1]);
                translate([wall_thick, wall_thick, wall_thick]) cuboid(size = [size[0] - wall_thick * 2, display_size_b[1] - wall_thick * 2, height - 2 * wall_thick], anchor=[-1, -1, -1]);
            }
        }

        // 切割同样形状的立方体
        translate([0, (size[2] + display_size_b[1]) * sin(angle),  (size[2] + display_size_b[1]) * -cos(angle)])
        {
            rotate([angle, 0, 0])
            {
                translate([size[0]/2, -size[1]/2, 0])  cuboid(size = [size[0] + display_size_b[1], size[1] + display_size_b[1], size[2] + display_size_b[1]], anchor=[0, 0, -1]);
            }
        }

        // 顶盖
        // translate([-50, -72+0.01, height - 0.01])  cuboid(size = [200, 100, 4], anchor=[-1, -1, 0]);

        // typec 口
        translate([size[0]/2, display_size_b[1] + 0.5 + 0.01, 5]){
            rotate([90, 0, 0]){
                type_c_hole(offset=offset);
            }
        }
    }

    // 芯片支架
    translate([size[0]/2, display_size_b[1] -TP4056_size[0]/2 - 3.5, 0]){
        rotate([0, 0, 90]){
            four_corner_clips(chip_size=[TP4056_size[0], TP4056_size[1], 1], clip_thick=2);
        }
    }

    // %translate([-50, -30+0.01, height - 0.01])  cuboid(size = [200, 100, 4], anchor=[-1, -1, 0]);


}

module display_C() {

    cuboid(size=[size[0], 50, 2]);

}

module box(){
    translate([0, size[2] * sin(angle),  size[2] * -cos(angle)])
    {
        rotate([angle, 0, 0])
        {
            display_A(size=size);
        }
    }

    // 盒子
    display_B();

    // // 电池
    // translate([25, 21, 0]){
    //     rotate([0, 0, 90]) 
    //         Battery_box_18650();
    // }
}


box();

// display_B();






