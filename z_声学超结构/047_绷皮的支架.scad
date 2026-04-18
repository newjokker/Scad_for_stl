include <BOSL2/std.scad>

$fn = 200;

length      = 120; 
width       = 80;
height      = 50;
thickness   = 10; 


module rect_frame_support(len=120, wid=80, hei=50, t=7) {

    union() {
        // =========================
        // 4 根竖直立柱
        // =========================
        for (x = [-len/2 + t/2, len/2 - t/2])
            for (y = [-wid/2 + t/2, wid/2 - t/2])
                translate([x, y, 0])
                    cuboid([t, t, hei], anchor=CENTER);

        // =========================
        // 顶部前后两根（X方向）
        // =========================
        for (y = [-wid/2 + t/2, wid/2 - t/2])
            translate([0, y, hei/2 - t/2])
                cuboid([len, t, t], anchor=CENTER);

        // =========================
        // 底部前后两根（X方向）
        // =========================
        for (y = [-wid/2 + t/2, wid/2 - t/2])
            translate([0, y, -hei/2 + t/2])
                cuboid([len, t, t], anchor=CENTER);

        // =========================
        // 顶部左右两根（Y方向）
        // =========================
        for (x = [-len/2 + t/2, len/2 - t/2])
            translate([x, 0, hei/2 - t/2])
                cuboid([t, wid, t], anchor=CENTER);

        // =========================
        // 底部左右两根（Y方向）
        // =========================
        for (x = [-len/2 + t/2, len/2 - t/2])
            translate([x, 0, -hei/2 + t/2])
                cuboid([t, wid, t], anchor=CENTER);
    }
}


// 渲染
rect_frame_support(
    len = length,
    wid = width,
    hei = height,
    t = thickness
);