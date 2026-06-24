include <BOSL2/std.scad>
include <BOSL2/cubetruss.scad>

// BOSL2 立方桁架结构示例。
// 使用 cubetruss() 生成开放式模块桁架，可用于轻量框架、展示支架和模块连接。

// ---------------- 可调参数 ----------------
// X 方向单元数
count_x = 1;
// Y 方向单元数
count_y = 3;
// Z 方向单元数
count_z = 1;
// 单元边长，单位 mm
cell_size = 28;
// 桁架杆宽，单位 mm
strut_size = 4;
// 是否加入斜撑
bracing = true;
// 卡夹厚度，单位 mm
clip_thick = 1.6;

part_color = [0.78, 0.80, 0.76, 1.00];


color(part_color)
cubetruss(
    extents=[count_x, count_y, count_z],
    clips=[FRONT, BACK],
    bracing=bracing,
    size=cell_size,
    strut=strut_size,
    clipthick=clip_thick,
    anchor=CENTER
);
