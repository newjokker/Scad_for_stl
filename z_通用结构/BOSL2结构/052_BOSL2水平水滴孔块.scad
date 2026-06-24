include <BOSL2/std.scad>

// 3D 打印常用水平水滴孔结构。
// 用 teardrop() 切出横向孔，顶部是尖拱形，打印时比圆孔更少悬垂。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 48;

// 测试块长，单位 mm
block_x = 46;
// 测试块宽，单位 mm
block_y = 24;
// 测试块高，单位 mm
block_z = 24;
// 水滴孔直径，单位 mm
hole_diam = 10;
// 水滴孔顶部角度，单位 deg
hole_angle = 45;

part_color = [0.78, 0.80, 0.76, 1.00];


color(part_color)
difference() {
    cuboid([block_x, block_y, block_z], rounding=1.2, edges="Z", anchor=BOTTOM);

    translate([0, 0, block_z / 2])
        teardrop(
            d=hole_diam,
            l=block_x + 0.2,
            ang=hole_angle,
            anchor=CENTER,
            orient=RIGHT
        );
}
