include <BOSL2/std.scad>


module A(){
    // 内部结构
    difference(){
        cuboid([3.75 + 2.5 , 3.75 + 2.5, 1], anchor = [-1,-1,0]);

        translate([0, 0, -0.1])
            cuboid([3.75 , 3.75, 1 + 0.2], anchor = [-1,-1,0]);
    }

    translate([3.75, 3.75, 0])
    difference(){
        cuboid([6, 6, 4], anchor = [-1,-1,0]);

        translate([0, 0, -2])
            linear_extrude(height = 4)
                polygon([
                    [0,0],
                    [2.5,0],
                    [0,2.5]
                ]);
    }
}


module B(){
    // 外壳
    difference(){
        cuboid([12.5, 12.5, 9], anchor = [-1,-1,-1]);

        translate([1, 1, 1])
            cuboid([10.5, 10.5, 8], anchor = [-1,-1,-1]);
    }
}


module C(){
    translate([1, 1, 4.5])
        A();

    // color([1, 1, 1, 0.5])
        B();
}


// ======== 阵列拼接模块 ========
module C_array(cols=2, rows=2, pitch_x=11.5, pitch_y=11.5){
    for (y = [0 : rows-1])
        for (x = [0 : cols-1])
            translate([x * pitch_x, y * pitch_y, 0])
                C();
}


// 完整的箱子
module compare_box(){

    difference(){
        cuboid([153, 153, 136], anchor=[0, 0, -1]);

        translate([0, 0, 18])
            cuboid([153 -18*2, 153 - 18*2, 136 - 18], anchor=[0, 0, -1]);
    }

}


// ======== 生成长方形阵列 ========
scale([2, 2, 2])
    C_array(cols=5, rows=5, pitch_x=11.5, pitch_y=11.5);


scale([2, 2, 2])
    translate([70, 0, 0])
        cuboid([9 , 11.5 * 6 + 1, 9], anchor = [-1,-1,-1]);

scale([2, 2, 2])
    translate([80, 0, 0])
        cuboid([9 , 11.5 * 5 + 1, 9], anchor = [-1,-1,-1]);

// scale([2, 2, 2])
//     translate([0, 80, 0])
//         cuboid([11.5 * 5 + 1 , 11.5 * 5 + 1, 9], anchor = [-1,-1,0]);
        

// compare_box();


