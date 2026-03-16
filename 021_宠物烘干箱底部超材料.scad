
include <BOSL2/std.scad>
use <del.scad>


$fn = 200;              // 圆形细分精度

thick = 1.5;
brick_w = 67.3 - thick;
brick_h = 12 - thick;
brick_l = 80 - thick;
d_1 = 14.3;
d_2 = 18;
dh_scale = 0.6;
d_hollow = 99.3 * dh_scale;      // 出气孔的大小
// cuboid([brick_w * 5, thick, brick_h], ancho



// r = [0,0,-1]);

// translate([0, brick_w, 0])
//     cuboid([brick_w * 5, thick, brick_h], anchor = [0,0,-1]);

// rotate([0, 0, 90])
//     cuboid([brick_w * 5, thick, brick_h], anchor = [0,0,-1]);

// translate([brick_l, 0, 0])
//     rotate([0, 0, 90])
//         cuboid([brick_w * 5, thick, brick_h], anchor = [0,0,-1]);


module A(){
    color("red"){
        translate([0, (brick_w/2 + thick/2), 0])
            cuboid([brick_w * 2, thick, brick_h], anchor = [0,0,-1]);

        translate([0, -(brick_w/2 + thick/2), 0])
            cuboid([brick_w * 2, thick, brick_h], anchor = [0,0,-1]);

        translate([-(brick_l/2 + thick/2), 0, 0])
            cuboid([thick, brick_w * 2, brick_h], anchor = [0,0,-1]);

        translate([(brick_l/2 + thick/2), 0, 0])
            cuboid([thick, brick_w * 2, brick_h], anchor = [0,0,-1]);

        translate([(brick_l/2 + thick/2), (brick_w/2 + thick/2), 0])
            cylinder(h = brick_h, d = d_2, center = false);
        
        translate([-(brick_l/2 + thick/2), (brick_w/2 + thick/2), 0])
            cylinder(h = brick_h, d = d_2, center = false);
        
        translate([(brick_l/2 + thick/2), -(brick_w/2 + thick/2), 0])
            cylinder(h = brick_h, d = d_2, center = false);
        
        translate([-(brick_l/2 + thick/2), -(brick_w/2 + thick/2), 0])
            cylinder(h = brick_h, d = d_2, center = false);

    }
}

module B(){

    difference(){
        cuboid([brick_l, brick_w, brick_h], anchor = [0,0,-1]);

        cylinder(h = brick_h, d = d_hollow, center = false);
    }
}

module C(){

    // 共振频率为 1080Hz，管径 d 为 10mm，管长为 76.4 mm
    // 共振频率为 1080Hz，管径 d 为 50mm，管长为 64.4 mm

    h_1_4 = 5;
    d_1_4 = 10;

    translate([d_hollow/2 + 7, -13, 0])
        cylinder(h = h_1_4, d = d_1_4, center = false);
    translate([d_hollow/2 + 7, 13, 0])
        cylinder(h = h_1_4, d = d_1_4, center = false);
    translate([d_hollow/2 + 7, 0, 0])
        cylinder(h = h_1_4, d = d_1_4, center = false);
    translate([-(d_hollow/2 + 7), -13, 0])
        cylinder(h = h_1_4, d = d_1_4, center = false);
    translate([-(d_hollow/2 + 7), 13, 0])
        cylinder(h = h_1_4, d = d_1_4, center = false);
    translate([-(d_hollow/2 + 7), 0, 0])
        cylinder(h = h_1_4, d = d_1_4, center = false);

}

module Helm_in(){

    a = 12;                 // 腔体内长 mm
    b = 12;                 // 腔体内宽 mm
    c = 12;                 // 腔体内高 mm

    h = 10;                  // neck length mm
    r = 1.8;                  // neck radius mm
    thick = 0.5;            // 壁厚 mm


    cuboid([a, b, c], anchor = [0,0,1]);
    cylinder(h = h + thick + 0.02, d = 2 * r, center = false);
    
}

difference(){
    B();
    A();
    // C();
}

scale([0.6, 0.6, 0.6]){
    DoubleHelix();
    // std_module();
}
