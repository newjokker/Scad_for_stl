include <BOSL2/std.scad>
include <BOSL2/joiners.scad>

// 3D 打印弹性卡扣销组件。
// 使用 BOSL2 snap_pin() 和 snap_pin_socket() 生成标准弹性卡扣销及其插槽，
// 销头为弹性裂口圆柱，插入后膨胀锁紧，可选防转（fixed）和尖头（pointed）形态。
// 适用于两件快速对准锁紧、无需工具的组装定位、玩具/模型快拆连接等场景。
// 可直接复制模块调用到具体模型中使用。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 48;
// 打印配合间隙
$slop = 0.18;

// 标准尺寸
pin_size = "standard";
// 插座是否防转
fixed_socket = true;
// 插座内是否带支撑薄片
socket_fins = true;
// 是否使用尖头
pointed = true;
// 展示间距
exploded_gap = 24;

pin_color = [0.95, 0.55, 0.16, 1.00];
socket_color = [0.18, 0.48, 0.78, 1.00];


simple_snap_pin_pair();


module simple_snap_pin_pair() {
    color(pin_color)
    left(exploded_gap / 2)
        snap_pin(pin_size, pointed=pointed, anchor=CENTER, orient=UP);

    color(socket_color)
    right(exploded_gap / 2)
        snap_pin_socket(
            pin_size,
            fixed=fixed_socket,
            fins=socket_fins,
            pointed=pointed,
            anchor=CENTER,
            orient=UP
        );
}
