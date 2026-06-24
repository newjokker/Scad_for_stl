include <BOSL2/std.scad>

// BOSL2 立体文字结构示例。
// 使用 text3d() 生成可附着的浮雕文字，可用于标签、铭牌和方向标识。

// ---------------- 可调参数 ----------------
// 文字内容
label_text = "BOSL2";
// 字体大小，单位 mm
text_size = 18;
// 文字厚度，单位 mm
text_height = 3;
// 字符间距倍率
text_spacing = 1.0;

part_color = [0.95, 0.55, 0.16, 1.00];


color(part_color)
text3d(
    text=label_text,
    size=text_size,
    h=text_height,
    spacing=text_spacing,
    font="Arial:style=Bold",
    anchor=CENTER
);
