include <BOSL2/std.scad>
include <BOSL2/joiners.scad>

// BOSL2燕尾槽 示例。
// 每个文件只展示一个 BOSL2 常用结构，顶部参数用于快速调整尺寸和显示形式。
// 可直接复制模块调用到具体模型中使用。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 48;
// 打印配合间隙
$slop = 0.18;

// 基座长度
block_length = 48;
// 基座宽度
block_width = 28;
// 基座厚度
block_thick = 8;
// 燕尾宽度
dovetail_width = 15;
// 燕尾高度
dovetail_height = 5;
// 滑入长度
slide_length = 30;
// 燕尾斜率
slope = 6;
// 锥度角
taper = 0;
// 展示间距
exploded_gap = 18;

body_color = [0.78, 0.80, 0.76, 1.00];
male_color = [0.95, 0.55, 0.16, 1.00];
female_color = [0.18, 0.48, 0.78, 1.00];


simple_dovetail_pair();


module simple_dovetail_pair() {
    left(block_length / 2 + exploded_gap / 2)
        male_block();

    right(block_length / 2 + exploded_gap / 2)
        female_block();
}


module male_block() {
    color(body_color)
    cuboid([block_length, block_width, block_thick], rounding=1,
        edges="Z", anchor=BOTTOM);

    color(male_color)
    up(block_thick)
        dovetail(
            "male",
            width=dovetail_width,
            height=dovetail_height,
            slide=slide_length,
            slope=slope,
            taper=taper,
            anchor=BOTTOM
        );
}


module female_block() {
    color(body_color)
    difference() {
        cuboid([block_length, block_width, block_thick], rounding=1,
            edges="Z", anchor=BOTTOM);

        up(block_thick)
            dovetail(
                "female",
                width=dovetail_width,
                height=dovetail_height,
                slide=slide_length,
                slope=slope,
                taper=taper,
                anchor=BOTTOM
            );
    }

    // 右侧半透明蓝色是对应的减料形状，实际使用时放进 difference()。
    color([female_color.x, female_color.y, female_color.z, 0.35])
    up(block_thick + 0.03)
        dovetail(
            "female",
            width=dovetail_width,
            height=dovetail_height,
            slide=slide_length,
            slope=slope,
            taper=taper,
            anchor=BOTTOM
        );
}
