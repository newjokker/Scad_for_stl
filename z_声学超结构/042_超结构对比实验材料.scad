include <BOSL2/std.scad>

$fn = 64;

// 外面的长宽 要控制在 119.5 * 149.5 , 圆角要控制在 3.6  

cuboid([149.5, 119.5, 30], rounding = 3.6, edges = [LEFT+FRONT, RIGHT+FRONT, LEFT+BACK, RIGHT+BACK], anchor = [-1, -1, -1]);



