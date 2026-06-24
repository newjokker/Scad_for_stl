include <BOSL2/std.scad>
include <BOSL2/sliders.scad>

// 3D 打印线性滑轨与滑块组件。
// 使用 BOSL2 rail() 和 slider() 生成免支撑燕尾形滑轨及匹配滑块，
// 滑块底部带过桥间隙和免支撑斜面角度（overhang_angle）。
// 适用于线性导向、抽屉滑道、可调夹具等需要直线运动的场景。
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
