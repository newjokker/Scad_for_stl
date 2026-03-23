$fn = 64;

text_str = "TO DO";
text_size = 60;
text_height = 5;
font_name = "Marker Felt:style=Wide";
magnet_diameter = 6.1;  // 稍微放大一点以便磁铁能放入
magnet_height = 3;     // 磁铁高度
hole_depth = magnet_height + 0.5; // 孔深度比磁铁稍深

// 先创建文字主体
difference() {
    linear_extrude(height = text_height)
        text(
            text_str,
            size = text_size,
            font = font_name,
            halign = "center",
            valign = "center"
        );
    
    // 为每个字符添加磁铁孔
    // "T" 字的磁铁孔
    translate([-text_size*1.44, -text_size*0.27, -0.1])
        cylinder(h = hole_depth, d = magnet_diameter);
    
    translate([-text_size*1.2, text_size*0.47, -0.1])
        cylinder(h = hole_depth, d = magnet_diameter);
        
    translate([-text_size*1.65, text_size*0.35, -0.1])
        cylinder(h = hole_depth, d = magnet_diameter);
    
    // "O" 字的磁铁孔
    translate([-text_size*0.34, 0, -0.1])
        cylinder(h = hole_depth, d = magnet_diameter);
    
    translate([-text_size*0.7, text_size*0.45, -0.1])
        cylinder(h = hole_depth, d = magnet_diameter);
        
    translate([-text_size*0.88, -text_size*0.05, -0.1])
        cylinder(h = hole_depth, d = magnet_diameter);
    
    // // "D" 字的磁铁孔
    translate([text_size*0.43, -text_size*0.45, -0.1])
        cylinder(h = hole_depth, d = magnet_diameter);
    
    translate([text_size*0.34, text_size*0.4, -0.1])
        cylinder(h = hole_depth, d = magnet_diameter);
        
    translate([text_size*0.75, -text_size*0, -0.1])
        cylinder(h = hole_depth, d = magnet_diameter);

    // "O" 字的磁铁孔
    translate([text_size*1.65, 0, -0.1])
        cylinder(h = hole_depth, d = magnet_diameter);
    
    translate([text_size*1.3, text_size*0.45, -0.1])
        cylinder(h = hole_depth, d = magnet_diameter);
        
    translate([text_size*1.1, -text_size*0.05, -0.1])
        cylinder(h = hole_depth, d = magnet_diameter);
    

}


