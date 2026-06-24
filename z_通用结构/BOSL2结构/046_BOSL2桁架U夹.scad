include <BOSL2/std.scad>
include <BOSL2/cubetruss.scad>

// BOSL2 桁架 U 夹结构示例。
// 使用 cubetruss_uclip() 生成可扣住桁架杆的 U 形夹，适合挂载小附件。

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
