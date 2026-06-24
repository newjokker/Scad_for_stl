include <BOSL2/std.scad>
include <BOSL2/cubetruss.scad>

// 3D 打印桁架段连接件组件。
// 使用 BOSL2 cubetruss_joiner() 生成桁架拼接连接件，两端卡入桁架杆件，
// 可水平或垂直方向连接两段桁架。
// 适用于延长桁架、组装大型框架时段的拼接连接等场景。
// 可直接复制模块调用到具体模型中使用。

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
