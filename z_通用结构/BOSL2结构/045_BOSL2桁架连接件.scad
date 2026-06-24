include <BOSL2/std.scad>
include <BOSL2/cubetruss.scad>

// BOSL2 桁架连接件结构示例。
// 使用 cubetruss_joiner() 生成桁架拼接连接件，用于连接两个开放桁架段。

// ---------------- 可调参数 ----------------
// 连接件宽度倍率
width_units = 1;
// 是否为竖向连接件
vertical = true;
// 单元边长，单位 mm
cell_size = 28;
// 桁架杆宽，单位 mm
strut_size = 4;
// 卡夹厚度，单位 mm
clip_thick = 1.6;

part_color = [0.95, 0.55, 0.16, 1.00];


color(part_color)
cubetruss_joiner(
    w=width_units,
    vert=vertical,
    size=cell_size,
    strut=strut_size,
    clipthick=clip_thick,
    anchor=CENTER
);
