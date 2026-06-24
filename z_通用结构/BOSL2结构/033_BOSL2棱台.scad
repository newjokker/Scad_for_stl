include <BOSL2/std.scad>

// BOSL2 棱台结构示例。
// 使用 prismoid() 生成上下尺寸不同的台体，可用于过渡座、斜收口和壳体变径。

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
