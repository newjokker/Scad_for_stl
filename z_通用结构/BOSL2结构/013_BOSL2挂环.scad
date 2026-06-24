include <BOSL2/std.scad>
include <BOSL2/hooks.scad>

// 3D 打印墙壁挂环组件。
// 使用 BOSL2 ring_hook() 生成带底座的圆形挂环，底部可螺丝固定，环内可穿绳、挂线或钩挂物品。
// 支持自定义环外径/内径、底座尺寸和圆角过渡。
// 适用于墙面挂架、线缆管理架、挂绳孔等需要悬挂固定的场景。
// 可直接复制模块调用到具体模型中使用。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 64;

// 底座宽度
base_x = 42;
// 底座厚度
base_y = 10;
// 孔中心高度
hole_z = 28;
// 外圆直径
outer_diam = 34;
// 内孔直径，0 表示实心
inner_diam = 18;
// 边缘圆角
rounding = 1.2;
// 底部过渡圆角
fillet = 2;

part_color = [0.78, 0.80, 0.76, 1.00];


color(part_color)
ring_hook(
    base_size=[base_x, base_y],
    hole_z=hole_z,
    od=outer_diam,
    id=inner_diam,
    rounding=rounding,
    fillet=fillet,
    hole_rounding=rounding,
    anchor=BOTTOM
);
