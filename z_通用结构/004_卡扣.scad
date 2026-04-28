include <BOSL2/std.scad>
include <BOSL2/hinges.scad>
include <BOSL2/joiners.scad>

$fn = 48;

spacing = 46;
row_gap = 38;   // 两排之间的间距

wall = 3;       // 盒子壁厚
gap = 0.25;     // 打印间隙


// ===== 第一排：BOSL2 盒盖扣锁 =====
translate([0, 0, 0])
xdistribute(spacing=spacing) {

    snap_lock(thick=wall, snaplen=8, snapdiam=5, foldangle=90);
    snap_socket(thick=wall, snaplen=8, snapdiam=5, foldangle=90, $slop=gap);
    snap_lock(thick=wall, snaplen=12, snapdiam=5, foldangle=75);
    snap_socket(thick=wall, snaplen=12, snapdiam=5, foldangle=75, $slop=gap);
}


// ===== 第二排：可按压拆卸的弹性卡扣 =====
translate([0, -row_gap, 0])
xdistribute(spacing=spacing) {

    rabbit_clip("pin", length=18, width=14, snap=1.2,
        thickness=1.2, depth=6, compression=0.3);

    rabbit_clip("socket", length=18, width=14, snap=1.2,
        thickness=1.2, depth=6.5, clearance=gap, orient=UP);

    rabbit_clip("pin", length=22, width=18, snap=1.6,
        thickness=1.4, depth=7, compression=0.2, lock=true,
        lock_clearance=2);

    rabbit_clip("socket", length=22, width=18, snap=1.6,
        thickness=1.4, depth=7.5, clearance=gap, lock=true,
        lock_clearance=2, orient=UP);
}


// ===== 第三排：上下盒体边缘示意 =====
translate([0, -row_gap * 2, 0])
xdistribute(spacing=spacing * 1.5) {

    snap_box_edge();
    rabbit_box_edge();
}


module snap_box_edge() {
    // 下半盒边缘
    color("lightgray")
    cuboid([56, 30, wall], anchor=BOTTOM);

    color("silver")
    fwd(18)
    up(wall)
    snap_socket(thick=wall, snaplen=10, snapdiam=5,
        foldangle=90, anchor=BOTTOM, $slop=gap);

    // 上半盒边缘，抬高展示，实际使用时扣到下半盒上
    color("gainsboro")
    up(18)
    cuboid([56, 30, wall], anchor=BOTTOM);

    color("orange")
    up(18 + wall)
    fwd(18)
    snap_lock(thick=wall, snaplen=10, snapdiam=5,
        foldangle=90, anchor=BOTTOM);
}


module rabbit_box_edge() {
    // 下半盒边缘
    color("lightgray")
    cuboid([56, 30, wall], anchor=BOTTOM);

    color("silver")
    fwd(18)
    up(wall)
    rabbit_clip("socket", length=18, width=14, snap=1.2,
        thickness=1.2, depth=6.5, clearance=gap, orient=UP);

    // 上半盒边缘，抬高展示，实际使用时按压卡入下半盒
    color("gainsboro")
    up(18)
    cuboid([56, 30, wall], anchor=BOTTOM);

    color("orange")
    up(18 + wall)
    fwd(18)
    rabbit_clip("pin", length=18, width=14, snap=1.2,
        thickness=1.2, depth=6, compression=0.3);
}
