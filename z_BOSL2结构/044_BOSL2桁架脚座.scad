include <BOSL2/std.scad>
include <BOSL2/cubetruss.scad>

// 3D 打印桁架脚座组件。
// 使用 BOSL2 cubetruss_foot() 生成带安装孔的桁架脚座，脚座顶部卡入桁架杆件，
// 底部可螺丝固定到平面或底板上。
// 适用于桁架框架的地脚固定、桁架与平面的转接安装等场景。
// 可直接复制模块调用到具体模型中使用。

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
