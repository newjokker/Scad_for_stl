include <BOSL2/std.scad>
include <BOSL2/partitions.scad>

// 3D 打印大件拼图切分工具。
// 使用 BOSL2 partition() 将一个物体沿 X/Y/Z 方向切分为两半，切口处可生成
// 互锁的锯齿形（jigsaw）连接面，实现免胶水精准对位拼装。
// 适用于超出打印床尺寸的大件拆分、需要多次拆装的模块、拼图式组装件等场景。
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
