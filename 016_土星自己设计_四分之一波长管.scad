

$fn = 200;              // 圆形细分精度


height      = 49.65;    // 模型高度
d_out       = 99.3;
d_in        = 44;
wall_thick  = 1;      // 壁厚
d_small     = 20;


module A(){
    color([1, 1, 0.5, 0.3]){
        difference(){
            cylinder(h = height, d = d_out, center = false);
            translate([0, 0, -0.1])
                cylinder(h = height + 0.2, d = d_in, center = false);
        }
    }
}

difference(){

    A();

    color([0.5, 0.5, 1]){

        r_0 = (d_out + d_in)/4;
        mini_0 = 0.02;

        translate([r_0, 0, -mini_0/2])
            // cylinder(h = 45.1 + mini_0, d = d_small, center = false);
            cylinder(h = 35.5 + mini_0, d = d_small, center = false);

        translate([-r_0, 0, -mini_0/2])
            // cylinder(h = 43.5 + mini_0, d = d_small, center = false);
            cylinder(h = 35.5 + mini_0, d = d_small, center = false);

        translate([0, r_0, -mini_0/2])
            // cylinder(h = 41.9 + mini_0, d = d_small, center = false);
            cylinder(h = 35.5 + mini_0, d = d_small, center = false);

        translate([0, -r_0, -mini_0/2])
            // cylinder(h = 40.5 + mini_0, d = d_small, center = false);
            cylinder(h = 35.5 + mini_0, d = d_small, center = false);

        translate([r_0/sqrt(2), r_0/sqrt(2), -mini_0/2])
            // cylinder(h = 39.1 + mini_0, d = d_small, center = false);
            cylinder(h = 35.5 + mini_0, d = d_small, center = false);

        translate([r_0/sqrt(2), -r_0/sqrt(2), -mini_0/2])
            // cylinder(h = 37.9 + mini_0, d = d_small, center = false);
            cylinder(h = 35.5 + mini_0, d = d_small, center = false);

        translate([-r_0/sqrt(2), r_0/sqrt(2), -mini_0/2])
            // cylinder(h = 36.6 + mini_0, d = d_small, center = false);
            cylinder(h = 35.5 + mini_0, d = d_small, center = false);

        translate([-r_0/sqrt(2), -r_0/sqrt(2), -mini_0/2])
            cylinder(h = 35.5 + mini_0, d = d_small, center = false);

    }
}









