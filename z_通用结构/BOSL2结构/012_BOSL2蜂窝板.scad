include <BOSL2/std.scad>
include <BOSL2/walls.scad>

// BOSL2蜂窝板 示例。
// 每个文件只展示一个 BOSL2 常用结构，顶部参数用于快速调整尺寸和显示形式。
// 可直接复制模块调用到具体模型中使用。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 48;

// 板长
panel_x = 80;
// 板宽
panel_y = 50;
// 板厚
panel_thick = 5;
// 蜂窝筋宽
strut = 1.5;
// 蜂窝间距
spacing = 10;
// 外框宽度
frame = 4;
// 是否给外框倒角
bevel_edges = true;

panel_color = [0.78, 0.80, 0.76, 1.00];


color(panel_color)
hex_panel(
    [panel_x, panel_y, panel_thick],
    strut=strut,
    spacing=spacing,
    frame=frame,
    bevel=bevel_edges ? [LEFT, RIGHT, FRONT, BACK] : [],
    anchor=CENTER
);
