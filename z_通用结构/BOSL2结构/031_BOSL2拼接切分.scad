include <BOSL2/std.scad>
include <BOSL2/partitions.scad>

// BOSL2拼接切分 示例。
// 每个文件只展示一个 BOSL2 常用结构，顶部参数用于快速调整尺寸和显示形式。
// 可直接复制模块调用到具体模型中使用。

// ---------------- 可调参数 ----------------
// 圆弧细分
$fn = 48;
// 拼接间隙
$slop = 0.12;

// 物体长
object_x = 70;
// 物体宽
object_y = 42;
// 物体高
object_z = 18;
// 两半展示间距
spread = 16;
// 拼接齿尺寸
cut_size = 8;
// 参数范围
cut_path = "jigsaw";

part_a_color = [0.95, 0.55, 0.16, 1.00];
part_b_color = [0.18, 0.48, 0.78, 1.00];


partition(
    size=[object_x, object_y, object_z],
    spread=spread,
    cutsize=cut_size,
    cutpath=cut_path
) {
    color($idx == 0 ? part_a_color : part_b_color)
        cuboid([object_x, object_y, object_z],
            rounding=2, edges="Z", anchor=CENTER);
}
