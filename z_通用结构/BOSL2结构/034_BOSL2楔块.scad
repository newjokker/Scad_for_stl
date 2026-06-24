include <BOSL2/std.scad>

// BOSL2 楔块结构示例。
// 使用 wedge() 生成直角斜面块，可作为斜撑、垫块、导向斜面或切除用 mask。

// ---------------- 可调参数 ----------------
// 楔块 X 尺寸，单位 mm
size_x = 54;
// 楔块 Y 尺寸，单位 mm
size_y = 34;
// 楔块 Z 高度，单位 mm
size_z = 24;

part_color = [0.78, 0.80, 0.76, 1.00];


color(part_color)
wedge(
    size=[size_x, size_y, size_z],
    anchor=BOTTOM
);
