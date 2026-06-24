include <BOSL2/std.scad>
include <BOSL2/ball_bearings.scad>

// 3D 打印参考用标准滚珠轴承。
// 使用 BOSL2 ball_bearing() 生成各种标准轴承规格（608、608ZZ、R8 等），
// 可选显示防尘盖（shield），内圈外圈和滚珠均有颜色区分。
// 适用于设计轴承座、滑轮、旋转件时作为尺寸参考和装配验证。
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
