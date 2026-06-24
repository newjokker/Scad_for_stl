include <BOSL2/std.scad>
include <BOSL2/cubetruss.scad>

// BOSL2 桁架转角结构示例。
// 使用 cubetruss_corner() 生成多方向转角桁架，可作为三维框架的角节点。

// ---------------- 可调参数 ----------------
// 竖向主体高度单元数
height_units = 1;
// 右方向延伸单元数
right_units = 2;
// 后方向延伸单元数
back_units = 2;
// 上方向延伸单元数
up_units = 1;
// 单元边长，单位 mm
cell_size = 28;
// 桁架杆宽，单位 mm
strut_size = 4;
// 是否加入斜撑
bracing = true;

part_color = [0.78, 0.80, 0.76, 1.00];


color(part_color)
cubetruss_corner(
    h=height_units,
    extents=[right_units, back_units, 0, 0, up_units],
    bracing=bracing,
    size=cell_size,
    strut=strut_size,
    anchor=CENTER
);
