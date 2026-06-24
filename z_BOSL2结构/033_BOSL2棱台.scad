include <BOSL2/std.scad>

// 3D 打印棱台（上下不同尺寸台体）组件。
// 使用 BOSL2 prismoid() 生成底面和顶面尺寸不同的台体，支持偏移（shift）和边缘圆角。
// 适用于壳体变径过渡段、漏斗形收口、电机座转接台等需要上下截面变化的场景。
// 可直接复制模块调用到具体模型中使用。

// ---------------- 可调参数 ----------------
// 底面 X 尺寸，单位 mm
bottom_x = 58;
// 底面 Y 尺寸，单位 mm
bottom_y = 38;
// 顶面 X 尺寸，单位 mm
top_x = 32;
// 顶面 Y 尺寸，单位 mm
top_y = 22;
// 高度，单位 mm
height = 24;
// 顶面相对底面的 X 偏移，单位 mm
shift_x = 0;
// 顶面相对底面的 Y 偏移，单位 mm
shift_y = 0;
// 边缘圆角，单位 mm
rounding = 1.5;

part_color = [0.78, 0.80, 0.76, 1.00];


color(part_color)
prismoid(
    size1=[bottom_x, bottom_y],
    size2=[top_x, top_y],
    h=height,
    shift=[shift_x, shift_y],
    rounding=rounding,
    anchor=BOTTOM
);
