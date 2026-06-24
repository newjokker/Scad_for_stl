include <BOSL2/std.scad>
include <BOSL2/bottlecaps.scad>

// 3D 打印标准瓶盖组件。
// 使用 BOSL2 pco1881_cap() / pco1810_cap() 生成符合 PET 瓶口标准的螺纹瓶盖，
// 支持不同瓶口标准和外表纹理（光面/肋纹），壁厚可调。
// 适用于容器密封盖、液体瓶盖、替换盖、密封结构原型等场景。
// 可直接复制模块调用到具体模型中使用。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 80;

// 瓶口标准
standard = "PCO1881";
// 壁厚
wall = 2;
// 外表纹理
texture = "ribbed";

part_color = [0.78, 0.80, 0.76, 1.00];


color(part_color)
if (standard == "PCO1881")
    pco1881_cap(wall=wall, texture=texture, anchor=BOTTOM);
else
    pco1810_cap(wall=wall, texture=texture, anchor=BOTTOM);
