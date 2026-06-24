include <BOSL2/std.scad>
include <BOSL2/joiners.scad>

// 3D 打印燕尾槽滑配连接组件。
// 使用 BOSL2 dovetail() 生成公母燕尾槽对，公头滑入母槽实现可拆卸连接，
// 支持锥度锁紧（taper）和斜面（slope）参数。
// 适用于需要频繁拆装的面板连接、模块接口、抽屉滑轨等场景。
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
