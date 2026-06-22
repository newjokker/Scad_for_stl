include <BOSL2/std.scad>
include <BOSL2/geometry.scad>

$fn = 200; 

// 定义设计参数
design_cavity_length    = 24;
design_cavity_width     = 24;
design_cavity_height    = 24;
design_neck_length      = 20;
design_neck_radius      = 3.6;
design_wall_thickness   = 1.0;

module helmholtz_resonator(
    cavity_length = 24,     // 腔体内部长度
    cavity_width = 24,      // 腔体内部宽度
    cavity_height = 24,     // 腔体内部高度
    neck_length = 20,       // 颈部管道长度
    neck_radius = 3.6,      // 颈部管道半径
    wall_thickness = 1.0,   // 壁厚
    neck_direction = "inside",  // 颈部方向："inside" 或 "outside"
    display_mode = "solid",     // 显示模式："solid" 或 "transparent"
    show_frequency = true,      // 是否显示共振频率
    frequency_text_size = 5,    // 文字大小
    text_emboss_height = 0.5,   // 浮雕高度
    sound_speed = 343           // 声速 (m/s)
) {
    // 计算腔体外部尺寸（内部尺寸 + 2倍壁厚）
    outer_length = cavity_length + 2 * wall_thickness;
    outer_width = cavity_width + 2 * wall_thickness;
    outer_height = cavity_height + 2 * wall_thickness;
    
    // 计算共振频率
    frequency = calculate_resonance_frequency(
        cavity_length, cavity_width, cavity_height,
        neck_length, neck_radius, sound_speed
    );
    
    // 判断显示模式
    is_solid = (display_mode == "solid");
    is_inside = (neck_direction == "inside");
    
    // 创建频率文字（浮雕效果）
    module frequency_text_emboss() {
        freq_text = str("f = ", round(frequency * 10) / 10, " Hz");
        
        // 文字大小自适应：根据底面宽度调整
        text_len = len(freq_text);
        adjusted_size = min(frequency_text_size, outer_width / (text_len * 0.6));
        
        // 创建浮雕文字（凸起）
        // 注意：文字默认在XY平面，Z轴方向凸起
        linear_extrude(height = text_emboss_height, center = false)
            text(
                text = freq_text,
                size = adjusted_size,
                font = "Arial:style=Bold",
                halign = "center",
                valign = "center"
            );
    }
    
    if (is_solid == true) {
        // ---------- 实体外壳模式 ----------
        // 构建外壳主体
        difference() {
            // 1. 外部立方体（外壳）
            cuboid([outer_length, outer_width, outer_height], anchor = [0, 0, -1]);
            
            // 2. 内部掏空（从底部向上偏移一个壁厚）
            translate([0, 0, wall_thickness])
                cuboid([cavity_length, cavity_width, cavity_height], anchor = [0, 0, -1]);
            
            // 3. 底部开口（用于颈部穿过腔体底部）
            translate([0, 0, wall_thickness - 0.01])
                cylinder(h = cavity_height + 2, d = 2 * neck_radius, center = false);
        }
        
        // ---------- 颈部管道 ----------
        if (is_inside == true) {
            // 颈部朝内：从腔体底部向上伸入内部
            translate([0, 0, cavity_height - neck_length + wall_thickness])
                difference() {
                    // 颈部外壁（管道壁）
                    cylinder(h = neck_length, d = 2 * (neck_radius + wall_thickness), center = false);
                    // 颈部内孔（空气通道）
                    translate([0, 0, -wall_thickness - 0.01])
                        cylinder(h = neck_length + wall_thickness + 0.02, d = 2 * neck_radius, center = false);
                }
        } else {
            // 颈部朝外：从腔体底部向下延伸
            translate([0, 0, -wall_thickness])
                difference() {
                    // 颈部外壁（管道壁）
                    cylinder(h = neck_length, d = 2 * (neck_radius + wall_thickness), center = false);
                    // 颈部内孔（空气通道）
                    translate([0, 0, -0.01])
                        cylinder(h = neck_length + 0.02, d = 2 * neck_radius, center = false);
                }
        }
        
        // ---------- 在底面显示共振频率（浮雕效果） ----------
        if (show_frequency) {
            translate([0, 0, -0.01])          // 放到底面外侧
            rotate([180, 0, 0])               // 让文字向下凸起
            color("Black")
            frequency_text_emboss();
        }
        
    } else {
        // ---------- 透明模式（显示内部结构） ----------
        // 显示内部空腔
        color("LightBlue", alpha = 0.3)
            cuboid([cavity_length, cavity_width, cavity_height], anchor = [0, 0, 1]);
        
        // 显示颈部通道（半透明橙色）
        color("Orange", alpha = 0.5)
            cylinder(h = neck_length + wall_thickness + 0.02, d = 2 * neck_radius, center = false);
        
        // 显示内部空气体积（用线框标识）
        color("Red", alpha = 0.2)
            cuboid([cavity_length, cavity_width, cavity_height], anchor = [0, 0, 1]);
        
        // ---------- 透明模式下也显示频率信息 ----------
        if (show_frequency) {
            translate([0, 0, 0])
            rotate([0, 0, 180])
            color("Black")
            frequency_text_emboss();
        }
    }
}

function calculate_resonance_frequency(
    cavity_length, 
    cavity_width, 
    cavity_height, 
    neck_length, 
    neck_radius,
    sound_speed = 343) =
    let(
        // 计算腔体体积（立方毫米 -> 立方米）
        cavity_volume_mm3 = cavity_length * cavity_width * cavity_height,
        cavity_volume_m3 = cavity_volume_mm3 / 1000000000,
        
        // 计算颈部截面积（平方毫米 -> 平方米）
        neck_area_mm2 = PI * pow(neck_radius, 2),
        neck_area_m2 = neck_area_mm2 / 1000000,
        
        // 有效颈长：实际长度 + 末端修正（约1.7倍半径）
        effective_length_mm = neck_length + 1.7 * neck_radius,
        effective_length_m = effective_length_mm / 1000
    )
    (sound_speed / (2 * PI)) * sqrt(neck_area_m2 / (cavity_volume_m3 * effective_length_m));

// 显示设计参数和计算出的频率
design_frequency = calculate_resonance_frequency(
    design_cavity_length,
    design_cavity_width, 
    design_cavity_height,
    design_neck_length,
    design_neck_radius
);

echo("====================");
echo("设计共振频率 =", round(design_frequency * 10) / 10, "Hz");
echo("====================");

// 使用示例
helmholtz_resonator(
    cavity_length = design_cavity_length,
    cavity_width = design_cavity_width,
    cavity_height = design_cavity_height,
    neck_length = design_neck_length,
    neck_radius = design_neck_radius,
    wall_thickness = design_wall_thickness,
    neck_direction = "inside",
    display_mode = "solid",
    show_frequency = true,
    frequency_text_size = 3,     
    text_emboss_height = 0.8     
);