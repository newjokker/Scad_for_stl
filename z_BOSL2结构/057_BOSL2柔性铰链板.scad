include <BOSL2/std.scad>
include <BOSL2/hinges.scad>

// 3D 打印常用柔性铰链板结构。
// 使用 living_hinge_mask() 在薄板中切出折弯槽，适合 PLA/PETG 薄片折页测试。

// ---------------- 可调参数 ----------------
// 板长，单位 mm
plate_x = 84;
// 板宽，单位 mm
plate_y = 34;
// 板厚，单位 mm
plate_thick = 2.4;
// 柔性铰链长度，单位 mm
hinge_length = 70;
// 目标折叠角，单位 deg
fold_angle = 90;
// 层高，单位 mm
layer_height = 0.2;
// 铰链槽间隙，单位 mm
hinge_gap = 0.45;
// 是否显示切除体
show_mask = true;

body_color = [0.78, 0.80, 0.76, 1.00];
mask_color = [0.18, 0.48, 0.78, 0.35];


color(body_color)
difference() {
    cuboid([plate_x, plate_y, plate_thick], rounding=1.2, edges="Z", anchor=BOTTOM);

    living_hinge_mask(
        l=hinge_length,
        thick=plate_thick,
        layerheight=layer_height,
        foldangle=fold_angle,
        hingegap=hinge_gap,
        anchor=BOTTOM
    );
}

if (show_mask)
    color(mask_color)
    up(0.02)
        living_hinge_mask(
            l=hinge_length,
            thick=plate_thick,
            layerheight=layer_height,
            foldangle=fold_angle,
            hingegap=hinge_gap,
            anchor=BOTTOM
        );
