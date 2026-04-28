include <BOSL2/std.scad>

$fn = 48;

spacing = 58;
row_gap = 42;   // 两排之间的间距

slop = 0.25;    // 打印间隙
wall = 2.4;     // 盒子壁厚


// ===== 第一排：矩形弹片公扣 =====
translate([0, 0, 0])
xdistribute(spacing=spacing) {

    snap_fit_latch(l=24, w=8, t=1.6, hook_h=2.4);
    snap_fit_latch(l=32, w=8, t=1.8, hook_h=2.8);
    snap_fit_latch(l=38, w=10, t=2.0, hook_h=3.2);
    snap_fit_latch(l=32, w=12, t=1.8, hook_h=2.8, relief=true);
}


// ===== 第二排：母扣座 / 扣槽 =====
translate([0, -row_gap, 0])
xdistribute(spacing=spacing) {

    snap_fit_socket(l=28, w=8, catch_h=2.6);
    snap_fit_socket(l=36, w=8, catch_h=3.0);
    snap_fit_socket(l=42, w=10, catch_h=3.4);
    snap_fit_socket(l=36, w=12, catch_h=3.0, side_wall=3);
}


// ===== 第三排：盒子边缘连接示意 =====
translate([0, -row_gap * 2, 0])
xdistribute(spacing=spacing * 1.55) {

    box_latch_exploded();
    box_latch_engaged();
}


// 矩形悬臂弹片公扣。X 方向为插入方向，末端向下的斜坡钩用于扣住母扣座。
module snap_fit_latch(
    l=32,
    w=8,
    t=1.8,
    base_l=9,
    base_h=5,
    hook_l=6,
    hook_h=3,
    relief=false
) {
    difference() {
        union() {
            // 安装根部
            translate([-base_l, -w / 2, 0])
                cube([base_l, w, base_h]);

            // 弹性悬臂
            translate([-0.05, -w / 2, base_h - 0.05])
                cube([l + 0.05, w, t + 0.05]);

            // 末端倒钩，前面是导入斜坡，后面是垂直止退面
            latch_hook(l=l, w=w, base_z=base_h, hook_l=hook_l, hook_h=hook_h);
        }

        if (relief) {
            // 根部释放槽，让弹片更容易弯曲
            translate([2, -w / 2 - 0.1, base_h - 0.25])
                cube([8, w + 0.2, t + 0.6]);
        }
    }
}


module latch_hook(l=32, w=8, base_z=5, hook_l=6, hook_h=3) {
    x0 = l - hook_l;
    x1 = l;
    y0 = -w / 2;
    y1 = w / 2;
    z0 = base_z - hook_h;
    z1 = base_z + 0.05;

    polyhedron(
        points=[
            [x0, y0, z1], [x1, y0, z1], [x0, y0, z0],
            [x0, y1, z1], [x1, y1, z1], [x0, y1, z0]
        ],
        faces=[
            [0, 1, 2],
            [3, 5, 4],
            [0, 3, 4, 1],
            [0, 2, 5, 3],
            [1, 4, 5, 2]
        ]
    );
}


// 母扣座。两侧导向，中间留给弹片，末端凸台供倒钩扣住。
module snap_fit_socket(
    l=36,
    w=8,
    base_t=3,
    side_wall=2.5,
    catch_l=4,
    catch_h=3,
    clearance=slop
) {
    outer_w = w + side_wall * 2 + clearance * 2;

    union() {
        // 底板
        translate([0, -outer_w / 2, 0])
            cube([l, outer_w, base_t]);

        // 两侧导向墙
        translate([0, -outer_w / 2, base_t - 0.05])
            cube([l, side_wall, catch_h + 2.05]);

        translate([0, outer_w / 2 - side_wall, base_t - 0.05])
            cube([l, side_wall, catch_h + 2.05]);

        // 止退凸台
        translate([l - catch_l, -outer_w / 2, base_t - 0.05])
            cube([catch_l, outer_w, catch_h + 0.05]);
    }
}


module box_latch_exploded() {
    socket_l = 38;
    latch_l = 32;
    latch_w = 9;

    // 下半盒边缘
    color("gainsboro")
    translate([0, 0, 0])
        cube([58, 28, wall], center=true);

    color("silver")
    translate([-socket_l / 2, 0, wall / 2])
        snap_fit_socket(l=socket_l, w=latch_w, catch_h=3, clearance=slop);

    // 上盖边缘，抬高显示
    color("lightgray")
    translate([0, 0, 18])
        cube([58, 28, wall], center=true);

    color("orange")
    translate([-latch_l / 2, 0, 18 - 5.4])
        snap_fit_latch(l=latch_l, w=latch_w, t=1.8, hook_h=3, relief=true);
}


module box_latch_engaged() {
    socket_l = 38;
    latch_l = 32;
    latch_w = 9;

    // 下半盒边缘
    color("gainsboro")
    translate([0, 0, 0])
        cube([58, 28, wall], center=true);

    color("silver")
    translate([-socket_l / 2, 0, wall / 2])
        snap_fit_socket(l=socket_l, w=latch_w, catch_h=3, clearance=slop);

    // 上盖边缘，靠近扣合位置
    color("lightgray")
    translate([0, 0, 8])
        cube([58, 28, wall], center=true);

    color("orange")
    translate([-latch_l / 2, 0, 2.9])
        snap_fit_latch(l=latch_l, w=latch_w, t=1.8, hook_h=3, relief=true);
}
