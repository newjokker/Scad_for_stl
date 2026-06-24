include <BOSL2/std.scad>

// 3D 打印常用定位销和定位孔结构。
// 左侧为圆柱定位销，右侧为对应插孔，用于盒盖、防呆定位和分件对齐。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 48;

// 定位销直径，单位 mm
pin_diam = 4;
// 定位销高度，单位 mm
pin_height = 8;
// 插孔间隙，单位 mm
clearance = 0.18;
// 底座尺寸，单位 mm
base_size = 20;
// 展示间距，单位 mm
part_gap = 14;

body_color = [0.78, 0.80, 0.76, 1.00];
pin_color = [0.95, 0.55, 0.16, 1.00];


module alignment_pin() {
    color(body_color)
        cuboid([base_size, base_size, 3], rounding=1, edges="Z", anchor=BOTTOM);

    color(pin_color)
    up(3)
        cyl(d=pin_diam, h=pin_height, chamfer2=0.5, anchor=BOTTOM);
}

module alignment_socket() {
    color(body_color)
    difference() {
        cuboid([base_size, base_size, 6], rounding=1, edges="Z", anchor=BOTTOM);

        up(6 + 0.05)
            cyl(d=pin_diam + 2 * clearance, h=pin_height + 0.2, anchor=TOP);
    }
}

left(base_size / 2 + part_gap / 2)
    alignment_pin();

right(base_size / 2 + part_gap / 2)
    alignment_socket();
