
include <BOSL2/std.scad>

$fn = 200;              // 圆形细分精度



// 可配置参数的管道模块
// 参数说明：
// c_h: 管道总高度（长度）
// c_r: 管道内半径
// rotate_x: 绕X轴旋转角度（用于控制管道方向）
// h: 基准Z轴高度（底部相对于原点的Z坐标）
// thick: 壁厚
// hollow: 是否掏空形成空心管（true=空心，false=实心）
module pip(c_h=40, c_r=10, rotate_x=90, h=10, thick=1, hollow=true){
    translate([0, 0, h]){  // 修正Y坐标为0，简化坐标
        rotate([rotate_x, 0, 0]){  // 绕X轴旋转控制管道方向
            
            if (hollow) {
                // 空心管：内外圆柱差集
                difference(){
                    // 外圆柱（包含壁厚）
                    cylinder(h = c_h, r = c_r + thick, center = false);
                    // 内圆柱（空腔）
                    translate([0, 0, -0.1])  // 微小偏移确保布尔运算正确
                    cylinder(h = c_h + 0.2, r = c_r, center = false);
                }
            } else {
                // 实心管
                cylinder(h = c_h, r = c_r, center = false);
            }
        }
    }
}

difference(){

    union(){
        pip(c_h=40, c_r=10, rotate_x=90, h = 15);

        pip(c_h=35, c_r=7, rotate_x=90, h = 40);

        pip(c_h=30, c_r=5, rotate_x=90, h = 60);
    }

    cylinder(h = 80, r = 20, center = false);
}

# difference(){
    cylinder(h = 80, r = 20 + 2, center = false);
    cylinder(h = 80, r = 20, center = false);

    union(){
        pip(c_h=40, c_r=10, rotate_x=90, h = 15, hollow=false);

        pip(c_h=35, c_r=7, rotate_x=90, h = 40, hollow=false);

        pip(c_h=30, c_r=5, rotate_x=90, h = 60, hollow=false);
    }

}


