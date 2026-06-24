include <BOSL2/std.scad>
include <BOSL2/screws.scad>

// 3D 打印常用直角安装支架。
// 两块互相垂直的安装板配合螺丝孔和三角加强筋，可用于固定传感器、小电路板或外壳。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 48;
// 打印配合间隙
$slop = 0.12;

// 支架宽度，单位 mm
width = 44;
// 底板长度，单位 mm
base_length = 36;
// 立板高度，单位 mm
upright_height = 34;
// 板厚，单位 mm
thick = 4;
// 螺丝规格
screw_spec = "M3";
// 是否显示螺丝孔
show_holes = true;

part_color = [0.78, 0.80, 0.76, 1.00];


color(part_color)
difference() {
    union() {
        cuboid([width, base_length, thick], rounding=1, edges="Z", anchor=BOTTOM);

        translate([0, base_length / 2 - thick / 2, thick])
            cuboid([width, thick, upright_height], rounding=1, edges="Z", anchor=BOTTOM);

        xcopies(spacing=width * 0.55, n=2)
            translate([0, base_length / 2 - thick, thick])
                rotate([90, 0, 0])
                    wedge([thick, upright_height * 0.75, base_length * 0.55], anchor=BOTTOM);
    }

    if (show_holes) {
        translate([-width * 0.25, -base_length * 0.18, thick + 0.05])
            screw_hole(screw_spec, length=thick + 0.2, anchor=TOP);

        translate([width * 0.25, -base_length * 0.18, thick + 0.05])
            screw_hole(screw_spec, length=thick + 0.2, anchor=TOP);

        translate([0, base_length / 2 + 0.05, thick + upright_height * 0.55])
            rotate([90, 0, 0])
                screw_hole(screw_spec, length=thick + 0.2, anchor=TOP);
    }
}
