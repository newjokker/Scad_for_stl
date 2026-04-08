include <BOSL2/std.scad>

$fn = 200;              // 圆形细分精度

L = 30;
offset = 10;
H = 2;

// 文字参数
txt_size = 4;
txt_h = 0.6;            // 文字挤出高度
txt_gap = 2;            // 文字离角的距离

module label_txt(str, x, y) {
    translate([x, y, H])
        linear_extrude(height = txt_h)
            text(str, size = txt_size, halign = "center", valign = "center");
}

// 左下角：rounding = 3
cuboid(
    [L, L, H],
    rounding = 3,
    edges = [LEFT+FRONT, RIGHT+FRONT, LEFT+BACK, RIGHT+BACK],
    anchor = [-1, -1, -1]
);

// 右上角：rounding = 3.3
translate([offset, offset, 0])
    cuboid(
        [L, L, H],
        rounding = 3.3,
        edges = [LEFT+FRONT, RIGHT+FRONT, LEFT+BACK, RIGHT+BACK],
        anchor = [-1, -1, -1]
    );

// 左上角：rounding = 3.6
translate([0, offset, 0])
    cuboid(
        [L, L, H],
        rounding = 3.6,
        edges = [LEFT+FRONT, RIGHT+FRONT, LEFT+BACK, RIGHT+BACK],
        anchor = [-1, -1, -1]
    );

// 右下角：rounding = 4
translate([offset, 0, 0])
    cuboid(
        [L, L, H],
        rounding = 4,
        edges = [LEFT+FRONT, RIGHT+FRONT, LEFT+BACK, RIGHT+BACK],
        anchor = [-1, -1, -1]
    );


// ===== 标注 =====
// 只在最终露出来的四个角附近标注
label_txt("r=3",   txt_gap + 4,           txt_gap + 4);
label_txt("r=4",   offset + L - 12,        txt_gap + 4);
label_txt("r=3.6", txt_gap + 6,           offset + L - 4);
label_txt("r=3.3", offset + L - 12,        offset + L - 4);