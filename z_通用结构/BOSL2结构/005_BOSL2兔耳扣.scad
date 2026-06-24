include <BOSL2/std.scad>
include <BOSL2/joiners.scad>

// BOSL2兔耳扣 示例。
// 每个文件只展示一个 BOSL2 常用结构，顶部参数用于快速调整尺寸和显示形式。
// 可直接复制模块调用到具体模型中使用。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 48;
// 打印配合间隙
$slop = 0.18;

// 卡扣长度
clip_length = 18;
// 卡扣宽度
clip_width = 14;
// 卡扣深度
clip_depth = 6;
// 弹片厚度
clip_thick = 1.2;
// 卡点深度
snap = 1.2;
// 弹片预压
compression = 0.25;
// 插座间隙
clearance = 0.18;
// 是否加锁止肩
lock = false;
// 展示间距
exploded_gap = 24;

pin_color = [0.95, 0.55, 0.16, 1.00];
socket_color = [0.18, 0.48, 0.78, 1.00];


simple_rabbit_clip_pair();


module simple_rabbit_clip_pair() {
    color(pin_color)
    left(exploded_gap / 2)
        rabbit_clip(
            "pin",
            length=clip_length,
            width=clip_width,
            snap=snap,
            thickness=clip_thick,
            depth=clip_depth,
            compression=compression,
            lock=lock,
            lock_clearance=lock ? 2 : 0
        );

    color(socket_color)
    right(exploded_gap / 2)
        rabbit_clip(
            "socket",
            length=clip_length,
            width=clip_width,
            snap=snap,
            thickness=clip_thick,
            depth=clip_depth + 0.5,
            clearance=clearance,
            lock=lock,
            lock_clearance=lock ? 2 : 0,
            orient=UP
        );
}
