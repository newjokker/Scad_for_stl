include <BOSL2/std.scad>
include <BOSL2/structs.scad>

$fn = 128;

// 固定参数
h = 20;
D = 34;
d = 10;
a = 4;
t = 1;

// 变化的
tf = 3;
df = 2;
theta = 36; 

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


module cell(tf=3, df=2, theta=36, move_x=0, move_y=0){

    translate([move_x, move_y, 0]){

        // 底板
        color([1, 0.5, 1])
            translate([0, 0, -t])
                cylinder(r=D/2, h=t, center=false);

        // 上盖
        # color([0.5, 1, 1])
            translate([0, 0, h])
            difference(){
                cylinder(r=D/2, h=tf, center=false);
                cylinder(r=df/2, h=tf, center=false);
            }

        // 外圈
        difference(){
            cylinder(r=D/2, h=h, center=false);
            translate([0, 0, -0.01])
                cylinder(r=D/2 -t, h=h + 0.02, center=false);
        }

        // 内圈的半圆
        half_ring(h=h, r=(d-2*t)/2, thick=t, a=theta * 2 );

        // 上下两个棍子
        A(0);
        A(180, a, (D-d)/2-a );

        // 其他缺口
        if(theta == 60)
        {
            A(-theta, a, (D-d)/2-a);
            A(theta, a, (D-d)/2-a);

            A(-theta*2, -t, (D-d)/2-a + t);    
            A(theta*2, -t, (D-d)/2-a + t);
        }
        else if(theta == 45)
        {
            A(-theta, -t, (D-d)/2-a + t);
            A(-theta * 2, a, (D-d)/2-a);
            A(-theta * 3, -t, (D-d)/2-a + t);
            
            A(theta, -t, (D-d)/2-a + t);
            A(theta * 2, a, (D-d)/2-a);
            A(theta * 3, -t, (D-d)/2-a + t);
        }
        else if(theta == 36)
        {
            A(-theta, a, (D-d)/2-a);
            A(-theta * 2, -t, (D-d)/2-a + t);
            A(-theta * 3, a, (D-d)/2-a);
            A(-theta * 4, -t, (D-d)/2-a + t);

            A(theta, a, (D-d)/2-a);
            A(theta * 2, -t, (D-d)/2-a + t);
            A(theta * 3, a, (D-d)/2-a);
            A(theta * 4, -t, (D-d)/2-a + t);
            
        }

    }

}

// ===== 第1组 (theta=60, tf=3)
cell(tf=3, df=1, theta=60, move_x=0, move_y=0);
cell(tf=3, df=2, theta=60, move_x=0, move_y=42);
cell(tf=3, df=3, theta=60, move_x=32.64, move_y=26.43);
cell(tf=3, df=4, theta=60, move_x=41.08, move_y=-8.73);

// ===== 第2组 (theta=45, tf=3)
cell(tf=3, df=1, theta=45, move_x=19.06, move_y=-37.42);
cell(tf=3, df=2, theta=45, move_x=-19.06, move_y=-37.42);
cell(tf=3, df=3, theta=45, move_x=-41.08, move_y=-8.73);
cell(tf=3, df=4, theta=45, move_x=-32.64, move_y=26.43);

// ===== 第3组 (theta=36, tf=3)
cell(tf=3, df=1, theta=36, move_x=0, move_y=77);
cell(tf=3, df=2, theta=36, move_x=32.91, move_y=69.61);
cell(tf=3, df=3, theta=36, move_x=59.84, move_y=48.45);
cell(tf=3, df=4, theta=36, move_x=74.93, move_y=17.71);

// ===== 第4组 (theta=60, tf=4)
cell(tf=4, df=1, theta=60, move_x=75.2, move_y=-16.53);
cell(tf=4, df=2, theta=60, move_x=59.92, move_y=-48.35);
cell(tf=4, df=3, theta=60, move_x=33.03, move_y=-69.55);
cell(tf=4, df=4, theta=60, move_x=-0.4, move_y=-76.99);

// ===== 第5组 (theta=45, tf=4)
cell(tf=4, df=1, theta=45, move_x=-33.75, move_y=-69.2);
cell(tf=4, df=2, theta=45, move_x=-60.09, move_y=-48.14);
cell(tf=4, df=3, theta=45, move_x=-75.02, move_y=-17.32);
cell(tf=4, df=4, theta=45, move_x=-75.05, move_y=17.19);

// ===== 第6组 (theta=36, tf=4)
cell(tf=4, df=1, theta=36, move_x=-60.17, move_y=48.03);
cell(tf=4, df=3, theta=36, move_x=-33.39, move_y=69.38);