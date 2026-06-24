include <BOSL2/std.scad>

// 3D 打印立体文字/浮雕标签组件。
// 使用 BOSL2 text3d() 生成可附着于表面的立体文字，支持自定义字体、大小、厚度和间距。
// 适用于产品铭牌、方向标识、门牌、装饰文字、浮雕标签等场景。
// 可直接复制模块调用到具体模型中使用。

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
