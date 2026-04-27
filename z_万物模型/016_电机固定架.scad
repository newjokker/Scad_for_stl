include <BOSL2/std.scad>

$fn = 80;

// -------- 电机尺寸 --------
motor_len   = 42.5;
motor_w     = 20;
motor_w_2   = 15;
thick       = 2;


// ===== 外形函数 =====
module motor_shape(motor_w, motor_w_2, motor_len) {
    difference(){
        // 圆柱
        cylinder(r = motor_w/2, h = motor_len);

        // 两侧削平
        translate([motor_w_2/2, 0, 0])
            cuboid([motor_w, motor_w, motor_len], anchor=[-1,0,-1]);

        translate([-motor_w_2/2, 0, 0])
            cuboid([motor_w, motor_w, motor_len], anchor=[1,0,-1]);
    }
}


// ===== 壳体 =====
difference(){
    motor_shape(motor_w + thick, motor_w_2 + thick, motor_len);           // 外壳
    motor_shape(motor_w, motor_w_2, motor_len);      // 内缩
}