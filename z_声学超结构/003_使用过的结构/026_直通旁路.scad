include <BOSL2/std.scad>

$fn = 200;              // 圆形细分精度

/* ========== 可配置参数 ========== */
// 圆柱主体参数
CYLINDER_HEIGHT = 90;   // 圆柱主体高度
CYLINDER_RADIUS = 25;   // 圆柱主体半径
WALL_THICKNESS = 1;     // 壁厚

// 管道参数
PIPE_COUNT = 4;         // 管道数量
PIPE_EXTEND = 35;  // 伸出圆柱的管道长度
PIPE_RADIUS = 10;       // 管道半径
PIPE_WALL = 1;          // 管道壁厚

// 管道起始角度和高度数组
PIPE_ROTATIONS = [0, 90, 180, 270];  // 各管道绕Z轴旋转角度
PIPE_HEIGHTS   = [15, 40, 60, 60];   // 各管道起始高度

// 底板参数
BASE_SIZE = 1000;       // 底板尺寸
BASE_HEIGHT = 2;        // 底板厚度
/* ============================== */

// 管道模块
module pip(c_extend=PIPE_EXTEND, c_r=PIPE_RADIUS, rotate_z=90, h=10, thick=PIPE_WALL, hollow=true){
    translate([0, 0, h]){
        rotate([90, 0, rotate_z]){
            if (hollow) {
                difference(){
                    cylinder(h = c_extend, r = c_r + thick, center = false);
                    translate([0, 0, -thick])
                    cylinder(h = c_extend + 0.2, r = c_r, center = false);
                }
            } else {
                cylinder(h = c_extend, r = c_r, center = false);
            }
        }
    }
}

// 生成所有管道
module all_pipes(hollow=true) {
    for (i = [0:PIPE_COUNT-1]) {
        pip(c_extend=PIPE_EXTEND + CYLINDER_RADIUS + WALL_THICKNESS , c_r=PIPE_RADIUS, 
            rotate_z=PIPE_ROTATIONS[i], 
            h=PIPE_HEIGHTS[i], 
            thick=PIPE_WALL, 
            hollow=hollow);
    }
}


module A(){

    // 主体结构
    difference(){ 
        union(){
            all_pipes(hollow=true);
        }
        cylinder(h = CYLINDER_HEIGHT, r = CYLINDER_RADIUS, center = false);
    }

    // 外壳
    difference(){
        cylinder(h = CYLINDER_HEIGHT, r = CYLINDER_RADIUS + WALL_THICKNESS, center = false);
        translate([0, 0, -0.01]){
            cylinder(h = CYLINDER_HEIGHT + 0.02, r = CYLINDER_RADIUS, center = false);
        }
        all_pipes(hollow=false);
    }

}


A();

// translate([CYLINDER_RADIUS * 1.5, CYLINDER_RADIUS * 1.5, 0])
//     A();

// // 底板
// difference(){
//     cuboid([BASE_SIZE, BASE_SIZE, BASE_HEIGHT], anchor=[0, 0, -1]);
//     cylinder(h = CYLINDER_HEIGHT, r = CYLINDER_RADIUS, center = false);
// }