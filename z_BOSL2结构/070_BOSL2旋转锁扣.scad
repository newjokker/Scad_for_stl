include <BOSL2/std.scad>

// 3D 打印常用旋转锁扣结构。
// 通过旋转锁舌锁紧两零件，适合需要快速锁定且防震的场合。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 64;
// 打印配合间隙
$slop = 0.15;

// 锁扣直径，单位 mm
lock_diam = 30;
// 锁扣厚度，单位 mm
lock_thick = 6;
// 锁舌长度，单位 mm
tongue_len = 12;
// 锁舌宽度，单位 mm
tongue_w = 6;
// 旋转角度，单位 deg
lock_angle = 90;

part_color = [0.65, 0.72, 0.78, 1.00];


color(part_color)
union() {
    // 圆形锁体
    cyl(d=lock_diam, h=lock_thick, rounding=1, anchor=BOTTOM);

    // 锁舌（两个对称的凸耳）
    for (a = [0, 180])
        zrot(a)
            back(lock_diam / 2 - 1)
                cuboid([tongue_w, tongue_len, lock_thick], rounding=0.5, edges="Z", anchor=BOTTOM);
}