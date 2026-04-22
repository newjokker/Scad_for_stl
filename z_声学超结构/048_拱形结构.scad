// 方法1：使用 hull() 组合
module smooth_cylinder_hull(h=20, r=5, base_height=2, base_r=10) {
    // 底部平面
    cylinder(h=base_height, r=base_r);
    
    // 圆柱
    translate([0, 0, base_height])
    cylinder(h=h, r=r);
    
    // 平滑过渡连接
    hull() {
        // 底部平面的顶部
        translate([0, 0, base_height])
        cylinder(h=0.1, r=base_r);
        
        // 圆柱的底部
        translate([0, 0, base_height])
        cylinder(h=0.1, r=r);
    }
}

// 方法2：使用旋转体创建自定义曲面
module smooth_cylinder_custom(h=20, r=5, base_height=2, base_r=10, transition_h=5) {
    // 创建旋转体剖面
    rotate_extrude(angle=360) {
        polygon(points=[
            // 底部平面
            [0, 0],
            [base_r, 0],
            [base_r, base_height],
            
            // 平滑过渡曲线
            [r + (base_r - r) * 0.8, base_height + transition_h * 0.2],
            [r + (base_r - r) * 0.6, base_height + transition_h * 0.4],
            [r + (base_r - r) * 0.4, base_height + transition_h * 0.6],
            [r + (base_r - r) * 0.2, base_height + transition_h * 0.8],
            
            // 圆柱
            [r, base_height + transition_h],
            [r, base_height + transition_h + h],
            [0, base_height + transition_h + h]
        ]);
    }
}

// 方法3：使用球体创建圆角过渡
module smooth_cylinder_rounded(h=20, r=5, base_height=2, base_r=10, fillet_r=3) {
    union() {
        // 底部平面
        cylinder(h=base_height, r=base_r);
        
        // 圆柱
        translate([0, 0, base_height])
        cylinder(h=h, r=r);
        
        // 创建圆角过渡
        translate([0, 0, base_height])
        rotate_extrude(angle=360)
        translate([r, 0, 0])
        circle(r=fillet_r);
    }
}

// 方法4：使用贝塞尔曲线创建更平滑的过渡
module smooth_cylinder_bezier(h=20, r=5, base_height=2, base_r=10, transition_h=8) {
    rotate_extrude(angle=360) {
        // 定义贝塞尔曲线控制点
        p0 = [base_r, base_height];
        p1 = [base_r + (r - base_r)/3, base_height + transition_h/3];
        p2 = [r + (base_r - r)/3, base_height + 2*transition_h/3];
        p3 = [r, base_height + transition_h];
        
        // 创建多边形（简化版贝塞尔）
        polygon(points=[
            [0, 0],
            [base_r, 0],
            p0,
            
            // 过渡区域
            [p1[0], p1[1]],
            [p2[0], p2[1]],
            p3,
            
            // 圆柱
            [r, base_height + transition_h + h],
            [0, base_height + transition_h + h]
        ]);
    }
}

// 主演示 - 显示所有方法
translate([-30, 0, 0]) {
    echo("方法1: 使用hull()组合");
    smooth_cylinder_hull(h=15, r=4, base_height=3, base_r=8);
}

translate([-10, 0, 0]) {
    echo("方法2: 自定义旋转体");
    smooth_cylinder_custom(h=15, r=4, base_height=3, base_r=8, transition_h=6);
}

translate([10, 0, 0]) {
    echo("方法3: 圆角过渡");
    smooth_cylinder_rounded(h=15, r=4, base_height=3, base_r=8, fillet_r=2);
}

translate([30, 0, 0]) {
    echo("方法4: 贝塞尔曲线过渡");
    smooth_cylinder_bezier(h=15, r=4, base_height=3, base_r=8, transition_h=7);
}

// 参数说明：
// h: 圆柱高度
// r: 圆柱半径
// base_height: 底部平面高度
// base_r: 底部平面半径
// transition_h: 过渡区域高度
// fillet_r: 圆角半径

// 专业平滑过渡示例
module professional_smooth_cylinder() {
    smooth_cylinder_custom(
        h = 25,
        r = 3,
        base_height = 5,
        base_r = 12,
        transition_h = 10
    );
    
    // 添加倒角
    translate([0, 0, 5])
    rotate_extrude(angle=360)
    translate([12, 0, 0])
    circle(r=1);
}

// 渲染高质量模型
$fn = 100;  // 提高渲染质量
professional_smooth_cylinder();