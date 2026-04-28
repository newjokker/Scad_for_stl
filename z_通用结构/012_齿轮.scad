include <BOSL2/std.scad>
include <BOSL2/gears.scad>

$fn = 80;

spacing = 100;
row_gap = 100;      // 两排之间的间距
mod_size = 1.5;    // 常用公制模数
pa = 20;           // 常用压力角
thick = 8;         // 齿轮厚度
shaft = 6;         // 轴孔直径


// ===== 第一排：圆柱齿轮 =====
translate([0, 0, 0])
xdistribute(spacing=spacing) {

    // 直齿圆柱齿轮
    spur_gear(mod=mod_size, teeth=20, thickness=thick,
        shaft_diam=shaft, pressure_angle=pa);

    // 小齿数直齿轮
    spur_gear(mod=mod_size, teeth=12, thickness=thick,
        shaft_diam=shaft, pressure_angle=pa);

    // 大齿数直齿轮
    spur_gear(mod=mod_size, teeth=32, thickness=thick,
        shaft_diam=shaft, pressure_angle=pa);

    // 斜齿轮
    spur_gear(mod=mod_size, teeth=24, thickness=thick,
        shaft_diam=shaft, pressure_angle=pa, helical=20);

    // 人字齿轮
    spur_gear(mod=mod_size, teeth=24, thickness=thick,
        shaft_diam=shaft, pressure_angle=pa, helical=25, herringbone=true);
}


// ===== 第二排：内齿圈和齿条 =====
translate([0, -row_gap, 0])
xdistribute(spacing=spacing) {

    // 内齿圈
    ring_gear(mod=mod_size, teeth=42, thickness=thick,
        backing=5, pressure_angle=pa);

    // 加宽外圈的内齿圈
    ring_gear(mod=mod_size, teeth=42, thickness=thick,
        backing=10, pressure_angle=pa);

    // 斜内齿圈
    ring_gear(mod=mod_size, teeth=42, thickness=thick,
        backing=5, pressure_angle=pa, helical=20);

    // 直齿齿条
    rack(mod=mod_size, teeth=12, thickness=thick,
        bottom=8, pressure_angle=pa);

    // 斜齿齿条
    rack(mod=mod_size, teeth=12, thickness=thick,
        bottom=8, pressure_angle=pa, helical=20);
}


// ===== 第三排：常见啮合组合 =====
translate([0, -row_gap * 2, 0])
xdistribute(spacing=spacing) {

    // 一对直齿轮
    gear_pair(teeth1=20, teeth2=30);

    // 齿轮齿条
    rack_and_pinion();

    // 冠状齿轮和小齿轮
    crown_and_pinion();

    // 锥齿轮
    bevel_gear(teeth=24, mate_teeth=24, mod=mod_size,
        face_width=8, shaft_diam=shaft, pressure_angle=pa);

    // 锥齿轮，齿数比 2:1
    bevel_gear(teeth=16, mate_teeth=32, mod=mod_size,
        face_width=8, shaft_diam=shaft, pressure_angle=pa);
}


// ===== 第四排：蜗杆蜗轮 =====
translate([0, -row_gap * 3, 0])
xdistribute(spacing=spacing) {

    // 蜗杆
    worm(mod=mod_size, d=14, l=34, starts=1,
        pressure_angle=pa, orient=RIGHT);

    // 多头蜗杆
    worm(mod=mod_size, d=16, l=34, starts=2,
        pressure_angle=pa, orient=RIGHT);

    // 蜗轮
    worm_gear(mod=mod_size, teeth=32, worm_diam=14,
        worm_starts=1, shaft_diam=shaft, pressure_angle=pa);

    // 蜗杆蜗轮组合
    worm_drive();
}


module gear_pair(teeth1=20, teeth2=30) {
    dist = gear_dist(mod=mod_size, teeth1=teeth1, teeth2=teeth2);

    left(dist / 2)
    spur_gear(mod=mod_size, teeth=teeth1, thickness=thick,
        shaft_diam=shaft, pressure_angle=pa);

    right(dist / 2)
    zrot(180 / teeth2)
    spur_gear(mod=mod_size, teeth=teeth2, thickness=thick,
        shaft_diam=shaft, pressure_angle=pa);
}


module rack_and_pinion(teeth=18) {
    dist = gear_dist(mod=mod_size, teeth1=teeth, teeth2=0);

    fwd(10)
    rack(mod=mod_size, teeth=11, thickness=thick,
        bottom=8, pressure_angle=pa);

    back(dist - 10)
    spur_gear(mod=mod_size, teeth=teeth, thickness=thick,
        shaft_diam=shaft, pressure_angle=pa);
}


module crown_and_pinion() {
    cteeth = 32;
    pteeth = 14;
    cpr = pitch_radius(mod=mod_size, teeth=cteeth);
    ppr = pitch_radius(mod=mod_size, teeth=pteeth);

    crown_gear(mod=mod_size, teeth=cteeth, backing=4,
        face_width=6, pressure_angle=pa);

    back(cpr + 3)
    up(ppr)
    spur_gear(mod=mod_size, teeth=pteeth, thickness=6,
        shaft_diam=shaft, pressure_angle=pa, orient=BACK,
        gear_spin=180 / pteeth);
}


module worm_drive() {
    wdiam = 14;
    wteeth = 32;
    dist = gear_dist(mod=mod_size, teeth1=wteeth, teeth2=0) + wdiam / 2;

    worm_gear(mod=mod_size, teeth=wteeth, worm_diam=wdiam,
        worm_starts=1, shaft_diam=shaft, pressure_angle=pa);

    back(dist)
    up(4)
    worm(mod=mod_size, d=wdiam, l=32, starts=1,
        pressure_angle=pa, orient=RIGHT);
}
