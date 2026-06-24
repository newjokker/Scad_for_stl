include <BOSL2/std.scad>

// BOSL2 尺子结构示例。
// 使用 ruler() 生成带刻度的实体尺，可作为模型中的校准标尺或打印测试件。

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
