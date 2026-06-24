include <BOSL2/std.scad>
include <BOSL2/sliders.scad>

// BOSL2滑轨滑块 示例。
// 每个文件只展示一个 BOSL2 常用结构，顶部参数用于快速调整尺寸和显示形式。
// 可直接复制模块调用到具体模型中使用。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 48;
// 打印配合间隙
$slop = 0.18;

// 滑轨长度
rail_length = 70;
// 滑轨宽度
rail_width = 12;
// 滑轨高度
rail_height = 8;
// 滑块长度
slider_length = 34;
// 滑块底座高度
slider_base = 7;
// 滑块侧壁厚度
slider_wall = 4;
// 免支撑斜面角度
overhang_angle = 30;
// 展示抬高距离
exploded_height = 20;

rail_color = [0.78, 0.80, 0.76, 1.00];
slider_color = [0.95, 0.55, 0.16, 1.00];


simple_slider_rail();


module simple_slider_rail() {
    color(rail_color)
    rail(
        l=rail_length,
        w=rail_width,
        h=rail_height,
        ang=overhang_angle,
        anchor=BOTTOM
    );

    color(slider_color)
    up(rail_height + exploded_height)
        slider(
            l=slider_length,
            w=rail_width,
            h=rail_height,
            base=slider_base,
            wall=slider_wall,
            ang=overhang_angle,
            anchor=BOTTOM
        );
}
