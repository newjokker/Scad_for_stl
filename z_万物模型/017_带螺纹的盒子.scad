include <BOSL2/std.scad>
include <BOSL2/threading.scad>

$fn = 200;

// ========== 参数配置区 ==========
thread_diameter = 35;      // 螺纹公称直径（mm）
thread_length = 40;        // 螺纹长度（mm）
thread_pitch = 2;          // 螺距（mm）
clearance = 0.4;          // 配合间隙（mm）- 3D打印建议0.2-0.4mm

// 外螺母/外壳尺寸
nut_outer_diameter = 40;   // 螺母外径（mm）
nut_height = 40;           // 螺母高度（mm）
nut_buttom_thick = 5;        // 螺母底部厚度（mm）- 3D打印建议3mm以上，确保强度

// ========== 外螺纹零件 ==========
module external_thread() {
    trapezoidal_threaded_rod(
        d = thread_diameter,
        l = thread_length,
        pitch = thread_pitch,
        anchor = [0, 0, -1]
    );

    cylinder(d = nut_outer_diameter, h = 20);
}

// ========== 内螺纹零件（带外壳） ==========
module internal_thread_nut(nut_buttom_thick=5) {
    difference() {
        cylinder(d = nut_outer_diameter, h = nut_height);
        translate([0, 0, nut_buttom_thick])  // 微调位置，避免布尔运算问题
            trapezoidal_threaded_rod(
                d = thread_diameter + clearance,  // 关键：加上间隙
                l = nut_height,
                pitch = thread_pitch,
                internal = true,
                anchor = [0, 0, -1]
            );
    }
}

// ========== 装配演示 ==========

// 方案1：分开展示（左右排列）
translate([-35, 0, 0])
    external_thread();

translate([35, 0, 0])
    internal_thread_nut();

