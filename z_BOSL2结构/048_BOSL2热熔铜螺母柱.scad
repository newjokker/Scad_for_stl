include <BOSL2/std.scad>

// 3D 打印常用热熔铜螺母柱结构。
// 上部为铜螺母预留孔，下部为螺丝通孔，适合盒体、盖板和可拆装结构。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 64;

// 螺母柱外径，单位 mm
post_diam = 12;
// 螺母柱高度，单位 mm
post_height = 18;
// 热熔铜螺母外径，单位 mm
insert_diam = 5.0;
// 热熔铜螺母深度，单位 mm
insert_depth = 6.0;
// 螺丝通孔直径，单位 mm
screw_clearance = 3.3;
// 孔口倒角，单位 mm
lead_chamfer = 0.5;

part_color = [0.78, 0.80, 0.76, 1.00];


module heatset_insert_post() {
    color(part_color)
    difference() {
        cyl(d=post_diam, h=post_height, rounding2=0.8, anchor=BOTTOM);

        up(post_height - insert_depth + 0.01)
            cyl(d=insert_diam, h=insert_depth + 0.1,
                chamfer1=lead_chamfer, anchor=BOTTOM);

        down(0.05)
            cyl(d=screw_clearance, h=post_height + 0.2, anchor=BOTTOM);
    }
}

heatset_insert_post();
