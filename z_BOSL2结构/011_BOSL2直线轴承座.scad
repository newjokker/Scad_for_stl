include <BOSL2/std.scad>
include <BOSL2/linear_bearings.scad>

// 3D 打印直线轴承座（LM*UU 型）组件。
// 使用 BOSL2 lmXuu_housing() 和 lmXuu_bearing() 生成开口夹紧式直线轴承座，
// 预留夹紧耳和锁紧螺丝孔，轴承内孔为标准 LM*UU 规格。
// 适用于 3D 打印机光轴支撑、直线导轨、滑动门机构等需要低摩擦直线运动的场景。
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
