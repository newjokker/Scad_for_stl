include <BOSL2/std.scad>
include <BOSL2/cubetruss.scad>

// 3D 打印桁架支撑（单向立柱）组件。
// 使用 BOSL2 cubetruss_support() 生成单向延伸的桁架支撑件，无卡夹节点，
// 结构更简洁，适合作为轻量立柱或斜撑。
// 适用于桁架框架的支撑柱、斜撑杆、轻量支架脚等场景。
// 可直接复制模块调用到具体模型中使用。

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
