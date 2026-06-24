include <BOSL2/std.scad>
include <BOSL2/bottlecaps.scad>

// BOSL2瓶盖 示例。
// 每个文件只展示一个 BOSL2 常用结构，顶部参数用于快速调整尺寸和显示形式。
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
