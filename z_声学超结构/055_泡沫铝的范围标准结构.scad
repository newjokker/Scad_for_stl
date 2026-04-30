

include <BOSL2/std.scad>

$fn = 200;              // 圆形细分精度

thick = 15;

difference(){
    cuboid([120 - 0.5, 150 - 0.5, 30], rounding = 3.6, edges = [LEFT+FRONT, RIGHT+FRONT, LEFT+BACK, RIGHT+BACK], anchor = [0, 0, 0]);
    cuboid([120 - thick - 0.5, 150 - thick - 0.5, 40], rounding = 3.6, edges = [LEFT+FRONT, RIGHT+FRONT, LEFT+BACK, RIGHT+BACK], anchor = [0, 0, 0]);
}


// 标准结构大小的一个框子，里面放上泡沫铝，泡沫铝和框子之间使用蓝丁胶进行密封

