include <BOSL2/std.scad>
include <BOSL2/screws.scad>

$fn = 80;

spacing = 18;
row_gap = 25;   // 两排之间的间距

// ===== 第一排：螺丝 =====
translate([0, 0, 0])
xdistribute(spacing=spacing) {

    screw("M6", length=20, head="hex");
    screw("M6", length=20, head="socket", drive="hex");
    screw("M6", length=20, head="button", drive="hex");
    screw("M6", length=20, head="pan", drive="phillips");
    screw("M6", length=20, head="pan", drive="slot");
    screw("M6", length=20, head="flat", drive="phillips");
    screw("M6", length=20, head="flat", drive="hex");
    screw("M6", length=12, head="none", drive="hex");
    screw("M6", length=20, head="button", drive="torx");
}


// ===== 第二排：螺母 =====
translate([0, -row_gap, 0])   // 👈 往下移一排
xdistribute(spacing=spacing) {

    nut("M6", thickness="normal");
    nut("M6", thickness="thin");
    nut("M6", thickness="thick");
    nut("M6", thickness="DIN");
    nut("M6", shape="square");
}