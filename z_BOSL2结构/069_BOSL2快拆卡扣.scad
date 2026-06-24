include <BOSL2/std.scad>

// 3D 打印常用快拆卡扣结构。
// 按压式快拆卡扣，用于两零件之间的快速连接和分离。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 48;
// 打印配合间隙
$slop = 0.18;

// 卡扣长度（悬臂方向），单位 mm
clip_len = 20;
// 卡扣宽度，单位 mm
clip_w = 10;
// 卡扣厚度，单位 mm
clip_t = 2;
// 卡勾高度，单位 mm
hook_h = 3;
// 卡勾长度，单位 mm
hook_len = 5;
// 安装底座厚度，单位 mm
base_t = 3;

part_color = [0.88, 0.56, 0.20, 1.00];


// 计算卡勾斜面
hook_slope = hook_h / hook_len * 2;

color(part_color)
union() {
    // 底座
    cuboid([clip_len + 6, clip_w, base_t], rounding=0.5, edges="Z", anchor=BOTTOM + BACK);

    // 悬臂卡扣主体
    up(base_t)
        cuboid([clip_len, clip_w, clip_t], anchor=BOTTOM + BACK);

    // 卡勾
    up(base_t + clip_t)
        back(clip_len / 2 - hook_len / 2)
            prismoid(
                size1=[clip_w, hook_len],
                size2=[clip_w, hook_len * 0.3],
                h=hook_h,
                anchor=BOTTOM + BACK
            );

    // 按压手柄
    up(base_t + clip_t)
        fwd(clip_len / 2 + 4)
            cuboid([clip_w, 8, clip_t + 1], rounding=0.5, edges="Z", anchor=BOTTOM + BACK);
}