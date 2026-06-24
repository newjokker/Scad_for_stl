include <BOSL2/std.scad>
include <BOSL2/screws.scad>

// 3D 打印螺丝孔测试块。
// 使用 BOSL2 screw_hole() 在一个测试块上演示螺丝孔减料，支持沉孔（counterbore）、
// 内螺纹（threaded）和水滴孔（teardrop）等选项。
// 适用于设计阶段验证螺丝孔尺寸、直接在零件中嵌入螺丝孔等场景。
// 可直接复制模块调用到具体模型中使用。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 48;
// 打印配合间隙
$slop = 0.12;

// 测试块长
block_x = 36;
// 测试块宽
block_y = 28;
// 测试块厚度
block_z = 14;
// 螺丝规格
screw_spec = "M4";
// 头型
head_type = "socket";
// 是否做内螺纹孔
threaded = false;
// 是否沉孔
counterbore = true;
// 是否水滴孔
teardrop = false;

body_color = [0.78, 0.80, 0.76, 1.00];


color(body_color)
difference() {
    cuboid([block_x, block_y, block_z], rounding=1.2, edges="Z", anchor=BOTTOM);

    up(block_z + 0.01)
        screw_hole(
            screw_spec,
            head=head_type,
            length=block_z + 0.2,
            thread=threaded,
            counterbore=counterbore,
            teardrop=teardrop,
            anchor=TOP
        );
}
