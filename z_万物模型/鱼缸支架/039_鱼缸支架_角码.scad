// ==========================================
// 参数化支架 (Parameterized Bracket)
// 使用 OpenSCAD 构建
// ==========================================

// ----- 核心尺寸参数 (Core Dimensions) -----
Bracket_Length   = 25;   // 支架总长度 (X轴)
Bracket_Width    = 25;   // 支架总宽度 (Y轴)
Bracket_Height   = 25;   // 支架总高度 (Z轴)
Bracket_Thickness = 5;   // 材料厚度 [4:15]
Bracket_Angle    = 90;   // 弯曲角度 (度) [45:150]

// ----- 孔位与安装参数 (Hole & Mounting) -----
Hole_Diameter   = 3.5;     // 安装孔径
Countersink     = false;  // 是否沉头 (true=是, false=否)
Pitch_X         = 10;    // 两孔X方向间距
Pitch_YZ        = Bracket_Width/2;     // 孔中心到Y/Z边缘的距离

// ----- 侧壁支撑选项 (Sidewall Supports) -----
Left_Sidewall   = true;  // 启用左侧支撑壁
Middle_Sidewall = true;   // 启用中间支撑壁
Right_Sidewall  = true;  // 启用右侧支撑壁

// ==========================================
// 模块化构建 (Modular Construction)
// ==========================================

// ----- 1. 主体建模 (Main Body) -----
// 使用差集运算：先通过Minkowski和创建圆角主体，再挖孔和切割

// ---- 1.1 水平底板 (X-Y平面, 沿Z方向拉伸) ----
difference() {     
    // 主体：带圆角的平板 (通过Minkowski和球体实现)
    minkowski() {
        translate ([-Bracket_Length/2 + 2, 0, 0])
            cube([Bracket_Length - 4, Bracket_Width - 4, Bracket_Thickness - 3.9]);
        sphere(2, $fn=150);   
    } 
    
    // 处理沉头孔 (如果启用)
    if (Countersink) {
        // 左侧沉头孔 (锥形)
        hull() {
            rotate([0, 180, 0])
                translate([-Pitch_X/2, Pitch_YZ - 2, -2.1 - Bracket_Thickness + 4]) 
                    cylinder(Hole_Diameter, Hole_Diameter, 0, $fn=150);
        }
        // 右侧沉头孔 (锥形)
        hull() {
            rotate([0, 180, 0])
                translate([Pitch_X/2, Pitch_YZ - 2, -2.1 - Bracket_Thickness + 4]) 
                    cylinder(Hole_Diameter, Hole_Diameter, 0, $fn=150);
        }
    }
    
    // 左侧通孔 (贯穿)
    translate([Pitch_X/2, Pitch_YZ - 2, -3])
        cylinder(60, Hole_Diameter/2 + 0.1, Hole_Diameter/2 + 0.1, $fn=150);

    // 右侧通孔 (贯穿)
    translate([-Pitch_X/2, Pitch_YZ - 2, -3])
        cylinder(60, Hole_Diameter/2 + 0.1, Hole_Diameter/2 + 0.1, $fn=150);
    
    // 切割掉多余的边缘 (用于适配弯曲角度)
    rotate([Bracket_Angle, 0, 0])
        translate([-Bracket_Length/2 - 5, -15, 2])
            cube([Bracket_Length + 10, 50, 10]);
}

