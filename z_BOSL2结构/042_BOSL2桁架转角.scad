include <BOSL2/std.scad>
include <BOSL2/cubetruss.scad>

// 3D 打印桁架转角节点组件。
// 使用 BOSL2 cubetruss_corner() 生成多方向转角桁架节点，可向上下和水平多个方向
// 延伸桁架杆，作为三维框架的角连接件。
// 适用于桁架框架的 L 形/T 形转角、多方向结构连接点等场景。
// 可直接复制模块调用到具体模型中使用。

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
