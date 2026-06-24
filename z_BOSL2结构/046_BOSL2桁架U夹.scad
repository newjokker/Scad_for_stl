include <BOSL2/std.scad>
include <BOSL2/cubetruss.scad>

// 3D 打印桁架 U 形卡夹组件。
// 使用 BOSL2 cubetruss_uclip() 生成可弹性扣住桁架杆的 U 形夹，
// 可选单夹或双夹模式，双夹可同时扣住两根相邻桁架杆。
// 适用于桁架框架上挂载传感器、线缆夹、小附件等场景。
// 可直接复制模块调用到具体模型中使用。

// ---------------- 可调参数 ----------------
// 是否做双夹
dual_clip = true;
// 单元边长，单位 mm
cell_size = 28;
// 桁架杆宽，单位 mm
strut_size = 4;
// 卡夹厚度，单位 mm
clip_thick = 1.6;

part_color = [0.95, 0.55, 0.16, 1.00];


color(part_color)
cubetruss_uclip(
    dual=dual_clip,
    size=cell_size,
    strut=strut_size,
    clipthick=clip_thick,
    anchor=CENTER
);
