include <BOSL2/std.scad>
include <BOSL2/screws.scad>

// BOSL2螺母陷阱 示例。
// 每个文件只展示一个 BOSL2 常用结构，顶部参数用于快速调整尺寸和显示形式。
// 可直接复制模块调用到具体模型中使用。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 48;
// 打印配合间隙
$slop = 0.12;

// 测试块长
block_x = 42;
// 测试块宽
block_y = 30;
// 测试块高
block_z = 16;
// 螺母规格
nut_spec = "M4";
// 侧插陷阱深度
trap_width = 18;
// 顶出孔长度
poke_len = 10;
// 是否显示减料形状
show_mask = true;

body_color = [0.78, 0.80, 0.76, 1.00];
mask_color = [0.18, 0.48, 0.78, 0.35];


color(body_color)
difference() {
    cuboid([block_x, block_y, block_z], rounding=1.2, edges="Z", anchor=BOTTOM);

    translate([0, 0, block_z / 2])
        nut_trap_side(
            trap_width=trap_width,
            spec=nut_spec,
            poke_len=poke_len,
            anchor=CENTER
        );
}

if (show_mask)
    color(mask_color)
    translate([0, 0, block_z / 2])
        nut_trap_side(
            trap_width=trap_width,
            spec=nut_spec,
            poke_len=poke_len,
            anchor=CENTER
        );
