include <BOSL2/std.scad>
include <BOSL2/threading.scad>

// BOSL2螺纹杆 示例。
// 每个文件只展示一个 BOSL2 常用结构，顶部参数用于快速调整尺寸和显示形式。
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
