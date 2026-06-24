include <BOSL2/std.scad>
include <BOSL2/cubetruss.scad>

// BOSL2 桁架支撑结构示例。
// 使用 cubetruss_support() 生成单向支撑桁架，适合做立柱、斜撑或轻量支架。

// ---------------- 可调参数 ----------------
// X 方向单元数
count_x = 1;
// Y 方向单元数
count_y = 1;
// Z 方向单元数
count_z = 3;
// 单元边长，单位 mm
cell_size = 28;
// 桁架杆宽，单位 mm
strut_size = 4;

part_color = [0.78, 0.80, 0.76, 1.00];


color(part_color)
cubetruss_support(
    extents=[count_x, count_y, count_z],
    size=cell_size,
    strut=strut_size,
    anchor=CENTER
);
