include <BOSL2/std.scad>
include <BOSL2/modular_hose.scad>

// 3D 打印模块化柔性软管组件。
// 使用 BOSL2 modular_hose() 生成可拼接的球窝关节软管段（segment），
// 支持 1/4、3/8、1/2 等标准尺寸，可多段串联组装成任意长度和弯曲角度的管道。
// 适用于冷却液管、真空吸尘管头、摄像头/灯具的万向支架、柔性布线管等场景。
// 可直接复制模块调用到具体模型中使用。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 64;

// 软管标准尺寸
hose_size = 1/2;
// 结构类型
hose_type = "segment";
// 配合间隙
clearance = 0.06;
// 中间腰部长度
waist_len = 8;

part_color = [0.95, 0.55, 0.16, 1.00];


color(part_color)
modular_hose(
    size=hose_size,
    type=hose_type,
    clearance=clearance,
    waist_len=waist_len,
    anchor=BOTTOM
);
