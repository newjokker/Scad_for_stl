include <BOSL2/std.scad>
include <BOSL2/cubetruss.scad>

// BOSL2 桁架脚座结构示例。
// 使用 cubetruss_foot() 生成桁架脚座，可把开放桁架固定到平面或底板上。

// ---------------- 可调参数 ----------------
// 脚座宽度倍率
width_units = 1;
// 单元边长，单位 mm
cell_size = 28;
// 桁架杆宽，单位 mm
strut_size = 4;
// 卡夹厚度，单位 mm
clip_thick = 1.6;

part_color = [0.78, 0.80, 0.76, 1.00];


color(part_color)
cubetruss_foot(
    w=width_units,
    size=cell_size,
    strut=strut_size,
    clipthick=clip_thick,
    anchor=CENTER
);
