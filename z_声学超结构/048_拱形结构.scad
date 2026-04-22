include <BOSL2/std.scad>

$fn = 220;

module dome_shell(
    bottom_h    = 2.3,   // 底部平面厚度
    wall_t      = 2.0,   // 壁厚

    base_r      = 60,    // 底部外圈半径
    flat_r      = 48,    // 上表面起拱前的平缓区域半径

    dome_z      = 30,    // 顶部球心高度
    dome_r      = 55,    // 顶部球半径

    // 拱面过渡控制
    trans_z1    = 3,
    trans_r1    = 46,

    trans_z2    = 9,
    trans_r2    = 40,

    trans_z3    = 18,
    trans_r3    = 30,

    // 开孔参数
    hole_n      = 4,     // 总洞数
    hole_r      = 20,    // 主孔半径
    hole_z      = 32,    // 主孔中心高度
    hole_len    = 220,   // 开孔长度

    // 关键：孔下方缓慢连接参数
    foot_r_scale   = 1.45,  // 底部过渡体半径倍率
    foot_drop_scale= 1.15,  // 底部过渡体下沉倍率
    foot_z_scale   = 0.65   // Z向压扁倍率，越小越“摊”
) {

    // ================= 外壳 =================
    module outer_shape() {
        union() {
            // 底部平面
            cylinder(h = bottom_h, r = base_r);

            // 拱罩
            hull() {
                translate([0, 0, bottom_h])
                    cylinder(h = 0.1, r = flat_r);

                translate([0, 0, trans_z1])
                    cylinder(h = 0.1, r = trans_r1);

                translate([0, 0, trans_z2])
                    cylinder(h = 0.1, r = trans_r2);

                translate([0, 0, trans_z3])
                    cylinder(h = 0.1, r = trans_r3);

                translate([0, 0, dome_z])
                    sphere(r = dome_r);
            }
        }
    }

    // ================= 内腔 =================
    module inner_shape() {
        union() {
            // 内部底面
            translate([0, 0, wall_t])
                cylinder(h = max(bottom_h - wall_t, 0.1), r = base_r - wall_t);

            // 内部拱腔
            hull() {
                translate([0, 0, bottom_h])
                    cylinder(h = 0.1, r = flat_r - wall_t);

                translate([0, 0, trans_z1])
                    cylinder(h = 0.1, r = trans_r1 - wall_t);

                translate([0, 0, trans_z2])
                    cylinder(h = 0.1, r = trans_r2 - wall_t);

                translate([0, 0, trans_z3])
                    cylinder(h = 0.1, r = trans_r3 - wall_t);

                translate([0, 0, dome_z])
                    sphere(r = dome_r - wall_t);
            }
        }
    }

    // ================= 单个圆滑孔 =================
    // 这个模块是关键：
    // 不是单纯横向圆柱，而是“横向主孔 + 底部过渡鼓包”的 hull
    // 这样孔下方的腿部根部会自然变圆滑
    module soft_hole(r=20, len=220) {
        foot_r    = r * foot_r_scale;
        foot_drop = r * foot_drop_scale;

        hull() {
            // 主孔
            rotate([0, 90, 0])
                cylinder(h = len, r = r, center = true);

            // 底部过渡体：往下拖、并在Z方向压扁
            translate([0, 0, -foot_drop])
                scale([1.15, 1.0, foot_z_scale])
                    sphere(r = foot_r);
        }
    }

    // ================= 环向均匀打孔 =================
    module side_holes(n, r, z, len) {
        for (i = [0 : n - 1]) {
            rotate([0, 0, i * 360 / n])
                translate([0, 0, z])
                    soft_hole(r = r, len = len);
        }
    }

    // ================= 主体 =================
    difference() {
        outer_shape();
        inner_shape();
        side_holes(hole_n, hole_r, hole_z, hole_len);
    }
}

// ================= 调用 =================
dome_shell();