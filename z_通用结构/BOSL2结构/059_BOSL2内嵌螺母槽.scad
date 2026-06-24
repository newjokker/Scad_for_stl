include <BOSL2/std.scad>
include <BOSL2/screws.scad>

// 3D 打印常用内嵌螺母槽结构。
// 使用 nut_trap_inline() 从孔轴方向嵌入螺母，适合厚壁件和端面锁紧结构。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 48;
// 打印配合间隙
$slop = 0.12;

// 测试块长，单位 mm
block_x = 34;
// 测试块宽，单位 mm
block_y = 34;
// 测试块高，单位 mm
block_z = 22;
// 螺母规格
nut_spec = "M4";
// 螺母槽深度，单位 mm
trap_length = 8;
// 是否显示减料形状
show_mask = true;

body_color = [0.78, 0.80, 0.76, 1.00];
mask_color = [0.18, 0.48, 0.78, 0.35];


color(body_color)
difference() {
    cuboid([block_x, block_y, block_z], rounding=1.2, edges="Z", anchor=BOTTOM);

    up(block_z + 0.05)
        nut_trap_inline(
            length=trap_length,
            spec=nut_spec,
            anchor=TOP
        );

    up(block_z + 0.05)
        screw_hole(nut_spec, length=block_z + 0.2, anchor=TOP);
}

if (show_mask)
    color(mask_color)
    up(block_z + 0.05)
        nut_trap_inline(
            length=trap_length,
            spec=nut_spec,
            anchor=TOP
        );
