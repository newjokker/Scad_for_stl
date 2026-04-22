include <BOSL2/std.scad>

$fn = 220;

// ================= 参数 =================
bottom_h = 2.3;   // 底部起始高度
wall_t   = 2.0;   // 壁厚

dome_z = 30;      // 鼓包球中心高度
dome_r = 55;      // 鼓包球半径
base_r = 60;      // 底部连接半径

hole_n   = 4;     // 总洞数
hole_r   = 20;    // 洞半径
hole_z   = 32;    // 洞中心高度
hole_len = 220;   // 打孔圆柱长度

// ================= 外壳 =================
module outer_shape() {
    hull() {
        translate([0, 0, -bottom_h])
            cylinder(h = 0.1, r = base_r);

        translate([0, 0, dome_z])
            sphere(r = dome_r);
    }
}

// ================= 内腔 =================
module inner_shape() {
    hull() {
        translate([0, 0, -bottom_h + wall_t])
            cylinder(h = 0.1, r = base_r - wall_t);

        translate([0, 0, dome_z])
            sphere(r = dome_r - wall_t);
    }
}

// ================= 环向均匀打孔 =================
module side_holes(n, r, z, len) {
    for (i = [0 : n - 1]) {
        rotate([0, 0, i * 360 / n])
            translate([0, 0, z])
                rotate([0, 90, 0])
                    cylinder(h = len, r = r, center = true);
    }
}

// ================= 主体 =================
difference() {
    outer_shape();
    inner_shape();

    // 底部切平到 z=0 以下
    translate([0, 0, 0])
        cuboid([200, 200, 200], anchor = [0, 0, 1]);

    side_holes(hole_n, hole_r, hole_z, hole_len);
}