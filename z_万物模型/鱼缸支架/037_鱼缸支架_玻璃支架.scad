include <BOSL2/std.scad>
include <BOSL2/joiners.scad>

$fn = 148;

// ==================== 参数配置 ====================
// 你可以在这里调整所有参数
glass_thickness = 8;        // 玻璃厚度 (mm)
holder_width = 140;         // 支架宽度 (mm)
holder_height = 35;         // 支架上沿高度 (mm)
holder_base_height = 15;    // 支架底部高度 (mm)
wall_thickness = 4;         // 支架壁厚 (mm)
plate_thickness = 5.2;      // 插入的板子厚度 (mm)
screw_hole_diameter = 3.5;      // 螺丝孔直径 (mm)
screw_offset_from_center = 5;   // 螺丝孔距中心偏移 (mm)
plate_width = 25.2;             // 板子开槽宽度 (mm)

// ==================== 计算值 ====================
thick_glass = glass_thickness + 0.2; // 玻璃厚度加上余量
total_thickness = thick_glass + wall_thickness * 2; // 总厚度
half_width = holder_width / 2;
half_plate_width = plate_width / 2;

// 两个板子的位置（距离中心的距离）
plate_position = 97.5 / 2;

// 螺丝孔距离底面的高度
screw_height_from_bottom = holder_base_height / 2;

// ==================== 主体模块 ====================
module GlassHolder() {
    difference() {
        // ---------- 主体 ----------
        union() {
            // 上部U型槽（卡玻璃的部分）
            translate([0, 0, holder_base_height]) {
                difference() {
                    // 外部轮廓
                    cuboid([holder_width, total_thickness, holder_height], 
                           anchor=[0, 0, -1]);
                    // 内部掏空（玻璃槽）
                    translate([0, 0, 0]) {
                        cuboid([holder_width + 0.1, thick_glass, holder_height + 0.1], 
                               anchor=[0, 0, -1]);
                    }
                }
            }
            
            // 底部实体
            cuboid([holder_width, total_thickness, holder_base_height], 
                   anchor=[0, 0, -1]);
        }

        // ---------- 开槽（插入板子） ----------
        // 右侧板子槽
        translate([plate_position, 0, 0]) {
            cuboid([plate_width, plate_thickness, 100], anchor=[0, 0, 0]);
        }
        
        // 左侧板子槽
        translate([-plate_position, 0, 0]) {
            cuboid([plate_width, plate_thickness, 100], anchor=[0, 0, 0]);
        }

        // ---------- 螺丝孔 ----------
        // 右侧两个螺丝孔
        for (x_offset = [screw_offset_from_center, -screw_offset_from_center]) {
            translate([plate_position + x_offset, 0, screw_height_from_bottom]) {
                rotate([90, 0, 0]) {
                    cylinder(h = 100, r = screw_hole_diameter / 2, center = true);
                }
            }
        }
        
        // 左侧两个螺丝孔
        for (x_offset = [screw_offset_from_center, -screw_offset_from_center]) {
            translate([-plate_position + x_offset, 0, screw_height_from_bottom]) {
                rotate([90, 0, 0]) {
                    cylinder(h = 100, r = screw_hole_diameter / 2, center = true);
                }
            }
        }
    }
}

// ==================== 渲染 ====================
GlassHolder();

// ==================== 辅助显示（可选） ====================
// 取消注释下面的代码可以显示玻璃位置参考

%translate([0, 0, holder_base_height]) {
    color("LightBlue", 0.3) {
        cuboid([holder_width + 50, glass_thickness, holder_height + 50], 
               anchor=[0, 0, -1]);
    }
}
