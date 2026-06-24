include <BOSL2/std.scad>
include <BOSL2/screws.scad>

// 3D 打印标准螺丝组件。
// 使用 BOSL2 screw() 生成各种标准规格螺丝，支持内六角、十字、一字等驱动类型，
// 以及圆柱头、沉头、半圆头等头型，螺纹可选粗牙/细牙。
// 适用于模型装配验证、螺丝孔位检查、展示说明等场景。
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
