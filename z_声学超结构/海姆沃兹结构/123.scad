// ======================================
// 串联双腔直颈型亥姆霍兹共鸣器示意模型
// 3D 打印友好，无倒扣，垂直打印零支撑
// ======================================

// ------------------
// 参数（可修改）
// ------------------
neck_d = 2;       // 颈直径 mm
neck_l = 6;       // 颈长度 mm

upper_r = 6;      // 上小腔半径 mm
upper_h = 6;      // 上小腔高度 mm

lower_r = 10;     // 下大腔半径 mm
lower_h = 15;     // 下大腔高度 mm

wall_thick = 1;   // 壁厚 mm

// ------------------
// 模块
// ------------------
module double_helmholtz(){
    // 整体组合
    union(){
        // 下大腔
        difference(){
            cylinder(h=lower_h, r=lower_r, center=false);
            cylinder(h=lower_h, r=lower_r-wall_thick, center=false);
        }
        
        // 上小腔
        translate([0,0,lower_h+neck_l])
            difference(){
                cylinder(h=upper_h, r=upper_r, center=false);
                cylinder(h=upper_h, r=upper_r-wall_thick, center=false);
            }
        
        // 直颈连接
        translate([0,0,lower_h])
            cylinder(h=neck_l, r=neck_d/2, center=false);
    }
}

// ------------------
// 渲染
// ------------------
double_helmholtz();