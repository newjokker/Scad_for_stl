include <BOSL2/std.scad>

$fn = 64;

// ========= 参数 =========
tube_w   = 210;   // 方管宽
tube_d   = 70;    // 方管深（挤出方向）
tube_h   = 50;    // 方管高

clearance = 0;    // 间隙

wall      = 6;    // 壁厚（够用了）
raise_h   = 180;  // 抬高高度

base_thick = 8;   // 底板厚


// ========= 上部 U 托 =========
module top_holder() {
    inner_w = tube_w + clearance*2;
    inner_h = tube_h + clearance;

    outer_w = inner_w + wall*2;
    outer_h = inner_h + wall;

    difference() {
        // 外壳
        translate([0,0,outer_h/2])
            cuboid([outer_w, tube_d, outer_h], anchor=CENTER);

        // 挖空
        translate([0,0,wall + inner_h/2])
            cuboid([inner_w, tube_d+1, inner_h+1], anchor=CENTER);
    }
}


// ========= 支腿 =========
module legs() {
    leg_w = wall;

    // 左
    translate([
        -(tube_w/2 + wall/2),
        0,
        base_thick + raise_h/2
    ])
        cuboid([leg_w, tube_d, raise_h], anchor=CENTER);

    // 右
    translate([
        (tube_w/2 + wall/2),
        0,
        base_thick + raise_h/2
    ])
        cuboid([leg_w, tube_d, raise_h], anchor=CENTER);
}


// ========= 底板 =========
module base_plate() {
    base_w = tube_w + 60;
    base_d = tube_d + 20;

    cuboid([base_w, base_d, base_thick], anchor=CENTER);
}


// ========= 组合 =========
union() {

    // 底板
    translate([0,0,base_thick/2])
        base_plate();

    // 支腿
    legs();

    // 上托
    translate([0,0,base_thick + raise_h])
        top_holder();
}