include <BOSL2/std.scad>

$fn = 200;              // 圆形细分精度

cuboid([120 -2, 150-2, 30], rounding = 3.6, edges = [LEFT+FRONT, RIGHT+FRONT, LEFT+BACK, RIGHT+BACK], anchor = [-1, -1, -1]);


