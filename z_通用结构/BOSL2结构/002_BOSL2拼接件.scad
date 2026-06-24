include <BOSL2/std.scad>
include <BOSL2/joiners.scad>

// BOSL2拼接件 示例。
// 每个文件只展示一个 BOSL2 常用结构，顶部参数用于快速调整尺寸和显示形式。
// 可直接复制模块调用到具体模型中使用。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 48;
// 打印配合间隙
$slop = 0.18;

// 单个拼接件长度
joiner_length = 28;
// 拼接件宽度
joiner_width = 12;
// 背板厚度
joiner_base = 8;
// 斜面角度
joiner_angle = 30;
// 螺丝孔直径，0 表示无孔
screw_diam = 3;
// 展示间距
exploded_gap = 18;

body_color = [0.78, 0.80, 0.76, 1.00];
part_a_color = [0.95, 0.55, 0.16, 1.00];
part_b_color = [0.18, 0.48, 0.78, 1.00];


simple_joiner_pair();


module simple_joiner_pair() {
    screw = screw_diam > 0 ? screw_diam : undef;

    color(part_a_color)
    left(exploded_gap / 2)
        half_joiner(
            l=joiner_length,
            w=joiner_width,
            base=joiner_base,
            ang=joiner_angle,
            screwsize=screw
        );

    color(part_b_color)
    right(exploded_gap / 2)
        half_joiner2(
            l=joiner_length,
            w=joiner_width,
            base=joiner_base,
            ang=joiner_angle,
            screwsize=screw
        );
}
