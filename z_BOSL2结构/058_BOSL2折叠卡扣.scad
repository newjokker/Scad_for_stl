include <BOSL2/std.scad>
include <BOSL2/hinges.scad>

// 3D 打印常用折叠盒盖卡扣结构。
// 使用 snap_lock() 和 snap_socket() 生成一组可折叠扣锁，适合薄板盒盖。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 48;
// 打印配合间隙
$slop = 0.18;

// 板厚，单位 mm
plate_thick = 3;
// 卡扣长度，单位 mm
snap_length = 9;
// 卡扣直径，单位 mm
snap_diam = 5;
// 折叠角，单位 deg
fold_angle = 90;
// 展示间距，单位 mm
part_gap = 18;

lock_color = [0.95, 0.55, 0.16, 1.00];
socket_color = [0.18, 0.48, 0.78, 1.00];


left(part_gap / 2)
    color(lock_color)
        snap_lock(
            thick=plate_thick,
            snaplen=snap_length,
            snapdiam=snap_diam,
            foldangle=fold_angle,
            anchor=BOTTOM
        );

right(part_gap / 2)
    color(socket_color)
        snap_socket(
            thick=plate_thick,
            snaplen=snap_length,
            snapdiam=snap_diam,
            foldangle=fold_angle,
            anchor=BOTTOM
        );
