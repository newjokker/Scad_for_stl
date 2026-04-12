include <BOSL2/std.scad>
include <BOSL2/structs.scad>

$fn = 128;


// ================= 通用卡箍模块 =================
module clamp_profile(
    inner_width = 200,
    wall_thick = 10,
    height = 60,
    bottom_thick = 10,
    extrude_h = 20
){
    points = [
        [-inner_width/2, height],
        [-inner_width/2 - wall_thick, height],
        [-inner_width/2 - wall_thick, 0],
        [ inner_width/2 + wall_thick, 0],
        [ inner_width/2 + wall_thick, height],
        [ inner_width/2, height],
        [ inner_width/2, bottom_thick],
        [-inner_width/2, bottom_thick]
    ];

    linear_extrude(height = extrude_h)
        polygon(points);
}


// ================= 上半部分 =================
clamp_profile(
    inner_width = 205,
    wall_thick = 10,
    height = 50,
    bottom_thick = 10,
    extrude_h = 50
);


// ================= 下半部分（翻转 + 参数不同） =================
rotate([0, 0, 180])
    clamp_profile(
        inner_width = 230,   
        wall_thick = 10,     
        height = 180,
        bottom_thick = 12,
        extrude_h = 50
    );