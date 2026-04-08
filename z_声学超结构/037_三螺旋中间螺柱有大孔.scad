
include <BOSL2/std.scad>

$fn = 200;              // 圆形细分精度


height      = 40;    // 模型高度
d_out       = 87 * 2;
d_in        = 25 * 2;
wall_thick  = 2.5;      // 壁厚


// 螺旋带结构
module A(){

    difference(){
        union(){
            turns   = 1 + 2/5;                    // 螺旋圈数
            // R       = 36;                   // 螺旋半径
            strip_w = (d_out - d_in)/2;     // 螺旋带宽度
            strip_t = wall_thick * 3;           // 螺旋带厚度
            R       = (strip_w/2) + d_in/2;                   // 螺旋半径

            // 扭转挤出生成螺旋带
            linear_extrude(height = height, twist = -360 * turns, slices = 300)
            translate([R, 0])
            square([strip_w, strip_t], center = true);
        }

        // 切掉圆环延伸出来的部分
        rotate(55)
            translate([0, 0, height])
                cuboid([10, 200, 10], anchor = [0,0,0]);
    }


}

// 外壳结构
module B(){

    // // 内侧圆环
    // difference(){

    //     // cylinder(h = height, d = d_in + wall_thick, center = false);
    //     cylinder(h = height, d = d_in + 0.4, center = false);

    //     translate([0, 0, -20])
    //         cylinder(h = height + 50, d = d_in, center = false);
    // }

    // 外侧圆环
    difference(){

        cylinder(h = height, d = d_out,center = false);

        // translate([0, 0, wall_thick])
        translate([0, 0, -1])
            cylinder(h = height + 20, d =d_out-wall_thick, center = false);

        translate([0, 0, -20])
            cylinder(h = height + 50, d = d_in, center = false);
    }
}

// 四分之一圆环切割结构
module C(){

    intersection(){

        // 圆环
        translate([0, 0, wall_thick])
        difference(){

            cylinder(h = 3,d = d_in + 10,center = false);

            translate([0,0,-2])
                cylinder(h = 10, d = d_in -10, center = false);
        }

        // 使用方块裁剪为 1/4
        rotate([0, 0, -25])
            translate([0, 0, -10])
                cube([50, 50, 30]);
    }

}

module DoubleHelix(){
    // 双螺旋
    A();

    rotate(180){
        A();
    }
    B();
}


// 三螺旋
A();

rotate(120){
    A();
}

rotate(240){
    A();
}


B();
