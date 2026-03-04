// 使用 linear_extrude + twist 生成螺旋带结构
$fn = 90;   // 圆柱等圆形的分段数（越大越圆滑）

module A(){
    H       = 50;   // 螺旋结构高度
    turns   = 1;    // 螺旋圈数（总共旋转多少圈）
    R       = 36;    // x + strip_w/2;   // 螺旋半径（从中心到带状结构的中心的距离）
    strip_w = (100 - 44)/2;   // 带状结构宽度（沿半径方向）
    strip_t = 1;    // 带状结构厚度（切向方向）

    // 通过扭转挤出生成螺旋
    linear_extrude(
        height = H,             // 挤出高度
        twist = 360 * turns,    // 总扭转角度
        slices = 300            // 分层数（越大螺旋越平滑）
    )
    translate([R, 0])           // 将截面移动到半径 R 的位置
    square([strip_w, strip_t], center = true);   // 螺旋带的截面
}

module B(){

    // 一个半透明圆柱体，用作参考外壳
    color([1, 0.5, 0.5, 0.5]){

        difference(){

            cylinder(
                h = 50,   // 圆柱高度
                d = 46,   // 圆柱直径
                center = false
            );

            translate([0, 0, -2]){
                cylinder(
                    h = 100,   // 圆柱高度
                    d = 44,   // 圆柱直径
                    center = false
                );
            }

        }


        difference(){

            cylinder(
                h = 50,   // 圆柱高度
                d = 100,   // 圆柱直径
                center = false
            );

            translate([0, 0, 2]){
                cylinder(
                    h = 50 + 20,   // 圆柱高度
                    d = 99,   // 圆柱直径
                    center = false
                );
            }

            translate([0, 0, -20]){
                cylinder(
                    h = 100,   // 圆柱高度
                    d = 44,   // 圆柱直径
                    center = false
                );
            }

        }

    }


}

module D(){
// 做一个开窗

}


A();


B();

