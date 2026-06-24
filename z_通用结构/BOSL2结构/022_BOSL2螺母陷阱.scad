include <BOSL2/std.scad>
include <BOSL2/screws.scad>

// 3D 打印侧插螺母陷阱槽。
// 使用 BOSL2 nut_trap_side() 在零件内部挖出从侧面滑入的螺母容槽，
// 螺母从侧边推入后被槽壁限位，螺丝从顶部穿过锁紧。
// 适用于薄壁件侧面嵌入螺母、型材内部螺母预埋、无需热熔铜螺母的紧固方案。
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
