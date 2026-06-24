include <BOSL2/std.scad>

// 3D 打印常用长圆调节孔板结构。
// 两端圆孔加中间矩形连通，适合皮带张紧、电机微调和安装孔位误差补偿。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 48;

// 板长，单位 mm
plate_x = 70;
// 板宽，单位 mm
plate_y = 30;
// 板厚，单位 mm
plate_thick = 5;
// 长圆孔长度，单位 mm
slot_length = 28;
// 长圆孔直径，单位 mm
slot_diam = 5;
// 两个长圆孔中心间距，单位 mm
slot_spacing = 34;

part_color = [0.78, 0.80, 0.76, 1.00];


module slot_hole(l, d, h) {
    hull() {
        left(l / 2 - d / 2)
            cyl(d=d, h=h, anchor=CENTER);
        right(l / 2 - d / 2)
            cyl(d=d, h=h, anchor=CENTER);
    }
}

color(part_color)
difference() {
    cuboid([plate_x, plate_y, plate_thick], rounding=1.2, edges="Z", anchor=BOTTOM);

    for (x = [-slot_spacing / 2, slot_spacing / 2])
        translate([x, 0, plate_thick / 2])
            slot_hole(slot_length, slot_diam, plate_thick + 0.2);
}
