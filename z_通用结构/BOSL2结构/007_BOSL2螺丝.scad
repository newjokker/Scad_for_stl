include <BOSL2/std.scad>
include <BOSL2/screws.scad>

// BOSL2螺丝 示例。
// 每个文件只展示一个 BOSL2 常用结构，顶部参数用于快速调整尺寸和显示形式。
// 可直接复制模块调用到具体模型中使用。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 48;
// 打印配合间隙
$slop = 0.12;

// 螺丝规格，如 M3、M4、M5
screw_spec = "M4";
// 螺丝长度
screw_length = 24;
// 头型
head_type = "socket";
// 驱动槽
drive_type = "hex";
// 螺纹类型
thread_type = "coarse";

screw_color = [0.72, 0.72, 0.70, 1.00];


color(screw_color)
screw(
    screw_spec,
    head=head_type,
    drive=drive_type,
    thread=thread_type,
    length=screw_length,
    anchor=BOTTOM
);
