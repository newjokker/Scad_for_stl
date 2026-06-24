include <BOSL2/std.scad>
include <BOSL2/ball_bearings.scad>

// BOSL2轴承 示例。
// 每个文件只展示一个 BOSL2 常用结构，顶部参数用于快速调整尺寸和显示形式。
// 可直接复制模块调用到具体模型中使用。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 96;

// 常用如 608、608ZZ、R8、F688ZZ
bearing_size = "608";
// 自定义尺寸时是否显示防尘盖
show_shield = true;
// 边缘圆角
rounding = 0.3;


ball_bearing(
    bearing_size,
    shield=show_shield,
    rounding=rounding,
    anchor=CENTER
);
