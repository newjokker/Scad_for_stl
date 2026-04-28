include <BOSL2/std.scad>

$fn = 40;

// 简约风 + 高科技感 + 浑然一体
// 一个整体成型的“未来梭核”：连续圆角主体、浅切线、隐藏光带、悬浮底缝。

body_l = 86;
body_w = 38;
body_h = 18;


color("#DDE6EA")
# monolith_body();

color("#70F5FF")
light_slot();

color("#AEB9C2")
top_panel();

color("#121820")
hover_shadow();


module monolith_body() {
    difference() {
        rounded_capsule_body(l=body_l, w=body_w, h=body_h);

        // 中腰隐藏光带槽
        translate([0, 0, body_h * 0.48])
        rounded_capsule_body(l=body_l - 8, w=body_w - 7, h=3.2);

        // 顶部无按钮触控嵌面
        translate([0, 0, body_h - 1.1])
        rounded_capsule_body(l=body_l * 0.56, w=body_w * 0.44, h=2.6);

        // 两条非常浅的侧向削线，增加精密感
        xcopies(spacing=body_l * 0.54, n=2)
        translate([0, 0, body_h * 0.65])
        cuboid([2.2, body_w + 4, 4], chamfer=0.8, edges="Z");

        // 底部削平
        down(7)
        cuboid([body_l + 10, body_w + 10, 14]);
    }
}


module light_slot() {
    translate([0, 0, body_h * 0.49])
    difference() {
        rounded_capsule_body(l=body_l - 10, w=body_w - 9, h=1.2);
        rounded_capsule_body(l=body_l - 17, w=body_w - 16, h=1.6);
    }
}


module top_panel() {
    translate([0, 0, body_h - 0.55])
    rounded_capsule_body(l=body_l * 0.50, w=body_w * 0.36, h=0.9);
}


module hover_shadow() {
    down(0.65)
    rounded_capsule_body(l=body_l * 0.74, w=body_w * 0.54, h=0.7);
}


module rounded_capsule_body(l=80, w=36, h=16) {
    hull() {
        xcopies(spacing=l - w, n=2)
        cyl(h=h, d=w, anchor=BOTTOM);
    }
}
