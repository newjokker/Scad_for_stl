include <BOSL2/std.scad>
include <BOSL2/nema_steppers.scad>

// 3D 打印 NEMA 步进电机安装孔。
// 使用 BOSL2 nema_mount_mask() 生成标准 NEMA 步进电机安装孔位 mask，
// 支持 NEMA8/11/14/17/23 等规格，可选圆孔或长圆调节槽（slot）。
// 适用于步进电机安装板、3D 打印机框架、CNC 电机座等需要标准电机孔位的场景。
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
