include <BOSL2/std.scad>
include <BOSL2/hinges.scad>

// BOSL2铰链结构 示例。
// 每个文件只展示一个 BOSL2 常用结构，顶部参数用于快速调整尺寸和显示形式。
// 可直接复制模块调用到具体模型中使用。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 64;
// 打印配合间隙
$slop = 0.18;

// 铰链总长度
hinge_length = 42;
// 铰链分段数量
hinge_segments = 7;
// 铰链圆筒外径
knuckle_diam = 7;
// 销轴孔直径
pin_diam = 2.4;

// 单侧叶片长度
leaf_length = 38;
// 叶片宽度
leaf_width = 42;
// 叶片厚度
leaf_thick = 3;
// 两片叶片间隙
leaf_gap = 0.6;
// 右侧叶片打开角度
open_angle = 0;

// 铰链支撑臂高度
arm_height = 0;
// 铰链支撑臂角度
arm_angle = 90;
// 是否使用一体打印铰链结构
print_in_place = false;
// 是否显示销轴
show_pin = true;
// 是否显示叶片安装孔
show_screw_holes = true;

body_color = [0.78, 0.80, 0.76, 1.00];
outer_color = [0.95, 0.55, 0.16, 1.00];
inner_color = [0.18, 0.48, 0.78, 1.00];
pin_color = [0.12, 0.12, 0.12, 1.00];


// 一个完整铰链示例：左叶片使用 outer，右叶片使用 inner。
simple_bosl2_hinge();


module simple_bosl2_hinge() {
    offset = max(leaf_thick + leaf_gap, knuckle_diam / 2);

    color(body_color)
    translate([-leaf_length / 2 - leaf_gap / 2, 0, 0])
        hinge_leaf(side="left");

    color(outer_color)
    translate([-leaf_gap / 2, 0, leaf_thick])
        rotate([0, 0, 90])
            hinge_part(inner=false, offset=offset);

    color(body_color)
    translate([leaf_length / 2 + leaf_gap / 2, 0, 0])
        rotate([0, open_angle, 0])
            hinge_leaf(side="right");

    color(inner_color)
    translate([leaf_gap / 2, 0, leaf_thick])
        rotate([0, open_angle, 0])
            rotate([0, 0, -90])
                hinge_part(inner=true, offset=offset);

    if (show_pin && !print_in_place)
        color(pin_color)
        translate([0, 0, leaf_thick + offset])
            rotate([90, 0, 0])
                cyl(d=pin_diam * 0.82, h=hinge_length + 5, anchor=CENTER);
}


module hinge_part(inner=false, offset=4) {
    knuckle_hinge(
        length=hinge_length,
        segs=hinge_segments,
        offset=offset,
        inner=inner,
        arm_height=arm_height,
        arm_angle=arm_angle,
        clear_top=arm_angle == 90,
        knuckle_diam=knuckle_diam,
        pin_diam=pin_diam,
        gap=$slop,
        in_place=print_in_place,
        anchor=BOTTOM
    );
}


module hinge_leaf(side="left") {
    xsign = side == "left" ? -1 : 1;

    difference() {
        cuboid([leaf_length, leaf_width, leaf_thick],
            rounding=1.2, edges="Z", anchor=BOTTOM);

        if (show_screw_holes)
            for (y = [-leaf_width * 0.25, leaf_width * 0.25])
                translate([xsign * leaf_length * 0.22, y, -0.1])
                    cyl(d=4.2, h=leaf_thick + 0.2, anchor=BOTTOM);
    }
}
