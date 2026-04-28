/*
 * OpenSCAD 贝塞尔曲线演示
 * 绘制一条二次贝塞尔曲线并生成3D模型
 */

// 定义贝塞尔曲线的控制点
// 格式: [x, y]
p0 = [0, 0];    // 起点
p1 = [20, 40];  // 控制点
p2 = [40, 0];   // 终点

// 贝塞尔曲线函数（二次）
// t: 参数，范围[0, 1]
function bezier2(t, p0, p1, p2) = 
    (1-t)*(1-t)*p0 + 2*(1-t)*t*p1 + t*t*p2;

// 创建点列表用于多边形
points = [for (t = [0:0.05:1]) bezier2(t, p0, p1, p2)];

// 方法1：绘制2D贝塞尔曲线
module drawBezierCurve2D() {
    echo("绘制2D贝塞尔曲线");
    
    // 绘制控制多边形
    color("red") {
        translate([p0[0], p0[1], 0]) circle(r=2);
        translate([p1[0], p1[1], 0]) circle(r=2);
        translate([p2[0], p2[1], 0]) circle(r=2);
    }
    
    // 绘制控制线
    color("gray", 0.3) {
        polygon([p0, p1, p2]);
    }
    
    // 绘制贝塞尔曲线
    color("blue") {
        polygon(points);
    }
}

// 方法2：创建3D挤出模型
module create3DModel() {
    echo("创建3D挤出模型");
    
    // 原始2D形状
    linear_extrude(height = 10) {
        polygon(points);
    }
}

// 方法3：创建旋转体
module createRevolvedModel() {
    echo("创建旋转体");
    
    rotate_extrude(angle = 360) {
        translate([50, 0, 0]) {
            polygon(points);
        }
    }
}

// 方法4：使用贝塞尔曲线作为扫描路径
module createSweptModel() {
    echo("创建扫描模型");
    
    // 定义扫描路径（贝塞尔曲线）
    path_points = [for (t = [0:0.1:1]) 
        [bezier2(t, p0, p1, p2)[0], 0, bezier2(t, p0, p1, p2)[1]]
    ];
    
    // 沿着路径扫描一个圆形
    for (i = [0:len(path_points)-2]) {
        hull() {
            translate(path_points[i]) sphere(r=5);
            translate(path_points[i+1]) sphere(r=5);
        }
    }
}

// 方法5：更复杂的贝塞尔曲面（通过放样）
module createLoftedSurface() {
    echo("创建放样曲面");
    
    // 定义多条贝塞尔曲线
    curve1 = [for (t = [0:0.1:1]) 
        [bezier2(t, p0, p1, p2)[0], 0, bezier2(t, p0, p1, p2)[1]]
    ];
    
    curve2 = [for (t = [0:0.1:1]) 
        [bezier2(t, p0, p1, p2)[0] + 10, 20, bezier2(t, p0, p1, p2)[1] + 10]
    ];
    
    curve3 = [for (t = [0:0.1:1]) 
        [bezier2(t, p0, p1, p2)[0] + 20, 40, bezier2(t, p0, p1, p2)[1] + 20]
    ];
    
    // 创建连接曲面的多边形
    polyhedron(
        points = concat(curve1, curve2, curve3),
        faces = [
            // 连接curve1和curve2
            for (i = [0:len(curve1)-2])
                [i, i+1, len(curve1)+i+1, len(curve1)+i],
            // 连接curve2和curve3
            for (i = [0:len(curve2)-2])
                [len(curve1)+i, len(curve1)+i+1, len(curve1)+len(curve2)+i+1, len(curve1)+len(curve2)+i]
        ],
        convexity = 10
    );
}

// 主程序 - 选择要显示的模型
echo("=== OpenSCAD 贝塞尔曲线演示 ===");
echo("控制点: P0", p0, "P1", p1, "P2", p2);

// 取消注释你想要查看的模型：

// // 1. 显示2D贝塞尔曲线（基础演示）
// drawBezierCurve2D();

// 2. 显示3D挤出模型
// translate([0, 60, 0]) create3DModel();

// 3. 显示旋转体
// translate([100, 0, 0]) createRevolvedModel();

// 4. 显示扫描模型
translate([0, -60, 0]) createSweptModel();

// 5. 显示放样曲面
// translate([-100, 0, 0]) createLoftedModel();