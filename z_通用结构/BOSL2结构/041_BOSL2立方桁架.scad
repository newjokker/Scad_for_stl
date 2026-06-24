include <BOSL2/std.scad>
include <BOSL2/cubetruss.scad>

// 3D 打印立方桁架模块。
// 使用 BOSL2 cubetruss() 生成由杆件组成的开放式立方桁架，可沿 X/Y/Z 方向扩展单元数，
// 杆件节点带卡夹（clips）用于连接附件，可选斜撑加强（bracing）。
// 适用于轻量框架结构、展示支架、模块化连接平台、骨架外壳等场景。
// 可直接复制模块调用到具体模型中使用。

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
