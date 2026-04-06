include <BOSL2/std.scad>
include <BOSL2/rounding.scad>

$fn = 200;  // 优化性能

// 这个尺寸正好能卡住开关，后面高度可以适当减少就可以直接安装了
difference(){
    cuboid([25, 10, 20]);
    cuboid([19, 6.7, 100]);
}



