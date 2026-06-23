
include <BOSL2/std.scad>

$fn = 200;              // 圆形细分精度


height      = 49.65;    // 模型高度
d_out       = 99.3;
d_in        = 44;
wall_thick  = 1;      // 壁厚
d_small     = 20;


// 外壳结构
module B(){

    // 内侧圆环
    difference(){

        union(){
            cylinder(h = height, d = d_in + wall_thick, center = false);
        
            // 竖过来的隔板
            cuboid([d_out, 1, height], anchor = [0,0,-1]);

            rotate(45) {
            cuboid([d_out, 1, height], anchor = [0,0,-1]); 
            }

            rotate(-45) {
            cuboid([d_out, 1, height], anchor = [0,0,-1]); 
            }

            rotate(90) {
            cuboid([d_out, 1, height], anchor = [0,0,-1]); 
            }

            // 横过来的隔板
            translate([0, 0, height/3])
                cylinder(h = 1, d = d_out, center = false);

            translate([0, 0, 2 * height/3])
                cylinder(h = 1, d = d_out, center = false);
        
        }

        translate([0, 0, -20])
            cylinder(h = height + 50, d = d_in, center = false);
    }


    // // 外侧圆环
    // difference(){
    //     cylinder(h = height, d = d_out,center = false);

    //     translate([0, 0, -1])
    //         cylinder(h = height + 20, d =d_out-wall_thick, center = false);
    // }

    // 外侧圆环
    difference(){
        cylinder(h = height, d = d_in + (d_out - d_in)/3 ,center = false);

        translate([0, 0, -1])
            cylinder(h = height + 20, d =d_in, center = false);
    }

    // 小孔
    rotate([90, 0, 90])
        cylinder(h = height + 20, d = 5 ,center = true);



}






B();