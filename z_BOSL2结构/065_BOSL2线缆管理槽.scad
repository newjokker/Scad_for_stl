include <BOSL2/std.scad>

// 3D 打印常用线缆管理槽结构。
// 用于固定和引导线缆走向的开口槽，可卡入线缆防止松动。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 48;
// 打印配合间隙
$slop = 0.12;

// 线缆直径，单位 mm
cable_diam = 6;
// 槽长度，单位 mm
channel_len = 30;
// 槽壁高度，单位 mm
wall_height = 8;
// 壁厚，单位 mm
wall = 2;
// 开口宽度比例（0~1），1 为全开
open_ratio = 0.7;

part_color = [0.74, 0.72, 0.68, 1.00];


// 计算尺寸
inner_w = cable_diam + $slop * 2;
outer_w = inner_w + wall * 2;
outer_len = channel_len;
// 开口宽度
open_w = inner_w * open_ratio;

color(part_color)
difference() {
    // 槽体外壳
    cuboid([outer_len, outer_w, wall_height], rounding=1, edges="Z", anchor=BOTTOM);

    // 线缆槽内腔
    up(wall)
        cuboid([outer_len + 0.1, inner_w, wall_height], anchor=BOTTOM);

    // 顶部开口（用于卡入线缆）
    up(wall_height - 0.1)
        cuboid([outer_len + 0.1, open_w, wall + 0.2], anchor=BOTTOM);
}