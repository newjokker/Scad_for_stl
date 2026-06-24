include <BOSL2/std.scad>
include <BOSL2/walls.scad>

// 3D 打印蜂窝轻量面板。
// 使用 BOSL2 hex_panel() 生成带六边形蜂窝网格的轻量面板，可自定义蜂窝密度、筋宽和外框，
// 外框可选倒角边。在保持结构强度的前提下大幅减少材料用量和打印时间。
// 适用于设备外壳、隔板、底板等需要大面积轻量化的场景。
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
