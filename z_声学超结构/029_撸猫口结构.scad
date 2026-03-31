include <BOSL2/std.scad>
include <BOSL2/structs.scad>

$fn = 128;

// =========================
// 固定参数
// =========================
h = 20;
D = 34;
d = 10;
a = 4;
t = 1;

// 底板参数
base_r = 190/2;
base_h = 2;
base_z = h - 2;


// =========================
// 单元参数矩阵
// 每一行格式： [tf, df, theta, x, y]
// =========================
cells = [
    // ===== 第1组 (theta=60, tf=3)
    [3, 1, 60,   0,      0],
    [3, 2, 60,   0,     42],
    [3, 3, 60,  32.64,  26.43],
    [3, 4, 60,  41.08,  -8.73],

    // ===== 第2组 (theta=45, tf=3)
    [3, 1, 45,  19.06, -37.42],
    [3, 2, 45, -19.06, -37.42],
    [3, 3, 45, -41.08,  -8.73],
    [3, 4, 45, -32.64,  26.43],

    // ===== 第3组 (theta=36, tf=3)
    [3, 1, 36,   0,     77],
    [3, 2, 36,  32.91,  69.61],
    [3, 3, 36,  59.84,  48.45],
    [3, 4, 36,  74.93,  17.71],

    // ===== 第4组 (theta=60, tf=4)
    [4, 1, 60,  75.2,  -16.53],
    [4, 2, 60,  59.92, -48.35],
    [4, 3, 60,  33.03, -69.55],
    [4, 4, 60,  -0.4,  -76.99],

    // ===== 第5组 (theta=45, tf=4)
    [4, 1, 45, -33.75, -69.2],
    [4, 2, 45, -60.09, -48.14],
    [4, 3, 45, -75.02, -17.32],
    [4, 4, 45, -75.05,  17.19],

    // ===== 第6组 (theta=36, tf=4)
    [4, 1, 36, -60.17,  48.03],
    [4, 3, 36, -33.39,  69.38]
];


// =========================
// 基础模块
// =========================
module half_ring(a=0, h=30, r=10, thick=1){
    rotate([0,0, a/2 + 180])
        rotate_extrude(angle = 360 - a)
            translate([r, 0, 0])
                square([thick, h]);
}

module A(angle=0, move=0, length=(D-d)/2){
    rotate([0, 0, angle])
        translate([d/2 + move, 0, 0])
            cuboid([length, t, h], anchor=[-1, 0, -1]);
}


// =========================
// 单个单元
// =========================
module cell(tf=3, df=2, theta=36, move_x=0, move_y=0){

    move_z = tf;

    translate([move_x, move_y, -move_z]){

        // 底板
        color([1, 0.5, 1])
            translate([0, 0, -t])
                cylinder(r=D/2, h=t, center=false);

        // 上盖
        color([0.5, 1, 1])
            translate([0, 0, h])
            difference(){
                cylinder(r=D/2, h=tf, center=false);
                cylinder(r=df/2, h=tf, center=false);
            }

        // 外圈
        difference(){
            cylinder(r=D/2, h=h, center=false);
            translate([0, 0, -0.01])
                cylinder(r=D/2 - t, h=h + 0.02, center=false);
        }

        // 内圈半圆环
        half_ring(h=h, r=(d-2*t)/2, thick=t, a=theta * 2);

        // 上下两个棍子
        A(0);
        A(180, a, (D-d)/2-a);

        // 其余辐条
        if(theta == 60)
        {
            A(-theta, a, (D-d)/2-a);
            A(theta,  a, (D-d)/2-a);

            A(-theta*2, -t, (D-d)/2-a + t);
            A(theta*2,  -t, (D-d)/2-a + t);
        }
        else if(theta == 45)
        {
            A(-theta,     -t, (D-d)/2-a + t);
            A(-theta * 2,  a, (D-d)/2-a);
            A(-theta * 3, -t, (D-d)/2-a + t);

            A(theta,       -t, (D-d)/2-a + t);
            A(theta * 2,    a, (D-d)/2-a);
            A(theta * 3,   -t, (D-d)/2-a + t);
        }
        else if(theta == 36)
        {
            A(-theta,     a,  (D-d)/2-a);
            A(-theta * 2, -t, (D-d)/2-a + t);
            A(-theta * 3, a,  (D-d)/2-a);
            A(-theta * 4, -t, (D-d)/2-a + t);

            A(theta,      a,  (D-d)/2-a);
            A(theta * 2,  -t, (D-d)/2-a + t);
            A(theta * 3,  a,  (D-d)/2-a);
            A(theta * 4,  -t, (D-d)/2-a + t);
        }
    }
}


// =========================
// 从矩阵生成阵列
// =========================
module cell_union(data=cells){
    for (row = data)
        cell(
            tf     = row[0],
            df     = row[1],
            theta  = row[2],
            move_x = row[3],
            move_y = row[4]
        );
}


// =========================
// 底板：从同一个矩阵挖孔
// =========================
module base_plate(data=cells){
    difference(){
        translate([0, 0, base_z])
            cylinder(r=base_r, h=base_h, center=false);

        for (row = data)
            translate([row[3], row[4], 0])
                cylinder(r=D/2, h=100, center=false);
    }
}


// =========================
// 阵列 + 底板
// =========================
module array_with_base(data=cells){
    union(){
        base_plate(data);
        cell_union(data);
    }
}


// =========================
// 显示
// =========================
array_with_base();