include <BOSL2/std.scad>
include <BOSL2/screws.scad>

// 3D 打印常用倒角安装块结构。
// 倒角长方体中加入螺丝孔，适合快速生成垫块、压块和固定座。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 48;
// 打印配合间隙
$slop = 0.12;

// 安装块长度，单位 mm
block_x = 42;
// 安装块宽度，单位 mm
block_y = 26;
// 安装块高度，单位 mm
block_z = 12;
// 倒角尺寸，单位 mm
chamfer = 2;
// 螺丝规格
screw_spec = "M4";
// 是否显示孔
show_hole = true;

part_color = [0.78, 0.80, 0.76, 1.00];


color(part_color)
difference() {
    cuboid([block_x, block_y, block_z], chamfer=chamfer, edges="Z", anchor=BOTTOM);

    if (show_hole)
        up(block_z + 0.05)
            screw_hole(screw_spec, length=block_z + 0.2, anchor=TOP);
}
