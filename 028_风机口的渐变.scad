include <BOSL2/std.scad>
include <BOSL2/structs.scad>

$fn = 128;

wall_thickness = 3; // 明确的壁厚值
blend_height = 145;
rect_length = 205;
rect_width  = 100;
diameter    = 156;

module pip_transformer(rect_length = 210, rect_width = 100, diameter = 160, blend_height = 50) {
    // 底部矩形基础
    linear_extrude(height = 1)
        square([rect_length, rect_width], center=true);
    
    cuboid([rect_length, rect_width, 20], anchor=[0, 0, 1]);

    translate([0, 0, blend_height])
        cylinder(h = 20, r = diameter/2, center = false);
    
    // 渐变部分
    hull() {
        translate([0, 0, 1])
        linear_extrude(height = 0.01)
            square([rect_length, rect_width], center=true);
        
        translate([0, 0, blend_height])
        linear_extrude(height = 0.01)
            circle(r = diameter/2);
    }
}

difference() {
    // 外轮廓：尺寸增加 2*壁厚
    pip_transformer(
        rect_length = rect_length + 2*wall_thickness,
        rect_width  = rect_width + 2*wall_thickness,
        diameter    = diameter + 2*wall_thickness,
        blend_height = blend_height
    );
    
    // 内轮廓：原始尺寸
    pip_transformer(
        rect_length = rect_length,
        rect_width  = rect_width,
        diameter    = diameter,
        blend_height = blend_height
    );
}