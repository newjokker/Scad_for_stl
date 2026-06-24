include <BOSL2/std.scad>
include <BOSL2/screws.scad>

// BOSL2螺母 示例。
// 每个文件只展示一个 BOSL2 常用结构，顶部参数用于快速调整尺寸和显示形式。
// 可直接复制模块调用到具体模型中使用。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 64;
// 打印配合间隙
$slop = 0.12;

// 螺母规格，如 M3、M4、M5
nut_spec = "M4";
// 螺母形状
nut_shape = "hex";
// 厚度类型
nut_thickness = "normal";
// 螺纹类型
thread_type = "coarse";

nut_color = [0.72, 0.72, 0.70, 1.00];


color(nut_color)
nut(
    nut_spec,
    shape=nut_shape,
    thickness=nut_thickness,
    thread=thread_type,
    anchor=BOTTOM
);
