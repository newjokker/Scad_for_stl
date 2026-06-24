include <BOSL2/std.scad>
include <BOSL2/tripod_mounts.scad>

// 3D 打印 Manfrotto RC2 快装板。
// 使用 BOSL2 manfrotto_rc2_plate() 生成标准摄影器材快装板，
// 可卡入 RC2 型云台底座，可选倒角模式（chamfer）。
// 适用于三脚架快装系统、摄影支架配件、需要标准快装接口的安装座等场景。
// 可直接复制模块调用到具体模型中使用。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 48;

// 倒角模式
chamfer_mode = "all";

part_color = [0.78, 0.80, 0.76, 1.00];


color(part_color)
manfrotto_rc2_plate(
    chamfer=chamfer_mode,
    anchor=BOTTOM
);
