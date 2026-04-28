include <BOSL2/std.scad>
include <BOSL2/joiners.scad>

$fn = 72;

// ===== 参数 =====
plate_x = 20;
plate_y = 35;
thick   = 3;

joint_l    = 28;   // 连接件长度
joint_w    = 8;    // 连接件宽度
joint_base = 8;    // 底座长度
joint_ang  = 30;   // 倒扣角度

slop = 35;       // 打印间隙


// ===== 公件 =====
module male_part() {
    union() {
        cuboid([plate_x, plate_y, thick], anchor=BOTTOM);

        translate([0, 0, thick])
            joiner(
                l = joint_l,
                w = joint_w,
                base = joint_base,
                ang = joint_ang,
                anchor = BOTTOM,
                $slop = 0
            );
    }
}


// ===== 母件 =====
module female_part() {
    difference() {
        cuboid([plate_x, plate_y, thick], anchor=BOTTOM);

        translate([0, 0, thick - 0.1])
            joiner_clear(
                l = joint_l,
                w = joint_w,
                ang = joint_ang,
                anchor = BOTTOM,
                $slop = slop
            );
    }
}


// ===== 分开展示 =====
translate([-40, 0, 0])
    male_part();

