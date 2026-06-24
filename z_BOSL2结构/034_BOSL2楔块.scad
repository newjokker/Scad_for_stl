include <BOSL2/std.scad>

// 3D 打印楔块（直角斜面块）组件。
// 使用 BOSL2 wedge() 生成单侧带斜面的楔形块，底面为矩形、顶面收敛为线。
// 适用于斜撑块、三角垫片、导向斜面、倾角底座、切除面具等场景。
// 可直接复制模块调用到具体模型中使用。

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
