include <BOSL2/std.scad>

// 3D 打印刻度尺组件。
// 使用 BOSL2 ruler() 生成带刻度和可选数字标签的实体尺，刻度为凹陷槽。
// 适用于打印尺寸校准测试件、模型中的比例参考尺、DIY 测量工具等场景。
// 可直接复制模块调用到具体模型中使用。

// ---------------- 可调参数 ----------------
// 尺子长度，单位 mm
ruler_length = 100;
// 尺子宽度，单位 mm
ruler_width = 16;
// 尺子厚度，单位 mm
ruler_thick = 2;
// 刻度深度，单位 mm
mark_depth = 1.2;
// 是否显示数字标签
show_labels = true;

part_color = [0.78, 0.80, 0.76, 1.00];


color(part_color)
ruler(
    length=ruler_length,
    width=ruler_width,
    thickness=ruler_thick,
    depth=mark_depth,
    labels=show_labels,
    anchor=BOTTOM
);