// ---- 1.2 竖直侧板 (X-Z平面, 沿Y方向拉伸) ----
// 旋转到垂直方向 (角度 = Bracket_Angle - 90)
difference() {
    // 带圆角的垂直板
    minkowski() {
        rotate([Bracket_Angle - 90, 0, 0])
            translate ([-Bracket_Length/2 + 2, 0, 0])
                cube([Bracket_Length - 4, Bracket_Thickness - 3.9, Bracket_Height - 4]);
        sphere(2, $fn=150);
    }   
    
    // 处理沉头孔 (如果启用)
    if (Countersink) {
        // 左侧沉头孔 (锥形)
        hull() {
            rotate([Bracket_Angle - 90, 0, 0])
                rotate([90, 0, 0])
                    translate([Pitch_X/2, Pitch_YZ - 2, -2.1 - Bracket_Thickness + 4]) 
                        cylinder(Hole_Diameter, Hole_Diameter, 0, $fn=150);
        }
        // 右侧沉头孔 (锥形)
        hull() {
            rotate([Bracket_Angle - 90, 0, 0])
                rotate([90, 0, 0])
                    translate([-Pitch_X/2, Pitch_YZ - 2, -2.1 - Bracket_Thickness + 4]) 
                        cylinder(Hole_Diameter, Hole_Diameter, 0, $fn=150);
        }
    }
    
    // 左侧通孔 (贯穿)
    rotate([Bracket_Angle - 90, 0, 0])
        rotate([90, 0, 0])
            translate([Pitch_X/2, Pitch_YZ - 2, -40])
                cylinder(60, Hole_Diameter/2 + 0.1, Hole_Diameter/2 + 0.1, $fn=150);
  
    // 右侧通孔 (贯穿)
    rotate([Bracket_Angle - 90, 0, 0])
        rotate([90, 0, 0])
            translate([-Pitch_X/2, Pitch_YZ - 2, -40])
                cylinder(60, Hole_Diameter/2 + 0.1, Hole_Diameter/2 + 0.1, $fn=150);
    
    // 切割掉多余的边缘 (用于适配弯曲角度)
    translate([-Bracket_Length/2 - 5, -15, -12])
        cube([Bracket_Length + 10, 50, 10]);
}

// ----- 2. 侧壁支撑 (Sidewall Supports) -----
// 增强结构强度的三角支撑

// ---- 2.1 右侧支撑 (Right Sidewall) ----
if (Right_Sidewall) {
    difference() {
        hull() {
            // 底部圆柱 (在水平板上)
            translate([-Bracket_Length/2 + 2, Bracket_Width - 4, Bracket_Thickness - 4]) 
                cylinder(0.001, 2, 2, $fn=150);
            // 顶部圆柱 (在垂直板上)
            rotate([Bracket_Angle - 90, 0, 0])
                translate([-Bracket_Length/2 + 2, Bracket_Thickness - 4, 0])
                    cylinder(Bracket_Height + 0.1 - 4, 2, 2, $fn=150);
        }
        // 切除下方多余部分，使其与主体融合
        translate([-Bracket_Length/2 - 5, -5, -12])
            cube([Bracket_Length + 10, Bracket_Width + 20, 10]);  
    }
}

// ---- 2.2 中间支撑 (Middle Sidewall) ----
if (Middle_Sidewall) {
    difference() {
        // 使用两个圆柱体生成一个更宽的支撑结构
        hull() {
            translate([0, Bracket_Width - 6, Bracket_Thickness - 2]) 
                cylinder(0.001, 1.5, 1.5, $fn=150);
            rotate([Bracket_Angle - 90, 0, 0])
                translate([0, Bracket_Thickness - 3.9, 2])
                    cylinder(Bracket_Height - 6, 1.5, 1.5, $fn=150);
        }
        hull() {
            translate([10, Bracket_Width - 2, Bracket_Thickness - 2]) 
                cylinder(0.001, 1.5, 1.5, $fn=150);
            rotate([Bracket_Angle - 90, 0, 0])
                translate([10, Bracket_Thickness - 3.9, 2.5])
                    cylinder(Bracket_Height - 2, 1.5, 1.5, $fn=150);
        }
        // 切除下方多余部分
        translate([-Bracket_Length/2 - 5, -5, -12])
            cube([Bracket_Length + 10, Bracket_Width + 20, 10]);  
    }
}

// ---- 2.3 左侧支撑 (Left Sidewall) ----
if (Left_Sidewall) {
    difference() {
        hull() {
            // 底部圆柱
            translate([Bracket_Length/2 - 2, Bracket_Width - 4, Bracket_Thickness - 4]) 
                cylinder(0.001, 2, 2, $fn=150);
            // 顶部圆柱
            rotate([Bracket_Angle - 90, 0, 0])
                translate([Bracket_Length/2 - 2, Bracket_Thickness - 4, 0])
                    cylinder(Bracket_Height + 0.1 - 4, 2, 2, $fn=150);
        }   
        // 切除下方多余部分
        translate([-Bracket_Length/2 - 5, -5, -12])
            cube([Bracket_Length + 10, Bracket_Width + 20, 10]);  
    }
}