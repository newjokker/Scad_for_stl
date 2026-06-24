include <BOSL2/std.scad>
include <BOSL2/screws.scad>

// 3D 打印常用沉头孔板结构。
// 使用 BOSL2 screw_hole() 生成平头、圆柱头或普通螺丝孔，适合面板安装位。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 64;
// 打印配合间隙
$slop = 0.12;

// 板长，单位 mm
plate_x = 44;
// 板宽，单位 mm
plate_y = 32;
// 板厚，单位 mm
plate_thick = 6;
// 螺丝规格
screw_spec = "M4";
// 头型
head_type = "flat";        // [flat, socket, pan, button, none]
// 是否使用沉孔
counterbore = true;

part_color = [0.78, 0.80, 0.76, 1.00];


color(part_color)
difference() {
    cuboid([plate_x, plate_y, plate_thick], rounding=1.2, edges="Z", anchor=BOTTOM);

    up(plate_thick + 0.05)
        screw_hole(
            screw_spec,
            head=head_type,
            length=plate_thick + 0.2,
            counterbore=counterbore,
            anchor=TOP
        );
}
