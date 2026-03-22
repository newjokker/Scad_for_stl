include <BOSL2/std.scad>
include <BOSL2/rounding.scad>

$fn = 200;  // 优化性能


module A(thick = 1.5, L = 150, W = 105, H = 298, r = 10) {
    difference() {
        // 外部实体：只对顶部的四个垂直棱边倒圆角
        // 使用 EDGES_Z_ALL 然后通过 mask2d_roundover 只处理顶部
        cuboid([L, W, H], anchor=BOT, rounding = r, edges = "Y", except = [BOTTOM]);
        
        // 内部挖空：内部也相应处理圆角
        translate([0, thick, thick]) {
            cuboid([L - 2*thick, W - thick, H - 2*thick], anchor=BOT, rounding = r, edges = "Y", except = [BOTTOM]);
        }
    }
}

module B(thick = 1.5, L = 150, W = 105, H = 298 -100, r = 10){
    difference(){
        cuboid([L, W, H], anchor=BOT, edges = "Y", except = [BOTTOM]);
        cuboid([L, W, H], anchor=BOT, rounding = 10, edges = "Y", except = [BOTTOM]);
    }

    translate([0, 0, H])
        A(thick = thick, L = L, W = W, H = H, r = r);

}




A(thick = 1.5, L = 100, W = 105, H = 100, r = 10);


// B(thick = 1.5, L = 100, W = 105, H = (298 - 100)/2, r = 10);



