include <BOSL2/std.scad>
include <BOSL2/walls.scad>

$fn = 48;

spacing = 58;
row_gap = 42;   // 两排之间的间距


// ===== 第一排：镂空支撑墙 =====
translate([0, 0, 0])
xdistribute(spacing=spacing) {

    sparse_wall(h=32, l=48, thick=3, strut=4, maxang=30);
    sparse_wall(h=32, l=48, thick=3, strut=3, maxang=45);
    sparse_wall(h=32, l=48, thick=4, strut=4, max_bridge=28);
}


// ===== 第二排：蜂窝板 =====
translate([0, -row_gap, 0])
xdistribute(spacing=spacing) {

    hex_panel([42, 42, 1], strut=0.5, spacing=5, frame=1);
    hex_panel([42, 32, 4], strut=1.5, spacing=9, frame=4);
    hex_panel([42, 42, 5], strut=1.5, spacing=10, frame=5, bevel=[FWD, BACK, LEFT, RIGHT]);
}


// ===== 第三排：波纹墙和薄壁加强 =====
translate([0, -row_gap * 2, 0])
xdistribute(spacing=spacing) {

    corrugated_wall(h=32, l=48, thick=6, strut=5, wall=2);
    thinning_wall(h=32, l=48, thick=6, strut=4, wall=2);
    thinning_wall(h=32, l=[50, 32], thick=6,
        strut=4, wall=2, braces=true);
}


// ===== 第四排：立体减重块和支撑筋 =====
translate([0, -row_gap * 3, 0])
xdistribute(spacing=spacing) {

    sparse_cuboid([32, 42, 18], dir=UP, strut=3, max_bridge=18);
    sparse_cuboid([32, 42, 18], dir=RIGHT, strut=3, max_bridge=18);
    narrowing_strut(w=12, l=42, wall=4, ang=30);
}
