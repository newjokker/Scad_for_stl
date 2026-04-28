include <BOSL2/std.scad>
include <BOSL2/ball_bearings.scad>

$fn = 48;

spacing = 34;
row_gap = 30;   // 两排之间的间距


// ===== 第一排：常见标准轴承 =====
translate([0, 0, 0])
xdistribute(spacing=spacing) {

    ball_bearing("629ZZ");
    ball_bearing("608ZZ");
    ball_bearing("6000ZZ");
    ball_bearing("6201ZZ");
    ball_bearing("6902ZZ");
}


// ===== 第二排：小型和法兰轴承 =====
translate([0, -row_gap, 0])
xdistribute(spacing=spacing) {

    ball_bearing("635ZZ");
    ball_bearing("MF105ZZ");
    ball_bearing("MF128ZZ");
    ball_bearing("F6800ZZ");
    ball_bearing("R8ZZ");
}


// ===== 第三排：自定义尺寸 =====
translate([0, -row_gap * 2, 0])
xdistribute(spacing=spacing) {

    ball_bearing(id=5, od=16, width=5, shield=true, rounding=0.3);
    ball_bearing(id=8, od=22, width=7, shield=true, rounding=0.4);
    ball_bearing(id=12, od=24, width=6, shield=true,
        flange=true, fd=26.5, fw=1.5, rounding=0.5);
    ball_bearing(id=15, od=32, width=9, shield=true, rounding=0.5);
}
