include <BOSL2/std.scad>
include <BOSL2/linear_bearings.scad>

// BOSL2直线轴承座 示例。
// 每个文件只展示一个 BOSL2 常用结构，顶部参数用于快速调整尺寸和显示形式。
// 可直接复制模块调用到具体模型中使用。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 64;
// 打印配合间隙
$slop = 0.15;

// LM*UU 内径
shaft_size = 8;
// 轴承座壁厚
wall = 3;
// 夹紧耳高度
tab = 7;
// 夹紧开口
gap = 5;
// 夹紧耳厚度
tabwall = 5;
// 锁紧螺丝
screw_size = 3;
// 是否显示轴承芯
show_bearing = true;

housing_color = [0.78, 0.80, 0.76, 1.00];


color(housing_color)
lmXuu_housing(
    size=shaft_size,
    wall=wall,
    tab=tab,
    gap=gap,
    tabwall=tabwall,
    screwsize=screw_size,
    anchor=BOTTOM
);

if (show_bearing)
    color([0.72, 0.72, 0.70, 1.00])
    up(wall)
        rotate([0, 90, 0])
            lmXuu_bearing(size=shaft_size, anchor=CENTER);
