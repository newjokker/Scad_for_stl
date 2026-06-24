include <BOSL2/std.scad>

// 3D 打印常用扎带耳座结构。
// 用于在模型上预留扎带穿孔的耳座，方便理线、固定线缆或管路。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 48;
// 打印配合间隙
$slop = 0.15;

// 扎带宽度，单位 mm（常用 2.5 / 3.6 / 4.8）
strap_width = 4.8;
// 扎带厚度，单位 mm（常用 1.0 / 1.2 / 1.5）
strap_thick = 1.2;
// 耳座宽度，单位 mm
tab_width = 10;
// 耳座高度，单位 mm
tab_height = 8;

part_color = [0.68, 0.70, 0.66, 1.00];


// 计算穿孔尺寸（加间隙）
slot_w = strap_width + $slop;
slot_h = strap_thick + $slop;
// 耳座总长
tab_len = slot_w + 4;

color(part_color)
difference() {
    // 耳座主体
    cuboid([tab_len, tab_width, tab_height], rounding=0.5, edges="Z", anchor=BOTTOM);

    // 扎带穿孔（沿 Y 方向贯穿）
    up(tab_height / 2)
        cuboid([slot_w, tab_width + 0.1, slot_h], anchor=CENTER);
}