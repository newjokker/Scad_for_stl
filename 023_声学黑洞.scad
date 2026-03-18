include <BOSL2/std.scad>

// ================= 参数 =================
L = 10;  // 三角形底边的长度
W = 10;  // 搓衣板的宽度
H = 15;  // 楔形高度
spacing = 0;  // 间距
c_height = 2; // 楔形块底部凸起高度
rows = 10;    // 行数
cols = 10;    // 列数

// ================= 单个楔形块模块 =================
module wedge() {
    polyhedron(
        points = [
            [0, 0, 0],    // 0: 底面左下
            [0, W, 0],    // 1: 底面右下
            [L, W, 0],    // 2: 底面右上
            [L, 0, 0],    // 3: 底面左上
            [L/2, 0, H],  // 4: 顶部前顶点
            [L/2, W, H]   // 5: 顶部后顶点
        ],
        faces = [
            [3,2,1,0],  // 底面
            [0,1,5,4],  // 前侧面
            [1,2,5],    // 右侧面
            [2,3,4,5],  // 后侧面
            [0,4,3]     // 左侧面
        ]
    );
    // // 底部凸起
    // cuboid([L, W, c_height], anchor = BOTTOM);
}

// ================= 横向排列的楔形块 =================
module horizontal_row() {
    wedge();
}

// ================= 竖向排列的楔形块 =================
module vertical_row() {
    rotate([0, 0, 90])
    wedge();
}

// ================= 搓衣板纹理生成 =================
module washboard_pattern() {
    for (i = [0:rows-1]) {
        for (j = [0:cols-1]) { 
            translate([j * (L + spacing), i * (W + spacing), 0]){
                if (i % 2 == 0) {   
                    if (j % 2 == 0) {
                        horizontal_row();
                    } else {
                        translate([L, 0, 0])
                        vertical_row();
                    }
                } 
                else {
                    if (j % 2 == 0) {
                        translate([L, 0, 0])
                        vertical_row();
                    } else {
                        horizontal_row();
                    }
                }
            }
        }
    }
}

// ================= 渲染 =================
washboard_pattern();