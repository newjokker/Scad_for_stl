include <BOSL2/std.scad>
include <BOSL2/nema_steppers.scad>

// BOSL2_NEMA电机安装孔 示例。
// 每个文件只展示一个 BOSL2 常用结构，顶部参数用于快速调整尺寸和显示形式。
// 可直接复制模块调用到具体模型中使用。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 48;
// 打印配合间隙
$slop = 0.15;

// NEMA 规格
nema_size = 17;
// 安装板长
plate_x = 62;
// 安装板宽
plate_y = 62;
// 安装板厚度
plate_thick = 5;
// 调节槽长度，0 为圆孔
slot_length = 4;
// 是否显示减料形状
show_mask = true;

body_color = [0.78, 0.80, 0.76, 1.00];
mask_color = [0.18, 0.48, 0.78, 0.35];


color(body_color)
difference() {
    cuboid([plate_x, plate_y, plate_thick], rounding=1.2, edges="Z", anchor=BOTTOM);

    up(plate_thick / 2)
        nema_mount_mask(
            size=nema_size,
            depth=plate_thick + 0.2,
            l=slot_length,
            anchor=CENTER
        );
}

if (show_mask)
    color(mask_color)
    up(plate_thick / 2)
        nema_mount_mask(
            size=nema_size,
            depth=plate_thick + 0.2,
            l=slot_length,
            anchor=CENTER
        );
