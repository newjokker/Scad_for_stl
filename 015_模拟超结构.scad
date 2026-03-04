
$fn = 200;              // 圆形细分精度


height      = 49.65;    // 模型高度
d_out       = 99.3;
d_in        = 44;
wall_thick  = 2.5;      // 壁厚


// 螺旋带结构
module A(){

    turns   = 2;                    // 螺旋圈数
    // R       = 36;                   // 螺旋半径
    strip_w = (d_out - d_in)/2;     // 螺旋带宽度
    strip_t = wall_thick;           // 螺旋带厚度
    R       = (strip_w/2) + d_in/2;                   // 螺旋半径

    // 扭转挤出生成螺旋带
    linear_extrude(
        height = height,
        twist = -360 * turns,
        slices = 3000
    )
    translate([R, 0])
    square([strip_w, strip_t], center = true);
}


// 外壳结构
module B(){

    // 内侧圆环
    difference(){

        cylinder(h = height, d = d_in + wall_thick, center = false);

        translate([0, 0, -20])
            cylinder(h = height + 50, d = d_in, center = false);
    }

    // 外侧圆环
    difference(){

        cylinder(h = height, d = d_out,center = false);

        translate([0, 0, wall_thick])
            cylinder(h = height + 20, d =d_out-wall_thick, center = false);

        translate([0, 0, -20])
            cylinder(h = height + 50, d = d_in, center = false);
    }
}


// 四分之一圆环切割结构
module C(){

    intersection(){

        // 圆环
        translate([0,0,1])
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


// 用四分之一圆环切掉外壳一部分
difference(){

    B();

    C();
}

// 添加螺旋结构
A();

