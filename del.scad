// 完善的螺栓柱模块
// diameter: 螺栓规格 ("m2" 或 "m3")
// height: 螺栓柱总高度
// rib_height: 圆柱形加强筋高度（从底部开始的高度）
// rib_thickness: 加强筋厚度
// pos: [x, y, z] 螺栓柱底部的坐标
// fn: 圆柱面细分度（默认30）
module bolt_post(diameter="m3", height=10, rib_height=5, rib_thickness=2, pos=[0, 0, 0], fn=60) {
    // 设置螺栓直径
    bolt_diameter = (diameter == "m3") ? 3.0 : (diameter == "m2") ? 2.0 : 3.0;
    
    // 螺栓孔直径（略大于标准直径以便装配）
    hole_diameter = bolt_diameter + 0.1;
    
    // 加强筋外径
    rib_outer_diameter = bolt_diameter + rib_thickness * 2;
    
    // 移动到指定位置
    translate(pos) {
        // 主要的螺栓孔（贯穿整个高度）
        cylinder(h = height, d = hole_diameter, $fn = fn);
        
        // 圆柱形加强筋（如果设置了高度和厚度）
        if (rib_height > 0 && rib_thickness > 0) {
            // 加强筋从底部向上延伸指定高度
            difference() {
                // 外层圆柱（加强筋区域）
                cylinder(h = rib_height, d = rib_outer_diameter, $fn = fn);
                
                // 内层圆柱（保持螺栓孔）
                cylinder(h = rib_height, d = hole_diameter, $fn = fn);
            }
        }
    }
}

// 示例使用 - 展示不同配置的螺栓柱
// M3螺栓柱，高度15mm，加强筋高度10mm，厚度2mm
translate([-20, 0, 0])
bolt_post(diameter="m2", height=15, rib_height=18, rib_thickness=2, pos=[0, 0, 0]);

