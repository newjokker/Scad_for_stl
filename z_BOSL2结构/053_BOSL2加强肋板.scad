include <BOSL2/std.scad>
include <BOSL2/walls.scad>

// 3D 打印常用加强肋板结构。
// 底板和立板之间加入 thinning_triangle() 三角筋，用于减少变形并提高支撑刚度。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 48;

// 底板长度，单位 mm
base_x = 64;
// 底板宽度，单位 mm
base_y = 26;
// 底板厚度，单位 mm
base_thick = 4;
// 立板高度，单位 mm
wall_height = 36;
// 立板厚度，单位 mm
wall_thick = 4;
// 加强筋数量
rib_count = 3;
// 加强筋厚度，单位 mm
rib_thick = 4;

part_color = [0.78, 0.80, 0.76, 1.00];


module ribbed_bracket() {
    color(part_color)
    union() {
        cuboid([base_x, base_y, base_thick], rounding=1, edges="Z", anchor=BOTTOM);

        translate([0, base_y / 2 - wall_thick / 2, base_thick])
            cuboid([base_x, wall_thick, wall_height], rounding=0.8, edges="Z", anchor=BOTTOM);

        xcopies(spacing=base_x / max(1, rib_count - 1), n=rib_count)
            translate([0, base_y / 2 - wall_thick - rib_thick / 2, base_thick])
                rotate([90, 0, 0])
                    thinning_triangle(
                        h=wall_height * 0.85,
                        l=base_y * 0.72,
                        thick=rib_thick,
                        wall=2,
                        strut=3,
                        anchor=BOTTOM
                    );
    }
}

ribbed_bracket();
