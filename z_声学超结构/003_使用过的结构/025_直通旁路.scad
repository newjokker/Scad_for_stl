
include <BOSL2/std.scad>

$fn = 200;              // 圆形细分精度



// 可配置参数的管道模块
module pip(c_h=40, c_r=10, rotate_z=90, h=10, thick=1, hollow=true){
    translate([0, 0, h]){  // 修正Y坐标为0，简化坐标
        rotate([90, 0, rotate_z]){  // 绕X轴旋转控制管道方向
            
            if (hollow) {
                // 空心管：内外圆柱差集
                difference(){
                    // 外圆柱（包含壁厚）
                    cylinder(h = c_h, r = c_r + thick, center = false);
                    // 内圆柱（空腔）
                    translate([0, 0, -thick])  // 微小偏移确保布尔运算正确
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
        pip(c_h=130, c_r=10, rotate_z=0, h = 15);

        pip(c_h=130, c_r=10, rotate_z=90, h = 40);

        pip(c_h=130, c_r=10, rotate_z=180, h = 60);

        pip(c_h=130, c_r=10, rotate_z=270, h = 60);
    }

    cylinder(h = 80, r = 60, center = false);
}

# difference(){
    cylinder(h = 80, r = 60 + 3, center = false);
    cylinder(h = 80, r = 60, center = false);

    union(){
        pip(c_h=130, c_r=10, rotate_z=0, h = 15, hollow=false);

        pip(c_h=130, c_r=10, rotate_z=90, h = 40, hollow=false);

        pip(c_h=130, c_r=10, rotate_z=180, h = 60, hollow=false);
        
        pip(c_h=130, c_r=10, rotate_z=270, h = 60, hollow=false);
    
    }
}

difference(){
    cuboid([1000, 1000, 2], anchor=[0, 0, -1]);
    cylinder(h = 80, r = 60, center = false);
}

