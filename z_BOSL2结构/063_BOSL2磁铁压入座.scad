include <BOSL2/std.scad>

// 3D 打印常用磁铁压入座结构。
// 用于将圆形磁铁压入固定，适合封箱、门吸、定位等场景。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 48;
// 打印配合间隙
$slop = 0.15;

// 磁铁直径，单位 mm
mag_diam = 10;
// 磁铁高度，单位 mm
mag_height = 3;
// 壁厚（磁铁孔到外壁），单位 mm
wall = 1.6;
// 底部厚度，单位 mm
base_thick = 2;

part_color = [0.72, 0.74, 0.70, 1.00];


// 计算磁铁孔内径（加间隙）
hole_d = mag_diam + $slop;
// 底座外尺寸
outer = hole_d + wall * 2;

color(part_color)
difference() {
    // 底座
    cyl(d=outer, h=base_thick + mag_height, rounding=1, anchor=BOTTOM);

    // 磁铁孔
    up(base_thick)
        cyl(d=hole_d, h=mag_height + 0.1, anchor=BOTTOM);
}