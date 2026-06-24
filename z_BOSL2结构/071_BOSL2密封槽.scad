include <BOSL2/std.scad>

// 3D 打印常用密封槽结构。
// 用于放置 O 型密封圈的矩形截面沟槽，适合盒子、舱门等需要防尘防水的场合。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 64;
// 打印配合间隙
$slop = 0.12;

// 密封圈线径，单位 mm
oring_w = 2;
// 密封槽宽度，单位 mm
groove_w = 2.6;
// 密封槽深度，单位 mm
groove_depth = 1.4;
// 槽中心线长度（边长），单位 mm
side_len = 50;
// 壁厚（槽外壁到模型边缘），单位 mm
wall = 3;
// 是否显示封闭矩形槽
show_closed = true;

part_color = [0.72, 0.78, 0.74, 1.00];


// 计算外壁尺寸
outer = side_len + wall * 2;

color(part_color)
difference() {
    // 主体
    if (show_closed)
        cuboid([outer, outer, 8], chamfer=1, edges="Z", anchor=BOTTOM);
    else
        cuboid([outer, outer, 8], chamfer=1, edges="Z", anchor=BOTTOM);

    // 密封槽（沿边缘的 U 形沟槽）
    if (show_closed) {
        // 四条边的密封槽
        x_off = side_len / 2;
        y_off = side_len / 2;

        // 上下边（X 向）
        up(8 - groove_depth)
            union() {
                back(y_off - groove_w / 2)
                    cuboid([side_len, groove_w, groove_depth + 0.1], anchor=BOTTOM);
                fwd(y_off - groove_w / 2)
                    cuboid([side_len, groove_w, groove_depth + 0.1], anchor=BOTTOM);
            }

        // 左右边（Y 向）
        up(8 - groove_depth)
            union() {
                left(x_off - groove_w / 2)
                    cuboid([groove_w, side_len, groove_depth + 0.1], anchor=BOTTOM);
                right(x_off - groove_w / 2)
                    cuboid([groove_w, side_len, groove_depth + 0.1], anchor=BOTTOM);
            }
    }
}