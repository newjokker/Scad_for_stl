include <BOSL2/std.scad>
include <BOSL2/threading.scad>

// 3D 打印螺纹杆组件。
// 使用 BOSL2 threaded_rod() 生成带连续螺纹的圆柱杆，可自定义螺距、头数（多线螺纹）
// 和左右旋方向，端部可选倒角。
// 适用于丝杆传动、螺纹连接件、导螺杆、夹具调节杆等场景。
// 可直接复制模块调用到具体模型中使用。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 64;
// 打印配合间隙
$slop = 0.08;

// 螺纹外径
diam = 10;
// 长度
length = 36;
// 螺距
pitch = 1.5;
// 头数
starts = 1;
// 是否左旋
left_handed = false;
// 是否端部倒角
bevel = true;

part_color = [0.72, 0.72, 0.70, 1.00];


color(part_color)
threaded_rod(
    d=diam,
    l=length,
    pitch=pitch,
    starts=starts,
    left_handed=left_handed,
    bevel=bevel,
    anchor=BOTTOM
);
